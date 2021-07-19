//19R3 reqNo: updated public with global in class name
global Without Sharing class AGN_ApexCaseProcessing{
    
    @AuraEnabled
    public static List<boolean> getbooleanAttribute(Id recordId){
        List<boolean> attributesList = new List<boolean>();
        Allergan_Customer_Registration_AGN__c acr;
        List<Allergan_Customer_Address_AGN__c> lstaddresses;
        List<Allergan_Customer_Contact_AGN__c> lstCustomerConts;
        Boolean ProcessBtnDisabled = false; 
        Boolean sendToSAPBtnDisabled = false;
        Boolean processagn;
        Boolean showSendSAPBtn;
        Boolean hasSAPIdForAllAdrs;
        Boolean hasEnableportalUserAllContacts;
        Boolean customerPortalBtnDisabled;
        String responseMessage = '';
        String registrationid;
        String paymentId;
        // added for netherlands requirement line 20
        Boolean showExtDataBtn = false;
        Boolean ExtDataBtnDisabled = false;
        List<Case> caseRecords = new list<case>();
        Case relatedCase = new Case(); 
        AGN_GCSP_Settings__c relatedGCSPSettings = new AGN_GCSP_Settings__c();
        List<AGN_GCSP_Settings__c> gcspSettingsRecords;
        User userid = [SELECT ID, Name, Position_AGN__c  FROM User WHERE Id=: UserInfo.getUserId()];
        //system.debug('@@userid'+userid);
        
        if (recordId.getSobjectType().getDescribe().getName() == 'Allergan_Customer_Payment_AGN__c'){
            paymentId = recordId;
            if(userid.Position_AGN__c == 'AR' || userid.Position_AGN__c == 'Admin' ){
                showSendSAPBtn = true;
                
            } 
        }else{
            registrationId = recordId;
            showSendSAPBtn = false;
        }
        if(registrationid != null)  
        {
            acr = [select  Id, 
                   Name,
                   RecordType.Name, 
                   Process_AGN__c, 
                   Case_AGN__c,
                   Processed_By_SAP_AGN__c,
                   SAP_Search_Performed__c, 
                   Ship_to_AC_validated_AGN__c, 
                   Documentation_provided_as_per_SOP__c, 
                   Address_Validated__c, 
                   Official_Websites_Used_AGN__c,
                   Case_AGN__r.Country_Code_AGN__c, 
                   Case_AGN__r.Account_Country_Code_AGN__c,
                   Online_Registration_AGN__c,
                   Allergan_Direct_Access_Requested_AGN__c,
                   Form_of_Payment_AGN__c,
                   Payment_Term_AGN__c,
                   Case_Category__c,
                   Case_AGN__r.OwnerId,
                   Denied_Parties_List_Checked_AGN__c,
                   ABN_NZBN_Extract_Attached_AGN__c,
                   SAP_Country_Code_AGN__c,
                   Processed_By_Okta_AGN__c
                   from Allergan_Customer_Registration_AGN__c where id=:registrationid limit 1];    
            //system.debug('@acr'+acr);
            
            processagn = acr.Process_AGN__c ; 
            //system.debug('@@processed'+processagn);
            
            
            
            lstAddresses =[SELECT ID, Name,RecordType.Name, Ship_To_AGN__c, Sold_To_AGN__c, Bill_To_AGN__c, SAP_ID_AGN__c, Parent_AGN__c,
                           SAP_Search_Term_1_AGN__c,SAP_Payment_Code_AGN__c,SAP_Payment_Term_Code_AGN__c,Form_Of_Payment_AGN__c,
                           Payment_Term_AGN__c, SAP_Action_AGN__c 
                           FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =:acr.id ];
            
            hasSAPIdForAllAdrs = true ; 
            for(Allergan_Customer_Address_AGN__c aca : lstAddresses){
                if((aca.SAP_ID_AGN__c==NULL || aca.SAP_ID_AGN__c=='') || (aca.RecordType.Name=='Amend')){
                    hasSAPIdForAllAdrs = false ;
                    break;
                }       
            }
            lstCustomerConts = [SELECT ID, Enable_Portal_User_AGN__c, Allergan_Direct_Access_Requested_AGN__c FROM Allergan_Customer_Contact_AGN__c Where Parent_AGN__c =: acr.Id];
            
            hasEnableportalUserAllContacts = false;
            customerPortalBtnDisabled = true;
            String RecordTypeName = acr.RecordType.Name;
            if((acr.Case_AGN__r.OwnerId == userid.Id) && ((acr.Process_AGN__c == true && userid.Position_AGN__c == 'DBA') || (acr.Process_AGN__c == false && userid.Position_AGN__c == 'Customer Service' && lstaddresses.isEmpty())) 
               && acr.Processed_By_Okta_AGN__c == false && (RecordTypeName.equalsIgnoreCase('New') || RecordTypeName.equalsIgnoreCase('Update'))){
                   for(Allergan_Customer_Contact_AGN__c acc : lstCustomerConts){
                       if(acc.Enable_Portal_User_AGN__c){
                           hasEnableportalUserAllContacts = true;
                           customerPortalBtnDisabled = false;    
                           ProcessBtnDisabled = true ;
                           break;
                       }
                       
                   }
               }
        }
        
        gcspSettingsRecords = [SELECT Name,
                               Online_Account_Management__c,
                               SendtoSAP_Password__c,
                               SendtoSAP_Post_Request_URL__c,
                               SendtoSAP_Username__c,
                               Allowed_User_Position_for_Portal_Access__c,
                               Is_Send_to_SAP_checklist_Required__c                                      
                               FROM AGN_GCSP_Settings__c 
                               WHERE Name =: acr.Case_AGN__r.Account_Country_Code_AGN__c  OR 
                               Name =:  acr.Case_AGN__r.Country_Code_AGN__c LIMIT 1 ];
        
        if (gcspSettingsRecords.size()>0){
            relatedGCSPSettings = gcspSettingsRecords[0];
        }
        
        if(String.isEmpty(relatedGCSPSettings.SendtoSAP_Post_Request_URL__c) && String.isEmpty(relatedGCSPSettings.SendtoSAP_Username__c) && String.isEmpty(relatedGCSPSettings.SendtoSAP_Password__c) ){
            showSendSAPBtn = false ;
        }
        else{
            showSendSAPBtn = true ;
        }   
        
        if((acr.Case_AGN__r.OwnerId != userid.id) || (acr.Process_AGN__c == true) || (acr.Processed_By_SAP_AGN__c == 'Success') || userid.Position_AGN__c !='DBA'){
            sendToSAPBtnDisabled = true;
         //   ExtDataBtnDisabled = true;
        }
        
        caseRecords = [SELECT OwnerId, Account_Country_Code_AGN__c, Country_Code_AGN__c, Case_Sub_Status_AGN__c FROM Case WHERE Id =: acr.Case_AGN__c LIMIT 1];
        
        if (caseRecords.size()>0) 
        {
            relatedCase = caseRecords[0];
        }
        if(
            (acr.Processed_By_SAP_AGN__c == 'Success'|| !showSendSAPBtn ) && (
                (relatedCase.OwnerId == userid.id && userid.Position_AGN__c == 'DBA') || (userid.Position_AGN__c == 'Admin' ) ) && (acr.Process_AGN__c == false)  
        )   
        {
            ProcessBtnDisabled = false ;
        }
        else{
            ProcessBtnDisabled = true ;
        }
       if(acr.Case_AGN__r.Country_Code_AGN__c == 'NL'){
           showSendSAPBtn = false; 
            showExtDataBtn = true;
          //    ProcessBtnDisabled = false;
        }
        attributesList.add(processagn);
        attributesList.add(hasSAPIdForAllAdrs);
        attributesList.add(hasEnableportalUserAllContacts);
        attributesList.add(customerPortalBtnDisabled);
        attributesList.add(showSendSAPBtn);
        attributesList.add(sendToSAPBtnDisabled);
        attributesList.add(ProcessBtnDisabled);
        attributesList.add(showExtDataBtn);
        attributesList.add(ExtDataBtnDisabled);
    //    //system.debug(processagn);
    //    //system.debug(hasSAPIdForAllAdrs);
    //    //system.debug(hasEnableportalUserAllContacts);
    //    //system.debug(customerPortalBtnDisabled);
    //    //system.debug(showSendSAPBtn);
    //    //system.debug(sendToSAPBtnDisabled);
    //    //system.debug(ProcessBtnDisabled);
    //    //system.debug('list'+attributesList);
        return attributesList;
        
    }
    
    @AuraEnabled
    public static Map<String, String> processCase(Id registrationId, Boolean SendToSAPDisable)
    {   
        String errorMsg='';
        String successMsg='';
        Boolean refreshPage;
        //Added for dupechecker validation//
        Map<String, String> resultMap = new Map<String, String>();
        //Added for dupechecker validation//
        Case relatedCase = new Case();  
        List<Allergan_Customer_Address_AGN__c> lstaddresses;
        boolean flagAllAddrCheckedOK = true;
        Allergan_Customer_Registration_AGN__c acr = [select  Id, 
                                                         Name,
                                                         RecordType.Name, 
                                                         Process_AGN__c, 
                                                         Case_AGN__c,
                                                         Country_Code_AGN__c,
                                                         Processed_By_SAP_AGN__c,
                                                         SAP_Search_Performed__c, 
                                                         Ship_to_AC_validated_AGN__c, 
                                                         Documentation_provided_as_per_SOP__c, 
                                                         Address_Validated__c, 
                                                         Official_Websites_Used_AGN__c,
                                                         Case_AGN__r.Country_Code_AGN__c, 
                                                         Case_AGN__r.Account_Country_Code_AGN__c,
                                                         Online_Registration_AGN__c,
                                                         Allergan_Direct_Access_Requested_AGN__c,
                                                         Form_of_Payment_AGN__c,
                                                         Payment_Term_AGN__c,
                                                         Case_AGN__r.OwnerId,
                                                         //      Denied_Parties_List_Checked_AGN__c,
                                                         //      ABN_NZBN_Extract_Attached_AGN__c,
                                                         //      Case_Category__c,
                                                         SAP_Country_Code_AGN__c,
                                                         Processed_By_Okta_AGN__c
                                                         from Allergan_Customer_Registration_AGN__c where id=:registrationid limit 1];
        
        
        lstAddresses =[SELECT ID, Name,RecordType.Name, Ship_To_AGN__c, Sold_To_AGN__c, Bill_To_AGN__c, SAP_ID_AGN__c, Parent_AGN__c,
                       SAP_Search_Term_1_AGN__c,SAP_Payment_Code_AGN__c,SAP_Payment_Term_Code_AGN__c,Form_Of_Payment_AGN__c,
                       Payment_Term_AGN__c, SAP_Action_AGN__c,Use_Existing_Account_AGN__c 
                       FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =:acr.id ];        
        for(Allergan_Customer_Address_AGN__c tempAddr : lstAddresses)
        {
            if ( ( tempAddr.SAP_ID_AGN__c == Null || tempAddr.SAP_ID_AGN__c == Null ) && acr.Processed_By_SAP_AGN__c != null)
            {
                String myMsg = 'SAPID Required for '+tempAddr.Name+' to Process'; 
                errorMsg = myMsg;
                flagAllAddrCheckedOK = false; 
            }  
        }                   
        
        
        //Calling the dupechecker method for validations//
        
        
            ////system.debug('calling dupechecker');
            ////system.debug('errormsg---->'+errorMsg);
            
            resultMap = dupecheckerValidations(acr,lstAddresses);
            ////system.debug('resultMap from dup validation-------->' +resultMap);
            if(!resultMap.isEmpty() && resultMap.get('ERROR').contains('Please acknowledge the')){
                flagAllAddrCheckedOK = false;
                ////system.debug('errormsg---->'+errorMsg);
                ////system.debug('errmsg---->'+errMsg);
                errorMsg= errorMsg + '\n' +resultMap.get('ERROR');
                ////system.debug('errormsg->'+errorMsg);
            }   
        
            
        //Calling the dupechecker method for validations//
        
        if(flagAllAddrCheckedOK)
        {
            acr.Process_AGN__c = true;
            acr.Processed_By_AGN__c = UserInfo.getUserId();
            acr.Processed_Date_AGN__c = date.today();
            relatedCase.Id = acr.Case_AGN__c;
            relatedCase.Registration_Record_Processed__c = true;// R15
            //system.debug('acr values: '+acr);
            //system.debug('relatedCase'+relatedCase);
            String DMLProcessSucErrMsg ;
            //update acr;
            //update relatedCase;
            try{         
                update acr;
                Database.SaveResult sr = Database.update(relatedCase, false);//R15 strt
                if(sr.isSuccess())
                {
                    //system.debug('Record Updated');
                }
                else
                {
                    //system.debug('Sr:'+sr);
                } //R15 end
                //system.debug('Update') ; 
                successMsg = System.Label.CaseSuccessfulProcess; 
                refreshPage =true;
                //update relatedCase;
            }
            catch(DMLException dmlEx){
                DMLProcessSucErrMsg = dmlEx.getMessage();
            }
            finally{
                errorMsg = DMLProcessSucErrMsg;
            } 
        } // flagAllAddrCheckedOK - If check closed               
        
        if(String.isBlank(successMsg)) {
            //throw new AuraHandledException(errorMsg); 
            //system.debug('error----------->'+errorMsg);
            resultMap.put('ERROR',errorMsg);
            //system.debug('problem----->'+resultMap);
        }
        else {
            //system.debug('succmsg---->'+successMsg);
            resultMap.put('SUCCESS',successMsg);
        }
        //system.debug('issue----->'+resultMap);
        return resultMap;
    }
    @AuraEnabled
    public static Map<String, String> customerPortalApex(id registrationId)
    {    
        registrationid = registrationId;
        String errorMsg;
        String successMsg;
        Boolean refreshPage;
        Case relatedCase = new Case();
        //system.debug('Call customerPortalApex');
        String DMLSucErrMsg ;
        Allergan_Customer_Registration_AGN__c acr = [select  Id, 
                                                     Name,
                                                     RecordType.Name, 
                                                     Process_AGN__c, 
                                                     Case_AGN__c, 
                                                     Processed_By_SAP_AGN__c,
                                                     SAP_Search_Performed__c, 
                                                     Ship_to_AC_validated_AGN__c, 
                                                     Documentation_provided_as_per_SOP__c, 
                                                     Address_Validated__c, 
                                                     Official_Websites_Used_AGN__c,
                                                     Case_AGN__r.Country_Code_AGN__c, 
                                                     Case_AGN__r.Account_Country_Code_AGN__c,
                                                     Online_Registration_AGN__c,
                                                     Allergan_Direct_Access_Requested_AGN__c,
                                                     Form_of_Payment_AGN__c,
                                                     Payment_Term_AGN__c,
                                                     Case_AGN__r.OwnerId,
                                                     //      Denied_Parties_List_Checked_AGN__c,
                                                     //      ABN_NZBN_Extract_Attached_AGN__c,
                                                     //      Case_Category__c,
                                                     SAP_Country_Code_AGN__c,
                                                     Processed_By_Okta_AGN__c
                                                     from Allergan_Customer_Registration_AGN__c where id=:registrationid limit 1];
        
        try{
            
            Allergan_Customer_Registration_AGN__c acrNew = [SELECT Id, Account_AGN__c, Okta_Enabled_AGN__c, Language_AGN__c,
                                                            Country_Code_AGN__c,SAP_Country_Code_AGN__c, Email_AGN__c, Online_Registration_AGN__c, 
                                                            Allergan_Direct_Access_Requested_AGN__c, First_Name_AGN__c, Last_Name_AGN__c,
                                                            Processed_By_Okta_AGN__c, Process_AGN__c, Processed_By_AGN__c, Processed_Date_AGN__c  
                                                            from Allergan_Customer_Registration_AGN__c where Id =:acr.Id];
            acrNew.Processed_By_Okta_AGN__c = true;
            acrNew.Process_AGN__c = true;
            acrNew.Processed_By_AGN__c = UserInfo.getUserId();
            acrNew.Processed_Date_AGN__c = date.today();
            acrNew.Online_Registration_Step_AGN__c = '5';
            relatedCase.Registration_Record_Processed__c = true;// R15
            
            if ((Boolean)AGN_GCSP_Settings__c.getValues(acrNew.Country_Code_AGN__c).get('Is_Okta_Enabled_AGN__c')){               
                
                String countryCode;
                if(!String.isEmpty(acrNew.SAP_Country_Code_AGN__c)){
                    countryCode = acrNew.SAP_Country_Code_AGN__c;
                }
                else{
                    countryCode = acrNew.Country_Code_AGN__c;
                }
                String DisplayMsg = AGN_GCSP_OktaProcessNew.processADRequestOkta(acrNew);
                /*if(countryCode.equalsIgnoreCase('AN') 
|| countryCode.equalsIgnoreCase('AU') 
|| countryCode.equalsIgnoreCase('NZ')
|| countryCode.equalsIgnoreCase('BR')
){

AGN_OktaProcessNew.processADRequestOkta(acrNew);
}
else if(acrNew.Account_AGN__c !=null){
AGN_OktaProcess.processADRequestOkta(acrNew);                         
}
*/
                if(!String.isEmpty(DisplayMsg)){
                    DMLSucErrMsg = DisplayMsg;
                    refreshPage =true;
                    errorMsg = DMLSucErrMsg;
                    
                    
                }else{
                    DMLSucErrMsg =  System.Label.AGN_OAM_Portal_Access_Activated;  
                    refreshPage =true;
                    successMsg = DMLSucErrMsg;
                    
                    //system.debug('acr values: '+acrNew);
                    
                    List<Allergan_Customer_Registration_AGN__c> tempCRAList = new List<Allergan_Customer_Registration_AGN__c>();
                    tempCRAList.add(acrNew);              
                    String objCustomerAdd = 'Allergan_Customer_Registration_AGN__c';
                    SObjectType objCRAType = ((SObject)(Type.forName('Schema.'+objCustomerAdd).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(tempCRAList,objCRAType,'UPDATE');
                    
                    update acrNew; 
                    
                    //system.debug('acr record is successfully processed by okta:::::'+acrNew);
                    Database.SaveResult sr = Database.update(relatedCase, false);//R15 strt
                    if(sr.isSuccess())
                    {
                        //system.debug('Record Updated');
                    }
                    else
                    {
                        //system.debug('Sr:'+sr);
                    } //R15 end
                    
                } 
            }
        }
        catch(Exception e){
            DMLSucErrMsg = e.getMessage();
            refreshPage =true;
            errorMsg = DMLSucErrMsg;
            
        }
        
        Map<String, String> resultMap = new Map<String, String>();
        resultMap.put('SUCCESS','');
        resultMap.put('ERROR','');
        if(String.isBlank(successMsg)) {
            //throw new AuraHandledException(errorMsg); 
            resultMap.put('ERROR',errorMsg);
        }
        else {
            resultMap.put('SUCCESS',successMsg);
        }
        return resultMap;
    }
    
    @AuraEnabled
    global static Boolean disableSendButton(Boolean disable)
    {
        //system.debug('in disable method' + disable);
        Boolean sendToSAPBtnDisabled  = disable;
       // Boolean ExtDataBtnDisabled = disable;
        //system.debug('in disable method' + sendToSAPBtnDisabled);
        return sendToSAPBtnDisabled;
    }
    
    //Added a new method for enabling dupechecker validations //
    @AuraEnabled
    public static Map<String, String> dupecheckerValidations(Allergan_Customer_Registration_AGN__c acr, List<Allergan_Customer_Address_AGN__c> aca){
        boolean flagAllAddrCheckedOK = true; 
        boolean flagAllConCheckedOK = true;
        Boolean refreshPage;
        String duperrorMsg = '';
        String dupsuccessMsg = '';
        
        for(Allergan_Customer_Address_AGN__c tempAddr : aca)
        {
            if(tempAddr.Use_Existing_Account_AGN__c == false && tempAddr.RecordType.Name == 'New') {
                String myMsg = 'Please acknowledge the matching suggestion on '+tempAddr.Name;
                duperrorMsg = duperrorMsg + '\n' + myMsg;
                flagAllAddrCheckedOK = false; 
            }
    }
        List<Allergan_Customer_Contact_AGN__c> customerContacts = [SELECT ID, Name, Use_Existing_Account_AGN__c 
                                                                   FROM Allergan_Customer_Contact_AGN__c 
                                                                   WHERE Parent_AGN__c =:acr.Id ];
        for(Allergan_Customer_Contact_AGN__c customerContact : customerContacts) {
            if(customerContact.Use_Existing_Account_AGN__c == false) {
                String myMsg = 'Please acknowledge the HCP matching suggestion on '+customerContact.Name;
                duperrorMsg = duperrorMsg + '\n' + myMsg;
                flagAllConCheckedOK = false; 
            }
        }
            
        
        Map<String, String> resultMap = new Map<String, String>();
        resultMap.put('SUCCESS','');
        resultMap.put('ERROR','');
        if(String.isBlank(dupsuccessMsg)) {
            //throw new AuraHandledException(errorMsg); 
            resultMap.put('ERROR',duperrorMsg);
        }
        else if(String.isBlank(duperrorMsg)){
            return resultMap;
        }
        else {
            resultMap.put('SUCCESS',dupsuccessMsg);
        }
        return resultMap;
        
        
    }
    //Added a new method for enabling dupechecker validations //
    
    @AuraEnabled
    public static Map<String, String> sendtosap(Id registrationId)
    {  
        boolean flagAllAddrCheckedOK = true; 
        boolean flagAllConCheckedOK = true;
        //Added for CA CR request -----> If allergan customer registration country code is not CA or Case.Adobe_Sign_Status_for_Agreement_agn__c != ‘Signed’ then custom validation is thrown//
        boolean adobeSigned= true;
        //Added for CA CR request -----> If allergan customer registration country code is not CA or Case.Adobe_Sign_Status_for_Agreement_agn__c != ‘Signed’ then custom validation is thrown//
        Boolean refreshPage;
        String errorMsg = '';
        String successMsg = '';
        String SAPID;
        //Added for dupechecker validation//
        Map<String, String> resultMap = new Map<String, String>();
        //Added for dupechecker validation//
        Allergan_Customer_Registration_AGN__c acr;
        list<AGN_GCSP_Settings__c> gcspSettingsRecords;
        List<Allergan_Customer_Address_AGN__c> lstaddresses;
        AGN_GCSP_Settings__c relatedGCSPSettings;
        //system.debug('registrationId@@@ '+registrationid);
        if(registrationId != null)  
        {
            acr = [select  Id, 
                   Name,
                   RecordType.Name, 
                   Process_AGN__c, 
                   Case_AGN__c,
                   Case_AGN__r.Adobe_Sign_Status_for_Agreement_agn__c,
                   Country_Code_AGN__c,
                   Processed_By_SAP_AGN__c,
                   SAP_Search_Performed__c, 
                   Ship_to_AC_validated_AGN__c, 
                   Documentation_provided_as_per_SOP__c, 
                   Address_Validated__c, 
                   Official_Websites_Used_AGN__c,
                   Case_AGN__r.Country_Code_AGN__c, 
                   Case_AGN__r.Account_Country_Code_AGN__c,
                   Online_Registration_AGN__c,
                   Allergan_Direct_Access_Requested_AGN__c,
                   Form_of_Payment_AGN__c,
                   Payment_Term_AGN__c,
                   Case_AGN__r.OwnerId,
                   //      Denied_Parties_List_Checked_AGN__c,
                   //      ABN_NZBN_Extract_Attached_AGN__c,
                   //      Case_Category__c,
                   SAP_Country_Code_AGN__c,
                   Processed_By_Okta_AGN__c, 
                   Use_Existing_Account_AGN__c
                   from Allergan_Customer_Registration_AGN__c where id=:registrationid limit 1];
        }    
         String country = acr.SAP_Country_Code_AGN__c;
        if(String.isEmpty(acr.SAP_Country_Code_AGN__c)){
            country = acr.Country_Code_AGN__c;
        }
        Boolean isDeactivate = false;
        
        
        
        lstAddresses =[SELECT ID, Name,RecordType.Name, Ship_To_AGN__c, Sold_To_AGN__c, Bill_To_AGN__c, SAP_ID_AGN__c, Parent_AGN__c,
                       SAP_Search_Term_1_AGN__c,SAP_Payment_Code_AGN__c,SAP_Payment_Term_Code_AGN__c,Form_Of_Payment_AGN__c,
                       Payment_Term_AGN__c, SAP_Action_AGN__c, Use_Existing_Account_AGN__c 
                       FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =:acr.id ];
        for(Allergan_Customer_Address_AGN__c tempAddr : lstAddresses)
        {
            if ( tempAddr.SAP_Search_Term_1_AGN__c == Null )
            {
                String myMsg = 'SAP Search Term 1 required  for '+tempAddr.Name+' to Process' ;
                errorMsg = errorMsg + '\n' + myMsg;
                //system.debug('errorMsgfirst@@ '+errorMsg);
                flagAllAddrCheckedOK = false; 
                
            } 
            
            if(String.isNotBlank(tempAddr.SAP_Action_AGN__c) &&  tempAddr.SAP_Action_AGN__c == '3'){
                isDeactivate = true;
            }
        }
        
        
        gcspSettingsRecords = [SELECT Name,
                                   Online_Account_Management__c,
                                   SendtoSAP_Password__c,
                                   SendtoSAP_Post_Request_URL__c,
                                   SendtoSAP_Username__c,
                                   Allowed_User_Position_for_Portal_Access__c,
                                   Is_Send_to_SAP_checklist_Required__c                                      
                                   FROM AGN_GCSP_Settings__c 
                                   WHERE Name =: acr.Case_AGN__r.Account_Country_Code_AGN__c  OR 
                                   Name =:  acr.Case_AGN__r.Country_Code_AGN__c LIMIT 1 ];
        
        if (gcspSettingsRecords.size()>0){
            relatedGCSPSettings = gcspSettingsRecords[0];
        }
        
        
        //Calling the dupechecker method for validations//
        
        
            //system.debug('calling dupechecker');
            //system.debug('errormsg---->'+errorMsg);
             
            resultMap = dupecheckerValidations(acr,lstAddresses);
            //system.debug('resultMap from dup validation-------->' +resultMap);
            if(!resultMap.isEmpty() && resultMap.get('ERROR').contains('Please acknowledge the')){
                flagAllAddrCheckedOK = false;
                //system.debug('errormsg---->'+errorMsg);
                ////system.debug('errmsg---->'+errMsg);
                errorMsg= errorMsg + '\n' +resultMap.get('ERROR');
                //system.debug('errormsg->'+errorMsg);
            }   
        
        
        //Calling the dupechecker method for validations//
        
        
        //if((acr.SAP_Search_Performed__c == false) || (acr.Ship_to_AC_validated_AGN__c == false) || (acr.Documentation_provided_as_per_SOP__c == false) || (acr.Address_Validated__c == false) || (acr.Official_Websites_Used_AGN__c == false))
        if(country == 'AU' || country == 'NZ'){
            if((!relatedGCSPSettings.Is_Send_to_SAP_checklist_Required__c) || isDeactivate ||((acr.SAP_Search_Performed__c ) && (acr.Ship_to_AC_validated_AGN__c ) && 
                                                                                              (acr.Documentation_provided_as_per_SOP__c ) && (acr.Address_Validated__c ) 
                                                                                              //     && (acr.Denied_Parties_List_Checked_AGN__c ) 
                                                                                              //     && (acr.ABN_NZBN_Extract_Attached_AGN__c)
                                                                                              && (flagAllAddrCheckedOK)
                                                                                              && (flagAllConCheckedOK)
                                                                                             ))
            { 
                //system.debug('Sending SAP Request>>>>>>>>>>>>>');
                SAPID = AGN_SendToSapController.sendNow(acr.ID);
                String myMsg = SAPID; 
                if(myMsg.contains('succes')) {
                    successMsg = myMsg;
                }
                else {
                    errorMsg = errorMsg + '\n' + myMsg;
                }
                //system.debug('@@@@@@@ SAP ID @@@@ :'+SAPID); 
                
            }
            else if(acr.SAP_Search_Performed__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Ship_to_AC_validated_AGN__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Documentation_provided_as_per_SOP__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Address_Validated__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            /*else if(acr.Denied_Parties_List_Checked_AGN__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }else if(acr.ABN_NZBN_Extract_Attached_AGN__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }*/     
        }
        else if(country == 'NL'){
            if(acr.SAP_Search_Performed__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Ship_to_AC_validated_AGN__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Documentation_provided_as_per_SOP__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Address_Validated__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Official_Websites_Used_AGN__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }   
        }
        
        
        else if(country == 'CA'){
            
            //Added for CA CR request -----> If allergan customer registration country code is not CA or Case.Adobe_Sign_Status_for_Agreement_agn__c != ‘Signed’ then custom validation is thrown//
            if(acr.Case_AGN__r.Adobe_Sign_Status_for_Agreement_agn__c !='Signed'){
                String myMsg = 'Please complete eSignature process' ;
                errorMsg = errorMsg + '\n' + myMsg;
                //system.debug('errorMsgfirst@@ '+errorMsg);
                adobeSigned = false;
            }
            //Added for CA CR request -----> If allergan customer registration country code is not CA or Case.Adobe_Sign_Status_for_Agreement_agn__c != ‘Signed’ then custom validation is thrown//
            
            if(((!relatedGCSPSettings.Is_Send_to_SAP_checklist_Required__c) ||((acr.SAP_Search_Performed__c ) && (acr.Ship_to_AC_validated_AGN__c ) && 
                                                                              (acr.Documentation_provided_as_per_SOP__c ) && (acr.Address_Validated__c ) && (acr.Official_Websites_Used_AGN__c ) && (flagAllAddrCheckedOK)
                                                                             )) && (adobeSigned)) // Extra condition appended for checking Adobe Sign//
            { 
                //system.debug('Sending SAP Request>>>>>>>>>>>>>');
                SAPID = AGN_SendToSapController.sendNow(acr.ID);
                String myMsg = SAPID; 
                if(myMsg.contains('succes')) {
                    successMsg = myMsg;
                }
                else {
                    errorMsg = errorMsg + '\n' + myMsg;
                }
                //system.debug('@@@@@@@ SAP ID @@@@ :'+SAPID); 
                
            }
            else if(acr.SAP_Search_Performed__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Ship_to_AC_validated_AGN__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Documentation_provided_as_per_SOP__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Address_Validated__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Official_Websites_Used_AGN__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }   

        }
        
        
        else
   /*         gcspSettingsRecords = [SELECT Name,
                                   Online_Account_Management__c,
                                   SendtoSAP_Password__c,
                                   SendtoSAP_Post_Request_URL__c,
                                   SendtoSAP_Username__c,
                                   Allowed_User_Position_for_Portal_Access__c,
                                   Is_Send_to_SAP_checklist_Required__c                                      
                                   FROM AGN_GCSP_Settings__c 
                                   WHERE Name =: acr.Case_AGN__r.Account_Country_Code_AGN__c  OR 
                                   Name =:  acr.Case_AGN__r.Country_Code_AGN__c LIMIT 1 ];
        
        if (gcspSettingsRecords.size()>0){
            relatedGCSPSettings = gcspSettingsRecords[0];
        }*/
        {
            if((!relatedGCSPSettings.Is_Send_to_SAP_checklist_Required__c) ||((acr.SAP_Search_Performed__c ) && (acr.Ship_to_AC_validated_AGN__c ) && 
                                                                              (acr.Documentation_provided_as_per_SOP__c ) && (acr.Address_Validated__c ) && (acr.Official_Websites_Used_AGN__c ) && (flagAllAddrCheckedOK)
                                                                             ))
            { 
                //system.debug('Sending SAP Request>>>>>>>>>>>>>');
                SAPID = AGN_SendToSapController.sendNow(acr.ID);
                String myMsg = SAPID; 
                if(myMsg.contains('succes')) {
                    successMsg = myMsg;
                }
                else {
                    errorMsg = errorMsg + '\n' + myMsg;
                }
                //system.debug('@@@@@@@ SAP ID @@@@ :'+SAPID); 
                
            }
            else if(acr.SAP_Search_Performed__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Ship_to_AC_validated_AGN__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Documentation_provided_as_per_SOP__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Address_Validated__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }
            else if(acr.Official_Websites_Used_AGN__c == false){
                String myMsg = System.Label.AGN_Send_To_SAP_Validation; 
                errorMsg = errorMsg + '\n' + myMsg;
            }   
        }
        
       if(String.isBlank(successMsg)) {
            //throw new AuraHandledException(errorMsg); 
            //system.debug('successMsg---->'+successMsg);
            resultMap.put('ERROR',errorMsg);
        }
        else if(String.isBlank(errorMsg)){
            //system.debug('successMsg---->'+successMsg);
            //system.debug('resultMap---->'+resultMap);
            //Added by Aritra for stopping loader after sendtoSAP is done//
            resultMap.put('SUCCESS',successMsg);
            ////Added by Aritra for stopping loader after sendtoSAP is done//
            return resultMap;
        }
        else {
            
            //system.debug('resultMap---->'+resultMap);
            resultMap.put('SUCCESS',successMsg);
            //system.debug('successMsg---->'+successMsg);
        }
        //system.debug('finalresultMap-------->' +resultMap);
        return resultMap;
        
        
    }    
    @AuraEnabled
    public static List<Allergan_Customer_Address_AGN__c> createExcel(Id recordId){
       List<Allergan_Customer_Address_AGN__c> fieldsList = [SELECT Name,Account_AGN__c,Account_AGN__r.Name,SAP_Name_1_AGN__c,SAP_Name_2_AGN__c,
                                                                SAP_Name_3_AGN__c,SAP_Search_Term_1_AGN__c,Address_Line_1_AGN__c,
                                                                City_AGN__c,Phone_AGN__c,
                                                                Zip_AGN__c,Fax_AGN__c,
                                                                Email_AGN__c,Customer_Group_AGN__c,Payment_Term_AGN__c,Payment_Term_AGN__r.Name,Payment_Term_AGN__r.Payment_Term_Label_AGN__c,
                                                                Form_Of_Payment_AGN__c,Form_Of_Payment_AGN__r.Name,Form_Of_Payment_AGN__r.SAP_Code_AGN__c,Customer_group_1_AGN__c,Customer_group_2_AGN__c,
                                                                Doctors_First_Name_AGN__c,State_License_Number_AGN__c,
                                                                Coolsculpting_Machine_AGN__c, KB23_Article_AGN__c,Parent_AGN__r.Name,Parent_AGN__r.First_Name_AGN__c,
                                                                Parent_AGN__r.Last_Name_AGN__c,Sold_To_AGN__c,Ship_To_AGN__c,Bill_To_AGN__c,SAP_Referenced_Customer_ID_AGN__c,
                                                                SAP_Account_Group_AGN__c,VAT_Number_AGN__c,SWIFT_BIC_AGN__c,SAP_ID_AGN__c,RecordType.Name
                                                                FROM Allergan_Customer_Address_AGN__c where Parent_AGN__c =:recordId];
        //system.debug('fieldsList' + fieldsList);
        return fieldsList;
    }
    public pagereference sendtosapcred(){
        return null;
    }
}