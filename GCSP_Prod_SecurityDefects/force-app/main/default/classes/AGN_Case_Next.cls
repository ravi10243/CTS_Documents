/*
Type Name: AGN_Case_Next
Reason: Next button on case layout for Case Assignment and Approval process submission.
*/
global without sharing class AGN_Case_Next {
    
    @InvocableMethod
    public static void sendCaseToNextStep(List<Id> caseIds){
        
        gotoNextStep(caseIds[0]);             
    }
        
    webservice static void gotoNextStep(ID caseId){
        
        //string [] errorMessage = new string []{'Case has been successfully assigned.'};
        //boolean dmlSuccess = false;
    
        Case caseToUpdate = [select Id, OwnerId, Case_Step_Number_AGN__c, Status,Sub_Status_AGN__c,RecordType.Name,Escalated_to_QA_AGN__c,Approved_Rejected_QA_AGN__c from Case where Id = :caseId limit 1];
        
        if((caseToUpdate.RecordType.Name!= 'Support Request - Customer Registration' || caseToUpdate.RecordType.Name!='Support Request - Customer Update') && (caseToUpdate.Status=='Working' || caseToUpdate.Status=='Assigned') && (caseToUpdate.Approved_Rejected_QA_AGN__c == 'Rejected') && (caseToUpdate.Sub_Status_AGN__c.contains('Customer Service')) && (caseToUpdate.Case_Step_Number_AGN__c>=3)) 
        {
            System.debug('Inside QA change');
            caseToUpdate.Escalated_to_QA_AGN__c = true;
        }
        
        gotoNextStep(caseId, userinfo.getUserId());
    }
    
    public static ID gotoNextStep(ID caseId, String submitterUserID){
        
        Case caseToUpdate = [select Id, OwnerId, Case_Step_Number_AGN__c, Status from Case where Id = :caseId limit 1];
        
        //Trigger Case Assignment rules
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        dmo.EmailHeader.triggerUserEmail = true;
        caseToUpdate.setOptions(dmo);
        update caseToUpdate;                  
        
        //Trigger Case Approval Processes
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(caseId);
        req.setSubmitterId(submitterUserID);
        //req.setProcessDefinitionNameOrId(cs.Approval_Process_ID__c);
        req.setSkipEntryCriteria(false);
        try{
            Approval.ProcessResult result = Approval.process(req);
            //Blanck Update to initiate the milistone
            case c = new case(Id=caseId) ;
            update c; 
        }catch(System.Exception e){
            system.debug('Exception: ' + e);
            return caseId;
        }
        return caseId;
        
    }
}