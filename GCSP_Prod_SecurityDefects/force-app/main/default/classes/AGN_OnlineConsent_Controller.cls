public class AGN_OnlineConsent_Controller 
{ 
    public List<Account> accountList{get;set;}
    public Boolean isErorTxtinRed {get; set;}
    public String errorTxt {get; set;}
    public String myString{get; set;}    
    public String languageSelectOption;
    public String uniqueCode {get; set;}
    public Account account {get; set;}
    public String primaryEmail {get; set;}
    public String additionalEmail {get; set;}
    public String phonenumber {get; set;}
    public String personName {get; set;}
    public String countryIdfromAccount {get; set;}
    public Boolean displayPersonalDetails {get; set;}
    public Boolean displayAdditionEmailDetails {get; set;}
    public boolean successMsg {get;set;}
    //public boolean isPharmaCustomer {get;set;}
    public StringCarrier defaultLanguage {get; set;}    
    public StringCarrier cookieLanguage {get; set;} 
    public StringCarrier cookieHomeLanguage {get; set;} 
    public StringCarrier cookieMessageLanguage {get; set;}   
    public  List<Consent_Type_vod__c> consentTypeList {get; set;}
    public  List<ConsentWrapper> consentWrapperList {get; set;}
    
    
    //Updated as a part of ICL Project
    public String ID {get;set;}
    public Boolean showbutton {get;set;}
    public Boolean hidebutton {get;set;}
    public Boolean ICLConsent {get;set;}
    public String Country {get;set;}
    public boolean GDPRcountry {get;set;}
    public boolean NonGDPRICLcountry {get;set;}
    public boolean GDPRICLcountry {get;set;}
    public String ICLflag {get; set;}
    public Boolean consentexist {get;set;}
    public Boolean consentnonexist {get;set;}
    public String ICLlang {get; set;}
    public String ICLcookie {get;set;}
    public String ICLOK {get;set;}
    public String ICLcookieDiv1 {get;set;}
    //Updated as a part of ICL Project
    
    public Boolean prodServPrimaryEmailConsent {get; set;}
    public Boolean prodServAdditionalEmailConsent {get; set;}
    public Boolean prodServPhoneConsent {get; set;}
    public Boolean transFinancialConsent {get; set;}
    public Boolean allerganEventPrimaryEmailConsent {get; set;}
    public Boolean allerganEventAdditionalEmailConsent {get; set;}
    public Boolean nonAllerganEventPrimaryEmailConsent {get; set;}
    public Boolean nonAllerganEventAdditionalEmailConsent {get; set;}
    public static string userCountryCode{get{return system.label.OnlineConsent_DefaultCountryCode_AGN;}}
    public String franceCountryCodeId{get; set;}
    public String cancellang {get;set;}
    
    public enum CONSENT_TYPE { APPROVED_EMAIL_VOD, PHONE_AGN, TOV_AGN, ALLERGAN_EVENT_AGN, NON_ALLERGAN_EVENT_AGN }
    
    public Boolean displayTOV{get; set;}
    public Boolean displayContinueBtn{get; set;}
    
    
    
    //google recaptcha properties
    private static string baseUrl = (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('reCaptcha_End_Point__c'); //'https://www.google.com/recaptcha/api/siteverify';
    private static string secret= (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('reCaptcha_Secret__c'); //'6Ldi0xAUAAAAAEvQfV-xWR8p5vQfNHOLujtleuFs';
    private static string key = (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('reCaptcha_Site_Key__c');
    
    public String sitekey {
        get { return key;}
    }
    public String response  { 
        get { return ApexPages.currentPage().getParameters().get('g-recaptcha-response'); }
    }
    
    public String getlanguageSelectOption(){
        return languageSelectOption;
    }
    
    public void setlanguageSelectOption(String languageSelectOption){
        this.languageSelectOption = languageSelectOption;
        cookieLanguage.value = this.languageSelectOption;  
        defaultLanguage.value = this.languageSelectOption; 
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();        
        options.add(new SelectOption('True',system.label.AGN_ICL_HCP_Consent_Yes));
        options.add(new SelectOption('False',system.label.AGN_ICL_HCP_Consent_No));
        return options; 
    }
    
    public AGN_OnlineConsent_Controller()
    {
        //Updated as a part of ICL Project
        //AM CC commented out the next line since not needed
        // ID=ApexPages.currentPage().getParameters().get('id');
        if(ApexPages.currentPage().getParameters().get('id')!=NULL)
        {
            
            displayAdditionEmailDetails = true;
            prodServPrimaryEmailConsent=true;
            showbutton=false;
            hidebutton=true;
            consentWrapperList = new List<ConsentWrapper>();
            consentTypeList = new List<Consent_Type_vod__c>();
            ICLConsent=true;
            Country=ApexPages.currentPage().getParameters().get('country');
            languageSelectOption = [select Language_Code_AGN__c from AGN_ICL_Language_Settings__c where Name=: ApexPages.currentPage().getParameters().get('language')].Language_Code_AGN__c ;
            defaultLanguage = new StringCarrier();
            defaultLanguage.value = languageSelectOption ;
            
            system.debug('AGNGDPRCountries1'+Label.AGNGDPRCountries);
            List<String> Clabel=Label.AGNGDPRCountries.split(';');
            for(Integer i=0;i<Clabel.size();i++)
            {
                system.debug('clabel'+Clabel);
                system.debug('compare'+clabel.contains(Country));
                if(clabel.contains(Country))
                {
                    GDPRICLcountry = true;
                    NonGDPRICLcountry=false;
                    GDPRcountry = false;
                } 
                else
                {
                    GDPRICLcountry = false;
                    NonGDPRICLcountry=true;
                    GDPRcountry = false;
                }
                
            }               
            
            
            
        }
        
        else
        {
            showbutton=true;
            hidebutton=false;
            GDPRICLcountry = false;
            NonGDPRICLcountry=false;
            GDPRcountry = true;
            consentnonexist=true;
            consentexist=false;
            
        }
        
        
        
        //Updated as a part of ICL Project
        
        
        isErorTxtinRed = False;
        defaultLanguage = new StringCarrier();
        defaultLanguage.value = 'en_US';
        
        cookieMessageLanguage = new StringCarrier();
        cookieLanguage = new StringCarrier();
        cookieLanguage.value = 'en_US';
        
        cookieHomeLanguage= new StringCarrier();
        
        prodServPrimaryEmailConsent = false;
        prodServAdditionalEmailConsent = false;
        prodServPhoneConsent = false;
        transFinancialConsent = false;
        
        allerganEventPrimaryEmailConsent = false;
        allerganEventAdditionalEmailConsent = false;
        nonAllerganEventPrimaryEmailConsent = false;
        nonAllerganEventAdditionalEmailConsent = false;
        
        displayPersonalDetails = false;
        displayTOV = true;
        displayAdditionEmailDetails = false;
        displayContinueBtn = false;
        
        consentTypeList = new List<Consent_Type_vod__c>();
        
        consentWrapperList = new List<ConsentWrapper>();
        
        List<Country_vod__c> countryList = new List<Country_vod__c>();
        countryList = [Select Id from Country_vod__c where Name = 'FR' limit 1]; 
        franceCountryCodeId = (countryList != null && countryList.size() > 0) ? countryList[0].Id : '';  //assuming france country record to exists.
        
        //Updated as a part of ICL Project
        
        ICLflag = ApexPages.currentPage().getParameters().get('ICLFlag');
        System.debug('icl flag************** '+ICLflag);
        List<Practitioner_Listing_AGN__c> prac=[select Id,Consent_Check_AGN__c,Status_AGN__c 
                                                from Practitioner_Listing_AGN__c 
                                                where Practitioner_AGN__c=:ApexPages.currentPage().getParameters().get('id') 
                                                and Consent_Check_AGN__c=false and Status_AGN__c !='Inactive'];
        system.debug('Practitioner'+prac);
        if(ICLflag == 'true' && prac.size()> 0)
        {
            System.debug('enter icl flag*************');
            consentnonexist=true;
            consentexist=false;
            
            //AM CC
            
            //ICLlang= ApexPages.currentPage().getParameters().get('language');
            //String ICLCountry=ApexPages.currentPage().getParameters().get('country');
            AGN_ICL_Language_Settings__c ail=[select Language_Code_AGN__c from AGN_ICL_Language_Settings__c where Name=:ApexPages.currentPage().getParameters().get('language')] ;
            //Allergan_Consent_Cookie_Info__c cookie=[select OkLabel__c,Cookie_Content__c from Allergan_Consent_Cookie_Info__c where Application_Flag_AGN__c='ICL' and Language__c=:ail.Language_Code_AGN__c ];
            Country_vod__c cv=[select Id from Country_vod__c where Name=:ApexPages.currentPage().getParameters().get('country')];
            //AM CC
            List<Allergan_Consent_Cookie_Info__c > acf=[select Name from Allergan_Consent_Cookie_Info__c where Language__c=:ail.Language_Code_AGN__c  and country_code_AGN__c=:cv.Id] ;
            if(acf.size()>0)
            {
                Allergan_Consent_Cookie_Info__c cookie=[select OkLabel__c,Cookie_Content__c from Allergan_Consent_Cookie_Info__c where Application_Flag_AGN__c='ICL' and Language__c=:ail.Language_Code_AGN__c and country_code_AGN__c=:cv.Id];
                ICLcookie =cookie.Cookie_Content__c ;
                ICLcookieDiv1 =cookie.Cookie_Content__c.substring(0, cookie.Cookie_Content__c.length()/3);
                ICLOK=cookie.OkLabel__c;         
            }
            if(acf.isEmpty())
            {
                Allergan_Consent_Cookie_Info__c cookie=[select OkLabel__c,Cookie_Content__c from Allergan_Consent_Cookie_Info__c where Language__c='en_US' limit 1];
                ICLcookie =cookie.Cookie_Content__c ;
                ICLcookieDiv1 =cookie.Cookie_Content__c.substring(0, cookie.Cookie_Content__c.length()/3);
                ICLOK=cookie.OkLabel__c;  
            }
            doredirect();
        }
        if(ICLflag=='true' && prac.isEmpty())
        {
            
            consentexist=true;
            consentnonexist=false;
            
        }
    }
    
    //Updated as a part of ICL Project
    
    public void cookieLang()
    {
        cookieLanguage.value = languageSelectOption;     
    }
    
    public PageReference doVerify () {     
        isErorTxtinRed = False;
        errorTxt = '';
        ApexPages.getMessages().clear();
        Boolean chkEmail = validateMyEmail(primaryEmail);
        Boolean chkSecEmail = validateMyEmail(additionalEmail);
        
        if(primaryEmail =='' || primaryEmail == null){
            errorTxt += Label.OnlineConsent_PEmailBlank_AGN +'\n';
        }
        else if(chkEmail == false){
            errorTxt += Label.OnlineConsent_PEmailError_AGN +'\n';
        }
        else if(additionalEmail != '' && chkSecEmail == false){
            errorTxt += Label.OnlineConsent_AEmailErrot_AGN +'\n';
        }
        else{
            
            try{        
                system.debug('baseurl: '+baseUrl);
                system.debug('secret: '+secret);
                system.debug('response: '+response);
                
                string responseBody = makeRequest(baseUrl,
                                                  'secret=' + secret +
                                                  '&response='+ response
                                                 );
                
                system.debug('response body: '+responseBody);
                string success = getValueFromJson(responseBody, 'success'); 
                
                if(success.equalsIgnoreCase('true')){                
                    successMsg = true;  
                    PageReference nextPage = SaveAndContinueUniqueCode();
                    return nextPage;
                }
                else{                    
                    errorTxt = Label.OnlineConsent_Recatpcha_AGN +'\n';             
                }            
            }
            catch(Exception ex){
                system.debug('error: '+ex);
                errorTxt += Label.OnlineConsent_ErrorUpdateAcc_AGN +'\n';   
            } 
        }
        
        if(errorTxt != NULL && !string.isBlank(errorTxt)){
            isErorTxtinRed = True;                 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorTxt);
            ApexPages.addMessage(myMsg);                 
            return null;            
        } 
        else{
            return null;
        } 
    }    
    
    public List<SelectOption> getLanguages() {
        List<selectOption> options = new List<selectOption>(); 
        List<AGN_OnlineConsent_Languages__c> langList = AGN_OnlineConsent_Languages__c.getAll().values();
        options.add(new Selectoption('', Label.OnlineConsent_SelectLang_AGN));
        for(AGN_OnlineConsent_Languages__c lang : langList) {                      
            options.add(new Selectoption(lang.Language_Name__c, lang.Name));
        } 
        return options;
    } 
    
    public pageReference ApplyCode(){   
        displayPersonalDetails = False;
        isErorTxtinRed = False;
        errorTxt = ''; 
		//isPharmaCustomer = False;        
        
        if(String.IsBlank(uniqueCode)) {
            errorTxt = Label.OnlineConsent_EnterCodeValid_AGN +'\n';                
        }       
        else{
            String trimUniqueCode = uniqueCode.trim();
            accountList = [Select Id, Salutation, FirstName, LastName, Consent_UniqueRef_AGN__c, PersonEmail, 
                           Email_Internal_AGN__c, Name_from_Consent_AGN__c, Country_vod__c, PersonIndividualId, IsPersonAccount ,Is_Pharma_Customer_AGN__c
                           FROM Account where Consent_UniqueRef_AGN__c = :trimUniqueCode];
            
            if(!accountList.isEmpty() && accountList.size() >0){
                if(accountList.size()>1){
                    errorTxt += Label.OnlineConsent_EnterCodeValid_AGN +'\n';
                }
                else{
                    account = accountList[0];
                    
                    if(account != null ){
                        //Start:Consent Portal change - block Pharma Customers from using the Consent Portal
                        if(account.Is_Pharma_Customer_AGN__c){
                           // isPharmaCustomer = true;
                            return page.AGN_OnlineConsent_PharmaRestricted;
                        }
                        else{
                            personName = ((account.Salutation != null) ? account.Salutation : '') +' '+ 
                                ((account.FirstName != null) ? account.FirstName : '' ) +' '+ 
                                account.LastName;
                            if(account.Country_vod__c != null && account.IsPersonAccount == True){
                                countryIdfromAccount = account.Country_vod__c;
                                if(franceCountryCodeId != '' && account.Country_vod__c == franceCountryCodeId){
                                    displayTOV = false;
                                }
                                else
                                    displayTOV = true;
                                
                                displayPersonalDetails = true;
                                primaryEmail = '';
                                additionalEmail = '';
                            }
                        }
                     //End:Consent Portal change - block Pharma Customers from using the Consent Portal
                    }  
                }                
            }
            else{//If not HCP
                errorTxt += Label.OnlineConsent_EnterCodeValid_AGN +'\n';
            }
        }
        
        if(errorTxt != NULL && !string.isBlank(errorTxt)){
            isErorTxtinRed = True;                 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorTxt);
            ApexPages.addMessage(myMsg);  
            return null;
        } 
        else{
            return null;
        }            
    }
    
    
    public PageReference SaveAndContinueUniqueCode()
    {
        defaultLanguage.value = languageSelectOption;
        if(additionalEmail != '')
            displayAdditionEmailDetails = true;
        
        System.debug('uniqueCode:: '+uniqueCode);
        if(uniqueCode != null && account != null)
        {
            try
            {
                account.Name_from_Consent_AGN__c = personName;
                account.PersonEmail = primaryEmail;
                account.Email_Internal_AGN__c = additionalEmail;
                update account;
                
                retrieveContentHeaderData();
                
                return new PageReference('/apex/AGN_OnlineConsent_ConsentPage'); 
            }  
            catch(Exception ex)
            {
                System.debug('Error while updating the account or retrieving the consent type: '+ex);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.OnlineConsent_ErrorUpdateAcc_AGN));               
            }
            return null;        
        }
        else
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.OnlineConsent_EnterCodeValid_AGN));
        return null;
    }
    
    public void retrieveContentHeaderData()
    {    
        //Updated as a part of ICL Project
        
        if(ApexPages.currentPage().getParameters().get('id')!=NULL)
        {
            languageSelectOption = [select Language_Code_AGN__c from AGN_ICL_Language_Settings__c where Name=: ApexPages.currentPage().getParameters().get('language')].Language_Code_AGN__c ;
            cancellang= languageSelectOption ;
        }
        //AM CC-Instead of storing the ID in a variable we are directly using it     
        List<Account> la=[Select country_vod__c from Account where id=:ApexPages.currentPage().getParameters().get('id')];
        //AM CC
        for(Account lac:la)
        {
            countryIdfromAccount=lac.country_vod__c;
        }
        System.debug('language: *********** '+languageSelectOption);
        if(languageSelectOption != null)
        {
            String statusofConsentType = 'Active_vod';
            /*       String query = 'Select Id, Channel_Label_vod__c, RecordTypeId, Consent_Header_vod__c, Disclaimer_Text_vod__c, Display_Order_vod__c, '+
'zvod_Consent_Default_Consent_Text_vod__c, RecordType.DeveloperName ' +
'from Consent_Type_vod__c '+
'where Consent_Header_vod__r.Language_vod__c = :languageSelectOption' +
' and Consent_Header_vod__r.Status_vod__c = :statusofConsentType' ;   */
            
            String query = 'Select Id, Channel_Label_vod__c, RecordTypeId, Consent_Header_vod__c, Disclaimer_Text_vod__c, Display_Order_vod__c, '+
                'zvod_Consent_Default_Consent_Text_vod__c, RecordType.DeveloperName, ' +
                ' (Select Id, Content_Type_Display_Name_vod__c, Content_Type_vod__c, Content_Type_vod__r.External_Id_vod__c From Consent_Type_vod__r order by Display_Order_vod__c) '+
                'from Consent_Type_vod__c '+
                'where Consent_Header_vod__r.Language_vod__c = :languageSelectOption' +
                ' and Consent_Header_vod__r.Status_vod__c = :statusofConsentType' ;                      
            
            List<String> recordTypeNames;
            if(countryIdfromAccount != null)
            {                
                query += ' and Consent_Header_vod__r.Country_vod__c = :countryIdfromAccount';
            }
            
            
            if(countryIdfromAccount == franceCountryCodeId)
            {
                recordTypeNames = new List<String>{'TOV_AGN'};
                    }
            
            if(recordTypeNames != null) query += ' and RecordType.DeveloperName Not In :recordTypeNames';
            
            query += ' order by Display_Order_vod__c';  
            
            System.debug('query*** '+query);
            System.debug('recordTypeNames** '+recordTypeNames);
            System.debug('countryIdfromAccount** '+countryIdfromAccount);
            System.debug('languageSelectOption** '+languageSelectOption);
            System.debug('statusofConsentType** '+statusofConsentType);
            
            consentTypeList =  Database.query(query);                         
            
            
            if(consentTypeList.isEmpty() || consentTypeList == null)
            {
                List<Consent_Header_vod__c> headerList = new List<Consent_Header_vod__c>(); 
                headerList = [Select Id, Language_vod__c from Consent_Header_vod__c where Language_vod__c = :languageSelectOption and Status_vod__c = 'Active_vod' limit 1];
                
                if(headerList != null && headerList.size() > 0)
                {
                    /*String queryL = 'Select Id, Channel_Label_vod__c, RecordTypeId, Consent_Header_vod__c, Disclaimer_Text_vod__c, Display_Order_vod__c,'+
' zvod_Consent_Default_Consent_Text_vod__c, RecordType.DeveloperName'+
' from Consent_Type_vod__c '+
'  where Consent_Header_vod__c = \''+headerList[0].Id +'\'';  */
                    
                    String queryL = 'Select Id, Channel_Label_vod__c, RecordTypeId, Consent_Header_vod__c, Disclaimer_Text_vod__c, Display_Order_vod__c,'+
                        ' zvod_Consent_Default_Consent_Text_vod__c, RecordType.DeveloperName,'+
                        ' (Select Id, Content_Type_Display_Name_vod__c, Content_Type_vod__c, Content_Type_vod__r.External_Id_vod__c From Consent_Type_vod__r) '+
                        ' from Consent_Type_vod__c '+
                        '  where Consent_Header_vod__c = \''+headerList[0].Id +'\'';                    
                    
                    List<String> recordTypeNamesL;
                    if(franceCountryCodeId != '' && countryIdfromAccount == franceCountryCodeId)
                    {
                        recordTypeNamesL = new List<String>{'TOV_AGN'};
                            }
                    
                    if(recordTypeNamesL != null) queryL += ' and RecordType.DeveloperName Not In :recordTypeNamesL';
                    
                    queryL += ' order by Display_Order_vod__c';   
                    
                    System.debug('queryL*** '+queryL);
                    consentTypeList =  Database.query(queryL);
                }
            }                 
        } 
        system.debug('consent type: '+consentTypeList);
        
        buildWrapperList(consentTypeList);
    }  
    
    private void buildWrapperList(List<Consent_Type_vod__c> consentTypeList)
    {          
        
        //Updated as a part of ICL Project   
        
        ID=ApexPages.currentPage().getParameters().get('id');
        system.debug('Updated as a part of ICL ProjectID'+ID);
        if(ID==NULL)
        {
            if(!consentTypeList.isEmpty() && consentTypeList != null)
            {
                for(Consent_Type_vod__c ct_vod : consentTypeList)
                {
                    
                    if(ct_vod.RecordType.DeveloperName == 'Approved_Email_vod')
                    {                       
                        if(ct_vod.Consent_Type_vod__r != null && !ct_vod.Consent_Type_vod__r.isEmpty()){ 
                            
                            List<String> disclaimerTextSplit = ct_vod.Disclaimer_Text_vod__c.split('<BR/>');         
                            
                            String prodDisText = '';
                            String allerganEventDisText = '';
                            String nonallerganDisText = '';
                            
                            //System.debug('disclaimer text::::::::::'+disclaimerTextSplit.size());
                            if(disclaimerTextSplit != null && !disclaimerTextSplit.isEmpty() && disclaimerTextSplit.size() > 10)
                            {
                                for(Integer i=0;i<disclaimerTextSplit.size();i++)
                                {                                    
                                    if(String.isNotBlank(disclaimerTextSplit[i]))
                                    {
                                        System.debug('i= '+i);
                                        if(i==2)
                                            prodDisText = disclaimerTextSplit[i];
                                        else if(i > 5 && i < disclaimerTextSplit.size()-3) 
                                            allerganEventDisText = disclaimerTextSplit[i];
                                        else if(i==disclaimerTextSplit.size()-1)
                                            nonallerganDisText = disclaimerTextSplit[i];                                        
                                    }                               
                                }
                            }
                            
                            
                            /*System.debug('prodDisText***'+prodDisText);
System.debug('allerganEventDisText***'+allerganEventDisText);
System.debug('nonallerganDisText***'+nonallerganDisText);      */                           
                            
                            for(Consent_Line_vod__c line : ct_vod.Consent_Type_vod__r){
                                System.debug('line.Content_Type_vod__r.External_Id_vod__c****  '+line.Content_Type_vod__r.External_Id_vod__c);
                                
                                
                                
                                if(line.Content_Type_vod__r.External_Id_vod__c == Label.AGN_OnlineConsent_PSMEmail_ExtId){
                                    ConsentWrapper wrapper = new ConsentWrapper();
                                    wrapper.consentRecordType = CONSENT_TYPE.APPROVED_EMAIL_VOD.name();
                                    
                                    wrapper.disclaimerText = prodDisText;
                                    
                                    wrapper.consentText  = ct_vod.zvod_Consent_Default_Consent_Text_vod__c;
                                    
                                    consentWrapperList.add(wrapper);
                                    
                                    
                                }else if(line.Content_Type_vod__r.External_Id_vod__c == Label.AGN_OnlineConsent_AllerganEvent_ExtId){
                                    ConsentWrapper wrapper = new ConsentWrapper();
                                    wrapper.consentRecordType = CONSENT_TYPE.ALLERGAN_EVENT_AGN.name();
                                    
                                    wrapper.disclaimerText = allerganEventDisText;
                                    wrapper.consentText  = ct_vod.zvod_Consent_Default_Consent_Text_vod__c;
                                    
                                    consentWrapperList.add(wrapper);
                                }else if(line.Content_Type_vod__r.External_Id_vod__c == Label.AGN_OnlineConsent_AllerganEvent_ExtId_Non_Allergan){
                                    ConsentWrapper wrapper = new ConsentWrapper();
                                    wrapper.consentRecordType = CONSENT_TYPE.NON_ALLERGAN_EVENT_AGN.name();
                                    wrapper.disclaimerText = nonallerganDisText;
                                    wrapper.consentText  = ct_vod.zvod_Consent_Default_Consent_Text_vod__c;
                                    
                                    consentWrapperList.add(wrapper);
                                }
                            }
                        }               
                    }
                    else
                    {
                        ConsentWrapper wrapper = new ConsentWrapper();
                        
                        //Updated as a part of ICL Project
                        
                        if(ct_vod.RecordType.DeveloperName != 'ICL_Consent_AGN')
                        {
                            //Updated as a part of ICL Project
                            if(ct_vod.RecordType.DeveloperName == 'TOV_AGN'){
                                wrapper.consentRecordType = CONSENT_TYPE.TOV_AGN.name();
                            }else{
                                wrapper.consentRecordType = CONSENT_TYPE.PHONE_AGN.name();
                            }
                            
                            
                            wrapper.disclaimerText = ct_vod.Disclaimer_Text_vod__c;
                            wrapper.consentText  = ct_vod.zvod_Consent_Default_Consent_Text_vod__c;
                            
                            consentWrapperList.add(wrapper);
                            
                        }//End of Updated as a part of ICL Project If
                        
                        
                    }
                    
                    
                    
                }
            }
            
            System.debug('consentWrapperList::: '+consentWrapperList);
        }
        
        //Updated as a part of ICL Project
        
        if(ID!=NULL)
        {   
            
            for(Consent_Type_vod__c ct_vod : consentTypeList)
            {
                ConsentWrapper wrapper = new ConsentWrapper();
                
                if(ct_vod.RecordType.DeveloperName == 'ICL_Consent_AGN' ){
                    
                    
                    wrapper.consentRecordType = 'ICL_Consent_AGN';
                    wrapper.disclaimerText = ct_vod.Disclaimer_Text_vod__c;
                    wrapper.consentText = ct_vod.zvod_Consent_Default_Consent_Text_vod__c;
                    consentWrapperList.add(wrapper);
                }
                
            }
            System.debug('consentWrapperListforICL::: '+consentWrapperList);
        }
        //Updated as a part of ICL Project
        
    }
    
    
    public PageReference FinalSave()
    {      
        isErorTxtinRed = False;
        errorTxt = ''; 
        
        if(prodServPhoneConsent && (phonenumber == '' || phonenumber == null))
        {
            errorTxt += Label.OnlineConsent_MobileErr_AGN +'\n';               
        }else
        {
            try
            {
                system.debug('Updated as a part of ICL Projectindividual');
                Id consentRecordId = createIndividualRecord();
                
                if(consentRecordId != null)
                {
                    if(account != null )
                    {
                        account.PersonIndividualId = consentRecordId;
                        
                        if(phonenumber != '' && phonenumber != null)
                            account.PersonMobilePhone = phonenumber;
                        
                        update account;
                        
                    }
                    
                    if(account.PersonEmail == account.Email_Internal_AGN__c)
                    {
                        if(prodServPrimaryEmailConsent || prodServAdditionalEmailConsent)
                        {
                            prodServPrimaryEmailConsent = true;
                            prodServAdditionalEmailConsent = true;
                        }
                        
                        if(allerganEventPrimaryEmailConsent || allerganEventAdditionalEmailConsent)
                        {
                            allerganEventPrimaryEmailConsent = true;
                            allerganEventAdditionalEmailConsent = true;
                        }
                        
                        if(nonAllerganEventPrimaryEmailConsent || nonAllerganEventAdditionalEmailConsent)
                        {
                            nonAllerganEventPrimaryEmailConsent = true;
                            nonAllerganEventAdditionalEmailConsent = true;
                        }
                        
                    }
                    
                    updateIndividualRecord(consentRecordId);
                    return new PageReference('/apex/AGN_OnlineConsent_Finish') ;
                }
                else
                    errorTxt += Label.OnlineConsent_ErrorUpdateAcc_AGN +'\n';
            }
            catch(Exception ex)
            {
                errorTxt += Label.OnlineConsent_ErrorUpdateAcc_AGN +'\n';
            }
        }
        if(errorTxt != NULL && !string.isBlank(errorTxt)){
            isErorTxtinRed = True;                 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorTxt);
            ApexPages.addMessage(myMsg);                 
            return null;
        } 
        else{
            return null;
        }     
    }
    
    public Id createIndividualRecord()
    {
        if(account != null && account.PersonIndividualId != null)        
            return account.PersonIndividualId;        
        else
        {
            Individual consentRecord = new Individual(LastName = account.LastName);
            insert consentRecord;
            
            return consentRecord.Id;
        }            
    }
    
    public void updateIndividualRecord(Id indId)
    {
        Individual consentRecord;
        
        if(account != null && indId != null)
        {
            consentRecord = new Individual( Id = indId, Salutation = account.Salutation, FirstName = account.FirstName,
                                           LastName = account.LastName, Online_consent__c = true,                                           
                                           Selected_Language__c = languageSelectOption,
                                           Country__c = countryIdfromAccount,
                                           Approved_Primary_Email__c = prodServPrimaryEmailConsent,
                                           Approved_Additional_Email__c = prodServAdditionalEmailConsent,
                                           Phone_Consent__c = prodServPhoneConsent,
                                           TOV_Consent__c = transFinancialConsent,
                                           Mobile_Number__c = phonenumber,
                                           Allergan_Event_Consent__c = allerganEventPrimaryEmailConsent,
                                           Allergan_Event_Adn_Email_Consent_AGN__c = allerganEventAdditionalEmailConsent,
                                           Non_Allergan_Event_Consent__c = nonAllerganEventPrimaryEmailConsent,
                                           Non_Allergan_Event_Adn_Consent_AGN__c = nonAllerganEventAdditionalEmailConsent,
                                           ICL_Flag_AGN__c=false
                                           
                                          );                     
        }        
        if(consentRecord != null) update consentRecord;        
    }
    
    public static string getValueFromJson ( String strJson, String field ){
        JSONParser parser = JSON.createParser(strJson);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                if(parser.getText() == field){
                    // Get the value.
                    parser.nextToken();
                    return parser.getText();
                }
            }
        }
        return null;
    }
    
    public static string makeRequest(string url, string body)  {
        
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        
        try {
            Http http = new Http();
            response = http.send(req);
            return response.getBody();
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return '{"success":false}';
    }
    
    public PageReference Cancel(){
        displayPersonalDetails = False;
        displayAdditionEmailDetails = false;
        uniqueCode = '';
        accountList = new List<Account>();
        isErorTxtinRed = false;
        errorTxt = '';
        
        languageSelectOption = '';
        uniqueCode = '';
        primaryEmail = '';
        additionalEmail = '';
        phonenumber = '';
        personName = '';
        countryIdfromAccount = '';
        defaultLanguage = new StringCarrier();
        defaultLanguage.value = 'en_US';
        
        consentTypeList= new List<Consent_Type_vod__c>();
        
        prodServPrimaryEmailConsent = false;
        prodServAdditionalEmailConsent = false;
        prodServPhoneConsent = false;
        transFinancialConsent = false;
        
        allerganEventPrimaryEmailConsent = false;
        allerganEventAdditionalEmailConsent = false;
        nonAllerganEventPrimaryEmailConsent = false;
        nonAllerganEventAdditionalEmailConsent = false;
        
        displayTOV = true;
        displayContinueBtn = false;
        
        return new PageReference('/apex/AGN_OnlineConsent_HomePage') ; 
        
        
    }
    
    public static Boolean validateMyEmail(String email) {
        Boolean res = true;           
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }
    
    public class ConsentWrapper
    {
        public String consentRecordType {get; set;}
        public String disclaimerText {get; set;}
        public String consentText {get; set;}       
    }
    
    //Updated as a part of ICL Project
    
    /*  public PageReference doredirect()
{
system.debug('Updated as a part of ICL Project');

displayAdditionEmailDetails = true;
prodServPrimaryEmailConsent=true;
consentWrapperList = new List<ConsentWrapper>();
consentTypeList = new List<Consent_Type_vod__c>();

retrieveContentHeaderData();

return new PageReference('/apex/AGN_OnlineConsent_ConsentPage'); 

} */
    
    public void doredirect()
    {
        system.debug('Updated as a part of ICL Project');
        
        displayAdditionEmailDetails = true;
        prodServPrimaryEmailConsent=true;
        consentWrapperList = new List<ConsentWrapper>();
        consentTypeList = new List<Consent_Type_vod__c>();
        
        retrieveContentHeaderData();
        
        // return new PageReference('/apex/AGN_OnlineConsent_ConsentPage'); 
        
    }
    
    
    public PageReference ICLConsentRecord()
    {      
        //AM CC
        //ID=ApexPages.currentPage().getParameters().get('id');
        //Id practitionerId = ApexPages.currentPage().getParameters().get('pid');
        
        Individual consentRecord;
        Account account=[select Salutation,FirstName,LastName,PersonIndividualId,PersonEmail from Account where id=:ApexPages.currentPage().getParameters().get('id')];
        List<Practitioner_Listing_AGN__c> praclist = [select Id,Email_AGN__c from Practitioner_Listing_AGN__c where Id = :ApexPages.currentPage().getParameters().get('pid')]; 
        
        List<Account> acc=[select PersonIndividualId from Account where id =:ApexPages.currentPage().getParameters().get('id') and PersonIndividualId !=null];
        //AM CC 
        if(acc.isEmpty())
        {
            consentRecord = new Individual( Salutation = account.Salutation, FirstName = account.FirstName,
                                           LastName = account.LastName, Online_consent__c = true,                                           
                                           Selected_Language__c = languageSelectOption,
                                           Country__c = countryIdfromAccount,
                                           ICL_Flag_AGN__c=true,                                                     
                                           ICL_PractitionerEmail_AGN__c = praclist[0].Email_AGN__c,
                                           ICL_Consent_AGN__c=ICLConsent);
            System.debug('indvv************************* '+consentRecord);
            insert consentRecord;
            
            Individual consent=[select ID,createddate,Lastmodifieddate from Individual order by createddate desc limit 1];
            
            account.PersonIndividualId = consentRecord.ID;
            
            
            update account;
            
            //AG CC
            if(Schema.sObjectType.Practitioner_Listing_AGN__c.fields.Consent_AGN__c.isUpdateable())
            {
                praclist[0].Consent_AGN__c=ICLConsent;
            }
            if(Schema.sObjectType.Practitioner_Listing_AGN__c.fields.Consent_Check_AGN__c.isUpdateable())
            {
                praclist[0].Consent_Check_AGN__c=true;
            }
            update consentRecord;
            update praclist;                     
        }     
        else
        {
            
            
            Individual consent=[select ID from Individual where ID=:acc[0].PersonIndividualId];
            List<Practitioner_Listing_AGN__c>  pla=new List<Practitioner_Listing_AGN__c>();
            for(Practitioner_Listing_AGN__c pl:praclist)
            { 
                //AG CC
                if(Schema.sObjectType.Practitioner_Listing_AGN__c.fields.Consent_AGN__c.isUpdateable())
                {
                    pl.Consent_AGN__c=ICLConsent;
                }
                consent.ICL_Consent_AGN__c=ICLConsent;
                //Added on 24.07
                consent.ICL_Flag_AGN__c=true;
                //Added on  24.07
                if(Schema.sObjectType.Practitioner_Listing_AGN__c.fields.Consent_Check_AGN__c.isUpdateable())
                {
                    pl.Consent_Check_AGN__c=true;
                }
                update consent;
                pla.add(pl);
            }
            system.debug('UpdateList'+pla);
            update pla;
            
            
        }          
        return new PageReference('/apex/AGN_OnlineConsent_Finish') ;         
    }   
    
}