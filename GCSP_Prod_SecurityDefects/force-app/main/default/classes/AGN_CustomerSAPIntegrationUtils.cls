/*
Type Name: AGN_CustomerSAPIntegrationUtils
Reason: Helper class for SAP Integration call outs
12-03-2017 - SG - Initial Version
15-02-2018 - KM - Enhanced to make it reusable for all countries 
12-02-2021 - KH - PMO 2151 - Enabling Contact affiliation for ship-to and bill-to 
*/
public class AGN_CustomerSAPIntegrationUtils {
    
    public static map<string, string> sfToSapAccountFieldMap = new map<string, string>(); 
    public static map<string, string> sfToSapAccountFieldMapListType = new map<string, string>();
    //new map for required field mapping
    public static boolean requiredFieldCheck = true;
    public static String errorMessage = '';
    public static map<string, map<string, boolean>> sfToSapAccountFieldMapRequired = new map<string, map<string, boolean>>();
    public static List<Allergan_Customer_Contact_AGN__c> customerContacts = new List<Allergan_Customer_Contact_AGN__c>();
    // PMO 2151
    public static List<Allergan_Customer_Contact_AGN__c> customerContactFromAddrContMapping;
    public static String country;
    
    // Build JSON body for Account creation in SAP
    public static string createAccountJson(Allergan_Customer_Registration_AGN__c customer, list<Allergan_Customer_Address_AGN__c> addresses, String custCountryCode){
        
        list<map<string, string>> fieldValueMapList = new list<map<string, string>>();
        List<map<string, string>> fieldValueList=new List<map<string,string>>();
        
        fetchFieldMappings(custCountryCode); // modified by Krishanu: Added parameterized call.
        // PMO 2151
        // fetchContactPersonDetails(customer);
        country = custCountryCode;
        for(Allergan_Customer_Address_AGN__c adr : addresses){
            /*if(String.isBlank(adr.SAP_Country_Code_AGN__c) || adr.SAP_Country_Code_AGN__c == 'BR'){
                adr.Distribution_ID_AGN__c  = '';
            }*/
            // PMO 2151 start
            customerContactFromAddrContMapping = new List<Allergan_Customer_Contact_AGN__c>();
            customerContactFromAddrContMapping = fetchContactPersonDetails(customer, adr.Id);
            if(customerContactFromAddrContMapping.size() == 0) fetchContactPersonDetails(customer);
            // PMO 2151 end
            list<SObject> recordList = new list<SObject>();
            recordList.add(customer);
            recordList.add(adr);
            fieldValueMapList.add(createFieldValueRequiredMap(recordList, sfToSapAccountFieldMapRequired));
            //fieldValueMapList.add(createMetadataList(recordList));
        }
        JSONGenerator genCustDetail = JSON.createGenerator(true);
        genCustDetail.writeStartObject();
        genCustDetail.writeFieldName('REQUEST');
        genCustDetail.writeStartArray();
        
        for (map<string, string> fieldValue : fieldValueMapList){
            genCustDetail.writeStartObject();
            
            system.debug('fieldValue.keySet()======'+fieldValue.keySet());
            
            for (string key : fieldValue.keySet()){
            system.debug('fieldValue.keySet()======'+key );
                if(fieldValue.get(key)==null){
                    genCustDetail.writeStringField(key, '');
                }else{
                    genCustDetail.writeStringField(key, fieldValue.get(key)); 
                }
                    
            }
            genCustDetail.writeEndObject();
        }
        genCustDetail.writeEndArray();
        genCustDetail.writeEndObject();        
        string custdetail=genCustDetail.getAsString().replaceAll('\\\\', '').replaceAll('\"\\[', '[').replaceAll('\\]\"',']').replace('^','\\\"');
        custdetail = custdetail.replaceAll('\"\\{', '{');
        custdetail = custdetail.replaceAll('\\}\"', '}');
        /*if(custCountryCode == 'CA' || custCountryCode == 'AU' || custCountryCode == 'NZ' || custCountryCode == 'AN'){//This is to remove '[' && ']' from inner json 
            //String formattedTxt = custdetail.deleteWhitespace();
            String formattedTxt = custdetail;
            if(formattedTxt.contains('NEW_ACCOUNT')){
                formattedTxt = removeArrays(formattedTxt , 'NEW_ACCOUNT');
            }
            if(formattedTxt.contains('ADTNL_DATA')){
                formattedTxt = removeArrays(formattedTxt , 'ADTNL_DATA');
            }
            if(formattedTxt.contains('CUST_PROGRAM')){
                formattedTxt = removeArrays(formattedTxt , 'CUST_PROGRAM');
            }
            return formattedTxt;
        }*/
        system.debug('===custdetail=='+custdetail);
        return custdetail;
    }
    
