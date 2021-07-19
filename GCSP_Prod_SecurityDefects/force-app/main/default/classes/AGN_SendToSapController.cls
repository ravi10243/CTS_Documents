/*
Type Name: AGN_SendToSapController
Reason: Webservice class for SAP Integration call outs
12-03-2017 - KS - Initial Version 
15-02-2018 - KM - Enhanced to make it reusable for all countries
*/
global with sharing class AGN_SendToSapController{
    
    webservice static String sendNow(ID customerRegID){
        String statusMsg = '';
        String requestBody; 
        String custCountryCode = '' ; // variable added by Krishanu 
        
        Allergan_Customer_Registration_AGN__c custReg = 
            [SELECT Id,             
             BirthDate_AGN__c,
             Birth_Date_EU_format_AGN__c,
             Country_Code_AGN__c, 
             Customer_Group_AGN__c, 
             Last_Name_AGN__c, 
             Middle_Name_AGN__c, 
             First_Name_AGN__c,
             SAP_Payment_Code_AGN__c, 
             Physician_Registration_Reference_AGN__c,
             Registration_License_Number_AGN__c, 
             Tax_Exempted_AGN__c, 
             VAT_AGN__c,
             Case_AGN__c, 
             Processed_By_SAP_AGN__c, 
             SAP_Country_Code_AGN__c,
             Invoice_Footer_AGN__c,
             Email_AGN__c,
             Salutation_AGN__c,
             Contact_Person_Type_AGN__c,
             SAP_Payment_Term_Code_AGN__c,
             SAP_Language_Code_AGN__c,
             SAP_Salutation_Code_AGN__c,
             Professional_Designation_AGN__c,
             Specialty_Allergan_1_AGN__c,
             Phone_AGN__c,
             Fax_AGN__c,
             Send_to_SAP_By_AGN__c,
             Send_to_SAP_Date_AGN__c
             
             FROM Allergan_Customer_Registration_AGN__c 
             WHERE Id = :customerRegID];
        
        String CRID = String.escapeSingleQuotes(customerRegID);
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
        query = 'select Parent_AGN__r.Customer_Group_AGN__c,' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Parent_AGN__c ='+'\''+ CRID+ '\'' + ' ORDER BY SAP_Account_Group_AGN__c';
        
        List<Allergan_Customer_Address_AGN__c> addressList = Database.query(query);  
        
        if(custReg!=NULL && custReg.Country_Code_AGN__c!= NULL && custReg.Country_Code_AGN__c!='')
        {
            custCountryCode = custReg.Country_Code_AGN__c ; // Added by Krishanu. Set value to the variable. 
            Integer i = 0;
            while(i < addressList.size()){
                if(addressList.get(i).SAP_Action_AGN__c == '1' && addressList.get(i).SAP_ID_AGN__c != null)
                    addressList.remove(i);
                else
                    i++;
            }
            
            /* Changed by Krishanu - Start */  
            string postRequestUrl = ''; 
            string username = '' ; 
            string password = '';  
            boolean logRequest ;
            string namedCredential = '' ;
            if(custCountryCode != NULL && AGN_GCSP_Settings__c.getValues(custCountryCode)!= NULL)
            {
                /* for dynamic SAP Callout*/
                if(AGN_CustomerSAPIntegrationUtils.IsSandbox()){
                    postRequestUrl = 'callout:SAP_ECC_DEV';
                }else{
                    postRequestUrl = 'callout:SAP_ECC_PRD';
                }
                
                logRequest = (boolean)AGN_GCSP_Settings__c.getValues(custCountryCode).get('Enable_Logs__c');
            }
            /* Changed by Krishanu - End */
            
            if(postRequestUrl!='')  // IF block added by Krishanu
            {   
                HttpRequest req = new HttpRequest();        
                req.setEndpoint(postRequestUrl);
                req.setMethod('POST');
                req.setHeader('Content-Type','application/json;charset=UTF-8'); 
                try{
                    requestBody = AGN_CustomerSAPIntegrationUtils.createAccountJson(custReg, addressList, custCountryCode); // changed by Krishanu, adding one more parameter, country code, in the call 
                    req.setBody(requestBody);
                    req.setTimeout(120000);
                    System.debug('SAP Call::RequestBody==>'+requestBody);
                    //if (logRequest) AGN_ErrorLogger.addCustomerRegsistrationError('Salesforce', 'Request', requestBody, custReg.Id, NULL);
                    system.debug('AGN_CustomerSAPIntegrationUtils.requiredFieldCheck=='+ AGN_CustomerSAPIntegrationUtils.requiredFieldCheck);
                    
                    if(AGN_CustomerSAPIntegrationUtils.requiredFieldCheck){
                    
                    if (logRequest) AGN_ErrorLogger.addCustomerRegsistrationError('Salesforce', 'Request', requestBody, custReg.Id, NULL);                    
                        Http http = new Http();       
                        HTTPResponse res = http.send(req);  
                        statusMsg = 'SAP Call::ResponseBody==> ' + res.getBody()  + ' ' + '==ResponseCode==' + res.getStatusCode();
                        if (logRequest) AGN_ErrorLogger.addCustomerRegsistrationError('SAP', 'Response', res.getBody(), custReg.Id, NULL);

                        List<Map<String, String>> jsonResponseMapList = AGN_CustomerSAPIntegrationUtils.parseAccountJson(res.getBody());            
                        Map<Id, SObject> recordsToUpdate= new Map<Id, Sobject>();            
                        custReg.Processed_By_SAP_AGN__c = 'In Progress';

                        for(Map<String, String> jsonObject : jsonResponseMapList){
                            if(jsonObject.get('IND') == 'S'){
                                statusMsg = 'Request succesfully processed in SAP!';
                                if (custReg.Processed_By_SAP_AGN__c == 'In Progress'){
                                    custReg.Processed_By_SAP_AGN__c = 'Success';
                                    custReg.Send_to_SAP_By_AGN__c  = UserInfo.getUserId();
                                    custReg.Send_to_SAP_Date_AGN__c = date.today();
                                    recordsToUpdate.put(custReg.Id, custReg);
                                }
                                
                                Allergan_Customer_Address_AGN__c addressToUpdate = new Allergan_Customer_Address_AGN__c(Id = jsonObject.get('ADDR_SFID'));
                                addressToUpdate.SAP_ID_AGN__c = jsonObject.get('CUST');                    
                                recordsToUpdate.put(addressToUpdate.Id, addressToUpdate);
                                
                                if(jsonObject.get('FIELD_ERRORS')!=''){
                                    AGN_ErrorLogger.addCustomerRegsistrationError('SAP', 'Field Error', jsonObject.get('FIELD_ERRORS'), custReg.Id,jsonObject.get('ADDR_SFID'));
                                }                                     
                                
                            }
                            else if(jsonObject.get('IND') == 'F'){
                                custReg.Processed_By_SAP_AGN__c='Failure';                    
                                recordsToUpdate.put(custReg.Id, custReg);
                                if(jsonObject.get('IND') == 'F' && jsonObject.get('MESSAGE')!= '' ){
                                    AGN_ErrorLogger.addCustomerRegsistrationError('SAP', 'Call Out', jsonObject.get('MESSAGE'), custReg.Id, jsonObject.get('ADDR_SFID'));
                                }
                                statusMsg = 'An error occured while processing the request in SAP! Please refresh the page and check error logger for details.';
                            }                   
                        }
                        update recordsToUpdate.values();
                    }else{
                        system.debug('StatusMsg :: '+AGN_CustomerSAPIntegrationUtils.errorMessage);
                        statusMsg = AGN_CustomerSAPIntegrationUtils.errorMessage;
                    } 
                }
                catch(Exception e){
                    System.debug('Exception - ' + e );
                    statusMsg = 'Exception - ' + e;
                    AGN_ErrorLogger.addCustomerRegsistrationError('Salesforce', e.getTypeName(), e.getMessage(), custReg.Id, NULL);    
                    custReg.Processed_By_SAP_AGN__c='Failure';
                    update custReg;
                }
                finally{
                    AGN_ErrorLogger.saveLogs();            
                } 
            }
            else{
                System.debug('Internal Error - SAP Integration Configuration Not Properly Set') ; 
            }   
        }
        else{
            System.debug('Invalid Country Code In Account') ; 
        }
        return statusMsg;
    }
}