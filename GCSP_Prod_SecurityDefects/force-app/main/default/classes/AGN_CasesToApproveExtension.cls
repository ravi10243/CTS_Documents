public with sharing class AGN_CasesToApproveExtension {

    private string fieldSetDeveloperName{get;set;}
    private list<string> casesId = new list<String>();
    public list<CaseWrapper> casesWrapper{get;set;}
    public string operation{get;set;}   
    public boolean hasRecords{get;set;}
    public List<SelectOption> views {get; set;}
    public String selectedView {get;set;}
    public List <string> selectedFields {get; set;}
    private string fullURL;
    public Boolean isConsole{get;set;}
    public PageReference pageRef;
    public Boolean editHide{get;set;}
    public string urlString{get;set;}
    public String userAgent{get;set;}
    public Boolean isIpad{get;set;}
    public Boolean myFlag{get;set;}
    public PageReference returnPage{get;set;} 
    public List<SelectOption> sortExpression {get;set;}
    public String sortExpressionSt{get;set;}
    public List<SelectOption> sortDirection {get;set;}
    public String sortDirectionSt {get;set;}
    public String firstSortExpVal = 'None';
    public String firstSortDirVal = 'None';
    
    //Appending code to capture and maintain the last view for the User he accessed; by Debopriyo Dey
    List<GCSP_Items_to_Approve_AGN__c> lastView;
    Boolean noViewAssigned;
    string userId;
    String userNm;
    public Boolean preselected{get;set;}
    List<CaseToApproveFieldSet_AGN__c> defView;
    
    public AGN_CasesToApproveExtension(ApexPages.standardController controller){
        
        fullURL = URL.getCurrentRequestUrl().toExternalForm();
        system.debug('fullURL '+fullURL);
        if(fullURL.contains('Console'))
            isConsole=true;
        pageRef = new PageReference(ApexPages.currentPage().getUrl());
        userId = UserInfo.getUserId();
        
        lastView = new List<GCSP_Items_to_Approve_AGN__c>();
        
        String userName=UserInfo.getUserName();
        
        userNm=UserInfo.getName();
        userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        
        if(userAgent.contains('iPad'))
            isIpad=true;
        else
            isIpad=false;
        
        sortExpression = new List<SelectOption>();
        sortDirection = new List<SelectOption>();       
        
        List <CaseToApproveFieldSet_AGN__c> lstViews = [SELECT Id, Name, Selectedfields_AGN__c FROM CaseToApproveFieldSet_AGN__c WHERE User_AGN__c =: userId];
        views = new List<SelectOption>();
        system.debug('views '+views);
        defView = [SELECT Id, Name, Selectedfields_AGN__c FROM CaseToApproveFieldSet_AGN__c where Name='Default' and User_AGN__c =null];
        views.add(new SelectOption(defView[0].Id, System.Label.CaseDefault_AGN));
        
        for (CaseToApproveFieldSet_AGN__c cfs : lstViews){
            views.add(new SelectOption(cfs.Id, cfs.Name));
        }
        
        preselected=false;           
                   
        selectedFields = new List<String>();
        
        fieldSetDeveloperName = 'CasesToApproveFieldSet';
        
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
        
        list<ProcessInstanceWorkitem> items = [SELECT ActorId, Actor.Name, CreatedDate, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name
                                                FROM ProcessInstanceWorkitem
                                                WHERE (ActorId = :userId OR ActorId IN: groupIds) AND ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type = 'Case'];
        if(items.isEmpty()){
            hasRecords = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,System.Label.CaseNoCasesToManage));
            return;
        }else{
            hasRecords = true;
        }
        
        for(ProcessInstanceWorkitem item : items){
            casesId.add(item.ProcessInstance.TargetObjectId);
        }
        List<String> lstFields;
       Map<String,String> dupCheck = new map<String,String>();
       String query = '';
         lastView=[select Last_accessed_view_AGN__c from GCSP_Items_to_Approve_AGN__c where User_Id_AGN__c =:userId];
       System.debug('@LAST ACCESSED View '+lastView);
        system.debug('selectedView  1========>'+selectedView);
        if(lastView.size() > 0 && lastView != NULL){
             if(lastView[0].Last_accessed_view_AGN__c == defView[0].Id){
                 preselected=false;
                 noViewAssigned=true;
                 selectedView = defView[0].Id;
             }
             else{
             selectedView=lastView[0].Last_accessed_view_AGN__c;
             system.debug('selectedView  2========>'+selectedView);
             noViewAssigned=false;
             preselected=true;
             }
        }
        else{
             noViewAssigned=true;
             selectedView = defView[0].Id;
        } 
       CaseToApproveFieldSet_AGN__c lastViewed;
        if (lstViews.size()==0){ 
            query = 'SELECT caseNumber ';
            lstFields = defView[0].Selectedfields_AGN__c.split(';');
            for (String field : lstFields){
                        system.debug('query looping   '+query);
                        query += (', ' + field);
                        selectedFields.add(field);
                    }
            query += ' FROM Case where id in: casesId' ;     
        }  else {
           myFlag=true;
           query = 'SELECT caseNumber ';
            if(noViewAssigned)
                lstFields = defView[0].Selectedfields_AGN__c.split(';');
            else{
                lastViewed = [select Selectedfields_AGN__c,Where_Clause_AGN__c,Sort_Criteria_AGN__c,Sort_Expression_AGN__c,Sort_Order_AGN__c from CaseToApproveFieldSet_AGN__c where id=:selectedView];
                lstFields = lastViewed.Selectedfields_AGN__c.split(';');
            }
            system.debug('selectedView  3========>'+selectedView);
            system.debug('lstFields '+lstFields);
            for (String field : lstFields){
                        system.debug('query looping   '+query);
                        query += (', ' + field);
                        selectedFields.add(field);
                    }
            query += ' FROM Case where id in: casesId' ;
        }
        //===========Sort Logic Added=======================//
        sortExpression.add(new SelectOption('None',System.Label.CaseNone_AGN));
        sortExpression.add(new SelectOption('CaseNumber',System.Label.CaseNumber_AGN));
        Schema.SObjectType newsObject = Schema.getGlobalDescribe().get('Case');
        Map<String, Schema.SObjectField> o = newsObject.getDescribe().fields.getMap();
        for(String s : lstFields){
            for(Schema.SObjectField field : o.values()) {
                String apiname=field.getDescribe().getName();
                String type = string.valueOf(field.getDescribe().getType());
                if(apiname.equals(s) && type!='textarea' )
                    sortExpression.add(new SelectOption(s,field.getDescribe().getLabel()));
            }
        }
        system.debug('selectedView  4========>'+selectedView);    
        sortDirection.add(new SelectOption('None',System.Label.CaseNone_AGN));
        sortDirection.add(new SelectOption('ASC',System.Label.CaseAscending_AGN));
        sortDirection.add(new SelectOption('DESC',System.Label.CaseDescending_AGN));
        sortExpressionSt='None';
        sortDirectionSt='None';
        //==================END========================//
        if(lastViewed != NULL){
            if(lastViewed.Where_Clause_AGN__c != NULL && lastViewed.Where_Clause_AGN__c != ''){                
                query += ' AND ( ' +  lastViewed.Where_Clause_AGN__c + ' )';
            }
            if(lastViewed.Sort_Criteria_AGN__c != NULL && lastViewed.Sort_Criteria_AGN__c != ''){
                sortExpressionSt = lastViewed.Sort_Expression_AGN__c;
                sortDirectionSt = lastViewed.Sort_Order_AGN__c;
                query += ' ' + lastViewed.Sort_Criteria_AGN__c;
            }
        }        
        system.debug('query: ' + query);
        list<Case> cases = Database.query(query);
        system.debug('selectedView  5========>'+selectedView);
        casesWrapper = new list<CaseWrapper>();
        for(Case c : cases)
            casesWrapper.add(new CaseWrapper(c, false));        
        system.debug('casesWrapper: ' + casesWrapper);            
    }    
    
    public boolean viewExists(string viewId, list<CaseToApproveFieldSet_AGN__c> views){
        for(CaseToApproveFieldSet_AGN__c view: views )
            if(view.Id == viewId && view.Selectedfields_AGN__c != null){
                return true;
            } 
        return false;
    }
    
    public void initialize(){
        if (selectedView != null && selectedView != ''){
            changeView();
        }
    }

    public void reassign(){
        string parameters = 'ids=';
        for(CaseWrapper c: casesWrapper){
            if(c.checked){
                if(parameters=='ids=') 
                    parameters += c.caseField.id;
                else
                    parameters+= '--' + c.caseField.id; 
            }
        }
        urlString = 'apex/AGN_ReassignCase?' + parameters + '&retURL=/home/home.jsp' ;
        
    }

    public void redirectToApproveRejectPage(){
        string parameters = 'ids=';
        for(CaseWrapper c: casesWrapper){
            if(c.checked){
                if(parameters=='ids=') 
                    parameters += c.caseField.id;
                else
                    parameters+= '--' + c.caseField.id; 
            }
        }
        urlString = 'apex/AGN_ApproveRejectCase?' + parameters + '&massOperation=' + operation + '&retURL=/home/home.jsp';        
    }
    
    public list<Case> getChecked(){
        list<Case> checkedCases = new list<Case>();
        
        for(CaseWrapper cw :casesWrapper){
            if(cw.checked){
                checkedCases.add(cw.caseField);
            }
        }
        return checkedCases;
    }


    public class CaseWrapper{
        public Case caseField{get;set;}
        public boolean checked{get;set;}

        public CaseWrapper(Case caseField, boolean checked){
            this.caseField = caseField;
            this.checked = checked;
        }
        
    }
    public pageReference deleteView(){
        String viewName = [Select Name from CaseToApproveFieldSet_AGN__c where id=:selectedView].Name;
        if(viewName != 'Default'){
            CaseToApproveFieldSet_AGN__c view = [SELECT Id FROM CaseToApproveFieldSet_AGN__c WHERE id=:selectedView];
            delete view;
            preselected=false;
             lastView=[select Id,Last_accessed_view_AGN__c from GCSP_Items_to_Approve_AGN__c where User_Id_AGN__c =:userId];
             lastView[0].Last_accessed_view_AGN__c=defView[0].Id;
             upsert lastView;
        }
        return null;
    }
    public Pagereference sortTable(){        
        selectedFields.clear();
        String query='';
        String storeSortExpressionSt = '';
        String storeSortDirectionSt = '';
        String storeSortCriteria = '';
        storeSortExpressionSt = sortExpressionSt;
        CaseToApproveFieldSet_AGN__c viewDetails = [SELECT Id, Name, Selectedfields_AGN__c,Where_Clause_AGN__c,Sort_Expression_AGN__c,Sort_Order_AGN__c,Sort_Criteria_AGN__c FROM CaseToApproveFieldSet_AGN__c WHERE Id =: selectedView];
                       
            query = 'SELECT Id';
            if (viewDetails.Selectedfields_AGN__c != null) {
                list <string> lstFields = viewDetails.Selectedfields_AGN__c.split(';');
                if (lstFields != null) {
                    for (string field : lstFields){
                        if (!field.equalsIgnoreCase('CaseNumber')){
                            selectedFields.add(field);
                            query += (', ' + field);
                            system.debug('query  %%%%%%%%%%%%% '+query);
                        }
                    }
                }
            }
            query += ', caseNumber FROM Case where id in: casesId ' ;
        if(viewDetails.Where_Clause_AGN__c != NULL && viewDetails.Where_Clause_AGN__c != ''){
            query += ' AND ( ' +  viewDetails.Where_Clause_AGN__c + ' )';
        }                
        //==========Check Type for Lookup Field===============//
            Schema.SObjectType newsObject = Schema.getGlobalDescribe().get('Case');
            Map<String, Schema.SObjectField> o = newsObject.getDescribe().fields.getMap();
                for(Schema.SObjectField field : o.values()) {
                    String apiname=field.getDescribe().getName();
                    String type = string.valueOf(field.getDescribe().getType());
                    if(apiname.equals(sortExpressionSt) && type=='reference'){
                        if(sortExpressionSt.contains('__c')){                            
                            sortExpressionSt=sortExpressionSt.substring(0,sortExpressionSt.length()-1)+'r.Name';
                        }else{
                            sortExpressionSt=sortExpressionSt.substring(0,sortExpressionSt.length()-2)+'.Name';
                        }
                            
                    }                       
                }        
        system.debug('query=======>'+query);
        if(sortDirectionSt != null && sortDirectionSt != 'None' && sortExpressionSt != null && sortExpressionSt != 'None'){
            if(sortDirectionSt=='ASC'){
                storeSortCriteria = ' Order by '+sortExpressionSt+ ' ' + sortDirectionSt+' NULLS first';
                query+= storeSortCriteria;
                if(viewDetails.Name != 'Default'){
                    viewDetails.Sort_Expression_AGN__c = storeSortExpressionSt;
                    viewDetails.Sort_Order_AGN__c = sortDirectionSt;
                    viewDetails.Sort_Criteria_AGN__c = storeSortCriteria;
                }
            }else{
                storeSortCriteria = ' Order by '+sortExpressionSt+ ' ' + sortDirectionSt+' NULLS last';
                query+= storeSortCriteria;
                if(viewDetails.Name != 'Default'){
                    viewDetails.Sort_Expression_AGN__c = storeSortExpressionSt;
                    viewDetails.Sort_Order_AGN__c = sortDirectionSt;
                    viewDetails.Sort_Criteria_AGN__c = storeSortCriteria;
                }
            }
               upsert viewDetails;
        }
        system.debug('query=======>'+query);
        List<Case> cases = Database.query(query);
        system.debug('<======= cases ========> '+cases);
        system.debug('<========= Wrapper Before Clear ==========>'+casesWrapper +'AND Size==>'+casesWrapper.size());
        casesWrapper.clear();
        system.debug('<========= Wrapper After Clear ==========>'+casesWrapper);
        for(Case c : cases){
            casesWrapper.add(new CaseWrapper(c,false));
        }        
        system.debug('<======= casesWrapper ========> '+casesWrapper +'AND Size==>'+casesWrapper.size());
        return null;
    }
    
    public Pagereference changeView(){
        sortExpressionSt = 'None';
        sortDirectionSt = 'None';
        system.debug('sortDirectionSt===>'+sortDirectionSt+'AND sortDirectionSt====>'+sortDirectionSt);
        String viewName = [Select Name from CaseToApproveFieldSet_AGN__c where id=:selectedView].Name;
        if(viewName== 'Default'){
            myFlag=false;
            preselected=false;
        }
        else
           {
            myFlag=true;
            editHide=true;
           }
        selectedFields = new List<String>();
       
        String query = '';
        if (selectedView == 'default'){
          preselected=false;
        } else {
            CaseToApproveFieldSet_AGN__c viewDetails = [SELECT Id, Name, Selectedfields_AGN__c,Where_Clause_AGN__c,Sort_Criteria_AGN__c,Sort_Expression_AGN__c,Sort_Order_AGN__c FROM CaseToApproveFieldSet_AGN__c WHERE Id =: selectedView];
            List<String> fields = viewDetails.Selectedfields_AGN__c.split(';');
            sortExpression.clear();
            sortExpression.add(new SelectOption('None',System.Label.CaseNone_AGN));
            sortExpression.add(new SelectOption('CaseNumber',System.Label.CaseNumber_AGN));
            Schema.SObjectType newsObject = Schema.getGlobalDescribe().get('Case');
            Map<String, Schema.SObjectField> o = newsObject.getDescribe().fields.getMap();
            for(String s : fields){
                //Added for Sorting logic
                for(Schema.SObjectField field : o.values()) {
                    String apiname=field.getDescribe().getName();
                    String type = string.valueOf(field.getDescribe().getType());
                    if(apiname.equals(s) && type!='textarea' )
                        sortExpression.add(new SelectOption(s,field.getDescribe().getLabel()));
                }
            }
            query = 'SELECT Id';
            system.debug('viewDetails '+viewDetails );
            if (viewDetails.Selectedfields_AGN__c != null) {
                list <string> lstFields = viewDetails.Selectedfields_AGN__c.split(';');
                if (lstFields != null) {
                    for (string field : lstFields){
                        if (!field.equalsIgnoreCase('CaseNumber')){
                            selectedFields.add(field);
                            query += (', ' + field);
                            system.debug('query  %%%%%%%%%%%%% '+query);
                        }
                    }
                }
            }            
            query += ', caseNumber FROM Case where id in: casesId ' ;            
            if(viewDetails.Where_Clause_AGN__c != NULL && viewDetails.Where_Clause_AGN__c != ''){                
                query += ' AND ( ' +  viewDetails.Where_Clause_AGN__c + ' )';
            }                
            if(viewDetails.Sort_Criteria_AGN__c != NULL && viewDetails.Sort_Criteria_AGN__c != ''){
                sortExpressionSt = viewDetails.Sort_Expression_AGN__c;
                sortDirectionSt = viewDetails.Sort_Order_AGN__c;
                query += ' ' + viewDetails.Sort_Criteria_AGN__c;
            }            
        }        
        system.debug('query=======>'+query);
        List<Case> cases = Database.query(query);
        system.debug('<======= cases ========> '+cases.size());
        casesWrapper = new list<CaseWrapper>();
        for(Case c : cases){
            casesWrapper.add(new CaseWrapper(c, false));
        }
        system.debug('<======= casesWrapper ========> '+casesWrapper);
        lastView=[select id,Last_accessed_view_AGN__c from GCSP_Items_to_Approve_AGN__c where User_Id_AGN__c =:userId];
       
        if(lastView.size() > 0 && lastView != NULL){
            lastView[0].Last_accessed_view_AGN__c=selectedView;
        }
        else{
            lastView.add(new GCSP_Items_to_Approve_AGN__c(Name=userNm,User_Id_AGN__c=userId,Last_accessed_view_AGN__c=selectedView));
        }
        upsert lastView;        
        return null;        
    }

    public Pagereference createNewView() {
        return new Pagereference('/apex/AGN_CaseViewFieldsPicker?retURL=' + EncodingUtil.urlEncode(fullURL,'UTF-8') );
    }
    
    public Pagereference editView() {
        String viewName = [Select Name from CaseToApproveFieldSet_AGN__c where id=:selectedView].Name;
        if(viewName!='Default')
            return new Pagereference('/apex/AGN_CaseViewFieldsPicker?id=' + selectedView + '&retURL=' + EncodingUtil.urlEncode(fullURL,'UTF-8'));
        else
            return new Pagereference('/home/home.jsp');         

     }

}