/*
Created On : Dec 3rd 2018    
Purpose : This class will make call to Trackwise webservice. For createating case in Trackwise after it case get created in salesforce.

*/

global class AGN_CallTrackwise{
    
    // Create case on Trackwise and update Prid on click of sent to trackwise button 
    webservice static string createCaseTrackwise(String caseId){
        String resBody = '';  
        String caseAttributeId = '';
        
        Map<String, Trackwise_Field_Setting_AGN__mdt> trackwiseSettings = new Map<String, Trackwise_Field_Setting_AGN__mdt>();        
        trackwiseSettings = getTrackwiseFieldSettings(trackwiseSettings);
        
        Case caseObject = getCaseInfo(caseId, trackwiseSettings.values());
        Address_vod__c accountAdd = new Address_vod__c();
        // Non Us Should get removed
        
        List<Address_vod__c> addressList = getAddressInfo(caseObject, trackwiseSettings.values());
        if(addressList.size() > 0){
            accountAdd =  addressList[0];
            for(Address_vod__c address : addressList){
                if(address.Primary_vod__c){
                    accountAdd = address;
                    break;
                }
            }
        }
        caseAttributeId = getCaseAttributeInfo(caseId, trackwiseSettings.values()).Id;
        resBody = getHttpRequestBody(resBody, caseObject, getCaseAttributeInfo(caseId, trackwiseSettings.values()), accountAdd, trackwiseSettings.values());           
        
        HTTPResponse res;   
        try{
            
            res = callOutToTrackwise(resBody, 'POST', trackwiseSettings );
        }catch(Exception ex){
            updateCase(caseId, null);
            insertErrorDetails(caseId, ex.getMessage());
            return Label.Trackwise_Problem_Call_Out_Issue_AGN;
        }       
        try{ 
           
            Map<String, String> responseInfo = getResponse(res.getBody());  
            
            if(responseInfo.size() > 0){
                if(errorConfig.containsKey(responseInfo.get('ReturnCode'))){                   
                    if(String.isNotBlank(responseInfo.get('PrId'))){
                        updateCase(caseId, responseInfo.get('PrId'));
                        updateCaseAttribute(caseAttributeId);
                    } else {
                        updateCase(caseId, null);
                    }
                    return errorConfig.get(responseInfo.get('ReturnCode'));
                }  
            }
        } catch (Exception ex){
            insertErrorDetails(caseId, ex.getMessage());
            return Label.Trackwise_Custom_Exception_AGN;
        } /**/     
        return null;        
    }
    
    // For Update Case
    public static Case updateCase(String caseId, String prId){
        Case c = new Case(Id = caseId, PR_ID_Trackwise_AGN__c = prId, Send_To_Trackwise_AGN__c = false);  
        update c;
        return c;
    }
    
    // For Insert Exception/Error Message
    public static Allergan_Error_Logger_AGN__c insertErrorDetails(String caseId, String message){
        Allergan_Error_Logger_AGN__c e = new Allergan_Error_Logger_AGN__c(Case_AGN__c = caseId, Error_Message_AGN__c = message, Source_AGN__c = 'Trackwise');
        insert e;
        return e;
    }
    
    // For Update Case Attribute
    public static Case_Attributes_for_CoolSculpting_AGN__c updateCaseAttribute(String caseAttributeId){
        Case_Attributes_for_CoolSculpting_AGN__c cac = new Case_Attributes_for_CoolSculpting_AGN__c(Id = caseAttributeId, Complaint_Status_Trackwise_AGN__c = Label.Trackwise_Complaint_Status_Open_AGN);  
        update cac;
        return cac;
    }
    
    // Trackwise response error code with message
    public static Map<String, String> errorConfig = new Map<String, String>{
        
        '0'  => Label.Trackwise_PrId_Success_Message_AGN,
            
            '10'  => Label.Trackwise_case_already_exists_AGN,
            
            '100'  => Label.Trackwise_Failed_WS_Authentication_UserName_AGN,
            
            '101'  => Label.Trackwise_Failed_WS_Authentication_Password_AGN,
            
            '111'  => Label.Trackwise_Casenumber_empty_AGN,
            
            '112'  => Label.Trackwise_sapAccountId_empty_AGN,
            
            '113'  => Label.Trackwise_sourceId_empty_AGN,
            
            '114'  => Label.Trackwise_Invalid_Source_ID_AGN,
            
            '200'  => Label.Trackwise_Custom_Exception_AGN
            };
                
                // Get Case details
                public static Case getCaseInfo(String caseId, List<Trackwise_Field_Setting_AGN__mdt> trackwiseSettings){
                    
                    Set<String> caseIdset = new Set<String>();
                    caseIdset.add(caseId);
                    
                    String query = 'SELECT ';
                    for(Trackwise_Field_Setting_AGN__mdt trackWiseField : trackwiseSettings){
                        if(trackWiseField.Object_Name_AGN__c == 'Case' && trackWiseField.Field_Name_AGN__c != Null && trackWiseField.MasterLabel != 'api:UserName' && trackWiseField.MasterLabel != 'api:Password' && trackWiseField.DeveloperName != 'End_Point_Url')
                            query += trackWiseField.Field_Name_AGN__c+', '; 
                    }        
                    query = query.removeEnd(', ');
                    query += ' FROM Case WHERE Id IN :caseIdset';
                    
                    return Database.query(query);              
                }
    
    // Get Case Attribute details
    private static Case_Attributes_for_CoolSculpting_AGN__c getCaseAttributeInfo(String caseId, List<Trackwise_Field_Setting_AGN__mdt> trackwiseSettings){
        
        Set<String> caseIdset = new Set<String>();
        caseIdset.add(caseId);
        
        String query = 'SELECT ';
        for(Trackwise_Field_Setting_AGN__mdt trackWiseField : trackwiseSettings){
            if(trackWiseField.Object_Name_AGN__c == 'Case_Attributes_for_CoolSculpting_AGN__c' && trackWiseField.Field_Name_AGN__c != Null && trackWiseField.MasterLabel != 'api:UserName' && trackWiseField.MasterLabel != 'api:Password' && trackWiseField.DeveloperName != 'End_Point_Url')
                query += trackWiseField.Field_Name_AGN__c+', '; 
        }        
        query = query.removeEnd(', ');
        query += ' FROM Case_Attributes_for_CoolSculpting_AGN__c WHERE Case_CoolS_AGN__c IN :caseIdset';
        
        return Database.query(query);   
    } 
    
    // Get Primary Address Details of Account in Case
    private static List<Address_vod__c> getAddressInfo(Case caseObject, List<Trackwise_Field_Setting_AGN__mdt> trackwiseSettings){
        Set<String> accountIdset = new Set<String>();        
        accountIdset.add(caseObject.AccountId);   
        
        String query = 'SELECT Primary_vod__c, ';
        for(Trackwise_Field_Setting_AGN__mdt trackWiseField : trackwiseSettings){
            if(trackWiseField.Object_Name_AGN__c == 'Address_vod__c' && trackWiseField.Field_Name_AGN__c != Null && trackWiseField.MasterLabel != 'api:UserName' && trackWiseField.MasterLabel != 'api:Password' && trackWiseField.DeveloperName != 'End_Point_Url')
                query += trackWiseField.Field_Name_AGN__c+', '; 
        }        
        query = query.removeEnd(', ');
        query += ' FROM Address_vod__c WHERE Account_vod__c IN :accountIdset';
        return Database.query(query);       
    }
    
    // Generate Request Body
    //Release 19R3.4 Requirement 2922 : Updated the method from createPR to createPR2
    public static string getHttpRequestBody(String resBody, Case caseRec, Case_Attributes_for_CoolSculpting_AGN__c caseAttributeRec, Address_vod__c address, List<Trackwise_Field_Setting_AGN__mdt> trackwiseSettings){        
        
        Map<String, Schema.SObjectField> objectName ;
        SObject objType;
        
        resBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:api="http://api.sparta.com"><soapenv:Header/><soapenv:Body><api:createPR2>';
        
        for(Trackwise_Field_Setting_AGN__mdt trackWiseField : trackwiseSettings){
            
            if(trackWiseField.DeveloperName != 'End_Point_Url'){
                
                String refField = trackWiseField.Field_Name_AGN__c;
                if(string.isNotBlank(refField) && refField.contains('.')){
                    refField = refField.substringBefore('.')+'Id'; 
                }
                
                resBody += '<'+trackWiseField.MasterLabel+'>';           
                
                if(trackWiseField.Object_Name_AGN__c != null){
                    objectName = Schema.getGlobalDescribe().get(trackWiseField.Object_Name_AGN__c).getDescribe().fields.getMap();
                    Schema.SobjectField field = objectName.get(refField);
                    
                    if(Schema.getGlobalDescribe().get(trackWiseField.Object_Name_AGN__c) == caseRec.getSObjectType()){
                        objType = caseRec;
                    } else if(Schema.getGlobalDescribe().get(trackWiseField.Object_Name_AGN__c) == caseAttributeRec.getSObjectType()){
                        objType = caseAttributeRec;
                    } else if(Schema.getGlobalDescribe().get(trackWiseField.Object_Name_AGN__c) == address.getSObjectType()){
                        objType = address;
                    } 
                    
                    if(String.isNotBlank(String.valueof(field)) && String.isNotBlank(String.valueOf(objType.get(field)))){ 
                        
                        if(trackWiseField.MasterLabel != 'api:UserName' && trackWiseField.MasterLabel != 'api:Password' ){
                            Schema.DisplayType fieldType = field.getDescribe().getType();   
                            if(Schema.DisplayType.STRING == fieldType || Schema.DisplayType.TEXTAREA == fieldType){ 
                                resBody += String.valueOf(objType.get(field)).escapeHtml4();
                            }else if(Schema.DisplayType.DATE == fieldType){
                                resBody += formatDate(String.valueof(objType.get(field)));
                            }else if(Schema.DisplayType.REFERENCE == field.getDescribe().getType()){                           
                                if((trackWiseField.Field_Name_AGN__c).substringBefore('.') == 'Owner' && Test.isRunningTest() ){                               
                                    resBody += 'Owner Name';
                                }else{
                                    resBody += String.valueof(objType.getSobject((trackWiseField.Field_Name_AGN__c).substringBefore('.')).get((trackWiseField.Field_Name_AGN__c).substringAfter('.'))).escapeHtml4();
                                }                           
                            }else if(Schema.DisplayType.DATETIME == fieldType){                       
                                resBody += Datetime.Valueof(objType.get(field)).format('yyyy-MM-dd\'T\'HH:mm:ss');
                            }else{
                                if(objType.get(field) != null){
                                    resBody += objType.get(field);
                                }else{
                                    resBody += '';
                                }
                            } 
                        }
                    }
                }else{                    
                    if(trackWiseField.MasterLabel == 'api:sourceId'){
                        resBody += UserInfo.getOrganizationId();
                    }else{
                        if(trackWiseField.Field_Name_AGN__c != null){
                            resBody += trackWiseField.Field_Name_AGN__c; 
                        }else{
                            resBody += ''; 
                        }
                    }                           
                }
                resBody += '</'+trackWiseField.MasterLabel+'>' ;
            }
        }
        resBody += '</api:createPR2></soapenv:Body></soapenv:Envelope>';        
        return resBody;
    }
    
    // Call out to Trackwise system for creating case
    public static HTTPResponse callOutToTrackwise(String resBody, String method, Map<String, Trackwise_Field_Setting_AGN__mdt> trackwiseSettings){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(trackwiseSettings.get('End_Point_Url').Field_Name_AGN__c);
        req.setMethod(method);
        req.setHeader('SOAPAction', '""');
        req.setHeader('Content-Type', 'text/xml'); 
        req.setBody(resBody);
        req.setTimeout(60000);
        
        Http http = new Http();
        return http.send(req);
    }
    
    // Get Response info from Body
    public static Map<String, String> getResponse(String response){
        
        Map<String, String> responseInfo = new Map<String, String>();
        if(response.contains('ns:return')){
            response = response.substringBetween('<ns:return>', '</ns:return>');
            
            DOM.Document document = new DOM.Document();
            document.load(response);
            
            Dom.XMLNode docRootElement= document.getRootElement();        
            Dom.XMLNode cprTag = document.getRootElement();
            
            responseInfo.put('PrId', cprTag.getChildElement('PrId', null).getText());
            responseInfo.put('ReturnCode', cprTag.getChildElement('ReturnCode', null).getText());
            responseInfo.put('Message', cprTag.getChildElement('Message', null).getText());
        }
        return responseInfo;
    }
    
    public static Map<String, Trackwise_Field_Setting_AGN__mdt> getTrackwiseFieldSettings(Map<String, Trackwise_Field_Setting_AGN__mdt> trackwiseSettings){
        
        for(Trackwise_Field_Setting_AGN__mdt trackwiseSetting : [SELECT DeveloperName, MasterLabel, Field_Name_AGN__c, Object_Name_AGN__c, Trackwise_Attribute_Order_AGN__c FROM Trackwise_Field_Setting_AGN__mdt ORDER BY Trackwise_Attribute_Order_AGN__c ASC]){
            trackwiseSettings.put(trackwiseSetting.DeveloperName, trackwiseSetting);
        }
        return trackwiseSettings;
    }
    
    // Format Date by removing time from date field
    public static string formatDate(String value){
        
        if(String.valueOf(value).contains('00:00:00')){
            return String.valueOf(value).replaceAll('00:00:00', '').trim();
        }  
        return string.valueof(value);
    }
    
}