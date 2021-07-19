global without sharing class AGN_OAMFlowUtils {
    
    
    /********/
    global static void replicateExistingAccount(String accSAPId, String caseSFDCId){
        
        
        Map<string, string> AccountToCROFieldMap = new Map<string, string>();
        Map<string, string> AddressToCRAFieldMap = new Map<string, string>();
        Map<string, string> BizAccountToCRAFieldMap = new Map<string, string>();
        Set<string> CroFieldsToBooleanify = new Set<string>();
        Set<string> CraFieldsToBooleanify = new Set<string>();
        AGN_CRO_ProcessUtils.fetchFieldMappings();
         
        //AccountToCROFieldMap = AGN_CRO_ProcessUtils.CroToAccountFieldMap ; 
        //AddressToCRAFieldMap = AGN_CRO_ProcessUtils.CraToAddressFieldMap ;
        //BizAccountToCRAFieldMap = AGN_CRO_ProcessUtils.CraToBizAccountFieldMap ; 
        //this.CroFieldsToBooleanify = AGN_CRO_ProcessUtils.CroFieldsToBooleanify ;
        //this.CraFieldsToBooleanify = AGN_CRO_ProcessUtils.CraFieldsToBooleanify ;
        
        String selectedObjectCR = 'Allergan_Customer_Registration_AGN__c';
        String selectedObjectCRA = 'Allergan_Customer_Address_AGN__c';
        String selectedObjectAcc = 'Account';
        
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        
        Schema.Describesobjectresult dsrCR = gdMap.get(selectedObjectCR).getDescribe();
        Map<String, Schema.SObjectField> fieldMapCR = dsrCR.fields.getMap();
        
        Schema.Describesobjectresult dsrCRA = gdMap.get(selectedObjectCRA).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dsrCRA.fields.getMap();
        
        Schema.Describesobjectresult dsrAcc = gdMap.get(selectedObjectAcc).getDescribe();
        Map<String, Schema.SObjectField> fieldMapAcc = dsrAcc.fields.getMap();

        /*
        for(String craObjectField : AGN_CRO_ProcessUtils.CraToAddressFieldMap.keySet() ){
            AddressToCRAFieldMap.put(CraToAddressFieldMap.get(craObjectField),craObjectField) ; 
        }
        */
        
            
        /*** Fetching Biz Account Start ****/
        
        String strSOQLBizAccFull = '' ;
        String strSOQLBizAccSelectSection = 'SELECT ' ; 
        String strSOQLBizAccRestSection = ' FROM ACCOUNT ' ; 
        
        for(String bizObjectField : AGN_CRO_ProcessUtils.CraToBizAccountFieldMap.keySet() ){
            BizAccountToCRAFieldMap.put(AGN_CRO_ProcessUtils.CraToBizAccountFieldMap.get(bizObjectField),bizObjectField) ;  
            strSOQLBizAccSelectSection = strSOQLBizAccSelectSection + AGN_CRO_ProcessUtils.CraToBizAccountFieldMap.get(bizObjectField) + ', ' ;
        }
        
        strSOQLBizAccSelectSection = strSOQLBizAccSelectSection + 'Id ' ; 
        strSOQLBizAccRestSection = ' FROM ACCOUNT WHERE External_ID2_AGN__c = \''+ String.escapeSingleQuotes(accSAPId)+'\' LIMIT 1';  
        strSOQLBizAccFull = strSOQLBizAccSelectSection + strSOQLBizAccRestSection ; 
        
        List<Account> bizAccs = Database.query(strSOQLBizAccFull) ;

        Allergan_Customer_Address_AGN__c newCRAddressRecord = new Allergan_Customer_Address_AGN__c() ; 
        
        /*** Data Binding For Biz Account Start ****/
        System.debug('bizAccs----'+bizAccs[0]) ; 
        for(Account myacc : bizAccs) {
            System.debug('BizAccountToCRAFieldMap.keySet()----'+BizAccountToCRAFieldMap.keySet()) ;
            for(String accField : BizAccountToCRAFieldMap.keySet()){
                
                Schema.SObjectField s = fieldMapAcc.get(accField) ; 
                System.debug('s-----'+s) ; 
                System.debug('-----'+fieldMapCR.get(BizAccountToCRAFieldMap.get(accField))) ; 
                 System.debug('-----'+myacc.get(s))  ;  
                //newCRAddressRecord.(fieldMapCR.get(BizAccountToCRAFieldMap.get(accField))) = myacc.(fieldMapAcc.get(accField)) ; 
                 if(fieldMapCR.get(BizAccountToCRAFieldMap.get(accField)) != NULL && myacc.get(s)!=NULL)  
                    newCRAddressRecord.put(fieldMapCR.get(BizAccountToCRAFieldMap.get(accField)),myacc.get(s)) ; 
               
                 
            }
             
            
        }       
        /*** Fetching Biz Account End ****/
        
        /*** Fetching Person Account Start ****/
        
        String strSOQLPerAccFull = '' ;
        String strSOQLPersonAccSelectSection = 'SELECT ' ; 
        String strSOQLPersonAccRestSection = ' FROM ACCOUNT ' ; 
        
        for(String crObjectField : AGN_CRO_ProcessUtils.CroToAccountFieldMap.keySet() ){
            AccountToCROFieldMap.put(AGN_CRO_ProcessUtils.CroToAccountFieldMap.get(crObjectField),crObjectField) ; 
            strSOQLPersonAccSelectSection = strSOQLPersonAccSelectSection + AGN_CRO_ProcessUtils.CroToAccountFieldMap.get(crObjectField) + ', ' ; 
        }
        
        strSOQLPersonAccSelectSection = strSOQLPersonAccSelectSection + 'Id ' ; 
        strSOQLPersonAccRestSection = ' FROM ACCOUNT WHERE Primary_Parent_vod__c = \''+ bizAccs[0].Id+'\' LIMIT 1';  
        strSOQLPerAccFull = strSOQLPersonAccSelectSection + strSOQLPersonAccRestSection ; 
        System.debug('Krishanu Testing = '+strSOQLPerAccFull) ; 
        List<Account> personAccs = Database.query(strSOQLPerAccFull) ; 
        Allergan_Customer_Registration_AGN__c newAgnCRRecord = new Allergan_Customer_Registration_AGN__c() ;
        
        for(Account myacc : personAccs) {
            
            for(String accField : AccountToCROFieldMap.keySet()){
                
                Schema.SObjectField s = fieldMapAcc.get(accField) ; 
                //newAgnCRRecord.(fieldMapCR.get(AccountToCROFieldMap.get(accField))) = myacc.(fieldMapAcc.get(accField)) ; 
                if(fieldMapCR.get(AccountToCROFieldMap.get(accField)) != NULL && myacc.get(s)!=NULL){  
                    
                    if(AGN_CRO_ProcessUtils.CroFieldsToBooleanify.contains(AccountToCROFieldMap.get(accField)))
                    {
                        System.debug('Boolean Test==='+myacc.get(s)) ;  
                        if(myacc.get(s)=='true') newAgnCRRecord.put(fieldMapCR.get(AccountToCROFieldMap.get(accField)),'Yes') ;
                        else newAgnCRRecord.put(fieldMapCR.get(AccountToCROFieldMap.get(accField)),'No') ;
                    }
                    else {
                        newAgnCRRecord.put(fieldMapCR.get(AccountToCROFieldMap.get(accField)),myacc.get(s)) ; 
                    }   
                }    
            }
            newAgnCRRecord.Account_AGN__c = myacc.Id ; 
            
        }   
        

       try{
           newAgnCRRecord.Case_AGN__c = caseSFDCId ; 
           //------CheckMarx--Added on 24/07/2020----------      
           List<Allergan_Customer_Registration_AGN__c> tempCrList = new List<Allergan_Customer_Registration_AGN__c>();
           tempCrList.add(newAgnCRRecord);
          /* SObjectAccessDecision decisionOnCr = Security.stripInaccessible(AccessType.CREATABLE,tempCrList);
           if(decisionOnCr.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
               throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_OAMFlowUtils and Method Name: replicateExistingAccount]');
           }
           else{
                insert newAgnCRRecord ; 
           }*/
           String objCrRe = 'Allergan_Customer_Registration_AGN__c';
           SObjectType objCrReType = ((SObject)(Type.forName('Schema.'+objCrRe).newInstance())).getSObjectType();
           AGN_FLSCheck.check(tempCrList,objCrReType,'INSERT');
           insert newAgnCRRecord ; 
           //--------------------
         
       //insert newCRAddressRecord
       }
        catch(Exception ex){
            System.debug('#######ERROR on Insert######') ;  
        }
        
    }
    /********/
    
    @InvocableMethod
    global static list<crChangeComparatorOutput> generateCustomerAddresChangeList(List<crChangeComparatorInput> comparatorAttributesList ){
        system.debug('inside change list generator');
        crChangeComparatorInput crComp = comparatorAttributesList[0];
        string changeList= '';
        
        if (!string.isEmpty(crComp.parentCrId))
           changeList= [SELECT Change_List_AGN__c FROM Allergan_Customer_Registration_AGN__c WHERE Id=:crComp.parentCrId LIMIT 1][0].Change_List_AGN__c;
        if (changelist== Null)
            changelist='';
        List<CR_Changlist_Setting_AGN__mdt> changeListSettings =New List<CR_Changlist_Setting_AGN__mdt>([SELECT Field_Details__c,Object_API_Name__c FROM CR_Changlist_Setting_AGN__mdt]);
        
        for(CR_Changlist_Setting_AGN__mdt cListSetting : changeListSettings){
            
            //Change in Personal Details
            if(cListSetting.Object_API_Name__c=='Allergan_Customer_Registration_AGN__c' && crComp.newCustReg!= Null && crComp.oldCustReg!=NULL ){                
                List<String> crFieldInfoList = cListSetting.Field_Details__c.split(',');        
                for(String crFieldInfo : crFieldInfoList) {
                    String[] crField = crFieldInfo.split('=');
                    if(((String.valueOf(crComp.newCustReg.get(crField[1].trim()))) != String.valueOf(crComp.oldCustReg.get(crField[1].trim()))) && !(string.isEmpty(String.valueOf(crComp.newCustReg.get(crField[1].trim())))   && string.isEmpty(String.valueOf(crComp.oldCustReg.get(crField[1].trim())))))
                           changeList += '<b>\u25AA</b>&ensp Set <b>"'+crField[0].trim()+'"</b> from "' + crComp.oldCustReg.get(crField[1].trim()) + '" to "' + crComp.newCustReg.get(crField[1].trim()) + '"<br>';
                }
                
            }
            //Change in Address Details 
            if(cListSetting.Object_API_Name__c=='Allergan_Customer_Address_AGN__c' && crComp.newAddress!= Null && crComp.oldAddress!=NULL){
                changeList += '<br>Address <b>'+crComp.oldAddress.Company_Name_AGN__c +'</b> has been amended with below changes : <br>';
                List<String> craFieldInfoList = cListSetting.Field_Details__c.split(',');        
                for(String craFieldInfo : craFieldInfoList) {
                    String[] craField = craFieldInfo.split('=');
                    if((( String.valueOf(crComp.newAddress.get(craField[1].trim()))) != String.valueOf(crComp.oldAddress.get(craField[1].trim()))) && !(string.isEmpty(String.valueOf(crComp.newAddress.get(craField[1].trim())))   && string.isEmpty(String.valueOf(crComp.oldAddress.get(craField[1].trim())))))
                        changeList += '&emsp<b>\u25AA</b>&ensp Set <b>"'+craField[0].trim()+'"</b> from "' + crComp.oldAddress.get(craField[1]) + '" to "' + crComp.newAddress.get(craField[1].trim().trim()) + '"<br>';
                }
            }
        }
        
        system.debug('changeList' + changeList);    
        //if(changeList != '')
            //changeList = 'Update ' + crComp.oldAddress.Company_Name_AGN__c + ' (' + crComp.newAddress.SAP_ID_AGN__c + ') with the following changes:' + '<br><br>' + changeList + '<br>';
            //changeList =  '<br>Address <b>'+crComp.oldAddress.Company_Name_AGN__c +'</b> has been updated with below changes : <br>' + changeList + '<br>';
            list<crChangeComparatorOutput> outputList= new list<crChangeComparatorOutput>();
            crChangeComparatorOutput output = new crChangeComparatorOutput();
            output.changeList=changeList;
            outputList.add(output);
        return outputList;
    }
    
    @AuraEnabled
    public static DocumentDetails getAllAttachments(Id parentRecId,String documentList){
            
        set<string> documentDescSet= new set<string>();
        list<Attachment>listOfSavedAttachments = new list<Attachment>();
        list<AttachmentWrapper> newAttachments = new list<AttachmentWrapper>();
        DocumentDetails attWithDetails = new DocumentDetails();
        Allergan_Customer_Registration_AGN__c parentRecordDetails = getCustomerRegistrationDetails(parentRecId);
        string webSites= String.isEmpty(documentList)? getDocumentList(parentRecordDetails).Official_website_AGN__c : '';
        documentList = String.isEmpty(documentList)?getDocumentList(parentRecordDetails).Documents_Required_AGN__c:documentList;
       // documentList = getDocumentList(parentRecordDetails).Documents_Required_AGN__c;
        
        
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
            }
        }
        system.debug('==newAttachments=='+ newAttachments);
        attWithDetails.AttachmentWrapperList= newAttachments;
       // attWithDetails.missingAttachment
         system.debug('==attWithDetails=='+ attWithDetails);        
        return attWithDetails;
        
    }
    
    @AuraEnabled
    public static void saveFile(String attachmentId, Id parentId, String fileName, String base64Data, String contentType, String description) {
        system.debug('== [FileUploadMethod].[saveTheFile] =='+attachmentId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        List<Attachment> attachmentList = new List<Attachment>();
        Allergan_Customer_Registration_AGN__c acr = new Allergan_Customer_Registration_AGN__c();
        acr = [SELECT Id FROM Allergan_Customer_Registration_AGN__c WHERE Id=:parentId LIMIT 1];
        
        
        Attachment attachmentFile = new Attachment(); 
        
        if ((!String.isEmpty(attachmentId)) && attachmentId.trim() != 'undefined'){
            attachmentFile.Id = attachmentId;
        } 
        else{
        //attachmentFile.Id =  String.isEmpty(attachmentId)? null : attachmentId;
        attachmentFile.ParentId = acr.Id;
        }
        attachmentFile.Body = EncodingUtil.base64Decode(base64Data);
        attachmentFile.Name = fileName;
        attachmentFile.ContentType = contentType;
        attachmentFile.Description = description.trim();

        system.debug('•attachmentFile•'+attachmentFile);
        
         //------CheckMarx--Added on 24/07/2020----------  
        List<Attachment> tmpAttList = new List<Attachment>();        
        tmpAttList.add(attachmentFile);
        /*SObjectAccessDecision decisionOnAtt = Security.stripInaccessible(AccessType.UPSERTABLE,tmpAttList);
        if(decisionOnAtt.getRemovedFields().get('Attachment')!=null){
            throw new AGN_CommonException('Error: Insufficient Create/Edit Access On Attachment [Class Name: AGN_OAMFlowUtils and Method Name: saveFile]');
        }
        else{
           upsert attachmentFile;
        }*/
        String objCrAtt = 'Attachment';
        SObjectType ACRAttObjType = ((SObject)(Type.forName('Schema.'+objCrAtt).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tmpAttList,ACRAttObjType,'UPSERT');
        upsert attachmentFile;
        //-------------------- 
      

        //return attachmentFile.Id;
    }
    @AuraEnabled
    public static string saveTestFile(){
        system.debug('•Inside Dummy Method•');
        Case c=new Case();
        //------CheckMarx--Updated on 25/07/2020----------  
        if(Schema.sObjectType.Case.fields.CaseNumber.isAccessible()){
            c=[select CaseNumber, Id from Case limit 1];
            return c.CaseNumber;
        }
        else{
            throw new AGN_CommonException('Error: Insufficient Access permission on Case [Class Name: AGN_OAMDocumentUploaderStep3Utils and Method Name: saveTestFile]');
        }
        //----------------------------------------------

    }
    
    // added by abdul flow upload
       @AuraEnabled
    public static Id saveChunk(String fileId,String attachmentId, Id parentId, String fileName, String base64Data, String contentType, String description) {
     
       
        if (fileId == '') {
            fileId = saveTheFile(attachmentId, parentId, fileName,base64Data, contentType,description);
            system.debug('== fileId In If=='+fileId);
            
        } else {
            system.debug('== fileId In Else =='+fileId);
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
    
    
    
    //@AuraEnabled
    public static Id saveTheFile(String attachmentId, Id parentId, String fileName, String base64Data, String contentType, String description) {
        system.debug('@@attachmentId@@ '+attachmentId);
         system.debug('== parentId =='+parentId);
         system.debug('== fileName =='+fileName);
         system.debug('== description =='+description);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
      system.debug('== base64Data =='+base64Data);
        List<Attachment> attachmentList = new List<Attachment>();
        Allergan_Customer_Registration_AGN__c acr = new Allergan_Customer_Registration_AGN__c();
        acr = [SELECT Id FROM Allergan_Customer_Registration_AGN__c WHERE Id=:parentId LIMIT 1];
        
         system.debug('== Id =='+acr.Id);
        Attachment attachmentFile = new Attachment(); 
        
        if ((!String.isEmpty(attachmentId)) && attachmentId.trim() != 'undefined'){
            attachmentFile.Id = attachmentId;
        } 
        else{
        //attachmentFile.Id =  String.isEmpty(attachmentId)? null : attachmentId;
        attachmentFile.ParentId = acr.Id;
            
        }
        
        attachmentFile.Body = EncodingUtil.base64Decode(base64Data);
        attachmentFile.Name = fileName;
        attachmentFile.ContentType = contentType;
        attachmentFile.Description = description.trim();

        system.debug('•attachmentFile•'+attachmentFile);
        
        //------CheckMarx--Added on 24/07/2020----------  
        List<Attachment> tmpattList = new List<Attachment>();        
        tmpattList.add(attachmentFile);
        /*SObjectAccessDecision decisionOnAtt = Security.stripInaccessible(AccessType.UPSERTABLE,tmpattList);
        if(decisionOnAtt.getRemovedFields().get('Attachment')!=null){
            throw new AGN_CommonException('Error: Insufficient Create/Edit Access On Attachment [Class Name: AGN_OAMFlowUtils and Method Name: saveTheFile]');
        }
        else{
            upsert attachmentFile;
            return attachmentFile.Id;
        }*/
        String objCrAtt = 'Attachment';
        SObjectType ACRAttObjType = ((SObject)(Type.forName('Schema.'+objCrAtt).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tmpattList,ACRAttObjType,'UPSERT');
        upsert attachmentFile;
        return attachmentFile.Id;
        //--------------------  
       
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        
        system.debug('== appendToFile fileId =='+fileId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        //------CheckMarx--Updated on 25/07/2020----------   
        if(Schema.sObjectType.Attachment.fields.Body.isUpdateable()){
             update a;
        }
        else{
            throw new AGN_CommonException('Error: Insufficient Edit Access On Attachment [Class Name: AGN_OAMFlowUtils and Method Name: appendToFile]');
        }  
        //----------------------------------------------
 
       
    }
    
   // end of flow doc upload
        
    
    public static Allergan_Customer_Registration_AGN__c getCustomerRegistrationDetails (Id crId ){
        Allergan_Customer_Registration_AGN__c crRecord = new Allergan_Customer_Registration_AGN__c();
        crRecord= [SELECT Customer_Group_AGN__c,
                          Customer_Category_AGN__c,
                          Customer_Sub_Category_AGN__c,
                          SAP_Country_Code_AGN__c,
                          Country_Code_AGN__c,
                          Country_AGN__c
                   FROM Allergan_Customer_Registration_AGN__c
                   WHERE Id =: crId LIMIT 1][0];
        System.debug('crRecord --'+crRecord);
        return crRecord;
        
    }
    
    @AuraEnabled
    public static Customer_Type_Configuration_AGN__c getDocumentList ( Allergan_Customer_Registration_AGN__c  custRegRecord){
        Customer_Type_Configuration_AGN__c ctcRec = new Customer_Type_Configuration_AGN__c();
        
        system.debug('==custRegRecord=='+ custRegRecord.Customer_Group_AGN__c+ '-'+custRegRecord.SAP_Country_Code_AGN__c+ '-'+custRegRecord.Customer_Category_AGN__c + '-'+custRegRecord.Customer_Sub_Category_AGN__c );
        ctcRec= [SELECT Official_website_AGN__c ,
                        Documents_Required_AGN__c,
                        Country_Code_AGN__c,
                        Customer_Country_AGN__r.Alpha_2_Code_vod__c
                   FROM Customer_Type_Configuration_AGN__c
                   WHERE Customer_Group_AGN__c =: custRegRecord.Customer_Group_AGN__c  AND 
                         Customer_Country_AGN__r.Alpha_2_Code_vod__c =:custRegRecord.SAP_Country_Code_AGN__c AND
                         Category_AGN__c =:custRegRecord.Customer_Category_AGN__c AND
                         Sub_Category__c =:custRegRecord.Customer_Sub_Category_AGN__c 
                   LIMIT 1][0];
        system.debug('==ctcRec=='+ ctcRec);
        return ctcRec;        
    } 
    
    global class crChangeComparatorInput {
        @InvocableVariable
        global Allergan_Customer_Address_AGN__c newAddress;       
    
        @InvocableVariable
        global Allergan_Customer_Address_AGN__c oldAddress;
        
        @InvocableVariable
        global string parentCrId;   
        
        @InvocableVariable
        global Allergan_Customer_Registration_AGN__c newCustReg;
    
        @InvocableVariable
        global Allergan_Customer_Registration_AGN__c oldCustReg; 

    }
    
    global class crChangeComparatorOutput {
        @InvocableVariable
        global string changeList;       
     }

    
    public class AttachmentWrapper{
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public boolean isRequired {get;set;}
        @AuraEnabled
        public Attachment file {get;set;}
        @AuraEnabled
        public string inputFileHtmlId {get;set;}
        
        public AttachmentWrapper(string newLabel, Attachment newAttachment){
            this.label = newLabel;
            this.isRequired = false;
            this.file = newAttachment;
            this.file.Description = newLabel.trim();
            this.inputFileHtmlId = newLabel.deleteWhitespace();
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
}