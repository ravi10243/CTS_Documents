public with sharing class AGN_ApproveRejectCaseExtension {
    
    public ProcessInstance apProcess{get;set;}
    public ProcessInstanceWorkitem workItem{get;set;}
    
    public Case caso{get;set;}
    public ApexPages.standardController controller{get;set;}
    public string comments{get;set;}
    public string operation{get;set;}
    public String userAgent{get;set;}
    public Boolean isConsole{get;set;}
    public PageReference pageRef {get;set;}
    public Boolean isIpad{get;set;}
    public boolean manageAll{get;set;}
    public string massOperation{get;set;}
    public list<ProcessInstanceWorkitem> workItems;
    public list<id> casesListIds{get;set;}
        
    public AGN_ApproveRejectCaseExtension(ApexPages.standardController controller){

        userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(userAgent.contains('iPad'))
            isIpad=true;
        else
            isIpad=false;
        String userId = UserInfo.getUserId();
        pageRef = new PageReference(ApexPages.currentPage().getUrl());
         if(string.valueOf(pageRef).contains('Console'))
            isConsole=true;
         else
             isConsole=false;
             
        map<string,string> pageParameters = ApexPages.currentPage().getParameters();
        
        //query queues
        List<GroupMember> lstGroupMembers = [SELECT GroupId FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId()];
        List<Id> groupIds = new List<Id>();
        for (GroupMember gm : lstGroupMembers) {
            groupIds.add(gm.GroupId);
        }
        
        lstGroupMembers = [SELECT GroupId FROM GroupMember WHERE ( UserOrGroupId IN: groupIds OR UserOrGroupId =: UserInfo.getUserId() ) AND Group.Type = 'Queue'];
        for (GroupMember gm : lstGroupMembers) {
            groupIds.add(gm.GroupId);
        }
        
        if(pageParameters.containsKey('ids') && pageParameters.containsKey('massOperation') ){
            manageAll = true;
            massOperation = pageParameters.get('massOperation');
            casesListIds = pageParameters.get('ids').split('--');
            workItems = [SELECT ActorId, Actor.Name, CreatedDate, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name
                                FROM ProcessInstanceWorkitem
                                WHERE (ActorId =: userId OR ActorId IN: groupIds) AND ProcessInstance.TargetObjectId in:casesListIds AND ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type = 'Case'];
        }else{
            manageAll = false;

            id caseId = controller.getId();
            caso = [SELECT ownerId,caseNumber,Approver_AGN__c FROM Case where id=:caseId];
            workItem = [SELECT ActorId, Actor.Name, CreatedDate, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name
                                FROM ProcessInstanceWorkitem
                                WHERE (ActorId =:userId OR ActorId IN: groupIds) AND ProcessInstance.TargetObjectId=:caseId AND ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type = 'Case'];          
        }
    }
    
    public pageReference doCancel() {
        
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        PageReference pageRef = new PageReference(retURL);
        
        //return pageRef;
       return null;
        
    }
    
    public Pagereference doApprove(){
        operation = 'Approve';
        return execute();
    }
    
    public Pagereference doReject(){
        operation = 'Reject';
        return execute();
    }
    
    public pageReference execute(){
        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
        pwr.setAction(operation);
        pwr.setWorkitemId(workItem.id);
        pwr.setComments(comments);
        system.debug('ProcessWorkitemRequest' + pwr);
        Approval.Process(pwr);
        
        return new PageReference('/home/home.jsp');   
    } 
    
    public pageReference executeMass(){
        list<Approval.ProcessWorkitemRequest> items =  new list<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workit: workitems){ //obtener todos los workitem
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setAction(massOperation);
            pwr.setWorkitemId(workit.id);
            pwr.setComments(comments);
            items.add(pwr);
        }
        system.debug('massOperation ********* '+massOperation);
        system.debug('items mass ' + massOperation + ': ' + items );
        Approval.Process(items);
        return null;
        //return new PageReference('/home/home.jsp');
    }
    
    public pageReference cancel(){
        return null;
        //return new PageReference('/home/home.jsp');
    }

}