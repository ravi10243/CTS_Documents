public without sharing class AGN_OAM_ProcessUtils {
    
    public static Map<string, string> CroToAccountFieldMap = new Map<string, string>();
    public static Map<string, string> CraToAddressFieldMap = new Map<string, string>();
    public static Map<string, string> CraToBizAccountFieldMap = new Map<string, string>();
    public static Map<string, string> CraToSAPCustomerFieldMap = new Map<string, string>();
    public static Set<string> CroFieldsToBooleanify = new Set<string>();
    public static Set<string> CraFieldsToBooleanify = new Set<string>();
    public static String expMessg{get;set;}
    public static boolean managedByCustomer{get;set;}
    //private static Id soldToId{get;set;}
    private static map<Id, Id> craAccountMap = new map<Id, Id>();
    private static map<Id, Id> craAddressVodMap = new map<Id, Id>(); 
    private static map<Id, Id> craSAPCustomerMap = new map<Id, Id>(); 
    private static map<Id, Id> craCustomerPaymentMap = new map<Id, Id>(); 
    
    private static map<Id, Id> concustomerConMap = new map<Id, Id>(); 
    
    private static set<Id> contactsSet = new set<Id>(); 
    
    //record types  
    private static map<string, RecordType> CroRecordTypes;
    private static map<string, RecordType> CraRecordTypes;    
    
    public static Account perAcc = null;
    public static Id soldToId = null;
    public static Id soldToSapCustomerId = null;
    

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
            
            //if (record.Online_Registration_AGN__c) acc.Customer_Managed_AGN__c = true; //set flag for online account management
            //Added for OAM EMEA    
            // if(acc.Customer_Managed_AGN__c==false && managedByCustomer==true) acc.Customer_Managed_AGN__c = true;
            
            upsert acc;
            perAcc = acc;
            system.debug(acc);          
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
    

    private static void processContacts(map<Id, Allergan_Customer_Contact_AGN__c> crcMap, map<Id, Allergan_Customer_Address_AGN__c> craMap, 
                                        map<Id, Id> craBAMap, Allergan_Customer_Registration_AGN__c record){
                                            
                                            // key ==> (Allergan_Customer_Contact_AGN__c).Id, Values ==> Contacts
                                            map<Id, Contact> contactMap = new map<Id, Contact>();
                                            list<Account> newHcpList = new list<Account>();
                                            
                                            for (Allergan_Customer_Contact_AGN__c c : crcMap.values()){            
                                                Contact newCon = new Contact(); 
                                                newCon.Is_Primary_Contact_AGN__c = (c.Primary_Contact_AGN__c) ? true :false;
                                                newCon.Salutation = c.Salutation_AGN__c;
                                                newCon.FirstName = c.First_Name_AGN__c;
                                                newCon.Middle_Name_AGN__c = c.Middle_Name_AGN__c;
                                                newCon.LastName = c.Last_Name_AGN__c;
                                                newCon.Email = c.Email_AGN__c;            
                                                newCon.Phone = c.Phone_AGN__c;
                                                newCon.SAP_Contact_Person_Type_AGN__c = c.Contact_Person_Type_AGN__c;
                                                newCon.Has_Allergan_Direct_Access_AGN__c = c.Allergan_Direct_Access_Requested_AGN__c;
                                                newCon.Customer_Registration_AGN__c = 'Complete'; 
                                                if (c.Contact_AGN__c != null){
                                                    newCon.Id = c.Contact_AGN__c; 
                                                    newCon.AccountId = c.Contact_AGN__r.AccountId;
                                                }
                                                else{
                                                    newCon.AccountId = soldToId;
                                                }
                                                contactMap.put(c.Id, newCon);            
                                            }
                                            
                                            if(!contactMap.isEmpty()){
                                                upsert contactMap.values();
                                            }                                             
                                            
                                            list<Contact> contactPersonAccount = new list<Contact>();
                                            Map<Id, Contact> contactPersonAccountMap =new Map<Id, Contact>();
                                            
                                            for (Allergan_Customer_Contact_AGN__c c : crcMap.values()){             
                                                c.Contact_AGN__c = contactMap.get(c.Id)?.Id;
                                                concustomerConMap.put(c.Id, contactMap.get(c.Id)?.Id);
                                                //Add the contactIds to set 
                                                contactsSet.add(c.Contact_AGN__c);
                                                
                                                if (c.Enable_HCP_AGN__c && c.Contact_AGN__c != null){
                                                    contactPersonAccountMap.put(contactMap.get(c.Id)?.Id, contactMap.get(c.Id));
                                                }
                                            }  
                                            
                                            if(!crcMap.isEmpty()) {
                                                update crcMap.values();
                                            }
                                           If (!contactPersonAccountMap.isEmpty()) {
                                            system.debug('@@@@@Contacts Created Successfully@@@@@@');
                                            string contactPAMap = JSON.serialize(contactPersonAccountMap);
                                            string crAddressMaP = JSON.serialize(craMap);
                                            string craBzzAccMap = JSON.serialize(craBAMap);
                                            string cr = JSON.serialize(record);
                                            string CRToAccFieldMap = JSON.serialize(CroToAccountFieldMap);
                                            string CRFieldToB = JSON.serialize(CroFieldsToBooleanify);      
                                           
                                            AGN_CustomerRegistrationUtils.createPersonAccounts(contactPAMap, crAddressMaP, craBzzAccMap, cr, CRToAccFieldMap, CRFieldToB);
                                           } 
                                        }
    

    private static void processBusinessAccounts(map<Id, Allergan_Customer_Address_AGN__c> craMap, Allergan_Customer_Registration_AGN__c record){
        //CraID and Bussiness Account MAP
        map<Id, Account> businessAccounts = new map<Id, Account>();
        //CraID and Bussiness AccountID MAP
        map<Id, Id> craBusinessAccountsMap = new map<Id, Id>();
        //Bzz AccounyId and Bussiness Account MAP
        Map<Id, Account> existingAccountMap = new Map<Id, Account>();
        
        for (Allergan_Customer_Address_AGN__c cra : craMap.values()){
            if (cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){
                Set<Id> conIdList = new Set<Id>();
                Account bizAcc = new Account(); 
                Boolean isConvertAccData = true;
                if(String.isNotEmpty(cra.Account_AGN__c)){
                    craBusinessAccountsMap.put(cra.Id, cra.Account_AGN__c);
                }
                if(String.isNotEmpty(cra.Account_AGN__c) && !cra.Is_Update_Bussiness_Account_AGN__c){
                    isConvertAccData = false;
                   /* bizAcc.Id = cra.Account_AGN__c;
                    if(cra.RecordTypeId == CraRecordTypes.get('New').Id){
                        bizAcc.Ready_For_DCR_AGN__c = true;   
                        if(!existingAccountMap.containskey(bizAcc.Id)){
                            existingAccountMap.put(bizAcc.Id, bizAcc);
                            businessAccounts.put(cra.Id, bizAcc);
                        }  
                    }*/
                                  
                }
                //Oam NeW SoldTo Bussinesss Accoutns Or New Bussinesss Accounts Covered by the Next if Block.
                if(isConvertAccData){               
                    //bizAcc.Customer_Managed_AGN__c = record.Online_Registration_AGN__c; //set flag for online account management
                    bizAcc.Customer_Category_AGN__c = Record.Customer_Category_AGN__c;
                    bizAcc.Customer_Sub_Category_AGN__c = Record.Customer_Sub_Category_AGN__c;
                    bizAcc.Calling_Name_AGN__c = cra.Company_Name_AGN__c;
                    bizAcc.SAP_Customer_Group_AGN__c = cra.Parent_AGN__r.Customer_Group_AGN__c;
                    
                    //Added for OAM EMEA    
                    //if(bizAcc.Customer_Managed_AGN__c==false && managedByCustomer==true) bizAcc.Customer_Managed_AGN__c = true;
                    
                    //populating SAP Code for EMEA OAM
                    bizAcc.Country_Code__c = cra.Country_Code_AGN__c;
                    bizAcc.SAP_Country_Code_AGN__c = cra.SAP_Country_Code_AGN__c;
                    bizAcc.SAP_Sales_Org_AGN__c = cra.Sales_Organization_AGN__c;
                    
                    for (string craField : CraToBizAccountFieldMap.keySet()){            
                        // Otherwise, transfer the value.
                        string accField = CraToBizAccountFieldMap.get(craField);
                        
                        bizAcc.put(accField, cra.get(craField));
                  
                    }                
                    
                    //Assign the Account Recordtype based on Account Type
                    bizAcc.recordtypeID =[select Id from recordtype where (name =:bizAcc.Account_Type__c OR developerName =:bizAcc.Account_Type__c) limit 1]?.Id;
                    System.debug('recordtypeId @@@'+bizAcc.recordtypeID);
                    System.debug('AccountType @@'+bizAcc.Account_Type__c);
                    if((Boolean)AGN_GCSP_Settings__c.getValues(cra.Parent_AGN__r.Country_Code_AGN__c).get('HCP_to_HCO__c')){
                        bizAcc.Specialty_Allergan_1_AGN__c=cra.Parent_AGN__r.Specialty_Allergan_1_AGN__c; // R011
                        bizAcc.Additional_Specialties_AGN__c=cra.Parent_AGN__r.Business_Unit_AGN__c; // R011
                        bizAcc.SAP_Customer_Group_AGN__c = cra.Parent_AGN__r.Customer_Group_AGN__c;
                    }
                    
                    if(cra.RecordTypeId == CraRecordTypes.get('New').Id){
                        bizAcc.Ready_For_DCR_AGN__c = true;
                    }
                    
                    if (cra.Account_AGN__c != null){
                        bizAcc.Id = cra.Account_AGN__c; 
                        if(!existingAccountMap.containskey(bizAcc.Id)){
                            existingAccountMap.put(bizAcc.Id, bizAcc);
                            businessAccounts.put(cra.Id, bizAcc);
                        }  
                        
                    }else{
                        businessAccounts.put(cra.Id, bizAcc);                        
                    }
                    
                    
                    
                }
            }
        }
        
        //check Bussines Account Values are empty
        if(!businessAccounts.isEmpty()) {
            //upsert the bussiness account Values           
            upsert businessAccounts.values();
           
        }   
        
        //update business account id on CRA
        for (Allergan_Customer_Address_AGN__c cra : craMap.values()){
            if (cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){
                //cra.Account_AGN__c = businessAccounts.get(cra.Id)?.Id;
                //create map of cra and BA ids
                Id accId = businessAccounts.containskey(cra.Id) ? businessAccounts.get(cra.Id)?.Id : craBusinessAccountsMap.get(cra.Id);
                craAccountMap.put(cra.Id, accId);
            }
            else if(cra.RecordTypeId == CraRecordTypes.get('Replace').Id || cra.RecordTypeId == CraRecordTypes.get('Affiliate').Id){
                //create map of cra and BA ids
                craAccountMap.put(cra.Id, cra.Account_AGN__c);
            }
            //get sold to ID
            if (cra.Sold_To_AGN__c) soldToId = businessAccounts.containskey(cra.Id) ? businessAccounts.get(cra.Id)?.Id : craBusinessAccountsMap.get(cra.Id);
            // if Multiple SoldTo's choose primary SoldTo
            if(soldToId != null && cra.Primary_AGN__c) soldToId = businessAccounts.containskey(cra.Id) ? businessAccounts.get(cra.Id)?.Id : craBusinessAccountsMap.get(cra.Id);
            
        }
        
        if (soldToId == null){
            soldToId = [SELECT AccountId FROM Case where Id =: record.Case_AGN__c LIMIT 1]?.AccountId;           
            
        } 
    }
    

    private static void processAddresses(map<Id, Allergan_Customer_Address_AGN__c> craMap, map<Id, Id> craBAMap){
        
        map<Id, Address_vod__c> addressToInsert = new map<Id, Address_vod__c>();
        
        
        for (Allergan_Customer_Address_AGN__c cra : craMap.values()){
            // Create the address.
            Address_vod__c addr = new Address_vod__c();
            Boolean isConvertAddress = true;
            if(String.isNotEmpty(cra.Account_AGN__c) && !cra.Is_Update_Bussiness_Account_AGN__c){
                isConvertAddress = false;
                //addr.Account_vod__c = craBAMap.get(cra.Id);
                //if (cra.Parent_Address_AGN__c != null) addr.Id = cra.Parent_Address_AGN__c;
                //addressToInsert.put(cra.Id, addr);
                
            }
            
            if(isConvertAddress){
                //Need to check Veeva Addressline1 validation.
                if (cra.Parent_Address_AGN__c != null) addr.Id = cra.Parent_Address_AGN__c;
                
                if(String.IsEmpty(cra.Parent_Address_AGN__c)){
                    addr.Account_vod__c = craBAMap.get(cra.Id);
                }
                //Added for OAM EMEA    
                // if(addr.Customer_Managed_AGN__c==false && managedByCustomer==true) addr.Customer_Managed_AGN__c = true;
                for (string craField : CraToAddressFieldMap.keySet()) //SG: commented out to allow null values to be updated on Address
                {                                          
                    // Otherwise, transfer the value.
                    string addrField = CraToAddressFieldMap.get(craField);
                    
                    if (CraFieldsToBooleanify.contains(craField))
                    {
                        object val = cra.get(craField);
                        
                        if (val != null)
                        {
                            string value = (string)(val);
                            
                            addr.put(addrField, value.toUpperCase() == 'YES');
                        }
                    }
                    else
                    {
                        addr.put(addrField, cra.get(craField));
                    }
                    //addr.Primary_vod__c=True;                   
                }
                
                addressToInsert.put(cra.Id, addr);
                
            }
            
        }
        if(!addressToInsert.isEmpty()) upsert addressToInsert.values();  
        
        for(Allergan_Customer_Address_AGN__c cra : craMap.values() ){
            cra.Parent_Address_AGN__c = String.IsNotEmpty(cra.Parent_Address_AGN__c) ? cra.Parent_Address_AGN__c : addressToInsert.get(cra.Id)?.Id;
            craAddressVodMap.put(cra.Id, cra.Parent_Address_AGN__c);
        }
        
        //TODO : Update address ID on CRA ?? do we really need it?
        //address.addAll(addressToInsert.values()); //add to list for auto dcr
        
    }
    

    private static void processSAPCustomers(map<Id, Allergan_Customer_Address_AGN__c> craMap, map<Id, Id> craBAMap){
        
        map<Id, Customer_Detail_AGN__c> sapCustomresToInsert = new map<Id, Customer_Detail_AGN__c>();
        for (Allergan_Customer_Address_AGN__c cra : craMap.values()){
            if(cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){
                // Create the address.
                Customer_Detail_AGN__c sapCustomer = new Customer_Detail_AGN__c();
                sapCustomer.Parent_Account_AGN__c = craBAMap.get(cra.Id);
                
                //Check SAP Customer is present 
                if (cra.Parent_SAP_Customer_AGN__c != null) sapCustomer.Id = cra.Parent_SAP_Customer_AGN__c;
                
                //sapCustomer.Customer_Managed_AGN__c = cra.Parent_AGN__r.Online_Registration_AGN__c; //set flag for online account management
                sapCustomer.Customer_Category_AGN__c = cra.Parent_AGN__r.Customer_Category_AGN__c;
                sapCustomer.Customer_Sub_Category_AGN__c = cra.Parent_AGN__r.Customer_Sub_Category_AGN__c;
                sapCustomer.Calling_Name_AGN__c = cra.Company_Name_AGN__c;
                sapCustomer.SAP_Customer_Group_AGN__c = cra.Parent_AGN__r.Customer_Group_AGN__c;
                
                //populating SAP Code for EMEA OAM
                sapCustomer.Country_Code_AGN__c = cra.Country_Code_AGN__c;
                sapCustomer.SAP_Country_Code_AGN__c = cra.SAP_Country_Code_AGN__c;
                sapCustomer.SAP_Sales_Org_AGN__c = cra.Sales_Organization_AGN__c;
                
                if((Boolean)AGN_GCSP_Settings__c.getValues(cra.Parent_AGN__r.Country_Code_AGN__c).get('HCP_to_HCO__c')){
                    sapCustomer.Specialty_Allergan_1_AGN__c=cra.Parent_AGN__r.Specialty_Allergan_1_AGN__c; // R011
                    sapCustomer.Additional_Specialties_AGN__c=cra.Parent_AGN__r.Business_Unit_AGN__c; // R011                   
                }
                
                //Added for OAM EMEA    
                //if(sapCustomer.Customer_Managed_AGN__c==false && managedByCustomer==true) sapCustomer.Customer_Managed_AGN__c = true;
                for (string craField : CraToSAPCustomerFieldMap.keySet()) //SG: commented out to allow null values to be updated on Address
                {                                          
                    // Otherwise, transfer the value.
                    string sapCustomerField = CraToSAPCustomerFieldMap.get(craField);
                    
                    if (CraFieldsToBooleanify.contains(craField))
                    {
                        object val = cra.get(craField);
                        
                        if (val != null)
                        {
                            string value = (string)(val);
                            
                            sapCustomer.put(sapCustomerField, value.toUpperCase() == 'YES');
                        }
                    }
                    else
                    {
                        sapCustomer.put(sapCustomerField, cra.get(craField));
                    }
                    
                }
                
                sapCustomresToInsert.put(cra.Id, sapCustomer);
            }
        }
        system.debug('sapaatrlist-->'+sapCustomresToInsert);
        if(!sapCustomresToInsert.isEmpty()) upsert sapCustomresToInsert.values();  
        
        list<Customer_Detail_AGN__c> sapCustomersList = new list<Customer_Detail_AGN__c>();
        
        //String parentSAPCustomerId = null;
        
        for(Allergan_Customer_Address_AGN__c cra : craMap.values() ){
            
            craSAPCustomerMap.put(cra.Id, sapCustomresToInsert.get(cra.Id)?.Id);
            if(cra.Sold_To_AGN__c) {
                //parentSAPCustomerId = sapCustomresToInsert.get(cra.Id)?.Id;
                soldToSapCustomerId = sapCustomresToInsert.get(cra.Id)?.Id;
            }
        }  
        if(String.isEmpty(soldToSapCustomerId)){
            soldToSapCustomerId  = [SELECT Id FROM Customer_Detail_AGN__c WHERE Parent_Account_AGN__c =:soldToId LIMIT 1]?.Id;
        }
        for(Customer_Detail_AGN__c customer : sapCustomresToInsert.values()){
            Customer_Detail_AGN__c sapCustomerData = new Customer_Detail_AGN__c();
            if(!customer.SAP_Sold_To_AGN__c && soldToSapCustomerId != null){
                sapCustomerData.Parent_Sold_To_AGN__c = soldToSapCustomerId;
                sapCustomerData.Id = customer.Id;
                sapCustomersList.add(sapCustomerData);
            }
            
        }        
        //Update SAP Customers data with Parent SAP Customer Data except Sold To SAP Customer. 
        if(!sapCustomersList.isEmpty()) update sapCustomersList;        
        
    }
    

    private static void processCustomerDetailContactRelations(map<Id, Id> craSapCustIdMap, list<Allergan_Address_Contact_Mapping_agn__c> customerAddressAff, map<Id, Id> contactCustomerMap){
        //set<Id> contactsSet,
        //map<Id, Allergan_Customer_Address_AGN__c> craMap,
        Set<Id> conId = new Set<Id>();
        Set<Id> sapDetailsId = new Set<Id>();
        for(Allergan_Address_Contact_Mapping_agn__c addCon : customerAddressAff){
            //conId.add(addCon.Allergan_Customer_Contact_agn__r.Contact_AGN__c); 
            //sapDetailsId.add(addCon.Allergan_Customer_Address_agn__r.Parent_SAP_Customer_AGN__c);
            conId.add(contactCustomerMap.get(addCon.Allergan_Customer_Contact_agn__c));
            sapDetailsId.add(craSapCustIdMap.get(addCon.Allergan_Customer_Address_agn__c));
        }
        
        
        Map<String, Contact_Custmer_Detail_Relation_AGN__c> ccdrMap = new Map<String, Contact_Custmer_Detail_Relation_AGN__c>();
        for(Contact_Custmer_Detail_Relation_AGN__c ccdr : [SELECT Id, Name, 
                                                           Contact_AGN__c, 
                                                           Customer_Detail_AGN__c, 
                                                           Sold_To_AGN__c, 
                                                           Ship_To_AGN__c, 
                                                           Bill_To_AGN__c,
                                                           Is_Active_AGN__c
                                                           FROM Contact_Custmer_Detail_Relation_AGN__c
                                                           WHERE Contact_AGN__c In : conId 
                                                           AND Customer_Detail_AGN__c In : sapDetailsId]){
                                                               String conIdCustomerId = ccdr.Contact_AGN__c + '-' + ccdr.Customer_Detail_AGN__c;        
                                                               ccdrMap.put(conIdCustomerId, ccdr);
                                                           }
        List<Contact_Custmer_Detail_Relation_AGN__c> contctCustomerList = new List<Contact_Custmer_Detail_Relation_AGN__c>();
        
        //for(Allergan_Customer_Address_AGN__c cra : craMap.Values()){          
        for(Allergan_Address_Contact_Mapping_agn__c affData : customerAddressAff){
            Contact_Custmer_Detail_Relation_AGN__c ccdrRec = new Contact_Custmer_Detail_Relation_AGN__c();
            string contactId = contactCustomerMap.get(affData.Allergan_Customer_Contact_agn__c);
            string sapCustomerId = craSapCustIdMap.get(affData.Allergan_Customer_Address_agn__c);
            
            String conIdCustomerId = contactId + '-' + sapCustomerId;
            //Check same affliation Exist
            if(!ccdrMap.containskey(conIdCustomerId)){                    
                ccdrRec.Contact_AGN__c = contactId;
                ccdrRec.Customer_Detail_AGN__c = sapCustomerId;                                       
            }
            else{
                ccdrRec.Id = ccdrMap.get(conIdCustomerId)?.Id; 
            }             
            contctCustomerList.add(ccdrRec);                
        }            
        //}
        
        if(!contctCustomerList.isEmpty()) upsert contctCustomerList;
    }
     

     private static void processAffiliations(map<Id, Allergan_Customer_Address_AGN__c> craMap, map<Id, Id> craBAMap){
        list<Child_Account_vod__c> chilAccountList = new list<Child_Account_vod__c>();
        list<Child_Account_vod__c> chilAccountListToDelete = new list<Child_Account_vod__c>(); 
        map<Id, Child_Account_vod__c> exitsingAffilMap = new map<Id, Child_Account_vod__c>();
        if (perAcc != null){
            for (Child_Account_vod__c c : [select Id, Parent_Account_vod__c, Child_Account_vod__c from Child_Account_vod__c where Parent_Account_vod__c =:craBAMap.values() and Child_Account_vod__c =:perAcc.Id]){
                exitsingAffilMap.put(c.Parent_Account_vod__c, c);
            }
        }
        Map<String, Child_Account_vod__c>  existingAffiliationsMap = new Map<String, Child_Account_vod__c>();
        //craBAMap.get(cra.Id)
        for(Child_Account_vod__c cPAcc : [SELECT Id, Child_Account_vod__c, Parent_Account_vod__c FROM Child_Account_vod__c WHERE Parent_Account_vod__c =: soldToId OR Child_Account_vod__c =: craBAMap.values()]){
            String childParentMap = cPAcc.Parent_Account_vod__c+'-'+cPAcc.Child_Account_vod__c;
            system.debug('query-BA-Affil'+'====='+childParentMap);
            existingAffiliationsMap.put(childParentMap, cPAcc);
        }
        map<string, Child_Account_vod__c> duplicateAffilCheck= new map<string, Child_Account_vod__c>();
         
        for(Allergan_Customer_Address_AGN__c cra : craMap.values()){
            
            if (cra.RecordTypeId == CraRecordTypes.get('Replace').Id && perAcc != null){
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
                // if(paAffil.Customer_Managed_AGN__c== false && managedByCustomer==true) paAffil.Customer_Managed_AGN__c = true;
                chilAccountList.add(paAffil);
            }
            else if (cra.RecordTypeId == CraRecordTypes.get('Affiliate').Id && perAcc != null){
                // Create the affiliation
                Child_Account_vod__c paAffil = new Child_Account_vod__c();
                paAffil.Child_Account_vod__c = perAcc.Id;
                paAffil.Parent_Account_vod__c = cra.Account_AGN__c;
                paAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;
                paAffil.Sold_To_AGN__c = cra.Sold_To_AGN__c;
                paAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                paAffil.Copy_Address_vod__c = true;
                // paAffil.Customer_Managed_AGN__c= cra.Parent_AGN__r.Online_Registration_AGN__c ;// SB:added for onboarding existing customer to OAM
                
                //Added for OAM EMEA    
                //if(paAffil.Customer_Managed_AGN__c==false && managedByCustomer==true) paAffil.Customer_Managed_AGN__c = true;
                
                system.debug(LoggingLevel.ERROR, paAffil);                    
                chilAccountList.add(paAffil);
            }
            else if  (cra.RecordTypeId == CraRecordTypes.get('New').Id){
                if(String.isNotEmpty(cra.Account_AGN__c) && !cra.Is_Update_Bussiness_Account_AGN__c){
                    //create BA affiliations
                    if(!(cra.Sold_To_AGN__c) && (Boolean)AGN_GCSP_Settings__c.getValues(cra.Parent_AGN__r.Country_Code_AGN__c).get('Enable_HCO_Affiliation__c')) { //insert hco affiliations
                        
                        Child_Account_vod__c baAffil = new Child_Account_vod__c();
                         // Added for EMEAS OAM release 
                        string cpAccMap = soldToId+'-'+craBAMap.get(cra.Id);
                        
                        system.debug('BA-Affil'+'====='+cpAccMap);
                        system.debug('Address Name'+'====='+cra.Id+'=='+cra.Address_Line_1_AGN__c+'=='+cra.Account_AGN__c);
                        if(existingAffiliationsMap.containsKey(cpAccMap)){
                            baAffil.Id = existingAffiliationsMap.get(cpAccMap)?.Id;
                            baAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;                            
                            baAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                            baAffil.Country_Code__c = cra.Country_Code_AGN__c;
                        }else if(craBAMap.containsKey(cra.Id)){
                            baAffil.Child_Account_vod__c = craBAMap.get(cra.Id);
                            baAffil.Parent_Account_vod__c = soldToId;
                            baAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;                            
                            baAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                            baAffil.Country_Code__c = cra.Country_Code_AGN__c;
                        }                        
                        duplicateAffilCheck.put(cpAccMap,baAffil);
                            
                        //chilAccountList.add(baAffil);
                    }
                }
            }
            else if (cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){
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
                    //if(paAffil.Customer_Managed_AGN__c==false && managedByCustomer==true) paAffil.Customer_Managed_AGN__c = true;
                    
                    if (cra.Sold_To_AGN__c) paAffil.Network_Primary_vod__c = true;
                    //system.debug('PA-Affil'+'====='+paAffil.Parent_Account_vod__c+'-'+paAffil.Child_Account_vod__c); 
                    chilAccountList.add(paAffil);
                } 
                
            }   
        }
        
        if(!duplicateAffilCheck.isEmpty()) database.upsert(duplicateAffilCheck.values(), false); //upsert chilAccountList; 
        
        if (!chilAccountListToDelete.isEmpty()) delete chilAccountListToDelete;
    }
    

    private static void processPaymentDetails(map<Id, Allergan_Customer_Address_AGN__c> craMap, map<Id, Id> craBAMap, map<Id, Id> craSAPCustomerIdsMap){
        
        Map<Id, Allergan_Customer_Payment_AGN__c> customerPaymentMap = new Map<Id, Allergan_Customer_Payment_AGN__c>();
        
        for(Allergan_Customer_Address_AGN__c cra : craMap.values()){
            if (cra.Sold_To_AGN__c == true || cra.Bill_To_AGN__c == true){
                system.debug('@@cra payment caling::: ');
                Allergan_Customer_Payment_AGN__c paym = new Allergan_Customer_Payment_AGN__c();
                paym.Account_AGN__c = craBAMap.get(cra.Id);
                paym.Parent_SAP_Customer_AGN__c = craSAPCustomerIdsMap.get(cra.Id);
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
                paym.Business_Name_Reference3_AGN__c = cra.Business_Name_Reference3_AGN__c;
                paym.Contact_Name_Reference1_AGN__c =  cra.Contact_Name_Reference1_AGN__c;
                paym.Contact_Name_Reference2_AGN__c = cra.Contact_Name_Reference2_AGN__c;
                paym.Contact_Name_Reference3_AGN__c = cra.Contact_Name_Reference3_AGN__c;
                paym.Fax_Reference1_AGN__c = cra.Fax_Reference1_AGN__c;
                paym.Fax_Reference2_AGN__c = cra.Fax_Reference2_AGN__c;
                paym.Phone_Reference1_AGN__c = cra.Phone_Reference1_AGN__c;
                paym.Phone_Reference2_AGN__c = cra.Phone_Reference2_AGN__c;
                paym.Phone_Reference3_AGN__c = cra.Phone_Reference3_AGN__c;
                paym.Email_Reference1_AGN__c = cra.Email_Reference1_AGN__c;
                paym.Email_Reference2_AGN__c = cra.Email_Reference2_AGN__c;
                paym.Email_Reference3_AGN__c = cra.Email_Reference3_AGN__c;
                paym.Form_Of_Payment_AGN__c = cra.Form_Of_Payment_AGN__c;
                paym.Payment_Term_AGN__c = cra.Payment_Term_AGN__c;
                //TODO : Replace with default field update from from CRO
                //paym.Form_Of_Payment_AGN__c= string.isEmpty(cra.Form_Of_Payment_AGN__c) ? record.Form_Of_Payment_AGN__c : cra.Form_Of_Payment_AGN__c;
                //paym.Payment_Term_AGN__c = string.isEmpty(cra.Payment_Term_AGN__c ) ? record.Payment_Term_AGN__c : cra.Payment_Term_AGN__c ;                
                
                customerPaymentMap.put(cra.Id, paym);
            }
        }
        
        if(!customerPaymentMap.isEmpty()) upsert customerPaymentMap.values();
        
        //Key ==> Customer Address Ids, Values ==> Customer Payment Ids
        for(Allergan_Customer_Address_AGN__c cra : craMap.values()){
            craCustomerPaymentMap.put(cra.Id, customerPaymentMap.get(cra.Id)?.Id);
        }
    }
    

    private static void processToUpdatecustomerAddress(map<Id, Allergan_Customer_Address_AGN__c> craMap, map<Id, Id> craBAMap, map<Id, Id> craAddMap, map<Id, Id> craSapCustIdMap, map<Id, Id> craPaymentIdMap){
        
        list<Allergan_Customer_Address_AGN__c> customerAddressList = new list<Allergan_Customer_Address_AGN__c>();
        for(Allergan_Customer_Address_AGN__c cra : craMap.values() ){
            Allergan_Customer_Address_AGN__c customerAddress = new Allergan_Customer_Address_AGN__c();
            customerAddress.Id = cra.Id;
            customerAddress.Parent_SAP_Customer_AGN__c = craSapCustIdMap.get(cra.Id);
            customerAddress.Parent_Address_AGN__c = craAddMap.get(cra.Id);
            customerAddress.Account_AGN__c = craBAMap.get(cra.Id);
            customerAddress.Customer_Payment__c = craPaymentIdMap.get(cra.Id);
            customerAddressList.add(customerAddress);
        }
        
        if(!customerAddressList.isEmpty()) update customerAddressList;
    }
    

    public static void Process(Allergan_Customer_Registration_AGN__c record){
        
        //store the all customer address records associated customer registration record
        map<Id, Allergan_Customer_Address_AGN__c> craMap = new map<Id, Allergan_Customer_Address_AGN__c>();
        //store the all customer contact records associated customer registration record
        map<Id, Allergan_Customer_Contact_AGN__c> crcMap = new map<Id, Allergan_Customer_Contact_AGN__c>();
        
        //store the all customer contact Affliate records associated customer registration record
        list<Allergan_Address_Contact_Mapping_agn__c> customerAddressAff = new list<Allergan_Address_Contact_Mapping_agn__c>();
        
        //Store the customer registration record type information
        CroRecordTypes = fetchRecordTypes('Allergan_Customer_Registration_AGN__c');
        //Store the customer addreess record type information
        CraRecordTypes = fetchRecordTypes('Allergan_Customer_Address_AGN__c');
        
        // get the all field mapping from metadata.      
        fetchFieldMappings();
        
        //controlled by custom settings value
        managedByCustomer = ((Boolean)AGN_GCSP_Settings__c.getValues(record.Country_Code_AGN__c).get('Online_Account_Management__c')) ? true : false;
        
        //store the all customer address fields from CRA to BizAccount , CRA to Address, CRA to SAP Customer metadata CRA field values
        Set<string> addrFields = new Set<string>(CraToAddressFieldMap.keySet());
        addrFields.addAll(CraToBizAccountFieldMap.keySet());
        addrFields.addAll(CraToSAPCustomerFieldMap.keySet());
        
        //Country_Code_AGN__c
        for (Allergan_Customer_Address_AGN__c cra : Database.query('SELECT Id, Payment_Term_AGN__c, Parent_SAP_Customer_AGN__c, Form_Of_Payment_AGN__c,Bank_Name_AGN__c, Bank_Account_Number_AGN__c, IBAN_AGN__c,IBAN_Text_AGN__c, Sort_Code_AGN__c, SWIFT_BIC_AGN__c,Control_Key_AGN__c,Bank_Key_AGN__c,Tax_Office_Name_AGN__c, Customer_Payment__c, Parent_AGN__c, Parent_AGN__r.Account_AGN__c, Parent_AGN__r.Specialty_Allergan_1_AGN__c, Parent_AGN__r.Business_Unit_AGN__c, Parent_AGN__r.Online_Registration_AGN__c, Parent_AGN__r.Customer_Category_AGN__c, Parent_AGN__r.Customer_Sub_Category_AGN__c, Account_AGN__c, Parent_AGN__r.Country_Code_AGN__c, Parent_AGN__r.Customer_Group_AGN__c, Replacer_AGN__c, Parent_Address_AGN__r.Controlling_Address_vod__c, RecordTypeId, Business_Name_Reference1_AGN__c, Business_Name_Reference2_AGN__c, Business_Name_Reference3_AGN__c,Contact_Name_Reference1_AGN__c, Contact_Name_Reference2_AGN__c, Contact_Name_Reference3_AGN__c, Fax_Reference1_AGN__c, Fax_Reference2_AGN__c, Phone_Reference1_AGN__c, Phone_Reference2_AGN__c, Phone_Reference3_AGN__c, Email_Reference1_AGN__c, Email_Reference2_AGN__c, Email_Reference3_AGN__c, SAP_Country_Code_AGN__c, Sales_Organization_AGN__c,Is_Update_Bussiness_Account_AGN__c,' + string.join(new List<string>(addrFields), ', ') + 
                                                                   ' FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c = \'' + record.Id + '\'' + ' ORDER BY Sold_To_AGN__c DESC')){
                                                                       craMap.put(cra.Id, cra);                                                                                                                         
                                                                   }
        
        for (Allergan_Customer_Contact_AGN__c crc : Database.query('SELECT ID, Contact_AGN__c,Contact_AGN__r.AccountId, First_Name_AGN__c,Salutation_AGN__c,Middle_Name_AGN__c, Contact_Person_Type_AGN__c, Phone_AGN__c, Last_Name_AGN__c, Email_AGN__c, Enable_HCP_AGN__c, Enable_Portal_User_AGN__c, Primary_Contact_AGN__c, Allergan_Direct_Access_Requested_AGN__c from Allergan_Customer_Contact_AGN__c WHERE Parent_AGN__c = \'' + record.Id + '\'')){
            crcMap.put(crc.Id, crc);            
        }
        
        customerAddressAff = [SELECT Id, Allergan_Customer_Contact_agn__c, Allergan_Customer_Contact_agn__r.Contact_AGN__c,Allergan_Customer_Address_agn__c, Allergan_Customer_Address_agn__r.Parent_SAP_Customer_AGN__c FROM Allergan_Address_Contact_Mapping_agn__c WHERE Allergan_Customer_Registration_agn__c =: record.Id];
        
        //process person account
        //processPersonAccount(record);             
        //process business account
        processBusinessAccounts(craMap, record);        
        //process address
        processAddresses(craMap, craAccountMap);  
        //Process SAP Customres
        processSAPCustomers(craMap, craAccountMap);     
        //process affiliation
        processAffiliations(craMap, craAccountMap);        
        //process payment details
        processPaymentDetails(craMap, craAccountMap, craSAPCustomerMap); // need to modify after create the SAP Customers Records. 
        //process contact
        processContacts(crcMap, craMap, craAccountMap,record); 
        //TODO : Update addressID, Parent AccountId, Parent SAP CustomerId on CRA ?? do we really need it?
        //processToUpdatecustomerAddress(craMap, craAccountMap, craAddressVodMap, craSAPCustomerMap, craCustomerPaymentMap);
        //process contact customer detail affiliations
        //processCustomerDetailContactRelations(craMap, craSAPCustomerMap, contactsSet);
        processCustomerDetailContactRelations(craSAPCustomerMap, customerAddressAff, concustomerConMap);
        
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
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+mapping);
            
            CroToAccountFieldMap.put(mapping.Customer_Registration_Field_AGN__c, mapping.Account_Field_Name_AGN__c);
            system.debug('mapping'+CroToAccountFieldMap);
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
        
        // Pull out the CRA->SAP Customer mappings...
        List<CRA_to_SAP_Customer_Mapping_AGN__mdt> craSapCustomerMapping = [SELECT CRA_Field_AGN__c, SAP_Customer_Field_AGN__c, Is_Address_Fromula_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CRA_to_SAP_Customer_Mapping_AGN__mdt];
        
        for (CRA_to_SAP_Customer_Mapping_AGN__mdt mapping : craSapCustomerMapping)
        {
            CraToSAPCustomerFieldMap.put(mapping.CRA_Field_AGN__c, mapping.SAP_Customer_Field_AGN__c);
            
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
    }
    
}