    /*public static String removeArrays(String source , String attr){
        system.debug('source>>>>>>>>>>>>>'+source);
        system.debug('attr>>>>>>>>>>>>>'+attr);
        //String searchStr = '"'+ attr +'":[';
        String searchStr = '"'+ attr +'" : [';
        if(source.contains(searchStr)){
            String mainsub = source.substringBetween(searchStr , ']');
            system.debug('mainsub>>>>>>>>>>>>>>>>'+mainsub);
            Integer first = source.indexof(mainsub) - 1;
            Integer len = mainsub.length();
            Integer last = first + len;
            system.debug('first>>>>>>>>>>>>>>>>'+first);
            system.debug('last>>>>>>>>>>>>>>>>'+last);
            String firstremoved = source.left(first)+source.right(source.length()-first-1);
            source = firstremoved;
            String lastremoved = source.left(last)+source.right(source.length()-last-1);
            source = lastremoved;
            system.debug('firstremoved>>>>>>>>>>>>>>'+firstremoved);
            system.debug('lastremoved>>>>>>>>>>>>>>'+lastremoved);
        }else{
            system.debug('error');
        }
        system.debug('Formatted String>>>>>>>>>>>>'+source);
        return source;
    }*/
    
    /*public static string createCreditJson(Allergan_Customer_Payment_AGN__c payment, String custCountryCode){
        list<map<string, string>> fieldValueMapList = new list<map<string, string>>();
        List<map<string, string>> fieldValueList=new List<map<string,string>>();
        fetchFieldMappingsCr(custCountryCode);
        list<SObject> recordList = new list<SObject>();
        recordList.add(payment);
        if(payment.Account_AGN__c != null){
            Account acc = [SELECT Id,External_ID2_AGN__c FROM Account WHERE Id =: payment.Account_AGN__c];
            recordList.add(acc);
        }
        
        fieldValueMapList.add(createFieldValueMapCR(recordList, sfToSapAccountFieldMap));
        System.debug('fieldValueList--'+fieldValueList);
        System.debug('fieldValueMapList--'+fieldValueMapList);
        JSONGenerator genCustDetail = JSON.createGenerator(true);
        genCustDetail.writeStartObject();
        genCustDetail.writeFieldName('REQUEST');
        genCustDetail.writeStartArray();
        for (map<string, string> fieldValue : fieldValueMapList){
            genCustDetail.writeStartObject();
            
            system.debug('fieldValue.keySet()======'+fieldValue.keySet());
            
            for (string key : fieldValue.keySet()){
            system.debug('fieldValue.keySet()======'+key );  
                if(fieldValue.get(key)==null)
                    genCustDetail.writeStringField(key, '');
                else
                    genCustDetail.writeStringField(key, fieldValue.get(key));
            }
            genCustDetail.writeEndObject();
        }
        genCustDetail.writeEndArray();
        genCustDetail.writeEndObject();
        string custdetail=genCustDetail.getAsString().replaceAll('\\\\', '').replaceAll('\"\\[', '[').replaceAll('\\]\"',']').replace('^','\\\"');
        system.debug('===custdetail=='+custdetail);
        return custdetail;
    }
    
     public static map<string, string> createFieldValueMapCR(list<SObject> recordList, map<string, string> fieldMapping){
        map<string, string> fieldValueMap = new map<string, string>();
        for (string sapField : fieldMapping.keySet()){
            string [] sfObjectField = fieldMapping.get(sapField).split('\\.');
            
            string sfObjectName = sfObjectField[0]; //object name
            string sfFieldName = sfObjectField[1]; //field name
            for(SObject obj : recordList){
                if (obj.getSObjectType().getDescribe().getName() == sfObjectName){ //compare object name
                    system.debug(obj.get(sfFieldName));
                    String fldVal = '';
                    if(obj.get(sfFieldName) != Null && obj.get(sfFieldName) != ''){
                        fldVal += obj.get(sfFieldName);
                        system.debug('fldVal init>>>>>>>>>>>>>>>>>>>>>'+fldVal);
                        fldVal = fldVal.replace('\"', '^');
                        if(sfFieldName == 'Total_Amount_AGN__c' 
                           || sfFieldName == 'Individual_Amount_AGN__c' 
                           || sfFieldName == 'Customer_Credit_Limit_AGN__c'){
                            //system.debug('fldVal>>>>>>>>>>>>>>>>>>>>>'+fldVal);
                            if(fldVal.contains('.')){//Number - remove value after decimal point
                              fldVal = fldVal.substringBefore('.');  
                            }
                        }else if(sfFieldName == 'Last_Interval_Review_AGN__c' 
                                 || sfFieldName == 'Next_Interval_Review_AGN__c'){
                            //system.debug('fldVal>>>>>>>>>>>>>>>>>>>>>'+fldVal);
                            if(fldVal.contains('-')){//Date - remove time related data
                                fldVal = fldVal.substringBefore(' ');
                            }       
                                     
                        }
                        fieldValueMap.put(sapField, fldVal);
                    }else{
                        fieldValueMap.put(sapField, '');
                    }                  
                }
            } 
        }
        for(string sapFieldColtype:sfToSapAccountFieldMapListType.keySet()){
                fieldValueMap.put(sapFieldColtype,'['+getListTypeMetadataDetails(recordList,sapFieldColtype)+']'); 
        }
        return fieldValueMap;
    }*/
    
