/**************************************************************************************************************************
@ Class:          AGN_AMI_CertificateController
@ Version:        1.0
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
@ Purpose:        Controller class for AGN_AMI_Certificate component.
@ PMO:            CR-3277: Enable Certification (CPD) after Curriculum completion (badging).
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 08.05.2020 / JOYDEV MONDOL / Created the class.
***************************************************************************************************************************/

public class AGN_AMI_CertificateController {
    public String userLanguage {get; set;}
    public Account accRecord {get; set;}
    public AMI_CPD_Granted_AGN__c ach{get; set;}
    public Date validTillDate {get; set;}
    
    /**********************************************************************************************************************
    @ Constructor:    AGN_AMI_CertificateController 
    @ Version:        1.0
    @ Author:         Sujan Guha (sujan.guha@cognizant.com)
    @ Purpose:        Initialises the class members.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 01.07.2020 / Sujan Guha / Created the constructor
    ***********************************************************************************************************************/
    
    public AGN_AMI_CertificateController(){
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        accRecord = userDetails.accountRecord;
        getCertDetails();
    }
        
    //PMO #3277 method for fetching certification details
        public void getCertDetails(){

        ach=[SELECT Achieved_Certification_AGN_AMI__r.Name,CreatedDate,AMI_Certificate_Id_AGN__c,HCP_AGN_AMI__r.Name,Id,Achieved_Certification_AGN_AMI__c,
             Achieved_Certification_AGN_AMI__r.Certificate_Location_AGN_AMI__c,Achieved_Certification_AGN_AMI__r.Certificate_Zinc_Code_AGN_AMI__c,
             Achieved_Certification_AGN_AMI__r.Certification_Validaity_AGN_AMI__c, LastModifiedDate,
             Achieved_Certification_AGN_AMI__r.Certificate_Logo_AGN_AMI__c,Achieved_Certification_AGN_AMI__r.First_Signature_Image_AGN_AMI__c,
             Achieved_Certification_AGN_AMI__r.First_Signature_Text_AGN_AMI__c,Achieved_Certification_AGN_AMI__r.Valid_Through_AGN_AMI__c,      
             Achieved_Certification_AGN_AMI__r.Second_Signature_Image_AGN_AMI__c,Achieved_Certification_AGN_AMI__r.Second_Signature_Text_AGN_AMI__c,
             Account_name_AGN_AMI__c,Achieved_Certification_AGN_AMI__r.CertificateBackground_AGN_AMI__c,DateOfCompletion_AGN_AMI__c  
             FROM AMI_CPD_Granted_AGN__c 
             WHERE Achieved_Certification_AGN_AMI__r.Active_AGN_AMI__c=TRUE AND
             HCP_AGN_AMI__c =: accRecord.Id LIMIT 1];
        
        validTillDate = ach.DateOfCompletion_AGN_AMI__c.date().addYears((Integer)ach.Achieved_Certification_AGN_AMI__r.Certification_Validaity_AGN_AMI__c);
    }    
}