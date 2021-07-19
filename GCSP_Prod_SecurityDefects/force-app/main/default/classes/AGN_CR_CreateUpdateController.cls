public class AGN_CR_CreateUpdateController
{ 
	
    public Integer mlength { get; set;} 
    
    public final PageReference CurrentPage;
    public final Allergan_Customer_Registration_AGN__c Record { get; set; }   
    public final Allergan_Customer_Registration_AGN__c PrevRecord { get; set; }  
    public Account Account
    {
        get
        {
            return Record.Account_AGN__r;
        }

        set
        {
            Record.Account_AGN__r = value;
            Record.Account_AGN__c = value.Id;
        }
    }
    public List<Allergan_Customer_Address_AGN__c> Addresses { get; set; }
    // below is keyed on the Address_vod__c ID
    public Map<Id, Allergan_Customer_Address_AGN__c> PreviousAddress { get; set; }
    public Map<Id, Address_vod__c> RealAddresses { get; set; }
    
    // These are populated on construction via the getFieldMappings method.
    // These two map Allergan_Customer_Registration_AGN__c fields to Account fields
    Map<string, string> CroToAccountMap = new Map<string, string>();
    Map<string, string> AccountToCroMap = new Map<string, string>();
    
    // These two map Allergan_Customer_Address_AGN__c fields to Address fields
    Map<string, string> CraToAddressFieldMap = new Map<string, string>();
    Map<string, string> AddressToCraFieldMap = new Map<string, string>();

    // These two map Allergan_Customer_Address_AGN__c business account fields to Account fields
    Map<string, string> CraToBusAccountFieldMap = new Map<string, string>();
    Map<string, string> BusAccountToCraFieldMap = new Map<string, string>();
    
    
    public Set<string> CroFieldsToBooleanify = new Set<string>();
    public static Set<string> CraFieldsToBooleanify = new Set<string>();

    public integer TargetAddress { get; set; }
    
    public boolean IsUpdate { get; set; }
    
    public boolean IsDeactivate {get;set;}
    
    public string Changelist { get; set; }
    
    public boolean IsOnline {get;set;}
    
    public AGN_CR_CreateUpdateController() 
    {          
        //========== Release 14.1 Niladri ==============
		mlength = 80;
        List<User> loggedInUser = [select Id, Name, Country,Country_Code__c FROM User WHERE Id =: UserInfo.getUserId()];        
        System.debug('=============== Country Code : '+loggedInUser[0].Country_Code__c);       
        
        AGN_Settings__c ac = AGN_Settings__c.getInstance();
		System.debug('==== Value ====== '+ac.GCSPAddrLengthRestrictionCountries_AGN__c);
		String data = ac.GCSPAddrLengthRestrictionCountries_AGN__c;        
        List<String> lstCountryCode = data.split(',');        
        System.debug(lstCountryCode);
		for(String gc : lstCountryCode){
            if(loggedInUser[0].Country_Code__c == gc){
                mlength = 35;
            }            
        }                        
		System.debug('========= mlength ========= '+mlength);
        
        
        Record = new Allergan_Customer_Registration_AGN__c();
        Record.Account_Type_AGN__c = 'Professional';
        Record.Country_Code_AGN__c = [select Country_Code__c from User where Id = :UserInfo.getUserId()].Country_Code__c;
        IsUpdate = false;
        IsDeactivate = false;
        IsOnline = (Boolean)AGN_GCSP_Settings__c.getValues(Record.Country_Code_AGN__c).get('Online_Account_Management__c');
        
        CurrentPage = ApexPages.currentPage();
        Addresses = new List<Allergan_Customer_Address_AGN__c>();
        PreviousAddress = new Map<Id, Allergan_Customer_Address_AGN__c>();
    
        // Populate our Customer Registration Object to Account field maps. This
        // stores the relationship between CRO fields and Account fields.
        fetchFieldMappings();

        // If we're updating an existing record, select out the values.
        Map<string, string> params = CurrentPage.getParameters();

        if (params.containsKey('acc') || params.containsKey('caseStaticCategory') && params.get('caseStaticCategory').toUpperCase() == 'UPDATE' || 
                            params.containsKey('caseStaticCategory') && params.get('caseStaticCategory').toUpperCase() == 'DEACTIVATE')
        {
            IsUpdate = true;            
            record.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'Update' LIMIT 1][0].Id;
            
            if (params.containsKey('caseStaticCategory') && params.get('caseStaticCategory').toUpperCase() == 'DEACTIVATE') isDeactivate = true;                
        }    
        else if (params.containsKey('caseStaticCategory') && params.get('caseStaticCategory').toUpperCase() == 'DEACTIVATE'){
            IsDeactivate = true;
        }
        else
        {
            IsUpdate = false;
            record.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id;
        }

        if (params.containsKey('acc'))
        {
            // Query out the account.
            Id accId = (Id)(params.get('acc'));
            Set<string> accountFields = new Set<string>();
            accountFields.addAll(AccountToCroMap.keySet());

            string query = 'SELECT Country_vod__r.Alpha_2_Code_vod__c, ' + string.join(new List<string>(AccountToCroMap.keySet()), ', ') + ' FROM Account WHERE Id = :accId';
            system.debug(LoggingLevel.ERROR, '*** KH ' + query);
            Account = database.query(query);

            // Set our record type to an Update.
            record.Account_AGN__c = Account.Id;
      record.SAP_Country_Code_AGN__c = Account.Country_vod__r.Alpha_2_Code_vod__c;
            // And now iterate through our account fields and set
            // the values of our CRO.
            for (string accField : AccountToCroMap.keySet())
            {
                string croField = AccountToCroMap.get(accField);

                if (CroFieldsToBooleanify.contains(croField))
                {
                    Record.put(croField, Account.get(accField) == true ? 'Yes' : 'No');
                }
                else
                {
                    Record.put(croField, Account.get(accField));
                }
            }
            system.debug(LoggingLevel.ERROR, '*** KH: ' + Account);
            system.debug(LoggingLevel.ERROR, '*** KH: ' + Record);

            // And now pull out all the related addresses.
            Addresses = fetchAddresses(accId);
        }
        PrevRecord = Record.clone();
    }
    
    public void fetchFieldMappings()
    {
        // Pull out the CRO->Account mappings...
        List<CR_To_Account_Mapping_AGN__mdt> crmapping = [SELECT Customer_Registration_Field_AGN__c, Account_Field_Name_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CR_To_Account_Mapping_AGN__mdt];
        
        for (CR_To_Account_Mapping_AGN__mdt mapping : crmapping)
        {
            CroToAccountMap.put(mapping.Customer_Registration_Field_AGN__c, mapping.Account_Field_Name_AGN__c);
            AccountToCroMap.put(mapping.Account_Field_Name_AGN__c, mapping.Customer_Registration_Field_AGN__c);


            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CroFieldsToBooleanify.add(mapping.Customer_Registration_Field_AGN__c);
            }
        }
        
        // Pull out the CRA->Address mappings...
        List<CRA_To_Address_Mapping_AGN__mdt> cramapping = [SELECT CRA_Field_AGN__c, Address_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CRA_To_Address_Mapping_AGN__mdt];

        for (CRA_To_Address_Mapping_AGN__mdt mapping : cramapping)
        {   
        // Added if condition for state code  and state conversion
            if(mapping.CRA_Field_AGN__c=='State_Code_AGN__c'){
                CraToAddressFieldMap.put('State_AGN__c', mapping.Address_Field_AGN__c);
                AddressToCraFieldMap.put(mapping.Address_Field_AGN__c, 'State_AGN__c');            
            }
            else{
                CraToAddressFieldMap.put(mapping.CRA_Field_AGN__c, mapping.Address_Field_AGN__c);
                AddressToCraFieldMap.put(mapping.Address_Field_AGN__c, mapping.CRA_Field_AGN__c);
            }

            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
        
        // Pull out the CRA->BusAccount mappings...
        List<CRA_to_Business_Account_Mapping_AGN__mdt> crabamapping = [SELECT CRA_Field_AGN__c, Account_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CRA_to_Business_Account_Mapping_AGN__mdt];
        
        for (CRA_to_Business_Account_Mapping_AGN__mdt mapping : crabamapping)
        {
            CraToBusAccountFieldMap.put(mapping.CRA_Field_AGN__c, mapping.Account_Field_AGN__c);
            BusAccountToCraFieldMap.put(mapping.Account_Field_AGN__c, mapping.CRA_Field_AGN__c);
                        
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
        
    }

    
    public List<Allergan_Customer_Address_AGN__c> fetchAddresses(id personAccountId){
        Set<ID> busAccntID =new Set<ID>();
        
        List<Child_Account_vod__c> listChildAccnt = [select Parent_Account_vod__c, Bill_To_AGN__c, Ship_To_AGN__c, Sold_To_AGN__c from Child_Account_vod__c where Child_Account_vod__c =:personAccountId ];
        
        List<Allergan_Customer_Address_AGN__c> rtn = new List<Allergan_Customer_Address_AGN__c>();
        
        for(Child_Account_vod__c childAccnt : listChildAccnt){
            
            ID childAccntId = childAccnt.Parent_Account_vod__c;            
            
            string query = 'SELECT Account_vod__c, Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c, ' + string.join(new List<string>(AddressToCraFieldMap.keySet()), ', ') +  ' FROM Address_vod__c WHERE Account_vod__c = :childAccntId';
            List<Address_vod__c> addresses = Database.query(query);
            
            for (Address_vod__c addr : addresses){
                Allergan_Customer_Address_AGN__c crAddr = new Allergan_Customer_Address_AGN__c();
                
                /* Populate Business Account Address information in Allergan Customer Address object */                
                for (string key : AddressToCraFieldMap.keySet()){
                    string craField = AddressToCraFieldMap.get(key);
                    
                    if (CraFieldsToBooleanify.contains(craField)){
                        crAddr.put(craField, addr.get(key) == true ? 'Yes' : 'No');
                    }
                    //Added for Statecode to state conversion
                    else if(key=='State_vod__c'){
                        crAddr.put('State_AGN__c',string.isblank(addr.State_vod__c) ?'':(addr.Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c+'-'+ addr.State_vod__c));
                    }
                    else{
                        crAddr.put(craField, addr.get(key));
                    }
                }                
                crAddr.Parent_Address_AGN__c = addr.Id;
                crAddr.Parent_Address_AGN__r = addr;
                
                /* Populate Business Account information in Allergan Customer Address object */
                string paymentQuery = '(SELECT Id, Bank_Account_Number_AGN__c, Bank_Name_AGN__c, Form_Of_Payment_AGN__c, IBAN_AGN__c, Sort_Code_AGN__c, SWIFT_BIC_AGN__c from Allergan_Customer_Payments__r LIMIT 1)';
                //string accntQuery = 'SELECT recordtype.Name, ' + string.join(new List<string>(BusAccountToCraFieldMap.keySet()), ', ') + ' FROM Account WHERE Id = :childAccntId';
                string accntQuery = 'SELECT recordtype.Name, ' + string.join(new List<string>(BusAccountToCraFieldMap.keySet()), ', ') +  ', ' + paymentQuery + ' FROM Account WHERE Id = :childAccntId';
                List<Account> accntList = Database.query(accntQuery);
                for(Account accnt : accntList){
                 
                    for (string key : BusAccountToCraFieldMap.keySet()){
                        string craField = BusAccountToCraFieldMap.get(key);
                        
                        if (CraFieldsToBooleanify.contains(craField))
                        {
                            crAddr.put(craField, accnt.get(key) == true ? 'Yes' : 'No');
                        }
                        else
                        {
                            system.debug('@@@@@@@@@@@@@@'+craField);
                            crAddr.put(craField, accnt.get(key));
                        }
                        
                    } 
                    //  crAddr.Account_Type_AGN__c = accntList[0].recordtype.Name;
                        crAddr.Account_Type_AGN__c = accnt.recordtype.Name; 
                      // populate payment information
                      for(Allergan_Customer_Payment_AGN__c cp : accnt.Allergan_Customer_Payments__r){
                            crAddr.Bank_Account_Number_AGN__c = cp.Bank_Account_Number_AGN__c;
                            crAddr.Bank_Name_AGN__c = cp.Bank_Name_AGN__c;                      
                            crAddr.IBAN_AGN__c = cp.IBAN_AGN__c;
                            crAddr.Sort_Code_AGN__c = cp.Sort_Code_AGN__c;
                            crAddr.SWIFT_BIC_AGN__c = cp.SWIFT_BIC_AGN__c;
                            crAddr.Customer_Payment__c = cp.Id;
                        }
                }
                
                /* Populate Ship to and Sold to information in Allergan Customer Address object */
                crAddr.Ship_To_AGN__c = childAccnt.Ship_To_AGN__c;
                crAddr.Sold_To_AGN__c = childAccnt.Sold_To_AGN__c;
                crAddr.Bill_To_AGN__c = childAccnt.Bill_To_AGN__c;
                rtn.add(crAddr);            
                PreviousAddress.put(addr.Id, crAddr.clone());                
            }            
            RealAddresses = new Map<Id, Address_vod__c>(addresses); 
        }               
        return rtn;
    }
    
    public void addNewAddress()
    {
        Allergan_Customer_Address_AGN__c addr = new Allergan_Customer_Address_AGN__c();
        addr.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'Affiliate' LIMIT 1][0];
        addr.RecordTypeId = addr.RecordType.Id;
        Addresses.add(addr);
    }
    
    public void resetAddress(Allergan_Customer_Address_AGN__c addr)
    {
        addr.Account_AGN__c = null;
        if (addr.Parent_Address_AGN__c != null)
        {
            for (string key : addr.getPopulatedFieldsAsMap().keySet())
            {
                system.debug('Amend Address:::::'+key);
                if (CraToAddressFieldMap.containsKey(key))
                {  system.debug('CraToAddressMap@@@@@@@@@@@@@'+key);
                    addr.put(key, addr.Parent_Address_AGN__r.get(CraToAddressFieldMap.get(key)));
                }
            }
        }
        else
        {
            for (string key : addr.getPopulatedFieldsAsMap().keySet())
            {
                if (key == 'RecordType' || key.endsWith('__r'))
                {
                    continue;
                }
                
                addr.put(key, null);
            }
        }
    }
   
    
    public void setAddressAsNew()
    {
        Allergan_Customer_Address_AGN__c addr = Addresses.get(TargetAddress);
        
        resetAddress(addr);
        
        addr.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0];
        addr.RecordTypeId = addr.RecordType.Id;
    }
    
    public void setAddressAsAffiliate()
    {
        Allergan_Customer_Address_AGN__c addr = Addresses.get(TargetAddress);
        
        resetAddress(addr);
        
        addr.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'Affiliate' LIMIT 1][0];
        addr.RecordTypeId = addr.RecordType.Id;
    }
    
    public void setAddressAsReplace()
    {
        Allergan_Customer_Address_AGN__c addr = Addresses.get(TargetAddress);
        
        resetAddress(addr);
        
        addr.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'Replace' LIMIT 1][0];
        addr.RecordTypeId = addr.RecordType.Id;
        
        addr.Account_AGN__c = addr.Parent_Address_AGN__r.Account_vod__c;
    }
    
    
    public void setAddressAsAmend()
    {
        Allergan_Customer_Address_AGN__c addr = Addresses.get(TargetAddress);
        
       // resetAddress(addr);

        addr.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'Amend' LIMIT 1][0];
        addr.RecordTypeId = addr.RecordType.Id;
        
        addr.Account_AGN__c = addr.Parent_Address_AGN__r.Account_vod__c;
    }
    
    
    public void setAddressAsUnchanged()
    {
        Allergan_Customer_Address_AGN__c addr = Addresses.get(TargetAddress);
        
     //   resetAddress(addr);
        
        addr.RecordType = null;
        addr.RecordTypeId = null;
      //  addr.Ship_To_AGN__c = false;
      //  addr.Sold_To_AGN__c = false;
    }
    
    public void deleteNewAddress()
    {
        System.debug('*** KH Removing ' + Addresses.get(TargetAddress));
        Addresses.remove(TargetAddress);
    }
    
    private void setSAPCustomerGroup(){
        
        Record.SAP_Country_Code_AGN__c = [Select Alpha_2_Code_vod__c from Country_vod__c where Id =: Record.Country_AGN__c].Alpha_2_Code_vod__c;        
        for(Customer_Type_Configuration_AGN__c ctc : [SELECT Name,
                         Account_Record_Type_AGN__c,
                         Category_AGN__c,
                         Country_Code_AGN__c,
                         Customer_Group_AGN__c ,
                         Sub_Category__c FROM Customer_Type_Configuration_AGN__c WHERE Country_Code_AGN__c=:Record.SAP_Country_Code_AGN__c]){
                             
                             if(ctc.Category_AGN__c == Record.Customer_Category_AGN__c && ctc.Sub_Category__c == Record.Customer_Sub_Category_AGN__c){
                                 Record.Customer_Group_AGN__c = ctc.Customer_Group_AGN__c;
                                   return;
                             }
                         }        
    }
    

    public PageReference save()
    {
        integer numSoldTo = 0;
        integer numShipTo = 0;
        
        //R12.1 Abhisek Mitra
        integer primaryCount = 0;
        integer primaryCountAff = 0;
        //end
        Map<string, string> params = CurrentPage.getParameters();
        
        Case cs = new Case();
        Set<string> addressHash = new Set<string>();
        
        cs.EntitlementId = (Id)(params.get('entitlementId'));
        cs.RecordTypeId = (Id)(params.get('recordType'));
        cs.Service_AGN__c = params.get('caseService');
        cs.Reason = params.get('caseReason');
        cs.Type = params.get('caseCategory');
        cs.Description_Rich_Text__c = Changelist;
        cs.Form_Of_Payment_AGN__c = Record.Form_Of_Payment_AGN__c;
        cs.Business_Unit_AGN__c = Record.Business_Unit_AGN__c;
            
        List<Allergan_Customer_Address_AGN__c> addressesToInsert = new List<Allergan_Customer_Address_AGN__c>();
        
        // If we are an update, then ONLY show the alterations.
        if (IsUpdate)
        {
            for (string key : Record.getPopulatedFieldsAsMap().keySet())
            {
                if (key == 'RecordTypeId')
                {
                    continue;
                }
                       
                system.debug(LoggingLevel.ERROR, '*** KH ' + key);
                // If we're unchanged, then set the value to null.
                if (CroToAccountMap.containsKey(key) && Record.get(key) == Account.get(CroToAccountMap.get(key)) )
                {
                   
                    //Record.put(key, null);
                }
                
                if(CroFieldsToBooleanify.contains(key) && ((String.valueof(Record.get(key))=='Yes' && Boolean.valueof(Account.get(CroToAccountMap.get(key)))==true) || (String.valueof(Record.get(key))=='NO' && Boolean.valueof(Account.get(CroToAccountMap.get(key)))==false)))
                {
                    //Record.put(key, null);
                }   
                    
            }
        }
        
        
        if (IsUpdate)
        {
            for (Child_Account_vod__c existing : [SELECT Parent_Account_vod__c, Child_Account_vod__c FROM Child_Account_vod__c 
                                                  WHERE Child_Account_vod__c = :Record.Account_AGN__c OR Child_Account_vod__c = :Record.Account_AGN__c])
            {
                addressHash.add((string)existing.Child_Account_vod__c + (string)existing.Parent_Account_vod__c);
                addressHash.add((string)existing.Parent_Account_vod__c + (string)existing.Child_Account_vod__c);
            }
        }
        
        // Do the same for addresses.
        for (Allergan_Customer_Address_AGN__c addr : Addresses)
        {
            numSoldTo += addr.Sold_To_AGN__c ? 1 : 0;
            numShipTo += addr.Ship_To_AGN__c ? 1 : 0;
            
            if (addr.RecordTypeId == null)
            {
                //R12.1 Abhisek Mitra
              
                if(addr.Primary_AGN__c==true)
                        primaryCount++;
              
                //end
                //added for portal access activation for existing user
                if( record.Online_Registration_AGN__c== PrevRecord.Online_Registration_AGN__c)       
                    continue;
            }
            
            system.debug(LoggingLevel.ERROR, '*** KH ' + addr.Parent_Address_AGN__c);
            
            // If we don't have a parent address, we are a new address altogether - so insert us. Otherwise,
            // check to see what changes have been made...
            if (addr.Parent_Address_AGN__c == null)
            {
                addressesToInsert.add(addr);
            }
            else
            {
                Allergan_Customer_Address_AGN__c parentAddress = PreviousAddress.get(addr.Parent_Address_AGN__c);
                integer numChanges = 0;
                
                for (string key : addr.getPopulatedFieldsAsMap().keySet())
                {
                    if (key.contains('RecordType') || key.contains('__r'))
                    {
                        continue;
                    }
                    
                    
                    system.debug(LoggingLevel.ERROR, '*** KH ' + key);
                    // If we're unchanged, then set the value to null.
                    //if (CraToAddressFieldMap.containsKey(key) && Record.get(key) == Account.get(CraToAddressFieldMap.get(key)))
                    if (addr.get(key) == parentAddress.get(key))
                    {
                        //addr.put(key, null);
                    }
                    else
                    {
                        numchanges++;
                    }
                }
                
                if (numchanges > 0)
                {
                    addressesToInsert.add(addr);
                }
                 //added for portal access activation for existing user
                else if( record.Online_Registration_AGN__c && !PrevRecord.Online_Registration_AGN__c && (addr.Sold_To_AGN__c || addr.Ship_To_AGN__c|| addr.Bill_To_AGN__c)){
                    system.debug('@@Inside portal access');
                    addr.Account_AGN__c = addr.Parent_Address_AGN__r.Account_vod__c;
                    addr.RecordTypeId= [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'Amend' LIMIT 1][0].Id;
                    addressesToInsert.add(addr);                    
                } 
            }
        }
        
        // Update our change list field to reflect this.
        Record.Change_List_AGN__c = Changelist;
        // Set SAP Customer Group
        if (!isUpdate) setSAPCustomerGroup();
        
        // Try now to insert the record.
        //System.Savepoint sp = Database.setSavepoint();
        Savepoint sp = Database.setSavepoint();
        try
        {
            cs.AccountId = Record.Account_AGN__c;
            cs.Description_Rich_Text__c = Record.Change_List_AGN__c;
            insert cs;

            Record.Case_AGN__c = cs.Id;
            Record.Trigger_Validation_of_Children__c = false;
            Record.Count_of_Ship_To_AGN__c = numShipTo;
            Record.Count_of_Sold_To_AGN__c = numSoldTo;
            insert Record;
            
            for (Allergan_Customer_Address_AGN__c addr : addressesToInsert)
            {
                addr.Parent_AGN__c = Record.Id;
                ID recordTypeID =addr.RecordTypeID;
                
                //R12.1 Abhisek Mitra                
                if(addr.Primary_AGN__c==true )
                    primaryCount++;
                //end
                
                String recordTypeName;
                if(null!=recordTypeID)
                {
                   recordTypeName = Allergan_Customer_Address_AGN__c.sObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeID).getName();   
                    
                } 
                //12.1 Abhisek Mitra    
                if(recordTypeName=='Affiliate')
                {
                   primaryCountAff++;
                }
                //end
                       
                system.debug('Record Type Name'+recordTypeName);
                List<Account> lAccount = new List<Account>();
                if(recordTypeName.contains('Affiliate'))
                lAccount =[select External_ID2_AGN__c from Account where id =: addr.Account_AGN__c];
                else if(recordTypeName.contains('Replace'))
                lAccount =[select External_ID2_AGN__c from Account where id =: addr.Replacer_AGN__c];    
                if(null!=lAccount && lAccount.size()>0 )
                addr.SAP_ID_AGN__c = lAccount[0].External_ID2_AGN__c ;
            }
            
            //R12.1 Abhisek Mitra
            
            if(primaryCount==0 && primaryCountAff==0){                
                Record.Id = null;
                for (Allergan_Customer_Address_AGN__c addr : addressesToInsert)
                {
                    addr.Id = null;
                }
                Database.rollback(sp);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.CaseNoPrimaryCheckError_AGN));
                
                return null;
            }            
            //end            
            insert addressesToInsert;
            system.debug(LoggingLevel.ERROR, '*** KH ' + addressesToInsert);

            // Then trigger an update on the record - to trigger off validation rules that focus on child records.
            Record.Trigger_Validation_of_Children__c = true;
            update Record;
        }
        catch (Exception e)
        {
            // as to why Salesforce doesn't unset these itself when rolling back I don't know!
            Record.Id = null;
            for (Allergan_Customer_Address_AGN__c addr : addressesToInsert)
            {
                addr.Id = null;
            }

            ApexPages.addMessages(e);
            Database.rollback(sp);
            return null;
        }
        
        // And finally - return us here afterwards.
        return new PageReference('/' + cs.Id);
    }

}