//19R3 reqNo: updated public with global in class name
global class AGN_ApexProcessButton{
    public Allergan_Customer_Registration_AGN__c acr{get;set;}
    public string registrationid{get;set;}
    public string paymentId{get;set;} // by Sharon for Credit Integration
    public boolean processagn{set;get;}
    public user userid{get;set;}
    public list<AGN_GCSP_Settings__c> gcspSettingsRecords{get;set;}
    public AGN_GCSP_Settings__c relatedGCSPSettings{get;set;}
    public list<case> caseRecords{get;set;}
    public case relatedCase{get;set;}
    Public List<Allergan_Customer_Address_AGN__c> lstaddresses{get;set;}
    public String SAPID{get;set;}
    public boolean hasSAPIdForAllAdrs{get;set;}
    public boolean ProcessBtnDisabled {get;set;}
    public boolean showSendSAPBtn {get;set;}
    public static boolean sendToSAPBtnDisabled {get;set;} //19R3 reqNo: updated with static word
    public string URLForPage{get;set;}
    public Boolean refreshPage {get;set;}    
    public boolean paymentFormCheck {get;set;}    //R15 Niladri       
    public boolean customerPortalBtnDisabled{get;set;}    // added by prince
    public String responseMessage {get;set;}    // by Sharon for Credit Integration
    
    public boolean hasEnableportalUserAllContacts{get;set;}
    public boolean showEnablePortalAccessBtn {get; set;}
   // public boolean showsendToOktaBtn {get; set;}
    
    Public List<Allergan_Customer_Contact_AGN__c> lstCustomerConts{get;set;}
    
    public AGN_ApexProcessButton(ApexPages.StandardController controller){
        
        responseMessage = '';
        caseRecords = new list<case>();
        relatedCase = new Case(); 
        relatedGCSPSettings = new AGN_GCSP_Settings__c();
        userid = [SELECT ID, Name, Position_AGN__c  FROM User WHERE Id=: UserInfo.getUserId()];
        Id recordId = ApexPages.currentPage().getParameters().get('Id');
        
        
        // by Sharon for Credit Integration
        if (recordId.getSobjectType().getDescribe().getName() == 'Allergan_Customer_Payment_AGN__c'){
            paymentId = recordId;
            if(userid.Position_AGN__c == 'AR' || userid.Position_AGN__c == 'Admin' ){
                showSendSAPBtn = true;
            } 
        }else{
            registrationId = recordId;
            showSendSAPBtn = false;
        }
        
        
        URLForPage = ApexPages.currentPage().getHeaders().get('Host');
        
        
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
            
            processagn = acr.Process_AGN__c ;   
            //R15 Niladri
            /*if(acr.Case_Category__c == 'Cadastro Novo' || acr.Case_Category__c == null){
if(acr.Form_of_Payment_AGN__c == null && acr.Payment_Term_AGN__c == null){
paymentFormCheck = true;                    
}
}*/
            
            /*address =[SELECT Ship_To_AGN__c, Sold_To_AGN__c, Bill_To_AGN__c, SAP_ID_AGN__c, Parent_AGN__c FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =:acr.id ];
SAPID = address.SAP_ID_AGN__c;
*/
            lstAddresses =[SELECT ID, Name,RecordType.Name, Ship_To_AGN__c, Sold_To_AGN__c, Bill_To_AGN__c, SAP_ID_AGN__c, Parent_AGN__c,
                           SAP_Search_Term_1_AGN__c,SAP_Payment_Code_AGN__c,SAP_Payment_Term_Code_AGN__c,Form_Of_Payment_AGN__c,
                           Payment_Term_AGN__c, SAP_Action_AGN__c 
                           FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =:acr.id ];
            //SAPID = address.SAP_ID_AGN__c; 
            
            /* Added by Ravi --- Start            
            if(acr.Case_Category__c == 'Cadastro Novo' || acr.Case_Category__c == null){
                //if(acr.Form_of_Payment_AGN__c == null && acr.Payment_Term_AGN__c == null){
                for(Allergan_Customer_Address_AGN__c cra : lstAddresses){
                    if(!cra.Ship_To_AGN__c && cra.Form_Of_Payment_AGN__c == null && cra.Payment_Term_AGN__c == null){ 
                        paymentFormCheck = true;  
                    }                       
                }                                       
                // }                                
            }
             Added by Ravi --- End */ 
            hasSAPIdForAllAdrs = true ; 
            for(Allergan_Customer_Address_AGN__c acr : lstAddresses){
                if((acr.SAP_ID_AGN__c==NULL || acr.SAP_ID_AGN__c=='') || (acr.RecordType.Name=='Amend')){
                    hasSAPIdForAllAdrs = false ;
                    break;
                }       
            }
            
            /*  Added by Ravi for Show and hide the Send to Okta Button -- Start */
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
                
             
             /* Added by Ravi for Show and hide the Send to Okta Button  -- End */
            
        }
        
        
        /*****************************/
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
        } 
        
        
        /*****************************/ 
        
        caseRecords = [SELECT Id, OwnerId, Account_Country_Code_AGN__c, Country_Code_AGN__c, Case_Sub_Status_AGN__c FROM Case WHERE Id =: acr.Case_AGN__c LIMIT 1];
        
        if (caseRecords.size()>0) 
        {
            relatedCase = caseRecords[0];
        }
        
        /*if( (relatedCase.OwnerId != userid.id) || (acr.Process_AGN__c == true) || (acr.Processed_By_SAP_AGN__c == 'Success')||  userid.Position_AGN__c != 'DBA' ){ 
system.debug('entered here'+relatedCase.OwnerId+'user id'+userid.id);
sendToSAPBtnDisabled = true ; 
}

if ( (relatedCase.OwnerId != userid.id) || 
(userid.Position_AGN__c != 'Admin' || userid.Position_AGN__c != 'DBA')|| 
(acr.Processed_By_SAP_AGN__c == 'In Progress' || acr.Processed_By_SAP_AGN__c == 'Failure' || acr.Processed_By_SAP_AGN__c == '' || acr.Processed_By_SAP_AGN__c == NULL)
)*/
        
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
       
        /* added by prince
        if(((relatedCase.OwnerId == userid.id && userid.Position_AGN__c == 'Customer Service')) && (acr.Allergan_Direct_Access_Requested_AGN__c == true) && ( acr.Online_Registration_AGN__c == true) && lstaddresses.size()==0 && (acr.Process_AGN__c == false))
        {
            customerPortalBtnDisabled = false ;
        }
        else{
            customerPortalBtnDisabled = true;
        }            
        // end prince      */
            
    }
    
    
    public pagereference process()
    {
        boolean flagAllAddrCheckedOK = true;         
        
        for(Allergan_Customer_Address_AGN__c tempAddr : lstAddresses)
        {
            if ( ( tempAddr.SAP_ID_AGN__c == Null || tempAddr.SAP_ID_AGN__c == Null ) && acr.Processed_By_SAP_AGN__c != null)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'SAPID Required for '+tempAddr.Name+' to Process'); 
                ApexPages.addMessage(myMsg);
                flagAllAddrCheckedOK = false; 
                break;
            }  
        }                   
        
        if(flagAllAddrCheckedOK)
        {
            acr.Process_AGN__c = true;
            acr.Processed_By_AGN__c = UserInfo.getUserId();
            acr.Processed_Date_AGN__c = date.today();
            relatedCase.Registration_Record_Processed__c = true;// R15
            System.debug('acr values: '+acr);
            System.debug('Related Case::'+relatedCase);
            ApexPages.Message DMLProcessSucErrMsg ;
            try{         
                update acr;
                
                Database.SaveResult sr = Database.update(relatedCase, false);//R15 strt
                if(sr.isSuccess())
                {
                    System.debug('Record Updated');
                }
                else
                {
                    System.debug('Sr:'+sr);
                } //R15 end
                System.debug('Update') ; 
                DMLProcessSucErrMsg = new ApexPages.Message(ApexPages.Severity.confirm, System.Label.CaseSuccessfulProcess); 
                
                /******* start delay *******
                Integer start = System.Now().millisecond();
                while(System.Now().millisecond()< start+5000){ 
                }
                ******* End Delay ******/
                
                refreshPage =true;
            }
            catch(DMLException dmlEx){
                DMLProcessSucErrMsg = new ApexPages.Message(ApexPages.severity.Error, dmlEx.getMessage());
            }
            finally{
                ApexPages.addMessage(DMLProcessSucErrMsg);
                
              /*  
                //***************** If SSO is enabled for the country ****** Start ******
                Allergan_Customer_Registration_AGN__c acrNew = [SELECT Id, Account_AGN__c, Okta_Enabled_AGN__c,  
                                                                Country_Code_AGN__c, SAP_Country_Code_AGN__c, Email_AGN__c, Online_Registration_AGN__c, 
                                                                Allergan_Direct_Access_Requested_AGN__c, First_Name_AGN__c, Last_Name_AGN__c, Language_AGN__c
                                                                from Allergan_Customer_Registration_AGN__c where Id =:acr.Id];
                
                
                system.debug('Country_Code_AGN__c===========>'+ acrNew.Country_Code_AGN__c);
                system.debug('Is_Okta_Enabled_AGN__c===========>'+ AGN_GCSP_Settings__c.getValues(acrNew.Country_Code_AGN__c).get('Is_Okta_Enabled_AGN__c'));
                
                Boolean isOktaEnable = false;
                
                if(AGN_GCSP_Settings__c.getValues(acrNew.Country_Code_AGN__c).get('Is_Okta_Enabled_AGN__c') == null){
                    isOktaEnable = false;
                }
                else{
                    isOktaEnable = (Boolean)AGN_GCSP_Settings__c.getValues(acrNew.Country_Code_AGN__c).get('Is_Okta_Enabled_AGN__c');
                }
                System.debug('isOktaEnable-->' + isOktaEnable);
                if (isOktaEnable){
                    String countryCode;
                    if(!String.isEmpty(acrNew.SAP_Country_Code_AGN__c)){
                        countryCode = acrNew.SAP_Country_Code_AGN__c;
                    }
                    else{
                        countryCode = acrNew.Country_Code_AGN__c;
                    }
                  
                }*/
                
                //*****************  End  *****************
            } 
        } // flagAllAddrCheckedOK - If check closed               
        
        
        return null;
    }
   
    public pagereference customerPortalApex()
    {    
       
        System.debug('Call customerPortalApex');
        ApexPages.Message DMLSucErrMsg ;
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
                //String DisplayMsg = AGN_OktaProcessNew.processADRequestOkta(acrNew);
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
                    DMLSucErrMsg = new ApexPages.Message(ApexPages.severity.Error, DisplayMsg);
                    refreshPage =true;
                    ApexPages.addMessage(DMLSucErrMsg);

                    
                }else{
                    DMLSucErrMsg =  new ApexPages.Message(ApexPages.Severity.confirm, System.Label.AGN_OAM_Portal_Access_Activated);  
                    refreshPage =true;
                    ApexPages.addMessage(DMLSucErrMsg);
                    
                    System.debug('acr values: '+acrNew);
                    
                    List<Allergan_Customer_Registration_AGN__c> tempCRAList = new List<Allergan_Customer_Registration_AGN__c>();
                    tempCRAList.add(acrNew);              
                    String objCustomerAdd = 'Allergan_Customer_Registration_AGN__c';
                    SObjectType objCRAType = ((SObject)(Type.forName('Schema.'+objCustomerAdd).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(tempCRAList,objCRAType,'UPDATE');
                    
                    update acrNew; 
                    
                    System.debug('acr record is successfully processed by okta:::::'+acrNew);
                    Database.SaveResult sr = Database.update(relatedCase, false);//R15 strt
                    if(sr.isSuccess())
                    {
                        System.debug('Record Updated');
                    }
                    else
                    {
                        System.debug('Sr:'+sr);
                    } //R15 end
                    
                } 
            }
        }
        catch(Exception e){
            DMLSucErrMsg = new ApexPages.Message(ApexPages.severity.Error, e.getMessage());
            refreshPage =true;
            ApexPages.addMessage(DMLSucErrMsg);
            
        }
        return null;
    }
    
    @RemoteAction
    global static Boolean disableSendButton(Boolean disable)
    {
        System.debug('in disable method' + disable);
        sendToSAPBtnDisabled  = disable;
        System.debug('in disable method' + sendToSAPBtnDisabled);
        return sendToSAPBtnDisabled;
    }
    
    public pagereference sendtosap()
    {         
        boolean flagAllAddrCheckedOK = true; 
        String country = acr.SAP_Country_Code_AGN__c;
        Boolean isDeactivate = false;
        for(Allergan_Customer_Address_AGN__c tempAddr : lstAddresses)
        {
            if ( tempAddr.SAP_Search_Term_1_AGN__c == Null )
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'SAP Search Term 1 required  for '+tempAddr.Name+' to Process'); 
                ApexPages.addMessage(myMsg);
                flagAllAddrCheckedOK = false; 
                break;
            } 
            if(String.isNotBlank(tempAddr.SAP_Action_AGN__c) &&  tempAddr.SAP_Action_AGN__c == '3'){
                isDeactivate = true;
            }
        }    
        
        //if((acr.SAP_Search_Performed__c == false) || (acr.Ship_to_AC_validated_AGN__c == false) || (acr.Documentation_provided_as_per_SOP__c == false) || (acr.Address_Validated__c == false) || (acr.Official_Websites_Used_AGN__c == false))
        if(country == 'AU' || country == 'NZ'){
            if((!relatedGCSPSettings.Is_Send_to_SAP_checklist_Required__c) || isDeactivate ||((acr.SAP_Search_Performed__c ) && (acr.Ship_to_AC_validated_AGN__c ) && 
                                                                              (acr.Documentation_provided_as_per_SOP__c ) && (acr.Address_Validated__c ) 
                                                                              && (acr.Denied_Parties_List_Checked_AGN__c ) 
                                                                              && (acr.ABN_NZBN_Extract_Attached_AGN__c)
                                                                              && (flagAllAddrCheckedOK)
                                                                             ))
            { 
                system.debug('Sending SAP Request>>>>>>>>>>>>>');
                SAPID = AGN_SendToSapController.sendNow(acr.ID);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, SAPID); 
                ApexPages.addMessage(myMsg);
                System.debug('@@@@@@@ SAP ID @@@@ :'+SAPID); 
                
            }
            else if(acr.SAP_Search_Performed__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }
            else if(acr.Ship_to_AC_validated_AGN__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }
            else if(acr.Documentation_provided_as_per_SOP__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }
            else if(acr.Address_Validated__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }
            else if(acr.Denied_Parties_List_Checked_AGN__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }else if(acr.ABN_NZBN_Extract_Attached_AGN__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }     
        }else{
            if((!relatedGCSPSettings.Is_Send_to_SAP_checklist_Required__c) ||((acr.SAP_Search_Performed__c ) && (acr.Ship_to_AC_validated_AGN__c ) && 
                                                                              (acr.Documentation_provided_as_per_SOP__c ) && (acr.Address_Validated__c ) && (acr.Official_Websites_Used_AGN__c ) && (flagAllAddrCheckedOK)
                                                                             ))
            { 
                system.debug('Sending SAP Request>>>>>>>>>>>>>');
                SAPID = AGN_SendToSapController.sendNow(acr.ID);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, SAPID); 
                ApexPages.addMessage(myMsg);
                System.debug('@@@@@@@ SAP ID @@@@ :'+SAPID); 
                
            }
            else if(acr.SAP_Search_Performed__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }
            else if(acr.Ship_to_AC_validated_AGN__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }
            else if(acr.Documentation_provided_as_per_SOP__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }
            else if(acr.Address_Validated__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }
            else if(acr.Official_Websites_Used_AGN__c == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.AGN_Send_To_SAP_Validation); 
                ApexPages.addMessage(myMsg);
            }   
        }
        
        refreshPage =true;
        
        return null;
    } 
    //by Sharon for Brazil Credit integration
    public pagereference sendtosapcred(){
        /*    if(String.isNotBlank(paymentId)){
List<Allergan_Customer_Payment_AGN__c> payments = new List<Allergan_Customer_Payment_AGN__c>([SELECT Id,Account_AGN__c,
Account_AGN__r.Country_Code__c, 
Customer_SAP_Id_AGN__c,
Credit_Control_Area_AGN__c,
Central_Data_Indicator_AGN__c,
Status_AGN__c,
Customer_Credit_Limit_AGN__c,
Risk_Category_AGN__c,
Total_Amount_AGN__c,
Individual_Amount_AGN__c,
SAP_Currency_AGN__c,
Action_AGN__c,
Internal_Information_AGN__c,
External_Information_AGN__c,
Last_Interval_EU_Format_AGN__c,
Next_Interval_EU_Format_AGN__c 
FROM Allergan_Customer_Payment_AGN__c 
WHERE Id =: paymentId]);
if(payments.size() > 0){
Allergan_Customer_Payment_AGN__c payment = payments.get(0);
SAPID = AGN_SendToSapController.sendNowCr(payment);
system.debug('SAPID>>>>>>>>>>>>>'+SAPID);
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, SAPID); 
ApexPages.addMessage(myMsg);
responseMessage = SAPID;
}

}
refreshPage =true; */
        return null;
    }
}