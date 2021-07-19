public class AGN_AMI_CRO_ProcessUtils 
{        
    
    public static Map<string, string> CroToAccountFieldMap = new Map<string, string>();
    public static Map<string, string> CraToAddressFieldMap = new Map<string, string>();
    public static Map<string, string> CraToBizAccountFieldMap = new Map<string, string>();
    public static Map<string, string> CrToContactFieldMap = new Map<string, string>();
    public static Map<string, string> CraToContactFieldMap = new Map<string, string>();
    public static Set<string> CroFieldsToBooleanify = new Set<string>();
    public static Set<string> CraFieldsToBooleanify = new Set<string>();
    public static String expMessg{get;set;}
    public static Account perAcc;
    public static Contact contact;
    public static List<Account> busAcc = new List<Account>();
    public static List<Child_Account_vod__c> childAcc = new List<Child_Account_vod__c>();
    public static List<Address_vod__c> address = new List<Address_vod__c>();
    //CR - 2600 Starts
    public static Map<string, string> CraToAddresstypeMap = new Map<string, string>(); 
    //CR - 2600 Ends
    public static void Process(Allergan_Customer_Registration_AGN__c record)
    {
        system.debug('called');
        // -- Firstly, set up.
        Map<string, RecordType> CroRecordTypes = fetchRecordTypes('Allergan_Customer_Registration_AGN__c');
        Map<string, RecordType> CraRecordTypes = fetchRecordTypes('Allergan_Customer_Address_AGN__c');
        Map<ID,ID> bizAccToCRARecordTypeMap = new Map<ID,ID>();
        Map<ID,ID> addrToCRARecordTypeMap = new Map<ID,ID>();
        fetchFieldMappings();
        
        
        // Set a save point just in case this fails - it should be all or nothing.
        System.SavePoint sp = Database.setSavepoint();
        
        try
        {  
            // -- Secondly, update the accounts themselves.
            
            Account acc = new Account();
            Account bizAcc = new Account();
            contact = new Contact();
            acc.Id = record.Account_AGN__c;               
            if(record.AMI_Registration_AGN__c)
                acc.OwnerId = AGN_AMI_Utility_class.OWNER_ID;
            else 
                acc.OwnerId = record.OwnerId;
            
            for (string croField : CroToAccountFieldMap.keySet()) //SG: commented out to allow null values to be updated on Account
            {
                // If our mappings do not contain a definition, then skip this.
                /*  //SG: commented out to allow null values to be updated on Account
                {
                continue;
                } */ 
                // Otherwise, transfer the value.
                string accField = CroToAccountFieldMap.get(croField);
                system.debug('accField-->'+accField);
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
            //Changes for MD Code CR 6.04.2020--Start
                if(acc.MDCodesCategory_AMI_AGN__c==null || acc.MDCodesCategory_AMI_AGN__c=='')
                {
                    acc.MDCodesCategory_AMI_AGN__c=record.MDCodesCategory_OEU_AMI_AGN__c;
                }
            //Changes for MD Code CR 6.04.2020--End
            
            if (record.Online_Registration_AGN__c) acc.Customer_Managed_AGN__c = true; //set flag for online account management
            
            perAcc = acc;
            system.debug('acc-->'+acc);
            system.debug('acc.first name-->'+acc.FirstName);
            system.debug('acc.Last name-->'+acc.LastName);
            system.debug('acc.name-->'+acc.Name);
            
            // If we're a new record, update the Allergan Customer Registration with our new account ID.
            // For existing Account, no update/upsert performed.
            
            if (record.Account_AGN__c == null)
            {
                acc.Business_Unit_AGN__c ='Medical Aesthetics';
                upsert acc;
                /* Record to be updated after contact creation - DQ - HCP Harmonization changes
                Allergan_Customer_Registration_AGN__c pass2 = new Allergan_Customer_Registration_AGN__c();
                pass2.Id = record.Id;
                pass2.Account_AGN__c = acc.Id;
                update pass2;
				*/
            }else{
                
                Account a =[select id,Business_Unit_AGN__c from account where id =: record.Account_AGN__c limit 1];
                system.debug('Business_Unit_AGN__c>>>>' +a.Business_Unit_AGN__c);
                if(a.Business_Unit_AGN__c == null){
                    a.Business_Unit_AGN__c ='Medical Aesthetics';
                    upsert a; 
                }
                else if(!a.Business_Unit_AGN__c.contains ('Medical Aesthetics')){
                   a.Business_Unit_AGN__c=a.Business_Unit_AGN__c+';Medical Aesthetics'; 
                    upsert a; 
                }
                
            }
            
            // -- Thirdly, process the addresses.
            // Select out our core record types for comparison.
            Id CraNewRT = CraRecordTypes.get('New_AMI_AGN').Id;
            
            //Get Id of Sold To Account
            List<Child_Account_vod__c> soldToAccounts = [SELECT Parent_Account_vod__c  FROM Child_Account_vod__c WHERE Child_Account_vod__c = :acc.Id AND Sold_TO_AGN__C=true LIMIT 1 ];
            Id soldToId = soldToAccounts.isEmpty()? null : soldToAccounts[0].Parent_Account_vod__c ;
            
            // Select out all the related CRA records.
            Set<string> addrFields = new Set<string>(CraToAddressFieldMap.keySet());
            addrFields.addAll(CraToBizAccountFieldMap.keySet());
            addrFields.addAll(CraToContactFieldMap.keySet());
            
            List<Allergan_Customer_Address_AGN__c> cras = Database.query('SELECT Bank_Name_AGN__c, Bank_Account_Number_AGN__c, IBAN_AGN__c, Sort_Code_AGN__c, SWIFT_BIC_AGN__c, Customer_Payment__c, Parent_AGN__r.Account_AGN__c, Parent_AGN__r.Specialty_Allergan_1_AGN__c, Parent_AGN__r.Business_Unit_AGN__c, Account_AGN__c, Parent_AGN__r.Country_Code_AGN__c, Parent_AGN__r.Country_AGN__r.Name ,Parent_AGN__r.Customer_Group_AGN__c, Replacer_AGN__c, Parent_Address_AGN__r.Controlling_Address_vod__c, RecordTypeId, Bill_To_AGN__c, ' + string.join(new List<string>(addrFields), ', ') + 
                                                                         ' FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c = \'' + record.Id + '\'' + ' ORDER BY Sold_To_AGN__c DESC');
            
            system.debug('cras-->'+cras);
            for (Allergan_Customer_Address_AGN__c cra : cras)
            {
                if (cra.RecordTypeId == CraNewRT)
                {                    
                    // Create the business account.
                    if (record.Online_Registration_AGN__c ) {
                        bizAcc.Customer_Managed_AGN__c = record.Online_Registration_AGN__c ; //set flag for online account management
                        bizAcc.Customer_Category_AGN__c = Record.Customer_Category_AGN__c;
                        bizAcc.Customer_Sub_Category_AGN__c = Record.Customer_Sub_Category_AGN__c;
                        bizAcc.Calling_Name_AGN__c = cra.Company_Name_AGN__c;
                    }
                    
                    system.debug(LoggingLevel.ERROR, cra);            
                    // //SG: commented out to allow null values to be updated on Account
                    for (string craField : CraToBizAccountFieldMap.keySet())
                    {
                        // If our mappings do not contain a definition, then skip this.             
                        // Otherwise, transfer the value.
                        string accField = CraToBizAccountFieldMap.get(craField);
                        bizAcc.put(accField, cra.get(craField));
                    }
                    
                    system.debug(bizAcc);
                    system.debug(CraToBizAccountFieldMap);
                    
                    // Insert it.
                    
                    List<RecordType> ListRecType =  [select id from recordtype where name =:bizAcc.Account_Type__c limit 1];
                    if(null!=ListRecType && ListRecType.size()>0 )
                    {
                        bizAcc.recordtypeID = ListRecType[0].id ;
                    } 
                    system.debug('cra.Parent_AGN__c-->'+cra.Parent_AGN__c);
                    system.debug('cra.Parent_AGN__r-->'+cra.Parent_AGN__r);
                    system.debug('cra.Parent_AGN__r.Country_AGN__c'+cra.Parent_AGN__r.Country_AGN__c);
                    system.debug('cra.Parent_AGN__r.Country_AGN__r'+cra.Parent_AGN__r.Country_AGN__r);
                    system.debug('cra.Parent_AGN__r.Country_AGN__r.Name-->'+cra.Parent_AGN__r.Country_AGN__r.Name);
                    if((Boolean)AMI_User_Settings_AGN__c.getValues(cra.Parent_AGN__r.Country_AGN__r.Name).get('HCP_to_HCO__c'))
                    {
                        bizAcc.Specialty_Allergan_1_AGN__c=cra.Parent_AGN__r.Specialty_Allergan_1_AGN__c; 
                        bizAcc.Additional_Specialties_AGN__c=cra.Parent_AGN__r.Business_Unit_AGN__c; 
                        bizAcc.SAP_Customer_Group_AGN__c = cra.Parent_AGN__r.Customer_Group_AGN__c;
                    }
                    
                    if (record.Online_Registration_AGN__c) bizAcc.Customer_Managed_AGN__c = true; //set flag for online account management
                    if(cra.Account_AGN__c == null)
                    	insert bizAcc;
                    else
                        bizAcc.Id = cra.Account_AGN__c;
                    bizAccToCRARecordTypeMap.put(bizAcc.Id, CraNewRT);
                    if (cra.Sold_To_AGN__c) soldToId = bizAcc.Id;
                    busAcc.add(bizAcc);
                    
                    // DQ - HCP Harmonization changes start
                    // Creating Contact with Business Account
                    
                    // Checking if Account is from Spark or has existing AMI
                    List<AccountContactRelation> acrList = [Select ContactId from AccountContactRelation 
                                                            where AccountId =: acc.Id 
                                                            and (Account.AGN_SPARK_Account__c = true 
                                                                 or
                                                                 Contact.is_AMI_Contact_AGN__c = true)                                                            
                                                            Limit 1];
                    // If account has a spark user, use the same user for AMI Portal Access
                    if(!acrList.isEmpty())
                    {
                        contact.id = acrList[0].ContactId;
                    }
                    else
                    {
                        contact.AccountId = bizAcc.Id;
                        contact.Is_AMI_Contact_AGN__c = true;
                        contact.AMI_Person_Account_AGN__c=acc.Id;//added CR- 3647 
                        // Copying Required fields from CR record to Contact Record
                        for (string croField : CrToContactFieldMap.keySet()) 
                        {
                            string conField = CrToContactFieldMap.get(croField);
                            if (CroFieldsToBooleanify.contains(croField))
                            {
                                object val = record.get(croField);
                                if (val != null)
                                {
                                    string value = (string)(val);
                                    contact.put(conField, value.toUpperCase() == 'YES');
                                }
                            }
                            else
                            {
                                contact.put(conField, record.get(croField));
                            }
                        }
                        // Copying Required fields from CRA record to Contact Record
                        for (string croField : CraToContactFieldMap.keySet()) 
                        {
                            string conField = CraToContactFieldMap.get(croField);
                            if (CroFieldsToBooleanify.contains(croField))
                            {
                                object val = cra.get(croField);
                                if (val != null)
                                {
                                    string value = (string)(val);
                                    contact.put(conField, value.toUpperCase() == 'YES');
                                }
                            }
                            else
                            {
                                contact.put(conField, cra.get(croField));
                            }
                        }
                    }
                    
                    
                    upsert contact;
                    
                    // Creating Account - Contact Relationship Record for person account
                    if(acrList.isEmpty())
                    {
                        AccountContactRelation acr = new AccountContactRelation();
                        acr.AccountId = acc.Id;
                        acr.ContactId = contact.Id;
                        acr.IsActive = true;
                        insert acr;
                    }
                    
                    
                    
                    // Update Registration record with Contact and Account record
                    Allergan_Customer_Registration_AGN__c pass2 = new Allergan_Customer_Registration_AGN__c();
                    pass2.Id = record.Id;
                    pass2.Account_AGN__c = acc.Id;
                    pass2.Contact_AGN__c = contact.Id;
                    update pass2; 
                    
                    // DQ - HCP Harmonization changes end
                    
                    // Create the address.
                    Address_vod__c addr = new Address_vod__c();
                    addr.Account_vod__c = bizAcc.Id;
                    addr.Customer_Managed_AGN__c = record.Online_Registration_AGN__c ; //set flag for online account management
                    
                    for (string craField : CraToAddressFieldMap.keySet()) //SG: commented out to allow null values to be updated on Address
                    {                   
                        // If our mappings do not contain a definition, then skip this.                          
                        // Otherwise, transfer the value.
                        string addrField = CraToAddressFieldMap.get(craField);
                        system.debug('craField-->'+craField);
                        system.debug('addrField-->'+addrField);
                        if (CraFieldsToBooleanify.contains(craField))
                        {
                            system.debug('Inside Booleanify');
                            object val = record.get(craField);
                            
                            if (val != null)
                            {
                                string value = (string)(val);
                                
                                addr.put(addrField, value.toUpperCase() == 'YES');
                            }
                        }
                        else
                        {
                            system.debug('Inside else booleanify');
                            system.debug('cra.get(craField)-->'+cra.get(craField));
                            if('AMI_Address_Type__c'.equals(craField)){
                                system.debug('Inside address type');
                                system.debug('CraToAddresstypeMap.get(craField)-->'+CraToAddresstypeMap.get(craField));
                                String str=(String)cra.get(craField);
                                System.debug('str-->'+str);
                                 addr.put(addrField,CraToAddresstypeMap.get(str));
                                 system.debug('addr-->'+addr);
                            }else{
                            	addr.put(addrField, cra.get(craField));
                            }
                        }
                    }
                    
                    addr.Primary_vod__c=True;
                    if(cra.Account_AGN__c == null)
                    	insert addr;
                    else
                        addr.Id = [Select Id from Address_vod__c where Account_vod__c = :cra.Account_AGN__c Limit 1].Id;
                    addrToCRARecordTypeMap.put(addr.Id, CraNewRT);
                    address.add(addr);
                    
                    // AB: Testing if person account and business account has affiliation
                    List<Child_Account_vod__c> existingAffiliation = new List<Child_Account_vod__c>();
                    if(record.Account_AGN__c != null & cra.Account_AGN__c != null)
                        existingAffiliation = [Select Id from Child_Account_vod__c 
                                               where Parent_Account_vod__c = :cra.Account_AGN__c 
                                               and Child_Account_vod__c = :record.Account_AGN__c];
                    
                    // Create the affiliation                    
                    Child_Account_vod__c paAffil = new Child_Account_vod__c();
                    paAffil.Child_Account_vod__c = acc.Id;
                    paAffil.Parent_Account_vod__c = bizAcc.Id;
                    paAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;
                    paAffil.Sold_To_AGN__c = cra.Sold_To_AGN__c;
                    paAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                    paAffil.Copy_Address_vod__c = true;
                    system.debug(paAffil.Copy_Address_vod__c);
                    system.debug(record.Online_Registration_AGN__c);
                    if (record.Online_Registration_AGN__c!= null && record.Online_Registration_AGN__c) {
                        paAffil.Customer_Managed_AGN__c = true; //set flag for online account management
                        if (cra.Sold_To_AGN__c) paAffil.Network_Primary_vod__c = true;
                        /* AB: Commented out as AMI Does not support Business Account to Business Account Affiliation
                        else if((Boolean)AMI_User_Settings_AGN__c.getValues(cra.Parent_AGN__r.Country_AGN__r.Name).get('Enable_HCO_Affiliation__c')) { //insert hco affiliations
                            Child_Account_vod__c baAffil = new Child_Account_vod__c();
                            baAffil.Child_Account_vod__c = bizAcc.Id;
                            baAffil.Parent_Account_vod__c = soldToId;
                            baAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;                            
                            baAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                            childAcc.add(baAffil);
                        }*/
                    }
                    if(existingAffiliation.isEmpty())
                    	childAcc.add(paAffil); 
                    else
                        childAcc.add(existingAffiliation[0]); 
                }
            }
            
            //insert affiliations
            upsert childAcc;
            
            
            //DCR Creation Start
            
            DCR_Config_Settings_AGN__c agnDCRSettings = new DCR_Config_Settings_AGN__c();
            agnDCRSettings = DCR_Config_Settings_AGN__c.getInstance();
            if ((Boolean)AMI_User_Settings_AGN__c.getValues(cras[0].Parent_AGN__r.Country_AGN__r.Name).get('Enable_Automated_New_DCR__c')){                        
                if(perAcc != null && !busAcc.isEmpty() && !address.isEmpty()){
                    if(agnDCRSettings.Veeva_Data_Change_Request_Countries_AGN__c.contains(cras[0].Parent_AGN__r.Country_AGN__r.Name)){
                        system.debug('## Call AGN_CR_CreateAutoDcrUtils.CreateDCR_nonFutureMethod()');
                        AGN_CR_CreateAutoDcrUtils.CreateDCR(Json.serialize(perAcc),Json.serialize(busAcc),Json.serialize(address),Json.serialize(childAcc),Json.serialize(record),Json.serialize(bizAccToCRARecordTypeMap),Json.serialize(addrToCRARecordTypeMap));
                    }else{
                        system.debug('callling@future');
                        callFutureMethod(Json.serialize(perAcc),Json.serialize(busAcc),Json.serialize(address),Json.serialize(childAcc),Json.serialize(record),Json.serialize(bizAccToCRARecordTypeMap),Json.serialize(addrToCRARecordTypeMap));
                    }
                }
            }
            //DCR Creation End
            // If isonline is checked ,Enable OAM portal access for the Account
            Account[] customerAccount = [select Id, Name,PersonContactId, FirstName, LastName, PersonEmail, Phone from Account where Id =: perAcc.Id limit 1];
            system.debug('The value of customerAccount is -->'+customerAccount);
            User[] existingUser;
            if(!customerAccount.IsEmpty())
                existingUser= [Select Id From User Where ContactId=: customerAccount[0].PersonContactId Limit 1];
            system.debug('====check==='+record.Online_Registration_AGN__c+'='+!customerAccount.IsEmpty()+'='+existingUser.IsEmpty());
            if(record.Online_Registration_AGN__c && !customerAccount.IsEmpty() && existingUser.IsEmpty() )
                AGN_CustomerRegistrationUtils.createCustomerUser(Json.serialize(customerAccount[0]));             
        }
        catch(DmlException ex)
        {
            database.rollback(sp);
            if (ex.getDmlType(0) == StatusCode.DUPLICATE_VALUE)
            {
                if (ex.getDmlMessage(0).contains('External_ID2_AGN__c'))
                    record.addError(Label.AGN_CR_Duplicate_SAP_ID_Exists);
                else
                    record.addError(Label.AGN_CR_CreateUpdate_An_affiliation_already_exists_between_these_two_accounts);               
            }
            else
            {
                //throw ex;
                record.addError(ex.getDmlMessage(0));
            }
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_CRO_ProcessUtils','Process');
        }
        catch(Exception ex)
        {
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_CRO_ProcessUtils','Process');
            // If we encounter an error, roll it back.
            database.rollback(sp);
            throw ex;
        }
    }
    //DCR Creation Start
    
    @future
    public static void callFutureMethod(String jAcc, String jBusAcc, String jAddr, String jChildAcc, String jCusRec, String jBusAccMap, String jAddrMap){
        AGN_CR_CreateAutoDcrUtils.CreateDCR(jAcc,jBusAcc,jAddr,jChildAcc,jCusRec,jBusAccMap,jAddrMap);
    }    
    
    //DCR Creation End
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
        List<AMI_CR_to_Account_Mapping_AGN__mdt> crmapping = [SELECT Customer_Registration_Field_AGN__c, Account_Field_Name_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM AMI_CR_To_Account_Mapping_AGN__mdt];
        
        for (AMI_CR_to_Account_Mapping_AGN__mdt mapping : crmapping)
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
        List<AMI_CRA_to_Address_Mapping_AGN__mdt> cramapping = [SELECT CRA_Field_AGN__c, Address_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM AMI_CRA_to_Address_Mapping_AGN__mdt];
        
        for (AMI_CRA_to_Address_Mapping_AGN__mdt mapping : cramapping)
        {
            CraToAddressFieldMap.put(mapping.CRA_Field_AGN__c, mapping.Address_Field_AGN__c);
            
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
        
        // Pull out the CRA->BizAccount mappings...
        List<AMI_CRA_to_Business_Account_Mapping_AGN__mdt   > crabamapping = [SELECT CRA_Field_AGN__c, Account_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM AMI_CRA_to_Business_Account_Mapping_AGN__mdt ];
        
        for (AMI_CRA_to_Business_Account_Mapping_AGN__mdt    mapping : crabamapping)
        {
            CraToBizAccountFieldMap.put(mapping.CRA_Field_AGN__c, mapping.Account_Field_AGN__c);
            
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
        
        // DQ - HCP Harmonization changes start
        // Pull out the CR->Contact mappings...
        List<AMI_CR_to_Contact_Mapping_AGN__mdt> crconmapping = [SELECT CR_Field_AGN__c, Contact_Field_Name_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM AMI_CR_to_Contact_Mapping_AGN__mdt];
        
        for (AMI_CR_to_Contact_Mapping_AGN__mdt mapping : crconmapping)
        {
            CrToContactFieldMap.put(mapping.CR_Field_AGN__c, mapping.Contact_Field_Name_AGN__c);

            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CR_Field_AGN__c);
            }
        }
        
        // Pull out the CRA->Contact mappings...
        List<AMI_CRA_to_Contact_Mapping_AGN__mdt> craconmapping = [SELECT CRA_Field_AGN__c, Contact_Field_Name_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM AMI_CRA_to_Contact_Mapping_AGN__mdt];
        
        for (AMI_CRA_to_Contact_Mapping_AGN__mdt mapping : craconmapping)
        {
            CraToContactFieldMap.put(mapping.CRA_Field_AGN__c, mapping.Contact_Field_Name_AGN__c);

            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
        // DQ - HCP Harmonization changes end
   
        // CR - 2600 Starts
        List<AMI_Account_Address_Type__mdt> craaddtypmapping = [SELECT AMI_Address_type__c, Country_AGN__c, Veeva_Address_Type__c FROM AMI_Account_Address_Type__mdt];
        for(AMI_Account_Address_Type__mdt t:craaddtypmapping){
            CraToAddresstypeMap.put(t.AMI_Address_type__c,t.Veeva_Address_Type__c);
        }
     	system.debug('CraToAddresstypeMap-->'+CraToAddresstypeMap);
        
        
        
        
        
        // CR - 2600 Ends

    }
    
    public class DmlDuplicateException extends Exception {}
}