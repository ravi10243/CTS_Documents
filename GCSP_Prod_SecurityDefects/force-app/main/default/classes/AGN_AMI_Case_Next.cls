global class AGN_AMI_Case_Next  
{
    webservice static ID gotoNextStep(ID caseId){
        
        Case caseToUpdate = [select Id, OwnerId, Case_Step_Number_AGN__c, Status from Case where Id = :caseId limit 1];
        
        //Trigger Case Assignment rules
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        dmo.EmailHeader.triggerUserEmail = true;
        caseToUpdate.setOptions(dmo);
        update caseToUpdate;                  
        return caseId;        
    }

}