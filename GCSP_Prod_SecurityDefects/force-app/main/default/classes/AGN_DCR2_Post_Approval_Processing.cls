// AGN_DCR2_Post_Approval_Processing //
//20 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team

public without sharing class AGN_DCR2_Post_Approval_Processing {
    
    
    public static void DCRToAccount(List<DCR_Account_AGN__c> lstDCR,Map<ID,DCR_Account_AGN__c> lstOldDCR,boolean isParentExecution) {
        
        system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].lstDCR =='+lstDCR);
        system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].lstOldDCR =='+lstOldDCR);
        
        List<RecordType> recordTypesList = 
            [SELECT Id, Developername FROM RecordType 
             WHERE SobjectType = 'DCR_Account_AGN__c' 
             AND Developername IN ('HCO_Insert_Company_Managed_AGN','HCO_Update_Company_Managed_AGN','HCO_Affiliated_Insert_Company_Managed',
                                   'HCP_Insert_Company_Managed_AGN','HCP_Update_Company_Managed_AGN','HCP_Affiliated_Insert_Company_Managed')];
        system.debug('== [Query:recordTypesList] =='+recordTypesList);
        Map<Id,RecordType> daccRecTypeMap = new Map<Id,RecordType>([SELECT ID, Developername FROM RecordType WHERE SobjectType = 'DCR_Account_AGN__c']);
        system.debug('== [Query:daccRecTypeMap] =='+daccRecTypeMap);
        Map<string,RecordType> daffRecTypeMap = new Map<string,RecordType>([SELECT ID, Developername FROM RecordType WHERE SobjectType = 'DCR_Affiliation_AGN__c']);
        system.debug('== [Query:daffRecTypeMap] =='+daffRecTypeMap);
        Set<Id> recordTypeSet = new Set<Id>();
        Set<Id> newAccRecTypeSet = new Set<Id>();
        Map<string,string> upsertedAccDcrMap = new Map<string,string>();
        Map<String,String> accRecTypeMap = new Map<String,String>();
        for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Account']) {
            system.debug('== [Query:rt] =='+rt);
            accRecTypeMap.put(rt.DeveloperName,rt.Id);
        }
        
        if(recordTypesList != null && recordTypesList.size() > 0) {
            for(RecordType rt : recordTypesList) {
                recordTypeSet.add(rt.Id);
                if(rt.Developername == 'HCO_Insert_Company_Managed_AGN' || rt.Developername == 'HCP_Insert_Company_Managed_AGN' ||
                   rt.Developername == 'HCO_Affiliated_Insert_Company_Managed' || rt.Developername == 'HCP_Affiliated_Insert_Company_Managed') {
                       newAccRecTypeSet.add(rt.Id);
                   }
            }
        }
        
        
        // ======== ACCOUNT VALUE STAMPING FROM DCR_ACCOUNT ======== //
        system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Account Value Stamping] ==');
        
        List<Account> lstAccount = new List<Account>();
        List<DCR_Account_AGN__c> lstinscheck = new List<DCR_Account_AGN__c>();
        Set<ID> setDCRIds = new Set<ID>();
        Set<ID> setExstngAccountIds = new Set<ID>();
        Set<ID> setNewAccountIds = new Set<ID>();
        Set<string> setNewAccDcrName = new Set<string>();
        boolean canProcess = false;
        String [] arr_accIdExist = new String[10];
        String [] arr_accId = new String[10];
        for(DCR_Account_AGN__c objDCR : lstDCR) {
            Account objAccount = new Account();
            
            if(isParentExecution) {
                if(lstOldDCR.get(objDCR.id).Request_Status_AGN__c != 'Accepted' && objDCR.Request_Status_AGN__c == 'Accepted' && recordTypeSet.contains(objDCR.RecordTypeId)) {
                    canProcess = true;
                    
                    if((daccRecTypeMap.get(objDCR.RecordTypeId).Developername).contains('HCO')) {
                        objAccount.Primary_Parent_vod__c = objDCR.Primary_Parent_AGN__c;
                    } else {
                        objAccount.Primary_Parent_vod__c = 
                            [SELECT Affiliated_Account_AGN__c FROM DCR_Affiliation_AGN__c 
                             WHERE Primary_AGN__c = 'Yes' AND Parent_DCR_AGN__c = :objDCR.id AND Delete_Record_AGN__c != 'Yes'].Affiliated_Account_AGN__c;
                        system.debug('== [Query:objAccount.Primary_Parent_vod__c] =='+objAccount.Primary_Parent_vod__c);
                    }
                }
            } else {
                if(objDCR.Parent_DCR_AGN__r.Request_Status_AGN__c == 'Accepted')
                    canProcess = true;
            }
            
            if(canProcess) {
                
                objAccount.Id = objDCR.Target_Account_AGN__c;
                
                if((daccRecTypeMap.get(objDCR.RecordTypeId).DeveloperName).contains('Insert')) {
                    objAccount.CreatedById = objDCR.CreatedById;
                    objAccount.AGN_DCR_Ref__c = objDCR.Name;
                }
                objAccount.Requested_from_DCR_AGN__c = True;
                objAccount.RecordTypeId = accRecTypeMap.get(objDCR.Account_Type_AGN__c);
                AGN_DCR2_Utilities.CopyAccountDetail(objAccount,objDCR,false,(daccRecTypeMap.get(objDCR.RecordTypeId).Developername).contains('HCP'));
                lstAccount.add(objAccount);
                setDCRIds.add(objDCR.Id);
                
                
                
                if(!string.isblank(objAccount.Id))
                {    setExstngAccountIds.add(objAccount.Id);
                 arr_accIdExist.add(string.valueOf(objAccount.Id));
                }
                if(newAccRecTypeSet.contains(objDCR.RecordTypeId)) {
                    setNewAccDcrName.add(objDCR.Name);
                }
            }
            
        }
        
        if(lstAccount != null && lstAccount.size() > 0) {
            system.debug('== [DML:upsert lstAccount] =='+lstAccount);
            upsert lstAccount;
            system.debug('== [DML:upsert lstAccount].success ==');
            
            for(DCR_Account_AGN__c objDCR : lstDCR) {
                if(!string.isblank(objDCR.Target_Account_AGN__c))
                    upsertedAccDcrMap.put(objDCR.id,objDCR.Target_Account_AGN__c);
                else {
                    for(Account acc : lstAccount) {
                        if(acc.AGN_DCR_Ref__c == objDCR.Name)
                            upsertedAccDcrMap.put(objDCR.id,acc.id);
                    }
                }
            }
            
            
            
            for(Account acc : lstAccount) {
                if(setNewAccDcrName.contains(acc.AGN_DCR_Ref__c)) 
                    {
                    setNewAccountIds.add(acc.id);
                    arr_accId.add(string.valueOf(acc.id));
                    }
            }
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Account Value Stamping].upsertedAccDcrMap =='+upsertedAccDcrMap);
        }
        // -------- ACCOUNT VALUE STAMPING FROM DCR_ACCOUNT -------- //
        
        
        
        
        // ======== ADDRESS CREATION,UPDATE & DELETE W.R.T. DCR_ADDRESS ======== //
        system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Address Creation/Update/Deletion] ==');
        List<Address_vod__c> lstAddress = new List<Address_vod__c>();
        Address_vod__c objAddress;
        List<Address_vod__c> lstAddressToDelete = new List<Address_vod__c>();
        Address_vod__c objAddressDel;
        List<Address_vod__c> lstPrimAddrUpd = new List<Address_vod__c>();
        List<Address_vod__c> lstPrimAddrhcoUpd = new List<Address_vod__c>();
        
        if(setDCRIds != null && setDCRIds.size() > 0) {
            
            // ======== SELECT ADDRESS RECORDS TO BE DELETED ======== //
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Dcr_Address Deletion] ==');
            List<DCR_Address_AGN__c> lstDCRAddressDeleted = 
                [SELECT Id,Target_Address_AGN__c,Tgt_Account_AGN__c FROM DCR_Address_AGN__c 
                 WHERE Parent_DCR_AGN__c IN :setDCRIds AND isDeleted = true ALL ROWS];
            system.debug('== [Query:lstDCRAddressDeleted] =='+lstDCRAddressDeleted);
            
            if(lstDCRAddressDeleted != null && lstDCRAddressDeleted.size() > 0) {
                for(DCR_Address_AGN__c objDCRAddress : lstDCRAddressDeleted) {
                    objAddressDel = new Address_vod__c(Account_vod__c = objDCRAddress.Tgt_Account_AGN__c);
                    objAddressDel.id = objDCRAddress.Target_Address_AGN__c;
                    
                    lstAddressToDelete.add(objAddressDel);
                }
            }
            // -------- SELECT ADDRESS RECORDS TO BE DELETED -------- //
            
            
            // ======== SELECT ADDRESS RECORDS TO BE ADDED/MODIFIED ======== //
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Dcr_Address Creation/Update] ==');
            List<DCR_Address_AGN__c> lstDCRAddress = 
                [SELECT Tgt_Account_AGN__c,Address_Line_1_AGN__c,Address_Line_2_AGN__c,Address_Line_3_AGN__c,
                 Address_Type_AGN__c,Appt_Required_AGN__c,Billing_AGN__c,Brick_AGN__c,Business_AGN__c,
                 Changed_AGN__c,City_AGN__c,Country_AGN__c,Inactive_AGN__c,Fax_AGN__c,Home_AGN__c,
                 Is_Changed_AGN__c,Mailing_AGN__c,Phone_AGN__c,Phone_2_AGN__c,Zip_AGN__c,Primary_AGN__c,
                 Receptionist_Email_AGN__c,Receptionist_Name_AGN__c,Shipping_AGN__c,State_AGN__c,
                 Target_Address_AGN__c,CreatedById,Parent_DCR_AGN__c,Parent_DCR_AGN__r.Name
                 FROM DCR_Address_AGN__c WHERE Parent_DCR_AGN__c IN :setDCRIds];
            system.debug('== [Query:lstDCRAddress] =='+lstDCRAddress);
            
            if(lstDCRAddress != null && lstDCRAddress.size() > 0) {
                for(DCR_Address_AGN__c objDCRAddress : lstDCRAddress) {                    
                    objDCRAddress.Tgt_Account_AGN__c = upsertedAccDcrMap.get(objDCRAddress.Parent_DCR_AGN__c);
                    objAddress = new Address_vod__c(Account_vod__c = objDCRAddress.Tgt_Account_AGN__c);
                    objAddress.id = objDCRAddress.Target_Address_AGN__c;
                    if(string.isblank(objDCRAddress.Id))
                        objAddress.CreatedById = objDCRAddress.CreatedById;
                    objAddress.Requested_from_DCR_AGN__c = True;
                    AGN_DCR2_Utilities.CopyAddressDetail(objAddress,objDCRAddress,false);
                    system.debug('•objAddress•'+objAddress);
                    lstAddress.add(objAddress);
                }
            }
            // -------- SELECT ADDRESS RECORDS TO BE ADDED/MODIFIED-------- //
            
            
            // ======== UPDATING HCP PRIMARY ADDRESS ========R11:1418======== //
            
            List<Id> hcpId= New List<Id>(); 
            List<Id> HCPDcrId= New List<Id>();
            List<Id> primAccountId = New List<Id>();
            
            
            for (DCR_Account_AGN__c dcrHCP:lstDCR) {
                if((daccRecTypeMap.get(dcrHCP.RecordTypeId).Developername).contains('HCP')) {
                    hcpId.add(dcrHCP.Target_Account_AGN__c);
                    HCPDcrId.add(dcrHCP.Id);
                }
                if((daccRecTypeMap.get(dcrHCP.RecordTypeId).Developername).contains('Update')) {
                    lstinscheck.add(dcrHCP);
                }
            }
            
            if(lstinscheck.size()>0) {
                
                List<DCR_Affiliation_AGN__c> DCRAffAdd = [SELECT Affiliated_Account_AGN__c FROM DCR_Affiliation_AGN__c 
                                                          WHERE Tgt_Account_AGN__c = :hcpId AND Primary_AGN__c = 'Yes' AND Parent_DCR_AGN__c = :HCPDcrId];
                
                if(DCRAffAdd != null && DCRAffAdd.size() > 0) {
                    for (DCR_Affiliation_AGN__c addraff:DCRAffAdd) {
                        primAccountId.add(addraff.Affiliated_Account_AGN__c);
                    }
                }   
                
                
                List<Address_vod__c> lstPrimAddrOld = [SELECT Id,Primary_vod__c 
                                                       FROM Address_vod__c WHERE Account_vod__c = :hcpId 
                                                       and (Controlling_Address_vod__r.Account_vod__c != :primAccountId 
                                                            or Controlling_Address_vod__r.Primary_vod__c != true) ];
                List<Address_vod__c> lstPrimAddrNew = 
                    [SELECT Id
                     FROM Address_vod__c WHERE Controlling_Address_vod__r.Account_vod__c = :primAccountId 
                     and Controlling_Address_vod__r.Primary_vod__c = true and Account_vod__c = :hcpId];
                
                
                
                if(lstPrimAddrOld != null && lstPrimAddrOld.size() > 0) {
                    for (Address_vod__c addr:lstPrimAddrOld) {
                        addr.Primary_vod__c = false;
                        lstPrimAddrUpd.add(addr);
                    }
                }
                
                
                if(lstPrimAddrNew != null && lstPrimAddrNew.size() > 0) {
                    for (Address_vod__c addr2:lstPrimAddrNew) {
                        addr2.Primary_vod__c = true;
                        lstPrimAddrUpd.add(addr2);
                    }
                }
                
                
                
                List<Id> hcoId= New List<Id>(); 
                List<Id> DcrId= New List<Id>();
                List<Id> Accaddrprim= New List<Id>() ; 
                List<Id> Accaddrsec= New List<Id>() ; 
                
                
                for (DCR_Account_AGN__c dcrHCP:lstDCR) {
                    if((daccRecTypeMap.get(dcrHCP.RecordTypeId).Developername).contains('HCO')) {
                        hcoId.add(upsertedAccDcrMap.get(dcrHCP.id));
                        // hcoId.add(dcrHCP.Target_Account_AGN__c);
                        system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Assignment of DCR target Account] == '+upsertedAccDcrMap.get(dcrHCP.id) );
                        DcrId.add(dcrHCP.Id);
                    }
                }
                
                
                
                List<DCR_Address_AGN__c> lstAddrId = 
                    [SELECT Target_Address_AGN__c,Primary_AGN__c 
                     FROM DCR_Address_AGN__c WHERE Tgt_Account_AGN__c = :hcoId and Parent_DCR_AGN__c = :DcrId];
                
                
                if(lstAddrId != null && lstAddrId.size() > 0) {
                    for(DCR_Address_AGN__c addr:lstAddrId ) {
                        if(addr.Primary_AGN__c == 'Yes')                                              
                            Accaddrprim.add(addr.Target_Address_AGN__c);
                        else     
                            Accaddrsec.add(addr.Target_Address_AGN__c);
                    }
                }
                
                List<Address_Vod__C> Conaddrprim = 
                    [SELECT Id FROM Address_Vod__C 
                     WHERE Controlling_Address_vod__c in :Accaddrprim and Account_vod__r.Primary_Parent_vod__c = :hcoId];
                
                
                List<Address_Vod__C> Conaddrsec = 
                    [SELECT Id FROM Address_Vod__C 
                     WHERE Controlling_Address_vod__c in :Accaddrsec and Account_vod__r.Primary_Parent_vod__c = :hcoId];
                
                if(Conaddrprim != null && Conaddrprim.size() > 0) {
                    for(Address_vod__C primaddr:Conaddrprim ) {
                        primaddr.Primary_vod__c = true;
                        lstPrimAddrhcoupd.add(primaddr);        
                    }
                }
                
                
                if(Conaddrsec != null && Conaddrsec.size() > 0) {
                    for(Address_vod__C secaddr:Conaddrsec ) {
                        secaddr.Primary_vod__c = false;
                        lstPrimAddrhcoupd.add(secaddr);     
                    }
                }
                
            }
            // ------------ UPDATING HCP PRIMARY ADDRESS ------------R11:1418---------- //
            
            
            
        }
        if(lstAddressToDelete != null && lstAddressToDelete.size() > 0){
            system.debug('== [DML:delete lstAddressToDelete] =='+lstAddressToDelete);
            delete lstAddressToDelete;
            system.debug('== [DML:delete lstAddressToDelete].success ==');
        }
        if(lstAddress != null && lstAddress.size() > 0){
            system.debug('== [DML:upsert lstAddress] =='+lstAddress);
            upsert lstAddress;
            system.debug('== [DML:upsert lstAddress].success ==');
            
        }
        
        if(lstPrimAddrUpd != null && lstPrimAddrUpd.size() > 0){
            system.debug('== [DML:upsert lstPrimAddrUpd] =='+lstPrimAddrUpd);
            upsert lstPrimAddrUpd;
            system.debug('== [DML:upsert lstPrimAddrUpd].success ==');
        }
        
        if(lstPrimAddrhcoUpd != null && lstPrimAddrhcoUpd.size() > 0){
            system.debug('== [DML:upsert lstPrimAddrhcoUpd] =='+lstPrimAddrhcoUpd);
            upsert lstPrimAddrhcoUpd;
            system.debug('== [DML:upsert lstPrimAddrhcoUpd].success ==');
        }
        
        
        // -------- ADDRESS CREATION,UPDATE & DELETE W.R.T. DCR_ADDRESS -------- //
        
        
        
        
        // ======== CHILD_ACCOUNT UPDATE & DELETION W.R.T. DCR_AFFILIATION ======== //
        system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Child_Account Creation/Update/Deletion] ==');
        List<Child_Account_vod__c> lstChildAffToUpsert = new List<Child_Account_vod__c>();
        Child_Account_vod__c objChildAffToUpsert;
        List<Child_Account_vod__c> lstChildAffToDelete = new List<Child_Account_vod__c >();
        List<DCR_Affiliation_AGN__c> lstDcrAffToUpdate = new List<DCR_Affiliation_AGN__c>();
        Child_Account_vod__c objChildAffToDelete;
        if(setDCRIds != null && setDCRIds.size() > 0) {
            
            // ======== SELECT CHILD_ACCOUNT RECORDS TO BE DELETED ======== //
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Dcr_Affiliation Deletion] ==');
            List<DCR_Affiliation_AGN__c> lstDCRAffiliationDeleted = 
                [SELECT Id,Target_Affiliation_AGN__c FROM DCR_Affiliation_AGN__c
                 WHERE Parent_DCR_AGN__c in :setDCRIds AND Delete_Record_AGN__c = 'Yes'];
            system.debug('== [Query:lstDCRAffiliationDeleted] =='+lstDCRAffiliationDeleted);
            
            if(lstDCRAffiliationDeleted != null && lstDCRAffiliationDeleted.size() > 0) {
                for(DCR_Affiliation_AGN__c objDCRAffiliation : lstDCRAffiliationDeleted) {
                    objChildAffToDelete = new Child_Account_vod__c();
                    objChildAffToDelete.id = objDCRAffiliation.Target_Affiliation_AGN__c;
                    if(objChildAffToDelete.id != null) {
                        lstChildAffToDelete.add(objChildAffToDelete);
                    }
                }
            }
            // -------- SELECT CHILD_ACCOUNT RECORDS TO BE DELETED -------- //
            
            
            // ======== SELECT CHILD_ACCOUNT RECORDS TO BE ADDED/MODIFIED ======== //
            if(isParentExecution) {
                system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Dcr_Affiliation Creation/Update].[Parent Execution] ==');
                List<DCR_Affiliation_AGN__c> lstDCRAffiliation =
                    [SELECT Address_AGN__c,Affiliated_Account_AGN__c,Affiliated_DCR_Account_AGN__c,
                     Affiliated_DCR_Account_Name_AGN__c,Changed_AGN__c,Delete_Record_AGN__c,
                     Is_Changed_AGN__c,Parent_DCR_AGN__c,OK_Role_AGN__c,Target_Affiliation_AGN__c,
                     Work_Status_AGN__c,Parent_DCR_AGN__r.Target_Account_AGN__c,Tgt_Account_AGN__c,
                     Parent_DCR_AGN__r.Name,CreatedById,RecordType.Developername
                     FROM DCR_Affiliation_AGN__c WHERE Parent_DCR_AGN__c IN :setDCRIds];
                system.debug('== [Query:lstDCRAffiliation] =='+lstDCRAffiliation);
                
                if(lstDCRAffiliation != null && lstDCRAffiliation.size() > 0) {
                    for(DCR_Affiliation_AGN__c objDCRAffiliation : lstDCRAffiliation) {
                        objChildAffToUpsert = new Child_Account_vod__c();
                        objChildAffToUpsert.id = objDCRAffiliation.Target_Affiliation_AGN__c;
                        objChildAffToUpsert.Copy_Address_vod__c = True;
                        if(string.isblank(objDCRAffiliation.Id))
                            objChildAffToUpsert.CreatedById = objDCRAffiliation.CreatedById;
                        if((objDCRAffiliation.RecordType.Developername).contains('HCP')) {
                            objChildAffToUpsert.Parent_Account_vod__c = objDCRAffiliation.Affiliated_Account_AGN__c;
                            objChildAffToUpsert.Child_Account_vod__c = upsertedAccDcrMap.get(objDCRAffiliation.Parent_DCR_AGN__c);
                        } else {
                            objChildAffToUpsert.Parent_Account_vod__c = upsertedAccDcrMap.get(objDCRAffiliation.Parent_DCR_AGN__c);
                            objChildAffToUpsert.Child_Account_vod__c = objDCRAffiliation.Affiliated_Account_AGN__c;
                        }
                        AGN_DCR2_Utilities.CopyAffiliationDetail(objChildAffToUpsert,objDCRAffiliation,false);
                        objChildAffToUpsert.External_ID_vod__c = objChildAffToUpsert.Parent_Account_vod__c+'__'+objChildAffToUpsert.Child_Account_vod__c;
                        if(objDCRAffiliation.Delete_Record_AGN__c != 'Yes') {
                            lstChildAffToUpsert.add(objChildAffToUpsert);
                        }
                    }
                }
            } else {
                system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Dcr_Affiliation Creation/Update].[Child Execution] =='+lstAccount);
                string hcpToAccAffRecTypeId;
                string hcoToAccAffRecTypeId;
                List<DCR_Affiliation_AGN__c> lstDCRAffiliation =
                    [SELECT Address_AGN__c,Affiliated_Account_AGN__c,Affiliated_DCR_Account_AGN__c,
                     Affiliated_DCR_Account_Name_AGN__c,Changed_AGN__c,Delete_Record_AGN__c,
                     Is_Changed_AGN__c,Parent_DCR_AGN__c,OK_Role_AGN__c,Target_Affiliation_AGN__c,
                     Work_Status_AGN__c,Tgt_Account_AGN__c,RecordType.Developername,Primary_AGN__c,
                     Parent_DCR_AGN__r.Target_Account_AGN__c,Affiliated_DCR_Account_AGN__r.Name
                     FROM DCR_Affiliation_AGN__c WHERE Affiliated_DCR_Account_AGN__c IN :setDCRIds];
                system.debug('== [Query:lstDCRAffiliation] =='+lstDCRAffiliation);
                
                for(string aaRectype: daffRecTypeMap.keyset()) {
                    if(daffRecTypeMap.get(aaRectype).Developername == 'HCP_to_ACC_Affiliation')
                        hcpToAccAffRecTypeId = daffRecTypeMap.get(aaRectype).Id;
                    if(daffRecTypeMap.get(aaRectype).Developername == 'HCO_to_ACC_Affiliation')
                        hcoToAccAffRecTypeId = daffRecTypeMap.get(aaRectype).Id;
                }
                
                if(lstDCRAffiliation != null && lstDCRAffiliation.size() > 0) {
                    for(DCR_Affiliation_AGN__c objDCRAffiliation : lstDCRAffiliation) {
                        for(Account ac: lstAccount) {
                            if(objDCRAffiliation.Affiliated_DCR_Account_AGN__r.Name == ac.AGN_DCR_Ref__c) {
                                objDCRAffiliation.Affiliated_Account_AGN__c = ac.id;
                                if(daffRecTypeMap.get(objDCRAffiliation.RecordTypeId).Developername == 'HCP_to_DCR_Affiliation') {
                                    objDCRAffiliation.RecordTypeId = hcpToAccAffRecTypeId;
                                }
                                else {//if(daffRecTypeMap.get(objDCRAffiliation.RecordTypeId).Developername == 'HCO_to_DCR_Affiliation') 
                                    objDCRAffiliation.RecordTypeId = hcoToAccAffRecTypeId;
                                }
                                lstDcrAffToUpdate.add(objDCRAffiliation);
                            }
                        }
                    }
                }
            }
            // -------- SELECT CHILD_ACCOUNT RECORDS TO BE ADDED/MODIFIED -------- //
            
        }
        if(lstChildAffToDelete !=null && lstChildAffToDelete.size()>0) {
            system.debug('== [DML:delete lstChildAffToDelete] =='+lstChildAffToDelete);
            delete lstChildAffToDelete;
            system.debug('== [DML:delete lstChildAffToDelete].success ==');
        }
        if(lstChildAffToUpsert!=null && lstChildAffToUpsert.size()>0) {
            system.debug('== [DML:upsert lstChildAffToUpsert] =='+lstChildAffToUpsert);
            upsert lstChildAffToUpsert External_ID_vod__c;
            system.debug('== [DML:upsert lstChildAffToUpsert].success ==');
        }
        if(lstDcrAffToUpdate!=null && lstDcrAffToUpdate.size()>0) {
            system.debug('== [DML:update lstDcrAffToUpdate] =='+lstDcrAffToUpdate);
            update lstDcrAffToUpdate;
            system.debug('== [DML:update lstDcrAffToUpdate].success =='+lstDcrAffToUpdate);
        }
        // -------- CHILD_ACCOUNT UPDATE & DELETION W.R.T. DCR_AFFILIATION -------- //
        
        
        
        
        // ======== PRODUCT_METRICS UPDATE & DELETION W.R.T. DCR_KEY_INDICATOR ======== //
        system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Product_Metrics Creation/Update/Deletion] ==');
        List<Product_Metrics_vod__c> lstProdMetrics = new List<Product_Metrics_vod__c>();
        Product_Metrics_vod__c objProdMetrics;
        Product_Metrics_vod__c objProdMetricsDetailGroup;
        String strExistDetailGroup='';
        String strIncludedData='';
        if(setDCRIds!=null && setDCRIds.size()>0){
            
            // ======== SELECT EXISTING PRODUCT_METRICS GROUP RECORDS TO BE EXCLUDED FROM INSERT ======== //
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Excluding Existing Product Group] ==');
            List<Product_Metrics_vod__c> lstExistingDetailGroup =
                [SELECT Id, Account_vod__c, Products_vod__c FROM Product_Metrics_vod__c
                 WHERE Account_vod__c IN :setExstngAccountIds
                 AND Products_vod__r.Product_Type_vod__c = 'Detail Group'];
            system.debug('== [Query:lstExistingDetailGroup] =='+lstExistingDetailGroup);
            
            if(lstExistingDetailGroup != null && lstExistingDetailGroup.size() > 0) {
                for(Product_Metrics_vod__c objMetrics : lstExistingDetailGroup) {
                    strExistDetailGroup = strExistDetailGroup + objMetrics.Account_vod__c + '#' + objMetrics.Products_vod__c + ',';
                }
            }
            // -------- SELECT EXISTING PRODUCT_METRICS GROUP RECORDS TO BE EXCLUDED FROM INSERT -------- //
            
            
            // ======== SELECT PRODUCT_METRICS RECORDS TO BE ADDED/MODIFIED ======== //
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Product_Metrics Creation/Update] ==');
            List<DCR_Key_Indicator_AGN__c> lstDCRKeyIndicator =
                [SELECT Changed_AGN__c,Delete_Record_AGN__c,Is_Changed_AGN__c,Parent_DCR_AGN__c,Tgt_Account_AGN__c,
                 Target_Key_Indicator_AGN__c,Product_AGN__c,Product_Group_AGN__c,Adoption_AGN__c,Allergan_Potential_AGN__c,
                 Account_Support_AGN__c,Adoption_IMS_AGN__c,Adoption_Level_AGN__c,Advocacy_Profile_AGN__c,Awareness_AGN__c,
                 Continuum_Placement_AGN__c,Engagements_AGN__c,Fase_AGN__c,Fixed_Consignment_AGN__c,Growth_Potential_AGN__c,
                 Investigator_AGN__c,Investigator_Readiness_AGN__c,Key_Account_AGN__c,Ophthalmology_Profile_AGN__c,
                 Potential_IMS_AGN__c,Product_Status_AGN__c,Profiling_AGN__c,Ratings_AGN__c,Retina_Profile_AGN__c,
                 Sales_Target_AGN__c,Sector_AGN__c,Customer_Segment_AGN__c,Segment1_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c,
                 Target_AGN__c,Product_AGN__r.Name,CreatedById,Parent_DCR_AGN__r.Name
                 FROM DCR_Key_Indicator_AGN__c WHERE Is_Changed_AGN__c = true AND Parent_DCR_AGN__c IN :setDCRIds];
            system.debug('== [Query:lstDCRKeyIndicator] =='+lstDCRKeyIndicator);
            
            if(lstDCRKeyIndicator != null && lstDCRKeyIndicator.size() > 0) {
                for(DCR_Key_Indicator_AGN__c objDCRKeyIndicator : lstDCRKeyIndicator) {
                    system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Product_Metrics Creation/Update].[for Detail Product].objDCRKeyIndicator =='+objDCRKeyIndicator);
                    objDCRKeyIndicator.Tgt_Account_AGN__c = upsertedAccDcrMap.get(objDCRKeyIndicator.Parent_DCR_AGN__c);
                    objProdMetrics = new Product_Metrics_vod__c(Account_vod__c = objDCRKeyIndicator.Tgt_Account_AGN__c);
                    objProdMetrics.id = objDCRKeyIndicator.Target_Key_Indicator_AGN__c;
                    if(string.isblank(objDCRKeyIndicator.Id))
                        objProdMetrics.CreatedById = objDCRKeyIndicator.CreatedById;
                    AGN_DCR2_Utilities.CopyKeyIndicatorDetail(objProdMetrics,objDCRKeyIndicator,false);
                    lstProdMetrics.add(objProdMetrics);
                    if (objDCRKeyIndicator.Product_Group_AGN__c != null && strExistDetailGroup.indexof(objDCRKeyIndicator.Tgt_Account_AGN__c + '#' + objDCRKeyIndicator.Product_Group_AGN__c) < 0 &&
                        strIncludedData.indexof(objDCRKeyIndicator.Tgt_Account_AGN__c + '#' + objDCRKeyIndicator.Product_Group_AGN__c) < 0) {
                            
                            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Product_Metrics Creation/Update].[for Product Group].objDCRKeyIndicator.Product_Group_AGN__c =='+objDCRKeyIndicator.Product_Group_AGN__c);
                            objDCRKeyIndicator.Tgt_Account_AGN__c = upsertedAccDcrMap.get(objDCRKeyIndicator.Parent_DCR_AGN__c);
                            objProdMetricsDetailGroup = new Product_Metrics_vod__c(Account_vod__c = objDCRKeyIndicator.Tgt_Account_AGN__c);
                            objProdMetricsDetailGroup.Products_vod__c = objDCRKeyIndicator.Product_Group_AGN__c;
                            strIncludedData = strIncludedData+objDCRKeyIndicator.Tgt_Account_AGN__c+'#'+objDCRKeyIndicator.Product_Group_AGN__c+',' ;
                            lstProdMetrics.add(objProdMetricsDetailGroup);
                        }
                }
            }
            // -------- SELECT PRODUCT_METRICS RECORDS TO BE ADDED/MODIFIED -------- //
            
        }
        if(lstProdMetrics !=null && lstProdMetrics.size()>0){
            system.debug('== [DML:upsert lstProdMetrics] =='+lstProdMetrics);
            upsert lstProdMetrics;
            system.debug('== [DML:upsert lstProdMetrics].success ==');
        }
        // -------- PRODUCT_METRICS UPDATE & DELETION W.R.T. DCR_KEY_INDICATOR CALLING FUTURE METHOD IN LOOP TO SAVE ACCOUNT RECORD LOCK-------- //
        system.debug('arr_accId===============>'+arr_accId);
        for (Integer i = 0; i<arr_accId.size(); i++){
            if (arr_accId[i]=='' || arr_accId[i] == null)
                continue;
            AccountAlign(arr_accId[i],arr_accIdExist);
        }
        
    }
    
    
    public static void AccountAlign(id arr, String [] arrExist){
        
        Set<ID> setNewAccountIds = new Set<ID>();
        //for (Integer i = 0; i<arr.size(); i++){
        setNewAccountIds.add(arr);
        //}
        Set<ID> setExstngAccountIds = new Set<ID>();
        for (Integer i = 0; i<arrExist.size(); i++){
             if (arrExist[i] != '' && arrExist[i] != null)
            setExstngAccountIds.add(arrExist[i]);
        }
        
        
        
        // ======== INSERT/UPDATE IN ATL, GAS_HISTORY & TSF FOR EACH ACCOUNT ======== //
        
        system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[ATL,GAS_History,TSF Creation/Update].setNewAccountIds ==' + setNewAccountIds);
        
        
        
        if(setNewAccountIds != null && setNewAccountIds.size() > 0){
            
            
            // ======== Forming String, Lists and Map of ATL & Territories for further use ======== //
            
            List<Account> lstNewAccountData =                        // Used in: TSF, createdByUserList, setNewAccountsForTSF
                [SELECT Id,Primary_Parent_vod__c,CreatedById FROM Account WHERE Id IN: setNewAccountIds];
            system.debug('== [Query:lstNewAccountData] =='+lstNewAccountData);
            
            List<Id> createdByUserList = new List<Id>();        // Used in: lstUserTerritory
            for(Account accData: lstNewAccountData)
                createdByUserList.add(accData.CreatedById);
            //changes for TM 1.0 to TM 2.0 Migration - Start
            List<Territory2> lstUserTerritory =                        // Used in: TSF, strTerritoryList, territoryNameList
                [SELECT ID,Name FROM Territory2 WHERE Id IN
                 (SELECT Territory2Id FROM UserTerritory2Association WHERE userid=: createdByUserList AND Territory2.Territory2Model.State ='Active')];
            system.debug('== [Query:lstUserTerritory] =='+lstUserTerritory);
            		
            String strTerritoryList = '';        // Used in: ATL, GAS
            
            List<String> territoryNameList = new List<String>();          // Used in: TSF, strTerritoryList, lstExistingTSF
            if(lstUserTerritory != null && lstUserTerritory.size() > 0) {
                for(Territory2 objTerritory : lstUserTerritory) {
                    strTerritoryList = strTerritoryList + objTerritory.Name + ';';
                    territoryNameList.add(objTerritory.Name);
                }
            }
            //changes for TM 1.0 to TM 2.0 Migration - End
            Set<ID> setNewAccountsForTSF = setNewAccountIds.clone();          // Used in: lstExistingTSF
            for(Account newAcc : lstNewAccountData)
                if(!string.isblank(newAcc.Primary_Parent_vod__c))
                setNewAccountsForTSF.add(newAcc.Primary_Parent_vod__c);
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[ATL,GAS_History,TSF Creation/Update].setNewAccountsForTSF =='+setNewAccountsForTSF);
            
            List<TSF_vod__c> lstExistingTSF =                        // Used in: TSF
                [SELECT External_Id_vod__c FROM TSF_vod__c WHERE Account_vod__c IN :setNewAccountsForTSF];
            system.debug('== [Query:lstExistingTSF] =='+lstExistingTSF);
            
            Set<String> SetTSFExistingExtrnlId = new Set<String>();        // Used in: TSF
            
            
            // ======== UPDATE/INSERT RECORDS IN ATL ======== //
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Insert/Update ATL].setExstngAccountIds =='+setExstngAccountIds);
            List<Account_Territory_Loader_vod__c> lstATL = new List<Account_Territory_Loader_vod__c>();
            Account_Territory_Loader_vod__c objATL;
            
            List<Account_Territory_Loader_vod__c> lstExistingATLforUpdate = new List<Account_Territory_Loader_vod__c>();
            if(setExstngAccountIds != null && setExstngAccountIds.size() > 0) {
                lstExistingATLforUpdate =
                    [SELECT ID,Name,Account_vod__c,Territory_vod__c,Territory_To_Add_vod__c
                     FROM Account_Territory_Loader_vod__c WHERE Account_vod__c IN: setExstngAccountIds];
                system.debug('== [Query:lstExistingATLforUpdate] =='+lstExistingATLforUpdate);
            }
            
            Map<Id,Account_Territory_Loader_vod__c> mapAccountToATLforUpdate = new Map<Id,Account_Territory_Loader_vod__c>();
            if(lstExistingATLforUpdate != null && lstExistingATLforUpdate.size() > 0) {
                for(Account_Territory_Loader_vod__c objexistingATL : lstExistingATLforUpdate) {
                    mapAccountToATLforUpdate.put(objexistingATL.Account_vod__c,objexistingATL);
                }
            }
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Insert/Update ATL].mapAccountToATLforUpdate =='+mapAccountToATLforUpdate);
            
            if(strTerritoryList != '' && setNewAccountIds != null && setNewAccountIds.size() > 0) {
                for(Id IDAccount : setNewAccountIds) {
                    if(mapAccountToATLforUpdate.containsKey(IDAccount) && IDAccount != null) {
                        objATL = mapAccountToATLforUpdate.get(IDAccount);
                        objATL.Territory_To_Add_vod__c = strTerritoryList;
                        lstATL.add(objATL);
                    } else if (IDAccount != null){
                        objATL = new Account_Territory_Loader_vod__c();
                        objATL.Account_vod__c = IDAccount;
                        objATL.Territory_To_Add_vod__c = strTerritoryList;
                        objATL.External_ID_vod__c = IDAccount;
                        lstATL.add(objATL);
                    }
                }
            }
            
            if(lstATL != null && lstATL.size() > 0) {
                system.debug('== [DML:upsert lstATL] =='+lstATL);
                upsert lstATL;
                system.debug('== [DML:upsert lstATL].success =='+lstATL);
                
            }
            // -------- UPDATE/INSERT RECORDS IN ATL -------- //
            GasAlign(arr,strTerritoryList);
            }
            
            }
            
            @future
            public static void GasAlign(id arr,String str){
            // ======== INSERT RECORD IN GAS_ALIGNMENT_HISTORY ======== //
            //system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Insert GAS_Alignment_History].setNewAccountIds =='+setNewAccountIds);
            Set<ID> setNewAccountIds = new Set<ID>();
            setNewAccountIds.add(arr);
            String strTerritoryList = str;
            
            List<GAS_Alignment_History_vts__c> lstGASHistory = new List<GAS_Alignment_History_vts__c >();
            GAS_Alignment_History_vts__c objGASHistory;
            
            List<Account_Territory_Loader_vod__c> lstExistingATLforGAS =
                [SELECT ID,Name,Account_vod__c,Territory_vod__c,Territory_To_Add_vod__c
                 FROM Account_Territory_Loader_vod__c WHERE Account_vod__c IN: setNewAccountIds];
            system.debug('== [Query:lstExistingATLforGAS] =='+lstExistingATLforGAS);
            
            Map<Id,Account_Territory_Loader_vod__c> mapAccountToATLforGAS = new Map<Id,Account_Territory_Loader_vod__c>();
            if(lstExistingATLforGAS != null && lstExistingATLforGAS.size() > 0) {
                for(Account_Territory_Loader_vod__c objexistingATL : lstExistingATLforGAS) {
                    mapAccountToATLforGAS.put(objexistingATL.Account_vod__c,objexistingATL);
                }
            }
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Insert GAS_Alignment_History].mapAccountToATLforGAS =='+mapAccountToATLforGAS);
            
            if(strTerritoryList != '' && setNewAccountIds != null && setNewAccountIds.size() > 0) {
                for(Id IDAccount : setNewAccountIds) {
                    if(mapAccountToATLforGAS.containsKey(IDAccount) && IDAccount != null) {
                        objGASHistory = new GAS_Alignment_History_vts__c();
                        objGASHistory.Account__c = IDAccount ;
                        objGASHistory.Account_Territory_Loader__c = mapAccountToATLforGAS.get(IDAccount).Id;
                        objGASHistory.New_Territory__c = strTerritoryList;
                        lstGASHistory.add(objGASHistory);
                    }
                }
            }
            if(lstGASHistory != null && lstGASHistory.size() > 0) {
                system.debug('== [DML:insert lstGASHistory] =='+lstGASHistory);
                insert lstGASHistory;
                system.debug('== [DML:insert lstGASHistory].success ==');
            }  
            // -------- INSERT RECORD IN GAS_ALIGNMENT_HISTORY -------- //
            
            
            // ======== GET USER'S TERRITORY AND UPDATE/INSERT TO TSF ======== //
            List<Account> lstNewAccountData =                        // Used in: TSF, createdByUserList, setNewAccountsForTSF
                [SELECT Id,Primary_Parent_vod__c,CreatedById FROM Account WHERE Id IN: setNewAccountIds];
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Insert TSF].lstNewAccountData =='+lstNewAccountData);
            
            List<Id> createdByUserList = new List<Id>();        // Used in: lstUserTerritory
            for(Account accData: lstNewAccountData)
                createdByUserList.add(accData.CreatedById);
            //changes for TM 1.0 to TM 2.0 Migration - Start
            List<Territory2> lstUserTerritory =                        // Used in: TSF, strTerritoryList, territoryNameList
                [SELECT ID,Name FROM Territory2 WHERE Id IN
                 (SELECT Territory2Id FROM UserTerritory2Association WHERE userid=: createdByUserList AND Territory2.Territory2Model.State ='Active')];
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[Insert TSF].lstUserTerritory =='+lstUserTerritory);
            
            List<TSF_vod__c> lstTSF = new List<TSF_vod__c>();
            Map<TSF_vod__c,TSF_vod__c> lstTSFfinal = new Map<TSF_vod__c,TSF_vod__c>();
            TSF_vod__c objTSF;
            TSF_vod__c objTSFParent;
            
            Set<ID> setNewAccountsForTSF = setNewAccountIds.clone();          // Used in: lstExistingTSF
            for(Account newAcc : lstNewAccountData)
                if(!string.isblank(newAcc.Primary_Parent_vod__c))
                setNewAccountsForTSF.add(newAcc.Primary_Parent_vod__c);
            system.debug('== [AGN_DCR2_Post_Approval_Processing].[DCRToAccount].[ATL,GAS_History,TSF Creation/Update].setNewAccountsForTSF =='+setNewAccountsForTSF);
            
            List<TSF_vod__c> lstExistingTSF =                        // Used in: TSF
                [SELECT External_Id_vod__c FROM TSF_vod__c WHERE Account_vod__c IN :setNewAccountsForTSF];
            system.debug('== [Query:lstExistingTSF] =='+lstExistingTSF);
            Set<String> SetTSFExistingExtrnlId = new Set<String>();
            
            for(TSF_vod__c exstTsf : lstExistingTSF)
                SetTSFExistingExtrnlId.add(exstTsf.External_Id_vod__c);
            if(lstUserTerritory != null && lstUserTerritory.size() > 0 && lstNewAccountData != null && lstNewAccountData.size() > 0) {
                for(Account objAccountTemp : lstNewAccountData) {
                    for(Territory2 objTerritory : lstUserTerritory) {
                        objTSF = new TSF_vod__c ();
                        objTSF.Account_vod__c = objAccountTemp.ID;
                        objTSF.Territory_vod__c = objTerritory.Name;
                        objTSF.Name = objTerritory.Name;
                        objTSF.Target_Manager_SMB__c = true;
                        objTSF.External_Id_vod__c=objAccountTemp.ID+'__'+objTerritory.Name;
                        system.debug('objTSF.External_Id_vod__c '+objTSF.External_Id_vod__c);
                        if(lstTSFfinal == null)
                        {   lstTSF.add(objTSF);
                         lstTSFfinal.put(objTSF,objTSF);
                        }
                        else
                        {
                            if(!lstTSFfinal.containsKey(objTSF))
                            {
                                lstTSF.add(objTSF);
                                lstTSFfinal.put(objTSF,objTSF);
                            }
                        }               
                        system.debug('lstTSFfinal1 '+lstTSFfinal);
                        system.debug('lstTSF1 '+lstTSF);
                        if(objAccountTemp.Primary_Parent_vod__c != null && !SetTSFExistingExtrnlId.contains(objAccountTemp.Primary_Parent_vod__c +'__' + objTerritory.Name)) {
                            objTSFParent = new TSF_vod__c ();
                            objTSFParent.Account_vod__c = objAccountTemp.Primary_Parent_vod__c;
                            objTSFParent.Territory_vod__c = objTerritory.Name;
                            objTSFParent.Name = objTerritory.Name;
                            objTSFParent.Target_Manager_SMB__c = true;
                            objTSF.External_Id_vod__c=objAccountTemp.ID+'__'+objTerritory.Name;
                            system.debug('objTSF.External_Id_vod__c '+objTSF.External_Id_vod__c);
                            if(lstTSFfinal == null)
                            {   lstTSF.add(objTSF);
                             lstTSFfinal.put(objTSF,objTSF);
                            }
                            else
                            {
                                if(!lstTSFfinal.containsKey(objTSF))
                                {
                                    lstTSF.add(objTSF);
                                    lstTSFfinal.put(objTSF,objTSF);
                                }
                            }
                            system.debug('lstTSFfinal2 '+lstTSFfinal);
                            system.debug('lstTSF2 '+lstTSF);
                        }
                    }
                }
            }
           //changes for TM 1.0 to TM 2.0 Migration - End
            if(lstTSF != null && lstTSF.size() > 0) {
                system.debug('== [DML:insert lstTSF] =='+lstTSF);
                upsert lstTSF;
                system.debug('== [DML:insert lstTSF].success ==');
            }
            // -------- GET USER'S TERRITORY AND UPDATE/INSERT TO TSF -------- //
        }  
        // -------- INSERT/UPDATE IN ATL, GAS_HISTORY & TSF FOR EACH ACCOUNT -------- //
    }


// AGN_DCR2_Post_Approval_Processing //