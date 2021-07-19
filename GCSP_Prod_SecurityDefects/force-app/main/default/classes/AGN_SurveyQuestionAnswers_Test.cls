@isTest
public class AGN_SurveyQuestionAnswers_Test {

   @testSetup static void Test_Data_Setup()
    {
        //Id accrectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital_vod').getRecordTypeId();
        Account a = new Account();
        a.Name = 'test account';
        a.Status_AGN__c = 'Active';
        //a.RecordTypeId = accrectype;
        insert a;
        
        Contract_Exhibit__c con1 = new Contract_Exhibit__c();
        con1.Primary_Institution__c = a.Id;
        con1.Type__c = 'Brazil';
        con1.Exhibit_Status__c = 'Draft';
        con1.Start_Date__c = System.today();
        con1.Contract_Language__c = 'English (UK & I)';
        con1.Currency__c = 'GBP (UK)';
        con1.Package_Hours__c = '>0';
        con1.Exhibit_Hours__c = 25;
        con1.Details_of_project_and_tasks__c = 'testing';
        con1.KPI_1__c = 'testing';
        con1.SAP_Code__c = '964644';
        con1.Business_Name_AGN__c = 'test exhibit';
        con1.Address_Business_Name_AGN__c = 'test address';
        insert con1;
        
        ApexPages.currentPage().getParameters().put('Id', con1.Id);
        ApexPages.currentPage().getParameters().put('Language', 'English (UK AND I)');
        BC_Survey_Answer_Type_AGN__c type1 = new BC_Survey_Answer_Type_AGN__c();
        type1.name = 'answer type 1';
        type1.Language_AGN__c = 'English (UK AND I)';
        insert type1;
        
        BC_Survey_Answer_Type_AGN__c type2 = new BC_Survey_Answer_Type_AGN__c();
        type2.name = 'answer type 2';
        type2.Language_AGN__c = 'English (UK AND I)';
        insert type2;
        
        BC_Survey_Question_AGN__c que1 = new BC_Survey_Question_AGN__c();
        que1.isActive_AGN__c = true;
        que1.BC_Survey_Answer_Type_AGN__c = type1.Id;
        que1.Display_order_AGN__c = 1;
        que1.Language_AGN__c = 'English (UK AND I)';
        que1.Question_AGN__c = 'The Allergan Business Consulting project met my expectations';
        insert que1;
        
        BC_Survey_Question_AGN__c que2 = new BC_Survey_Question_AGN__c();
        que2.isActive_AGN__c = true;
        que2.BC_Survey_Answer_Type_AGN__c = type2.Id;
        que2.Display_order_AGN__c = 2;
        que2.Language_AGN__c = 'English (UK AND I)';
        que2.Question_AGN__c = 'The project was managed effectively and completed in a timely way';
        insert que2;
        
        BC_Survey_Answer_AGN__c ans1 = new BC_Survey_Answer_AGN__c();
        ans1.isActive_AGN__c = true;
        ans1.Answer_AGN__c = 'Agree';
        ans1.BC_Survey_Answer_Type_AGN__c = type1.Id;
        ans1.Display_order_AGN__c = 1;
        ans1.Language_AGN__c = 'English (UK AND I)';
        ans1.weightage_AGN__c = '5';
        insert ans1;
        
        BC_Survey_Answer_AGN__c ans2 = new BC_Survey_Answer_AGN__c();
        ans2.isActive_AGN__c = true;
        ans2.Answer_AGN__c = 'Disagree';
        ans2.BC_Survey_Answer_Type_AGN__c = type1.Id;
        ans2.Display_order_AGN__c = 1;
        ans2.Language_AGN__c = 'English (UK AND I)';
        ans2.weightage_AGN__c = '1';
        insert ans2;
        
        BC_Survey_Answer_AGN__c ans3 = new BC_Survey_Answer_AGN__c();
        ans3.isActive_AGN__c = true;
        ans3.Answer_AGN__c = 'yes';
        ans3.BC_Survey_Answer_Type_AGN__c = type2.Id;
        ans3.Display_order_AGN__c = 1;
        ans3.Language_AGN__c = 'English (UK AND I)';
        ans3.weightage_AGN__c = '10';
        insert ans3;
        
        BC_Survey_Answer_AGN__c ans4 = new BC_Survey_Answer_AGN__c();
        ans4.isActive_AGN__c = true;
        ans4.Answer_AGN__c = 'no';
        ans4.BC_Survey_Answer_Type_AGN__c = type2.Id;
        ans4.Display_order_AGN__c = 1;
        ans4.Language_AGN__c = 'English (UK AND I)';
        ans4.weightage_AGN__c = '5';
        insert ans4;
    }
    
    public static testMethod void fetching_test()
    {
        AGN_SurveyQuestionAnswers_Test.Test_Data_Setup();
        AGN_SurveyQuestionAnswers sqa = new AGN_SurveyQuestionAnswers();
        sqa.getFetching_survey_questions();
        sqa.Survey_question_answer_Transaction();
    }
}