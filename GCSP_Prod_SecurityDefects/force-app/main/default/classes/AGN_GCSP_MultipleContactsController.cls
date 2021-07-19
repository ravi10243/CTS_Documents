/**
 * @description       : Show the list of available contacts and Save the affliations between Contacts and Address records.
 * @author            : GCSP Core Plus Dev Team 
 * @group             : 
 * @last modified on  : 04-13-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   02-25-2021   GCSP Core Plus Dev Team       Initial Version
**/
public without sharing class AGN_GCSP_MultipleContactsController {
    
    @AuraEnabled
    public Allergan_Customer_Registration_AGN__c newRegistration {get;set;}
    
    @AuraEnabled
    public Case newCase {get;set;}
    
    @AuraEnabled
    public list<Allergan_Customer_Address_AGN__c> addressList {get;set;}
    
    @AuraEnabled
    public list<Allergan_Customer_Contact_AGN__c> acrContactList {get;set;}
    
    @AuraEnabled
    public Map<String,set<String>> customerDetailConMap {get;set;}
    
    @AuraEnabled
    public Map<String,set<String>> conCustomerDetailMap {get;set;}
    
    @AuraEnabled
    public addressCntwrapper addcntwrap {get;set;}
    
    @AuraEnabled
    public static AGN_GCSP_MultipleContactsController doInit(string caseId, string sapId){
        
        AGN_GCSP_MultipleContactsController mccObj = new AGN_GCSP_MultipleContactsController();
        
        list<Contact> conList = new List<Contact>();
        
        mccObj.addcntwrap = new addressCntwrapper();        
        mccObj.newRegistration = new Allergan_Customer_Registration_AGN__c();
        mccObj.newCase = new Case();
        mccObj.addressList = new list<Allergan_Customer_Address_AGN__c>();
        mccObj.acrContactList = new list<Allergan_Customer_Contact_AGN__c>();       
        mccObj.customerDetailConMap = new Map<String,set<String>>();
        mccObj.conCustomerDetailMap = new Map<String,set<String>>();
        mccObj.newCase = AGN_GCSP_CustomerRegStep2Controller.getCaseDetails(caseId);
        mccObj.newRegistration = AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS(caseId);
        mccObj.addressList = getCustomerAddressDetails(mccObj.newRegistration.Id);
        
        system.debug('mccObj.addressList:::::::'+mccObj.addressList);
        
        Map<Id, Allergan_Customer_Contact_AGN__c> acrConMap = new Map<Id, Allergan_Customer_Contact_AGN__c>();
        Map<Id, Allergan_Customer_Contact_AGN__c> acrConMap1 = new Map<Id, Allergan_Customer_Contact_AGN__c>();
        acrConMap1 = getcustomerContactDetails(mccObj.newRegistration.Id);
        
        if(String.isNotEmpty(sapId)){       
            
            //list<Allergan_Customer_Contact_AGN__c> acrConList = new list<Allergan_Customer_Contact_AGN__c>();
            for(Allergan_Customer_Contact_AGN__c acrCon : getContactsList(sapId)){                
                if(acrConMap1.containskey(acrCon.Contact_AGN__c)){
                    acrCon.Id =  acrConMap1.get(acrCon.Contact_AGN__c)?.Id;
                    acrCon.Enable_Portal_User_AGN__c = acrConMap1.get(acrCon.Contact_AGN__c)?.Enable_Portal_User_AGN__c;
                    acrCon.Primary_Contact_AGN__c = acrConMap1.get(acrCon.Contact_AGN__c)?.Primary_Contact_AGN__c;
                    acrCon.Allergan_Direct_Access_Requested_AGN__c = acrConMap1.get(acrCon.Contact_AGN__c)?.Allergan_Direct_Access_Requested_AGN__c;
                    acrCon.Primary_Contact_AGN__c = acrConMap1.get(acrCon.Contact_AGN__c)?.Primary_Contact_AGN__c;
                    acrCon.Contact_Person_Type_AGN__c = acrConMap1.get(acrCon.Contact_AGN__c)?.Contact_Person_Type_AGN__c;                    
                    acrConMap.put(acrCon.Id, acrCon);
                }
                else{                   
                    acrConMap.put(acrCon.Contact_AGN__c, acrCon);
                }
            }            
            
            for(Contact_Custmer_Detail_Relation_AGN__c ccdr : [SELECT Id, Name, 
                                                               Contact_AGN__c, 
                                                               Customer_Detail_AGN__c,
                                                               Customer_Detail_AGN__r.Country_Code_AGN__c,
                                                               Customer_Detail_AGN__r.SAP_Country_Code_AGN__c,
                                                               Customer_Detail_AGN__r.External_ID_AGN__c
                                                               FROM Contact_Custmer_Detail_Relation_AGN__c
                                                               WHERE (Customer_Detail_AGN__r.External_ID_AGN__c =: sapId  OR Customer_Detail_AGN__r.Parent_SAP_Id_AGN__c =: sapId)
                                                               AND Is_Active_AGN__c = true
                                                              ]){  
                                                                  set<String> conIdList = new set<String>();
                                                                    if(mccObj.conCustomerDetailMap.containsKey(ccdr.Customer_Detail_AGN__r.External_ID_AGN__c)){
                                                                        conIdList.addAll(mccObj.customerDetailConMap.get(ccdr.Customer_Detail_AGN__r.External_ID_AGN__c));
                                                                        conIdList.add(ccdr.Contact_AGN__c);
                                                                        mccObj.customerDetailConMap.put(ccdr.Customer_Detail_AGN__r.External_ID_AGN__c,conIdList);
                                                                    }else{
                                                                        conIdList.add(ccdr.Contact_AGN__c);
                                                                        mccObj.customerDetailConMap.put(ccdr.Customer_Detail_AGN__r.External_ID_AGN__c,conIdList); 
                                                                    }
                                                                                                                          
                                                                    set<String> sapIdList = new set<String>();
                                                                    if(mccObj.conCustomerDetailMap.containsKey(ccdr.Contact_AGN__c)){
                                                                        sapIdList.addAll(mccObj.conCustomerDetailMap.get(ccdr.Contact_AGN__c));
                                                                        sapIdList.add(ccdr.Customer_Detail_AGN__r.External_ID_AGN__c);
                                                                        mccObj.conCustomerDetailMap.put(ccdr.Contact_AGN__c , sapIdList);
                                                                    }else{
                                                                        sapIdList.add(ccdr.Customer_Detail_AGN__r.External_ID_AGN__c);
                                                                        mccObj.conCustomerDetailMap.put(ccdr.Contact_AGN__c , sapIdList);			
                                                                    }
                                                              } 
            
        }else{
            for(Allergan_Customer_Contact_AGN__c con : acrConMap1.values()){
                acrConMap.put(con.Id, con);            }  
        }
        
        mccObj.acrContactList = acrConMap.values();
        
        return mccObj;
    }    
        
    public static Map<Id, Allergan_Customer_Contact_AGN__c> getcustomerContactDetails(String crRecordId) {
        Map<Id, Allergan_Customer_Contact_AGN__c> acrContactMap = new Map<Id, Allergan_Customer_Contact_AGN__c>();
        String regId = String.escapeSingleQuotes(crRecordId); 
        String SobjectApiName = 'Allergan_Customer_Contact_AGN__c';
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
        query = 'select '+ commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Parent_AGN__c ='+'\''+ regId + '\'' + ' ORDER BY createdDate DESC';
        
        
        for(Allergan_Customer_Contact_AGN__c acrCon : Database.query(query)){
            
            if(string.isNotEmpty(acrCon.Contact_AGN__c)){
                acrContactMap.put(acrCon.Contact_AGN__c, acrCon);
            }
            else{
                acrContactMap.put(acrCon.Parent_AGN__c, acrCon);
            }
            
        }
        
        return acrContactMap;
    }
    
    public static list<Allergan_Customer_Contact_AGN__c> getContactsList(String sapId){
        String externalId = String.escapeSingleQuotes(sapId);
        Map<Id, Contact_Custmer_Detail_Relation_AGN__c> conMap = new Map<Id, Contact_Custmer_Detail_Relation_AGN__c>();
        for(Contact_Custmer_Detail_Relation_AGN__c ccdr : [SELECT Id, Name, 
                                                           Contact_AGN__c, 
                                                           Customer_Detail_AGN__c,
                                                           Customer_Detail_AGN__r.Country_Code_AGN__c,
                                                           Customer_Detail_AGN__r.SAP_Country_Code_AGN__c,
                                                           Customer_Detail_AGN__r.External_ID_AGN__c
                                                           FROM Contact_Custmer_Detail_Relation_AGN__c
                                                           WHERE Customer_Detail_AGN__r.External_ID_AGN__c =: externalId 
                                                           OR Customer_Detail_AGN__r.Parent_SAP_Id_AGN__c =: externalId
                                                          ]){
                                                              conMap.put(ccdr.Contact_AGN__c, ccdr);
                                                          }       
        
        list<Allergan_Customer_Contact_AGN__c> acrConList = new list<Allergan_Customer_Contact_AGN__c>();
        
        
        for(Contact primaryContact : [SELECT Id, FirstName, LastName, Email, Salutation, Phone, 
                                      Is_Primary_Contact_AGN__c, Has_Allergan_Direct_Access_AGN__c,
                                      SAP_Contact_Person_Type_AGN__c,
                                      Okta_Id_AGN__c FROM Contact WHERE ID IN: conMap.keyset()]){
                                          Allergan_Customer_Contact_AGN__c crContact = new Allergan_Customer_Contact_AGN__c();
                                          string countryCode = conMap.get(primaryContact.Id)?.Customer_Detail_AGN__r.SAP_Country_Code_AGN__c;
                                          String countryCodeVal = conMap.get(primaryContact.Id)?.Customer_Detail_AGN__r.Country_Code_AGN__c;
                                          if(String.isEmpty(countryCode)||countryCodeVal.equalsIgnoreCase('IT') || countryCode.equalsIgnoreCase('IE')){
                                              countryCode = conMap.get(primaryContact.Id)?.Customer_Detail_AGN__r.Country_Code_AGN__c;
                                          }
                                          
                                          crContact.Parent_AGN__c = new Allergan_Customer_Registration_AGN__c()?.Id; 
                                          crContact.Contact_AGN__c = primaryContact.Id;
                                          crContact.First_Name_AGN__c = primaryContact.FirstName;
                                          crContact.Last_Name_AGN__c  = primaryContact.LastName;
                                          crContact.Email_AGN__c =  primaryContact.Email;
                                          crContact.Salutation_AGN__c = primaryContact.Salutation;
                                          crContact.Phone_AGN__c = primaryContact.Phone;
                                          crContact.Primary_Contact_AGN__c = primaryContact.Is_Primary_Contact_AGN__c;
                                          crContact.Enable_Portal_User_AGN__c = String.isNotEmpty(primaryContact.Okta_Id_AGN__c)? true : false;
                                          crContact.Allergan_Direct_Access_Requested_AGN__c = primaryContact.Has_Allergan_Direct_Access_AGN__c;
                                          crContact.Contact_Person_Type_AGN__c = primaryContact.SAP_Contact_Person_Type_AGN__c;
                                         // system.debug('gcspdebug   ' + AGN_GCSP_Settings__c.Enable_HCP_AGN__c);
                                        //  system.debug('gcspdebug   ' + AGN_GCSP_Settings__c.getValues(countryCode));
                                          if((Boolean)AGN_GCSP_Settings__c.getValues(countryCode).get('Enable_HCP_AGN__c') != null){
                                              crContact.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(countryCode).get('Enable_HCP_AGN__c');
                                          }else{
                                              crContact.Enable_HCP_AGN__c = false;
                                          }
                                          
                                          acrConList.add(crContact);
                                      }
        
        return acrConList;
        
    }
    
    public static List<Allergan_Customer_Address_AGN__c> getCustomerAddressDetails(String custRegId) {
        
        //Allergan_Customer_Registration_AGN__c custReg = getCustomerRegDetails();
        String RegId = String.escapeSingleQuotes(custRegId); 
        String SobjectApiName = 'Allergan_Customer_Address_AGN__c';
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
        query = 'select '+ commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Request_for_Deactivation_AGN__c = false and Parent_AGN__c ='+'\''+ RegId + '\'' + ' ORDER BY createdDate DESC';
        
        List<Allergan_Customer_Address_AGN__c> custAdd = Database.query(query); 
        
        
        return custAdd.isEmpty() ? new list<Allergan_Customer_Address_AGN__c>() : custAdd ;
    }
    
    @AuraEnabled
    Public static Case saveAcrContactsAffiliation(String caseId, String contactAddMap,
                                                    list<Allergan_Customer_Contact_AGN__c> customerConList,
                                                    list<Allergan_Customer_Address_AGN__c> addList,
                                                    Boolean isEscalateQa,
                                                    String priority
                                                 )
    {
        // list<Allergan_Address_Contact_Mapping_agn__c> addConList,
        system.debug('@@@caseId::::'+caseId);
        system.debug('@@@contactAddMap::::'+contactAddMap);
        system.debug('@@@customerConList::::'+customerConList);
        system.debug('@@@addList::::'+addList);
        Allergan_Customer_Registration_AGN__c custReg = AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS(caseId);
        List<Allergan_Customer_Address_AGN__c> addressList = AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetails(custReg.Id);
        list<addressCntwrapper> wrapList = (list<addressCntwrapper>)JSON.deserialize(contactAddMap, List<addressCntwrapper>.class);
        Map<String, Allergan_Customer_Address_AGN__c> addMap = new  Map<String, Allergan_Customer_Address_AGN__c>();
        Map<String, list<Allergan_Customer_Contact_AGN__c>> addContMap = new Map<String, list<Allergan_Customer_Contact_AGN__c>>();
        system.debug('map List>>>>>>>'+wrapList);
        
        String countryCode = custReg.SAP_Country_Code_AGN__c;
        if(String.isEmpty(countryCode) || countryCode == 'IE'){
            countryCode = custReg.Country_Code_AGN__c;
        }
        
        list<Allergan_Customer_Contact_AGN__c> custList = new list<Allergan_Customer_Contact_AGN__c>();
        if(!customerConList.isEmpty()){
            
            Map<String, Allergan_Customer_Contact_AGN__c> acrConMap = new Map<String, Allergan_Customer_Contact_AGN__c>();
            Map<String, Allergan_Customer_Contact_AGN__c> acrIdConMap = new Map<String, Allergan_Customer_Contact_AGN__c>();
            for(Allergan_Customer_Contact_AGN__c acrCon:customerConList){
                if(string.isEmpty(acrCon.Id)){
                    String acrConString = acrCon.First_Name_AGN__c+acrCon.Last_Name_AGN__c+acrCon.Phone_AGN__c+acrCon.Email_AGN__c+acrCon.Contact_Person_Type_AGN__c+acrCon.Contact_AGN__c;
            		if(!acrConMap.containsKey(acrConString)){
                        acrCon.Parent_AGN__c = custReg.Id;                        
                        if((Boolean)AGN_GCSP_Settings__c.getValues(countryCode).get('Enable_HCP_AGN__c') != null){
                            acrCon.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(countryCode).get('Enable_HCP_AGN__c');
                        }else{
                            acrCon.Enable_HCP_AGN__c = false;
                        }
                        if(acrCon.Allergan_Direct_Access_Requested_AGN__c || acrCon.Enable_Portal_User_AGN__c){
                            acrCon.Enable_Portal_User_AGN__c = true;
                            acrCon.Allergan_Direct_Access_Requested_AGN__c = true;
                        }
                        custList.add(acrCon);  
                        acrConMap.put(acrConString, acrCon);
                    }
                    
                }else{
                    if(!acrIdConMap.containsKey(acrCon.Id)){
                        
                        if((Boolean)AGN_GCSP_Settings__c.getValues(countryCode).get('Enable_HCP_AGN__c') != null){
                            acrCon.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(countryCode).get('Enable_HCP_AGN__c');
                        }else{
                            acrCon.Enable_HCP_AGN__c = false;
                        }
                        if(acrCon.Allergan_Direct_Access_Requested_AGN__c || acrCon.Enable_Portal_User_AGN__c){
                            acrCon.Enable_Portal_User_AGN__c = true;
                            acrCon.Allergan_Direct_Access_Requested_AGN__c = true;
                        }
                        
                        custList.add(acrCon);
                        acrIdConMap.put(acrCon.Id, acrCon);
                    }
                    
                }           
            }
            
            System.debug('@@@@@@@@custList::::::::: '+custList);
            if(!custList.isEmpty()){
                String obj = 'Allergan_Customer_Contact_AGN__c';
                SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                AGN_FLSCheck.check(custList,objType,'UPSERT');
                upsert custList;
            }             
        } 
        Map<String, Allergan_Customer_Address_AGN__c>  addRecordsMap = new   Map<String, Allergan_Customer_Address_AGN__c>();
        Map<String, Allergan_Customer_Address_AGN__c>  addUpsertRecordsMap = new   Map<String, Allergan_Customer_Address_AGN__c>();
        list<Allergan_Customer_Address_AGN__c> addRecordsList = new list<Allergan_Customer_Address_AGN__c>();
        for(Allergan_Customer_Address_AGN__c add : addList){
            if(String.isEmpty(add.Id)){
                    addRecordsMap.put(add.SAP_ID_AGN__c, add);
                }else{
                    addRecordsMap.put(add.Id, add);
                }
            
        }
        for(addressCntwrapper addwrap : wrapList){           
           
            if(addRecordsMap.containskey(addwrap.key) && !addUpsertRecordsMap.containskey(addwrap.key)){
            
                addUpsertRecordsMap.put(addwrap.key, addRecordsMap.get(addwrap.key));
            
            }
        } 
                                                           
        for(Allergan_Customer_Address_AGN__c add : addUpsertRecordsMap.values()){//addList
            //--------
            if(String.isEmpty(add.Tax_Classification_AGN__c)){  
                        if(custReg.Country_Code_AGN__c == 'IT'){
                            if(add.Country_AGN__c == 'Italy' ){
                                add.Tax_Classification_AGN__c = '9';
                            }else{
                                add.Tax_Classification_AGN__c = '0';
                            }
                        }else if(!String.isEmpty(custReg.Tax_Exempted_AGN__c)){
                            add.Tax_Classification_AGN__c = custReg.Tax_Exempted_AGN__c;
                        }
                        else{
                            add.Tax_Classification_AGN__c = '9';
                        }
                    }
           //--------- 
            if(String.isEmpty(add.Parent_AGN__c)){
                add.Parent_AGN__c = custReg.Id; 
            }
            
                if(String.isEmpty(add.Id)){
                    addMap.put(add.SAP_ID_AGN__c, add);
                }else{
                    addMap.put(add.Id, add);
                }
            
        }
        if(!addMap.isEmpty()){                                                           
            upsert addMap.values();
        }
        system.debug('@@@addMap::::::  '+addMap);
       
        Map<String, Allergan_Customer_Contact_AGN__c> acContactMap = new Map<String, Allergan_Customer_Contact_AGN__c>();
        Map<String, Set<String>> addAcContactMap = new Map<String, Set<String>>();
        
        for(addressCntwrapper addwrap : wrapList){  
            Allergan_Customer_Contact_AGN__c acrCon = addwrap.acrConList;
            String acrConString = acrCon.First_Name_AGN__c+acrCon.Last_Name_AGN__c+acrCon.Phone_AGN__c+acrCon.Email_AGN__c+acrCon.Contact_Person_Type_AGN__c+acrCon.Contact_AGN__c;
            acContactMap.put(acrConString, addwrap.acrConList);
            Set<String> acrConStringSet = new Set<String>();            
            if(addAcContactMap.containsKey(addMap.get(addwrap.key)?.Id)){
                acrConStringSet.addAll(addAcContactMap.get(addMap.get(addwrap.key)?.Id));
                acrConStringSet.add(acrConString);
                addAcContactMap.put(addMap.get(addwrap.key)?.Id, acrConStringSet); 
            }else{
                acrConStringSet.add(acrConString);
                addAcContactMap.put(addMap.get(addwrap.key)?.Id, acrConStringSet); 
            }            
        }    
        system.debug('acContactMap:::::::'+acContactMap);
        system.debug('addAcContactMap:::::::'+addAcContactMap);
        
        Map<String, Allergan_Customer_Contact_AGN__c> listaccMap = new Map<String, Allergan_Customer_Contact_AGN__c>();        
        
       for(Allergan_Customer_Contact_AGN__c acrCon : acContactMap.values()){ 
                String acrConString = acrCon.First_Name_AGN__c+acrCon.Last_Name_AGN__c+acrCon.Phone_AGN__c+acrCon.Email_AGN__c+acrCon.Contact_Person_Type_AGN__c+acrCon.Contact_AGN__c;
                
                if((Boolean)AGN_GCSP_Settings__c.getValues(countryCode).get('Enable_HCP_AGN__c') != null){
                    acrCon.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(countryCode).get('Enable_HCP_AGN__c');
                }else{
                    acrCon.Enable_HCP_AGN__c = false;
                }
                if(acrCon.Allergan_Direct_Access_Requested_AGN__c || acrCon.Enable_Portal_User_AGN__c){
                    acrCon.Enable_Portal_User_AGN__c = true;
                    acrCon.Allergan_Direct_Access_Requested_AGN__c = true;
                }
                if(String.isEmpty(acrCon.Parent_AGN__c)){
                    acrCon.Parent_AGN__c = custReg.Id;
                }
                if(!listaccMap.containsKey(acrConString)){
                  listaccMap.put(acrConString, acrCon);   
                }                                              
            }
        if(!listaccMap.isEmpty()){
            upsert listaccMap.values();
        	system.debug('listaccMap::::'+listaccMap);        
        	custList.addAll(listaccMap.values());
        }
        
        Map<String, Allergan_Address_Contact_Mapping_agn__c> acmMap = new Map<String, Allergan_Address_Contact_Mapping_agn__c>();
        for(String key : addAcContactMap.keyset()){ 
                for(String acConKey : addAcContactMap.get(key)){
                    String accAddId = listaccMap.get(acConKey).Id+'-'+key; 
                    if(String.isNotEmpty(listaccMap.get(acConKey).Id) && String.isNotEmpty(key)){
                       Allergan_Address_Contact_Mapping_agn__c acm = new Allergan_Address_Contact_Mapping_agn__c();
                        acm.Allergan_Customer_Address_agn__c = key;
                        acm.Allergan_Customer_Contact_agn__c = listaccMap.get(acConKey).Id;
                        acm.Allergan_Customer_Registration_agn__c = custReg.Id;
                        if(!acmMap.containsKey(accAddId)){
                            acmMap.put(accAddId, acm);
                        } 
                    }
                }
         }
        system.debug('@@@acmMap::::::: '+acmMap);
        //Map<String, Allergan_Address_Contact_Mapping_agn__c> accMap = new Map<String, Allergan_Address_Contact_Mapping_agn__c>();
        for(Allergan_Customer_Address_AGN__c add : addressList){
            if(add.Sold_To_AGN__c){
                for(Allergan_Customer_Contact_AGN__c con :custList){   
                   String accAddId = con.Id+'-'+add.Id;
                    if(!acmMap.containsKey(accAddId)) {
                        if(String.isNotEmpty(con.Id) && String.isNotEmpty(add.Id)){ 
                            Allergan_Address_Contact_Mapping_agn__c acm = new Allergan_Address_Contact_Mapping_agn__c();
                            acm.Allergan_Customer_Address_agn__c = add.Id;
                            acm.Allergan_Customer_Contact_agn__c = con.Id;
                            acm.Allergan_Customer_Registration_agn__c = custReg.Id;
                            //acmList.add(acm); 
                            acmMap.put(accAddId, acm);
                        }
                    }
                }
                break;
            }
            
        }
         system.debug('@@@acmMap::Include SoldTo:::::: '+acmMap);
        List<Allergan_Address_Contact_Mapping_agn__c> mappingList = new List<Allergan_Address_Contact_Mapping_agn__c>();
        Map<String, Allergan_Address_Contact_Mapping_agn__c> newMapping = new Map<String, Allergan_Address_Contact_Mapping_agn__c>();
       
        for(Allergan_Address_Contact_Mapping_agn__c aacm : [Select Id, Allergan_Customer_Address_agn__c, Allergan_Customer_Contact_agn__c from Allergan_Address_Contact_Mapping_agn__c Where Allergan_Customer_Registration_agn__c = :custReg.Id]){
           string existingRecId = aacm.Allergan_Customer_Contact_agn__c+'-'+aacm.Allergan_Customer_Address_agn__c;
            newMapping.put(existingRecId, aacm); 
        }
        system.debug('newMapping::::::::'+newMapping);  
        system.debug('newMappingSize::::::::'+newMapping.size());
        if(!acmMap.isEmpty()){
            for(Allergan_Address_Contact_Mapping_agn__c objOld : acmMap.values()){
                string acmValId = objOld.Allergan_Customer_Contact_agn__c+'-'+objOld.Allergan_Customer_Address_agn__c;
                if(!newMapping.containsKey(acmValId)){
                    mappingList.add(objOld);
                }
            }            
        }
        system.debug('mappingList:::'+mappingList);
        system.debug('mappingListSize:::'+mappingList.size());
        if(!mappingList.isEmpty()){
            String obj = 'Allergan_Address_Contact_Mapping_agn__c';
            SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
            AGN_FLSCheck.check(mappingList,objType,'UPSERT');
            upsert mappingList;
        }
        
        if(String.isNotEmpty(custReg.Id)){
            Allergan_Customer_Registration_AGN__c acrReg = new Allergan_Customer_Registration_AGN__c();
            acrReg.Id = custReg.Id;
            for(Allergan_Customer_Contact_AGN__c con : [SELECT Id, First_Name_AGN__c, Last_Name_AGN__c, Email_AGN__c, Phone_AGN__c, 
                                                       Contact_Person_Type_AGN__c, Allergan_Direct_Access_Requested_AGN__c, Primary_Contact_AGN__c 
                                                        FROM Allergan_Customer_Contact_AGN__c WHERE Parent_AGN__c =:String.escapeSingleQuotes(custReg.Id) 
                                                       AND Primary_Contact_AGN__c=true]){ 
                
                    acrReg.First_Name_AGN__c = con.First_Name_AGN__c;
                    acrReg.Last_Name_AGN__c = con.Last_Name_AGN__c;
                    acrReg.Email_AGN__c = con.Email_AGN__c;
                    acrReg.Phone_AGN__c = con.Phone_AGN__c;
                    acrReg.Contact_Person_Type_AGN__c = con.Contact_Person_Type_AGN__c;
                    acrReg.Allergan_Direct_Access_Requested_AGN__c = con.Allergan_Direct_Access_Requested_AGN__c;
              
            }
            acrReg.Online_Registration_Step_AGN__c = '5';
            
            List<Allergan_Customer_Registration_AGN__c> tempCRAList = new List<Allergan_Customer_Registration_AGN__c>();
            tempCRAList.add(acrReg);              
            String objCustomerAdd = 'Allergan_Customer_Registration_AGN__c';
            SObjectType objCRAType = ((SObject)(Type.forName('Schema.'+objCustomerAdd).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCRAList,objCRAType,'UPSERT');
            upsert acrReg;
        }
        
        Case caseVal = new Case(Id = caseId, Priority=priority, Escalated_to_QA_AGN__c =isEscalateQa );
        upsert caseVal;
        
        
        AGN_Case_Next.gotoNextStep(caseId);
        return [SELECT Id, CaseNumber FROM Case WHERE Id =: caseId LIMIT 1];
    }
    
    
    public class addressCntwrapper{        
        public string  key;        
        public Allergan_Customer_Contact_AGN__c acrConList; 
        // @AuraEnabled public Map<String, List<Allergan_Customer_Contact_AGN__c>> conAddMapWrap {get;set;}
    }
    
    @AuraEnabled
    public static DocumentDetails getUpdateAttachments(Id parentRecId, String stepNo, String source){ //, string fieldName, string objectname, string creteriaValue
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        System.debug('parentRecId in getAllAttachments : '+parentRecId);
        set<string> documentDescSet= new set<string>();
        list<Attachment>listOfSavedAttachments = new list<Attachment>();
        list<AttachmentWrapper> newAttachments = new list<AttachmentWrapper>();
        DocumentDetails attWithDetails = new DocumentDetails();
        
        List<Allergan_Customer_Address_AGN__c> addressDetailsList = AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetails(parentRecId);
        
        Allergan_Customer_Registration_AGN__c parentRecordDetails = AGN_GCSP_CustomerRegStep2Controller.getCustomerRegistrationDetailsTemp(parentRecId);  
        
        string documentListAdditional;
        String documentListWithoutAdditional='';
        string documentList='';
        List<string> documentNames = new List<string> ();
        string countryCode = parentRecordDetails.SAP_Country_Code_AGN__c;
        if(String.isEmpty(countryCode)){
            countryCode = parentRecordDetails.Country_Code_AGN__c;
        }
         
        
        Map<String,Set<String>> fieldDocMap = new Map<String,Set<String>>();
        List<AGN_GCSP_Document__mdt> docMetaData = new List<AGN_GCSP_Document__mdt>();
        docMetaData = getUploadDocumentListForUpdate(countryCode, parentRecordDetails.Customer_Group_AGN__c, stepNo, source); //, creteriaValue, fieldName, objectname,
        Set<string> documentReturnSet = new Set<string> ();
        system.debug('docMetaData>>>>'+docMetaData);
        for(AGN_GCSP_Document__mdt attObj : docMetaData){
            
            String key = attObj.AGN_Country__c+'_'+attObj.AGN_Field_API_Name__c+'_'+attObj.Step_No_AGN__c;            
            Set<string> documentNameSet = new Set<string> ();
            string userLocal = userinfo.getLocale();
			String userLang = userinfo.getLanguage();            
            Boolean isEnLang = (String.isNotEmpty(source) && source.equalsIgnoreCase('oam') && (!userLocal.equalsIgnoreCase('en') || !userLang.equalsIgnoreCase('en'))) ? false : true;
            String translatedDocuments = attObj.Document_Translated_Name_AGN__c;
            String [] str = isEnLang ? attObj.AGN_OAMDocument_List__c.split(';') : String.isEmpty(translatedDocuments) ? attObj.AGN_OAMDocument_List__c.split(';') : translatedDocuments.split(';');
            system.debug('str>>>>'+str);
            for (integer i = 0; i < str.size(); i++){              
                documentNames.add(str[i]);
                documentNameSet.add(str[i]);
                documentReturnSet.add(str[i]);
            }
           
        }
        
        for (String str : documentReturnSet){
            newAttachments.add(new AttachmentWrapper(str, new Attachment(Description = str)));
            //documentDescSet.add(documentReturnSet[i]);
        }
        System.debug('newAttachments>>>>'+newAttachments);
        listOfSavedAttachments = [SELECT  Id,
                                  Name,
                                  Description,
                                  Body,
                                  BodyLength,
                                  ContentType,
                                  OwnerId,
                                  ParentId 
                                  FROM Attachment                                                         
                                  WHERE ParentId =:parentRecId ] ;
        
        if(listOfSavedAttachments!=null){
            for (AttachmentWrapper aw:newAttachments ){
                for(Attachment att :listOfSavedAttachments){
                    
                    if(att.Description.Trim()==aw.file.Description.Trim())
                    {    
                        aw.file.Id=att.Id;
                        aw.file.Name=att.Name;
                    }
                }
                if (aw.file.Description.containsIgnoreCase('(Required)')){
                    aw.label = aw.file.Description.removeEndIgnoreCase('(Required)');
                    aw.isRequired= true;
                    if(string.isEmpty(aw.file.Id)){
                        attWithDetails.missingAttachment= true;
                    }
                }
                
                /* for downLoad link  */
                if (aw.file.Description.containsIgnoreCase('(Download)')){
                    if(aw.file.Description.containsIgnoreCase('(Required)')){
                        aw.label = aw.file.Description.removeEndIgnoreCase('(Required)(Download)');
                    }else{
                        aw.label = aw.file.Description.removeEndIgnoreCase('(Download)');
                    }    
                    
                    String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(parentRecordDetails.Country_Code_AGN__c)?.get('Community_Base_URL_AGN__c');           
                    String comSuffix = (String)AGN_GCSP_Settings__c.getValues(parentRecordDetails.Country_Code_AGN__c)?.get('Community_Suffix_AGN__c');
                    String communityBaseURL = ''; //commonOktaConfig.Community_Base_URL_AGN__c + commonOktaConfig.Community_Suffix_AGN__c;
                    
                    if(String.isEmpty(comSuffix) || comSuffix.equalsIgnoreCase('/'))
                    {
                        communityBaseURL = comBaseURL;
                    }else{
                        communityBaseURL = comBaseURL+comSuffix;
                    }                       
                       
                    Id docId = getDocument(aw.label); 
                    if(docId != null){
                        aw.documentId = docId;
                    }
                    aw.downloadLink = communityBaseURL+'/servlet/servlet.FileDownload?file='+docId;   /* Ex: https://gcspeudev-allergancommunityeu.cs84.force.com/customerIT/servlet/servlet.FileDownload?file=   */
                    aw.isDownload= true;
                    if(string.isEmpty(aw.file.Id)){
                        attWithDetails.missingAttachment= true;
                    }
                }
            }
        }
        
        system.debug('==newAttachments=='+ newAttachments);
        attWithDetails.AttachmentWrapperList= newAttachments;
        // attWithDetails.missingAttachment
        system.debug('==attWithDetails=='+ attWithDetails);        
        return attWithDetails;
    }
    
    public class DocumentDetails{
        @AuraEnabled
        public List<AttachmentWrapper> attachmentWrapperList {get;set;}
        @AuraEnabled
        public List<String> webSiteList{get;set;}
        @AuraEnabled
        public Boolean missingAttachment {get;set;}
        
        public DocumentDetails(){
            this.attachmentWrapperList = new list<AttachmentWrapper>();
            this.webSiteList= new list<String>();
            this.missingAttachment = false;
        }
    }
    
    public class AttachmentWrapper{
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public boolean isRequired {get;set;}
        @AuraEnabled
        public Attachment file {get;set;}
        @AuraEnabled
        public string inputFileHtmlId {get;set;}
        
        /* for Download button  */
        @AuraEnabled
        public string downloadLink {get;set;}        
        @AuraEnabled
        public boolean isDownload {get;set;}
        @AuraEnabled
        public string documentId {get;set;}
        
        public AttachmentWrapper(string newLabel, Attachment newAttachment){
            this.label = newLabel;
            this.isRequired = false;
            this.file = newAttachment;
            this.file.Description = newLabel.trim();
            this.inputFileHtmlId = newLabel.deleteWhitespace();
        }
        
    }
    
    @AuraEnabled
    public static  List<AGN_GCSP_Document__mdt> getUploadDocumentListForUpdate (String countryCode,String customerGrp,String CurrStep, String source){
        
        List<AGN_GCSP_Document__mdt>  docRetrunList = new List<AGN_GCSP_Document__mdt>();
        List<AGN_GCSP_Document__mdt> docList = new List<AGN_GCSP_Document__mdt>();
        String regSource = String.isEmpty(source) ? '' : '\'%'+String.escapeSingleQuotes(source)+'%\'';
        countryCode = String.isEmpty(countryCode) ? '' : String.escapeSingleQuotes(countryCode);
        CurrStep = String.isEmpty(CurrStep) ? '' : String.escapeSingleQuotes(CurrStep);
        String queryStr = 
            'SELECT AGN_Country__c,'+
            ' Registration_Source_AGN__c,'+
            ' Dependent_Field_Show_Criteria_AGN__c,'+
            ' AGN_Field_API_Name__c,AGN_OAM_Customer_Group__c,'+
            ' AGN_OAMDocument_List__c,AGN_SObject_API_Name__c,Document_Translated_Name_AGN__c,'+
            ' Step_No_AGN__c'+
            ' FROM AGN_GCSP_Document__mdt'+
            ' WHERE AGN_Country__c = \'' + countryCode + '\'' + 
            ' AND Step_No_AGN__c = \'' + CurrStep + '\'' +
            ' AND Registration_Source_AGN__c LIKE ' + regSource ; 
        
        System.debug('queryStr es: '+queryStr);  
        docList =  Database.query(queryStr);       
        System.debug('docList>>>'+docList);
        if(!docList.isEmpty())
        {
            if (String.IsNotEmpty(customerGrp)) {

                for(AGN_GCSP_Document__mdt doc:docList)
                {   
                    List < String > lstCustGrp = String.isNotEmpty(doc.AGN_OAM_Customer_Group__c) ? doc.AGN_OAM_Customer_Group__c.split(',') : new list<String>();
                    if(lstCustGrp.contains(customerGrp) || lstCustGrp.isEmpty() ) 
                    {
                        docRetrunList.add(doc);                      
                    }
                    
                }
                  return docRetrunList;
            }
            return docList;
            
        }
        return docList;    
    }
    
    /* get documents for downLoad link  */
    public static string getDocument(string docName){
        system.debug('@@@@DocName::::'+docName);
        if(docName != ''){            
            list<Document> docId =  [SELECT Id FROM Document WHERE Name =:docName];
            if(docId.size()>0){
                return docId[0].Id; 
            }else{return null;}
            
        }else{
            return null;  
        }
        
    }
    
}