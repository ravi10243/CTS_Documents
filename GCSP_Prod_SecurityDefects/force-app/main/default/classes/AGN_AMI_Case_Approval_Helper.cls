/**************************************************************************************************************************
@ Class:          AGN_AMI_Case_Approval_Helper 
@ Version:        1.0
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        This is helper class for process builder, which is triggered when a case of AMI Clinical Gallery is approved
@ PMO:            CR-3257: Clinical Gallery Tab
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 15.06.2020 / Ayush Basak / Created the class.
***************************************************************************************************************************/


public class AGN_AMI_Case_Approval_Helper {
    
    /***********************************************************************************************************************
    @ Method:         createProjects
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        Creates AMI Project Records when ever a case of AMI Clinical Gallery is approved
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the method.
	@ Change history: 15.06.2020 / Ayush Basak / Update record creation, removed category field and included Product, 
					  Area and Dosage
    ***********************************************************************************************************************/
    
    @InvocableMethod 
    public static void createProjects(List<ID> ids){
        List<Case> caseList = [SELECT id, AccountId, 
                               ContactId, Description, 
                               Account.Country_vod__c, 
                               Category_AGN_AMI__c, 
                               Title_Submitted_AGN_AMI__c, 
                               Area_AGN_AMI__c,
                               Product_AGN_AMI__c
                               FROM Case 
                               WHERE id IN :ids];
        List<AMI_Project_AGN__c> projectList = new List<AMI_Project_AGN__c>();
        
        for(Case c : caseList){
            // Fields updated as part of Clinical Gallery Enhancement
            AMI_Project_AGN__c project = new AMI_Project_AGN__c(Case_AGN_AMI__c = c.Id, 
                                                                Account_AGN_AMI__c = c.AccountId, 
                                                                Contact_AGN_AM__c = c.ContactId, 
                                                                //Preview_Description_AGN_AMI__c = c.Description,
                                                                Country_AGN__c = c.Account.Country_vod__c, 
                                                                //Category_AGN_AMI__c = c.Category_AGN_AMI__c,
                                                                Description_AGN_AMI__c = c.Description, 
                                                                Title_AGN_AMI__c = c.Title_Submitted_AGN_AMI__c,
                                                                Area_AGN_AMI__c = c.Area_AGN_AMI__c,
                                                                Product_AGN_AMI__c = c.Product_AGN_AMI__c);
            projectList.add(project);
        }
        try{
            insert projectList;
        }
        catch(Exception ex){
            system.debug('Exception : '+ex.getMessage());
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Case_Approval_Helper','createProjects');
            
        }
        
        List<Case> caseUpdateList = new List<Case>();
        for(AMI_Project_AGN__c project : projectList){
            Case updateCase = new Case(Id = project.Case_AGN_AMI__c, 
                                       Clinical_Gallery_Project_AGN_AMI__c = project.Id);
            caseUpdateList.add(updateCase);
        }
        try{
            update caseUpdateList;
        }
        catch(Exception ex){
            system.debug('Exception : '+ex.getMessage());
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Case_Approval_Helper','createProjects');
            
        }
    }
}