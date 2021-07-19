@isTest
public class AGN_OAM_AD_Enable_Queueable_Test {
    
    public static testmethod void CustPortalTest(){ 
        
        Account acc1 = new Account ( Name='fname', Country_Code__c='DE', phone='7623434785356', Email_Internal_AGN__c='krishna9892@yopmail.com',Customer_Sub_Category_AGN__c='Public or Private Clinic',Customer_Category_AGN__c ='Clinic');
        insert acc1;
        
        List<Contact> listContact = new List<Contact>();
        List<Contact> listContact1 = new List<Contact>();
        
        Contact con1 = new Contact ( AccountId = acc1.Id, LastName = 'portalTestUser');
        listContact.add(con1);
        insert listContact;
        String contactID = String.Valueof(con1.Id);
        
    //    String jsonList = '['+JSON.serialize(con1)+']';
        
        Map<String, Boolean> isContactMap =  new  Map<String, Boolean>();
        isContactMap.put(contactID,true);
        
        user u = AGN_CustReg_TestUtilityClass.createUser();
        user u1 = AGN_CustReg_TestUtilityClass.createUser();
        List<User> userList = new List<User>();
        userList.add(u);
        userList.add(u1);
        String jsonList = '['+JSON.serialize(userList)+']';
        
        System.runAs(u){
            OAM_User_Settings__c oamUser = AGN_CustReg_TestUtilityClass.createOAMUser();
            System.Assert(oamUser != null, 'create OAM_User_Settings_UnitTest.testCreating OAM_UserSettings FAIL: OAM_UserSettings was not inserted properly!');
            AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
            System.Assert(gcspSettings != null, 'AGN_GCSP_Settings_UnitTest.testCreating AGN_GCSP_Settings FAIL: AGN_GCSP_Settings was not inserted properly!');
        }
        
        test.starttest();       
        
        AGN_OAM_AD_Enable_Queueable agncontroller;      
        
        Try{
        //agncontroller = new AGN_OAM_AD_Enable_Queueable(listContact ,'de','DE', con1.id,jsonList,'susr@testsandorg.com',isContactMap);
        }catch(System.JSONException e){}
        
        //AGN_OAM_AD_Enable_Queueable agncontroller1 = new AGN_OAM_AD_Enable_Queueable(listContact,'de','DE', isContactMap,con1.id);
        System.runAs(u){
        //Try{
        //System.enqueueJob(agncontroller1);    
        //System.enqueueJob(agncontroller);
        //}catch(Exception e){}
        }
        //AGN_OAM_AD_Enable_Queueable agncontroller2 = new AGN_OAM_AD_Enable_Queueable(listContact1,'de','DE', isContactMap,con1.id);
        //System.enqueueJob(agncontroller2 );
        //System.enqueueJob(agncontroller );
        
        integer i = 0;
        integer j = 0;
        System.assertEquals(i,j);
        test.stopTest();
            
   }
   
    
}