    //Get field => value for JSON
    public static map<string, string> createFieldValueMap(list<SObject> recordList, map<string, string> fieldMapping){
        map<string, string> fieldValueMap = new map<string, string>();
        for (string sapField : fieldMapping.keySet()){
            string [] sfObjectField = fieldMapping.get(sapField).split('\\.');
            
            string sfObjectName = sfObjectField[0]; //object name
            string sfFieldName = sfObjectField[1]; //field name
            for(SObject obj : recordList){
                if (obj.getSObjectType().getDescribe().getName() == sfObjectName){ //compare object name
                    fieldValueMap.put(sapField, (string)obj.get(sfFieldName)== Null?(string)obj.get(sfFieldName):((string)obj.get(sfFieldName)).replace('\"', '^'));  //get field value from object
                }
            } 
        }
        for(string sapFieldColtype:sfToSapAccountFieldMapListType.keySet())
        {
            if(sapFieldColtype == 'CUST_TEXTS' || sapFieldColtype == 'CONTACT_PERSON'){
                fieldValueMap.put(sapFieldColtype,'['+getListTypeMetadataDetails(recordList,sapFieldColtype)+']');
            }
            else{                 
                fieldValueMap.put(sapFieldColtype, getListTypeMetadataDetails(recordList,sapFieldColtype));
            }
                
        }
        return fieldValueMap;
    }
    
