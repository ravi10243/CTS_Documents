public class AGN_CRO_ProcessUtils
{        
    
    public static Map<string, string> CroToAccountFieldMap = new Map<string, string>();
    public static Map<string, string> CraToAddressFieldMap = new Map<string, string>();
    public static Map<string, string> CraToBizAccountFieldMap = new Map<string, string>();
    public static Set<string> CroFieldsToBooleanify = new Set<string>();
    public static Set<string> CraFieldsToBooleanify = new Set<string>();
    public static String expMessg{get;set;}
    public static boolean managedByCustomer{get;set;}
    private static Id soldToId{get;set;}
    private static map<Id, Id> craAccountMap = new map<Id, Id>();
    //record types
    private static map<string, RecordType> CroRecordTypes;
    private static map<string, RecordType> CraRecordTypes;
        
    public static Account perAcc = null;
    //Auto DCR - Commented out since not used
    /*public static List<Account> busAcc = new List<Account>();
    public static List<Child_Account_vod__c> childAcc = new List<Child_Account_vod__c>();
    public static List<Address_vod__c> address = new List<Address_vod__c>();
    public static Map<ID,ID> bizAccToCRARecordTypeMap = new Map<ID,ID>();
    public static Map<ID,ID> addrToCRARecordTypeMap = new Map<ID,ID>();*/
    
    private static void processPersonAccount(Allergan_Customer_Registration_AGN__c record){
        
        //String newRecordId= [SELECT id from recordType where sobjecttype='Allergan_Customer_Registration_AGN__c' and DeveloperName='New' limit 1].id; 
        //String updateRecordId= [SELECT id from recordType where sobjecttype='Allergan_Customer_Registration_AGN__c' and DeveloperName='Update' limit 1].id;
        Allergan_Customer_Registration_AGN__c pass2 = new Allergan_Customer_Registration_AGN__c();
        String updatedAcc = null;
        
        Account acc = new Account(); 
        //To check if a person account is updated/worked upon
        //if(record.AGN_Business_Account__c == NULL || record.RecordTypeid==newRecordId ||record.RecordTypeid==updateRecordId)
        if(record.AGN_Business_Account__c == NULL)
        {                     
            // -- Secondly, update the accounts themselves.            
            acc.Id = record.Account_AGN__c;
            acc.OwnerId = record.OwnerId;
            
            for (string croField : CroToAccountFieldMap.keySet()) //SG: commented out to allow null values to be updated on Account
            {                               
                // Otherwise, transfer the value.
                string accField = CroToAccountFieldMap.get(croField);
                if (CroFieldsToBooleanify.contains(croField))
                {
                    object val = record.get(croField);
                    
                    if (val != null)
                    {
                        string value = (string)(val);
                        
                        acc.put(accField, value.toUpperCase() == 'YES');
                    }
                }
                else
                {
                    acc.put(accField, record.get(croField));
                }
            }
            
            if (record.Online_Registration_AGN__c) acc.Customer_Managed_AGN__c = true; //set flag for online account management
            //Added for OAM EMEA    
            if(acc.Customer_Managed_AGN__c==false && managedByCustomer==true) acc.Customer_Managed_AGN__c = true;
            
            upsert acc;
            perAcc = acc;        
        }
        
        // If we're a new record, update the Allergan Customer Registration with our new account ID.
        if (record.Account_AGN__c == null)
        {
            pass2.Id = record.Id;
            pass2.Account_AGN__c = acc.Id;
            // update pass2;
            Database.SaveResult result = Database.update(pass2, false);   
            if(result.isSuccess() == true)
            {
                updatedAcc = pass2.Account_AGN__c;
            }
        }
    }
    
    private static void processBusinessAccounts(map<Id, Allergan_Customer_Address_AGN__c> craMap, Allergan_Customer_Registration_AGN__c record){
        
        map<Id, Account> businessAccounts = new map<Id, Account>();
        for (Allergan_Customer_Address_AGN__c cra : craMap.values()){            
            if (cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){  
                
                Account bizAcc = new Account();
                if (record.Online_Registration_AGN__c) {
                    bizAcc.Customer_Managed_AGN__c = record.Online_Registration_AGN__c; //set flag for online account management
                    bizAcc.Customer_Category_AGN__c = Record.Customer_Category_AGN__c;
                    bizAcc.Customer_Sub_Category_AGN__c = Record.Customer_Sub_Category_AGN__c;
                    bizAcc.Calling_Name_AGN__c = cra.Company_Name_AGN__c;                
                }
                
                if (cra.RecordTypeId == CraRecordTypes.get('Amend').Id){
                    bizAcc.Id = cra.Account_AGN__c;
                }
                
                //Added for OAM EMEA    
                if(bizAcc.Customer_Managed_AGN__c==false && managedByCustomer==true) bizAcc.Customer_Managed_AGN__c = true;
                
                //populating SAP Code for EMEA OAM
                bizAcc.Country_Code__c = cra.Country_Code_AGN__c;
                bizAcc.SAP_Country_Code_AGN__c = cra.SAP_Country_Code_AGN__c;
                bizAcc.SAP_Sales_Org_AGN__c = cra.Sales_Organization_AGN__c;
                
                for (string craField : CraToBizAccountFieldMap.keySet()){            
                    // Otherwise, transfer the value.
                    string accField = CraToBizAccountFieldMap.get(craField);
                    bizAcc.put(accField, cra.get(craField));
                }                
                
                // Insert it.
                
                List<RecordType> ListRecType =  [select id from recordtype where name =:bizAcc.Account_Type__c limit 1];
                if(null!=ListRecType && ListRecType.size()>0 ){
                    bizAcc.recordtypeID = ListRecType[0].id ;
                } 
                
                if((Boolean)AGN_GCSP_Settings__c.getValues(cra.Parent_AGN__r.Country_Code_AGN__c).get('HCP_to_HCO__c')){
                    bizAcc.Specialty_Allergan_1_AGN__c=cra.Parent_AGN__r.Specialty_Allergan_1_AGN__c; // R011
                    bizAcc.Additional_Specialties_AGN__c=cra.Parent_AGN__r.Business_Unit_AGN__c; // R011
                    bizAcc.SAP_Customer_Group_AGN__c = cra.Parent_AGN__r.Customer_Group_AGN__c;
                }                
                businessAccounts.put(cra.Id, bizAcc);
            }
        }
        
        upsert businessAccounts.values();
        //update business account id on CRA
        for (Allergan_Customer_Address_AGN__c cra : craMap.values()){
            if (cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){
                cra.Account_AGN__c = businessAccounts.get(cra.Id).Id;
                //create map of cra and BA ids
                craAccountMap.put(cra.Id, cra.Account_AGN__c);
            }
            else if(cra.RecordTypeId == CraRecordTypes.get('Replace').Id || cra.RecordTypeId == CraRecordTypes.get('Affiliate').Id){
                //create map of cra and BA ids
                craAccountMap.put(cra.Id, cra.Account_AGN__c);
            }
            
            //get sold to ID
            if (cra.Sold_To_AGN__c) {
                soldToId = cra.Account_AGN__c;
            }
            else if(string.isEmpty(soldToId) && !string.isEmpty(cra.SAP_Referenced_Customer_ID_AGN__c)){
                List<Account> soldToAcc= new list<Account>();
                soldToAcc=[Select Id from Account WHERE External_ID2_AGN__c =:cra.SAP_Referenced_Customer_ID_AGN__c LIMIT 1];
                soldToId = soldToAcc[0].Id;
            }            
        }
        //add all accounts to list for auto DCR
        //busAcc.addAll(businessAccounts.values());
    }
    
    private static void processAddresses(map<Id, Allergan_Customer_Address_AGN__c> craMap, map<Id, Id> craBAMap){
                       
        map<Id, Address_vod__c> addressToInsert = new map<Id, Address_vod__c>();
        
        for (Allergan_Customer_Address_AGN__c cra : craMap.values()){       
            
            if (cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){
                // Create the address.
                Address_vod__c addr = new Address_vod__c();
                addr.Account_vod__c = craBAMap.get(cra.Id);
                if (cra.Parent_Address_AGN__c != null) addr.Id = cra.Parent_Address_AGN__c;
                //Added for OAM EMEA    
                if(addr.Customer_Managed_AGN__c==false && managedByCustomer==true) addr.Customer_Managed_AGN__c = true;
                for (string craField : CraToAddressFieldMap.keySet()) //SG: commented out to allow null values to be updated on Address
                {                                          
                    // Otherwise, transfer the value.
                    string addrField = CraToAddressFieldMap.get(craField);
                    
                    if (CraFieldsToBooleanify.contains(craField))
                    {
                        object val = cra.get(craField);                    
                        if (val != null){
                            string value = (string)(val);                        
                            addr.put(addrField, value.toUpperCase() == 'YES');
                        }
                    }
                    else{
                        addr.put(addrField, cra.get(craField));
                    }
                    addr.Primary_vod__c=True;               
                }            
                addressToInsert.put(cra.Id, addr);
            }
        }               
        upsert addressToInsert.values();        
        //TODO : Update address ID on CRA ?? do we really need it?
        //address.addAll(addressToInsert.values()); //add to list for auto dcr      
    }
    
    private static void processAffiliations(map<Id, Allergan_Customer_Address_AGN__c> craMap, map<Id, Id> craBAMap){
        list<Child_Account_vod__c> chilAccountList = new list<Child_Account_vod__c>();
        list<Child_Account_vod__c> chilAccountListToDelete = new list<Child_Account_vod__c>(); 
        map<Id, Child_Account_vod__c> exitsingAffilMap = new map<Id, Child_Account_vod__c>();
        for (Child_Account_vod__c c : [select Id, Parent_Account_vod__c, Child_Account_vod__c from Child_Account_vod__c where Parent_Account_vod__c =:craBAMap.values() and Child_Account_vod__c =:perAcc.Id]){
            exitsingAffilMap.put(c.Parent_Account_vod__c, c);
        } 
        
        for(Allergan_Customer_Address_AGN__c cra : craMap.values()){
            
            if (cra.RecordTypeId == CraRecordTypes.get('Affiliate').Id){
                    // Create the affiliation
                    Child_Account_vod__c paAffil = new Child_Account_vod__c();
                    paAffil.Child_Account_vod__c = perAcc.Id;
                    paAffil.Parent_Account_vod__c = cra.Account_AGN__c;
                    paAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;
                    paAffil.Sold_To_AGN__c = cra.Sold_To_AGN__c;
                    paAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                    paAffil.Copy_Address_vod__c = true;
                    paAffil.Customer_Managed_AGN__C= cra.Parent_AGN__r.Online_Registration_AGN__c ;// SB:added for onboarding existing customer to OAM
                    
                    //Added for OAM EMEA    
                    if(paAffil.Customer_Managed_AGN__c==false && managedByCustomer==true) paAffil.Customer_Managed_AGN__c = true;
                    
                    system.debug(LoggingLevel.ERROR, paAffil);                    
                    chilAccountList.add(paAffil);
            }
            if (cra.RecordTypeId == CraRecordTypes.get('Replace').Id){
                
                if (exitsingAffilMap.containsKey(cra.Account_AGN__c)) chilAccountListToDelete.add(exitsingAffilMap.get(cra.Account_AGN__c));
                Child_Account_vod__c paAffil = new Child_Account_vod__c();
                paAffil.Child_Account_vod__c = perAcc.Id;
                paAffil.Parent_Account_vod__c = cra.Replacer_AGN__c;
                paAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;
                paAffil.Sold_To_AGN__c = cra.Sold_To_AGN__c;
                paAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                paAffil.Country_Code__c = cra.Country_Code_AGN__c; 
                paAffil.Copy_Address_vod__c = true;                    
                //Added for OAM EMEA    
                if(paAffil.Customer_Managed_AGN__c== false && managedByCustomer==true) paAffil.Customer_Managed_AGN__c = true;
                chilAccountList.add(paAffil);
            }
            if  (cra.RecordTypeId == CraRecordTypes.get('New').Id){
                //create BA affiliations
                if(!(cra.Sold_To_AGN__c) && (Boolean)AGN_GCSP_Settings__c.getValues(cra.Parent_AGN__r.Country_Code_AGN__c).get('Enable_HCO_Affiliation__c')) { //insert hco affiliations
                    Child_Account_vod__c baAffil = new Child_Account_vod__c();
                    baAffil.Child_Account_vod__c = craBAMap.get(cra.Id);
                    baAffil.Parent_Account_vod__c = soldToId;
                    baAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;                            
                    baAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                    baAffil.Country_Code__c = cra.Country_Code_AGN__c; // Added for EMEAS OAM release
                    chilAccountList.add(baAffil);
                }
            }            
            if (cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){
                //create PA affiliations
                //if(record.Account_AGN__c!=null ||record.RecordTypeid==newRecordId || updatedAcc!= NULL ){
                
                if (perAcc!=null && !exitsingAffilMap.containsKey(craBAMap.get(cra.Id))){ //check if PA affiliation exists
                    Child_Account_vod__c paAffil = new Child_Account_vod__c();
                    paAffil.Child_Account_vod__c = perAcc.Id;
                    paAffil.Parent_Account_vod__c = craBAMap.get(cra.Id);
                    paAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;
                    paAffil.Sold_To_AGN__c = cra.Sold_To_AGN__c;
                    paAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                    paAffil.Copy_Address_vod__c = true;
                    paAffil.Country_Code__c = cra.Country_Code_AGN__c; // Added for EMEAS OAM release                
                    //Added for OAM EMEA    
                    if(paAffil.Customer_Managed_AGN__c==false && managedByCustomer==true) paAffil.Customer_Managed_AGN__c = true;
                    
                    if (cra.Sold_To_AGN__c) paAffil.Network_Primary_vod__c = true;                    
                    chilAccountList.add(paAffil);
                }                                
            }
        }
            
        insert chilAccountList;
        if (!chilAccountListToDelete.isEmpty()) delete chilAccountListToDelete;
    }
    
    private static void processPaymentDetails(map<Id, Allergan_Customer_Address_AGN__c> craMap, map<Id, Id> craBAMap){
                    
        list<Allergan_Customer_Payment_AGN__c> customerPaymentList = new list<Allergan_Customer_Payment_AGN__c>();        
        for(Allergan_Customer_Address_AGN__c cra : craMap.values()){            
            if (cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){                    
                if (cra.Sold_To_AGN__c == true || cra.Bill_To_AGN__c){
                    Allergan_Customer_Payment_AGN__c paym = new Allergan_Customer_Payment_AGN__c();
                    paym.Account_AGN__c = craBAMap.get(cra.Id);
                    if (cra.Customer_Payment__c != null) paym.Id = cra.Customer_Payment__c; // for update 
                    paym.Bank_Name_AGN__c = cra.Bank_Name_AGN__c;
                    paym.Bank_Account_Number_AGN__c = cra.Bank_Account_Number_AGN__c;
                    paym.IBAN_AGN__c = cra.IBAN_AGN__c;
                    paym.IBAN_Text_AGN__c = cra.IBAN_Text_AGN__c;
                    paym.Sort_Code_AGN__c = cra.Sort_Code_AGN__c;
                    paym.SWIFT_BIC_AGN__c = cra.SWIFT_BIC_AGN__c;
                    paym.Control_Key_AGN__c=cra.Control_Key_AGN__c;
                    paym.Bank_Key_AGN__c=cra.Bank_Key_AGN__c;
                    paym.Tax_Office_Name_AGN__c= cra.Tax_Office_Name_AGN__c;           
                    paym.Business_Name_Reference1_AGN__c = cra.Business_Name_Reference1_AGN__c;
                    paym.Business_Name_Reference2_AGN__c = cra.Business_Name_Reference2_AGN__c;
                    paym.Contact_Name_Reference1_AGN__c =  cra.Contact_Name_Reference1_AGN__c;
                    paym.Contact_Name_Reference2_AGN__c = cra.Contact_Name_Reference2_AGN__c;
                    paym.Fax_Reference1_AGN__c = cra.Fax_Reference1_AGN__c;
                    paym.Fax_Reference2_AGN__c = cra.Fax_Reference2_AGN__c;
                    paym.Phone_Reference1_AGN__c = cra.Phone_Reference1_AGN__c;
                    paym.Phone_Reference2_AGN__c = cra.Phone_Reference2_AGN__c;
                    paym.Form_Of_Payment_AGN__c = cra.Form_Of_Payment_AGN__c;
                    paym.Payment_Term_AGN__c = cra.Payment_Term_AGN__c;
                    //TODO : Replace with default field update from from CRO
                    //paym.Form_Of_Payment_AGN__c= string.isEmpty(cra.Form_Of_Payment_AGN__c) ? record.Form_Of_Payment_AGN__c : cra.Form_Of_Payment_AGN__c;
                    //paym.Payment_Term_AGN__c = string.isEmpty(cra.Payment_Term_AGN__c ) ? record.Payment_Term_AGN__c : cra.Payment_Term_AGN__c ;                
                    customerPaymentList.add(paym);                    
                }
            }
        }
        upsert customerPaymentList;
    }
    
    public static void Process(Allergan_Customer_Registration_AGN__c record){
        
        CroRecordTypes = fetchRecordTypes('Allergan_Customer_Registration_AGN__c');
        CraRecordTypes = fetchRecordTypes('Allergan_Customer_Address_AGN__c');
        /* */       
        fetchFieldMappings();
        
        if((Boolean)AGN_GCSP_Settings__c.getValues(record.Country_Code_AGN__c).get('Online_Account_Management__c'))
            managedByCustomer= true;
        
        Set<string> addrFields = new Set<string>(CraToAddressFieldMap.keySet());
        addrFields.addAll(CraToBizAccountFieldMap.keySet());
        map<Id, Allergan_Customer_Address_AGN__c> craMap = new map<Id, Allergan_Customer_Address_AGN__c>();
        for (Allergan_Customer_Address_AGN__c cra : Database.query('SELECT Id, SAP_Referenced_Customer_ID_AGN__c, Payment_Term_AGN__c, Form_Of_Payment_AGN__c,Bank_Name_AGN__c, Bank_Account_Number_AGN__c, IBAN_AGN__c,IBAN_Text_AGN__c, Sort_Code_AGN__c, SWIFT_BIC_AGN__c,Control_Key_AGN__c,Bank_Key_AGN__c,Tax_Office_Name_AGN__c, Customer_Payment__c,Parent_AGN__r.Account_AGN__r.Primary_Parent_vod__c, Parent_AGN__r.Account_AGN__c, Parent_AGN__r.Specialty_Allergan_1_AGN__c, Parent_AGN__r.Business_Unit_AGN__c, Account_AGN__c, Parent_AGN__r.Country_Code_AGN__c,Parent_AGN__r.Customer_Group_AGN__c, Parent_AGN__r.Online_Registration_AGN__c, Replacer_AGN__c, Parent_Address_AGN__r.Controlling_Address_vod__c, RecordTypeId, Country_Code_AGN__c,  Business_Name_Reference1_AGN__c, Business_Name_Reference2_AGN__c, Contact_Name_Reference1_AGN__c, Contact_Name_Reference2_AGN__c, Fax_Reference1_AGN__c, Fax_Reference2_AGN__c, Phone_Reference1_AGN__c, Phone_Reference2_AGN__c, SAP_Country_Code_AGN__c, Sales_Organization_AGN__c,' + string.join(new List<string>(addrFields), ', ') + 
                                                                   ' FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c = \'' + record.Id + '\'' + ' ORDER BY Sold_To_AGN__c DESC')){
             craMap.put(cra.Id, cra);                                                                                                                         
        }
        
        //process person account
        processPersonAccount(record);               
        //process business account
        processBusinessAccounts(craMap, record);        
        //process address
        
        processAddresses(craMap, craAccountMap);
        //process affiliation
        processAffiliations(craMap, craAccountMap);
        //process payment details
        processPaymentDetails(craMap, craAccountMap);
                
        //process auto dcr - commented out since not used       
        /*DCR_Config_Settings_AGN__c agnDCRSettings = new DCR_Config_Settings_AGN__c();
        agnDCRSettings = DCR_Config_Settings_AGN__c.getInstance();
        if ((Boolean)AGN_GCSP_Settings__c.getValues(record.Country_Code_AGN__c).get('Enable_Automated_New_DCR__c')){                        
            if(perAcc != null && !busAcc.isEmpty() && !address.isEmpty()){
                if(agnDCRSettings.Veeva_Data_Change_Request_Countries_AGN__c.contains(record.Country_Code_AGN__c)){
                    system.debug('## Call AGN_CR_CreateAutoDcrUtils.CreateDCR_nonFutureMethod()');
                    AGN_CR_CreateAutoDcrUtils.CreateDCR(Json.serialize(perAcc),Json.serialize(busAcc),Json.serialize(address),Json.serialize(childAcc),Json.serialize(record),Json.serialize(bizAccToCRARecordTypeMap),Json.serialize(addrToCRARecordTypeMap));
                }else{
                    system.debug('callling@future');
                    callFutureMethod(Json.serialize(perAcc),Json.serialize(busAcc),Json.serialize(address),Json.serialize(childAcc),Json.serialize(record),Json.serialize(bizAccToCRARecordTypeMap),Json.serialize(addrToCRARecordTypeMap));
                }
            }
        }*/
        // process Enable OAM portal access for the Account
        if(record.Online_Registration_AGN__c && perAcc != null ){
                            
            Account[] customerAccount = [select Id, Name,PersonContactId, FirstName, LastName, PersonEmail, Phone from Account where Id =: perAcc.Id limit 1];
            User[] existingUser;
            if(!customerAccount.IsEmpty()) existingUser= [Select Id From User Where ContactId=: customerAccount[0].PersonContactId Limit 1];
            
            Boolean isOktaEnable = false;
                
            if(AGN_GCSP_Settings__c.getValues(record.Country_Code_AGN__c).get('Is_Okta_Enabled_AGN__c') == null){
                isOktaEnable = false;
            }
            else{
                isOktaEnable = (Boolean)AGN_GCSP_Settings__c.getValues(record.Country_Code_AGN__c).get('Is_Okta_Enabled_AGN__c');
            }
            
            if(record.Online_Registration_AGN__c && !customerAccount.IsEmpty() && existingUser.IsEmpty() && !isOktaEnable){
                AGN_CustomerRegistrationUtils.createCustomerUser(Json.serialize(customerAccount[0]));                     
            }
        }
    }
    
    @future
    public static void callFutureMethod(String jAcc, String jBusAcc, String jAddr, String jChildAcc, String jCusRec, String jBusAccMap, String jAddrMap){
        AGN_CR_CreateAutoDcrUtils.CreateDCR(jAcc,jBusAcc,jAddr,jChildAcc,jCusRec,jBusAccMap,jAddrMap);
    }    
        
    public static Map<string, RecordType> fetchRecordTypes(string sobjecttype)
    {
        Map<string, RecordType> output = new Map<string, RecordType>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :sobjecttype])
        {
            output.put(rt.DeveloperName, rt);
        }
            
        return output;
    }
    
    public static void fetchFieldMappings()
    {
        // Pull out the CRO->Account mappings...
        List<CR_To_Account_Mapping_AGN__mdt> crmapping = [SELECT Customer_Registration_Field_AGN__c, Account_Field_Name_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CR_To_Account_Mapping_AGN__mdt];
        
        for (CR_To_Account_Mapping_AGN__mdt mapping : crmapping)
        {
           
            CroToAccountFieldMap.put(mapping.Customer_Registration_Field_AGN__c, mapping.Account_Field_Name_AGN__c);            
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CroFieldsToBooleanify.add(mapping.Customer_Registration_Field_AGN__c);
            }
        }
        
        // Pull out the CRA->Address mappings...
        List<CRA_To_Address_Mapping_AGN__mdt> cramapping = [SELECT CRA_Field_AGN__c, Address_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CRA_To_Address_Mapping_AGN__mdt];
        
        for (CRA_To_Address_Mapping_AGN__mdt mapping : cramapping)
        {
            CraToAddressFieldMap.put(mapping.CRA_Field_AGN__c, mapping.Address_Field_AGN__c);

            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
        
        // Pull out the CRA->BizAccount mappings...
        List<CRA_to_Business_Account_Mapping_AGN__mdt> crabamapping = [SELECT CRA_Field_AGN__c, Account_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CRA_to_Business_Account_Mapping_AGN__mdt];
        
        for (CRA_to_Business_Account_Mapping_AGN__mdt mapping : crabamapping)
        {
            CraToBizAccountFieldMap.put(mapping.CRA_Field_AGN__c, mapping.Account_Field_AGN__c);

            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
    }
    
    public class DmlDuplicateException extends Exception {}
}