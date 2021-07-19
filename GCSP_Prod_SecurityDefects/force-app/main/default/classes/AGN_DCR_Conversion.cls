public class AGN_DCR_Conversion {
    
    static Map<ID,String> countryMap;
    static Map<ID,String> countryNameMap;    
    static Map<ID,String> rTypeMap = new Map<ID,String>();
    static Map<String,Boolean> territoryMap = new Map<String,Boolean>();
    static Map<String, List<Data_Change_Request_Line_vod__c>> dcrToDCRLineMap = new Map<String, List<Data_Change_Request_Line_vod__c>>();
    
    static String userTerritory;
    static User DCRUser = new User();
    static DCR_Config_Settings_AGN__c dcrSettings;
    static List<Account_Territory_Loader_vod__c> atlToInsert = new List<Account_Territory_Loader_vod__c>();
    static List<Account_Territory_Loader_vod__c> atlToUpdate = new List<Account_Territory_Loader_vod__c>();    
    static List<TSF_vod__c> tsfToInsert = new List<TSF_vod__c>();   
    static List<TSF_vod__c> tsfToDelete = new List<TSF_vod__c>(); 
    
    static string PROVISIONAL = 'Provisional';
    static string ADD = 'Add';
    static string REMOVE = 'Remove';
    
    
    @InvocableMethod
    public static void AGN_DCR_ConversionMethod(List<Data_Change_Request_vod__c> dcrList){
        
        system.debug('## Inside AGN_DCR_ConversionMethod()');
        
        Integer counter = 0;
        
        String accId;
        String addressId;
        String childAccountId;
        List<Data_Change_Request_vod__c> dcrToUpdate = new List<Data_Change_Request_vod__c>();
        Map<ID,ID> dcrToAccountMap = new Map<ID,ID>();
        Map<ID,ID> dcrToAddressMap = new Map<ID,ID>();
        Map<ID,ID> dcrToChildAccountMap = new Map<ID,ID>();
        Map<String,String> newATLMap = new Map<String, String>();
        DCRUser = [SELECT Name, CompanyName, Email, FirstName, LastName, Phone,Is_CoolSculpting_User_AGN__c FROM User WHERE Id = :UserInfo.getUserId()];
        countryMap = new Map<ID,String>();
        countryNameMap = new Map<ID,String>();
        
        for(RecordType rType : [select Id, Name from RecordType where SObjectType = 'Data_Change_Request_vod__c']){            
            rTypeMap.put(rType.Id, rType.Name);            
        }
        
        /*********** Below lines of code were included as a part of Coolsculpting development ***********/
        //for(Territory terr : [select Name, Coolsculpting_Territory_AGN__c from Territory]){
        //territoryMap.put(terr.Name, terr.Coolsculpting_Territory_AGN__c);
        // }
        //system.debug('@@ territoryMap: ' + territoryMap);
        /*********** End of code designed as a part of Coolsculpting development ***********/
        
        for(Country_vod__c country : [select ID, Alpha_2_Code_vod__c, Cluster_Country_AGN__c, AGN_Country_Name__c from Country_vod__c]){
            if(country.Alpha_2_Code_vod__c != null && country.Alpha_2_Code_vod__c != ''){
                if(country.Cluster_Country_AGN__c != null && country.Cluster_Country_AGN__c != ''){
                    countryMap.put(country.ID, country.Cluster_Country_AGN__c);
                }else{
                    countryMap.put(country.ID, country.Alpha_2_Code_vod__c);
                }
                countryNameMap.put(country.ID, country.AGN_Country_Name__c);                
            }            
        }
        
        Set<String> dcrIdSet = new Set<String>();        
        for(Data_Change_Request_vod__c dcr : dcrList){
            dcrIdSet.add(dcr.Id);
        }
        
        List<Data_Change_Request_Line_vod__c> dcrLineList = new List<Data_Change_Request_Line_vod__c>();        
        for(Data_Change_Request_Line_vod__c dcrLine : [select Field_API_Name_vod__c, Old_Value_vod__c, Old_Localized_Value_vod__c, 
                                                       New_Value_vod__c, New_Localized_Value_vod__c, Data_Change_Request_vod__c
                                                       from Data_Change_Request_Line_vod__c
                                                       where Data_Change_Request_vod__c in :dcrIdSet
                                                      ])
        {
            dcrLineList.add(dcrLine);
        }
        
        List<Data_Change_Request_Line_vod__c> dcrLineTempList;
        for(String dcrId : dcrIdSet){
            dcrLineTempList = new List<Data_Change_Request_Line_vod__c>();
            for(Data_Change_Request_Line_vod__c dcrLine : dcrLineList){
                if(dcrLine.Data_Change_Request_vod__c == dcrId){
                    dcrLineTempList.add(dcrLine);
                }                
            }
            if(dcrLineTempList.size() > 0){
                dcrToDCRLineMap.put(dcrId, dcrLineTempList);
            }
        }
        
        
        dcrSettings = DCR_Config_Settings_AGN__c.getInstance();
        
        try{
            for(Data_Change_Request_vod__c dcr : dcrList){
                counter++;
                system.debug('## Inside AGN_DCR_ConversionMethod(). counter: ' + counter + '    dcr.Name: ' + dcr.Name + '    dcr: ' + dcr);
                system.debug('## Inside AGN_DCR_ConversionMethod(). Self_Auto_Approved_AGN__c: ' + dcr.Self_Auto_Approved_AGN__c);
                userTerritory = null;
                if(rTypeMap.get(dcr.RecordTypeId) == 'Account_vod' && dcr.Type_vod__c == 'New_vod'){
                    //create Provisional Customer
                    if(dcr.Provisional_Contact_Required_AGN__c == TRUE){
                        if(dcr.DCR_Status_AGN__c == 'Saved'){
                            accId = createAccount(dcr, PROVISIONAL);
                        }
                    }                    
                    if(accId != '' && accId != null){
                        dcrToAccountMap.put(dcr.Id, accId);
                        newATLMap.put(accId, userTerritory);
                    }
                }
                
                if(rTypeMap.get(dcr.RecordTypeId) == 'Address_vod' && dcr.Type_vod__c == 'New_vod'){
                    if(dcr.Parent_Data_Change_Request_vod__c != null){
                        //create address and link to Provisional Customer
                        if(dcr.Provisional_Contact_Required_AGN__c == TRUE  && 
                           ((dcr.DCR_Status_AGN__c == 'Saved' ||  dcr.DCR_Status_AGN__c == 'Pending for Approval') || 
                            (dcr.Self_Auto_Approved_AGN__c == 'YES' && dcr.DCR_Status_AGN__c == 'Approved')
                           )
                          )
                        {
                            addressId = createAddress(dcr, PROVISIONAL);  
                        }
                    }
                    if(addressId != null && addressId != ''){
                        dcrToAddressMap.put(dcr.Id, addressId);
                    }                    
                }
                
                if(rTypeMap.get(dcr.RecordTypeId) == 'Child_Account_vod' && dcr.Type_vod__c == 'New_vod'){
                    system.debug('## dcr.DCR_Status_AGN__c: ' + dcr.DCR_Status_AGN__c);
                    system.debug('## Inside AGN_DCR_ConversionMethod(). Inside child account loop. Self_Auto_Approved_AGN__c: ' + dcr.Self_Auto_Approved_AGN__c);
                    if(dcr.Parent_Data_Change_Request_vod__c != null){
                        if(dcr.Provisional_Contact_Required_AGN__c == TRUE  && 
                           ((dcr.DCR_Status_AGN__c == 'Saved' ||  dcr.DCR_Status_AGN__c == 'Pending for Approval') || 
                            (dcr.Self_Auto_Approved_AGN__c == 'YES' && dcr.DCR_Status_AGN__c == 'Approved')
                           )
                          )
                        {
                            childAccountId = createChildAccount(dcr, PROVISIONAL);
                        }                       
                        
                    }
                    system.debug('## Inside AGN_DCR_ConversionMethod(). childAccountId = ' + childAccountId);                    
                    if(childAccountId != null && childAccountId != ''){
                        dcrToChildAccountMap.put(dcr.Id, childAccountId);
                    } 
                }            
            }
            
            if(dcrToAccountMap.size()>0){
                for(Data_Change_Request_vod__c dcr : [select Id, Account_vod__c from Data_Change_Request_vod__c where Id in :dcrToAccountMap.keySet()]){
                    dcr.Account_vod__c = dcrToAccountMap.get(dcr.Id);
                    dcrToUpdate.add(dcr);
                }
                if(newATLMap.size() > 0){
                    Create_Remove_ATL_TSF(newATLMap, ADD);
                }                
            }
            
            if(dcrToAddressMap.size() > 0){
                for(Data_Change_Request_vod__c dcr : [select Id, Address_vod__c from Data_Change_Request_vod__c where Id in :dcrToAddressMap.keySet()]){
                    dcr.Address_vod__c = dcrToAddressMap.get(dcr.Id);
                    dcrToUpdate.add(dcr);
                }
            }
            
            if(dcrToChildAccountMap.size() > 0){
                for(Data_Change_Request_vod__c dcr : [select Id, Child_Account_vod__c from Data_Change_Request_vod__c where Id in :dcrToChildAccountMap.keySet()]){
                    dcr.Child_Account_vod__c = dcrToChildAccountMap.get(dcr.Id);
                    dcrToUpdate.add(dcr);
                }
            }            
            
            if(dcrToUpdate.size() > 0){
                update dcrToUpdate;
            }
            if(atlToInsert.size() > 0){
                insert atlToInsert;
            }
            if(atlToUpdate.size() > 0){
                update atlToUpdate;
            }            
            if(tsfToInsert.size() > 0){
                insert tsfToInsert;
            }
            if(tsfToDelete.size() > 0){
                delete tsfToDelete;
            }
        }catch(System.Exception e){
            system.debug('## Exception Inside AGN_DCR_ConversionMethod: ' + e + ' ## Cause: ' + e.getCause() + ' ## Type: ' + e.getTypeName() + ' ## Line: ' + e.getLineNumber());
        }
        
    }
    
    
    
    static String createAccount(Data_Change_Request_vod__c dcr, String Type){
        
        system.debug('## Inside createProvisionalAccount()');        
        Account acc = new Account();        
        for(Data_Change_Request_Line_vod__c dcrLine : dcrToDCRLineMap.get(dcr.Id))
        {
            if(dcrLine.Field_API_Name_vod__c != 'Territory_vod__c' && dcrLine.Field_API_Name_vod__c != 'IsPersonAccount' ){
                
                if(AGN_VeevaDCR_Utilities.getFieldType('Account',dcrLine.Field_API_Name_vod__c) == 'BOOLEAN'){
                    acc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToBoolean(dcrLine.New_Value_vod__c));
                }
                else if(AGN_VeevaDCR_Utilities.getFieldType('Account',dcrLine.Field_API_Name_vod__c) == 'INTEGER'){
                    acc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToInteger(dcrLine.New_Value_vod__c));
                }
                else if(AGN_VeevaDCR_Utilities.getFieldType('Account',dcrLine.Field_API_Name_vod__c) == 'DOUBLE'){
                    acc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDouble(dcrLine.New_Value_vod__c));
                }      
                else if(AGN_VeevaDCR_Utilities.getFieldType('Account',dcrLine.Field_API_Name_vod__c) == 'PERCENT'){
                    acc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDouble(dcrLine.New_Value_vod__c));
                }                  
                else if(AGN_VeevaDCR_Utilities.getFieldType('Account',dcrLine.Field_API_Name_vod__c) == 'DATE'){
                    acc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDate(dcrLine.New_Value_vod__c));
                }
                else if(AGN_VeevaDCR_Utilities.getFieldType('Account',dcrLine.Field_API_Name_vod__c) == 'DATETIME'){
                    acc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDateTime(dcrLine.New_Value_vod__c));
                }                            
                else{
                    acc.put(dcrLine.Field_API_Name_vod__c,dcrLine.New_Value_vod__c);
                }                            
                
            }
            if(dcrLine.Field_API_Name_vod__c == 'Territory_vod__c'){
                userTerritory = dcrLine.New_Value_vod__c.mid(1,dcrLine.New_Value_vod__c.length()-2);
                system.debug('## Inside createProvisionalAccount(). userTerritory: ' + userTerritory);                
            }
            
        }
        
        acc.OwnerId = dcrSettings.Integration_User_ID_AGN__c;
        acc.Country_vod__c = dcr.Country_AGN__c;
        acc.Country_Code__c = countryMap.get(dcr.Country_AGN__c);
        
        if(Type == PROVISIONAL){
            acc.Status_AGN__c = 'Pending Validation';
        }        
        acc.Consent_to_Contact_AGN__c = True;
        acc.AGN_DCR_Ref__c = dcr.Name;
        
        /*********** Below lines of code were included as a part of Coolsculpting development ***********/
        // if(territoryMap.get(userTerritory) == TRUE){
        //acc.CoolSculpting_Status_AGN__c = 'CoolSculpting Prospect';
        
        //}
        if ( DCRUser.Is_CoolSculpting_User_AGN__c == TRUE){            
            acc.CoolSculpting_Status_AGN__c = 'CoolSculpting Prospect';            
        }
        /*********** End of code included as a part of Coolsculpting development ***********/
        
        insert acc;
        return acc.Id;        
    }
    
    static string createAddress(Data_Change_Request_vod__c dcr, String Type){
        system.debug('## Inside createAddress()');
        Address_vod__c addr = new Address_vod__c();
        
        for(Data_Change_Request_Line_vod__c dcrLine : dcrToDCRLineMap.get(dcr.Id))
        {
            
            if(AGN_VeevaDCR_Utilities.getFieldType('Address_vod__c',dcrLine.Field_API_Name_vod__c) == 'BOOLEAN'){
                addr.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToBoolean(dcrLine.New_Value_vod__c));
            }
            else if(AGN_VeevaDCR_Utilities.getFieldType('Address_vod__c',dcrLine.Field_API_Name_vod__c) == 'INTEGER'){
                addr.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToInteger(dcrLine.New_Value_vod__c));
            }
            else if(AGN_VeevaDCR_Utilities.getFieldType('Address_vod__c',dcrLine.Field_API_Name_vod__c) == 'DOUBLE'){
                addr.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDouble(dcrLine.New_Value_vod__c));
            }      
            else if(AGN_VeevaDCR_Utilities.getFieldType('Address_vod__c',dcrLine.Field_API_Name_vod__c) == 'PERCENT'){
                addr.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDouble(dcrLine.New_Value_vod__c));
            }                  
            else if(AGN_VeevaDCR_Utilities.getFieldType('Address_vod__c',dcrLine.Field_API_Name_vod__c) == 'DATE'){
                addr.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDate(dcrLine.New_Value_vod__c));
            }
            else if(AGN_VeevaDCR_Utilities.getFieldType('Address_vod__c',dcrLine.Field_API_Name_vod__c) == 'DATETIME'){
                addr.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDateTime(dcrLine.New_Value_vod__c));
            }else{
                addr.put(dcrLine.Field_API_Name_vod__c,dcrLine.New_Value_vod__c);
            }
            
        }
        
        if(Type == PROVISIONAL){
            addr.Account_vod__c = [select Account_vod__c from Data_Change_Request_vod__c where Id = :dcr.Parent_Data_Change_Request_vod__c].Account_vod__c;
            system.debug('## Inside createAddress(). Type == PROVISIONAL. addr.Account_vod__c: ' + addr.Account_vod__c);
        }
        
        addr.Requested_from_DCR_AGN__c = True;
        addr.Country_Code__c = countryMap.get(dcr.Country_AGN__c);
        if(addr.Country_vod__c == null || addr.Country_vod__c == ''){
            addr.Country_vod__c = countryNameMap.get(dcr.Country_AGN__c);
        }     
        
        system.debug('## Inside createAddress(). addr: ' + addr);
        
        insert addr;
        return addr.Id;
    }
    
    static string createChildAccount(Data_Change_Request_vod__c dcr, String Type){
        
        system.debug('## Inside createChildAccount()');
        Child_Account_vod__c childAcc = new Child_Account_vod__c();
        Child_Account_vod__c childAccList = new Child_Account_vod__c();
        String parentId;
        String childId;
        String extId;
        Schema.SObjectField extIDField = Child_Account_vod__c.External_ID_vod__c;
        
        for(Data_Change_Request_Line_vod__c dcrLine : dcrToDCRLineMap.get(dcr.Id))
        {
            if(dcrLine.Field_API_Name_vod__c == 'Primary_vod__c'){
                continue;
            }
            if(dcrLine.Field_API_Name_vod__c == 'Parent_Account_vod__c'){
                parentId = dcrLine.New_Value_vod__c;
            }
            if(dcrLine.Field_API_Name_vod__c == 'Child_Account_vod__c'){
                childId = dcrLine.New_Value_vod__c;
            }
            system.debug('## Inside createChildAccount(). Inside PROVISIONAL. parentId: ' + parentId + '   childId: ' + childId + '   dcrLine.Field_API_Name_vod__c: ' + dcrLine.Field_API_Name_vod__c + '    dcrLine.New_Value_vod__c: ' + dcrLine.New_Value_vod__c);
            
            if(AGN_VeevaDCR_Utilities.getFieldType('Child_Account_vod__c',dcrLine.Field_API_Name_vod__c) == 'BOOLEAN'){
                childAcc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToBoolean(dcrLine.New_Value_vod__c));
            }
            else if(AGN_VeevaDCR_Utilities.getFieldType('Child_Account_vod__c',dcrLine.Field_API_Name_vod__c) == 'INTEGER'){
                childAcc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToInteger(dcrLine.New_Value_vod__c));
            }
            else if(AGN_VeevaDCR_Utilities.getFieldType('Child_Account_vod__c',dcrLine.Field_API_Name_vod__c) == 'DOUBLE'){
                childAcc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDouble(dcrLine.New_Value_vod__c));
            }      
            else if(AGN_VeevaDCR_Utilities.getFieldType('Child_Account_vod__c',dcrLine.Field_API_Name_vod__c) == 'PERCENT'){
                childAcc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDouble(dcrLine.New_Value_vod__c));
            }                  
            else if(AGN_VeevaDCR_Utilities.getFieldType('Child_Account_vod__c',dcrLine.Field_API_Name_vod__c) == 'DATE'){
                childAcc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDate(dcrLine.New_Value_vod__c));
            }
            else if(AGN_VeevaDCR_Utilities.getFieldType('Child_Account_vod__c',dcrLine.Field_API_Name_vod__c) == 'DATETIME'){
                childAcc.put(dcrLine.Field_API_Name_vod__c,AGN_VeevaDCR_Utilities.convertToDateTime(dcrLine.New_Value_vod__c));
            }else{
                childAcc.put(dcrLine.Field_API_Name_vod__c,dcrLine.New_Value_vod__c);                    
            }
            
        }
        
        if(Type == PROVISIONAL){
            childId = [select Account_vod__c from Data_Change_Request_vod__c where Id = :dcr.Parent_Data_Change_Request_vod__c].Account_vod__c;
            
            system.debug('## Inside createChildAccount(). Inside PROVISIONAL. parentId: ' + parentId + '   childId: ' + childId + '   dcr.Parent_Data_Change_Request_vod__c: ' + dcr.Parent_Data_Change_Request_vod__c);
            
            childAccList = [select Id, Primary_vod__c, Copy_address_vod__c, External_Id_vod__c from Child_Account_vod__c where Parent_Account_vod__c = :parentId AND Child_Account_vod__c = :childId LIMIT 1];
            
            if(childAccList != null){                
                extId = childAccList.External_ID_vod__c;
            }
        }
        
        childAcc.OwnerId = dcrSettings.Integration_User_ID_AGN__c;
        childAcc.Copy_Address_vod__c = True;
        childAcc.External_ID_vod__c = extId;
        
        system.debug('## Inside createChildAccount(). childAcc.OwnerId: ' + childAcc.OwnerId);
        system.debug('## Inside createChildAccount(). childAcc.Copy_Address_vod__c: ' + childAcc.Copy_Address_vod__c);
        system.debug('## Inside createChildAccount(). childAcc.External_ID_vod__c: ' + childAcc.External_ID_vod__c);
        
        Database.UpsertResult ups = Database.upsert(childAcc, extIDField, true);
        
        system.debug('## Inside createChildAccount(). After uspert Child Account: ' + childAcc.Id);
        
        return childAcc.Id;
    }
    
    static void Create_Remove_ATL_TSF(Map<String,String> ATLmap, String Type){
        
        system.debug('## Inside createATLandTSF(). ATLmap : ' + ATLmap);
        
        Account_Territory_Loader_vod__c atl;
        TSF_vod__c tsf;
        
        if(Type == ADD){
            for(String accountId : ATLMap.keySet()){
                atl = new Account_Territory_Loader_vod__c(Account_vod__c = accountId, External_ID_vod__c = accountId, Territory_To_Add_vod__c = ATLMap.get(accountId));
                atltoInsert.add(atl);
                tsf = new TSF_vod__c(Name = ATLMap.get(accountId), Account_vod__c = accountId, Territory_vod__c = ATLMap.get(accountId), External_Id_vod__c = accountId + '__' + ATLMap.get(accountId), Target_Manager_SMB__c = true);
                tsfToInsert.add(tsf);
            }            
        }else if(Type == REMOVE){
            for(String accountId : ATLMap.keySet()){
                atl = [select Id, Territory_to_Drop_vod__c, External_ID_vod__c from Account_Territory_Loader_vod__c where External_ID_vod__c = :accountId LIMIT 1];
                atl.Territory_to_Drop_vod__c = ATLMap.get(accountId);
                atlToUpdate.add(atl);
                tsf = [select Id from TSF_vod__c where Account_vod__c = :accountId AND Territory_vod__c = :ATLMap.get(accountId) LIMIT 1];
                tsfToDelete.add(tsf);
            }            
        }        system.debug('## Leaving createATLandTSF(). atltoInsert : ' + atltoInsert + '      tsf: ' + tsfToInsert);
    }
    
    Static String getQuery(String objectName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        String query = 'SELECT';
        for(String fieldName : fieldMap.keySet()){
            query = query + ' ' + fieldName + ',';
        }
        if (query.subString(query.Length()-1,query.Length()) == ','){
            query = query.subString(0,query.Length()-1);
        }    
        query = query + ' FROM ' + objectName;
        return query;
    }    
}