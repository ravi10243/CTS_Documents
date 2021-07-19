/*
Created On  : Sept 25th 2020
Author      : Cognizant Team    
Purpose     : This class will make call to OneTrack webservice. 
For createating case in OneTrack after case get created in salesforce and Send To OneTrack button clicked    
*/

global class AGN_CallToOneTrack{
    
    // Create case on Trackwise and update Prid on click of sent to trackwise button 
    webservice static string submitCaseToOneTrack(String caseId, Boolean isUpdate){
        String resBody = '';  
        String caseAttributeId = '';
        
        Map<String, Trackwise_Field_Setting_AGN__mdt> trackwiseSettings = new Map<String, Trackwise_Field_Setting_AGN__mdt>();        
        trackwiseSettings = getTrackwiseFieldSettings(trackwiseSettings);
        Integer attSize = attachmentSizeCheck(caseId,isUpdate);
        
        Case caseObject = getCaseInfo(caseId, trackwiseSettings.values());
        Address_vod__c accountAdd = new Address_vod__c();
        
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
        if(isUpdate){
            resBody= getRequestBodyForUpdateIntake(resBody, getCaseInfo(caseId, trackwiseSettings.values()), trackwiseSettings.values(),attSize);
        }else{
            resBody = getRequestBodyForCreateIntake(resBody, caseObject, getCaseAttributeInfo(caseId, trackwiseSettings.values()), accountAdd, trackwiseSettings.values(),attSize);           
        }
        
        HTTPResponse res;   
        try{
            
            res = callOutToTrackwise(resBody, 'POST', trackwiseSettings, isUpdate);
            System.debug('####Response####' +res.getBody()); 
        }catch(Exception ex){
            if(!isUpdate){
                updateCase(caseId, null, false);
            }
            insertErrorDetails(caseId, ex.getMessage());
            return Label.OneTrack_Problem_Call_Out_Issue_AGN;
        }
        
        try{ 
            Map<String, String> responseInfo = getResponse(res.getBody());  
            System.debug('####ResponseInfo####' +responseInfo);
            if(responseInfo.size() > 0){
                if(errorConfig.containsKey(responseInfo.get('ReturnCode'))){                   
                    if(String.isNotBlank(responseInfo.get('IntakeId'))){
                        updateCase(caseId, responseInfo.get('IntakeId'), isUpdate);
                        updateCaseAttribute(caseAttributeId);
                    }else{
                        if(!isUpdate){
                            updateCase(caseId, null, false);
                        }
                    }
                    return errorConfig.get(responseInfo.get('ReturnCode'));
                }  
            }
        } catch (Exception ex){
            insertErrorDetails(caseId, ex.getMessage());
            System.debug('####Exception Message####'+ex.getMessage());
            return Label.OneTrack_Custom_Exception_AGN;
        }    
        return null;        
    }
    
    // For Update Case
    public static void updateCase(String caseId, String intakeId, Boolean isUpdate){
        Case c = new Case(Id = caseId, PR_ID_Trackwise_AGN__c = intakeId, 
                          Send_To_Trackwise_AGN__c = false, OTI_Last_Run_CoolS_AGN__c = System.now());
        if(isUpdate){
            if(Schema.sObjectType.Case.fields.OTI_Batch_Status_CoolS_AGN__c.isUpdateable()){
              c.OTI_Batch_Status_CoolS_AGN__c = 'Completed';
            }
            
            if(Schema.sObjectType.Case.fields.Memo_CoolS_AGN__c.isUpdateable()){
                c.Memo_CoolS_AGN__c = '';
            }
        }
        System.debug('####Case####' +c);
        
         update c;
        
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
            '102'  => Label.AGN_OT_No_Input_Fields,
            '111'  => Label.Trackwise_Casenumber_empty_AGN,
            '112'  => Label.Trackwise_sapAccountId_empty_AGN,
            '113'  => Label.Trackwise_sourceId_empty_AGN,
            '114'  => Label.Trackwise_Invalid_Source_ID_AGN,
            '115'  => Label.AGN_OT_Inconsistent_Attachment,
            '116'  => Label.AGN_OT_Case_Number_InProcess,
            '117'  => Label.AGN_OT_Record_Already_Processed,
            '118'  => Label.AGN_OT_Intake_Not_Returned_Resubmit,
            '119'  => Label.AGN_OT_AwareDate_Empty,
            '121'  => Label.AGN_OT_IntakeId_Empty,
            '122'  => Label.AGN_OT_IntakeId_Not_Exist,
            '200'  => Label.Trackwise_Custom_Exception_AGN
            };
                
                // Get Case details
                public static Case getCaseInfo(String caseId, List<Trackwise_Field_Setting_AGN__mdt> trackwiseSettings){
                    
                    Set<String> caseIdset = new Set<String>();
                    caseIdset.add(caseId);
                    
                    String query = 'SELECT ';
                    for(Trackwise_Field_Setting_AGN__mdt trackWiseField : trackwiseSettings){
                        if(trackWiseField.Object_Name_AGN__c == 'Case' && trackWiseField.Field_Name_AGN__c != Null && trackWiseField.MasterLabel != 'api:UserName' && trackWiseField.MasterLabel != 'api:Password' && trackWiseField.DeveloperName != 'End_Point_Url'
                           && trackWiseField.MasterLabel != 'api:attachments' && trackWiseField.MasterLabel != 'api:fileNames' && trackWiseField.MasterLabel != 'api:totalAttachmentSize')
                            query += trackWiseField.Field_Name_AGN__c+', '; 
                    }        
                    query = query.removeEnd(', ');
                    query += ' FROM Case WHERE Id IN :caseIdset';
                    System.debug('####case query######'+query);
                    return Database.query(query);              
                }
    
    // Get Case Attribute details
    private static Case_Attributes_for_CoolSculpting_AGN__c getCaseAttributeInfo(String caseId, List<Trackwise_Field_Setting_AGN__mdt> trackwiseSettings){
        
        Set<String> caseIdset = new Set<String>();
        caseIdset.add(caseId);
        
        String query = 'SELECT ';
        for(Trackwise_Field_Setting_AGN__mdt trackWiseField : trackwiseSettings){
            if(trackWiseField.Object_Name_AGN__c == 'Case_Attributes_for_CoolSculpting_AGN__c' && trackWiseField.Field_Name_AGN__c != Null && trackWiseField.MasterLabel != 'api:UserName' && trackWiseField.MasterLabel != 'api:Password' && trackWiseField.DeveloperName != 'End_Point_Url'
               && trackWiseField.MasterLabel != 'api:attachments' && trackWiseField.MasterLabel != 'api:fileNames' && trackWiseField.MasterLabel != 'api:totalAttachmentSize')
                query += trackWiseField.Field_Name_AGN__c+', '; 
        }        
        query = query.removeEnd(', ');
        query += ' FROM Case_Attributes_for_CoolSculpting_AGN__c WHERE Case_CoolS_AGN__c IN :caseIdset';
        System.debug('####Case attribute query######'+query);
        return Database.query(query);   
    } 
    
    // Get Primary Address Details of Account in Case
    private static List<Address_vod__c> getAddressInfo(Case caseObject, List<Trackwise_Field_Setting_AGN__mdt> trackwiseSettings){
        Set<String> accountIdset = new Set<String>();        
        accountIdset.add(caseObject.AccountId);   
        
        String query = 'SELECT Primary_vod__c, ';
        for(Trackwise_Field_Setting_AGN__mdt trackWiseField : trackwiseSettings){
            if(trackWiseField.Object_Name_AGN__c == 'Address_vod__c' && trackWiseField.Field_Name_AGN__c != Null && trackWiseField.MasterLabel != 'api:UserName' && trackWiseField.MasterLabel != 'api:Password' && trackWiseField.DeveloperName != 'End_Point_Url'
               && trackWiseField.MasterLabel != 'api:attachments' && trackWiseField.MasterLabel != 'api:fileNames' && trackWiseField.MasterLabel != 'api:totalAttachmentSize')
                query += trackWiseField.Field_Name_AGN__c+', '; 
        }        
        query = query.removeEnd(', ');
        query += ' FROM Address_vod__c WHERE Account_vod__c IN :accountIdset';
        System.debug('####Primary address query######'+query);
        return Database.query(query);       
    }
    
    // Generate Request Body for Create Intake
    public static string getRequestBodyForCreateIntake(String resBody, Case caseRec, Case_Attributes_for_CoolSculpting_AGN__c caseAttributeRec, Address_vod__c address, List<Trackwise_Field_Setting_AGN__mdt> trackwiseSettings, Integer attSize){        
        
        Map<String, Schema.SObjectField> objectName ;
        SObject objType;
        //List<Attachment> attachmentList = [select id,Name,Body from attachment where parentId =: caseRec.id];
        
        resBody = '<?xml version="1.0" encoding="utf-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:api="http://tempuri.org/"> <soapenv:Header/> <soapenv:Body> <api:CreateIntake> <api:addIntake>';
        system.debug('####Attechment size####'+attSize);
        for(Trackwise_Field_Setting_AGN__mdt trackWiseField : trackwiseSettings){
            
            if(trackWiseField.DeveloperName != 'End_Point_Url'){
                
                String refField = trackWiseField.Field_Name_AGN__c;
                if(string.isNotBlank(refField) && refField.contains('.') && trackWiseField.MasterLabel != 'api:attachments' && trackWiseField.MasterLabel != 'api:fileNames' && trackWiseField.MasterLabel != 'api:totalAttachmentSize'&& trackWiseField.MasterLabel != 'api:intakeId'&& trackWiseField.MasterLabel != 'api:memo'){
                    refField = refField.substringBefore('.')+'Id'; 
                }
                
                if((trackWiseField.MasterLabel == 'api:attachments' || trackWiseField.MasterLabel == 'api:fileNames')){
                    if(attSize  <= 3145728){
                        if(trackWiseField.MasterLabel == 'api:attachments'){ 
                            
                            resBody += '<'+trackWiseField.MasterLabel+'>';
                            for(Attachment att: [select id,Name,Body from attachment where parentId =: String.escapeSingleQuotes(caseRec.id)]){
                                Blob csvBlob = att.Body;
                                //String attachment = EncodingUtil.base64Encode(csvBlob);
                                if(trackWiseField.MasterLabel == 'api:attachments')
                                {
                                    resBody += '<api:string>';
                                    resBody += EncodingUtil.base64Encode(csvBlob);
                                    resBody += '</api:string>';
                                }
                            }
                            resBody += '</'+trackWiseField.MasterLabel+'>' ;
                        } 
                        if(trackWiseField.MasterLabel == 'api:fileNames'){
                            resBody += '<'+trackWiseField.MasterLabel+'>';
                            for(Attachment att: [select id,Name,Body from attachment where parentId =: String.escapeSingleQuotes(caseRec.id)]){
                                String fileName =  att.Name;
                                if(trackWiseField.MasterLabel == 'api:fileNames' && !(fileName == null || fileName == '')){
                                    resBody += '<api:string>';
                                    resBody +=  fileName.escapeXml();
                                    resBody += '</api:string>';
                                }
                            }
                            resBody += '</'+trackWiseField.MasterLabel+'>' ;
                        } 
                    }
                    
                    if(attSize  > 3145728){
                        if(trackWiseField.MasterLabel == 'api:fileNames'){
                            resBody += '<'+trackWiseField.MasterLabel+'>';
                            for(Attachment att: [select id,Name,Body from attachment where parentId =: String.escapeSingleQuotes(caseRec.id)]){
                                String fileName =  att.Name;
                                if(trackWiseField.MasterLabel == 'api:fileNames' && !(fileName == null || fileName == '' )){
                                    resBody += '<api:string>';
                                    resBody +=  fileName.escapeXml();
                                    resBody += '</api:string>';
                                }                                
                            }
                            resBody += '</'+trackWiseField.MasterLabel+'>' ;                           
                        }
                    }
                }
                else if(trackWiseField.MasterLabel == 'api:totalAttachmentSize'){
                    resBody += '<'+trackWiseField.MasterLabel+'>';
                    resBody += attSize;
                    resBody += '</'+trackWiseField.MasterLabel+'>' ;
                }
                
                else{
                    
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
                            
                            if(trackWiseField.MasterLabel != 'api:UserName' && trackWiseField.MasterLabel != 'api:Password' && trackWiseField.MasterLabel != 'api:attachments' && trackWiseField.MasterLabel != 'api:fileNames' 
                               && trackWiseField.MasterLabel != 'api:totalAttachmentSize' && trackWiseField.MasterLabel != 'api:intakeId' && trackWiseField.MasterLabel != 'api:memo'){
                                   Schema.DisplayType fieldType = field.getDescribe().getType();   
                                   if(Schema.DisplayType.STRING == fieldType || Schema.DisplayType.TEXTAREA == fieldType){ 
                                       resBody += String.valueOf(objType.get(field)).escapeXml();
                                   }else if(Schema.DisplayType.DATE == fieldType){
                                       resBody += formatDate(String.valueof(objType.get(field)));
                                   }else if(Schema.DisplayType.REFERENCE == field.getDescribe().getType()){                           
                                       if((trackWiseField.Field_Name_AGN__c).substringBefore('.') == 'Owner' && Test.isRunningTest() ){                               
                                           resBody += 'Owner Name';
                                       }else{
                                           resBody += String.valueof(objType.getSobject((trackWiseField.Field_Name_AGN__c).substringBefore('.')).get((trackWiseField.Field_Name_AGN__c).substringAfter('.'))).escapeXml();
                                       }                           
                                   }else if(Schema.DisplayType.DATETIME == fieldType){                       
                                       resBody += Datetime.Valueof(objType.get(field)).format('yyyy-MM-dd\'T\'HH:mm:ss','GMT');
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
                        if(trackWiseField.Field_Name_AGN__c != null){
                            resBody += trackWiseField.Field_Name_AGN__c.escapeXml(); 
                        }else{
                            resBody += ''; 
                        }                           
                    }
                    resBody += '</'+trackWiseField.MasterLabel+'>' ;
                }
            }
        }
        resBody += '</api:addIntake></api:CreateIntake> </soapenv:Body> </soapenv:Envelope>';
        System.debug('####Create Intake Request Body####' +resBody);        
        return resBody;
    }
    
    
    //Generate Request Body for Update Intake
    public static String getRequestBodyForUpdateIntake(String requestBody,Case caseRec, List<Trackwise_Field_Setting_AGN__mdt> trackwiseSettings, Integer attachmentSize){
        String xmlStartTag ;
        String xmlEndTag; 
        xmlStartTag = '<?xml version="1.0" encoding="utf-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:api="http://tempuri.org/"> <soapenv:Header/> <soapenv:Body> <api:UpdateIntake> <api:updateIntake>';
        xmlEndTag = '</api:updateIntake> </api:UpdateIntake> </soapenv:Body> </soapenv:Envelope>'; 
        requestBody = xmlStartTag;
        
        //Case updatedCase = [SELECT CaseNumber,OTI_Last_Run_CoolS_AGN__c FROM Case WHERE Id =:caseRec.id];
        //List<Attachment> attachmentList = [select id,Name,Body,LastModifiedDate from Attachment where parentId =:caseRec.id]; 
        
        for(Trackwise_Field_Setting_AGN__mdt trackWiseField : trackwiseSettings){
            if(trackWiseField.DeveloperName != 'End_Point_Url'){
                
                if(trackWiseField.MasterLabel == 'api:UserName' || trackWiseField.MasterLabel == 'api:Password'){
                    requestBody += '<'+trackWiseField.MasterLabel+'>';
                    requestBody += trackWiseField.Field_Name_AGN__c.escapeXml(); 
                    requestBody += '</'+trackWiseField.MasterLabel+'>';
                }
                
                else if((trackWiseField.MasterLabel == 'api:intakeId' || trackWiseField.MasterLabel == 'api:memo')){
                    requestBody += '<'+trackWiseField.MasterLabel+'>';
                    String removeBR;
                    if(String.valueOf(caseRec.get(trackWiseField.Field_Name_AGN__c))!=null){
                      removeBR =  String.valueOf(caseRec.get(trackWiseField.Field_Name_AGN__c)).unescapeHtml4();
                    }
                    String replaceBR = (String.isNotBlank(removeBR)) ? removeBR.replace('<br>', '\n') : '';
                    requestBody += replaceBR.escapeXml();
                    requestBody += '</'+trackWiseField.MasterLabel+'>';
                }
                
                else if((trackWiseField.MasterLabel == 'api:attachments' || trackWiseField.MasterLabel == 'api:fileNames')){
                    if(attachmentSize  <= 3145728){
                        
                        Case updatedCase = [SELECT CaseNumber,OTI_Last_Run_CoolS_AGN__c FROM Case WHERE Id =:caseRec.id];
                        
                        if(trackWiseField.MasterLabel == 'api:attachments'){ 
                            requestBody += '<'+trackWiseField.MasterLabel+'>';
                            for(Attachment att: [select id,Name,Body,LastModifiedDate from Attachment where parentId =:caseRec.id]){
                                if(att.LastModifiedDate > updatedCase.OTI_Last_Run_CoolS_AGN__c){
                                    Blob csvBlob = att.Body;
                                    
                                    if(trackWiseField.MasterLabel == 'api:attachments'){
                                        requestBody += '<api:string>';
                                        requestBody += EncodingUtil.base64Encode(csvBlob);
                                        requestBody += '</api:string>';
                                    }   
                                }
                            }
                            requestBody += '</'+trackWiseField.MasterLabel+'>' ;
                        } 
                        if(trackWiseField.MasterLabel == 'api:fileNames'){
                            requestBody += '<'+trackWiseField.MasterLabel+'>';
                            for(Attachment att: [select id,Name,Body,LastModifiedDate from Attachment where parentId =:caseRec.id]){
                                if(att.LastModifiedDate > updatedCase.OTI_Last_Run_CoolS_AGN__c){
                                    String fileName =  att.Name;
                                    if(trackWiseField.MasterLabel == 'api:fileNames' && !(fileName == null || fileName == '')){
                                        requestBody += '<api:string>';
                                        requestBody +=  fileName.escapeXml();
                                        requestBody += '</api:string>';
                                    }
                                    
                                }
                            }
                            requestBody += '</'+trackWiseField.MasterLabel+'>' ;
                        } 
                    }
                    
                    if(attachmentSize > 3145728){
                        
                        Case updatedCase = [SELECT CaseNumber,OTI_Last_Run_CoolS_AGN__c FROM Case WHERE Id =:caseRec.id];
                        
                        if(trackWiseField.MasterLabel == 'api:fileNames'){
                            requestBody += '<'+trackWiseField.MasterLabel+'>';
                            for(Attachment att: [select id,Name,Body,LastModifiedDate from Attachment where parentId =:caseRec.id]){
                                if(att.LastModifiedDate > updatedCase.OTI_Last_Run_CoolS_AGN__c){
                                    String fileName =  att.Name;
                                    if(trackWiseField.MasterLabel == 'api:fileNames' && !(fileName == null || fileName == '' )){
                                        requestBody += '<api:string>';
                                        requestBody +=  fileName.escapeXml();
                                        requestBody += '</api:string>';
                                    }
                                }
                            }
                            requestBody += '</'+trackWiseField.MasterLabel+'>' ;                           
                        }
                    }
                }
                
                else if(trackWiseField.MasterLabel == 'api:totalAttachmentSize'){
                    requestBody += '<'+trackWiseField.MasterLabel+'>';
                    requestBody += attachmentSize;
                    requestBody += '</'+trackWiseField.MasterLabel+'>' ;
                }
                
            }
        }
        
        requestBody += xmlEndTag;
        system.debug('####Update Intake Request Body####'+requestBody);          
        return requestBody;
    }
    
    // Call out to Trackwise system for creating case
    public static HTTPResponse callOutToTrackwise(String resBody, String method, Map<String, Trackwise_Field_Setting_AGN__mdt> trackwiseSettings, Boolean isUpdate){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(trackwiseSettings.get('End_Point_Url').Field_Name_AGN__c);
        req.setMethod(method);
        if(isUpdate){
            req.setHeader('SOAPAction', Label.AGN_OT_SetHeader_URL_Update);
        }else{
            //req.setHeader('SOAPAction', '""');
            req.setHeader('SOAPAction', Label.AGN_OT_SetHeader_URL_Create);
        }
        req.setHeader('Content-Type', 'text/xml;charset=utf-8');
        req.setBody(resBody);
        req.setTimeout(60000);
        System.debug('####CallOutToTrackwise - HttpRequest####'+req);
        
        Http http = new Http();
        return http.send(req);
    }
    
    // Get Response info from Body
    public static Map<String, String> getResponse(String response){
        Map<String, String> responseInfo = new Map<String, String>();
        
        System.debug('####Inside getResponse method - Before response####'+response);
        if(response.contains('CreateIntakeResult')){
            response = response.substringBetween('<CreateIntakeResult>', '</CreateIntakeResult>');
        }else{
            response = response.substringBetween('<UpdateIntakeResult>', '</UpdateIntakeResult>');
        }
        //Added root element
        response = '<IntakeResult>' + response + '</IntakeResult>'; 
        System.debug('####Inside getResponse method - After response####'+response);   
        DOM.Document document = new DOM.Document();
        document.load(response);
        
        Dom.XMLNode docRootElement= document.getRootElement(); 
        Dom.XMLNode cprTag = document.getRootElement();
        System.debug('####Inside getResponse method cprTag####'+cprTag);
        
        responseInfo.put('IntakeId', cprTag.getChildElement('IntakeId', null).getText());
        responseInfo.put('ReturnCode', cprTag.getChildElement('ReturnCode', null).getText());
        responseInfo.put('Message', cprTag.getChildElement('Message', null).getText());
        
        System.debug('####ResponseInfo####' +responseInfo);
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
    
    //Method to check the size of all attachments 
    webservice static Integer attachmentSizeCheck(String caseId, Boolean isUpdate){
        //String attachment='';
        Integer attachmentSize = 0;
        String csId = caseId;
        Case updatedCase = [SELECT CaseNumber,OTI_Last_Run_CoolS_AGN__c FROM Case WHERE Id =:String.escapeSingleQuotes(csId)];
        
        for(Attachment atta:[select id,Body,Name,BodyLength,LastModifiedDate from attachment where parentId =: String.escapeSingleQuotes(csId)]){
            if(isUpdate && updatedCase.OTI_Last_Run_CoolS_AGN__c != null){
                if(atta.LastModifiedDate > updatedCase.OTI_Last_Run_CoolS_AGN__c){
                    attachmentSize =attachmentSize + atta.BodyLength;
                }
            }
            
            else if(!isUpdate){
                attachmentSize =attachmentSize + atta.BodyLength;
            }
            system.debug('####Attachement Body Length####' + atta.BodyLength);
        }
        system.debug('####Total attachment size####'+attachmentSize);
        return attachmentSize;
    }
    
    
}