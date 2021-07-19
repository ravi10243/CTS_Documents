public class SplitCase_Controller_AGN_GDPR {
    @AuraEnabled
    public static List<Case> ValidateCaseDetails(Id caseId) 
    {
        List<Case> ca = new List<Case>();
        ca = [SELECT CaseNumber,Id,Affiliation_GDPR_AGN__c,Affiliation_Bus_Clinic_Name_GDPR_AGN__c,Status, 
              Person_Allergan_Employee_GDPR_AGN__c, Comments_GDPR_AGN__c, Case_Creation_Channel_GDPR_AGN__c, Country_AGN_GDPR__c, 
              Data_Subject_Email_GDPR_AGN__c, Date_of_Form_Submission_GDPR_AGN__c, Date_recieved_AGN_GDPR__c, DPO_Comment_GDPR_AGN__c,
              DS_Selected_Language_GDPR_AGN__c, E_Mail_Address_GDPR_AGN__c, Expected_Case_Close_Date_GDPR_AGN__c, First_Name_GDPR_AGN__c,
              Full_Address_GDPR_AGN__c, Full_Name_GDPR_AGN__c, Way_of_Indentify_GDPR_AGN__c, Justification_for_Others_Role_GDPR_AGN__c, 
              Last_Name_GDPR_AGN__c, Data_Subject_Phone_GDPR_AGN__c, Phone_GDPR_AGN__c, Postal_Country_AGN_GDPR__c, Post_State_GDPR_AGN__c,
              Post_Street_Address_GDPR_AGN__c, Post_Town_City_GDPR_AGN__c, Post_Zip_GDPR_AGN__c, Provide_additional_Information_AGN__c,
              Provide_Consent_GDPR_AGN__c, OptINOthers_AGN_GDPR__c, Rectification_changes_GDPR_AGN__c, Request_Type_GDPR_AGN_new__c, Role_with_Allergan_GDPR_AGN__c,
              State_GDPR_AGN__c, Street_Address_GDPR_AGN__c, Person_E_Mail_Address_GDPR_AGN__c, Person_First_Name_GDPR_AGN__c,
              Person_Last_Name_GDPR_AGN__c, Person_Requester_Relationship_GDPR_AGN__c, Submitting_for_Another_Person_GDPR_AGN__c,
              Titile_AGN_GDPR__c,RecordTypeId,Town_City_GDPR_AGN__c,RejectCase_AGN__c,Mail_Sent_AGN__c,Initial_Closed_Date_AGN__c,Personal_Data_GDPR_AGN__c, Withdraw_Consent_GDPR_AGN__c, OptOUTOthers_AGN_GDPR__c,Split_Case_AGN__c,
              Zip_AGN_GDPR__c FROM Case WHERE Id = :caseId];
        
        //system.debug('Request Type :' + ca[0].Request_Type_GDPR_AGN_new__c);
        // system.debug('Request Type Size :' + ca[0].Request_Type_GDPR_AGN_new__c.split(';').size());
        
        if(ca[0].Status =='Under Review' && ca.size() > 0 && ca[0].Split_Case_AGN__c == false && ca[0].Request_Type_GDPR_AGN_new__c.split(';').size() > 1)
        {
            List<Case> lstSplitCases = new List<Case>();
            
            for(string requestType : ca[0].Request_Type_GDPR_AGN_new__c.split(';'))
            {
                Case objcase = new Case();
                objcase.ParentId = ca[0].Id;
                objcase.Affiliation_GDPR_AGN__c = ca[0].Affiliation_GDPR_AGN__c;
                objcase.Affiliation_Bus_Clinic_Name_GDPR_AGN__c = ca[0].Affiliation_Bus_Clinic_Name_GDPR_AGN__c;
                objcase.Status = ca[0].Status;
                objcase.Person_Allergan_Employee_GDPR_AGN__c = ca[0].Person_Allergan_Employee_GDPR_AGN__c;
                objcase.Comments_GDPR_AGN__c = ca[0].Comments_GDPR_AGN__c;
                objcase.Case_Creation_Channel_GDPR_AGN__c = ca[0].Case_Creation_Channel_GDPR_AGN__c;
                objcase.Country_AGN_GDPR__c = ca[0].Country_AGN_GDPR__c;
                objcase.Data_Subject_Email_GDPR_AGN__c = ca[0].Data_Subject_Email_GDPR_AGN__c;
                objcase.Date_of_Form_Submission_GDPR_AGN__c = ca[0].Date_of_Form_Submission_GDPR_AGN__c;
                objcase.Date_recieved_AGN_GDPR__c = ca[0].Date_recieved_AGN_GDPR__c;
                objcase.DPO_Comment_GDPR_AGN__c = ca[0].DPO_Comment_GDPR_AGN__c;
                objcase.DS_Selected_Language_GDPR_AGN__c = ca[0].DS_Selected_Language_GDPR_AGN__c;
                objcase.E_Mail_Address_GDPR_AGN__c = ca[0].E_Mail_Address_GDPR_AGN__c;
                objcase.Expected_Case_Close_Date_GDPR_AGN__c = ca[0].Expected_Case_Close_Date_GDPR_AGN__c;
                objcase.First_Name_GDPR_AGN__c = ca[0].First_Name_GDPR_AGN__c;
                objcase.Full_Address_GDPR_AGN__c = ca[0].Full_Address_GDPR_AGN__c;
                objcase.Full_Name_GDPR_AGN__c = ca[0].Full_Name_GDPR_AGN__c;
                objcase.Way_of_Indentify_GDPR_AGN__c = ca[0].Way_of_Indentify_GDPR_AGN__c;
                objcase.Justification_for_Others_Role_GDPR_AGN__c = ca[0].Justification_for_Others_Role_GDPR_AGN__c;
                objcase.Last_Name_GDPR_AGN__c = ca[0].Last_Name_GDPR_AGN__c;
                objcase.Data_Subject_Phone_GDPR_AGN__c = ca[0].Data_Subject_Phone_GDPR_AGN__c;
                objcase.Phone_GDPR_AGN__c = ca[0].Phone_GDPR_AGN__c;
                objcase.Postal_Country_AGN_GDPR__c = ca[0].Postal_Country_AGN_GDPR__c;
                objcase.Post_State_GDPR_AGN__c = ca[0].Post_State_GDPR_AGN__c;
                objcase.Post_Street_Address_GDPR_AGN__c = ca[0].Post_Street_Address_GDPR_AGN__c;
                objcase.Post_Town_City_GDPR_AGN__c = ca[0].Post_Town_City_GDPR_AGN__c;
                objcase.Post_Zip_GDPR_AGN__c = ca[0].Post_Zip_GDPR_AGN__c;
                objcase.Provide_additional_Information_AGN__c = ca[0].Provide_additional_Information_AGN__c;
                objcase.Provide_Consent_GDPR_AGN__c = ca[0].Provide_Consent_GDPR_AGN__c;
                objcase.OptINOthers_AGN_GDPR__c = ca[0].OptINOthers_AGN_GDPR__c;
                objcase.Rectification_changes_GDPR_AGN__c = ca[0].Rectification_changes_GDPR_AGN__c;
                objcase.Request_Type_GDPR_AGN_new__c = requestType;
                objcase.Role_with_Allergan_GDPR_AGN__c = ca[0].Role_with_Allergan_GDPR_AGN__c;
                objcase.State_GDPR_AGN__c = ca[0].State_GDPR_AGN__c;
                objcase.Street_Address_GDPR_AGN__c = ca[0].Street_Address_GDPR_AGN__c;
                objcase.Person_E_Mail_Address_GDPR_AGN__c = ca[0].Person_E_Mail_Address_GDPR_AGN__c;
                objcase.Person_First_Name_GDPR_AGN__c = ca[0].Person_First_Name_GDPR_AGN__c;
                objcase.Person_Last_Name_GDPR_AGN__c = ca[0].Person_Last_Name_GDPR_AGN__c;
                objcase.Person_Requester_Relationship_GDPR_AGN__c = ca[0].Person_Requester_Relationship_GDPR_AGN__c;
                objcase.Submitting_for_Another_Person_GDPR_AGN__c = ca[0].Submitting_for_Another_Person_GDPR_AGN__c;
                objcase.Titile_AGN_GDPR__c = ca[0].Titile_AGN_GDPR__c;
                objcase.Town_City_GDPR_AGN__c = ca[0].Town_City_GDPR_AGN__c;
                objcase.Personal_Data_GDPR_AGN__c = ca[0].Personal_Data_GDPR_AGN__c;
                objcase.Withdraw_Consent_GDPR_AGN__c = ca[0].Withdraw_Consent_GDPR_AGN__c;
                objcase.OptOUTOthers_AGN_GDPR__c = ca[0].OptOUTOthers_AGN_GDPR__c;
                objcase.Zip_AGN_GDPR__c = ca[0].Zip_AGN_GDPR__c;
                objcase.RecordTypeId = ca[0].RecordTypeId;
                objcase.Mail_Sent_AGN__c=ca[0].Mail_Sent_AGN__c;
                objcase.RejectCase_AGN__c=ca[0].RejectCase_AGN__c;
                lstSplitCases.add(objcase);
            }
            insert lstSplitCases;
            
            Case objInitialCase = new Case();
            objInitialCase.Id = ca[0].Id;
            objInitialCase.Split_Case_AGN__c = true;
            update objInitialCase;
        }
        
        return ca;
    }
}