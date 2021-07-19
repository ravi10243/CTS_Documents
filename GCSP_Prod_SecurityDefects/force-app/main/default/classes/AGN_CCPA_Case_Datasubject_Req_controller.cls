public without sharing class AGN_CCPA_Case_Datasubject_Req_controller 
{  
    public Case caseObj { get; set; } 
    public Attachment attachment { get; set; } 
    public List<DS_Email_Verification_GDPR_AGN__c> emailVerificationObj { get; set;} 
    public string selectedLang{get;set;}
    public string caseSource {get;set;}
    public List<SelectOption> selectOptions{get;set;}
    public List<String> selectedRequest {get;set;}
    public String[] banks {get;set;}
    public String currentRecordId {get;set;}
    public String parameterValue {get;set;}
    public Boolean bool {get;set;}
    public Boolean bool1 {get;set;}
    public Boolean boolOther {get;set;}
    public Boolean displayInputputText{get;set;}
  
   
    public AGN_CCPA_Case_Datasubject_Req_controller(ApexPages.StandardController stdController)
    {

        selectedLang = apexpages.currentpage().getparameters().get('Lang');
        if(selectedLang==null){
          selectedLang='en_US';  
        }
        caseSource = apexpages.currentpage().getparameters().get('Source');
        //Record for update
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        if(String.isNotEmpty(currentRecordId))
        {
            caseObj = [select id ,CaseNumber, SuppliedName,status,Full_Address_GDPR_AGN__c,Country_AGN_GDPR__c,Postal_Country_AGN_GDPR__c,SuppliedEmail, SuppliedPhone,Request_Type_GDPR_AGN_new__c, Affiliation_GDPR_AGN__c, Date_of_Form_Submission_GDPR_AGN__c,Role_with_Allergan_GDPR_AGN__c,Rectification_changes_GDPR_AGN__c,Personal_Data_GDPR_AGN__c from Case where id =: currentRecordId ];
            bool=true;
        }
        else
        {
            bool=false; 
            System.debug('Inside Isert block of constructor');
            caseObj = new Case();
              attachment= new Attachment();

        }

    }


    public PageReference doInsert() 
    {
        try
        {
            System.debug('Given Email Value'+ RequestItems1);
            system.debug('==> Lang== :' + selectedLang);
            boolean isEmailInsertReq = false;
            if(caseObj.Case_Creation_Channel_GDPR_AGN__c == 'Email' && String.isBlank(caseObj.SuppliedEmail))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Provide Email for Email Communication')); // Replace this message with Custom Label
                return null;
            }
            
            List<RecordType> recType= [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'CCPA Case'];
            List<Group> groupType= [SELECT Id FROM Group WHERE Name = 'CCPA'];
            List<User> userType= [SELECT Id FROM User WHERE Name = 'GDPR Case Site Guest User'];
            List<AGN_GDPR_Language_Settings__c> languageNameFetchList = [select name,Language_Code_AGN__c,Language_Order_GDPR_AGN__c from AGN_GDPR_Language_Settings__c WHERE Language_Code_AGN__c = :selectedLang ];
            //AGN_GDPR_Language_Settings__c languageNameFetchList = AGN_GDPR_Language_Settings__c.getValues(selectedLang);
           // System.debug('Language Name'+languageNameFetchList.name);
            if(caseSource == 'Email')
                caseObj.Origin='Email';
            else
                caseObj.Origin='Web'; 
            
             if(caseObj.Submitting_for_Another_Person_GDPR_AGN__c==false){
               caseObj.Person_First_Name_GDPR_AGN__c=''; 
               caseObj.Person_Last_Name_GDPR_AGN__c='';
               caseObj.Person_E_Mail_Address_GDPR_AGN__c='';
               caseObj.Person_Requester_Relationship_GDPR_AGN__c='';
               caseObj.Person_Allergan_Employee_GDPR_AGN__c=false; 
                
            }
            
           if((!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}',caseObj.Person_E_Mail_Address_GDPR_AGN__c))&&(caseObj.Person_E_Mail_Address_GDPR_AGN__c!='')){
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Requestor Email not valid')); 
           }
            System.debug('After 1st email check');
            
          if(String.isNotBlank(caseObj.E_Mail_Address_GDPR_AGN__c)){
             System.debug('Inside 2nd email check');
            if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}',caseObj.E_Mail_Address_GDPR_AGN__c)){
            
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'DS Email not valid')); 
            }
           }
            
            System.debug('After 2nd email check');

        
           caseObj.OwnerId=groupType[0].ID;
            caseObj.RecordTypeId=recType[0].ID;
            caseObj.DS_Selected_Language_GDPR_AGN__c=languageNameFetchList[0].name;
            caseObj.Full_Name_GDPR_AGN__c=caseObj.First_Name_GDPR_AGN__c +' '+ caseObj.Last_Name_GDPR_AGN__c;
            caseObj.Subject=caseObj.Full_Name_GDPR_AGN__c+'-'+RequestItems1;
            System.debug('Full Name '+caseObj.Full_Name_GDPR_AGN__c);
            System.debug('DS Selected Language '+caseObj.DS_Selected_Language_GDPR_AGN__c);
            DS_Email_Verification_GDPR_AGN__c emailVar = new DS_Email_Verification_GDPR_AGN__c();
            if(caseObj.Case_Creation_Channel_GDPR_AGN__c == 'Email')
            {
                system.debug('==inside if==');
                emailVerificationObj = [select id,Name,IsVerified_GDPR_AGN__c from DS_Email_Verification_GDPR_AGN__c where DS_Email_GDPR_AGN__c= :caseObj.SuppliedEmail];
                
                if(emailVerificationObj.isEmpty())
                {
                    isEmailInsertReq = true;                    
                    
                    
                    caseObj.Status='Email Not Verified';
                    caseObj.OwnerId=userType[0].ID;
                }
                else
                {
                    if(!emailVerificationObj[0].IsVerified_GDPR_AGN__c)
                    {
                        delete emailVerificationObj;
                        isEmailInsertReq = true;                                                
                        caseObj.Status='Email Not Verified';
                        caseObj.OwnerId=userType[0].ID;
                    }
                    else
                    {
                        caseObj.Status='New';
                        isEmailInsertReq = false;
                    }
                }
            }
            else
            {
                caseObj.Status='New';
                isEmailInsertReq = false;
            }
            
            insert caseObj;
            
            if(isEmailInsertReq)
            {
                emailVar.DS_Email_GDPR_AGN__c =caseObj.SuppliedEmail;
                emailVar.IsVerified_GDPR_AGN__c= false;
                emailVar.Language_GDPR_AGN__c=languageNameFetchList[0].name;
                //emailVar.Case_ID_GDPR_AGN__c = caseObj.Id;
                emailVar.Case_ID_GDPR_AGN__c = caseObj.CaseNumber;
                Insert emailVar;
            }
              if(attachment.body!=Null && attachment.name!=Null){
                attachment.ParentId = caseObj.Id; // the record the file is attached to
                attachment.IsPrivate = false;
                insert attachment;
            }else{
                System.debug('Attachment Not Present');
            }
            
            System.debug('Inserted Case object record Full Name==> '+caseObj.Full_Name_GDPR_AGN__c);
            System.debug('Inserted Case object record ID==> '+caseObj.ID);
            pagereference ref = new pagereference('/apex/AGN_CCPA_Case_Submit_Redirect?Lang='+selectedLang +'&CaseID=' + caseObj.Id);
            ref.setredirect(true);
            return ref;
            //system.debug('==>1: ' + getRequestOptions);
            
        }
        catch(Exception ex)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record creation failed: ' + ex.getMessage()));
        }    
       return null;
    }

    public List<SelectOption> getRoles()
    {

        Schema.sObjectType sobject_type = Case.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Role_with_Allergan_GDPR_AGN__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for (Schema.PicklistEntry a : pick_list_values) 
        {
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }


    public List<selectoption> getAvailableLanguages()
    {
        List<selectOption> options = new List<selectOption>();
        List<AGN_GDPR_Language_Settings__c> languageList = [select name,Language_Code_AGN__c,Language_Order_GDPR_AGN__c from AGN_GDPR_Language_Settings__c ORDER BY Language_Order_GDPR_AGN__c ASC];
        // for (AGN_GDPR_Language_Settings__c iso : AGN_GDPR_Language_Settings__c.getAll().values()){
        for(AGN_GDPR_Language_Settings__c iso :languageList)
        {
            options.add(new SelectOption(iso.Language_Code_AGN__c,iso.Name));
        }
        return options;
    }



    public String[] RequestItems1 
    { 
        get 
        {
            List<String> selected = new List<String>();
            // List<SelectOption> options = this.getRequestPicklist;
            List<SelectOption> options = this.getRequestOptions;
            for(SelectOption obj : options) 
            {
                if (this.caseObj.Request_Type_GDPR_AGN_new__c !=null && this.caseObj.Request_Type_GDPR_AGN_new__c.contains(obj.getValue()))
                    selected.add(obj.getValue());
            }
            return selected;
        }
        public set 
        {
            String selectedCheckBox = '';
            for(String s : value) 
            {
                if (selectedCheckBox == '') 
                    selectedCheckBox += s;
                else 
                    selectedCheckBox += ';' + s;
            }
            caseObj.Request_Type_GDPR_AGN_new__c = selectedCheckBox;
            if(selectedCheckBox.contains('Rectification'))
            {
                bool1=true;
                system.debug('Rectifiaction value check++'+bool1);
            }
            else
            {
                bool1=false;
            }
        }
    } 



    public List<SelectOption> getRequestOptions 
    {
        get 
        { 
            List<SelectOption> options = new List<SelectOption>();
            String accVal= Label.Request_Picklist_Access_GDPR_AGN;
            String recVal= Label.Request_Picklist_Rectification_GDPR_AGN;
            String proVal= Label.Request_Picklist_Portability_GDPR_AGN;
            String eraVal= Label.Request_Picklist_Erasure_GDPR_AGN;
            String objVal= Label.Request_Picklist_Objection_GDPR_AGN;
            String resVal= Label.Request_Picklist_Restriction_GDPR_AGN;
            

            options.add(new SelectOption('Access',accVal));
            options.add(new SelectOption('Rectification',recVal));
            options.add(new SelectOption('Portability',proVal));
            options.add(new SelectOption('Erasure',eraVal));
            options.add(new SelectOption('Objection',objVal));
            options.add(new SelectOption('Restriction',resVal));
            return options; 
        } 
        set;
    }
    
    
    public String[] ProvideConsentItems 
    { 
        get 
        {
            List<String> selected = new List<String>();
            // List<SelectOption> options = this.getRequestPicklist;
            List<SelectOption> options = this.getProvideConsentOptions;
            for(SelectOption obj : options) 
            {
                if (this.caseObj.Provide_Consent_GDPR_AGN__c !=null && this.caseObj.Provide_Consent_GDPR_AGN__c.contains(obj.getValue()))
                    selected.add(obj.getValue());
            }
            return selected;
        }
        public set 
        {
            String selectedCheckBox = '';
            for(String s : value) 
            {
                if (selectedCheckBox == '') 
                    selectedCheckBox += s;
                else 
                    selectedCheckBox += ';' + s;
            }
            caseObj.Provide_Consent_GDPR_AGN__c = selectedCheckBox;

        }
    } 

   
  public List<SelectOption> getProvideConsentOptions 
    {
        get 
        { 
            List<SelectOption> options = new List<SelectOption>();
            String inviteAGNSponEmail= Label.Invitation_by_email_to_Allergan_sponsored_event_and_registration_GDPR_AGN;
            String inviteNonAGNSponEmail= Label.Invitation_by_email_to_non_Allergan_sponsored_event_and_registration_GDPR_AGN;
            String transFinancial= Label.Transparency_and_financial_Disclosure_GDPR_AGN;
            String productMarketByMob= Label.Product_and_service_direct_marketing_by_Mobile_GDPR_AGN;
            String productMarketByEmail= Label.Product_and_service_direct_marketing_by_email_GDPR_AGN;
            String OtherOption= Label.Other_GDPR_AGN;


            options.add(new SelectOption('Invitation by email to Allergan-sponsored event and registration',inviteAGNSponEmail));
            options.add(new SelectOption('Invitation by email to non-Allergan-sponsored event and registration',inviteNonAGNSponEmail));
            options.add(new SelectOption('Transparency and financial Disclosure',transFinancial));
            options.add(new SelectOption('Product and service direct marketing by Mobile',productMarketByMob));
            options.add(new SelectOption('Product and service direct marketing by email',productMarketByEmail));
            options.add(new SelectOption('Other',OtherOption));
            return options; 
        } 
        set;
    }

    public String[] WithdrawConsentItems 
    { 
        get 
        {
            List<String> selected = new List<String>();
            // List<SelectOption> options = this.getRequestPicklist;
            List<SelectOption> options = this.getWithdrawConsentOptions;
            for(SelectOption obj : options) 
            {
                if (this.caseObj.Withdraw_Consent_GDPR_AGN__c !=null && this.caseObj.Withdraw_Consent_GDPR_AGN__c.contains(obj.getValue()))
                    selected.add(obj.getValue());
            }
            return selected;
        }
        public set 
        {
            String selectedCheckBox = '';
            for(String s : value) 
            {
                if (selectedCheckBox == '') 
                    selectedCheckBox += s;
                else 
                    selectedCheckBox += ';' + s;
            }
            caseObj.Withdraw_Consent_GDPR_AGN__c = selectedCheckBox;

        }
    } 

   
  public List<SelectOption> getWithdrawConsentOptions 
    {
        get 
        { 
            List<SelectOption> options = new List<SelectOption>();
            String inviteAGNSponEmail= Label.Invitation_by_email_to_Allergan_sponsored_event_and_registration_GDPR_AGN;
            String inviteNonAGNSponEmail= Label.Invitation_by_email_to_non_Allergan_sponsored_event_and_registration_GDPR_AGN;
            String transFinancial= Label.Transparency_and_financial_Disclosure_GDPR_AGN;
            String productMarketByMob= Label.Product_and_service_direct_marketing_by_Mobile_GDPR_AGN;
            String productMarketByEmail= Label.Product_and_service_direct_marketing_by_email_GDPR_AGN;
            String OtherOption= Label.Other_GDPR_AGN;


            options.add(new SelectOption('Invitation by email to Allergan-sponsored event and registration',inviteAGNSponEmail));
            options.add(new SelectOption('Invitation by email to non-Allergan-sponsored event and registration',inviteNonAGNSponEmail));
            options.add(new SelectOption('Transparency and financial Disclosure',transFinancial));
            options.add(new SelectOption('Product and service direct marketing by Mobile',productMarketByMob));
            options.add(new SelectOption('Product and service direct marketing by email',productMarketByEmail));
            options.add(new SelectOption('Other',OtherOption));
            return options; 
        } 
        set;
    }
    
    
    
}