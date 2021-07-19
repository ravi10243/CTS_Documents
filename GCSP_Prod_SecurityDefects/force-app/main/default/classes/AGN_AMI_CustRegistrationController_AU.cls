public without sharing class AGN_AMI_CustRegistrationController_AU  {
    
    /*****SWAR START******/
    public Boolean verified { get; private set; }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('g-recaptcha-response');
        }
    }
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String publicKey {get;set;}
     
    private String remoteHost{
        get {
            String ret = '127.0.0.1';
            //Also could use x-original-remote-host
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret = hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret = hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
     
    //Google Secret Key
    private static String secretKey = [Select Secret_key__c from AMI_Captcha_Settings__c LIMIT 1].Secret_key__c;
    private static String baseUrl = [Select Base_URL__c from AMI_Captcha_Settings__c LIMIT 1].Base_URL__c;
    
    
    
    /*****SWAR END******/
    
    public Allergan_Customer_Registration_AGN__c custReg{ get; set; }
    public Allergan_Customer_Address_AGN__c custAdd{get;set;}    
    transient Public list<Country_vod__c>  countryList;   
    public List<SelectOption>  countryCollection {get;set;}
    transient public string lang_code;
    public AMI_Language_AGN__c defLang {get; set;}
    public string headercountry{get;set;}
    public List<SelectOption> languageList{get;set;}
    public Attachment attach{ get ; set;  } 
    String countryCode;
    transient list<string> uniqueSpecialityList;
    public string country{ get ; set; } 
    transient string croid;
    public List<SelectOption> customerSpeciality {get; set;}
    List<SelectOption> customerSubType {get; set;}
    transient List<Specialty_AGN__c> lstSpecialty; 
    transient List<AMI_SPecality_AGN__c> lstAMISpeciality; 
    //Added for Turkey - Start
    transient List<Specialty_Allergan_AGN__c> lstSpecialtyAllergan;
    public List<SelectOption> getAllerganEducation {get; set;}
    public Boolean CountryManagedSpeciality;
    //Added for Turkey - End
    public boolean registrationSuccess {get; set;}
    public string phone{get;set;}
    public string phoneExt{get;set;}
    String tempcountry;
    String ClusterCountryCode;
    
    public string physical_reg_code{get;set;}	
    public string street{get;set;}
    
    // Added for PMO#2601
    public Boolean showSpecCA {get; set;}
    public string designationCA { get { return 'Physician'; } set; }
    
    public AGN_AMI_CustRegistrationController_AU() {
        /*** SWAR START ****/
        this.publicKey = [Select Site_Key__c from AMI_Captcha_Settings__c LIMIT 1].Site_Key__c;
        this.verified = false;
        /*** SWAR END ****/
        
        registrationSuccess = false;
        showSpecCA = false; // Added for PMO#2601
        system.debug('entering if condtion1>>>>>');
        country=ApexPages.currentPage().getParameters().get('country');
        system.debug('entering if country>>>>>' + country);
        // SPARK integration changes
        string croid=ApexPages.currentPage().getParameters().get('croId');
        System.debug('..............................custReg.croid : '+croid);
        if(croid!=null)
        { 
            custReg = getSparkCustomerInfo(croid);
            System.debug('..............................custReg.Is_From_Spark_AGN__c : '+custReg.Is_From_Spark_AGN__c);
            if(custReg.Is_From_Spark_AGN__c){
                
            }
            country=custReg.Country_Code_AGN__c;
            lstSpecialty=new List<Specialty_AGN__c>();
            lstSpecialty=[select Id,Name,Country_code_AGN__c from Specialty_AGN__c where Country_code_AGN__c=:country order by Name ASC];
            /*AMI MENA changes- Start */
            if(lstSpecialty.size()==0){
                ClusterCountryCode= [Select Cluster_Country_AGN__c From Country_vod__c Where Name=:country].Cluster_Country_AGN__c;
                if(ClusterCountryCode!=null)
                {
                    lstSpecialty=[select Id,Name,Country_code_AGN__c from Specialty_AGN__c where Country_code_AGN__c=:ClusterCountryCode order by Name ASC];
                }
            }
            /*AMI MENA changes- End */
            
            /*AMI MENA changes- Start */
            //tempcountry=country;
            //AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            //country =  userDetails.userCountryName;
            /*AMI MENA changes- End */
            lstAMISpeciality = [select Id,Allergan_Speciality_Name_AGN__c,Name_AGN__c,Name,Country_code_AGN__c from AMI_SPecality_AGN__c where Country_code_AGN__c=:country order by Allergan_Speciality_Name_AGN__c ASC];
            /*AMI MENA changes- Start */
            //country=tempcountry;
            /*AMI MENA changes- End */
            languageList=new List<SelectOption>();             
            system.debug('country >>>>>>>>>>>>>>>>>>>>>' + country);            
            uniqueSpecialityList = new List<String>();
            custAdd= new Allergan_Customer_Address_AGN__c();  
            attach= new Attachment();              
            custAdd =getAddressInfo(croid);
            custAdd.Country_Lookup_AGN__c =  custReg.Country_AGN__c;
            system.debug('Address country >>>>>>>>>>>>>>>>>>>>>' + custAdd.Country_Lookup_AGN__c);
            if(custReg.Language_AGN__c != null)
                lang_code = custReg.Language_AGN__c;
            else
                lang_code = 'en_GB';            
            
        }
        else
        {
            system.debug('entering else condtion>>>>>');
            country=ApexPages.currentPage().getParameters().get('country');
            lstSpecialty=new List<Specialty_AGN__c>();
            system.debug('Constructor country'+country); 
            
            /*AMI MENA changes- Start */
            //tempcountry=country;
            //AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            //country =  userDetails.userCountryName;
            /*AMI MENA changes- End */    
            lstSpecialty=[select Id,Name,Country_code_AGN__c from Specialty_AGN__c where Country_code_AGN__c=:country order by Name ASC];
            /*AMI MENA changes- Start */
            if(lstSpecialty.size()==0){
                ClusterCountryCode= [Select Cluster_Country_AGN__c From Country_vod__c Where Name=:country].Cluster_Country_AGN__c;
                if(ClusterCountryCode!=null)
                {
                    lstSpecialty=[select Id,Name,Country_code_AGN__c from Specialty_AGN__c where Country_code_AGN__c=:ClusterCountryCode order by Name ASC];
                }
            }
            /*AMI MENA changes- End */             
            lstAMISpeciality = [select Id,Allergan_Speciality_Name_AGN__c,Name_AGN__c,Name,Country_code_AGN__c from AMI_SPecality_AGN__c where Country_code_AGN__c=:country order by Allergan_Speciality_Name_AGN__c ASC];
            system.debug('lstSpecialty-->'+lstSpecialty);
            system.debug('lstSpecialty-->'+lstAMISpeciality); 
            //Added for Turkey - Start
            lstSpecialtyAllergan=new List<Specialty_Allergan_AGN__c>();
            lstSpecialtyAllergan=[select Id,Name,Country_code_AGN__c from Specialty_Allergan_AGN__c where Country_code_AGN__c=:country order by Name ASC];
            /*AMI MENA changes- Start */
            if(lstSpecialtyAllergan.size()==0 || country=='EG'){ // wrong data present in veeva object for Egypt
                ClusterCountryCode= [Select Cluster_Country_AGN__c From Country_vod__c Where Name=:country].Cluster_Country_AGN__c;
                if(ClusterCountryCode!=null)
                {
                    lstSpecialtyAllergan=[select Id,Name,Country_code_AGN__c from Specialty_Allergan_AGN__c where Country_code_AGN__c=:ClusterCountryCode order by Name ASC];
                }
            }
            /*AMI MENA changes- End */ 
            system.debug('lstSpecialtyAllergan>>>>'+ lstSpecialtyAllergan);
            //Added for Turkey - End  
            /*AMI MENA changes- Start */
            //country=tempcountry;    
            /*AMI MENA changes- End */     
            languageList=new List<SelectOption>(); 
            uniqueSpecialityList = new List<String>();
            custReg= new Allergan_Customer_Registration_AGN__c (RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'New_AMI_AGN'].Id,
                                                                Account_Type_AGN__c = 'Professional' );  
            custAdd= new Allergan_Customer_Address_AGN__c();  
            attach= new Attachment();
            system.debug('country:' + ApexPages.currentPage().getParameters().get('countryCode')); 
            if(ApexPages.currentPage().getParameters().get('countryCode') != null && ApexPages.currentPage().getParameters().get('countryCode')!='null')
            {
                custReg.Country_AGN__c= ApexPages.currentPage().getParameters().get('countryCode');             
                custAdd.Country_Lookup_AGN__c =  custReg.Country_AGN__c;
            }
            if(ApexPages.currentPage().getParameters().get('userlang')!=null)
                custReg.Language_AGN__c= ApexPages.currentPage().getParameters().get('userlang');
            if(ApexPages.currentPage().getParameters().get('firstName')!=null)
                custReg.First_Name_AGN__c= ApexPages.currentPage().getParameters().get('firstName')=='null'?'': ApexPages.currentPage().getParameters().get('firstName');
            if(ApexPages.currentPage().getParameters().get('lastName')!=null)
                custReg.Last_Name_AGN__c= ApexPages.currentPage().getParameters().get('lastName')=='null'?'': ApexPages.currentPage().getParameters().get('lastName');
            if(ApexPages.currentPage().getParameters().get('email')!=null)
                custReg.Email_AGN__c= ApexPages.currentPage().getParameters().get('email')=='null'?'': ApexPages.currentPage().getParameters().get('email');
            if(ApexPages.currentPage().getParameters().get('registrationRef')!=null)
                custReg.Physician_Registration_Reference_AGN__c= ApexPages.currentPage().getParameters().get('registrationRef')=='null'?'': ApexPages.currentPage().getParameters().get('registrationRef');     
            
            //countryList = [SELECT Id, Name,AGN_Country_Name__c, Cluster_Country_AGN__c From Country_vod__c];
            
            if(ApexPages.currentPage().getParameters().get('lang') != null)
                lang_code = ApexPages.currentPage().getParameters().get('lang');
            else
                lang_code = 'en_GB';
        }
        defLang=AMI_Language_AGN__c.getvalues(lang_code)!=null?AMI_Language_AGN__c.getvalues(lang_code):AMI_Language_AGN__c.getvalues('en_GB');
        headerCountry=defLang!=null?defLang.Language__c:AMI_Language_AGN__c.getvalues('en_GB').Language__c;
        languageList.add(new SelectOption(defLang.Lang_Code__c,defLang.Language__c));
        countryList = [SELECT Id, Name,AGN_Country_Name__c, Cluster_Country_AGN__c From Country_vod__c];  
        system.debug('countryList-->'+countryList);    
        selectSpecialityList();
        countryCollection=getcountryList();
        system.debug('..............countryCollection.............'+countryCollection);
    }   
    
    /* Added for SPARK user enabling */
    public Allergan_Customer_Registration_AGN__c getSparkCustomerInfo(string croid)
    {
        Allergan_Customer_Registration_AGN__c sparkCustomerInfo = new Allergan_Customer_Registration_AGN__c();
        sparkCustomerInfo =[select Id,First_Name_AGN__c,Last_Name_AGN__c,Language_AGN__c,BirthDate_AGN__c,Birth_Date_EU_format_AGN__c,Phone_AGN__c,Case_AGN__c,
                            Mobile_AGN__c,Country_AGN__r.AGN_Country_Name__c,Country_Code_AGN__c,Email_AGN__c,Physician_Registration_Reference_AGN__c, AMI_Registration_AGN__c,
                            Salutation_AGN__c,Specialty_1_AGN__c,Specialty_Allergan_1_AGN__c,
                            MDCodesCategory_AMI_AGN__c,MDCodesCategory_OEU_AMI_AGN__c, Is_From_Spark_AGN__c, Allergan_Education_AMI_AGN__c, Specialty_Comments_AMI_AGN__c, Specialty_AMI_AGN__c 
                            from Allergan_Customer_Registration_AGN__c where Id=:croid];   
        return sparkCustomerInfo;
    }
    
    /* Added for SPARK user enabling */
    public PageReference isAMIEnabledUser(){
        string croid = ApexPages.currentPage().getParameters().get('croId');
        if(String.isNotBlank(croid)){
            Id pSetId = [SELECT id, name,profileid FROM permissionset WHERE Name ='AGN_AMI_Portal_Access'].id; 
            Allergan_Customer_Registration_AGN__c sparkCustomerInfo = [SELECT Id, Country_Code_AGN__c, Language_AGN__c, Is_From_Spark_AGN__c, Account_AGN__r.AGN_AMI_Enabled__c  
                                                                       FROM Allergan_Customer_Registration_AGN__c WHERE Id=:croid];
            for (PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.id =: pSetId AND AssigneeId =: UserInfo.getUserId() LIMIT 1]){
                
                
                if(String.isNotBlank(psa.AssigneeId) && sparkCustomerInfo.Account_AGN__r.AGN_AMI_Enabled__c){
                    PageReference amiLandingPage = Page.AGN_AMI_Landing_Page;
                    // amiLandingPage.getParameters().put('country', sparkCustomerInfo.Country_Code_AGN__c);
                    //amiLandingPage.getParameters().put('lang', sparkCustomerInfo.Language_AGN__c);
                    return amiLandingPage;
                }  
            }            
        } 
        return null;
    }
    
    public Allergan_Customer_Address_AGN__c getAddressInfo(string parentId)
    {
        Allergan_Customer_Address_AGN__c addr= new Allergan_Customer_Address_AGN__c();        
        addr = [select Company_Name_AGN__c,Street_Name_AGN__c,House_Number_AGN__c,City_AGN__c,
                Country_AGN__c,Zip_AGN__c,State_AMI_AGN__c
                from Allergan_Customer_Address_AGN__c where Parent_AGN__c =:parentId];
        return addr;
        
    }
    
    
    
    public List<SelectOption> getcountryList(){
        
        List<SelectOption> optns = new List<Selectoption>();
        for(Country_vod__c country: countryList ){  
            
            if(custReg.Country_AGN__c==country.id){
                
                if(country.Cluster_Country_AGN__c != null)
                {
                    countryCode = country.Cluster_Country_AGN__c;
                }
                else
                {
                    countryCode = country.Name;
                }
                
                custAdd.Country_AGN__c= country.AGN_Country_Name__c;
                System.debug(custAdd.Country_AGN__c);
                //Australia Changes - start
                /*if (country.AGN_Country_Name__c == 'Australia')
				optns.add(new selectOption(country.Id, 'Australia/New Zealand'));
				else*/
                optns.add(new selectOption(country.Id, country.AGN_Country_Name__c));
                //Australia Changes - end
                //optns.add(new selectOption(country.Id, country.AGN_Country_Name__c));
            }
        }     
        return optns;
    }      
    
    public void selectLanguage(){
        set<String> uniqueLanguage = new set<String>();
        languageList = new List<SelectOption>();
        string country=[select name from Country_vod__c where id=:custReg.Country_AGN__c limit 1].Name;
        List<AMI_Language_AGN__c> lstLanguages=AMI_Language_AGN__c.getAll().values();
        for( AMI_Language_AGN__c lang : lstLanguages){
            if (lang.Country__c == country){
                uniqueLanguage.add(lang.Language__c);              
            }
        }
        
        for( string l : uniqueLanguage){
            languageList.add(new SelectOption(l , l));
        }
        languageList.sort();
    }
    
    
    public PageReference Clear() {
        
        PageReference newpage = new PageReference(System.currentPageReference().getURL());
        newpage.setRedirect(true);
        return newpage;
        
    }   
    
    public void createNewCustomerRegistration(){  
        
        if (response!= null ){
        	HttpResponse res = getGoogleReCAPTCHAResponse(baseUrl,'secret=' + secretKey + '&remoteip=' + remoteHost + '&response=' + response);
            if (res != null ) {
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'success')) {
                        parser.nextToken();
                        this.verified = parser.getBooleanValue();
                        break;
                    }
                }            
            }
            if(this.verified){ // write registration logic if verified true
        		system.debug('Inside createNewCustomerRegistration');
        country=ApexPages.currentPage().getParameters().get('country');
        // countryCode=ApexPages.currentPage().getParameters().get('countryCode');        
        if(!checkDuplicateRegistration()) 
        {
            try{            
                case cs = new case();
                // Spark user changes
                if(custReg.Case_AGN__c != null){
                    cs.Id = custReg.Case_AGN__c;
                }
                cs.Service_AGN__c = 'AMI Customer Registration';
                cs.Type = 'New';
                cs.Reason = 'New Customer Registration';
                cs.Priority = 'Medium';
                cs.Origin = 'Web';
                cs.Status = 'New';
                cs.Country_Code_AGN__c = country;
                cs.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Support_Request_AMI_Customer_Registration_AGN' LIMIT 1][0].Id;
                cs.SuppliedName = custReg.First_Name_AGN__c+ ' ' + custReg.Last_Name_AGN__c;
                cs.Subject =custReg.First_Name_AGN__c+ ' '+ custReg.Last_Name_AGN__c+ ' - ' + cs.Type;
                cs.SuppliedEmail = custReg.Email_AGN__c;
                cs.Case_Sub_Status_AGN__c='AMI Registration - In Progress';            
                upsert cs;            
                //create customer registration
                custReg.Online_Registration_Step_AGN__c='2';
                custReg.AMI_Registration_AGN__c= true;
                custReg.Case_AGN__c = cs.Id;
                // custReg.Account_AGN__c = acc.Id;
                custReg.Trigger_Validation_of_Children__c = false;
                // Spark user changes 
                if(custReg.id != null){
                    custReg.Use_Existing_Account_AGN__c = true;
                    custReg.Is_From_Spark_AGN__c = true;
                }           
                if (custReg.RecordTypeId == null){
                    custReg.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'New_AMI_AGN'].Id;  
                }
                
                //mapCustomerType(configList, customerAddress, custReg);
                //  custReg.OwnerId = OWNER_ID;
                custReg.Processed_By_SAP_AGN__c = 'In Progress';
                custReg.Country_Code_AGN__c=countryCode ;
                system.debug('custReg.Country_Code_AGN__c-->>' + custReg.Country_Code_AGN__c);
                custReg.AMI_Registration_AGN__c=true; //added
                custReg.Portal_Access_AGN__c='AMI';
                
                //Added 3/12/2019
                if(String.isNotBlank(phone) && String.isNotBlank(phoneExt)){
                    custReg.Phone_AGN__c = phone + '[' + phoneExt + ']';
                }
                
                else if(String.isNotBlank(phone)){
                    custReg.Phone_AGN__c = phone;
                }
                else if (String.isNotBlank(phoneExt)){
                    custReg.Phone_AGN__c = '[' + phoneExt + ']';
                }
                //End Added3/12/2019
                //PMO-3285 adding registration code to registration field	
                if(String.isNotBlank(physical_reg_code)){	
                    custReg.Physician_Registration_Reference_AGN__c=custReg.Physician_Registration_Reference_AGN__c+'_'+physical_reg_code;	
                }
                //Remove when used in DE
                if (Apexpages.currentPage().getParameters().get('emailconsent') != null && Apexpages.currentPage().getParameters().get('emailconsent') != '')
                    custReg.Email_Consent_AMI_AGN__c = Boolean.valueOf(Apexpages.currentPage().getParameters().get('emailconsent'));
                if (Apexpages.currentPage().getParameters().get('phoneconsent') != null && Apexpages.currentPage().getParameters().get('phoneconsent') != '')
                    custReg.Phone_Consent_AMI_AGN__c = Boolean.valueOf(Apexpages.currentPage().getParameters().get('phoneconsent'));                
                //custAdd.Invited_By_AMI_AGN__c = Apexpages.currentPage().getParameters().get('invitedBy');
                
                Integer myIntDate  = 0;
                Integer myIntMonth = 0;
                Integer myIntYear = 0;
                if(custReg.BirthDate_AGN__c != null)
                {
                    Date dtString1 = custReg.BirthDate_AGN__c;
                    String dtString = string.valueOf(dtString1);                
                    String[] strDate = dtString.split('-');
                    myIntDate  = integer.valueOf(strDate[2]);
                    myIntMonth = integer.valueOf(strDate[1]);
                    myIntYear = integer.valueOf(strDate[0]);
                }
                //custReg.Specialty_1_AGN__c=custReg.Specialty_Allergan_1_AGN__c;
                DateTime dtm = DateTime.newInstance(myIntYear,myIntMonth,myIntDate);
                Date dt = date.newinstance(dtm.year(), dtm.month(), dtm.day());  
                system.debug('dt-->'+dt);  
                system.debug('custReg.Mobile_AGN__c--'+custReg.Mobile_AGN__c);
                system.debug('custReg.Phone_AGN__c-->'+custReg.Phone_AGN__c);
                system.debug('custReg.Salutation_AGN__c-->'+custReg.Salutation_AGN__c);
                system.debug('custReg.MDCodesCategory_AMI_AGN__c-->'+custReg.MDCodesCategory_AMI_AGN__c);
                system.debug('custReg.AMI_Instagram_Handle_AGN__c-->'+custReg.AMI_Instagram_Handle_AGN__c);
                system.debug('custReg.AMI_Instagram_Handle_AGN__c-->'+custReg.AMI_Instagram_Handle_AGN__c);
                // custReg.Language_AGN__c=[select Language__c from AMI_Language_AGN__c where id=:regLanguage limit 1].Language__c;
                
                upsert custReg;  
                system.debug('custReg upserted');
                if((country =='AN') || (country =='TR')){
                    //Australia changes - attachment - start
                    attach.contentType = 'application/pdf'; 
                    attach.ParentId = custReg.Id;
                    system.debug('==attachmentParentId=='+ attach.ParentId);
                    system.debug('==attachmentName=='+ attach.Name);
                    system.debug('==attachmentBody=='+ attach.Body);
                    if(attach.body != null ) {  
                        insert attach;
                    }
                    attach=new attachment();
                }
                //Australia changes - attachment - end            
                //create sold to address
                //custAdd.Company_Name_AGN__c= custReg.First_Name_AGN__c+ ' ' + custReg.Last_Name_AGN__c;
                //system.debug('custAdd.Company_Name_AGN__c-->'+custAdd.Company_Name_AGN__c);
                //custAdd.Company_Name_AGN__c = Apexpages.currentPage().getParameters().get('hospital'); 
                
                If(custAdd.Id == null){
                    custAdd.Parent_AGN__c = custReg.Id;
                }
                //custAdd.Sold_To_AGN__c = true; 
                custAdd.Email_AGN__c = custReg.Email_AGN__c;
                custAdd.Phone_AGN__c = custReg.Phone_AGN__c;  
                //3285	
                if(String.isNotBlank(street)){	
                    custAdd.Street_Name_AGN__c= custAdd.Street_Name_AGN__c+' '+street;
                }
                
                custAdd.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New_AMI_AGN'].Id;                              
                upsert custAdd;                  
                system.debug('custAdd upserted');     
                if(!string.isBlank(custReg.id)){
                    AGN_AMI_Case_Next.gotoNextStep(cs.id);
                    // PMO#2734 Consent Email Start
                    AMI_User_Settings_AGN__c aus = AMI_User_Settings_AGN__c.getInstance(cs.Country_Code_AGN__c);
                    if(aus.Consent_Required_AGN__c)
                    {
                        List<Messaging.SingleEmailMessage > emailList = new List<Messaging.SingleEmailMessage>();
                        Id templateId = [Select id from EmailTemplate 
                                         where DeveloperName = 'AGN_AMI_Communities_Consent_Verification' Limit 1].Id;
                        Id senderId = [Select id from OrgWideEmailAddress where DisplayName = 'AMI Sender' Limit 1].Id;
                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId,UserInfo.getUserId(),custReg.Id);
                        List<String> emailAddress = new List<String>();
                        emailAddress.add(custReg.Email_AGN__c);
                        email.setToAddresses(emailAddress);
                        email.setOrgWideEmailAddressId(senderId);
                        email.setSaveAsActivity(false);
                        emailList.add(email);
                        Messaging.sendEmail(emailList);
                    }
                    // PMO#2734 Consent Email End
                }
                registrationSuccess = true;
            }
            catch(exception e){
                system.debug('Exception : '+e.getMessage());
                AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_CustRegistrationController_AU','Registration_Submitted');
            }
        }    
            }
        }
        
        
    }   
    
    public List<SelectOption> getSalutaionList(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> oeuList = new List<String>{'BE','NL'};
        options.add(new SelectOption( '', '--'));
        Schema.DescribeFieldResult fieldResult; 
        //currently added for canada - start        
        if(country == 'CA'){
            fieldResult = Allergan_Customer_Registration_AGN__c.AMI_Account_Salutation__c.getDescribe(); 
        }
        else if(country == 'TR'){
            /* fieldResult = Allergan_Customer_Registration_AGN__c.Salutation_AGN__c.getDescribe();*/
            /*options.add(new SelectOption('Mr.','Mr.'));
			options.add(new SelectOption('Mrs.','Mrs.'));*/
            options.add(new SelectOption('Dr.','Dr.'));
            options.add(new SelectOption('Prof.','Prof.'));
        }
        else if(oeuList.contains(country)){
            
            options.add(new SelectOption('Mr.','Mr.'));
            options.add(new SelectOption('Mrs.','Mrs.'));
            options.add(new SelectOption('Dr.','Dr.'));
            options.add(new SelectOption('Nurse','Nurse'));
            options.add(new SelectOption('Ms.','Ms.'));
            options.add(new SelectOption('Miss','Miss'));
            options.add(new SelectOption('Prof.','Prof.'));
            options.add(new SelectOption('Drs','Drs'));            
        }
        else{
            fieldResult = Allergan_Customer_Registration_AGN__c.Salutation_AGN__c.getDescribe();
        }     
        //currently added for canada - end 
        
        if(fieldResult != null){        
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
            for( Schema.PicklistEntry f : ple){
                options.add(new SelectOption( f.getValue(), f.getLabel()));
            } 
        }
        return options;
    } 
    
    //currently added for Canada - start
    public List<SelectOption> getDesignationList(){
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '', '--'));
        Schema.DescribeFieldResult fieldResult = Allergan_Customer_Registration_AGN__c.AMI_Account_Designation_AGN__c.getDescribe();     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption( f.getValue(), f.getLabel()));
        }   
        return options;
    }
    //currently added for Canada - end 
    
    
    //currently added for Turkey - start
    public List<SelectOption> getAllerganEducation(){
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '', '--'));
        Schema.DescribeFieldResult fieldResult = Allergan_Customer_Registration_AGN__c.Allergan_Education_AMI_AGN__c.getDescribe();     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption( f.getValue(), f.getLabel()));
        }   
        return options;
    }
    //currently added for Turkey - end
    
    public PageReference selectSpecialityList(){
        
        Map<String,String> uniqueSpeciality = new Map<String,String>();      
        customerSpeciality = new List<SelectOption>();  
        customerSpeciality.add(new SelectOption( '', '--'));
        List<String> uniqueSpecialityListTemp = new List<String>();
        system.debug('Inside selectSpecialityList');
        /*AMI MENA changes- Start */
        //tempCountry=country;
        //AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        //system.debug('userDetails.userCountryName-->'+userDetails.userCountryName);
        //system.debug('userDetails.maskedUserCountryName-->'+userDetails.maskedUserCountryName);
        //country =  userDetails.userCountryName;
        /*AMI MENA changes- End */
        //Added for Turkey -- Start 
        //Added for Country managed speciality -- Start 
        List<AMI_User_Settings_AGN__c> userSettings = [Select Name,Country_Managed_Specialty_AGN__c from AMI_User_Settings_AGN__c where Name =:country];
        for(AMI_User_Settings_AGN__c usrS : userSettings){
            
            CountryManagedSpeciality = usrS.Country_Managed_Specialty_AGN__c;
        }
        
        
        //if(country == 'BR' || country == 'ES'){
        if(CountryManagedSpeciality == true){    
            for(Specialty_Allergan_AGN__c s : lstSpecialtyAllergan)     
            {       
                for(AMI_SPecality_AGN__c asp : lstAMISpeciality)        
                {
                    
                    if(s.Name==asp.Allergan_Speciality_Name_AGN__c)     
                    {       
                        if(!uniqueSpecialityListTemp.contains(asp.Name_AGN__c))     
                        {       
                            uniqueSpeciality.put(asp.Name_AGN__c,s.Id); 
                            uniqueSpecialityList.add(s.Id);     
                            uniqueSpecialityListTemp.add(asp.Name_AGN__c);      
                        }       
                    }       
                }                   
            }       
            for(String speciality : uniqueSpeciality.keySet()){     
                customerSpeciality.add(new SelectOption(uniqueSpeciality.get(speciality), speciality ));        
            }       
            for (Integer i =0; i < customerSpeciality.size(); i++) {        
                
                for (Integer j = i; j > 0; j--) {       
                    
                    if (customerSpeciality[j-1].getLabel() > customerSpeciality[j].getLabel()){     
                        SelectOption temp = customerSpeciality[j];      
                        customerSpeciality[j] = customerSpeciality[j-1];        
                        customerSpeciality[j-1] = temp;     
                    }       
                }       
            }       
            
        }       
        //Added for Country managed speciality -- End       
        else{
            for(Specialty_AGN__c s : lstSpecialty)
            {
                for(AMI_SPecality_AGN__c asp : lstAMISpeciality)
                {
                    
                    if(s.Name==asp.Allergan_Speciality_Name_AGN__c)
                    {
                        if(!uniqueSpecialityListTemp.contains(asp.Name_AGN__c))
                        {
                            uniqueSpeciality.put(asp.Name_AGN__c,s.Id);
                            uniqueSpecialityList.add(s.Id); 
                            uniqueSpecialityListTemp.add(asp.Name_AGN__c);
                        }
                    }
                }            
            }
            for(String speciality : uniqueSpeciality.keySet()){
                customerSpeciality.add(new SelectOption(uniqueSpeciality.get(speciality), speciality ));
            }
            for (Integer i =0; i < customerSpeciality.size(); i++) {
                
                for (Integer j = i; j > 0; j--) {
                    
                    if (customerSpeciality[j-1].getLabel() > customerSpeciality[j].getLabel()){
                        SelectOption temp = customerSpeciality[j];
                        customerSpeciality[j] = customerSpeciality[j-1];
                        customerSpeciality[j-1] = temp;
                    }
                }
            }
        }
        /*AMI MENA changes- Start */
        //country =  tempCountry;
        /*AMI MENA changes- End */
        return null;
    }
    
    /* This method is written for the brazil address validation, 
	use to fetch the response from the Utility class*/
    public void fetchAddress(){
        AGN_AMI_Utility_class.AddressDetail cepDetail= AGN_AMI_Utility_class.getAddressDetail(custAdd.Zip_AGN__c);
        system.debug('Zip@@@'+custAdd.Zip_AGN__c);
        system.debug('============>'+cepDetail);
        custAdd.Street_Name_AGN__c     = cepDetail.street;
        custAdd.Address_Line_3_AGN__c   = cepDetail.bairro;         
        custAdd.City_AGN__c       = cepDetail.city;
        system.debug('countryCode@@@'+countryCode);
        custAdd.State_AMI_AGN__c     = countryCode+'_'+cepDetail.state;
        system.debug('state@@@'+custAdd.State_AMI_AGN__c);
    }
    
    /* 
    * @Author Hijith NS
    * @description : Added as part of validation Fix 
    * 				 Method fetch validation info from CustomMetada -AGN_AMI_Layout_Setting__mdt
    * @param : country Code
    * @date : 07/09/2020
    */
    
    @RemoteAction
    public static List<AGN_AMI_Layout_Setting__mdt> getMetadataVal(String countryCde){
        List<AGN_AMI_Layout_Setting__mdt> mData = new  List<AGN_AMI_Layout_Setting__mdt>();
        try{
            mData = [SELECT FieldName__c,Regex__c,Max_Length__c,
                     Allowable_Characters__c,Country__c,HelpText__c,MaxLenHelpTxt__c,Exclusion__c,Validate__c,
                     show_invalid_character_error__c,Show_max_length_error__c
                     FROM AGN_AMI_Layout_Setting__mdt 
                     WHERE Country__c=:countryCde LIMIT 30];
        }
        catch(exception ex){
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_CustRegistrationController_AU','getMetadataVal');
        }
        return mData;
    }
    
    // Check for Duplicate Registration before allowing user to go to registration page
    public boolean checkDuplicateRegistration()
    {
        Boolean isExists = true ;
        try{
            List<Allergan_Customer_Registration_AGN__c> acr = [SELECT Id, Case_AGN__r.CaseNumber
                                                               FROM Allergan_Customer_Registration_AGN__c 
                                                               WHERE First_Name_AGN__c = :custReg.First_Name_AGN__c 
                                                               AND Last_Name_AGN__c = :custReg.Last_Name_AGN__c 
                                                               AND Email_AGN__c = :custReg.Email_AGN__c 
                                                               AND Country_AGN__c = :custReg.Country_AGN__c 
                                                               AND RecordType.DeveloperName = 'New_AMI_AGN'
                                                               AND Rejected_AMI_AGN__c = FALSE
                                                               AND Process_AGN__c= FALSE //duplicate registration validation issue
                                                               LIMIT 1];
            if(acr.isEmpty()){
                isExists = false;
            }          
        }
        catch(exception ex){
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_CustRegistrationController_AU','getMetadataVal');
        }       
        return isExists;
    }
    /***********************************************************************************************************************
    @ Method:         checkDesignation
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        Created for PMO2601 - to control hide and show of speciality field for CA
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.07.2020 / Ayush Basak / Created the method.
    ***********************************************************************************************************************/   
    public void checkDesignation(){
        if(custReg.AMI_Account_Designation_AGN__c == designationCA)
            showSpecCA = true;
        else
            showSpecCA = false;
    }
    
    
    /*** SWAR START ****/
    public PageReference submit(){
        if (response == null ){
            //Google recaptcha empty response
            return null;
        }
        HttpResponse res = getGoogleReCAPTCHAResponse(baseUrl,'secret=' + secretKey + '&remoteip=' + remoteHost + '&response=' + response);
        if (res != null ) {
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'success')) {
                    parser.nextToken();
                    this.verified = parser.getBooleanValue();
                    break;
                }
            }            
        }   
        if(this.verified){
            //Add your logic
            return null;
        }
        else{
            //Stay on page to re-try reCAPTCHA
            return null;
        }
    }
     
    //Get Google reCAPTCHA Service Response 
    private static HttpResponse getGoogleReCAPTCHAResponse(string requestURL, string body){
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(requestURL);
        req.setMethod('POST');
        req.setBody (body);
        try{
            Http http = new Http();
            response = http.send(req);
            System.debug('ReCAPTCHA Response-' + response);
            System.debug('ReCAPTCHA Body-' + response.getBody());
        }
        catch(System.Exception ex){
            System.debug('ERROR Message-' + ex.getMessage());
        }
        return response;
    }
    
    /*** SWAR END ****/
    
    
    
}