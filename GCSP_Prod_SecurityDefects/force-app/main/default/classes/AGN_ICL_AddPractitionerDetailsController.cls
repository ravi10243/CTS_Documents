/*
Modified by :ICL Project Team
Description: Added code for checking the Practioner image available checkbox if Practioner image is available.
             Added code as a part of ICL wave 3 development for cluster country logic.
             Added Graduation_Year_AGN__c,Contact_Number_AGN__c,Middle_Name_AGN__c,License_Number_AGN__c field as a part of canada rollout
             Added isTwoLayerLayout method as a part of Canada change for Two Column Layout
             Added getMultipicklistBrandCount method for Duallist Box Logic for Brand 
Release :ICL Wave-3
*/
/*
Modified by :ICL Project Team
Description: Line from 68 to 100 ,134 to 135 has been added as a part of DCR Enablement
             Lines from 138 to 149 , 533 to 546 has been added and From Lines 175 TO 187 has been updated as a part of DCR Checkmarxs report. 
Modified Date :3 Mar 2021
*/

public without sharing class AGN_ICL_AddPractitionerDetailsController{
    
    public Practitioner_Listing_AGN__c practitioner{get;set;}
    
    public List<Practitioner_Listing_AGN__c> practitionerList{get;set;}
    
    
    public AGN_ICL_AddPractitionerDetailsController(){
        
    }
    
    @AuraEnabled
    public static List<String> getBrandPicklistValues1()
    {
        List<String> picklistval = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Locator_Listing_AGN__c').getDescribe().fields.getMap().get('Brand_AGN__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            picklistval.add(f.getValue());
        }   
        return picklistval;
    }
    
    @AuraEnabled
    public static List<String> getBrandPicklistValues(){
        User u = [SELECT id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c  
                  FROM User 
                  WHERE id =:UserInfo.getUserId() 
                  LIMIT 1];
        return AGN_ICL_UtlityClass.getBrandPicklistValues(u.Country_Code__c);
    }
    
    
    @AuraEnabled
    public static List<Practitioner_Listing_AGN__c> fetchAllPractioners(String loclstId){
        //String loclistingid = [Select id,name,ContactId,Locator_Listing_Id_AGN__c from User where id =:Userinfo.getUserId() limit 1].Locator_Listing_Id_AGN__c;
        //Graduation_Year_AGN__c,Contact_Number_AGN__c,Middle_Name_AGN__c,License_Number_AGN__c field add as a part of canada rollout
        List<Practitioner_Listing_AGN__c> practitionerList= [SELECT  ID,Salutation_AGN__c,Gender_AGN__c,First_Name_AGN__c,Type_AGN__c,
                                                             Last_Name_AGN__c,Brand_AGN__c,Qualification_AGN__c,Consent_AGN__c,
                                                             Practitioner_Image_Available_AGN__c,Locator_Listing_AGN__c,Years_of_Experience_AGN__c,
                                                             Practitioner_Image_AGN__c,Email_AGN__c ,Status_AGN__c,Graduation_Year_AGN__c,
                                                             Contact_Number_AGN__c,Middle_Name_AGN__c,License_Number_AGN__c
                                                             FROM Practitioner_Listing_AGN__c 
                                                             WHERE Locator_Listing_AGN__c =:loclstId and Status_AGN__c = 'Active'];
        return practitionerList;
    }
    
    @AuraEnabled
    public static Practitioner_Listing_AGN__c addPractitionerRecord(Practitioner_Listing_AGN__c practitioner,String loclstId){
        Account account;
       //Line of code has been added as a part of DCR Enablement 
        AssignmentRule AR = new AssignmentRule(); 
        AR = [select id,Name from AssignmentRule where SobjectType = 'Case' and Active = true and Name =: System.label.AGN_ICL_Case_Assignment_Rule limit 1];
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        dmlOpts.EmailHeader.triggerUserEmail = true;
        //dmlOpts.EmailHeader.triggerAutoResponseEmail = true; 
        
        Locator_Listing_AGN__c loc =[select id,Country_AGN__c,Country_Code_AGN__c from Locator_Listing_AGN__c where id=:loclstId];
        Case cs = new Case();
        cs.Service_AGN__c = 'ICL Practitioner Registration';
        cs.Type = 'New';
        cs.Priority = 'Medium';
        cs.Origin = 'Web';
        cs.Status = 'New';
        cs.Country_AGN_GDPR__c = loc.Country_AGN__c;
        //cs.Subject = 'Practitioner Case';
        //cs.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Support_Request_ICL_Clinic_Registration_AGN' LIMIT 1][0].Id;
        cs.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Support_Request_ICL_Practitioner_Registration_AGN' LIMIT 1][0].Id;
        cs.setOptions(dmlOpts);
        //Adding checkmarx comment
        			       try{
        	List<Case> Casepract = new List<Case>();
           			Casepract.add(cs); 
                    String objCase = 'Case';
                    SObjectType caseObjType = ((SObject)(Type.forName('Schema.'+objCase).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Casepract,caseObjType,'INSERT');
                    insert Casepract; 
                 }
        catch(Exception ex)
            {
                System.debug('There is an exception for the Practitioner Case Creation:'+ex);
			}
       // insert cs; 
        //END
        
        try{
            AGN_ICL_Portal_Settings__c portal_setting = AGN_ICL_Portal_Settings__c.getInstance();
            // Account acc ;
            if(practitioner!= null){
                User u = [Select id,name,Locator_Listing_Id_AGN__c,ContactId,LanguageLocaleKey  from User where id =:UserInfo.getUserId()];
                //Contact con = [Select id,name from Contact where id=:u.ContactId];
                /*String loc_id = [Select id,name,ContactId,Locator_Listing_Id_AGN__c from User where id =:Userinfo.getUserId() limit 1].Locator_Listing_Id_AGN__c;

if(loc_id != null)
{
Locator_Listing_AGN__c loc = [select id,name,Clinic_Admin_AGN__c,Country_Code_AGN__c,User_Language_AGN__c,Account_AGN__c from Locator_Listing_AGN__c where id=:loc_id limit 1];
String acc_id = loc.Account_AGN__c;
acc = [Select Id,Salutation,FirstName,Country_Code__c,LastName,PersonEmail,Primary_Parent_vod__c from Account where Id=:acc_id];
}*/
                String userlang = u.LanguageLocaleKey;
                if(userlang.equalsIgnoreCase('en_AU'))
                {
                    userlang = 'en_GB';
                }
                List<AGN_ICL_Language_Settings__c> icl=[SELECT Name,Language_Code_AGN__c 
                                                        FROM AGN_ICL_Language_Settings__c 
                                                        WHERE Language_Code_AGN__c=:userlang 
                                                        LIMIT 1];
                
                //practitioner.Clinic_AGN__c=acc.id;//'0015E00000ku4FE'; //HCO
                
                practitioner.Locator_Listing_AGN__c=loclstId;//'a7q5E000000CiH5';
                practitioner.Language_AGN__c = icl[0].Name;//langcodemap.get(u.LanguageLocaleKey);//
                practitioner.Status_AGN__c = 'Active';
                 // Line of code has been added as a part of DCR Enablement
                practitioner.ICL_Practitioner_Case__c = cs.Id;
                practitioner.CountryCode__c = loc.Country_Code_AGN__c;
                //END
               //Adding checkmarx comment
             try{
                	List<Practitioner_Listing_AGN__c> practinsert = new List<Practitioner_Listing_AGN__c>();
           			practinsert.add(practitioner); 
                    String objPac = 'Practitioner_Listing_AGN__c';
                    SObjectType pacObjType = ((SObject)(Type.forName('Schema.'+objPac).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(practinsert,pacObjType,'INSERT');
                    insert practinsert;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Practitioner update:'+ex);
			}
            //End
              //  insert practitioner;  
     
            }
        }catch (DMLException ex){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(errorMsg );
            return null;
        }           
        
        return practitioner;
    } 
    
    @AuraEnabled
    public static Practitioner_Listing_AGN__c updatePractitionerRecord(Practitioner_Listing_AGN__c practitioner){
        try{
            
        //Added below lines for checking the Practioner image available checkbox if Practioner image is available.
           if(practitioner.Practitioner_Image_AGN__c!=null)
            {
                practitioner.Practitioner_Image_Available_AGN__c=true;
            }
          //End
              //Adding checkmarx comment
             
                	List<Practitioner_Listing_AGN__c> pract = new List<Practitioner_Listing_AGN__c>();
           			pract.add(practitioner); 
                    String objPac = 'Practitioner_Listing_AGN__c';
                    SObjectType pacObjType = ((SObject)(Type.forName('Schema.'+objPac).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(pract,pacObjType,'UPDATE');
                    update pract;
            

           // update practitioner;
            //SendEmailToPractitioner.sendEmailToPractitioner(practitioner);
        }catch(DMLException ex){
            
            System.debug('There is an exception for the Practitioner update:'+ex);
        }
        return practitioner;
    }
    
    
    @Auraenabled
    public static Boolean deltePractitionerById(Practitioner_Listing_AGN__c Practitioner)
    {
        Boolean success = false;
        Practitioner.Status_AGN__c = 'Inactive';
        Practitioner.Consent_AGN__c = FALSE;
        try{
            update Practitioner;
            success = true;
        }catch(Exception ex)
        {
            success = false;
        }
        updateIndividualRecord(Practitioner);
        sendDeleteNotificationToHCP(Practitioner);
        return success;
    }
    
    public static Boolean updateIndividualRecord(Practitioner_Listing_AGN__c Practitioner){
        
        Individual invObj = new Individual (); 
        try{
            Practitioner_Listing_AGN__c PractObject  = [SELECT Id, Practitioner_AGN__c,Practitioner_AGN__r.PersonIndividualId 
                                                        FROM Practitioner_Listing_AGN__c 
                                                        WHERE Id =: Practitioner.Id];
            if(String.IsNotEmpty(PractObject.Practitioner_AGN__c) && String.IsNotEmpty(PractObject.Practitioner_AGN__r.PersonIndividualId)){
                invObj = [SELECT Id,ICL_Consent_AGN__c 
                          FROM Individual 
                          WHERE id =:PractObject.Practitioner_AGN__r.PersonIndividualId  AND ICL_Consent_AGN__c =TRUE 
                          LIMIT 1];        
                invObj.ICL_Consent_AGN__c = false;
                update invObj;
                return true;                
            }              
        }
        catch(exception ex){
          
        }        
        return false;
    }
    
    public static void  sendDeleteNotificationToHCP(Practitioner_Listing_AGN__c PractObj){
        
        String PractitionerCountryCode = ''; 
        String PractitionerLangCode = '';
        List<EmailTemplate> eTList = new List<EmailTemplate>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        //list<ICL_Email_Status_Log_AGN__c> logList = new list<ICL_Email_Status_Log_AGN__c>(); 
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String fromEmailAddress = (String)portalSetting.From_Email_Address_AGN__c;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName ='Allergan International Clinic Locator'];
        Map<String, EmailTemplate> eTMap = new Map<String, EmailTemplate>(); 
        list<ICL_Email_Status_Log_AGN__c> logList = new list<ICL_Email_Status_Log_AGN__c>();
        for(EmailTemplate objCS : [SELECT Id, Body, Description, Name, Subject, Markup, HtmlValue, DeveloperName  
                                   FROM EmailTemplate 
                                   WHERE DeveloperName 
                                   LIKE 'AGN_ICL_DeleteNotificationTo%'])
        {
            eTMap.put(objCS.DeveloperName, objCS);
        } 
        Practitioner_Listing_AGN__c practitioner  = [SELECT Id, Email_AGN__c, Language_AGN__c,
                                                     Locator_Listing_AGN__r.User_Language_AGN__c, 
                                                     Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c,
                                                     Locator_Listing_AGN__r.First_Level_Clinic_Approver_AGN__c,
                                                     Locator_Listing_AGN__r.First_Level_Clinic_Approver_AGN__r.Email
                                                     FROM Practitioner_Listing_AGN__c WHERE Id =: PractObj.Id];
        
        PractitionerCountryCode = practitioner.Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c;
        PractitionerLangCode = practitioner.Locator_Listing_AGN__r.User_Language_AGN__c; 
          //Updated below lines as part of Cluster Logic for ICL Wave3 Project
        String CountryCode = AGN_ICL_UtlityClass.isCluster(PractitionerCountryCode);
        String HCPtemplateName = 'AGN_ICL_DeleteNotificationTo'+'HCP_'+CountryCode;
        String ICLAdmintemplateName = 'AGN_ICL_DeleteNotificationTo_ICL_Admin';
        Messaging.SingleEmailMessage mailToHCP = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage mailToICLAdmin = new Messaging.SingleEmailMessage();
        
        if ( owea.size() > 0 )
        { 
            mailToHCP.setOrgWideEmailAddressId(owea.get(0).Id);
            mailToICLAdmin.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        else
        {
            mailToHCP.setSenderDisplayName('Allergan Clinic Locator Portal'); 
            mailToICLAdmin.setSenderDisplayName('Allergan Clinic Locator Portal'); 
        }
        List<String> sendTo = new List<String>();
        sendTo.add(practitioner.Email_AGN__c);
        mailToHCP.setToAddresses(sendTo);        
        mailToHCP.setTargetObjectId(UserInfo.getUserId());
        mailToHCP.setWhatId(practitioner.Id);        
        mailToHCP.setTreatTargetObjectAsRecipient(false);        
        mailToHCP.setSaveAsActivity(false);        
        mailToHCP.setToAddresses(sendTo);        
        mailToHCP.setTemplateId(eTMap.get(HCPtemplateName).id);   
        mailToHCP.setCharset('UTF-8');
        mails.add(mailToHCP);
        ICL_Email_Status_Log_AGN__c emailLog1 = new ICL_Email_Status_Log_AGN__c();
        Messaging.SingleEmailMessage email1 = Messaging.renderStoredEmailTemplate(eTMap.get(HCPtemplateName).id, null,practitioner.Id);
        emailLog1.Subject_AGN__c = email1.Subject;
        emailLog1.From_AGN__c = fromEmailAddress;
        emailLog1.Body_AGN__c = email1.getHtmlBody();
        emailLog1.To_AGN__c =  AGN_ICL_SendEmailNotification.getStringValue(sendTo);
        logList.add(emailLog1);
        //--------------
        List<String> sendTo1 = new List<String>();
        sendTo1.add(practitioner.Locator_Listing_AGN__r.First_Level_Clinic_Approver_AGN__r.Email);
        mailToICLAdmin.setToAddresses(sendTo1);        
        mailToICLAdmin.setTargetObjectId(UserInfo.getUserId());
        mailToICLAdmin.setWhatId(practitioner.Id);        
        mailToICLAdmin.setTreatTargetObjectAsRecipient(false);        
        mailToICLAdmin.setSaveAsActivity(false);        
        mailToICLAdmin.setToAddresses(sendTo1);        
        mailToICLAdmin.setTemplateId(eTMap.get(ICLAdmintemplateName).id); 
        mails.add(mailToICLAdmin);
        ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(eTMap.get(ICLAdmintemplateName).id, null,practitioner.Id);
        emailLog.Subject_AGN__c =email.Subject;
        emailLog.From_AGN__c = fromEmailAddress;
        emailLog.Body_AGN__c = email.getHtmlBody();
        emailLog.Sent_On_AGN__c = datetime.now();
        emailLog.To_AGN__c =  AGN_ICL_SendEmailNotification.getStringValue(sendTo1);
        logList.add(emailLog);      
        
        //ICL_Email_Status_Log_AGN__c iclEmailLog = new ICL_Email_Status_Log_AGN__c();        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        
        if(results.size() > 0)
        {   
            integer i=0;
            for(Messaging.SendEmailResult result : results){         
                logList[i].Success_Error_Message_AGN__c = result.isSuccess() ? 'success' : JSON.serialize(result.errors);    
                i++;
            }   
            try{
                //------CheckMarx Phase2--Added on 18/11/2020----------               
                String objlog = 'ICL_Email_Status_Log_AGN__c';
                SObjectType objlogType = ((SObject)(Type.forName('Schema.'+objlog).newInstance())).getSObjectType();
                AGN_FLSCheck.check(logList,objlogType,'INSERT');
                //------CheckMarx Phase2--Ends here----------
                insert logList;  
            }
            catch(Exception e){

            }             
            
        }
        
    }
    
    public static void  sendDeleteNotificationToICLAdmin(){
        
    }
    
    @AuraEnabled
    public static List<PicklistWrapper> fetchPicklistValues1(String objectName, String field_apiName,Boolean nullRequired){
        List<String> optionlist = new List<String>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        List<PicklistWrapper> piclistval = new List<PicklistWrapper>();
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        if(nullRequired == true){
            // optionlist.add('--None--');
            optionlist.add('');
            //piclistval.add(new PicklistWrapper());
        }
        
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
            piclistval.add(new PicklistWrapper(pv));
        }
        return piclistval;
    } 
    
    @AuraEnabled
    public static List<AGN_ICL_UtlityClass.PicklistWrapper> fetchPicklistValues(String objectName, String field_apiName,Boolean nullRequired){
        List<String> optionlist = new List<String>();
        User u = [SELECT id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c  
                  FROM User 
                  WHERE id =:UserInfo.getUserId() 
                  LIMIT 1];
        
        if(nullRequired == true){
            // optionlist.add('--None--');
            optionlist.add('');
            //piclistval.add(new PicklistWrapper());
        }        
        return AGN_ICL_UtlityClass.getPicklistValues(objectName, field_apiName, u.Country_Code__c);
    } 
    
    @Testvisible
    private class PicklistWrapper {
        @AuraEnabled public String label           {get;private set;}
        @AuraEnabled public String value           {get;private set;}
        @AuraEnabled public Boolean isDefaultValue {get;private set;}
        
        public PicklistWrapper() {
            this.label          = '';
            this.value          = '';
            this.isDefaultValue = false;
        }
        
        public PicklistWrapper(Schema.PicklistEntry picklistEntry) {
            this.label          = picklistEntry.getLabel();
            this.value          = picklistEntry.getValue();
            this.isDefaultValue = picklistEntry.isDefaultValue();
        }
    }
    
    @AuraEnabled
    public static List<String> getPicklistValues(String SObjectAPIName,String FieldAPIName)
    {
        List<String> picklistval = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(SObjectAPIName).getDescribe().fields.getMap().get(FieldAPIName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            picklistval.add(f.getValue());
        } 
        return picklistval;
    }
    
    @AuraEnabled
    public static List<AGN_ICL_Layout_Field__mdt> getMetaDataFields(String CountryCode){
        Integer lmtr = Limits.getLimitQueryRows() - Limits.getQueryRows(); 
        List<AGN_ICL_Layout_Field__mdt> fields = [SELECT id,Field_for_AGN__c,
                                                  Field_API_Name_AGN__c,
                                                  Field_Sobject_API_Name_AGN__c,
                                                  Field_Label_AGN__c,Field_Sort_Order_AGN__c,
                                                  Field_Type_AGN__c,IsPicklist_AGN__c,
                                                  Required_AGN__c,Country_Code_AGN__c 
                                                  FROM AGN_ICL_Layout_Field__mdt LIMIT :lmtr];
        return fields;
    }
    
    @AuraEnabled
    public static List<String> getPractitionerType(){
        List<String> typeList = new List<String>();
        typeList.add('');
        String alltypes = System.Label.AGN_ICL_Practitioner_Type;
        String[] typearr = alltypes.split(';');
        for(String str : typearr)
        {
            typeList.add(str);
        }
        return typeList;
    }
    
    @AuraEnabled
    public static List<AGN_ICL_Layout_Field__mdt> getCountryWiseFieldList(){
        List<AGN_ICL_Layout_Field__mdt> fieldList = new List<AGN_ICL_Layout_Field__mdt>();
        String CountryCode = [Select id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c  from User where id =:UserInfo.getUserId()][0].Country_Code__c;
        //Added as a  part of ICL wave 3 development for cluster country logic
        CountryCode = AGN_ICL_UtlityClass.isCluster(CountryCode);
        //Ends
        if(CountryCode == 'AU')
        {
            CountryCode = 'AN';
        }
        fieldList = [Select id,Section_Header__c,Field_Regex_AGN__c,Field_for_AGN__c,Field_API_Name_AGN__c,Field_Sobject_API_Name_AGN__c,Field_Label_AGN__c,Field_Of_HCP_or_HCA_AGN__c,Field_Sort_Order_AGN__c,Field_Type_AGN__c,IsPicklist_AGN__c,Required_AGN__c,Country_Code_AGN__c from AGN_ICL_Layout_Field__mdt WHERE Field_Of_HCP_or_HCA_AGN__c = 'Practitioner' and Country_Code_AGN__c =:CountryCode order by Field_Sort_Order_AGN__c];
        return fieldList;
    }
    
    
    //Added as a part of Canada change for Two Column Layout
    @AuraEnabled
    public static Boolean isTwoLayerLayout(String countryCode)
    {   
        
        Boolean twolayerlayout = AGN_ICL_UtlityClass.isTwoLayerLayout(countryCode);
        return twolayerlayout;
        
    }
    //END
     // Duallist Box Logic added for Brand 
       @AuraEnabled
       public static String getMultipicklistBrandCount(){
       return AGN_ICL_UtlityClass.getMultipicklistBrand();
       }
     // Duallist Box Logic added for Brand
    
    @AuraEnabled
    public static String image(Id parentId,String fileName1,String contentType,String base64Data)
    {
        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        String fetchimage;
        //String attachmentBody = EncodingUtil.base64Encode(attach[0].Body);
        String attachmentBody = EncodingUtil.base64Encode(EncodingUtil.base64Decode(base64Data));
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        
        List<AWS_Login_AGN__c> al= AWS_Login_AGN__c.getall().values();
        
        String key = al[0].key_AGN__c; //AWS key
        String secret = al[0].secret_AGN__c; //AWS Secret key
        String bucketname = al[0].bucket_AGN__c; //AWS bucket name
        String host = al[0].host_AGN__c;
        String method = 'PUT';
        //String filename = attach[0].ParentId + '-' + attach[0].Name;
        
        String filename = parentId + '-' + fileName1;
        
        
        HttpRequest req = new HttpRequest();
        
        req.setMethod(method);
        req.setEndpoint('https://' + bucketname + '.' + host + '/' + filename);
        req.setHeader('Host', bucketname + '.' + host);
        req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
        req.setHeader('Content-Encoding', 'UTF-8');
        // req.setHeader('Content-type', attach[0].ContentType);
        req.setHeader('Content-type', contentType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('ACL', 'public-read-write');
        // req.setBodyAsBlob(attach[0].Body);
        req.setBodyAsBlob(EncodingUtil.base64Decode(base64Data));
        //String stringToSign = 'PUT\n\n' + attach[0].ContentType + '\n' + formattedDateString + '\n' + '/' + bucketname + '/' + filename;
        
        String stringToSign = 'PUT\n\n' + contentType + '\n' + formattedDateString + '\n' + '/' + bucketname + '/' + filename;
        
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signedKey  = EncodingUtil.base64Encode(mac);
        
        String authHeader = 'AWS' + ' ' + key + ':' + signedKey ;
        
        
        req.setHeader('Authorization',authHeader);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if(filename!=null && res.getStatusCode()==200)
        {
            Practitioner_Listing_AGN__c ac=[select id,Practitioner_Image_AGN__c,Practitioner_Image_Available_AGN__c from Practitioner_Listing_AGN__c where id=:parentId];
            
            ac.Practitioner_Image_AGN__c='https://s3-eu-west-1.amazonaws.com/allergan-icl/'+filename;
            //ac.Practitioner_Image_AGN__c='https://' + host +'/' + bucketname +'/' + filename;
            ac.Practitioner_Image_Available_AGN__c=true;
            try{
                	List<Practitioner_Listing_AGN__c> practup = new List<Practitioner_Listing_AGN__c>();
           			practup.add(ac); 
                    String objPac = 'Practitioner_Listing_AGN__c';
                    SObjectType pacObjType = ((SObject)(Type.forName('Schema.'+objPac).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(practup,pacObjType,'UPDATE');
                    update practup;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Practitioner update:'+ex);
			}
           
          //  update ac;
            
            fetchimage = ac.Practitioner_Image_AGN__c;
            
            
        }
        if(filename==null)
        {
            fetchimage=null;
        }
        return fetchimage;
    }
    
    @InvocableMethod(label='SentConsentCaptureMail')
    public static void SentConsentCaptureMailHCP(List<Practitioner_Listing_AGN__c>  prList) {
          
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String fromEmailAddress = (String)portalSetting.From_Email_Address_AGN__c;
        list<ICL_Email_Status_Log_AGN__c> logList = new list<ICL_Email_Status_Log_AGN__c>();
        Map<String, EmailTemplate> eTMap = new Map<String, EmailTemplate>(); 
        String PractitionerCountryCode,templateName;
        
        try{
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: fromEmailAddress LIMIT 1];   
            for(EmailTemplate objCS : [SELECT Id, Body, Description, Name, Subject, Markup, HtmlValue, DeveloperName  
                                       FROM EmailTemplate 
                                       WHERE  DeveloperName Like 'AGN_ICL_AddPractitioner_Consent_%'])
            {
                eTMap.put(objCS.DeveloperName, objCS);
            }
            map<id,Practitioner_Listing_AGN__c>  pracMap = new map<id,Practitioner_Listing_AGN__c>();
            for(Practitioner_Listing_AGN__c PrcObj:prList){
                pracMap.put(PrcObj.id,PrcObj);
            }
            map<id,String>  pracCntryMap = new map<id,String>();
            for(Practitioner_Listing_AGN__c temp: [SELECT id,Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c 
                                                   FROM Practitioner_Listing_AGN__c
                                                   WHERE ID IN:pracMap.keySet()])
            {
                pracCntryMap.put(temp.id,temp.Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c);                
            }
            for(Practitioner_Listing_AGN__c PrcObj:prList){ 
                
                PractitionerCountryCode = pracCntryMap.get(PrcObj.id); 
                 //Added as a part of cluster logic for ICL wave3 Project
                String CountryCode = AGN_ICL_UtlityClass.isCluster(PractitionerCountryCode);
                templateName = 'AGN_ICL_AddPractitioner_Consent_'+CountryCode;
                if(eTMap.containsKey(templateName)){
                    Messaging.SingleEmailMessage mailToHCP = new Messaging.SingleEmailMessage();                   
                    List<String> sendTo = new List<String>();
                    sendTo.add(PrcObj.Email_AGN__c);
                    mailToHCP.setOrgWideEmailAddressId(owea.Id);
                    mailToHCP.setToAddresses(sendTo);
                    mailToHCP.setTargetObjectId(UserInfo.getUserId());
                    mailToHCP.setWhatId(PrcObj.Id);        
                    mailToHCP.setTreatTargetObjectAsRecipient(false);        
                    mailToHCP.setSaveAsActivity(false);
                    mailToHCP.setCharset('UTF-8');
                    mailToHCP.setTemplateId(eTMap.get(templateName).id);          
                    mails.add(mailToHCP);                    
                    ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(eTMap.get(templateName).id, null, PrcObj.id);
                    emailLog.Subject_AGN__c =email.Subject;
                    emailLog.From_AGN__c = fromEmailAddress;          
                    emailLog.Body_AGN__c = email.getHtmlBody();
                    emailLog.Sent_On_AGN__c = datetime.now();
                    emailLog.To_AGN__c = AGN_ICL_SendEmailNotification.getStringValue(sendTo);
                    logList.add(emailLog);
                }
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);            
            if(results.size() > 0){    
                integer i=0;
                for(Messaging.SendEmailResult result : results){          
                    logList[i].Success_Error_Message_AGN__c = result.isSuccess() ? 'success' : JSON.serialize(result.errors);    
                    i++;
                }   
                if(logList.size()>0){
                    
                    //------CheckMarx Phase2--Added on 18/11/2020----------
                    String objlog = 'ICL_Email_Status_Log_AGN__c';
                    SObjectType objlogType = ((SObject)(Type.forName('Schema.'+objlog).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(logList,objlogType,'UPSERT');
                    //------CheckMarx Phase2--Ends here----------
                    upsert logList;  
                    
                }                    
            }            
            
        }
        catch(exception ex){

        }
        
    }
    
    
}