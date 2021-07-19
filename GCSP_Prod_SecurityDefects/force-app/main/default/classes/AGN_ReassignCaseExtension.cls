public with sharing class AGN_ReassignCaseExtension {

    public Case caso{get;set;}
    public boolean manageAll{get;set;}
    public boolean noRecords{get;set;}

    public ProcessInstanceWorkitem workItem{get;set;}
    public list<ProcessInstanceWorkitem> workItems{get;set;}
    
    public AGN_ReassignCaseExtension(ApexPages.StandardController controller){
        String userId = UserInfo.getUserId();
        
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
        
        if(pageParameters.containsKey('ids')){ //we reassign a list of cases. we get a list of steps and a list of workitems
            manageAll = true;
            
            list<string> casesListIds = pageParameters.get('ids').split('--');
            workItems = [SELECT ActorId, OriginalActorId, Actor.Name, CreatedDate, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name
                                                FROM ProcessInstanceWorkitem
                                                WHERE (ActorId =:userId OR ActorId IN: groupIds) AND ProcessInstance.TargetObjectId in:casesListIds AND ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type = 'Case'];
            
            list<id> workItemsIds = new list<id>();
            for(ProcessInstanceWorkitem workitem : workitems)
                workItemsIds.add(workItem.id);
            if(!workItems.isEmpty())
                workItem = workItems[0];
        
        }else if(controller.getId() != null){ //we only reassign one case. we get the step for the comments and the workitemid for the actor
            manageAll = false;

            id caseId = controller.getId();
            caso = [SELECT ownerId,caseNumber,Approver_AGN__c FROM Case where id=:caseId];
            
            workItem = [SELECT ActorId, OriginalActorId, Actor.Name, CreatedDate, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name
                                                FROM ProcessInstanceWorkitem
                                                WHERE (ActorId = :userId OR ActorId IN: groupIds) AND ProcessInstance.TargetObjectId=:caseId AND ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type = 'Case'];
            
            system.debug('workitem: ' + workitem);
            system.debug('id: ' + caseId);
            
        }
        
    }
    
    public pageReference reassign(){
        update workItem;
        return new PageReference('/home/home.jsp');   
//        return new PageReference('/apex/CasesToApprove');
    }

    public pageReference reassignAll(){
        for(ProcessInstanceWorkitem wk: workitems){
            wk.actorId = workItem.actorId ;
        }
        update workitems;
        return new PageReference('/home/home.jsp');   
//        return new PageReference('/apex/CasesToApprove');
    }

    
    public pageReference cancel(){
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));        
    }
    
}