/**
 * @description       : Save the data from Server for Registration process Step2, step3 and step4
 * @author            : GCSP Core Plus Dev Team
 * @group             : 
 * @last modified on  : 04-15-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   01-21-2021   GCSP Core Plus Dev Team   Initial Version
**/
public without sharing class AGN_GCSP_CustomerRegStep2Controller {
    public AGN_GCSP_CustomerRegStep2Controller() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Object> fetchCountryList(String countryCode, String source){ 
        try{  
            return AGN_GCSP_CustomerRegStep1Controller.fetchCountryList(countryCode,source);   
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map < String, List < AGN_Community_Layout_Setting__mdt >> getLayout(String country, String stepNo, String source) {
        try{
            return AGN_GCSP_CustomerRegUtils.getLayoutCountrySetting(country, stepNo, null, null, null, source);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map < String, List < AGN_Community_Layout_Setting__mdt >> getLayout(String country, String stepNo, String customerType, String customerSubType, List < Customer_Type_Configuration_AGN__c > custTypeConfig, String source) {
        try{  
            return AGN_GCSP_CustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, custTypeConfig, source);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    /* For Update Registration --Start */
    @AuraEnabled(cacheable=true)
    public static Map < String, List < AGN_Community_Layout_Setting__mdt >> getLayoutUpdateReg(String country, String stepNo, String source) {
        try{
            return AGN_GCSP_CustomerRegUtils.getLayoutCountrySettingUpdateReg(country, stepNo, null, null, null, source);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map < String, List < AGN_Community_Layout_Setting__mdt >> getLayoutUpdateReg(String country, String stepNo, String customerType, String customerSubType, List < Customer_Type_Configuration_AGN__c > custTypeConfig, String source) {
        try{  
            return AGN_GCSP_CustomerRegUtils.getLayoutCountrySettingUpdateReg(country, stepNo, customerType, customerSubType, custTypeConfig, source);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    /* For Update Registration -- End */

    @AuraEnabled
    public static String getCustomerGroup(String countryCode, String customerType , String customerSubType) {  
        try{
            return AGN_GCSP_CustomerRegUtils.getCustomerGroup(countryCode, customerType, customerSubType);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 

    public static List<Customer_Type_Configuration_AGN__c> customerTypeConfig(String countryCode, String source) {
        try{
            return AGN_GCSP_PortalCustomerRegUtils.customerTypeConfig(countryCode,source);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Allergan_Customer_Registration_AGN__c getCustomerRegDetails() {
        try{
            
            return AGN_GCSP_PortalCustomerRegUtils.getCustomerRegDetails();
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    @AuraEnabled
    public static Allergan_Customer_Registration_AGN__c getCustomerRegDetailsCS(String caseRecId) {
        try{
            return AGN_GCSP_PortalCustomerRegUtils.getCustomerRegDetailsCS(caseRecId);  
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled
    public static List<Allergan_Customer_Address_AGN__c> getCustomerAddressDetails(String custRegId) {     
        try{
            return AGN_GCSP_PortalCustomerRegUtils.getCustomerAddressDetails(custRegId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    
    @AuraEnabled
    public static Case getCaseDetails(String caseId) { 
        try{
            return AGN_GCSP_PortalCustomerRegUtils.getCaseDetails(caseId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled
    public static Allergan_Customer_Contact_AGN__c getcustomerContactDetails(String custRegId) {
        try{
            return AGN_GCSP_PortalCustomerRegUtils.getcustomerContactDetails(custRegId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled
    public static Id upsertRegistrationDetails(Allergan_Customer_Address_AGN__c soldToAddr, 
                                          List<Allergan_Customer_Address_AGN__c> billToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> shipToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> newBillToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> newShipToAddrList,
                                          Allergan_Customer_Registration_AGN__c customer,
                                          String actionType,
                                          String currentStep)
    {
        
        try{
            
            return AGN_GCSP_PortalCustomerRegUtils.upsertRegistrationDetails(soldToAddr, 
                                                                           billToAddrList, 
                                                                           shipToAddrList, 
                                                                           newBillToAddrList, 
                                                                           newShipToAddrList,
                                                                             customer,
                                                                           actionType,
                                                                          currentStep);
            }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            system.debug('error>>>>>>>>>>>>>>'+e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
            }
    }
    
    
    @AuraEnabled
    public static Id saveChunk(String fileId,String attachmentId, Id parentId, String fileName, String base64Data, String contentType, String description) {
        try{
            return AGN_GCSP_PortalCustomerRegUtils.saveChunk( fileId, attachmentId,  parentId,  fileName,  base64Data,  contentType,  description);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteFile(Id fileId) {
        try{
            AGN_GCSP_PortalCustomerRegUtils.deleteFile(fileId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id upsertCustomerDetails(Allergan_Customer_Registration_AGN__c customer,
                                           Allergan_Customer_Address_AGN__c customerAddress, 
                                           String Specialty,
                                           String actionType,
                                           String currentStep,String source)
    {
        
        try{ 
            return AGN_GCSP_PortalCustomerRegUtils.upsertCustomerDetails(customer,customerAddress,Specialty,actionType,currentStep,source); 
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Allergan_Customer_Address_AGN__c FetchObjectDetails(){    
        try{ 
            Sobject objCust = getCustomerRegDetails();  
            
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
            query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Parent_AGN__c ='+'\''+ objCust.Id+ '\'' + 'AND Sold_To_AGN__c = True Limit 1';
            
            Allergan_Customer_Address_AGN__c objAdd = Database.query(query);     
            
            return objAdd;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteAddress(Allergan_Customer_Address_AGN__c customerAddress){
        
        try{
            AGN_GCSP_PortalCustomerRegUtils.deleteAddress(customerAddress);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    @AuraEnabled
    public static AGN_GCSP_Settings__c getGCSPSettings(String country){
        return AGN_GCSP_Settings__c.getValues(country);
    } 
    @AuraEnabled
    public static string upsertAllAddressDetails(Allergan_Customer_Address_AGN__c soldToAddr, 
                                          List<Allergan_Customer_Address_AGN__c> billToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> shipToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> newBillToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> newShipToAddrList,
                                          Allergan_Customer_Registration_AGN__c customer,
                                          String currentStep,
                                          String actionType,
                                          String source)
    {
        
        try{          
            return AGN_GCSP_PortalCustomerRegUtils.upsertAllAddressDetails(soldToAddr, billToAddrList, shipToAddrList, newBillToAddrList, newShipToAddrList,customer,currentStep,actionType,source);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            system.debug('error>>>>>>>>>>>>>>'+e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
   @AuraEnabled
    public static List<sObject> getPaymentTerms(list<Id> paymentMethodSet, string source){
        system.debug('Inside getPaymentTerms>>>>>>>>>>>>>>>>'+paymentMethodSet);
        try{
            List<Payment_Term_AGN__c> terms = new List<Payment_Term_AGN__c>([SELECT Id,Payment_Term_Label_AGN__c,
                                                                              Name,
                                                                             SAP_Payment_Term_Code_AGN__c,Form_Of_Payment__c,
                                                                             Bank_Details_Required_AGN__c
                                                                             FROM Payment_Term_AGN__c 
                                                                             WHERE Form_Of_Payment__c IN : paymentMethodSet
                                                                             AND Active_AGN__c = true
                                                                             AND Source_AGN__c includes(:source)]);
            system.debug('terms>>>>>>>>>>>>>>>>>'+terms);
            return terms;    
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<sObject> getPaymentMethods(String country, string source){
        system.debug('Inside getPaymentMethods>>>>>>>>>>>>>>>>'+country);
        try{
            List<Form_Of_Payment_AGN__c> terms = new List<Form_Of_Payment_AGN__c>([SELECT Id,Form_Of_Payment_Label_AGN__c,
                                                                                    Name,
                                                                                   Bank_Details_Required_AGN__c
                                                                                   FROM Form_Of_Payment_AGN__c 
                                                                                   WHERE SAP_Country_Code_AGN__c =: country 
                                                                                   AND Active_AGN__c= true
                                                                                   AND Source_AGN__c includes(:source)]);
            system.debug('Form OF Payments>>>>>>>>>>>>>>>>>'+terms);
            return terms;      
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
     @AuraEnabled
    public static List<sObject> getPickListValues(string objectName,String columnName,String columnId, String whereCondition){
        String wherecond = whereCondition != null ? String.valueOf(whereCondition) : '';
        // Checkmarx GCSP Core+ and HCO Harmonization: Adding below lines to avoid SOQL/SOSL Injection - start
        columnName = String.escapeSingleQuotes(String.valueOf(columnName));
        columnId = String.escapeSingleQuotes(String.valueOf(columnId));
        objectName = String.escapeSingleQuotes(String.valueOf(objectName));
        String query = 'select '+columnName+','+columnId+' From '+objectName + wherecond;
        // String query = 'select '+String.valueOf(columnName)+','+String.valueOf(columnId)+' From '+objectName + wherecond;
        // Checkmarx GCSP Core+ and HCO Harmonization: Adding below line to avoid SOQL/SOSL Injection - end
        system.debug('@@@@query@@@'+ query);
        system.debug('@@@@whereCondition@@@'+ wherecond);
        List<sObject> PicklistValues = Database.query(query);
        return PicklistValues;
    }
    
    @AuraEnabled
    public static DocumentDetails getAllAttachments(Id parentRecId, String source){
        try{
            AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
            System.debug('parentRecId in getAllAttachments : '+parentRecId);
            set<string> documentDescSet= new set<string>();
            list<Attachment>listOfSavedAttachments = new list<Attachment>();
            list<AttachmentWrapper> newAttachments = new list<AttachmentWrapper>();
            DocumentDetails attWithDetails = new DocumentDetails();
            
            Allergan_Customer_Address_AGN__c addressdetails=getCustomerAddressDetailsTemp(parentRecId);
            
            Allergan_Customer_Registration_AGN__c parentRecordDetails = getCustomerRegistrationDetailsTemp(parentRecId);  
            
            string documentListAdditional;
            String documentListWithoutAdditional='';
            string documentList='';
            Customer_Type_Configuration_AGN__c configData = getDocumentList(parentRecordDetails, source);
            
            string webSites = configData.Official_website_AGN__c;
                //getDocumentList(parentRecordDetails, source).Official_website_AGN__c;
            System.debug('Category : '+parentRecordDetails.Customer_Category_AGN__c);
            
            documentList = source.equalsIgnoreCase('oam') ? configData.Documents_For_Online_Registration_AGN__c : configData.Documents_Required_AGN__c;
                //getDocumentList(parentRecordDetails, source).Documents_For_Online_Registration_AGN__c;
            if(!string.isEmpty(documentList)){
                string [] documentNames = documentList.split(';');        
                for (integer i = 0; i < documentNames.size(); i++){
                    newAttachments.add(new AttachmentWrapper(documentNames[i], new Attachment(Description = documentNames[i])));
                    documentDescSet.add(documentNames[i]);
                }
            }
            
            if(!string.isEmpty(webSites)){        
                string [] websiteNames = webSites.split(';');        
                for (integer i = 0; i < websiteNames.size(); i++){
                    attWithDetails.webSiteList.add(websiteNames[i]);
                }
            }
            system.debug('==documentDescSet=='+ documentDescSet);
            
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
                        //String communityBaseURL = commonOktaConfig.Community_Base_URL_AGN__c + commonOktaConfig.Community_Suffix_AGN__c;
                       
                        String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(parentRecordDetails.Country_Code_AGN__c)?.get('Community_Base_URL_AGN__c');           
                        String comSuffix = (String)AGN_GCSP_Settings__c.getValues(parentRecordDetails.Country_Code_AGN__c)?.get('Community_Suffix_AGN__c');
                        String communityBaseURL = ''; 
                        
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
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
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
    /*@AuraEnabled
    public static Allergan_Customer_Contact_AGN__c submitContactDetails(Allergan_Customer_Contact_AGN__c contactObj, Id addressId){
        insert contactObj;
        Allergan_Address_Contact_Mapping_agn__c contactMappingObj = new Allergan_Address_Contact_Mapping_agn__c();
        contactMappingObj.Allergan_Customer_Address_agn__c = addressId;
        contactMappingObj.Allergan_Customer_Contact_agn__c = contactObj.Id;
        contactMappingObj.Allergan_Customer_Registration_agn__c = contactObj.Parent_AGN__c;
        insert contactMappingObj;
        return contactObj;
        }*/
    
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
    
    // for es state wise additional attachment purpose
    public static Allergan_Customer_Address_AGN__c getCustomerAddressDetailsTemp (Id crId ){
        Allergan_Customer_Address_AGN__c caRecord = new Allergan_Customer_Address_AGN__c();   
        List<Allergan_Customer_Address_AGN__c> addresses = new List<Allergan_Customer_Address_AGN__c>([SELECT ID,Country_Code_AGN__c,State_AGN__c 
                                                                                                       FROM Allergan_Customer_Address_AGN__c 
                                                                                                       WHERE Parent_AGN__c =:crId LIMIT 1]);
        if(addresses.size() > 0){
            caRecord= addresses.get(0);
        }
        
        return caRecord;
    }
    
    @AuraEnabled
    public static Allergan_Customer_Registration_AGN__c getCustomerRegistrationDetailsTemp(Id crId ){
        Allergan_Customer_Registration_AGN__c crRecord = new Allergan_Customer_Registration_AGN__c();
        List<Allergan_Customer_Registration_AGN__c> regs = new List<Allergan_Customer_Registration_AGN__c>([SELECT Customer_Group_AGN__c,
                   Customer_Category_AGN__c,
                   Customer_Sub_Category_AGN__c,
                   SAP_Country_Code_AGN__c,
                   Country_Code_AGN__c,
                   Country_AGN__c
                   FROM Allergan_Customer_Registration_AGN__c
                   WHERE Id =: crId LIMIT 1]);
        if(regs.size() > 0){
            crRecord = regs.get(0);
        }
        system.debug('Customer Registration>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+crRecord);
        return crRecord;
        
    } 
    
     @AuraEnabled
    public static Customer_Type_Configuration_AGN__c getDocumentList ( Allergan_Customer_Registration_AGN__c  custRegRecord, String source){
        Customer_Type_Configuration_AGN__c ctcRec = new Customer_Type_Configuration_AGN__c();       
        List<Customer_Type_Configuration_AGN__c> configs = new List<Customer_Type_Configuration_AGN__c>();
       system.debug('==custRegRecord=='+ custRegRecord.Country_Code_AGN__c + custRegRecord.Customer_Group_AGN__c+ '-'+custRegRecord.SAP_Country_Code_AGN__c+ '-'+custRegRecord.Customer_Category_AGN__c + '-'+custRegRecord.Customer_Sub_Category_AGN__c );
        String countryCode = custRegRecord.SAP_Country_Code_AGN__c; 
        if(String.isEmpty(countryCode) || (countryCode.equalsIgnoreCase('AU'))){
            countryCode = custRegRecord.Country_Code_AGN__c;
        }  
        if(source.equalsIgnoreCase('oam')){
            configs = [SELECT Official_website_AGN__c ,
                       Documents_For_Online_Registration_AGN__c,
                       Documents_Required_AGN__c,
                       Country_Code_AGN__c,
                       Customer_Country_AGN__c
                       FROM Customer_Type_Configuration_AGN__c
                       WHERE Customer_Group_AGN__c =: custRegRecord.Customer_Group_AGN__c  AND 
                      // Country_Code_AGN__c =:custRegRecord.Country_Code_AGN__c AND
                       Customer_Country_AGN__r.Alpha_2_Code_vod__c =: countryCode AND 
                       Category_AGN__c =:custRegRecord.Customer_Category_AGN__c AND
                       Sub_Category__c =:custRegRecord.Customer_Sub_Category_AGN__c AND
                       State_AGN__c ='' AND
                       Applicable_For_Online_Registration_AGN__c = true
                       LIMIT 1];
        }
        else{
            configs = [SELECT Official_website_AGN__c ,
                       Documents_Required_AGN__c,
                       Documents_For_Online_Registration_AGN__c,
                       Country_Code_AGN__c,
                       Customer_Country_AGN__c
                       FROM Customer_Type_Configuration_AGN__c
                       WHERE Customer_Group_AGN__c =: custRegRecord.Customer_Group_AGN__c  AND 
                     //  Country_Code_AGN__c =:custRegRecord.Country_Code_AGN__c AND
                       Customer_Country_AGN__r.Alpha_2_Code_vod__c =: countryCode AND 
                       Category_AGN__c =:custRegRecord.Customer_Category_AGN__c AND
                       Sub_Category__c =:custRegRecord.Customer_Sub_Category_AGN__c AND
                       State_AGN__c =''
                       LIMIT 1];
        }
        
        
        if(configs.size() > 0){
            ctcRec= configs.get(0);
        }
        //custRegRecord. 
        
        return ctcRec;              
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
    
    @AuraEnabled
    public static AGN_GCSP_PortalCustomerRegUtils.DocumentDetails getDependentAttachments(Id parentRecId,String stepNo,string source, string fieldName, string objectname, string creteriaValue){     
        try{
            return AGN_GCSP_PortalCustomerRegUtils.getDependentAttachments(parentRecId, stepNo, source, fieldName, objectname, creteriaValue);
            //return null;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    

 @AuraEnabled
    public static List<sObject> getSpecialityDetails(String countryCode){     
        try{
            return AGN_GCSP_PortalCustomerRegUtils.getSpecialityDetails(countryCode);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<sObject> getSubSpecialityDetails(String countryCode){     
        try{
            List<sObject> PicklistValues = [SELECT Id,
                                            Name,
                                            English_Value_AGN__c 
                                            FROM Sub_Specialty_Allergan__c
                                            WHERE Country_code_AGN__c=:countryCode
                                            AND Active_AGN__c= true];        
        return PicklistValues; 
           //return AGN_GCSP_PortalCustomerRegUtils.getSubSpecialityDetails(countryCode);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
   
        
    
}