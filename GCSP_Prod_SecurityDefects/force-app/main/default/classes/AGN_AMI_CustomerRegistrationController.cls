public without sharing class AGN_AMI_CustomerRegistrationController
{
    public Allergan_Customer_Registration_AGN__c custReg{ get; set; }
    public Allergan_Customer_Address_AGN__c custAdd{get;set;}    
    Public list<Country_vod__c>  countryList;   
    public List<SelectOption>  countryCollection {get;set;}
    public string lang_code;
    public AMI_Language_AGN__c defLang {get; set;}
    public string headercountry{get;set;}
    public List<SelectOption> languageList{get;set;}
    public Attachment attach{ get ; set;  } 
    String countryCode;
    list<string> uniqueSpecialityList;
    string country;
    string croid;
    public List<SelectOption> customerSpeciality {get; set;}
    List<SelectOption> customerSubType {get; set;}
    List<Specialty_AGN__c> lstSpecialty; 
    List<AMI_SPecality_AGN__c> lstAMISpeciality;
    //Added for Brazil&spain - Start
    List<Specialty_Allergan_AGN__c> lstSpecialtyAllergan;
    //Added for Brazil&spain - End    
    
  public AGN_AMI_CustomerRegistrationController() {
      customerSpeciality = new List<SelectOption>();  
        country=ApexPages.currentPage().getParameters().get('country');
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
            lstAMISpeciality = [select Id,Allergan_Speciality_Name_AGN__c,Name_AGN__c,Name,Country_code_AGN__c from AMI_SPecality_AGN__c where Country_code_AGN__c=:country order by Allergan_Speciality_Name_AGN__c ASC];
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
         country=ApexPages.currentPage().getParameters().get('country');
        lstSpecialty=new List<Specialty_AGN__c>();
        lstSpecialty=[select Id,Name,Country_code_AGN__c from Specialty_AGN__c where Country_code_AGN__c=:country order by Name ASC];
         //Added for Brazil&spai - Start
         lstSpecialtyAllergan=new List<Specialty_Allergan_AGN__c>();
         lstSpecialtyAllergan=[select Id,Name,Country_code_AGN__c from Specialty_Allergan_AGN__c where Country_code_AGN__c=:country order by Name ASC];
        //Added for Brazil&spain - End
        lstAMISpeciality = [select Id,Allergan_Speciality_Name_AGN__c,Name_AGN__c,Name,Country_code_AGN__c from AMI_SPecality_AGN__c where Country_code_AGN__c=:country order by Allergan_Speciality_Name_AGN__c ASC];
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
           if(ApexPages.currentPage().getParameters().get('website')!=null)
             custReg.Physician_Registration_Reference_AGN__c= ApexPages.currentPage().getParameters().get('website')=='null'?'': ApexPages.currentPage().getParameters().get('website');          
        countryList = [SELECT Id, Name,AGN_Country_Name__c, Cluster_Country_AGN__c From Country_vod__c];
        if(ApexPages.currentPage().getParameters().get('lang') != null)
            lang_code = ApexPages.currentPage().getParameters().get('lang');
        else
            lang_code = 'en_GB';
        }
        defLang=AMI_Language_AGN__c.getvalues(lang_code)!=null?AMI_Language_AGN__c.getvalues(lang_code):AMI_Language_AGN__c.getvalues('en_GB');
        headerCountry=defLang!=null?defLang.Language__c:AMI_Language_AGN__c.getvalues('en_GB').Language__c;
        languageList.add(new SelectOption(defLang.Lang_Code__c,defLang.Language__c));
        countryList = [SELECT Id, Name,AGN_Country_Name__c, Cluster_Country_AGN__c From Country_vod__c];  
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
                            MDCodesCategory_AMI_AGN__c, Is_From_Spark_AGN__c,Website_Link_AGN__c 
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
                optns.add(new selectOption(country.Id, country.AGN_Country_Name__c));
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
        system.debug('--'+country);
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
        string streetName = Apexpages.currentPage().getParameters().get('streetName');
        try{            
            system.debug('Create called');
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
            system.debug(cs+'cs>>>>>>>>>>>>>>>>>>' );
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
            custReg.Country_Code_AGN__c= countryCode;
            custReg.AMI_Registration_AGN__c=true; //added
            custReg.Portal_Access_AGN__c='AMI';
            System.debug('emailconsent--'+Apexpages.currentPage().getParameters().get('emailconsent'));
            if (Apexpages.currentPage().getParameters().get('emailconsent') != null && Apexpages.currentPage().getParameters().get('emailconsent') != '')
            {
                System.debug('emailconsent--'+Apexpages.currentPage().getParameters().get('emailconsent'));
                custReg.Email_Consent_AMI_AGN__c = Boolean.valueOf(Apexpages.currentPage().getParameters().get('emailconsent'));
            }
                
            if (Apexpages.currentPage().getParameters().get('phoneconsent') != null && Apexpages.currentPage().getParameters().get('phoneconsent') != '')
            {
                System.debug('emailconsent--'+Apexpages.currentPage().getParameters().get('emailconsent'));
                custReg.Phone_Consent_AMI_AGN__c = Boolean.valueOf(Apexpages.currentPage().getParameters().get('phoneconsent'));  
            }
                  
            custReg.Salutation_AGN__c = Apexpages.currentPage().getParameters().get('title');
            custAdd.Invited_By_AMI_AGN__c = Apexpages.currentPage().getParameters().get('invitedBy');
            //if(Apexpages.currentPage().getParameters().get('speciality') != '')
            if((country !='BR' && country !='ES' ) && Apexpages.currentPage().getParameters().get('speciality') != '')
                custReg.Specialty_1_AGN__c = Apexpages.currentPage().getParameters().get('speciality');
            //custReg.Sub_Specialty_Allergan_AGN__c = Apexpages.currentPage().getParameters().get('subspeciality');
             
            //Added for Brazil&spain - Start
             If((country =='BR' || country =='ES' ) && Apexpages.currentPage().getParameters().get('speciality') != '')
                custReg.Specialty_Allergan_1_AGN__c = Apexpages.currentPage().getParameters().get('speciality');
            //Added for Brazil&spain - End
            Integer myIntDate  = 0;
            Integer myIntMonth = 0;
            Integer myIntYear = 0;
            if(Apexpages.currentPage().getParameters().get('dob') != '' && Apexpages.currentPage().getParameters().get('dob') != null)
            {
                String dtString = Apexpages.currentPage().getParameters().get('dob');
                String[] strDate = dtString.split('/');
                myIntDate  = integer.valueOf(strDate[0]);
                myIntMonth = integer.valueOf(strDate[1]);
                myIntYear = integer.valueOf(strDate[2]);
            }

        DateTime dtm = DateTime.newInstance(myIntYear,myIntMonth,myIntDate);
        Date dt = date.newinstance(dtm.year(), dtm.month(), dtm.day());
                    
          // String dateStr = dt.format('dd.MM.yyyy','Europe/Berlin'); 
           
           
          //system.debug('BirthDate_AGN__c-- '+  Date.parse(String.valueOf((Apexpages.currentPage().getParameters().get('dob')).replace('/','.'))));
            custReg.BirthDate_AGN__c = (Apexpages.currentPage().getParameters().get('dob') != null && Apexpages.currentPage().getParameters().get('dob') != '')?dt: null;
            custReg.Mobile_AGN__c = Apexpages.currentPage().getParameters().get('mobile');
            custReg.Website_Link_AGN__c = Apexpages.currentPage().getParameters().get('website');//for italy
            system.debug('BirthDate_AGN__c--1 ');
            //currently added for Canada - start
            if (Apexpages.currentPage().getParameters().get('phoneExt') != null && Apexpages.currentPage().getParameters().get('phoneExt') != '')
                custReg.Phone_AGN__c = Apexpages.currentPage().getParameters().get('phone') + ' [' + Apexpages.currentPage().getParameters().get('phoneExt') + '] ';            
            else
                custReg.Phone_AGN__c = Apexpages.currentPage().getParameters().get('phone');
            system.debug('BirthDate_AGN__c--2 ');
            if (Apexpages.currentPage().getParameters().get('midname') != null && Apexpages.currentPage().getParameters().get('midname') != '')
              custReg.Middle_Name_AGN__c = Apexpages.currentPage().getParameters().get('midname');
            
            if (Apexpages.currentPage().getParameters().get('agnAccount') != null && Apexpages.currentPage().getParameters().get('agnAccount') != '')
                custReg.AMI_AllerganAccount_AGN__c = Apexpages.currentPage().getParameters().get('agnAccount');
            
            if (Apexpages.currentPage().getParameters().get('gradYear') != null && Apexpages.currentPage().getParameters().get('gradYear') != '')
                custReg.Graduation_Year_AGN__c = Apexpages.currentPage().getParameters().get('gradYear');
            
            if (Apexpages.currentPage().getParameters().get('designation') != null && Apexpages.currentPage().getParameters().get('designation') != '')
                custReg.AMI_Account_Designation_AGN__c = Apexpages.currentPage().getParameters().get('designation');
            system.debug('BirthDate_AGN__c--23');
            if (Apexpages.currentPage().getParameters().get('msgConsent') != null && Apexpages.currentPage().getParameters().get('msgConsent') != '')
                custReg.AMI_Message_Consent_AGN__c = Boolean.valueOf(Apexpages.currentPage().getParameters().get('msgConsent'));
            
            custReg.Salutation_AGN__c = Apexpages.currentPage().getParameters().get('title');
              //Added for Brazil - Start
            if (Apexpages.currentPage().getParameters().get('distribution_id') != null && Apexpages.currentPage().getParameters().get('distribution_id') != '')
                custReg.Distribution_ID_AGN__c = Apexpages.currentPage().getParameters().get('distribution_id');
            //Added for Brazil - End
            
            
            /*
            if(country == 'CA')
                custReg.AMI_Account_Salutation__c= Apexpages.currentPage().getParameters().get('title');
            else 
              custReg.Salutation_AGN__c = Apexpages.currentPage().getParameters().get('title');          
           */
            //currently added for Canada - end
            
            custReg.Physician_Registration_Reference_AGN__c = Apexpages.currentPage().getParameters().get('prr');
            custReg.MDCodesCategory_AMI_AGN__c = Apexpages.currentPage().getParameters().get('mdcodes');
            System.debug(custReg);
            system.debug('BirthDate_AGN__c--4');
           // custReg.Language_AGN__c=[select Language__c from AMI_Language_AGN__c where id=:regLanguage limit 1].Language__c;
            upsert custReg;  
              system.debug('BirthDate_AGN__c--5');          
            //create sold to address
            //custAdd.Company_Name_AGN__c= custReg.First_Name_AGN__c+ ' ' + custReg.Last_Name_AGN__c;
            custAdd.Company_Name_AGN__c = Apexpages.currentPage().getParameters().get('hospital'); 
        
            If(custAdd.Id == null){
                custAdd.Parent_AGN__c = custReg.Id;
            }
            custAdd.Street_Name_AGN__c=streetName;
            custAdd.City_AGN__c = Apexpages.currentPage().getParameters().get('city');
            custAdd.State_AMI_AGN__c = Apexpages.currentPage().getParameters().get('state');
            custAdd.House_Number_AGN__c = Apexpages.currentPage().getParameters().get('houseNum');
            custAdd.Zip_AGN__c = Apexpages.currentPage().getParameters().get('postcode');
            system.debug('BirthDate_AGN__c--6');
            
            //custAdd.Sold_To_AGN__c = true; 
            custAdd.Email_AGN__c = custReg.Email_AGN__c;
            custAdd.Phone_AGN__c = custReg.Phone_AGN__c;  
            
            //currently added for Canada - start
            if (Apexpages.currentPage().getParameters().get('suite') != null && Apexpages.currentPage().getParameters().get('suite') != '')
                custAdd.Suite_AGN__c = Apexpages.currentPage().getParameters().get('suite');
             if (Apexpages.currentPage().getParameters().get('license') != null && Apexpages.currentPage().getParameters().get('license') != '')
                custAdd.State_License_Number_AGN__c = Apexpages.currentPage().getParameters().get('license');           
            //currently added for Canada - end
            
              //Added for Brazil - start
             if (Apexpages.currentPage().getParameters().get('address3') != null && Apexpages.currentPage().getParameters().get('address3') != '')
                custAdd.Address_Line_3_AGN__c = Apexpages.currentPage().getParameters().get('address3');
            //added for Brazil - end
            //custAdd.Account_Type_AGN__c = 'Practice_vod';
            custAdd.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New_AMI_AGN'].Id;  
            system.debug('custAdd--'+custAdd);
            upsert custAdd;      
            system.debug('custAddid--'+custAdd.id);           
            if(!string.isBlank(custReg.id)){
                AGN_AMI_Case_Next.gotoNextStep(cs.id);
            }
        }
        catch(exception e){
            system.debug('Exception : '+e.getMessage());
        }
         
    }   
    
     public List<SelectOption> getSalutaionList(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '', '--'));
        Schema.DescribeFieldResult fieldResult; 
        //currently added for canada - start        
        if(country == 'CA')
               fieldResult = Allergan_Customer_Registration_AGN__c.AMI_Account_Salutation__c.getDescribe();  
        else                
               fieldResult = Allergan_Customer_Registration_AGN__c.Salutation_AGN__c.getDescribe();
        //currently added for canada - end         
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption( f.getValue(), f.getLabel()));
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
    
    
    public PageReference selectSpecialityList(){
        
        Map<Id,String> uniqueSpeciality = new Map<Id,String>();    
          customerSpeciality.add(new SelectOption('', '--'));
      
    
        List<String> uniqueSpecialityListTemp = new List<String>();
       //Added for Brazil&spain -- Start 
       if(country == 'BR' || country == 'ES' ){
           
           for(Specialty_Allergan_AGN__c s : lstSpecialtyAllergan)
        {
            for(AMI_SPecality_AGN__c asp : lstAMISpeciality)
            {
                if(s.Name==asp.Allergan_Speciality_Name_AGN__c)
                {
                    if(!uniqueSpecialityListTemp.contains(asp.Name_AGN__c))
                    {
                        uniqueSpeciality.put(s.Id,asp.Name_AGN__c);
                        uniqueSpecialityList.add(s.Id);
                        uniqueSpecialityListTemp.add(asp.Name_AGN__c);
                    }
                }
            }            
        }
        for(Id speciality : uniqueSpeciality.keySet()){
            customerSpeciality.add(new SelectOption(speciality , uniqueSpeciality.get(speciality)));
        }
        for (Integer i =0; i < customerSpeciality.size(); i++) {
            system.debug('i='+i);
            for (Integer j = i; j > 0; j--) {
                system.debug('j='+j);
                if (customerSpeciality[j-1].getLabel() > customerSpeciality[j].getLabel()){
                    SelectOption temp = customerSpeciality[j];
                    customerSpeciality[j] = customerSpeciality[j-1];
                    customerSpeciality[j-1] = temp;
                }
            }
        }
           
       }
       //Added for Brazil&spain -- End
       else{
       
        for(Specialty_AGN__c s : lstSpecialty)
        {
          system.debug('Specialty_AGN__c00001'+s);
            for(AMI_SPecality_AGN__c asp : lstAMISpeciality)
            { 
                system.debug('AMI_SPecality_AGN__c00001'+asp);
                if(s.Name==asp.Allergan_Speciality_Name_AGN__c)
                {
                    system.debug('s.Name'+s.Name);
                    if(!uniqueSpecialityListTemp.contains(asp.Name_AGN__c))
                    {
                        uniqueSpeciality.put(s.Id,asp.Name_AGN__c);
                        uniqueSpecialityList.add(s.Id);
                        uniqueSpecialityListTemp.add(asp.Name_AGN__c);
                    }
                }
            }            
        }
        for(Id speciality : uniqueSpeciality.keySet()){
            customerSpeciality.add(new SelectOption(speciality , uniqueSpeciality.get(speciality)));
        }
       
        for (Integer i =0; i < customerSpeciality.size(); i++) {
            system.debug('0001'+customerSpeciality[i]);
            system.debug('i='+i);
            for (Integer j = i; j > 0; j--) {
                system.debug('j='+j);
                if (customerSpeciality[j-1].getLabel() > customerSpeciality[j].getLabel()){
                    SelectOption temp = customerSpeciality[j];
                    customerSpeciality[j] = customerSpeciality[j-1];
                    customerSpeciality[j-1] = temp;
                }
            }
        }
      }
        system.debug('customerSpeciality---'+customerSpeciality);
        return null;
    }  
    
}