    public static map<string, string> createFieldValueRequiredMap(list<SObject> recordList, map<string, map<string, boolean>> fieldMapping){
        map<string, string> fieldValueMap = new map<string, string>();
        for (string sapField : fieldMapping.keySet()){ 
            map<string, boolean> sfFieldMap = fieldMapping.get(sapField);
            for (string sfField : sfFieldMap.keySet()){
                string [] sfObjectField = sfField.split('\\.');
                string sfObjectName = sfObjectField[0]; //object name
                string sfFieldName = sfObjectField[1]; //field name
                boolean isRequired = sfFieldMap.get(sfField);                    
                for(SObject obj : recordList){
                    
                    
                    if (obj.getSObjectType().getDescribe().getName() == sfObjectName){ //compare object name
                        //fieldValueMap.put(sapField, (string)obj.get(sfFieldName)== Null?(string)obj.get(sfFieldName):((string)obj.get(sfFieldName)).replace('\"', '^'));  //get field value from object

                        if (obj.get(sfFieldName)== Null && isRequired){
                            system.debug('required field missing>>>>>>>>>>>>>>>>'+sfFieldName);
                            //obj.getSObjectType().getDescribe().fields.getMap().get(sfFieldName).getDescribe().getLabel();
                            errorMessage = System.Label.AGN_CR_SAP_Required_Check_Message+' '+ obj.getSObjectType().getDescribe().fields.getMap().get(sfFieldName).getDescribe().getLabel();
                            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.AGN_CR_SAP_Required_Check_Message+' '+ obj.getSObjectType().getDescribe().fields.getMap().get(sfFieldName).getDescribe().getLabel()));                            
                            requiredFieldCheck= false;
                            break;
                        }
                        else{
                            //commented to implement uppercase fix
                            //fieldValueMap.put(sapField, (string)obj.get(sfFieldName)== Null?(string)obj.get(sfFieldName):((string)obj.get(sfFieldName)).replace('\"', '^')); 
                            if(String.isNotBlank(country) 
                               && country == 'AU' 
                               || country == 'NZ' 
                               || country == 'AN'){
                                system.debug('inside condn>>>>>>>'+sapField+'<<<<');
                                   if(sapField == 'ADDR_SFID'){
                                       fieldValueMap.put(sapField, (string)obj.get(sfFieldName)== Null?(string)obj.get(sfFieldName):((string)obj.get(sfFieldName)).replace('\"', '^'));
                                   }else{
                                       fieldValueMap.put(sapField, (string)obj.get(sfFieldName)== Null?(string)obj.get(sfFieldName):((string)obj.get(sfFieldName)).replace('\"', '^').toUpperCase());
                                   }
                                
                             }else{
                                fieldValueMap.put(sapField, (string)obj.get(sfFieldName)== Null?(string)obj.get(sfFieldName):((string)obj.get(sfFieldName)).replace('\"', '^'));    
                             }
                        }
                    }
                    
                }                 
            }
        }
        system.debug('sfToSapAccountFieldMapListType>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+sfToSapAccountFieldMapListType);                                        
        for(string sapFieldColtype:sfToSapAccountFieldMapListType.keySet())
        {
            if(sapFieldColtype == 'CUST_TEXTS' || sapFieldColtype == 'CONTACT_PERSON'){
                fieldValueMap.put(sapFieldColtype,'['+getListTypeMetadataDetails(recordList,sapFieldColtype)+']');
            }
            else{                 
                fieldValueMap.put(sapFieldColtype, getListTypeMetadataDetails(recordList,sapFieldColtype));
            }
            //fieldValueMap.put(sapFieldColtype,'['+getListTypeMetadataDetails(recordList,sapFieldColtype)+']');
        }
        return fieldValueMap;
    }
    
    // PMO 2151 start
    // This method will fetch customer contact from Allergan_Address_Contact_Mapping_agn__c object
    public static List<Allergan_Customer_Contact_AGN__c> fetchContactPersonDetails(Allergan_Customer_Registration_AGN__c customer, ID addressId){
    	List<Id> ContactList = new List<Id>();
        for (Allergan_Address_Contact_Mapping_agn__c addConMap : [SELECT Id, Allergan_Customer_Contact_agn__c FROM Allergan_Address_Contact_Mapping_agn__c WHERE Allergan_Customer_Address_agn__c = :addressId AND Allergan_Customer_Registration_agn__c = :customer.Id]) {
            ContactList.add(addConMap.Allergan_Customer_Contact_agn__c);
        }
        List<Allergan_Customer_Contact_AGN__c> customerContacts = new List<Allergan_Customer_Contact_AGN__c>([SELECT Id,Parent_AGN__c,First_Name_AGN__c,Last_Name_AGN__c,
                                                                       Contact_Person_Type_AGN__c,Email_AGN__c,SAP_Action_AGN__c,Phone_AGN__c    
                                                                       FROM Allergan_Customer_Contact_AGN__c 
                                                                       WHERE Id in :ContactList AND Contact_Person_Type_AGN__c != null]);
        return customerContacts;
    }
    
    // This method will fetch customer contact from Allergan_Customer_Contact_AGN__c if no mapping present in Allergan_Address_Contact_Mapping_agn__c object
    public static void fetchContactPersonDetails(Allergan_Customer_Registration_AGN__c customer){         
        customerContacts = new List<Allergan_Customer_Contact_AGN__c>([SELECT Id,Parent_AGN__c,First_Name_AGN__c,Last_Name_AGN__c,
                                                                       Contact_Person_Type_AGN__c,Email_AGN__c,SAP_Action_AGN__c,Phone_AGN__c    
                                                                       FROM Allergan_Customer_Contact_AGN__c 
                                                                       WHERE Parent_AGN__c =: customer.Id AND Contact_Person_Type_AGN__c != null]);      
    } 
    // PMO 2151 end
    
    public static void fetchFieldMappings(String CustCountryCode){
        for (SF_to_SAP_Account_Mapping_AGN__mdt mapping : [SELECT SAP_Field_AGN__c, SF_Field_AGN__c,JSON_Order_AGN__c,Is_Collection_AGN__c, Is_Required__c FROM SF_to_SAP_Account_Mapping_AGN__mdt WHERE (Country_Code__c=:CustCountryCode OR Country_Code__c= Null)  ORDER BY JSON_Order_AGN__c NULLS LAST]){ // Country Code field and filter added By Krishanu
            if(!mapping.Is_Collection_AGN__c){
                sfToSapAccountFieldMap.put(mapping.SAP_Field_AGN__c, mapping.SF_Field_AGN__c);
                sfToSapAccountFieldMapRequired.put(mapping.SAP_Field_AGN__c, new map<string, boolean>{mapping.SF_Field_AGN__c => mapping.Is_Required__c});
            }
            else
                sfToSapAccountFieldMapListType.put(mapping.SAP_Field_AGN__c, mapping.SF_Field_AGN__c); 
        }
    }
   /* 
    public static void fetchFieldMappingsCr(String CustCountryCode){
        for (SF_TO_SAP_CREDIT_MASTER_AGN__mdt mapping : [SELECT SAP_Field_AGN__c,SF_Field_AGN__c,JSON_Order_AGN__c,
                                                         Is_Collection_AGN__c,IsDate_AGN__c,IsNumber_AGN__c 
                                                         FROM SF_TO_SAP_CREDIT_MASTER_AGN__mdt 
                                                         ORDER BY JSON_Order_AGN__c]){ 
            if(!mapping.Is_Collection_AGN__c)
                sfToSapAccountFieldMap.put(mapping.SAP_Field_AGN__c, mapping.SF_Field_AGN__c);
            else
                sfToSapAccountFieldMapListType.put(mapping.SAP_Field_AGN__c, mapping.SF_Field_AGN__c);
        }
    } */
    
    public static string getListTypeMetadataDetails(list<SObject> recordList,string sapFieldColtype)
    {
        if(sapFieldColtype=='CUST_TEXTS'){
            string mapping='';
            map<string, string> fieldValueMapForList = new map<string, string>();
            for(CUST_TEXTS_AGN__mdt ct: [SELECT DeveloperName,  TEXT_ID_AGN__c, TEXT_DTLS_AGN__c,MasterLabel FROM CUST_TEXTS_AGN__mdt])
            {
                string sfObjectName =ct.TEXT_DTLS_AGN__c.split('\\.')[0];
                string sfFieldName = ct.TEXT_DTLS_AGN__c.split('\\.')[1];
                for(SObject obj : recordList){
                    if (obj.getSObjectType().getDescribe().getName() == sfObjectName){ //compare object name
                        string tempVal=(string)obj.get(sfFieldName)!=null?'"'+(string)obj.get(sfFieldName)+'"':'""';
                        if(tempVal != null 
                           && String.isNotBlank(country) 
                           && country == 'AU' 
                           || country == 'NZ' 
                           || country == 'AN'){
                            tempVal = tempVal.toUpperCase();       
                        }
                        fieldValueMapForList.put('"'+ct.MasterLabel.split('_')[0]+'_'+ct.MasterLabel.split('_')[1]+'"'+':'+'"'+ct.TEXT_ID_AGN__c+'"',
                                                 '"'+ct.DeveloperName.split('_')[0]+'_'+ct.DeveloperName.split('_')[1]+'"'+':'+tempVal);  //get field value from object
                    }
                }
            }
            for(string key:fieldValueMapForList.keyset())
            {
                mapping=mapping+'{'+key+','+fieldValueMapForList.get(key)+'},';
            }
            mapping=mapping.subString(0,mapping.Length()-1);
            system.debug('Mapping JSON>>>>>>>>>>>>>>>>>>'+mapping);
            return mapping;
        }else if(sapFieldColtype=='CONTACT_PERSON'){
            string mapping='';
            List<map<string, string>> fieldMapList = new List<map<string, string>>();
            map<string, string> fieldValueMapForList = new map<string, string>();
            system.debug('country>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+country);
            //commented to test contact model changes
            //if(String.isNotBlank(country) && country == 'AN' || country == 'AU' || country == 'NZ'){
            
            List<CONTACT_PERSON_AGN__mdt> contactPerson = new List<CONTACT_PERSON_AGN__mdt>([SELECT SAP_Field_AGN__c,SF_Field__c FROM CONTACT_PERSON_AGN__mdt]);
            for(SObject o : recordList){
                // PMO 2151 start
                /* Existing code start
                 if (o.getSObjectType().getDescribe().getName() == 'Allergan_Customer_Address_AGN__c'
                                    && (string)o.get('SAP_Account_Group_AGN__c') == '0001'){
                    for(SObject obj : customerContacts){
                        fieldValueMapForList = new map<string, string>();
                        mapping='{';
                        for(CONTACT_PERSON_AGN__mdt ct: contactPerson){
                            string sfObjectName =ct.SF_Field__c.split('\\.')[0];
                            string sfFieldName = ct.SF_Field__c.split('\\.')[1];
                            //system.debug('obj.getSObjectType().getDescribe().getName()>>>>>>>'+obj.getSObjectType().getDescribe().getName());
                            //system.debug('sfObjectName>>>>>>>'+sfObjectName);
                            if (sfObjectName == obj.getSObjectType().getDescribe().getName()){ //compare object name
                                //system.debug('inside condn>>>>>>'+obj.get(sfFieldName));
                                string tempVal=(string)obj.get(sfFieldName)!=null?'"'+(string)obj.get(sfFieldName)+'"':'""';
                                if(tempVal != null){
                                   tempVal = tempVal.toUpperCase(); 
                                }
                                //system.debug('tempVal>>>>>>>>>>>>>>>>>>>>>>>'+tempVal);
                                fieldValueMapForList.put('"'+ct.SAP_Field_AGN__c+'"',tempVal);  //get field value from object
                            }
                            \*for(string key:fieldValueMapForList.keyset()){
                                mapping=mapping+key+':'+fieldValueMapForList.get(key)+',';
                                }
                                //mapping='{'+mapping.subString(0,mapping.Length()-1)+'}';
                                mapping= mapping.subString(0,mapping.Length()-1);*\
                            system.debug('mapping>>>>>>>>>>>>>>>>>>>>>>'+mapping);
                            
                        }
                        fieldMapList.add(fieldValueMapForList);
                        
                    }
                                   

               
                for(map<string, string> fieldValueMap : fieldMapList){
                    
                    for(string key:fieldValueMap.keyset()){
                       mapping=mapping+key+':'+fieldValueMap.get(key)+',';
                    }
                    //mapping='{'+mapping.subString(0,mapping.Length()-1)+'}';
                    mapping= mapping.subString(0,mapping.Length()-1);
                    mapping = mapping + '},{';
                }
                
                mapping = mapping.removeEnd(',{');
                                         }
                Existing code end */ 
                // If no mapping present in Allergan_Address_Contact_Mapping_agn__c object then it will associate contact with Sold To address in SAP request body
                if (customerContactFromAddrContMapping.size() == 0 && o.getSObjectType().getDescribe().getName() == 'Allergan_Customer_Address_AGN__c' && (string)o.get('SAP_Account_Group_AGN__c') == '0001'){
                    for(SObject obj : customerContacts){
                        fieldValueMapForList = new map<string, string>();
                        mapping='{';
                        for(CONTACT_PERSON_AGN__mdt ct: contactPerson){
                            string sfObjectName =ct.SF_Field__c.split('\\.')[0];
                            string sfFieldName = ct.SF_Field__c.split('\\.')[1];
                            if (sfObjectName == obj.getSObjectType().getDescribe().getName()){ //compare object name
                                string tempVal=(string)obj.get(sfFieldName)!=null?'"'+(string)obj.get(sfFieldName)+'"':'""';
                                if(tempVal != null){
                                    tempVal = tempVal.toUpperCase(); 
                                }
                                fieldValueMapForList.put('"'+ct.SAP_Field_AGN__c+'"',tempVal);  //get field value from object
                            }
                        }
                        fieldMapList.add(fieldValueMapForList);
                    }
                    for(map<string, string> fieldValueMap : fieldMapList){
                        for(string key:fieldValueMap.keyset()){
                            mapping=mapping+key+':'+fieldValueMap.get(key)+',';
                        }
                        mapping= mapping.subString(0,mapping.Length()-1);
                        mapping = mapping + '},{';
                    }
                    mapping = mapping.removeEnd(',{');
                } // If mapping present in Allergan_Address_Contact_Mapping_agn__c object then it will associate contact(s) with address(es) based on Mapping object in SAP request body 
                else if (o.getSObjectType().getDescribe().getName() == 'Allergan_Customer_Address_AGN__c' && customerContactFromAddrContMapping.size() > 0){
                    for(SObject obj : customerContactFromAddrContMapping){
                        fieldValueMapForList = new map<string, string>();
                        mapping='{';
                        for(CONTACT_PERSON_AGN__mdt ct: contactPerson){
                            string sfObjectName =ct.SF_Field__c.split('\\.')[0];
                            string sfFieldName = ct.SF_Field__c.split('\\.')[1];
                            if (sfObjectName == obj.getSObjectType().getDescribe().getName()){ //compare object name
                                string tempVal=(string)obj.get(sfFieldName)!=null?'"'+(string)obj.get(sfFieldName)+'"':'""';
                                if(tempVal != null){
                                    tempVal = tempVal.toUpperCase(); 
                                }
                                fieldValueMapForList.put('"'+ct.SAP_Field_AGN__c+'"',tempVal);  //get field value from object
                            }
                        }
                        fieldMapList.add(fieldValueMapForList);
                    }
                    for(map<string, string> fieldValueMap : fieldMapList){
                        for(string key:fieldValueMap.keyset()){
                            mapping=mapping+key+':'+fieldValueMap.get(key)+',';
                        }
                        mapping= mapping.subString(0,mapping.Length()-1);
                        mapping = mapping + '},{';
                    }
                    mapping = mapping.removeEnd(',{');
                }
                // PMO 2151 end
            }
            //}
            /*commented to test contact model changes for all countries
            else{
            for(CONTACT_PERSON_AGN__mdt ct: [SELECT SAP_Field_AGN__c,SF_Field__c FROM CONTACT_PERSON_AGN__mdt])
            {
            string sfObjectName =ct.SF_Field__c.split('\\.')[0];
            string sfFieldName = ct.SF_Field__c.split('\\.')[1];
            system.debug('recordList>>>>>>'+recordList);
            for(SObject obj : recordList){
            if (obj.getSObjectType().getDescribe().getName() == sfObjectName){ //compare object name
            string tempVal=(string)obj.get(sfFieldName)!=null?'"'+(string)obj.get(sfFieldName)+'"':'""';
            fieldValueMapForList.put('"'+ct.SAP_Field_AGN__c+'"',tempVal);  //get field value from object
            }
            }
            }
            for(string key:fieldValueMapForList.keyset()){
            mapping=mapping+key+':'+fieldValueMapForList.get(key)+',';
            }
            if(mapping.Length()>0){
            mapping='{'+mapping.subString(0,mapping.Length()-1)+'}';
            }
            
            }*/
            return mapping;
        }
        /*
         // For Brazil Credit Text  
         
         else if(sapFieldColtype=='TEXT_ID'){
           string mapping='';
             map<string, string> fieldValueMapForList = new map<string, string>();
            for(CREDIT_CUST_TEXT_AGN__mdt ct: [SELECT MasterLabel,SPRAS_AGN__c,TEXT_AGN__c FROM CREDIT_CUST_TEXT_AGN__mdt]){
                mapping += '{';
                String key = 'ID';
                String val = ct.MasterLabel;
                mapping += '"' +key+'" : "'+val + '" ,';
                key = 'SPRAS';
                val = ct.SPRAS_AGN__c;
                mapping += '"' +key+'" : "'+val + '" ,';
                key = 'TEXT';
                val = ct.TEXT_AGN__c;
                
                
                string sfObjectName =ct.TEXT_AGN__c.split('\\.')[0];
                string sfFieldName = ct.TEXT_AGN__c.split('\\.')[1];
                for(SObject obj : recordList){
                    if (obj.getSObjectType().getDescribe().getName() == sfObjectName){ //compare object name
                        string tempVal = (string)obj.get(sfFieldName)!=null?(string)obj.get(sfFieldName):'';
                        if(String.isNotBlank(tempVal)){
                            mapping += '"' +key+'" : "'+tempVal + '"'; 
                        }else{
                            mapping += '"' +key+'" : ""';
                        }
                        
                    }
                }
                mapping += '},';
                system.debug('mapping>>>>>>>>>>>>>>'+mapping);
            }
            mapping=mapping.subString(0,mapping.Length()-1);
            system.debug('Mapping JSON>>>>>>>>>>>>>>>>>>'+mapping); return null;
            return mapping;
            
        } */
        else if(sapFieldColtype == 'NEW_ACCOUNT'){
            string mapping='';
            map<string, string> fieldValueMapForList = new map<string, string>();
            for(NEW_ACCOUNT_AGN__mdt ct: [SELECT SAP_Field_AGN__c,SF_Field_AGN__c FROM NEW_ACCOUNT_AGN__mdt])
            {
                string sfObjectName =ct.SF_Field_AGN__c.split('\\.')[0];
                string sfFieldName = ct.SF_Field_AGN__c.split('\\.')[1];
                for(SObject obj : recordList){
                    if (obj.getSObjectType().getDescribe().getName() == sfObjectName){ //compare object name
                        SObjectType r = ((SObject)(Type.forName('Schema.'+sfObjectName).newInstance())).getSObjectType();
                        DescribeSObjectResult des = r.getDescribe();
                        //System.debug('yoooooooooooooooooooooo'+des.fields.getMap().get(sfFieldName).getDescribe().getType());
                        /*if(des.fields.getMap().get(sfFieldName).getDescribe().getType() == Schema.DisplayType.BOOLEAN){
                           String tempVal = '';
                            if(obj.get(sfFieldName) == true){
                               tempVal = '"'+True+'"';
                            }else if(obj.get(sfFieldName) == false){
                               tempVal = '"'+False+'"';
                            }
                           fieldValueMapForList.put('"'+ct.SAP_Field_AGN__c+'"',tempVal);  //get field value from object  
                        }else{
                           string tempVal=(string)obj.get(sfFieldName)!=null?'"'+(string)obj.get(sfFieldName)+'"':'""';
                           fieldValueMapForList.put('"'+ct.SAP_Field_AGN__c+'"',tempVal);  //get field value from object 
                        }*/
                        string tempVal=(string)obj.get(sfFieldName)!=null?'"'+(string)obj.get(sfFieldName)+'"':'""';
                        if(tempVal != null 
                           && String.isNotBlank(country) 
                           && country == 'AU' 
                           || country == 'NZ' 
                           || country == 'AN'){
                            tempVal = tempVal.toUpperCase();       
                        }
                        fieldValueMapForList.put('"'+ct.SAP_Field_AGN__c+'"',tempVal);  //get field value from object 
                        
                    }
                }
            }
            for(string key:fieldValueMapForList.keyset())
            {
                mapping=mapping+key+':'+fieldValueMapForList.get(key)+',';
            }
            mapping='{'+mapping.subString(0,mapping.Length()-1)+'}';
            system.debug('Mapping JSON>>>>>>>>>>>>>>>>>>'+mapping);
            return mapping;
        }else if(sapFieldColtype == 'ADTNL_DATA'){
            string mapping='';
            map<string, string> fieldValueMapForList = new map<string, string>();
            for(ADTNL_DATA_AGN__mdt ct: [SELECT SAP_Field_AGN__c,SF_Field_AGN__c FROM ADTNL_DATA_AGN__mdt])
            {
                string sfObjectName =ct.SF_Field_AGN__c.split('\\.')[0];
                string sfFieldName = ct.SF_Field_AGN__c.split('\\.')[1];
                for(SObject obj : recordList){
                    if (obj.getSObjectType().getDescribe().getName() == sfObjectName){ //compare object name
                        string tempVal=(string)obj.get(sfFieldName)!=null?'"'+(string)obj.get(sfFieldName)+'"':'""';
                        if(tempVal != null 
                           && String.isNotBlank(country) 
                           && country == 'AU' 
                           || country == 'NZ' 
                           || country == 'AN'){
                            tempVal = tempVal.toUpperCase();       
                        }
                        fieldValueMapForList.put('"'+ct.SAP_Field_AGN__c+'"',tempVal);  //get field value from object
                    }
                }
            }
            for(string key:fieldValueMapForList.keyset())
            {
                mapping=mapping+key+':'+fieldValueMapForList.get(key)+',';
            }
            mapping='{'+mapping.subString(0,mapping.Length()-1)+'}';
            system.debug('Mapping JSON>>>>>>>>>>>>>>>>>>'+mapping);
            return mapping;
        }else if(sapFieldColtype == 'CUST_PROGRAM'){
            string mapping='';
            map<string, string> fieldValueMapForList = new map<string, string>(); 
            for(CUST_PROGRAM_AGN__mdt ct: [SELECT SAP_Field_AGN__c,SF_Field_AGN__c FROM CUST_PROGRAM_AGN__mdt])
            {
                string sfObjectName =ct.SF_Field_AGN__c.split('\\.')[0];
                string sfFieldName = ct.SF_Field_AGN__c.split('\\.')[1];
                for(SObject obj : recordList){
                    if (obj.getSObjectType().getDescribe().getName() == sfObjectName){ //compare object name
                        string tempVal=(string)obj.get(sfFieldName)!=null?'"'+(string)obj.get(sfFieldName)+'"':'""';
                        if(tempVal != null 
                           && String.isNotBlank(country) 
                           && country == 'AU' 
                           || country == 'NZ' 
                           || country == 'AN'){
                            tempVal = tempVal.toUpperCase();       
                        }
                        fieldValueMapForList.put('"'+ct.SAP_Field_AGN__c+'"',tempVal);  //get field value from object
                    }
                }
            } 
            for(string key:fieldValueMapForList.keyset())
            {
                mapping=mapping+key+':'+fieldValueMapForList.get(key)+',';
            }
            mapping='{'+mapping.subString(0,mapping.Length()-1)+'}';
            system.debug('Mapping JSON>>>>>>>>>>>>>>>>>>'+mapping);
            return mapping;
        }else
            return '';
    }
    public static list<map<string, string>> parseAccountJson(String jsonResponse){
        
        
        JSONParser parser = JSON.createParser(jsonResponse);
        list<map<string, string>> jsonResponseMapList = new list<map<string, string>>();
        
        while (parser.nextToken() != null) {
            // Start at the array of Json Response.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next customer registration address record
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire customer registration address record
                        String fieldErrorMessage='';
                        CustRegAddress cra = (CustRegAddress)parser.readValueAs(CustRegAddress.class);
                        
                        map<string, string> jsonResponseMap = new map<string, string>();
                        jsonResponseMap.put('ACTION', cra.action);
                        jsonResponseMap.put('CUST', cra.cust);
                        jsonResponseMap.put('ACCTGRP', cra.acctgrp);
                        jsonResponseMap.put('REF_CUST', cra.ref_cust);
                        jsonResponseMap.put('IND', cra.ind);
                        jsonResponseMap.put('MESSAGE', cra.message);
                        if(cra.field_errors.size()>0){
                            for(cls_FIELD_ERRORS fe : cra.field_errors){
                                fieldErrorMessage= fieldErrorMessage+ fe.fieldName + ' : ' + fe.message + '\n';
                            }
                            //fieldErrorMessage= fieldErrorMessage+ cra.field_errors[0].fieldName+ ' : '+ cra.field_errors[0].message + ' || ';
                        }
                        jsonResponseMap.put('FIELD_ERRORS', fieldErrorMessage);
                        jsonResponseMap.put('ADDR_SFID', cra.addr_sfid);                                                
                        jsonResponseMapList.add(jsonResponseMap);
                    }
                }
            }
        }
        
        return jsonResponseMapList;
    }
    
    public static boolean IsSandbox(){
        Organization org = [select IsSandbox from Organization];
        return org.IsSandbox;
    }
    
    public class CustRegAddress {
        public String action;
        public String cust;
        public String acctgrp;
        public String ref_cust;
        public String ind;
        public String message;
        public String addr_sfid;
        public List<cls_FIELD_ERRORS> field_errors;
        
        public CustRegAddress(String act, String sapno, String accountgrp, String refCust, String indicator, String msg, list<cls_FIELD_ERRORS>fldErrors ,String addr_id) {
            action = act;
            cust = sapno;
            acctgrp = accountgrp;
            ref_cust = refCust;
            ind = indicator;
            message = msg;
            field_errors= fldErrors;
            addr_sfid = addr_id;
        }
    }
    public class cls_FIELD_ERRORS {
        public String fieldName;    //IBAN
        public String message;  //Example: "The check digit of the IBAN is outside of the valid range 02-98"
        
        public cls_FIELD_ERRORS(String fname, String msg){  
            fieldName = fname;
            message = msg;
        }
    }
    
}