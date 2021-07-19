/*
*------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev Roushan
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        1.0
* @created        
* @modified      15-Nov-2019
* @testClass      
* ----------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019           
* Creates community User for Request type Access,Portablity and Information for GDPR and CCPA request types.
*-------------------------------------------------------------------------------------------------------------------------+
*/
public with sharing class AGN_GDPR_Case_Create_Community_User
{ 
    /* Method created for Task completed and Access check to open popup */   
    @AuraEnabled
    public static String createAcc(Id caseId)
    {
        case objCase = new case();
        List<Case> CaseList = [SELECT ContactId,Data_Subject_Email_GDPR_AGN__c,Data_Subject_Phone_GDPR_AGN__c,
                               Currently_Accessible_AGN__c,First_Name_GDPR_AGN__c,Full_Name_GDPR_AGN__c,
                               Id,Last_Name_GDPR_AGN__c,Phone_GDPR_AGN__c,Request_Type_GDPR_AGN_new__c,
                               Role_with_Allergan_GDPR_AGN__c,Status,RecordTypeId,RecordType.DeveloperName FROM Case Where Id = :caseId];
        
        
        if(((CaseList[0].Request_Type_GDPR_AGN_new__c=='Specific pieces of personal information (Access)') && CaseList[0].Status == 'Task Completed' && (CaseList[0].RecordType.DeveloperName == 'CCPA_Case' || CaseList[0].RecordType.DeveloperName == 'Contact_Center_AGN') && CaseList[0].Currently_Accessible_AGN__c == false))
        {
            return 'Task Completed CCPA';  
        }
        else if((CaseList[0].RecordType.DeveloperName.contains ('GDPR') &&(CaseList[0].Request_Type_GDPR_AGN_new__c.contains ('Access') || CaseList[0].Request_Type_GDPR_AGN_new__c.contains ('Portability')) && CaseList[0].Status == 'Task Completed'))
        {
            String resp = createAcc1(CaseList[0].ID);
            return resp;
        }
        else
        {
            return 'InComplete';  
        }
    }
    
    
    public static String createAcc1(Id caseId)
    {
        String response ='CannotCreate';
        String lname;
        case objCase = new case();
        List<Case> CaseList = [SELECT ContactId,Data_Subject_Email_GDPR_AGN__c,Data_Subject_Phone_GDPR_AGN__c,
                               Currently_Accessible_AGN__c,First_Name_GDPR_AGN__c,Full_Name_GDPR_AGN__c,
                               Id,Last_Name_GDPR_AGN__c,Phone_GDPR_AGN__c,Request_Type_GDPR_AGN_new__c,
                               Role_with_Allergan_GDPR_AGN__c,Status,RecordTypeId,RecordType.DeveloperName FROM Case Where Id = :caseId];
        
        if(CaseList[0].Last_Name_GDPR_AGN__c == null)
        {    
            lname = CaseList[0].Data_Subject_Email_GDPR_AGN__c.split('@')[0];
        }
        else
        {
            lname = CaseList[0].Last_Name_GDPR_AGN__c;
        }
        
        System.Debug('Case List --> ' +CaseList);
        
        if(CaseList.size() > 0)
        {
            if (((CaseList[0].Request_Type_GDPR_AGN_new__c.contains ('Access') || CaseList[0].Request_Type_GDPR_AGN_new__c.contains ('Portability')) && CaseList[0].Status == 'Task Completed' && CaseList[0].RecordType.DeveloperName.contains ('GDPR')) ||
                ((CaseList[0].Request_Type_GDPR_AGN_new__c.contains ('Access')) && CaseList[0].Status == 'Task Completed' && (CaseList[0].RecordType.DeveloperName == 'CCPA_Case' || CaseList[0].RecordType.DeveloperName == 'Contact_Center_AGN')))
            {
                // To check a GDPR User
                String comSuffix= System.Label.AGN_DSRM_Community_Suffix;
                String  usrname = CaseList[0].Data_Subject_Email_GDPR_AGN__c+'.'+comSuffix;
                
                List<User> CurrUser = [Select Id,IsActive,IsPortalEnabled,Email,CreatedDate  from User where username = :usrname];
                List<Contact> contct = New List<Contact>();
                
                System.Debug('Existing User Details --> ' +CurrUser);
                
                if (CurrUser.size() > 0)
                {
                   contct =[Select Id from Contact where Email = :CurrUser[0].Email];
                    if (CurrUser[0].IsActive == true && CaseList[0].Currently_Accessible_AGN__c == false)
                    {
                        response='UserExisting';
                        
                        //Date modified on User
                        Date d =  date.today();   
                        
                        List<AGN_GDPR_LoginExtension__c> lstCSLogin = new List<AGN_GDPR_LoginExtension__c>();
                        lstCSLogin = AGN_GDPR_LoginExtension__c.getall().values();
                     
                        Date extendedDate = d.addDays(Integer.valueOf(lstCSLogin[0].Days_to_Extend_AGN_GDPR__c)); 
                        
                        system.debug('EXTENDED DATE --> '+extendedDate);
                        
                        User u = new User();
                        u.Id = CurrUser[0].Id;
                        u.Access_Till_AGN_GDPR__c = extendedDate;
                        Update u;
                        
                        Case cs = new Case();
                        cs.ID= CaseList[0].Id;
                        cs.Currently_Accessible_AGN__c= true;
                        cs.ContactId=contct[0].Id;
                        cs.Portal_User_AGN__c = CurrUser[0].Id;
                        cs.Portal_User_active_date_AGN__c = date.valueOf(CurrUser[0].CreatedDate);
                        try
                        {
                            update cs;
                            
                            System.Debug('Existing Active User Inside ****' +CurrUser);
                        }
                        catch(DmlException e) 
                        {
                            System.debug('The following exception has occurred: ' + e.getMessage());
                        }         
                    }
                    else if(CurrUser[0].IsActive == false) 
                    {   
                        System.Debug('Existing Inactive User Inside ****' +CurrUser);
                        List<Contact> ConList = [Select Id, Email from Contact WHERE Email = :CaseList[0].Data_Subject_Email_GDPR_AGN__c];
                        System.Debug('Contact for the Case should be: ' +ConList);
                        
                        if (ConList.size() > 0)
                        {
                            //Update Case with existing Contact
                            try
                            {
                                objCase.Id= CaseList[0].Id;
                                objCase.ContactId = ConList[0].Id;
                                objCase.Currently_Accessible_AGN__c = True;
                               // objCase.ContactId=contct[0].Id;
                                objCase.Portal_User_AGN__c = CurrUser[0].Id ;
                                objCase.Portal_User_active_date_AGN__c = date.today();
                                update objCase;
                            }
                            catch(DmlException e) 
                            {
                                System.debug('The following exception has occurred: ' + e.getMessage());
                            }
                            
                            System.Debug('Contact for the Case is: ' +objCase);
                        }
                        activateUser(CurrUser[0].Id);
                        response='UserActivated';
                    }
                    else
                    {
                        response='UserExisting';
                    }
                }
                else
                {
                    List<Contact> ConList = [Select Id, Email from Contact WHERE Email = :CaseList[0].Data_Subject_Email_GDPR_AGN__c];
                    System.Debug('Contact for the Case should be: ' +ConList);
                    if (ConList.size() > 0)
                    {
                        //Update Case with existing Contact
                        try
                        {
                            objCase.Id= CaseList[0].Id;
                            objCase.ContactId = ConList[0].Id;
                            objCase.Currently_Accessible_AGN__c = True;
                            //objCase.ContactId=contct[0].Id;
                            update objCase;
                        }
                        catch(DmlException e) 
                        {
                            System.debug('The following exception has occurred: ' + e.getMessage());
                        }
                        System.Debug('Contact for the Case is: ' +objCase);
                        createUser(ConList[0].id,CaseList[0].RecordType.DeveloperName,CaseList[0].id);
                        response='UserCreated';
                    }
                    else
                    {
                        RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' and SObjectType = 'Account'];
                        try
                        {
                            Account Acct = new Account();
                            Acct.FirstName = CaseList[0].First_Name_GDPR_AGN__c;
                            Acct.LastName = lname;
                            Acct.RecordType = personAccountRecordType;
                            Acct.PersonEmail  = CaseList[0].Data_Subject_Email_GDPR_AGN__c;
                            Acct.Phone = CaseList[0].Data_Subject_Phone_GDPR_AGN__c;
                            insert Acct;
                            
                            System.Debug('Account Created ****' +Acct);
                            
                            //Update Case with existing Contact
                            Contact cont = [SELECT Id FROM CONTACT WHERE AccountId = :Acct.Id];
                            
                            objCase.Id= CaseList[0].Id;
                            objCase.ContactId = cont.Id;
                            objCase.Currently_Accessible_AGN__c = True;
                            update objCase;
                            System.Debug('Contact for the Case is: ' +objCase);
                            
                            createUser(cont.id,CaseList[0].RecordType.DeveloperName,CaseList[0].id);
                            response='UserCreated';
                            
                        }
                        catch(DmlException e) 
                        {
                            System.debug('The following exception has occurred: ' + e.getMessage());
                        }
                        
                    }
                    
                }
            }
        }
        return response;
    }
    /* Method created by Rahil for sending email after Save button click on popup */
    @AuraEnabled 
    public static String sendMailMethod(Id caseId,String body,Boolean partialcompleted,Boolean fullCompleted)
    {     
        String resp;
        Case caseObj = new Case();
        User usr = new User();
        caseObj = [SELECT Id,Data_Subject_Email_GDPR_AGN__c,CaseNumber,Full_Name_GDPR_AGN__c,
              Request_Type_GDPR_AGN__c,RecordType.DeveloperName,Status,
              DPO_Verified_the_Mail_Content_AGN__c,First_Name_GDPR_AGN__c,Last_Name_GDPR_AGN__c from Case where ID = :caseId];
        
        if(partialcompleted == true)
        {
            caseObj.DS_Email_Subject_GDPR_AGN__c  = '['+caseObj.CaseNumber+'] '+ System.Label.AGN_ACCESS_COMPLETE_INSTRUCTION_SUBJECT;  
        }
        else if(fullCompleted == true)
        {
            caseObj.DS_Email_Subject_GDPR_AGN__c = '['+caseObj.CaseNumber+'] '+ System.Label.AGN_ACCESS_PARTIALLY_COMPLETE_AND_EXPLANATION_SUBJECT;  
        }
        caseObj.DS_Email_Body_AGN__c = body;
        caseObj.DPO_Verified_the_Mail_Content_AGN__c = true;
    
        External_Email_Communication_GDPR_AGN__c externalEmailObj = new External_Email_Communication_GDPR_AGN__c();
        externalEmailObj.Associated_Case_GDPR_AGN__c=caseId;
        externalEmailObj.Email_Sent_To__c=caseObj.Data_Subject_Email_GDPR_AGN__c;
         if(partialcompleted == true)
        {
             externalEmailObj.Email_Subject_GDPR_AGN__c  = '['+caseObj.CaseNumber+'] '+ System.Label.AGN_ACCESS_COMPLETE_INSTRUCTION_SUBJECT;     
        }
        else if(fullCompleted == true)
        {
              externalEmailObj.Email_Subject_GDPR_AGN__c = '['+caseObj.CaseNumber+'] '+ System.Label.AGN_ACCESS_PARTIALLY_COMPLETE_AND_EXPLANATION_SUBJECT;  
        }
        externalEmailObj.Email_From_GDPR_AGN__c='System Owner';
        externalEmailObj.Email_Body_GDPR_AGN__c=body;
        
        try
        {
            insert externalEmailObj;
            update caseObj;
            system.debug('==>1 ' + externalEmailObj.Id);  
            
        }
        catch(DmlException e)
        {   
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
        System.debug('Last Line');
        resp = createAcc1(caseObj.ID);
        System.debug('Response Sent'+resp);
        return resp;
    }
    
    @future
    Public static void createUser(Id ConID ,String pos, ID caseId)
    {
        String lastName;
        String position;
        String emailbody;
        String emailSubject;
        
        Contact contactObj = [SELECT Id,Email,FirstName,LastName FROM CONTACT WHERE Id = :ConID];
        Profile userProfile = [SELECT Id FROM profile WHERE name='AGN_DS_Community_User' limit 1];
        Case caseObj = [SELECT Id,Data_Subject_Email_GDPR_AGN__c,CaseNumber,Full_Name_GDPR_AGN__c,
              Request_Type_GDPR_AGN__c,RecordType.DeveloperName,Status,
              DPO_Verified_the_Mail_Content_AGN__c,First_Name_GDPR_AGN__c,Last_Name_GDPR_AGN__c,DS_Email_Subject_GDPR_AGN__c,DS_Email_Body_AGN__c from Case where ID = :caseId];
        
        emailbody =caseObj.DS_Email_Body_AGN__c;
        emailSubject = caseObj.DS_Email_Subject_GDPR_AGN__c;
    
        if(contactObj.LastName == null)
        {    
            lastName = contactObj.Email.split('@')[0];
        }
        else
        {
            lastName = contactObj.LastName;
        }
        
        if(pos == 'CCPA_Case' ||pos == 'Contact_Center_AGN')
        {
            position ='CCPA';
        }
        else if(pos =='GDPR_DPO'||pos =='GDPR_Case')
        {
            position ='GDPR';
        }
        
        
        // adds .dsrm to the username as an suffix from the custom label
        String suffix= System.Label.AGN_DSRM_Community_Suffix;
        String  usname = contactObj.Email+'.'+suffix;
        try
        {
            User NewUser = new User(contactId=contactObj.Id, 
                                    username=usname,
                                    firstname=contactObj.FirstName, 
                                    lastname=lastName, 
                                    email=contactObj.Email,
                                    communityNickname = contactObj.LastName + '_'+Math.random(),
                                    Alias = (lastName.substring(0,2) +string.valueOf(math.random()).substring(0,6)), 
                                    profileid = userProfile.Id,
                                    Position_AGN__c = position,
                                    emailencodingkey='UTF-8',
                                    languagelocalekey='en_US', 
                                    localesidkey='en_US', 
                                    timezonesidkey='America/Los_Angeles',
                                    IsActive=True,
                                    AGN_Community_Email_Subject__c=emailSubject,
                                    AGN_Community_Email_Body__c=emailbody);                  
            insert NewUser;
            System.Debug('User Created ****' +NewUser);
            System.setPassword(NewUser.Id,'dsrmccpa@123');  
            
        }
        catch(DmlException e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    } 
    
    @future
    Public static void activateUser( Id UserId)
    {
        //Update the user
        try
        {
            User U = New user();
            U.Id = UserId;
            U.IsActive = true;
            update U;
            
            System.Debug('The updated user is: ' +U);
            List<User> usr = new List<User>();
            usr = [Select Username from User where Id =:U.Id];
            Site.forgotPassword(usr[0].Username);
        }
        catch(DmlException e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }  
}