public class AGN_GDPRCase_Datasubject_Req_controller 
{  
   public Case caseObj { get; set; } 
    public Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        set;
    }
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
    public Boolean bool2 {get;set;}
    public Boolean consentrederboolean {get;set;}
    public Boolean boolOther {get;set;}
    public Boolean boolReqester {get;set;}
    public Boolean req{get;set;}
    public Boolean isEmailVerified{get;set;}
    public Boolean displayInputputText{get;set;}
    public ContentDocument contDoc { get; set; }
    public ContentDocumentLink contDocLink { get; set; }
    public ContentVersion contDocVersion { get; set; }
    
    
    public AGN_GDPRCase_Datasubject_Req_controller(ApexPages.StandardController stdController)
    {
        bool2=false;
        consentrederboolean=false;
        req=false;
        
        selectedLang = apexpages.currentpage().getparameters().get('Lang');
        if(selectedLang==null){
          selectedLang='en_US';  
        }
        caseSource = apexpages.currentpage().getparameters().get('Source');
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('currentRecordId### '+currentRecordId);
        if(String.isNotEmpty(currentRecordId))
        {
            caseObj = [select id ,CaseNumber, SuppliedName,status,Full_Address_GDPR_AGN__c,Country_AGN_GDPR__c,Postal_Country_AGN_GDPR__c,SuppliedEmail,OptOUTOthers_AGN_GDPR__c, SuppliedPhone,Request_Type_GDPR_AGN_new__c, Affiliation_GDPR_AGN__c, Date_of_Form_Submission_GDPR_AGN__c,Role_with_Allergan_GDPR_AGN__c,Rectification_changes_GDPR_AGN__c,Personal_Data_GDPR_AGN__c,Zip_AGN_GDPR__c,Titile_AGN_GDPR__c,Post_Zip_GDPR_AGN__c from Case where id =: currentRecordId ];
            bool=true;
        }
        else
        {
            bool=false; 
            System.debug('Inside Isert block of constructor');
            caseObj = new Case();
            System.debug('caseObj### '+caseObj);
            attachment= new Attachment();
            contDoc = new ContentDocument();
            contDocLink = new ContentDocumentLink();
            contDocVersion = new ContentVersion();
        }

    }
   /* Method added by Rahil for OPTIN OPTOUT check */
    public boolean containsAny(List<String> toSearch, List<String> values)
    {
        System.debug('Inside OptIn Opt-Out Check');
        system.debug('Opt Out List '+toSearch);
        system.debug('Opt Out List Size'+toSearch.size());
        system.debug('Opt In List '+values);
        system.debug('Opt In List Size '+values.size());
       if(values ==Null || toSearch == Null || values.isEmpty() || toSearch.isEmpty()  )
        {
            System.debug('Returned False');
            return false;   
        }
        else
        {
            for (String i : toSearch)
            { 
                for (String j : values)
                {
                    if (i == j)
                    {
                         System.debug('Returned true');
                        return true;
                       
                    }
                }
            }
            
           }  
         System.debug('Returned False');
        return false;
       
    }

    public PageReference doInsert() 
    {
        try
        {
            system.debug('==> Lang== :' + selectedLang);
            /* Changes added by Rahil for OPTIN OPTOUT check */
            
            System.debug('selectedWithdraw## '+caseObj.Withdraw_Consent_GDPR_AGN__c);
            System.debug('provideConsentList## '+caseObj.Provide_Consent_GDPR_AGN__c);
            
            List<String> withdrawConsentList = new List<String>();
            List<String> provideConsentList = new List<String>();
            boolean checkBoxCheck = false;
            if(!String.isBlank(caseObj.Withdraw_Consent_GDPR_AGN__c)){
                System.debug('caseObj.Withdraw_Consent_GDPR_AGN__c');
                withdrawConsentList = caseObj.Withdraw_Consent_GDPR_AGN__c.split(';');
            }
            if(!String.isBlank(caseObj.Provide_Consent_GDPR_AGN__c)){
                System.debug('caseObj.Withdraw_Consent_GDPR_AGN__c');
                provideConsentList = caseObj.Provide_Consent_GDPR_AGN__c.split(';');
            }
            if(!withdrawConsentList.isEmpty() || !provideConsentList.isEmpty()){
                System.debug('withdrawConsentList## '+withdrawConsentList);
                System.debug('provideConsentList## '+provideConsentList);
                checkBoxCheck = containsAny(withdrawConsentList,provideConsentList);
            }
            // Changes for D_50 defect for Production Release Date - 9th May 2020 <!-- Starts here --->
            if(caseObj.Request_Type_GDPR_AGN_new__c =='Update Consent' && String.isBlank(caseObj.Withdraw_Consent_GDPR_AGN__c) && String.isBlank(caseObj.Provide_Consent_GDPR_AGN__c))
            {
                System.debug('Provide Consent Required');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AGN_GDPR_ConsentRequired)); // Replace this message with Custom Label
                return null;
            }
           // <!-- D-50 Changes Ends Here -->
            system.debug('checkBoxCheck----------> '+checkBoxCheck);
            //system.debug('withdrawConsentList------->'+withdrawConsentList[0]);
            //system.debug('provideConsentList------->'+provideConsentList[0]);
            boolean isEmailInsertReq = false;
            if(checkBoxCheck==true && !(withdrawConsentList.isEmpty() && provideConsentList.isEmpty()))
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You cannot Opt-IN & Opt-OUT of the same activities while providing consent.'));
               return null;
            }
            if(caseObj.Case_Creation_Channel_GDPR_AGN__c == 'Email' && String.isBlank(caseObj.SuppliedEmail))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Provide Email for Email Communication')); // Replace this message with Custom Label
                return null;
            }
            
            List<RecordType> recType= [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'GDPR Case'];
            List<Group> groupType= [SELECT Id FROM Group WHERE Name = 'GDPR' AND Type ='Queue' LIMIT 1];
            List<User> userType= [SELECT Id FROM User WHERE Name = 'GDPR Case Management Site Guest User' LIMIT 1];
            List<AGN_GDPR_Language_Settings__c> languageNameFetchList = [select name,Language_Code_AGN__c,Language_Order_GDPR_AGN__c from AGN_GDPR_Language_Settings__c WHERE Language_Code_AGN__c = :selectedLang ];
            if(caseSource == 'Email')
                caseObj.Origin='Email';
            else
                caseObj.Origin='Web'; 
            
            // newly added 20-Jun //
            if((!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}',caseObj.E_Mail_Address_GDPR_AGN__c))&&(caseObj.E_Mail_Address_GDPR_AGN__c!='')){
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'DS Email not valid')); 
                isEmailVerified=false;
            }
            System.debug('After 1st email check');
            
            if(String.isNotBlank(caseObj.Person_E_Mail_Address_GDPR_AGN__c)){
                System.debug('Inside 2nd email check');
                if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}',caseObj.Person_E_Mail_Address_GDPR_AGN__c)){
                    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Submitter Email not valid')); 
                    isEmailVerified=false;
                }
            }
            
            //end//
            DS_Email_Verification_GDPR_AGN__c emailVar = new DS_Email_Verification_GDPR_AGN__c();
            
            caseObj.OwnerId=groupType[0].ID;
            caseObj.RecordTypeId=recType[0].ID;
            caseObj.DS_Selected_Language_GDPR_AGN__c=languageNameFetchList[0].name;
            //caseObj.Full_Name_GDPR_AGN__c=caseObj.First_Name_GDPR_AGN__c +' '+ caseObj.Last_Name_GDPR_AGN__c;
          
          
          //  System.debug('Full Nmae '+caseObj.Full_Name_GDPR_AGN__c);
            //DS_Email_Verification_GDPR_AGN__c emailVar = new DS_Email_Verification_GDPR_AGN__c();
            if((caseObj.Request_Type_GDPR_AGN_new__c == 'Access' || caseObj.Request_Type_GDPR_AGN_new__c == 'Portability' ) && caseObj.Case_Creation_Channel_GDPR_AGN__c == 'Email')
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
            if(caseObj.Request_Type_GDPR_AGN_new__c == 'Update Consent' || caseObj.Request_Type_GDPR_AGN_new__c == 'Rectification')
            {
                System.debug('Before Inset Case '+caseObj);
                try
                { 
                    insert caseObj;
                }
                catch (Exception e)
                {
                    System.debug('Case Insert for Update ans Rectification failed due to '+e);
                }
                if(attachment.body!=Null && attachment.name!=Null)
                {
                    
                    attachment.ParentId = caseObj.Id; // the record the file is attached to
                    attachment.IsPrivate = false;
                    insert attachment; 
                }
                
                if(isEmailInsertReq)
                {
                    emailVar.DS_Email_GDPR_AGN__c =caseObj.SuppliedEmail;
                    emailVar.IsVerified_GDPR_AGN__c= false;
                    emailVar.Language_GDPR_AGN__c=languageNameFetchList[0].name;
                    emailVar.Language_Code_GDPR_AGN__c=languageNameFetchList[0].Language_Code_AGN__c;
                    //emailVar.Case_ID_GDPR_AGN__c = caseObj.Id;
                    emailVar.Case_ID_GDPR_AGN__c = caseObj.CaseNumber;
                    emailVar.Data_Subject_Name_AGN__c =caseObj.Titile_AGN_GDPR__c+' '+caseObj.Last_Name_GDPR_AGN__c;
                    Insert emailVar;
                }
        
                pagereference ref = new pagereference('/apex/AGN_GDPR_Case_Submit_Redirect?Lang='+selectedLang +'&CaseID=' + caseObj.Id);
                ref.setredirect(true);
                return ref;
            }
            else if((caseObj.Request_Type_GDPR_AGN_new__c == 'Update Consent'  || caseObj.Request_Type_GDPR_AGN_new__c == 'Rectification') && (attachment.body==Null || attachment.name==Null))
            {     
                System.debug('Attachment Missing!!');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Attachment Missing!!!')); 
            }
            else if(attachment.body==Null || attachment.name==Null)
            {
                System.debug('Attachment Missing!!');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Attachment Missing!!!')); 
            }
            else
            {
                System.debug('Case isert Without portablity');
                insert caseObj; 
                attachment.ParentId = caseObj.Id; // the record the file is attached to
                attachment.IsPrivate = false;
                insert attachment;
                if(isEmailInsertReq)
                {
                    emailVar.DS_Email_GDPR_AGN__c =caseObj.SuppliedEmail;
                    emailVar.IsVerified_GDPR_AGN__c= false;
                    emailVar.Language_GDPR_AGN__c=languageNameFetchList[0].name;
                    emailVar.Language_Code_GDPR_AGN__c=languageNameFetchList[0].Language_Code_AGN__c;
                    //emailVar.Case_ID_GDPR_AGN__c = caseObj.Id;
                    emailVar.Case_ID_GDPR_AGN__c = caseObj.CaseNumber;
                    /******************/
                    emailVar.Case_AGN__c=caseObj.Id;
                    emailVar.Data_Subject_Name_AGN__c=caseObj.Titile_AGN_GDPR__c+' '+caseObj.Last_Name_GDPR_AGN__c;
                    /******************/
                    Insert emailVar;
                }
                pagereference ref = new pagereference('/apex/AGN_GDPR_Case_Submit_Redirect?Lang='+selectedLang +'&CaseID=' + caseObj.Id);
                ref.setredirect(true);
                return ref;
            }
            

          
        }
        catch(Exception ex)
        {
            System.debug('Exception'+ex);
           // ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record creation failed: ' + ex.getMessage()));
        }    
 
        return null;
    }

     
    
       
 

    public void loadAllmethod()
    {
        System.debug('Inside loadmethod');  
       // getRoles();
       // getRequest();
    }
     
    public void consentrender()
    {
        consentrederboolean = true;
         System.debug('consentrederboolean '+ consentrederboolean); 
        
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


/*
   
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
            String upcons= Label.Update_Concent_GDPR_AGN;

            options.add(new SelectOption('Access',accVal));
            options.add(new SelectOption('Rectification',recVal));
            options.add(new SelectOption('Portability',proVal));
            options.add(new SelectOption('Erasure',eraVal));
            options.add(new SelectOption('Objection',objVal));
            options.add(new SelectOption('Restriction',resVal));
            options.add(new SelectOption('Update Consent',upcons));
            return options; 
        } 
        set;
    }
  */
    
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
            system.debug('selected------>'+selected);
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
            system.debug('case.Provide_Consent_GDPR_AGN__c----->inside set'+caseObj.Provide_Consent_GDPR_AGN__c);

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
            String OtherOption= Label.Other_AGN_GDPR;


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
            String OtherOption= Label.Other_AGN_GDPR;
            


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