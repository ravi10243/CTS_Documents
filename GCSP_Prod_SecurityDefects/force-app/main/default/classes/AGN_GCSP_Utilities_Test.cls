@isTest
public class AGN_GCSP_Utilities_Test{
    /*@isTest(SeeAllData=True)
    private static Id getFolderId(){
        List<Folder> l = [SELECT AccessType,Id FROM Folder WHERE AccessType = 'Public' LIMIT 1];
        return l[0].Id;
    }*/
    
    @isTest(SeeAllData=True)
    private static EmailTemplate getEmailTemp(){
        List<EmailTemplate> l = [SELECT Body,DeveloperName,FolderId,FolderName,HtmlValue,Id,IsActive,Name,Subject,TemplateType FROM EmailTemplate LIMIT 1];
        return l[0];
    }
    
    public static testmethod void utilitiesTest(){
        
        User user = AGN_GCSP_CustReg_TestUtilityClass.createUser();
        /*User u = new User();
        Profile sp = [SELECT Id, Name FROM Profile WHERE Name='AGN GCSP Lightning Profile' LIMIT 1];
        UserRole urole = [SELECT Name,Id FROM UserRole WHERE Name = 'CSMGR' LIMIT 1]; 
        u = new User(Alias = 'agn', Email='pk@vp.kp', 
                     EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='de', 
                     LocaleSidKey='de', ProfileId = sp.Id, UserRoleId = urole.Id,
                     TimeZoneSidKey='Europe/London', UserName='pk@vp.kp',Country_Code__c='DE');
        
        insert u;       */ 
        System.runAs(user){
            User u = AGN_GCSP_CustReg_TestUtilityClass.createCompleteCommunityUser();
            //Profile p = [SELECT Id, Name FROM Profile WHERE Name='Allergan Customer Community Login DE' LIMIT 1];
            //u.ProfileId = p.Id;
            //update u;
            //u.contact.Customer_Registration_AGN__c='Complete';
            //update u;
            
            AGN_GCSP_Common_Setting_AGN__mdt mdt = AGN_GCSP_CustReg_TestUtilityClass.createCommonSettingsMethod();
            System.assertNotEquals(mdt, null);
            
            Test.startTest();
            
            AGN_GCSP_Utilities.getGCSPCommonSetting();
            
            list<User> userList = AGN_GCSP_Utilities.geUserDetails('MyERwtest112211@utility.com');
            
            system.assertEquals(userList.isEmpty(), true);
            String myString = 'teest';
            object myObj = myString;
            AGN_GCSP_Utilities.nullOrEmpty(myObj);
            AGN_GCSP_Utilities.getLabelString('none');
            AGN_GCSP_Utilities.getLabelString('DE');
            AGN_GCSP_Utilities.getLabelString('ES');
            AGN_GCSP_Utilities.getLabelString('FR');
            AGN_GCSP_Utilities.getLabelString('IT');
            AGN_GCSP_Utilities.getLabelString('EN_GB');
            AGN_GCSP_Utilities.getLabelString('EN_AU');
            AGN_GCSP_Utilities.getLabelString('EN_NZ');
            AGN_GCSP_Utilities.getLabelString('EN_CA');
            AGN_GCSP_Utilities.getLabelString('EN_US');
            AGN_GCSP_Utilities.getLabelString('FR_CA');
            AGN_GCSP_Utilities.getLabelString('PT_BR');
            
            
            AGN_GCSP_Utilities.generateRandomString(8);
            AGN_GCSP_Utilities.findUserBy(u.contactId, u.Username);
            AGN_GCSP_Utilities.findUserBy(null, u.Username);
            AGN_GCSP_Utilities.getsObjectDetails('Account', 'Name', 'Id', null, '1', 'Name');
            System.runAs(u){
            AGN_GCSP_Utilities.getADRegStepInfos();
            }
            AGN_GCSP_Utilities.getADRegCurrentStepUrl('4');
            AGN_GCSP_Utilities.saveCaseRequest(null,'a','b','c');
            AGN_GCSP_Utilities.CheckRegistrationStatus();
            
            
            /*EmailTemplate e = new EmailTemplate (developerName = 'test', TemplateType= 'Text', Name = 'test', Subject='Test Email', HtmlValue=null, Body = 'Inside Template body.', FolderId=getFolderId(), IsActive=True); 
            insert e;*/
            EmailTemplate e = getEmailTemp();
            e.Body = 'Dear {!Recipient.FirstName} {!Recipient.LastName} We have received a request to change your password. Please Click Here to enter your new password. Please note: passwords must contain at least six characters and cannot be the same as your username or email address. If you did not make this request, please ignore this email. Many thanks, SF Admin';
            update e;
            
            Attachment att = AGN_GCSP_CustReg_TestUtilityClass.createAttachment(e);
            
            Map<String, String> subpm = new Map<String, String>();
            subpm.put('{!Case.Name}', 'C-00001');
            
            Map<String, String> bodypm = new Map<String, String>();
            bodypm.put('{!Recipient.FirstName}', 'Test');
            bodypm.put('{!Recipient.LastName}', 'User');
            
            AGN_EmailMessageWrapper msg = new AGN_EmailMessageWrapper('cs-germany@allergan.com.invalid', (string)u.Email, u.Id, null, 'This is the subject of test mail for {!Case.Name}', subpm, 'This is the body of test mail', bodypm);
            List<AGN_EmailMessageWrapper> listEmail = new List<AGN_EmailMessageWrapper>();
            listEmail.add(msg);
            
            //(String fromAddr, String toAddr, Id toAddrId, String bccAddr, String sub, Map<String, String>  mapSubjectParams, String body, Map<String, String> mapBodyParams) 
            
            AGN_GCSP_Utilities.sendEmail(listEmail, (String)e.Name, (String)msg.FromAddress);
            Integer inv = Limits.getEmailInvocations();
            System.assertEquals(0, inv); //blocking test class to send emails
            
            Test.stopTest();
        }
    }
}