/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Cognizant DSRM Project Management Team
* @createdBy        Rajeev Roushan
* @modifiedBy       Kunal Banerjee
* @maintainedBy   
* @version          1.1
* @created          25th Jan, 2020
* @modified         28th April,2020
* @testClass    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1           
* 28th April,2020   Added code block to stamp ds email verification email and welcome email to 
                    external email communication for GDPR Case , request type access and portability.
                    Defect D3, Regulation GDPR, made changes in Release 3 Sprint 1
                    change in line no: 28-29, 48-49,70-85,113-125
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class AGN_External_Email_Com_Record {
    @InvocableMethod
    public static void ExtenalEmail(List<ID> caseID)
    {
        System.debug('caseID --> '+caseID[0]);
        Id csId = caseID[0];
        List<RecordType> recordtype=[SELECT developerName FROM RecordType WHERE Id in(Select RecordTypeId  from Case where id=:caseId)];
        
        External_Email_Communication_GDPR_AGN__c ex = new External_Email_Communication_GDPR_AGN__c();
        External_Email_Communication_GDPR_AGN__c exWelcomeObj = new External_Email_Communication_GDPR_AGN__c();
        List<External_Email_Communication_GDPR_AGN__c> exEmailCommList = new List<External_Email_Communication_GDPR_AGN__c>();
        List<Case> cs = new List<Case>();
        cs=[Select Id,Status,Data_Subject_Email_GDPR_AGN__c,DS_Selected_Language_GDPR_AGN__c from Case where Id = :csId];
        System.debug('CS'+cs);
        
        ex.Associated_Case_GDPR_AGN__c=csId;
        ex.Email_From_GDPR_AGN__c='System Owner';
        ex.Email_Sent_To__c=cs[0].Data_Subject_Email_GDPR_AGN__c;
        if(recordtype[0].developerName == 'GDPR_Case' || recordtype[0].developerName == 'GDPR_DPO')
        {   
            if(cs[0].Status =='Email Not Verified')
            {
                exWelcomeObj.Associated_Case_GDPR_AGN__c=csId;
                exWelcomeObj.Email_From_GDPR_AGN__c='System Owner';
                exWelcomeObj.Email_Sent_To__c=cs[0].Data_Subject_Email_GDPR_AGN__c;
                
                if(cs[0].DS_Selected_Language_GDPR_AGN__c == 'English')
                {
                    ex.Email_Subject_GDPR_AGN__c=System.Label.AGN_WelcomeEmailNVSubj_GDPR;
                    ex.Email_Body_GDPR_AGN__c=System.Label.AGN_WelcomeEmailNV_GDPR;   
                    //added code block to stamp welcome email subject and body into external email comm for language english
                    exWelcomeObj.Email_Subject_GDPR_AGN__c=System.Label.AGN_WelcomeEmailNewSubj_GDPR;
                    exWelcomeObj.Email_Body_GDPR_AGN__c=System.Label.AGN_WelcomeEmailNew_GDPR;   
                }
                else
                {
                    AGN_GDPR_Language_Settings__c lg = AGN_GDPR_Language_Settings__c.getValues(cs[0].DS_Selected_Language_GDPR_AGN__c); 
                    String langCode=lg.Language_Code_AGN__c; 
                    ExternalString exs = new ExternalString();
                    exs=[SELECT Id FROM ExternalString WHERE Name = 'AGN_WelcomeEmailNV_GDPR'];
                    
                    ExternalStringLocalization ls =new ExternalStringLocalization();
                    ls =[Select Id,Value FROM ExternalStringLocalization WHERE ExternalStringId = :exs.Id AND Language= :langCode];
                    System.debug('Lang'+ls.Value);
                    
                    ExternalString exs1 = new ExternalString();
                    ExternalStringLocalization ls1 =new ExternalStringLocalization();
                    exs1 = [SELECT Id FROM ExternalString WHERE Name = 'AGN_WelcomeEmailNVSubj_GDPR'];
                    ls1 = [Select Id,Value FROM ExternalStringLocalization WHERE ExternalStringId = :exs1.Id AND Language= :langCode];
                    
                    ex.Email_Subject_GDPR_AGN__c=ls1.Value;
                    ex.Email_Body_GDPR_AGN__c=ls.Value;   
                    
                    // added code block to get localized version of welcome email subject and body
                    ExternalString  exWelcomeSubject = new ExternalString();
                    exWelcomeSubject=[SELECT Id FROM ExternalString WHERE Name = 'AGN_WelcomeEmailNewSubj_GDPR'];
                    ExternalStringLocalization exslWelcomeSubject =new ExternalStringLocalization();
                    exslWelcomeSubject =[Select Id,Value FROM ExternalStringLocalization WHERE ExternalStringId = :exWelcomeSubject.Id AND Language= :langCode];
                    
                    ExternalString  exWelcomeBody = new ExternalString();
                    exWelcomeBody=[SELECT Id FROM ExternalString WHERE Name = 'AGN_WelcomeEmailNew_GDPR'];
                    ExternalStringLocalization exslWelcomeBody =new ExternalStringLocalization();
                    exslWelcomeBody =[Select Id,Value FROM ExternalStringLocalization WHERE ExternalStringId = :exWelcomeBody.Id AND Language= :langCode];
                    
                    exWelcomeObj.Email_Subject_GDPR_AGN__c=exslWelcomeSubject.Value;
                    exWelcomeObj.Email_Body_GDPR_AGN__c=exslWelcomeBody.Value;  
                }
                //add external email communication instances into external email commn list
                exEmailCommList.add(ex);
                exEmailCommList.add(exWelcomeObj);
            }
            else if(cs[0].Status =='New')
            {
                if(cs[0].DS_Selected_Language_GDPR_AGN__c == 'English')
                {
                    ex.Email_Subject_GDPR_AGN__c=System.Label.AGN_WelcomeEmailNewSubj_GDPR;
                    ex.Email_Body_GDPR_AGN__c=System.Label.AGN_WelcomeEmailNew_GDPR;   
                }
                else
                {
                    AGN_GDPR_Language_Settings__c lg = AGN_GDPR_Language_Settings__c.getValues(cs[0].DS_Selected_Language_GDPR_AGN__c); 
                    String langCode=lg.Language_Code_AGN__c; 
                    ExternalString exs = new ExternalString();
                    exs=[SELECT Id FROM ExternalString WHERE Name = 'AGN_WelcomeEmailNew_GDPR'];
                    ExternalStringLocalization ls =new ExternalStringLocalization();
                    ls=[Select Id,Value FROM ExternalStringLocalization WHERE ExternalStringId = :exs.Id AND Language= :langCode];
                    System.debug('Lang'+ls.Value);
                    
                    ExternalString exs1 = new ExternalString();
                    ExternalStringLocalization ls1 =new ExternalStringLocalization();
                    
                    exs1 = [SELECT Id FROM ExternalString WHERE Name = 'AGN_WelcomeEmailNewSubj_GDPR'];
                    ls1 = [Select Id,Value FROM ExternalStringLocalization WHERE ExternalStringId = :exs1.Id AND Language= :langCode];
                    
                    ex.Email_Subject_GDPR_AGN__c=ls1.Value;
                    ex.Email_Body_GDPR_AGN__c=ls.Value;   
                }  
                exEmailCommList.add(ex); 
            }
        }
        
        try
        {  System.debug('exemailList:'+exEmailCommList);
         if(exEmailCommList.size()>0)
         {
             insert exEmailCommList; 
         }
         
        }
        catch(DmlException e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
}