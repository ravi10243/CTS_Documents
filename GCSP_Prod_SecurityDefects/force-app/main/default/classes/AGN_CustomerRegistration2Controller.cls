public without sharing class AGN_CustomerRegistration2Controller {
    
    public User uInfo {get;set;}
    public Allergan_Customer_Registration_AGN__c customer{get;set;}
    public Allergan_Customer_Address_AGN__c customerAddress{get;set;}
    public Allergan_Customer_Address_AGN__c practiceAddress {get;set;}
    public Allergan_Customer_Address_AGN__c deliveryAddress {get;set;}
    public Allergan_Customer_Address_AGN__c billingAddress {get;set;}
    public Boolean showStep1{get;set;}
    public Boolean showStep2{get;set;}
    public Boolean showStep3{get;set;}
    public Boolean showStep4{get;set;}
    public String practiceAddressIsSameAs{get;set;}
    public boolean finishMsg {get;set;}
    
    public String billingAddressRegion {get{  if(billingAddress.Address_Line_2_AGN__c!= null){
        system.debug('@@@@'+AGN_CustomerRegistrationUtils.getRegionNamebyCode(billingAddress.Address_Line_2_AGN__c, customer.SAP_Country_Code_AGN__c));
        return AGN_CustomerRegistrationUtils.getRegionNamebyCode(billingAddress.Address_Line_2_AGN__c, customer.SAP_Country_Code_AGN__c);
        
    }else return ' ';
                                           }set;}
    public String deliveryAddressRegion {get{  if(deliveryAddress.Address_Line_2_AGN__c!= null){
        system.debug('@@@@'+AGN_CustomerRegistrationUtils.getRegionNamebyCode(deliveryAddress.Address_Line_2_AGN__c, customer.SAP_Country_Code_AGN__c));
        return AGN_CustomerRegistrationUtils.getRegionNamebyCode(deliveryAddress.Address_Line_2_AGN__c, customer.SAP_Country_Code_AGN__c);
    }else return ' ';
                                            }set;}
    
    public String deliveryAddressIsSameAs{get;set;}
    public List<SelectOption> deliveryAddressIsSameAsOptions{get{
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('2RegisteredAddress', System.Label.AGN_OAM_Body_RegisteredAddress));
        //options.add(new SelectOption('3PracticeAddress','Practice Address'));
        options.sort();
        return options;}}
    public String billingAddressIsSameAs{get;set;}
    public List<SelectOption> billingAddressIsSameAsOptions{get{
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('2RegisteredAddress',System.Label.AGN_OAM_Body_RegisteredAddress));
        //options.add(new SelectOption('3PracticeAddress','Practice Address'));
        options.add(new SelectOption('4DeliveryAddress',System.Label.AGN_OAM_Body_DeliveryAddress));
        options.sort();
        return options;}}
    public Customer_Type_Configuration_AGN__c customerTypeConfig{get{
        Customer_Type_Configuration_AGN__c ctclist= new Customer_Type_Configuration_AGN__c();
        ctclist= [SELECT Documents_Required_AGN__c                         
                  FROM Customer_Type_Configuration_AGN__c
                  WHERE Customer_Group_AGN__c=:customer.Customer_Group_AGN__c  AND
                  Category_AGN__c=:customer.Customer_Category_AGN__c AND
                  Sub_Category__c=:customer.Customer_Sub_Category_AGN__c  AND
                  Applicable_For_Online_Registration_AGN__c= true LIMIT 1]; // Added Online flag check to differenciate records for Brazil visualflow
        return ctclist;
    }
                                                                }
    
    public List<SelectOption> getRegionList()
    {   
        List<SelectOption> regionList = new List<SelectOption>();
        regionList.add(new SelectOption('', ''));
        Schema.DescribeFieldResult fieldResult = Allergan_Customer_Address_AGN__c.State_AGN__c.getDescribe();     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            if(f.getValue().left(2).toUpperCase()==customer.SAP_Country_Code_AGN__c.toUpperCase())
                regionList.add(new SelectOption(f.getValue(), f.getLabel()));
        } 
        return regionList;
    }
    
    private list<Form_Of_Payment_AGN__c> formOfPaymentList{get{
        list<Form_Of_Payment_AGN__c> foplist= new list<Form_Of_Payment_AGN__c>();
        foplist= [SELECT Id,
                  Name
                  FROM Form_Of_Payment_AGN__c
                  //WHERE Country_Code_AGN__c=:customer.Country_Code_AGN__c AND
                  WHERE SAP_Country_Code_AGN__c=:customer.SAP_Country_Code_AGN__c AND
                  Active_AGN__c= true];
        if(!foplist.isEmpty())
            return foplist;
        else{
            foplist= [SELECT Id,
                      Name
                      FROM Form_Of_Payment_AGN__c
                      WHERE Country_Code_AGN__c='Core'AND
                      Name= 'default' Limit 1];
            return foplist;
        }
    }
                                                          }
    
    public List<SelectOption> getFormOfPaymentOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        for( Form_Of_Payment_AGN__c f : formOfPaymentList)
        {
            options.add(new SelectOption(f.Id , f.Name));
        }       
        return options;
    }
    private Case crCase;
    public String typeValue =null;
    List<String> splitTextMap = new List<String>();
    public Allergan_Customer_Address_AGN__c customerAddressOnLoad;
    public Allergan_Customer_Address_AGN__c deliveryAddressOnLoad;
    public Allergan_Customer_Address_AGN__c billingAddressOnLoad;
    
    public AGN_CustomerRegistration2Controller (){
        uInfo = [SELECT Id,Name, SmallPhotoUrl, ContactId, AccountId from User where Id =: UserInfo.getUserId() limit 1];       
        Allergan_Customer_Contact_AGN__c customerContact = [SELECT Id,Parent_AGN__c,Contact_AGN__c,Contact_Person_Type_AGN__c FROM Allergan_Customer_Contact_AGN__c WHERE Contact_AGN__c =: uInfo.ContactId];
        String RegId = String.escapeSingleQuotes(customerContact.Parent_AGN__c);     
        String SobjectApiName = 'Allergan_Customer_Registration_AGN__c';
        String query;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        query = 'select Country_AGN__r.AGN_Country_Name__c, Specialty_Allergan_1_AGN__r.Name, ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE ID ='+'\''+ RegId+ '\'';
        
        customer = Database.query(query);  
        /* customer = [ SELECT Id, 
        Account_Type_AGN__c, 
        Account_Sub_Type_AGN__c,
        Case_AGN__c,
        Customer_Group_AGN__c,
        Country_Code_AGN__c,
        First_Name_AGN__c, 
        Form_of_Payment_AGN__c,                            
        Last_Name_AGN__c,
        Online_Registration_Step_AGN__c,
        Payment_Term_AGN__c, 
        Physician_Registration_Reference_AGN__c, 
        Customer_Category_AGN__c,
        Customer_Sub_Category_AGN__c,
        Specialty_Allergan_1_AGN__r.Name,
        Country_AGN__r.AGN_Country_Name__c,
        VAT_AGN__c,
        Tax_Exempted_AGN__c,
        SAP_Country_Code_AGN__c,
        Mapping_1_AGN__c,
        Mapping_2_AGN__c,
        State_Registration__c,
        Distribution_ID_AGN__c,
        Salutation_AGN__c
        FROM Allergan_Customer_Registration_AGN__c 
        WHERE Account_AGN__c =: uInfo.AccountId  LIMIT 1]; */
        crCase =[SELECT Id, Type, RecordType.Name, Case_Sub_Status_AGN__c, EntitlementId,OwnerId FROM Case WHERE Id=:customer.Case_AGN__c];
        //To extract typeValue i.e "New" here from fetched String "New - Customer_Category_AGN__c" // Refer AGN_CustomerRegistrationutils,line 18
        typeValue = crCase.Type ;
        splitTextMap = typeValue.split(' ');
        for(String temp: splitTextMap)
        {
            crCase.Type= temp;
            break;
        }
        System.debug('Splitted Text: '+crCase.Type);
        
        Id addressRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id;
        
        customerAddress = new Allergan_Customer_Address_AGN__c(Country_AGN__c = customer.Country_AGN__r.AGN_Country_Name__c, Country_Lookup_AGN__c = customer.Country_AGN__c);        
        deliveryAddress = new Allergan_Customer_Address_AGN__c(Country_AGN__c = customer.Country_AGN__r.AGN_Country_Name__c, Country_Lookup_AGN__c = customer.Country_AGN__c);
        billingAddress = new Allergan_Customer_Address_AGN__c(Country_AGN__c = customer.Country_AGN__r.AGN_Country_Name__c, Country_Lookup_AGN__c = customer.Country_AGN__c);
        
        customerAddressOnLoad = new Allergan_Customer_Address_AGN__c();
        deliveryAddressOnLoad = new Allergan_Customer_Address_AGN__c();
        billingAddressOnLoad = new Allergan_Customer_Address_AGN__c();
        
        showStep1=false;
        showStep2=false;
        showStep3=false;
        showStep4=false;
        if(customer.Online_Registration_Step_AGN__c=='1')
            showStep1=true;
        else if(customer.Online_Registration_Step_AGN__c=='2')
            showStep2=true;
        else if(customer.Online_Registration_Step_AGN__c=='3')
            showStep3=true;
        else if(customer.Online_Registration_Step_AGN__c=='4')
            showStep4=true;
        
        list<Allergan_Customer_Address_AGN__c> customerAllAddresses =  new list<Allergan_Customer_Address_AGN__c>();
        customerAllAddresses=[ SELECT Id, Country_Lookup_AGN__c,
                              Account_Type_AGN__c,
                              House_Number_AGN__c,
                              Street_Name_AGN__c,
                              Address_Line_1_AGN__c,
                              Address_Line_2_AGN__c,
                              Address_Line_3_AGN__c,
                              City_AGN__c,
                              Company_Name_AGN__c,
                              Department_Name_AGN__c,
                              Country_AGN__c,
                              Email_AGN__c,
                              Mapping_1_AGN__c,
                              Mapping_2_AGN__c,
                              IsDeleted,
                              Phone_AGN__c,
                              Phone_2_AGN__c,                                     
                              Parent_AGN__c,
                              Zip_AGN__c,
                              Ship_To_AGN__c,
                              Sold_To_AGN__c,
                              Bill_To_AGN__c,
                              State_AGN__c,
                              RecordTypeId,
                              Sort_Code_AGN__c,
                              SWIFT_BIC_AGN__c,
                              Bank_Name_AGN__c,                            
                              Bank_Account_Number_AGN__c,
                              IBAN_Text_AGN__c,                                   
                              Sub_Type_AGN__c                                  
                              FROM Allergan_Customer_Address_AGN__c
                              WHERE Parent_AGN__c=:customer.Id
                              ORDER BY createdDate ASC LIMIT 4];
        
        if (!customerAllAddresses.isEmpty()){
            for(Allergan_Customer_Address_AGN__c aca : customerAllAddresses){
                
                if (aca.Sold_To_AGN__c == true){
                    customerAddress = aca.clone(true, false, false, false);
                    customerAddress.Ship_To_AGN__c=false;
                    customerAddress.Bill_To_AGN__c=false;
                    customerAddressOnLoad=aca.clone(true, false, false, false);
                    system.debug('======customerAddress========>'+customerAddress);
                    system.debug('======customerAddressOnLoad========>'+customerAddressOnLoad);
                }
                if (aca.Ship_To_AGN__c == true){
                    //deliveryAddressIsSameAs = '2RegisteredAddress';
                    deliveryAddress = aca.clone(true, false, false, false);
                    deliveryAddress.Sold_To_AGN__c=false;
                    deliveryAddress.Bill_To_AGN__c=false;
                    deliveryAddressOnLoad=aca.clone(true, false, false, false); 
                    system.debug('======deliveryAddress========>'+deliveryAddress);
                    system.debug('======deliveryAddressOnLoad========>'+deliveryAddressOnLoad);
                }
                if (aca.Bill_To_AGN__c == true){
                    //  billingAddressIsSameAs = '2RegisteredAddress';
                    billingAddress = aca.clone(true, false, false, false);
                    billingAddress.Sold_To_AGN__c=false;
                    billingAddress.Ship_To_AGN__c=false;
                    billingAddressOnLoad=aca.clone(true, false, false, false);
                }                   
                
                
            } 
        }        
    }
    public void finishRegistration(){
        
        //--------- Release 14 Niladri ----------- Start -----------
        if(!string.isBlank(customerAddress.Sort_Code_AGN__c))
            customerAddress.Sort_Code_AGN__c = customerAddress.Sort_Code_AGN__c.remove('-');
        //--------- Release 14 Niladri ----------- End -------------
        
        list<SObject> recordsToUpdate = new list<SObject>();
        
        if (customer.Online_Registration_Step_AGN__c == '4'){
            customer.Online_Registration_Step_AGN__c = '5';
            //------CheckMarx--Added on 24/07/2020----------      
            List<Allergan_Customer_Registration_AGN__c> tempCrList = new List<Allergan_Customer_Registration_AGN__c>();
            tempCrList.add(customer);
            /*SObjectAccessDecision decisionOnCr = Security.stripInaccessible(AccessType.UPDATABLE,tempCrList);
            if(decisionOnCr.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
                throw new AGN_CommonException('Error: Insufficient Edit Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_CustomerRegistration2Controller and Method Name: finishRegistration] No Permission on'+ decisionOnCr.getRemovedFields());
            }
            else{
                update customer;
            }*/
            String objcrReg = 'Allergan_Customer_Registration_AGN__c';
            SObjectType ACRRegType = ((SObject)(Type.forName('Schema.'+objcrReg).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCrList,ACRRegType,'UPDATE');
            update customer;
            //--------------------
           
            
            customerAddress.Form_Of_Payment_AGN__c = customer.Form_Of_Payment_AGN__c ;// Added for EMEA MDM
            if (AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_Bill_To__c')!=Null?
                (boolean)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_Bill_To__c'):false){
                    
                    if (!isSameAddress(customerAddress, billingAddress)){  
                        billingAddress.Form_Of_Payment_AGN__c= customerAddress.Form_Of_Payment_AGN__c; // Added for EMEA MDM                
                        billingAddress.Bank_Name_AGN__c = customerAddress.Bank_Name_AGN__c;
                        billingAddress.Bank_Account_Number_AGN__c = customerAddress.Bank_Account_Number_AGN__c;
                        billingAddress.Sort_Code_AGN__c = customerAddress.Sort_Code_AGN__c;
                        //billingAddress.IBAN_AGN__c = customerAddress.IBAN_AGN__c;                    
                        billingAddress.IBAN_Text_AGN__c = customerAddress.IBAN_Text_AGN__c;// removed encription
                        billingAddress.SWIFT_BIC_AGN__c = customerAddress.SWIFT_BIC_AGN__c;
                        billingAddress.Bill_To_AGN__c = true;
                        recordsToUpdate.add(billingAddress);
                    }
                    else{
                        customerAddress.Bill_To_AGN__c = true;
                    }
                }
            
            if (isSameAddress(customerAddress, deliveryAddress))
                customerAddress.Ship_To_AGN__c = true; 
            
            recordsToUpdate.add(customerAddress);
            //createOrUpdateAddress();
            
            
            crCase.Case_Sub_Status_AGN__c ='Online Registration Completed';
            if(customer.SAP_Country_Code_AGN__c=='BR')
                crCase.Case_Step_Number_AGN__c=2;      
            system.debug('======customerAddress========>'+crCase.RecordType.Name + '=='+crCase.Type+ '=='+ customer.Country_Code_AGN__c);
            crCase.EntitlementId = AGN_CustomerRegistrationUtils.setEntitlement(crCase.RecordType.Name, crCase.Type, customer.Country_Code_AGN__c);
            recordsToUpdate.add(crCase);
            update recordsToUpdate;
            
            //update crCase;
            //Trigger the assignment rule by calling the case next button functionality
            
            //AGN_Case_Next.gotoNextStep(crCase.id);
            
            //Fix: Records Submitted Behind the Scenes Approval Process Routing Activating on April 2, 2019 
            if(customer.SAP_Country_Code_AGN__c=='BR'){
                AGN_Case_Next.gotoNextStep(crCase.id, crCase.OwnerId); //OwnerId site guest user
            }
            else{
                AGN_Case_Next.gotoNextStep(crCase.id);
            }
        }
    }
    
    
    public void createOrUpdateAddress(){
        
        list<Allergan_Customer_Address_AGN__c> customerAddressesToUpdate =  new list<Allergan_Customer_Address_AGN__c>();
        list<Allergan_Customer_Address_AGN__c> customerAddressesToDelete =  new list<Allergan_Customer_Address_AGN__c>();
        
        //Following section will concatenate House Number and Street name to address line 1. This is country specific, some countries are using only Address Line 1 .
        if(customerAddress!= null){
            customerAddress.Address_Line_1_AGN__c= (string.isBlank(customerAddress.Street_Name_AGN__c) && string.isBlank(customerAddress.House_Number_AGN__c))?customerAddress.Address_Line_1_AGN__c:(customerAddress.Street_Name_AGN__c+'--'+customerAddress.House_Number_AGN__c);
                customerAddress.Company_Name_AGN__c=    String.isBlank(customerAddress.Company_Name_AGN__c)?(customer.Salutation_AGN__c+' '+customer.First_Name_AGN__c+' '+customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
        }
        if(deliveryAddress!= null)
        {
            deliveryAddress.Address_Line_1_AGN__c= (string.isBlank(deliveryAddress.Street_Name_AGN__c) && string.isBlank(deliveryAddress.House_Number_AGN__c))?deliveryAddress.Address_Line_1_AGN__c:(deliveryAddress.Street_Name_AGN__c+'--'+deliveryAddress.House_Number_AGN__c);
                deliveryAddress.Company_Name_AGN__c=   String.isBlank(deliveryAddress.Company_Name_AGN__c)?(customer.Salutation_AGN__c+' '+customer.First_Name_AGN__c+' '+customer.Last_Name_AGN__c) : deliveryAddress.Company_Name_AGN__c; 
        }
        //    -------- added in R16 -------->>
        if(deliveryAddress!= null && customerAddress!= null && customer.Customer_Category_AGN__c == 'Paciente (Pessoa Física)')
        {
            makeSameAddress(customerAddress , deliveryAddress);
            deliveryAddress.id = customerAddress.id;
            deliveryAddress.Ship_To_AGN__c=true;
        }
        //    <<-------- added in R16 --------
        if(billingAddress!= null)
        {
            billingAddress.Address_Line_1_AGN__c = (string.isBlank(billingAddress.Street_Name_AGN__c)  && string.isBlank(billingAddress.House_Number_AGN__c)) ?billingAddress.Address_Line_1_AGN__c:(billingAddress.Street_Name_AGN__c+'--'+billingAddress.House_Number_AGN__c);
                billingAddress.Company_Name_AGN__c= String.isBlank(billingAddress.Company_Name_AGN__c)?(customer.Salutation_AGN__c+' '+customer.First_Name_AGN__c+' '+customer.Last_Name_AGN__c) : billingAddress.Company_Name_AGN__c; 
        }
        //for Registered Address
        if(String.isBlank(customerAddress.Parent_AGN__c)){
            customerAddress.Parent_AGN__c = customer.Id;
            customerAddress.Sold_To_AGN__c=true;
            customerAddressesToUpdate.add(customerAddress);
        }        
        
        //for Delivery Address
        
        if(isSameAddress(deliveryAddress , customerAddress)){            
            customerAddress.Ship_To_AGN__c=true;
            deliveryAddress.Ship_To_AGN__c=false;
            billingAddress.Ship_To_AGN__c=false;
            
            customerAddressesToUpdate.add(customerAddress);
            if(deliveryAddress.Id!=customerAddress.Id)
                customerAddressesToUpdate.add(deliveryAddress);            
        }
        else{            
            if(!string.isBlank(deliveryAddress.Id) && (deliveryAddress.Id==customerAddress.Id)){
                deliveryAddress.Id= null;              
            }
            if(String.isBlank(deliveryAddress.Parent_AGN__c)){
                deliveryAddress.Parent_AGN__c = customer.Id;
            }
            deliveryAddress.Ship_To_AGN__c=true;
            customerAddress.Ship_To_AGN__c=false ;
            billingAddress.Ship_To_AGN__c=false;
            
            deliveryAddress.Account_Type_AGN__c = customerAddress.Account_Type_AGN__c;
            deliveryAddress.Sub_Type_AGN__c = customerAddress.Sub_Type_AGN__c;
            deliveryAddress.RecordTypeId = customerAddress.RecordTypeId;
            
            customerAddressesToUpdate.add(deliveryAddress);
        }
        
        //for Billing Address
        if (AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_Bill_To__c')!=Null?
            (boolean)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_Bill_To__c'):false){
                
                if(isSameAddress(billingAddress, customerAddress)){
                    customerAddress.Bill_To_AGN__c = true;
                    deliveryAddress.Bill_To_AGN__c = false;
                    billingAddress.Bill_To_AGN__c = false;
                    
                    
                    customerAddressesToUpdate.add(customerAddress);
                    if(billingAddress.Id!=customerAddress.Id)
                        customerAddressesToUpdate.add(billingAddress);             
                }
                else{
                    
                    if(!string.isBlank(billingAddress.Id) && ((billingAddress.Id==customerAddress.Id) ||(billingAddress.Id==deliveryAddressOnLoad.Id))){
                        billingAddress.Id= null;              
                    }
                    if(String.isBlank(billingAddress.Parent_AGN__c)){
                        billingAddress.Parent_AGN__c = customer.Id;
                    }
                    billingAddress.Bill_To_AGN__c = true;
                    customerAddress.Bill_To_AGN__c = false;
                    deliveryAddress.Bill_To_AGN__c = false;
                    
                    billingAddress.Account_Type_AGN__c = customerAddress.Account_Type_AGN__c;
                    billingAddress.Sub_Type_AGN__c = customerAddress.Sub_Type_AGN__c;
                    billingAddress.RecordTypeId = customerAddress.RecordTypeId;
                    
                    customerAddressesToUpdate.add(billingAddress);
                }
            }
        //Check whether Registered Address neeeds to be updated
        
        customerAddressesToUpdate.add(customerAddress);
        
        system.debug('======customerAddressesToUpdate=========>'+customerAddressesToUpdate);
        
        if(!customerAddressesToUpdate.isEmpty()){
            try{                
                system.debug('======customerAddressesToInsert========>'+removeDuplicateAddress(customerAddressesToUpdate));
                database.upsert(removeDuplicateAddress(customerAddressesToUpdate),false);
                if (customer.Online_Registration_Step_AGN__c == '2'){
                    customer.Online_Registration_Step_AGN__c = '3';
                    //------CheckMarx--Added on 24/07/2020----------      
                    List<Allergan_Customer_Registration_AGN__c> tempCrList = new List<Allergan_Customer_Registration_AGN__c>();
                    tempCrList.add(customer);
                    /*SObjectAccessDecision decisionOnCr = Security.stripInaccessible(AccessType.UPDATABLE,tempCrList);
                    if(decisionOnCr.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
                        throw new AGN_CommonException('Error: Insufficient Edit Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_CustomerRegistration2Controller and Method Name: createOrUpdateAddress]');
                    }
                    else{
                      update customer;
                    }*/
                    String objcrReg = 'Allergan_Customer_Registration_AGN__c';
                    SObjectType ACRRegType = ((SObject)(Type.forName('Schema.'+objcrReg).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(tempCrList,ACRRegType,'UPDATE');
                    update customer;
                    //--------------------
                   
                }
            }
            catch(Exception e){
                system.debug('Address Upsert Exception:'+e);        
            }
            
        }        
        
        //check whether any address neeeds to be deleted
        
        deleteBlankAddress(customer.Id);
        AGN_CustomerRegistration2Controller reset = new AGN_CustomerRegistration2Controller ();
        customerAddress=reset.customerAddress;
        deliveryAddress=reset.deliveryAddress;
        billingAddress=reset.billingAddress;
        
        
    }
    
    public boolean isSameAddress(Allergan_Customer_Address_AGN__c add1, Allergan_Customer_Address_AGN__c add2){
        system.debug('======add1=========>'+add1);
        system.debug('======add2=========>'+add2);
        
        add1.Company_Name_AGN__c = (add1.Company_Name_AGN__c == null ? '': add1.Company_Name_AGN__c);
        add1.Address_Line_1_AGN__c = (add1.Address_Line_1_AGN__c == null ? '': add1.Address_Line_1_AGN__c);
        add1.Address_Line_2_AGN__c = (add1.Address_Line_2_AGN__c == null ? '': add1.Address_Line_2_AGN__c);
        add1.Address_Line_3_AGN__c = (add1.Address_Line_3_AGN__c == null ? '': add1.Address_Line_3_AGN__c);
        add1.State_AGN__c = (add1.State_AGN__c == null ? '': add1.State_AGN__c);
        add1.City_AGN__c = (add1.City_AGN__c == null ? '': add1.City_AGN__c);
        add1.Country_AGN__c = (add1.Country_AGN__c == null ? '': add1.Country_AGN__c);
        add1.Zip_AGN__c = (add1.Zip_AGN__c == null ? '': add1.Zip_AGN__c);
        add1.Email_AGN__c = (add1.Email_AGN__c == null ? '': add1.Email_AGN__c);
        add1.Phone_AGN__c = (add1.Phone_AGN__c == null ? '': add1.Phone_AGN__c);
        add1.Phone_2_AGN__c = (add1.Phone_2_AGN__c == null ? '': add1.Phone_2_AGN__c);
        add1.Department_Name_AGN__c = (add1.Department_Name_AGN__c == null ? '': add1.Department_Name_AGN__c);
        add1.House_Number_AGN__c = (add1.House_Number_AGN__c == null ? '': add1.House_Number_AGN__c);
        
        
        add2.Company_Name_AGN__c = (add2.Company_Name_AGN__c == null ? '': add2.Company_Name_AGN__c);
        add2.Address_Line_1_AGN__c = (add2.Address_Line_1_AGN__c == null ? '': add2.Address_Line_1_AGN__c);
        add2.Address_Line_2_AGN__c = (add2.Address_Line_2_AGN__c == null ? '': add2.Address_Line_2_AGN__c);
        add2.Address_Line_3_AGN__c = (add2.Address_Line_3_AGN__c == null ? '': add2.Address_Line_3_AGN__c);
        add2.State_AGN__c = (add2.State_AGN__c == null ? '': add2.State_AGN__c);
        add2.City_AGN__c = (add2.City_AGN__c == null ? '': add2.City_AGN__c);
        add2.Country_AGN__c = (add2.Country_AGN__c == null ? '': add2.Country_AGN__c);
        add2.Zip_AGN__c = (add2.Zip_AGN__c == null ? '': add2.Zip_AGN__c);
        add2.Email_AGN__c = (add2.Email_AGN__c == null ? '': add2.Email_AGN__c);
        add2.Phone_AGN__c = (add2.Phone_AGN__c == null ? '': add2.Phone_AGN__c);
        add2.Phone_2_AGN__c = (add2.Phone_2_AGN__c == null ? '': add2.Phone_2_AGN__c);
        add2.Department_Name_AGN__c = (add2.Department_Name_AGN__c == null ? '': add2.Department_Name_AGN__c);
        add2.House_Number_AGN__c = (add2.House_Number_AGN__c == null ? '': add2.House_Number_AGN__c);
        
        
        if( add1.Company_Name_AGN__c.deleteWhitespace()== add2.Company_Name_AGN__c.deleteWhitespace() &&
           add1.Address_Line_1_AGN__c.deleteWhitespace()== add2.Address_Line_1_AGN__c.deleteWhitespace() &&
           add1.State_AGN__c.deleteWhitespace()== add2.State_AGN__c.deleteWhitespace() &&            
           add1.City_AGN__c.deleteWhitespace()== add2.City_AGN__c.deleteWhitespace() &&            
           add1.Country_AGN__c.deleteWhitespace()== add2.Country_AGN__c.deleteWhitespace() &&         
           add1.Zip_AGN__c.deleteWhitespace()== add2.Zip_AGN__c.deleteWhitespace() && 
           add1.Email_AGN__c.deleteWhitespace()== add2.Email_AGN__c.deleteWhitespace() &&
           add1.Phone_AGN__c.deleteWhitespace()== add2.Phone_AGN__c.deleteWhitespace() &&
           add1.Phone_2_AGN__c.deleteWhitespace()== add2.Phone_2_AGN__c.deleteWhitespace() &&
           add1.Address_Line_2_AGN__c.deleteWhitespace()== add2.Address_Line_2_AGN__c.deleteWhitespace() &&
           add1.Address_Line_3_AGN__c.deleteWhitespace()== add2.Address_Line_3_AGN__c.deleteWhitespace() &&
           add1.Department_Name_AGN__c.deleteWhitespace()== add2.Department_Name_AGN__c.deleteWhitespace() &&
           String.valueof(add1.House_Number_AGN__c).deleteWhitespace()== String.valueof(add2.House_Number_AGN__c).deleteWhitespace())
            return true;
        else  return false;                                       
    }
    
    //        -------- added in R16 -------->>
    public void makeSameAddress(Allergan_Customer_Address_AGN__c add1, Allergan_Customer_Address_AGN__c add2){
        system.debug('======add1 (from)=========>'+add1);
        system.debug('======add2 (to)=========>'+add2);
        
        add2.Company_Name_AGN__c = (add1.Company_Name_AGN__c == null ? '': add1.Company_Name_AGN__c);
        add2.Address_Line_1_AGN__c = (add1.Address_Line_1_AGN__c == null ? '': add1.Address_Line_1_AGN__c);
        add2.Address_Line_2_AGN__c = (add1.Address_Line_2_AGN__c == null ? '': add1.Address_Line_2_AGN__c);
        add2.Address_Line_3_AGN__c = (add1.Address_Line_3_AGN__c == null ? '': add1.Address_Line_3_AGN__c);
        add2.State_AGN__c = (add1.State_AGN__c == null ? '': add1.State_AGN__c);
        add2.City_AGN__c = (add1.City_AGN__c == null ? '': add1.City_AGN__c);
        add2.Country_AGN__c = (add1.Country_AGN__c == null ? '': add1.Country_AGN__c);
        add2.Zip_AGN__c = (add1.Zip_AGN__c == null ? '': add1.Zip_AGN__c);
        add2.Email_AGN__c = (add1.Email_AGN__c == null ? '': add1.Email_AGN__c);
        add2.Phone_AGN__c = (add1.Phone_AGN__c == null ? '': add1.Phone_AGN__c);
        add2.Phone_2_AGN__c = (add1.Phone_2_AGN__c == null ? '': add1.Phone_2_AGN__c);
        add2.Department_Name_AGN__c = (add1.Department_Name_AGN__c == null ? '': add1.Department_Name_AGN__c);
        add2.House_Number_AGN__c = (add1.House_Number_AGN__c == null ? '': add1.House_Number_AGN__c);
        add2.Street_Name_AGN__c = (add1.Street_Name_AGN__c == null ? '': add1.Street_Name_AGN__c);
        add2.Mapping_2_AGN__c = (add1.Mapping_2_AGN__c == null ? '': add1.Mapping_2_AGN__c);
        
        add2.Country_Lookup_AGN__c = (add1.Country_Lookup_AGN__c == null ? '': add1.Country_Lookup_AGN__c);
        add2.Account_Type_AGN__c = (add1.Account_Type_AGN__c == null ? '': add1.Account_Type_AGN__c);
        add2.Mapping_1_AGN__c = (add1.Mapping_1_AGN__c == null ? '': add1.Mapping_1_AGN__c);
        add2.Parent_AGN__c = (add1.Parent_AGN__c == null ? '': add1.Parent_AGN__c);
        // add2.Ship_To_AGN__c = add1.Ship_To_AGN__c;
        // add2.Sold_To_AGN__c = add1.Sold_To_AGN__c;
        // add2.Bill_To_AGN__c = add1.Bill_To_AGN__c;
        add2.RecordTypeId = (add1.RecordTypeId == null ? '': add1.RecordTypeId);
        add2.Sort_Code_AGN__c = (add1.Sort_Code_AGN__c == null ? '': add1.Sort_Code_AGN__c);
        add2.SWIFT_BIC_AGN__c = (add1.SWIFT_BIC_AGN__c == null ? '': add1.SWIFT_BIC_AGN__c);
        add2.Bank_Name_AGN__c = (add1.Bank_Name_AGN__c == null ? '': add1.Bank_Name_AGN__c);
        add2.Bank_Account_Number_AGN__c = (add1.Bank_Account_Number_AGN__c == null ? '': add1.Bank_Account_Number_AGN__c);
        add2.IBAN_Text_AGN__c = (add1.IBAN_Text_AGN__c == null ? '': add1.IBAN_Text_AGN__c);
        add2.Sub_Type_AGN__c = (add1.Sub_Type_AGN__c == null ? '': add1.Sub_Type_AGN__c);
    }
    //        <<-------- added in R16 --------
    
    public list<Allergan_Customer_Address_AGN__c> removeDuplicateAddress(list<Allergan_Customer_Address_AGN__c> addList){
        set<Allergan_Customer_Address_AGN__c> addSet =  new set<Allergan_Customer_Address_AGN__c>();
        list<Allergan_Customer_Address_AGN__c> result =  new list<Allergan_Customer_Address_AGN__c>();
        addSet.addAll(addList);
        result.addAll(addSet);
        return result;
    }
    
    public void deleteBlankAddress(Id customerId){
        list<Allergan_Customer_Address_AGN__c> customerAddressesToDelete =[SELECT Id 
                                                                           FROM Allergan_Customer_Address_AGN__c 
                                                                           WHERE (Parent_AGN__c=:customerId  AND
                                                                                  Sold_To_AGN__c=false AND
                                                                                  Ship_To_AGN__c=false AND
                                                                                  Bill_To_AGN__c=false)];               
        if(!customerAddressesToDelete.isEmpty()){
            try{                
                database.delete(removeDuplicateAddress(customerAddressesToDelete),false);
            }            
            catch(Exception e){
                system.debug('Address Deletion Exception:'+e);
            }
        }
    }
    public void fetchAddress(){
        AGN_GCSP_Settings__c cepl = AGN_GCSP_Settings__c.getInstance('BR');
        if(cepl.ZipFetchAddress__c)
        {
            AGN_CustomerRegistrationUtils.AddressDetail cepDetail= AGN_CustomerRegistrationUtils.getAddressDetail(customerAddress.Zip_AGN__c);
            AGN_CustomerRegistrationUtils.AddressDetail cepDetail1= AGN_CustomerRegistrationUtils.getAddressDetail(deliveryAddress.Zip_AGN__c);
            
            system.debug('============>'+cepDetail);
            customerAddress.Street_Name_AGN__c = cepDetail.street;
            customerAddress.Address_Line_3_AGN__c = cepDetail.bairro;
            customerAddress.City_AGN__c = cepDetail.city;
            getRegionList();
            customerAddress.State_AGN__c = customer.SAP_Country_Code_AGN__c+'-'+cepDetail.state;
            
            deliveryAddress.Street_Name_AGN__c= cepDetail1.street!=null && cepDetail1.street.contains(',')  ?cepDetail1.street.split(',')[0]:cepDetail1.street;
            deliveryAddress.Address_Line_3_AGN__c = cepDetail1.bairro;
            deliveryAddress.City_AGN__c = cepDetail1.city;
            deliveryAddress.State_AGN__c = customer.SAP_Country_Code_AGN__c+'-'+cepDetail1.state;
        }
    }
}