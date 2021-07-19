// This class is created as the Controller class of the Visualforce Page - AGN_Case_Survey_Send_Email
// Author - Rahul Mitra
// Created Date - 09/12/2019
// Last Modified By - Rahul Mitra
public class AGN_CaseSurveySendEmail 
{
    public boolean show{ get; set;}
    public case getcase { get; set; }
    public String UserLanguageSelect {get; set;}
    
    public List<Case> caselist;
    public List<Survey_Email_Question_Answer_AGN__c> EmailLang = new List<Survey_Email_Question_Answer_AGN__c>();
    String getId = ApexPages.currentPage().getParameters().get('id');
    String cName;
    String recTypeId;
    String recTypeIdsurv;
    
    public AGN_CaseSurveySendEmail()
    {
        recTypeId     = [Select id from RecordType where SobjectType = 'Survey_Email_Question_Answer_AGN__c' AND DeveloperName = 'Allergan_Case_Survey_AGN'][0].id;
        recTypeIdsurv = [select id from RecordType where SobjectType = 'Allergan_Survey_AGN__c' AND DeveloperName = 'Case_Survey_AGN'][0].id;
        
        caselist = [Select ContactEmail,ContactId,Contact.name,Status,Type,Service_AGN__c,Country_Code_AGN__c,
                    Case_Survey_Email_Sent_AGN__c,Case_Survey_Link_2_AGN__c,
                    Case_Survey_Language_AGN__c from Case where Id=:getId];
        if(caselist.size()>0)
        {
            getcase =  caselist[0];
        }
    }
    public List<SelectOption> UserLanguage
    {
        get
        {
            if(caselist.size()>0)
            {
                EmailLang = [Select Name,Survey_Email_Language_AGN__c,Country_Code_AGN__c 
                             from Survey_Email_Question_Answer_AGN__c 
                             where Country_Code_AGN__c =: getcase.Country_Code_AGN__c
                             and RecordTypeId =: recTypeId 
                             and Active_AGN__c = True
                             and Survey_Email_Category_AGN__c =: getcase.Type
                             and Survey_Email_Service_AGN__c =: getcase.Service_AGN__c ORDER BY Name];
                
                Schema.DescribeFieldResult fieldResult = Survey_Email_Question_Answer_AGN__c.Survey_Email_Language_AGN__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
                Set<SelectOption> languageSet = new Set<SelectOption>();
                UserLanguage = new List<SelectOption>();
                UserLanguage.add(new SelectOption('','Select Language'));
                
                for(Survey_Email_Question_Answer_AGN__c f:EmailLang)
                {
                    for(Schema.PicklistEntry langV:ple)
                    {
                        if(langV.getValue() == f.Survey_Email_Language_AGN__c && languageset.add(new SelectOption(langV.getValue(),langV.getLabel())))
                            UserLanguage.add(new SelectOption(langV.getValue(),langV.getLabel()));
                    }
                }
            }
            return UserLanguage;
        }
        set;
    }
    public void Send_Email()
    {
        List<String> sendTo    = new List<String>();
        List<String> sentToBcc = new List<String>();
        
        // BCC Metadata Start
        AGN_Case_Survey_Bcc_Email__mdt[] bccMappings = [Select MasterLabel,AGN_Bcc_Email__c,DeveloperName from
                                                        AGN_Case_Survey_Bcc_Email__mdt where MasterLabel =: getcase.Country_Code_AGN__c];
        
        if(bccMappings.size()>0)
        {
            for(AGN_Case_Survey_Bcc_Email__mdt bccmdt:bccMappings)
            {
                if(bccmdt.AGN_Bcc_Email__c!= NULL)
                {
                    List<String> bccMetaSplit = bccmdt.AGN_Bcc_Email__c.split(';');
                    for(String emailSplit:bccMetaSplit)
                    {
                        sentToBcc.add(emailSplit);
                    }
                }
            }
        }
        // BCC Metadata Start End      
        
        
        Savepoint sp = Database.setSavepoint();
        try
        {
            EmailTemplate templateId = [Select id,HtmlValue from EmailTemplate where folder.name='Case Email Templates' and TemplateType =:'visualforce' and DeveloperName =: 'AGN_Case_Survey_Template_VF'];
            if((getcase.ContactEmail != Null && UserLanguageSelect != Null && UserLanguageSelect != getcase.Case_Survey_Language_AGN__c))
            {
                getcase.Case_Survey_Language_AGN__c = UserLanguageSelect;
                getcase.Case_Survey_Link_2_AGN__c = Label.Allergan_Case_Survey_URL_AGN +'ID='+getId+'&'+'Language'+'='+UserLanguageSelect;
                update getcase;
                
                List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                OrgWideEmailAddress owea = new OrgWideEmailAddress();
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Allergan CoolSculpting Survey'];
                
                mail.setTargetObjectId(getcase.ContactId);
                sendTo.add(getcase.ContactEmail);
                mail.setToAddresses(sendTo);
                if(sentToBcc != NULL)
                {
                    mail.setBccAddresses(sentToBcc);
                }
                mail.setTemplateID(templateId.Id); 
                mail.setWhatId(getId);
                mail.setSaveAsActivity(false);
                mail.setOrgWideEmailAddressId(owea.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                mails.add(mail);
                
                if(sendTo.size()>0 && getcase.Case_Survey_Email_Sent_AGN__c==false)
                {
                    show=true;
                    getcase.Case_Survey_Email_Sent_AGN__c = True;
                    update getcase;
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.AGN_BC_Email_Send));
                    List<Allergan_Survey_AGN__c> allsurv =  new List<Allergan_Survey_AGN__c>();
                    Allergan_Survey_AGN__c surveytotal = new Allergan_Survey_AGN__c();
                    surveytotal.Case_AGN__c            = getId;
                    surveytotal.Case_Category_AGN__c   = getcase.Type;
                    surveytotal.Case_Service_AGN__c    = getcase.Service_AGN__c;
                    surveytotal.Email_AGN__c           = getcase.ContactEmail;
                    surveytotal.Survey_Language_AGN__c = UserLanguageSelect;
                    surveytotal.RecordTypeId           = recTypeIdsurv;
                    surveytotal.Country_Code_AGN__c    = getcase.Country_Code_AGN__c;
                    allsurv.add(surveytotal); 
                    insert allsurv;
                    Messaging.sendEmail(mails);
                }
            }
            else
            {
                if(getcase.ContactEmail==null && UserLanguageSelect==Null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_Survey_Email_Language_Blank_Error_AGN));
                }
                else if(UserLanguageSelect==Null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_Survey_Language_Blank_Error_AGN));
                    
                }
                else if(getcase.ContactEmail==null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_Survey_Contact_Email_Not_Present_AGN));
                    
                }
                Else 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_Survey_Email_Sending_Generic_Error_Message_AGN));  
                
            }
        }
        catch (Exception e)
        {
            String error = e.getMessage();
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_Survey_Email_Sending_Generic_Error_Message_AGN));
        }
    }
}