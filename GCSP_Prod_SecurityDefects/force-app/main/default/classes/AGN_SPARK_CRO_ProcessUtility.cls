/**
 *
 * @Class Name: AGN_AMI_Utility_class
 * @Created Date: 
 * @Description: Calss for spark common methods
 * @Author: 
 * @History     :  
 */
public class AGN_SPARK_CRO_ProcessUtility {        
    
    public static Map<string, string> CroToAccountFieldMap = new Map<string, string>();
    public static Map<string, string> CraToAddressFieldMap = new Map<string, string>();
    public static Map<string, string> CraToBizAccountFieldMap = new Map<string, string>();
    public static Set<string> CroFieldsToBooleanify = new Set<string>();
    public static Set<string> CraFieldsToBooleanify = new Set<string>();
    public static String expMessg{get;set;}
    public static Account perAcc;
    public static List<Account> busAcc = new List<Account>();
    public static List<Child_Account_vod__c> childAcc = new List<Child_Account_vod__c>();
    public static List<Address_vod__c> address = new List<Address_vod__c>();
    
    public static void Process(Allergan_Customer_Registration_AGN__c record){
        
        
        if(record.Account_AGN__c != null){
            //--End Veeva_Account search 
            
            // -- Firstly, set up.
            
            Map<ID,ID> bizAccToCRARecordTypeMap = new Map<ID,ID>();
            Map<ID,ID> addrToCRARecordTypeMap = new Map<ID,ID>();
            fetchFieldMappings();
            
            // Set a save point just in case this fails - it should be all or nothing.
            System.SavePoint sp = Database.setSavepoint();
            
           try{  
                // -- Update the accounts 
                Account acc         = new Account();
                acc.Language_vod__c = record.Language_AGN__c;
                acc.Id = record.Account_AGN__c;               
                
                
                for (string croField : CroToAccountFieldMap.keySet()){ 
                   
                    
                    // Otherwise, transfer the value.
                    string accField = CroToAccountFieldMap.get(croField);
                    if (CroFieldsToBooleanify.contains(croField)){
                        object val = record.get(croField);
                        if (val != null){
                            string value = (string)(val);
                            
                            acc.put(accField, value.toUpperCase() == 'YES');
                        }
                    }
                    else{
                        
                        acc.put(accField, record.get(croField));
                    }
                }
                
                if (record.Online_Registration_AGN__c) acc.Customer_Managed_AGN__c = true; //set flag for online account management
                
                upsert acc;
                perAcc = acc;
                
                
                                
                Id CraNewRT = Schema.SObjectType.Allergan_Customer_Address_AGN__c.getRecordTypeInfosByName().get('New SPARK').getRecordTypeId();
                
                
                
                // Select out all the related CRA records.
                Set<string> addrFields = new Set<string>(CraToAddressFieldMap.keySet());
                addrFields.addAll(CraToBizAccountFieldMap.keySet());
                List<Allergan_Customer_Address_AGN__c> cras = Database.query('SELECT Bank_Name_AGN__c, Bank_Account_Number_AGN__c, IBAN_AGN__c, Sort_Code_AGN__c, SWIFT_BIC_AGN__c, Customer_Payment__c, Parent_AGN__r.Account_AGN__c, Parent_AGN__r.Specialty_Allergan_1_AGN__c, Parent_AGN__r.Business_Unit_AGN__c, Account_AGN__c, Parent_AGN__r.Country_Code_AGN__c,Parent_AGN__r.Customer_Group_AGN__c, Replacer_AGN__c, Parent_Address_AGN__r.Controlling_Address_vod__c, RecordTypeId, Bill_To_AGN__c, ' + string.join(new List<string>(addrFields), ', ') + 
                                                                             ' FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c = \'' + record.Id + '\'' + ' ORDER BY Sold_To_AGN__c DESC');
                
                //add this in query 
                for (Allergan_Customer_Address_AGN__c cra : cras){
                    if (cra.RecordTypeId == CraNewRT){  
                        /*For Account Insertion we need an owner, from the Custom setting we are getting the system admin id*/
                        
                        // Create the business account.
                        Account bizAcc = new Account();
                        if (record.Online_Registration_AGN__c ){
                            bizAcc.Customer_Managed_AGN__c      = record.Online_Registration_AGN__c ; //set flag for online account management
                            bizAcc.Customer_Category_AGN__c     = Record.Customer_Category_AGN__c;
                            bizAcc.Customer_Sub_Category_AGN__c = Record.Customer_Sub_Category_AGN__c;
                            bizAcc.Calling_Name_AGN__c          = cra.Company_Name_AGN__c;
                        }
                        
                                   
                        // //SG: commented out to allow null values to be updated on Account
                        for (string craField : CraToBizAccountFieldMap.keySet()){
                            // If our mappings do not contain a definition, then skip this.             
                            // Otherwise, transfer the value.
                            string accField = CraToBizAccountFieldMap.get(craField);
                            bizAcc.put(accField, cra.get(craField));
                        }
                        
                        
                        // Insert it.
                        
                       
                        
                        Id bizzRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital').getRecordTypeId();
                        bizAcc.recordtypeID = bizzRecordTypeId;
                        AGN_SPARK_Settings__c obj   = AGN_SPARK_Utility.SPARK_SETTINGS ;
                        bizAcc.OwnerId              = obj.SPARK_Admin_UserId__c;
                        bizAcc.AGN_SPARK_Account__c = True;
                        
                        if (record.Online_Registration_AGN__c) bizAcc.Customer_Managed_AGN__c = true; //set flag for online account management
                        
                        bizAcc.Country_vod__c =record.Country_AGN__c  ;
                        
                        insert bizAcc;
                        
                        
                        
                        //Contact Insertion
                        Contact con     =   new Contact();
                        con.LastName    =   record.Last_Name_AGN__c;
                        con.FirstName   =   record.First_Name_AGN__c;
                        con.Phone       =   record.Phone_AGN__c;
                        con.Email       =   record.Email_AGN__c;    
                        con.AccountId   =   bizAcc.Id;   
                        con.country_agn__c = record.Country_AGN__c; 
                        con.country_code_agn__c = record.Country_Code_AGN__c;   
                        if(Schema.SObjectType.Contact.isCreateable()){   //cc_AD
                            Insert con;
						}
                           
                                              
                        
                        //AccountContactRelation Insertion
                        AccountContactRelation accConR = new AccountContactRelation(); 
                        accConR.Accountid = record.Account_AGN__c;
                        accConR.Contactid = con.id;
                        insert accConR; 
                                                 
                        
                        bizAccToCRARecordTypeMap.put(bizAcc.Id, CraNewRT);
                        busAcc.add(bizAcc);
                        
                        // Create the address.
                        Address_vod__c addr = new Address_vod__c();
                        addr.Account_vod__c = bizAcc.Id;
                        addr.Customer_Managed_AGN__c = record.Online_Registration_AGN__c ; //set flag for online account management
                        
                        for (string craField : CraToAddressFieldMap.keySet()){
                            //SG: commented out to allow null values to be updated on Address
                            
                            // If our mappings do not contain a definition, then skip this.                          
                            // Otherwise, transfer the value.
                            string addrField = CraToAddressFieldMap.get(craField);
                            
                            if (CraFieldsToBooleanify.contains(craField)){
                                object val = record.get(craField);
                                if (val != null){
                                    string value = (string)(val);
                                    addr.put(addrField, value.toUpperCase() == 'YES');
                                }
                            }
                            else{
                                addr.put(addrField, cra.get(craField));
                            }
                        }
                        
                        addr.Primary_vod__c=True;
                        insert addr;
                        
                        addrToCRARecordTypeMap.put(addr.Id, CraNewRT);
                        address.add(addr);
                        
                        // Create the affiliation                    
                        Child_Account_vod__c paAffil = new Child_Account_vod__c();
                        paAffil.Child_Account_vod__c = acc.Id;
                        paAffil.Parent_Account_vod__c = bizAcc.Id;
                        
                        paAffil.Copy_Address_vod__c = true;
                        if (record.Online_Registration_AGN__c) {
                            paAffil.Customer_Managed_AGN__c = true; //set flag for online account management
                            if (cra.Sold_To_AGN__c) paAffil.Network_Primary_vod__c = true;
                            else if((Boolean)AGN_SPARK_User_Setting__c.getValues(cra.Parent_AGN__r.Country_Code_AGN__c).get('Enable_HCO_Affiliation__c')) { //insert hco affiliations
                                Child_Account_vod__c baAffil = new Child_Account_vod__c();
                                baAffil.Child_Account_vod__c = bizAcc.Id;
                                
                                childAcc.add(baAffil);
                            }
                        }
                        childAcc.add(paAffil);
                    }
                }
                
                //insert affiliations
                
                insert childAcc;
                
                //DCR Creation Start
                DCR_Config_Settings_AGN__c agnDCRSettings = new DCR_Config_Settings_AGN__c();
                agnDCRSettings = DCR_Config_Settings_AGN__c.getInstance();
                if((Boolean)AGN_SPARK_User_Setting__c.getValues(record.Country_Code_AGN__c).get('Enable_Automated_New_DCR__c')){                        
                    if(perAcc != null && !busAcc.isEmpty() && !address.isEmpty()){
                        if(agnDCRSettings.Veeva_Data_Change_Request_Countries_AGN__c.contains(record.Country_Code_AGN__c)){
                            
                            AGN_CR_CreateAutoDcrUtils.CreateDCR(Json.serialize(perAcc),Json.serialize(busAcc),Json.serialize(address),Json.serialize(childAcc),Json.serialize(record),Json.serialize(bizAccToCRARecordTypeMap),Json.serialize(addrToCRARecordTypeMap));
                        }else{
                            system.debug('callling@future');
                            callFutureMethod(Json.serialize(perAcc),Json.serialize(busAcc),Json.serialize(address),Json.serialize(childAcc),Json.serialize(record),Json.serialize(bizAccToCRARecordTypeMap),Json.serialize(addrToCRARecordTypeMap));
                        }
                    }
                }
                //DCR Creation End
            }
            catch(DmlException ex){
                System.debug('DML operation has failed '+ ex);
                database.rollback(sp);
                if (ex.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
                    if (ex.getDmlMessage(0).contains('External_ID2_AGN__c'))
                        system.debug(ex);
                                   
                }
                else{
                    throw ex;
                    
                }
            }
            catch(Exception ex){
                // If we encounter an error, roll it back.
                System.debug('Generic exception has occurred '+ ex);
                database.rollback(sp);
                throw ex;
            }
        }
    }
    //DCR Creation Start
    
