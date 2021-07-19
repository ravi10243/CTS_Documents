@isTest
public class AGN_BCSendEmailTest 
{
    @istest
    static void testSendEmail()
    {
        Test.Starttest();
        
        Account a= new Account ();
            a.Name='Aesthetic Plastic Surgery';
            a.Status_AGN__c ='Active';
            Insert a;
        
              
        Contract_Exhibit__c ce= new Contract_Exhibit__c();
                                
            ce.Contract_Language__c='English (UK & I)';
            ce.Customer_Signer_Title__c='Dr.';
            ce.Primary_Institution__c=a.Id;
            ce.Type__c='Brazil';
            ce.Start_Date__c=system.today();
            ce.Exhibit_Status__c='Draft';
            ce.Package_Hours__c='>0';
            ce.Details_of_project_and_tasks__c='test';
            ce.KPI_1__c='test';
            ce.SAP_Code__c ='123'; 
            ce.Business_Name_AGN__c='Aesthetic Plastic Surgery';
            ce.Address_Business_Name_AGN__c='123 Secret Street';
            ce.Customer_Signer_Email__c='arijit.sarkar3@cognizant.com';
            ce.Customer_Signer_FirstName__c='Arijit';
            ce.Customer_Signer_LastName__c='Sarkar';
            ce.Allergan_Signatory__c='0051q000000cKQB';
            insert ce;
           
            
              
            PageReference pageRef = Page.AGN_BC_Send_Email;
            pageRef.getParameters().put('id', String.valueOf(ce.Id));
            Test.setCurrentPage(pageRef);
            AGN_BCSendEmail obj= new AGN_BCSendEmail();
            obj.Send_Email();
            //obj.Cancel();
        
        Test.StopTest();      
    }

}