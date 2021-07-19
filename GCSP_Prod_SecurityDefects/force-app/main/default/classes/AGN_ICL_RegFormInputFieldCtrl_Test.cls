@isTest
public class AGN_ICL_RegFormInputFieldCtrl_Test 
{
    
    static testmethod void method1()
    {
        Account acc=new Account(Name='TestAcc',Type='Customer - Channel');
        insert acc;
        //AGN_ICL_TestRegFormInputFieldController obj = new AGN_ICL_TestRegFormInputFieldController();

        Test.startTest();
        //PicklistWrapper p=new PicklistWrapper();
        
        
        Schema.DescribeFieldResult F = Account.Type.getDescribe();     
        List<Schema.PicklistEntry> p1 =F.getPicklistValues();
        Schema.PicklistEntry x=p1[0];
        
       //cklistWrapper q=new PicklistWrapper(x);
        
        //List<PicklistWrapper> pw=new List<PicklistWrapper>();
        AGN_ICL_TestRegFormInputFieldController.getPicklistValues('Locator_Listing_AGN__c','Approval_Status__c');
        System.assertEquals(acc.Type,'Customer - Channel');
        Test.stopTest();
     }
    

}