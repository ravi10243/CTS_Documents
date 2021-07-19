public with sharing class AGN_CR_CreateAutoDcrUtils{
    
    
    public static list<DCR_Account_AGN__c> dcrPerAccRecordList  = new list<DCR_Account_AGN__c>();
    public static list<DCR_Account_AGN__c> dcrBusAccRecordList  = new list<DCR_Account_AGN__c>();
    public static list<DCR_Address_AGN__c> dcrAddressRecordList  = new list<DCR_Address_AGN__c>();
    public static list<DCR_affiliation_AGN__c> dcrAffiliationRecordList  = new list<DCR_affiliation_AGN__c>();
    public static Map<String,String> busAccToDCRMap = new Map<String,String>();
    public static Map<String,String> perAccToDCRMap = new Map<String,String>();    
    public static Allergan_Customer_Registration_AGN__c cusRec  = new Allergan_Customer_Registration_AGN__c();
    public static DCR_Config_Settings_AGN__c agnDCRSettings = new DCR_Config_Settings_AGN__c();
    
    
    public static void CreateDCR(String jAcc, String jBusAcc, String jAddr, String jChildAcc, String jCusRec, String jBusAccMap, String jAddrMap){
        
        system.debug('## jAcc: ' + jAcc);
        system.debug('## jBusAcc: ' + jBusAcc);
        system.debug('## jAddr: ' + jAddr);
        system.debug('## jChildAcc: ' + jChildAcc);
        system.debug('## jCusRec: ' + jCusRec);
        
        Account acc=  (Account)JSON.deserialize(jAcc, Account.class);
        system.debug('## acc: ' + acc);
        List<Account> busAcc= (List<Account>)JSON.deserialize(jBusAcc, List<Account>.class);
        List<Address_vod__c> addr= (List<Address_vod__c>)JSON.deserialize(jAddr, List<Address_vod__c>.class);
        List<Child_Account_vod__c> childAcc= (List<Child_Account_vod__c>)JSON.deserialize(jChildAcc, List<Child_Account_vod__c>.class);
        Map<ID,ID> bizAccToCRARecordTypeMap = (Map<ID,ID>)JSON.deserialize(jBusAccMap, Map<ID,ID>.class);
        Map<ID,ID> addrToCRARecordTypeMap = (Map<ID,ID>)JSON.deserialize(jAddrMap, Map<ID,ID>.class);
        
        agnDCRSettings = DCR_Config_Settings_AGN__c.getInstance();
        cusRec= (Allergan_Customer_Registration_AGN__c)JSON.deserialize(jCusRec, Allergan_Customer_Registration_AGN__c.class);
        //Boolean autoDCR =(Boolean)AGN_GCSP_Settings__c.getValues(acc.Country_Code__c).get('Enable_Automated_New_DCR__c') ;
        String recTypeName = [Select Name from RecordType where id=:cusRec.RecordTypeId].Name;
        
        
        //=========Create Business Account and Address DCR in Veeva OOB DCR for countries using Veeva OOB DCR=========//
        if(agnDCRSettings.Veeva_Data_Change_Request_Countries_AGN__c.contains(cusRec.Country_Code_AGN__c)){    
            
            String acctDCRId;
            Map<String,String> acctToDCRMap = new Map<String,String>();
            String caseNumber = [select CaseNumber from Case where Id = :cusRec.Case_AGN__c LIMIT 1].CaseNumber;
            
            //=========Create Business Account DCR=======//
            ID craRecordTypeNew = [select ID from RecordType where SObjectType = 'Allergan_Customer_Address_AGN__c' and Name = 'New' LIMIT 1].ID;
            ID craRecordTypeNewAMI = [select ID from RecordType where SObjectType = 'Allergan_Customer_Address_AGN__c' and Name = 'New AMI' LIMIT 1].ID;
            for(Account acct : busAcc){
                system.debug('inside biz acc loop'+ acct );
                if(bizAccToCRARecordTypeMap.get(acct.Id) == craRecordTypeNew  || bizAccToCRARecordTypeMap.get(acct.Id) == craRecordTypeNewAMI){
                    acctDCRId = AGN_VeevaDCR_Utilities.createAccountDCR(acct, caseNumber, cusRec.Country_AGN__c);
                    acctToDCRMap.put(acct.Id, acctDCRId);
                }                
            }
            
            //============Create Address DCR==========//
            for(Address_vod__c address : addr){
                system.debug('inside addr loop'+ address);
                // Call Create Address DCR from AGN_VeevaDCR_Utilities //
                AGN_VeevaDCR_Utilities.createAddressDCR(address,acctToDCRMap.get(address.Account_vod__c), caseNumber);
            }
            
        }
        
        //=========Create DCRs in DCR2.0 for countries not using Veeva OOB DCR. This is the ELSE part of the IF condition=========//
        else{ 
            //=========Create DCR Person Account=======//
            if(recTypeName=='New'){
                
                createAutoDCRAccount(acc,'HCP_Insert');
                try{
                    //------CheckMarx--Added on 24/07/2020---------- 
                    String objDCRAccPer = 'DCR_Account_AGN__c';
                    SObjectType objDCRAccPrType = ((SObject)(Type.forName('Schema.'+objDCRAccPer).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(dcrPerAccRecordList,objDCRAccPrType,'INSERT');
                    insert dcrPerAccRecordList;
                    //-------------------- 
                    
                }
                catch (Exception ex){system.debug('Exception in person account insert : ' +ex);}
                for(DCR_Account_AGN__c dpacc:dcrPerAccRecordList)
                    perAccToDCRMap.put(dpacc.Target_Account_AGN__c, dpacc.Id);
            }
            
            //========Create DCR Business Account======//
            for(Account acct : busAcc){
                system.debug('inside biz acc loop'+ acct );               
                createAutoDCRAccount(acct,'HCO_Insert');
                
            }
            try{
                //------CheckMarx--Added on 24/07/2020----------  
                String objDCRAcc = 'DCR_Account_AGN__c';
                SObjectType objDCRAccType = ((SObject)(Type.forName('Schema.'+objDCRAcc).newInstance())).getSObjectType();
                AGN_FLSCheck.check(dcrBusAccRecordList,objDCRAccType,'INSERT');
                insert dcrBusAccRecordList;
                //--------------------  
                
            }
            catch (Exception ex){system.debug('Exception in Business account insert : ' +ex);}
            for(DCR_Account_AGN__c dbacc:dcrBusAccRecordList)
                busAccToDCRMap.put(dbacc.Target_Account_AGN__c, dbacc.Id);            
            
            //============Create DCR Address==========//
            for(Address_vod__c address : addr){
                createAutoDCRAddress(address,busAccToDCRMap.get(address.Account_vod__c));
            }
            try{ 
                //------CheckMarx--Added on 24/07/2020---------- 
                String objDCRAddr = 'DCR_Address_AGN__c';
                SObjectType objDCRAddrType = ((SObject)(Type.forName('Schema.'+objDCRAddr).newInstance())).getSObjectType();
                AGN_FLSCheck.check(dcrAddressRecordList,objDCRAddrType,'INSERT');
                insert dcrAddressRecordList;
                //--------------------  
               }
            catch (Exception ex){system.debug('Exception in Address insert : ' +ex);}
            
            //=========Create DCR Affiliation=========//
            if(recTypeName=='New'){
                for(Child_Account_vod__c affil: childAcc){
                    system.debug('inside affil loop'+ affil);
                    createAutoDCRAffiliation(affil,busAccToDCRMap.get(affil.Parent_Account_vod__c),perAccToDCRMap.get(affil.Child_Account_vod__c));
                }
                try{
                    //------CheckMarx--Added on 24/07/2020----------
                    String objDCR = 'DCR_affiliation_AGN__c';
                    SObjectType objDCRType = ((SObject)(Type.forName('Schema.'+objDCR).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(dcrAffiliationRecordList,objDCRType,'INSERT');
                    insert dcrAffiliationRecordList;
                    //--------------------   
                }
                catch (Exception ex){system.debug('Exception in Affiliation insert : ' +ex);}    
            }
            //==========Submit DCR Requests==========//
            submitDCR(dcrPerAccRecordList);
            submitDCR(dcrBusAccRecordList);
        }
    }
    
    public static void createAutoDCRAccount(Account acc, String requestType){
        
        DCR_Account_AGN__c dcrAccRecord  = new DCR_Account_AGN__c();
        String dcrRecType ='';
        system.debug('country code acc' +acc.Country_Code__c);
        system.debug('country code rec' +cusRec.Country_Code_AGN__c);
        string managedBy = (String)AGN_GCSP_Settings__c.getValues(cusRec.Country_Code_AGN__c).get('Account_Managed_By__c') ;
        if(requestType.equals('HCP_Insert')){        
            if(managedBy == 'Self')
                dcrRecType = [select id from RecordType where DeveloperName ='HCP_Update_Company_Managed_AGN'  AND SobjectType='DCR_Account_AGN__c'].id;
            else if(managedBy == 'Data')
                dcrRecType = [select id from RecordType where DeveloperName ='HCP_Update_Data_Provider_Managed_AGN'  AND SobjectType='DCR_Account_AGN__c'].id;
            
            dcrAccRecord.RecordTypeId = dcrRecType;
            dcrAccRecord.Target_Account_AGN__c= acc.Id;
            dcrAccRecord.Request_Status_AGN__c = 'Processing';          
            AGN_DCR2_Utilities.CopyAccountDetail(acc,dcrAccRecord,true,true);           
            if(dcrAccRecord.Gender_AGN__c==null)
                dcrAccRecord.Gender_AGN__c= 'NotProvided';
            dcrAccRecord.Country_AGN__c= acc.Country_VOD__c;
            system.debug('dcrAccRecord.Country_AGN__c : '+ dcrAccRecord.Country_AGN__c);
            system.debug('acc.Country_VOD__c : '+ acc.Country_VOD__c);
            dcrPerAccRecordList.add(dcrAccRecord);
            /*perAccToDCRMap.put(acc.id, dcrAccRecord.id);*/
            
        }
        
        else if(requestType.equals('HCO_Insert')){
            system.debug('inside HCO');
            //system.debug('parentDCRId'+ parentDCRId);
            if(managedBy == 'Self')
                dcrRecType = [select id from RecordType where DeveloperName ='HCO_Update_Company_Managed_AGN'  AND SobjectType='DCR_Account_AGN__c'].id;
            else if(managedBy == 'Data')
                dcrRecType = [select id from RecordType where DeveloperName ='HCO_Update_Data_Provider_Managed_AGN'  AND SobjectType='DCR_Account_AGN__c'].id;
            dcrAccRecord.RecordTypeId = dcrRecType;
            dcrAccRecord.Target_Account_AGN__c= acc.Id;
            //dcrAccRecord.Parent_DCR_AGN__c = parentDCRId;
            dcrAccRecord.Request_Status_AGN__c = 'Processing';
            dcrAccRecord.Account_Type_AGN__c = acc.RecordType.Name;
            system.debug('before copy' +dcrAccRecord);
            AGN_DCR2_Utilities.CopyAccountDetail(acc,dcrAccRecord,true,false);
            dcrAccRecord.Country_AGN__c= acc.Country_VOD__c;
            system.debug('dcrAccRecord.Country_AGN__c : '+ dcrAccRecord.Country_AGN__c);
            system.debug('acc.Country_VOD__c : '+ acc.Country_VOD__c);
            dcrBusAccRecordList.add(dcrAccRecord);
            /*busAccToDCRMap.put(acc.id,dcrAccRecord.id); */           
        }
    }
    public static void createAutoDCRAddress(Address_vod__c addr, String parentDCRAccId){    
        system.debug('parentDCRAccId:'+parentDCRAccId);
        String dcrAddrRecType = [select id from RecordType where DeveloperName ='Customer_Managed_AGN'  AND SobjectType='DCR_Address_AGN__c'].id;
        DCR_Address_AGN__c dcrAddress =  new DCR_Address_AGN__c();
        dcrAddress.RecordTypeId = dcrAddrRecType;
        dcrAddress.Parent_DCR_AGN__c = parentDCRAccId;
        dcrAddress.Target_Address_AGN__c = addr.id;
        dcrAddress.Is_Changed_AGN__c = false;
        AGN_DCR2_Utilities.CopyAddressDetail(addr,dcrAddress,true);
        dcrAddress.Primary_AGN__c='Yes';
        if(dcrAddress.Zip_AGN__c==null)
            dcrAddress.Zip_AGN__c='NotProvided';
        system.debug('dcrAddress.Primary_AGN__c=== :'+dcrAddress.Primary_AGN__c);
        system.debug('addr.Primary_Vod__c=== :'+addr.Primary_Vod__c);
        dcrAddressRecordList.add(dcrAddress) ;
    }
    public static void createAutoDCRAffiliation(Child_Account_vod__c affil, String dcrbusAccId,String dcrperAccId){
        String dcrAffRecType =[SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Affiliation_AGN__c' AND DeveloperName = 'HCP_to_Portal_ACC_Affiliation'].id;
        DCR_Affiliation_AGN__c dcrAffiliaction =  new DCR_Affiliation_AGN__c();
        dcrAffiliaction.RecordTypeId = dcrAffRecType ;
        dcrAffiliaction.Parent_DCR_AGN__c = dcrperAccId;
        dcrAffiliaction.Tgt_Account_AGN__c = affil.Child_Account_vod__c;
        dcrAffiliaction.Target_Affiliation_AGN__c=affil.Id;
        dcrAffiliaction.Affiliated_Account_AGN__c =affil.Parent_Account_vod__c;
        system.debug('affil.Child_Account_vod__r.Primary_Parent_vod__c ====:'+affil.Child_Account_vod__r.Primary_Parent_vod__c );
        system.debug('affil.Parent_Account_vod__c=====:'+affil.Parent_Account_vod__c);
        system.debug('affil.Parent_Account_vod__c=====:'+affil.Sold_To_AGN__c);
        dcrAffiliaction.Primary_AGN__c=affil.Sold_To_AGN__c?'Yes':'No';
        dcrAffiliaction.Is_Changed_AGN__c = false;
        AGN_DCR2_Utilities.CopyAffiliationDetail(affil,dcrAffiliaction,true);
        if(dcrAffiliaction.OK_Role_AGN__c==null)
            dcrAffiliaction.OK_Role_AGN__c='NotProvided';
        dcrAffiliationRecordList.add(dcrAffiliaction);    
    }
    
    public static void submitDCR(list<DCR_Account_AGN__c> dcrAcc){
        for(DCR_Account_AGN__c dacc : dcrAcc){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitted for approval for Customer Registartion via Auto DCR');
            req.setObjectId(dacc.Id);
            Approval.ProcessResult result = Approval.process(req);
            System.debug('Submitted for approval successfully: '+result.isSuccess()); 
        }
    }
}