    @future
    public static void callFutureMethod(String jAcc, String jBusAcc, String jAddr, String jChildAcc, String jCusRec, String jBusAccMap, String jAddrMap){
        AGN_CR_CreateAutoDcrUtils.CreateDCR(jAcc,jBusAcc,jAddr,jChildAcc,jCusRec,jBusAccMap,jAddrMap);
    }    
    
    //DCR Creation End
    public static Map<string, RecordType> fetchRecordTypes(string sobjecttype){
        Map<string, RecordType> output = new Map<string, RecordType>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :sobjecttype]){
            output.put(rt.DeveloperName, rt);
        }
        return output;
    }
    
    public static void fetchFieldMappings(){
        // Pull out the CRO->Account mappings...
        List<SPARK_CR_to_Account_Mapping_AGN__mdt> crmapping = [SELECT Customer_Registration_Field_AGN__c, Account_Field_Name_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM SPARK_CR_to_Account_Mapping_AGN__mdt];
        for (SPARK_CR_to_Account_Mapping_AGN__mdt mapping : crmapping){
            
            CroToAccountFieldMap.put(mapping.Customer_Registration_Field_AGN__c, mapping.Account_Field_Name_AGN__c);
            
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true){
                CroFieldsToBooleanify.add(mapping.Customer_Registration_Field_AGN__c);
            }
        }
        
        // Pull out the CRA->Address mappings...
        List<SPARK_CRA_to_Address_Mapping_AGN__mdt> cramapping = [SELECT CRA_Field_AGN__c, Address_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM SPARK_CRA_to_Address_Mapping_AGN__mdt];
        for (SPARK_CRA_to_Address_Mapping_AGN__mdt mapping : cramapping){
            CraToAddressFieldMap.put(mapping.CRA_Field_AGN__c, mapping.Address_Field_AGN__c);
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true){
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
        
        // Pull out the CRA->BizAccount mappings...
        List<SPARK_CRA_to_Busines_Account_Mapping_AGN__mdt> crabamapping = [SELECT CRA_Field_AGN__c, Account_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM SPARK_CRA_to_Busines_Account_Mapping_AGN__mdt ];
        for (SPARK_CRA_to_Busines_Account_Mapping_AGN__mdt    mapping : crabamapping){
            CraToBizAccountFieldMap.put(mapping.CRA_Field_AGN__c, mapping.Account_Field_AGN__c);
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true){
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
    }
    
    public class DmlDuplicateException extends Exception {}
    
}