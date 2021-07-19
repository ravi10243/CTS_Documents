/*
Type Name: AGN_CustomerRegistrationController
Reason: Controller class for Cusomer Registration Page.
21-03-2017 - SG - Initial Version
*/
public without sharing class AGN_CustomerRegistrationController{
    public static string userCountryCode{get{return AGN_CustomerRegistrationUtils.uInfo.Country_Code__c;}}         
    public Allergan_Customer_Registration_AGN__c customer{get;set;}
    public Allergan_Customer_Address_AGN__c customerAddress{get;set;}
    //public string allerganSpecialty{get;set;}
    public List<SelectOption> customerTypeList {get;set;}
    public List<SelectOption> customerSubTypeList {get; set;}
    public List<SelectOption> customerSpecialtyList {get; set;}
    public List<SelectOption> customerSubSpecialtyList {get; set;}
    public List<SelectOption> regionList {get; set;}    
    private list<Customer_Type_Configuration_AGN__c> customerTypeConfigList {get;set;} 
    private Map<String,Country_VOD__c> countryMap;
    public boolean successMsg {get;set;}
    
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
    
    
    public AGN_CustomerRegistrationController() {
        customer= new Allergan_Customer_Registration_AGN__c (Country_Code_AGN__c = userCountryCode);
        customerAddress = new Allergan_Customer_Address_AGN__c();
        successMsg = false;
        customerTypeConfigList = [SELECT Name,
                                  Account_Record_Type_AGN__c,
                                  Category_AGN__c,
                                  Country_Code_AGN__c,
                                  Customer_Country_AGN__c,
                                  Customer_Group_AGN__c ,
                                  Sub_Category__c,
                                  Specialty_Allergan_AGN__c, 
                                  Sub_Specialty_Allergan_AGN__c                        
                                  FROM Customer_Type_Configuration_AGN__c
                                  WHERE Country_Code_AGN__c=:userCountryCode
                                  AND Applicable_For_Online_Registration_AGN__c= True]; // Added Online flag check to differenciate records for Brazil visualflow
    }
    
    public list<SelectOption> getCountryList(){
        
        List<SelectOption> options = new List<SelectOption>(); 
        set<String> uniqueCountry = new set<String>();
        if(!customerTypeConfigList.isEmpty()){
            for(Customer_Type_Configuration_AGN__c custConfig :customerTypeConfigList )
            {  
                uniqueCountry.add(custConfig.Customer_Country_AGN__c);            
            }
        }
        countryMap= new Map<String,Country_VOD__c>([SELECT Id,
                                                    Country_Name_vod__c,
                                                    Alpha_2_Code_vod__c,
                                                    AGN_Country_Name__c
                                                    FROM Country_vod__c
                                                    WHERE Id IN:uniqueCountry]);
        
        for( Country_VOD__c cCountry : countryMap.values()){
            options.add(new SelectOption(cCountry.Id , cCountry.AGN_Country_Name__c)); 
        }
        return options;
    }
    
    public void selectCustomerType(){
        
        set<String> uniqueCategory = new set<String>();
        customerTypeList = new List<SelectOption>();
        for( Customer_Type_Configuration_AGN__c ctc : customerTypeConfigList){
            
            if(ctc.Customer_Country_AGN__c==customer.Country_AGN__c)
                uniqueCategory.add(ctc.Category_AGN__c);
        }
        
        for( string cType : uniqueCategory){
            customerTypeList.add(new SelectOption(cType , cType));
        }
        customerTypeList.sort();  
        getRegionList();
        setCustomerCountry();
    }
    
    public void selectCustomerSubType(){
        set<String> uniqueSubCategory = new set<String>();
        customerSubTypeList = new List<SelectOption>();
        for( Customer_Type_Configuration_AGN__c ctc : customerTypeConfigList){
            if (ctc.Category_AGN__c == customer.Customer_Category_AGN__c){
                uniqueSubCategory.add(ctc.Sub_Category__c);              
            }
        }
        for( string cSubType : uniqueSubCategory){
            customerSubTypeList.add(new SelectOption(cSubType , cSubType));
        }
        customerSubTypeList.sort();
    }
    
    public void selectCustomerSpecialty(){
        set<String> uniqueSpecialty = new set<String>();    
        customerSpecialtyList = new List<SelectOption>();
        
        List<Customer_Type_Configuration_AGN__c> specialtyListBasedOnCategory=[Select  Specialty_Allergan_AGN__c
                                                                               FROM Customer_Type_Configuration_AGN__c 
                                                                               WHERE Category_AGN__c=:customer.Customer_Category_AGN__c AND 
                                                                               Country_Code_AGN__c=:customer.SAP_Country_Code_AGN__c ];
        for(Customer_Type_Configuration_AGN__c c: specialtyListBasedOnCategory)
        {
            uniqueSpecialty.add(c.Specialty_Allergan_AGN__c);
        }
        List<Specialty_Allergan_AGN__c> lstAllerganSpecialty=new List<Specialty_Allergan_AGN__c>();
        lstAllerganSpecialty=[select Id,Name from Specialty_Allergan_AGN__c 
                              where Id IN :uniqueSpecialty];
        
        for( Specialty_Allergan_AGN__c cSpecialty : lstAllerganSpecialty){
            customerSpecialtyList.add(new SelectOption(cSpecialty.Id , cSpecialty.Name));
        }       
        customerSpecialtyList.sort();
    }
    
    
    public void selectCustomerSubSpecialty(){
        AGN_CustomerRegistrationUtils.setCustomerSpecialty(customer,customerTypeConfigList);
        set<String> uniqueSubSpecialty = new set<String>();    
        customerSubSpecialtyList = new List<SelectOption>();  
        
        /*List<Customer_Type_Configuration_AGN__c> subSpecialtyListBasedOnSpecialty=[Select  Sub_Specialty_Allergan_AGN__c
FROM Customer_Type_Configuration_AGN__c 
WHERE Category_AGN__c=:customer.Customer_Category_AGN__c AND 
Country_Code_AGN__c=:customer.SAP_Country_Code_AGN__c AND
Specialty_Allergan_AGN__c=:customer.Specialty_Allergan_1_AGN__c  ];*/
        for(Customer_Type_Configuration_AGN__c c: customerTypeConfigList)
        {
            if(c.Category_AGN__c==customer.Customer_Category_AGN__c 
               && c.Country_Code_AGN__c==customer.SAP_Country_Code_AGN__c 
               && c.Specialty_Allergan_AGN__c==customer.Specialty_Allergan_1_AGN__c)
                uniqueSubSpecialty.add(c.Sub_Specialty_Allergan_AGN__c);
        }
        List<Sub_Specialty_Allergan__c> lstAllerganSubSpecialty=new List<Sub_Specialty_Allergan__c>();
        lstAllerganSubSpecialty=[select Id,Name from Sub_Specialty_Allergan__c 
                                 where Id IN :uniqueSubSpecialty];
        
        for( Sub_Specialty_Allergan__c cSubSpecialty : lstAllerganSubSpecialty){
            customerSubSpecialtyList.add(new SelectOption(cSubSpecialty.Id , cSubSpecialty.Name));
        }
        if(!customerSubSpecialtyList.isEmpty())
            customerSubSpecialtyList.add(new SelectOption( '', '--'));
        customerSubSpecialtyList.sort(); 
        system.debug('customerSubSpecialtyList--- '+customerSubSpecialtyList.size());
        
    }
    
    
    public List<SelectOption> getSalutaionList(){
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '', '--'));
        Schema.DescribeFieldResult fieldResult = Allergan_Customer_Registration_AGN__c.Salutation_AGN__c.getDescribe();     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption( f.getValue(), f.getLabel()));
        }   
        return options;
    }
    
    public list<SelectOption> getGender(){
        List<SelectOption> options = new List<SelectOption>();    
        Schema.DescribeFieldResult fieldResult = Allergan_Customer_Registration_AGN__c.Gender_AGN__c.getDescribe();     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();   
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption( f.getValue(), f.getLabel()));
        } 
        if (options.size()>0)
            options.add(new SelectOption( '', '--'));
        options.sort();
        return options;
    }
    
    // Release 14.1 
    public list<SelectOption> getBusinessUnit(){
        List<SelectOption> options = new List<SelectOption>();    
        options.add(new SelectOption( '', '--'));
        Schema.DescribeFieldResult fieldResult = Allergan_Customer_Registration_AGN__c.Business_Unit_AGN__c.getDescribe();     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if(customer.Customer_Category_AGN__c == System.Label.AGN_Sub_Catagory_Dentista) {            
            for( Schema.PicklistEntry f : ple) {                
              //Fix for PMO 3091 and INC #INC0465845 Santanu start
              /*if(f.getLabel() == System.Label.AGN_SpecialityCare){ 
                  system.debug('--BusinessUnit Speciality care---' + f.getLabel());
                    options.add(new SelectOption( f.getValue(), f.getLabel()));
               }*/
               //Added this logic
               if(f.getLabel() == System.Label.AGN_OAM_Medical_Aesthetics){                   
                   options.add(new SelectOption( f.getValue(), f.getLabel()));
               }//Fix for PMO 3091 End
            }
        }
        
        else
        {
            for( Schema.PicklistEntry f : ple){
                options.add(new SelectOption( f.getValue(), f.getLabel()));
            } 
        }
        
        System.debug('Testing'+customer.Customer_Category_AGN__c);
        return options;
    }
    
    public list<SelectOption> getPreferredComm(){
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '', '--'));
        Schema.DescribeFieldResult fieldResult = Allergan_Customer_Registration_AGN__c.Preferred_Communication_AGN__c.getDescribe();     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption( f.getValue(),f.getLabel()));
        }       
        return options;
    }      
    
    // this method is called when the button is clicked
    
    public PageReference doVerify () {      
        try{
            
            if (AGN_CustomerRegistrationUtils.checkForDuplicateCustomer(customer.Email_AGN__c)){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.AGN_OAM_Apex_DuplicateEmail);
                ApexPages.addMessage(errorMsg);
                return null;
            }
            
            
            string responseBody = AGN_CustomerRegistrationUtils.makeRequest(baseUrl,
                                                                            'secret=' + secret +
                                                                            '&response='+ response
                                                                           );
            
            string success = AGN_CustomerRegistrationUtils.getValueFromJson(responseBody, 'success');
            
            if(success.equalsIgnoreCase('true')){
                Id caseId = AGN_CustomerRegistrationUtils.createNewCustomerRegistration(customer,customerAddress, customerTypeConfigList);              
                if(caseId!= null) {
                    successMsg = true;
                }
                return null;
            }
            else{
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please verify the captcha');
                ApexPages.addMessage(errorMsg);
                return null;
            }
        }
        catch(Exception ex){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(errorMsg );
            return null;
        }
        
    }
    
    //private helper methods
    
    private void setCustomerCountry(){
        //Country_vod__c agnCountryDetails = AGN_CustomerRegistrationUtils.getCountryDetailsById(customer.Country_AGN__c);
        customerAddress.Country_AGN__c =countryMap.get(customer.Country_AGN__c).AGN_Country_Name__c ;
        customerAddress.Country_Lookup_AGN__c= customer.Country_AGN__c;
        customer.SAP_Country_Code_AGN__c= countryMap.get(customer.Country_AGN__c).Alpha_2_Code_vod__c ;
    }
    
    private void getRegionList(){
        
        regionList = new List<SelectOption>();        
        Schema.DescribeFieldResult fieldResult = Allergan_Customer_Address_AGN__c.State_AGN__c.getDescribe();     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            regionList.add(new SelectOption( f.getValue(), f.getLabel()));
        } 
        regionList.sort();
    }
    
    public void fetchAddress(){
        AGN_GCSP_Settings__c cepl = AGN_GCSP_Settings__c.getInstance(userCountryCode);
        if(cepl.ZipFetchAddress__c)
        {
            AGN_CustomerRegistrationUtils.AddressDetail cepDetail= AGN_CustomerRegistrationUtils.getAddressDetail(customerAddress.Zip_AGN__c);
            
            system.debug('============>'+cepDetail);
            customerAddress.Street_Name_AGN__c = cepDetail.street;
            customerAddress.Address_Line_3_AGN__c = cepDetail.bairro;         
            customerAddress.City_AGN__c = cepDetail.city;
            setCustomerCountry();
            customerAddress.State_AGN__c = customer.SAP_Country_Code_AGN__c+'-'+cepDetail.state;
        }
    }
}