public class AGN_BCSendEmail
{

    public boolean show{ get; set;}
    public String contractlang { get; set; }
    String s;
    public Contract_Exhibit__c ce{get;set;}
    String getpara=ApexPages.currentPage().getParameters().get('id');

    public AGN_BCSendEmail()
    {
        ce=[select Name,Customer_Signer_Email__c,ownerid,Survey_link_AGN__c,Customer_Signer_Title__c,Contract_Language__c,Survey_Sent_AGN__c from Contract_Exhibit__c where Id=:getpara];
        boolean isWhitespace = ce.Contract_Language__c.containsWhitespace();
        if(isWhitespace)
          {
            s=ce.Contract_Language__c.deleteWhitespace();
            contractlang  = s.substring(0, s.indexOf('('));
          }
        else
        {
            contractlang =ce.Contract_Language__c;
        }
        
     BC_Setting_AGN__c bcs=[select BC_Survey_QuestionLanguage_Available_AGN__c from BC_Setting_AGN__c where setupownerid=:UserInfo.getOrganizationId()];
     Boolean b=bcs.BC_Survey_QuestionLanguage_Available_AGN__c.contains(ce.Contract_Language__c);
     if(bcs.BC_Survey_QuestionLanguage_Available_AGN__c.contains(ce.Contract_Language__c))
         {
          show=false;
           if(ce.Survey_Sent_AGN__c==true)
            {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.AGN_Survey_Answered));
             show=true;
            }
         }
           if(ce.Customer_Signer_Email__c==null)
            {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.AGN_BC_No_Language));
                 show=true;
            }
           if(b==false)
           {
            show=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.AGN_No_Survey));
           } 
         
       /* else
        {
            show=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.AGN_No_Survey));
        }*/
             
    }

    public void Send_Email() 
    {
        List<String> sendTo = new List<String>();
        try
         {
            EmailTemplate templateId = [Select id,HtmlValue from EmailTemplate where folder.name='AGN BC Survey Templates' and TemplateType =:'visualforce'];
            BC_Setting_AGN__c bcs=BC_Setting_AGN__c.getOrgDefaults();
            String s1='&';
            String s2=ce.Contract_Language__c;
            boolean b= s2.contains(s1);
            String s3;
             if(b==true)
             {
                s3 =ce.Contract_Language__c.replace('&', 'AND');
             }
             else
             {
                 s3 = ce.Contract_Language__c;
             }
             ce.Survey_link_AGN__c=bcs.Site_Url_AGN__c+'ID='+getpara+'&'+Label.AGN_BC_Survey_Language+'='+s3;  
             update ce;
            
            
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress owea = new OrgWideEmailAddress();
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Allergan Business Consulting Satisfaction Survey'];
            
           /* String htmlBody = templateId.HtmlValue;
            htmlBody = htmlBody.replace('{!Contract_Exhibit__c.Customer_Signer_Title__c}', ce.Customer_Signer_Title__c);
            htmlBody = htmlBody.replace('{!Contract_Exhibit__c.Survey_link_AGN__c}', ce.Survey_link_AGN__c);*/
           
            mail.setTargetObjectId(ce.ownerid);
            
            sendTo.add(ce.Customer_Signer_Email__c);
            mail.setToAddresses(sendTo);
            mail.setTemplateID(templateId.Id); 
            mail.setWhatId(getpara);
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owea.Id);
            //mail.setSenderDisplayName(Label.AGN_BC_Survey_Customer_Email_Footer2);
            mail.setTreatTargetObjectAsRecipient(false);
            mails.add(mail);
            //Messaging.sendEmail(mails);
            if(sendTo.size()>0 && ce.Survey_Sent_AGN__c==false)
            {
                 ce.Survey_Sent_AGN__c=true; 
                 update ce;
                 show=true;
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.AGN_BC_Email_Send));
                 Messaging.sendEmail(mails);
            }
         
            
         }
        catch(Exception e)
        {
            String error = e.getMessage();
            if(ce.Customer_Signer_Email__c==null)
            {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.AGN_BC_No_Language));
            }
           
            else
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.AGN_BC_Template));
                
            }
        }
        
    }
    
     /*public PageReference Cancel()
      {
          Pagereference pg=new Pagereference('/'+getpara);
          pg.setredirect(true);
          return pg;
      }

    public List<SelectOption> getlanglist()
    {
        List<SelectOption> listValues = new List<SelectOption>();
        listValues.add(new SelectOption('null',Label.AGN_BC_None));
        for(BC_Languages_AGN__c s: [select Name from BC_Languages_AGN__c])
        {
        listValues.add(new SelectOption(s.Name,s.Name));      
        }
        return listValues;
    }*/
}