global without sharing class AGN_OAMDocumentUploaderShipto_CA {
    
    public static List<Allergan_Customer_Address_AGN__c> getCustomerAddressDetails(Id ParentId) {
        system.debug('ParentId>>>>>>'+ParentId);
        
        List<Allergan_Customer_Address_AGN__c> custAdd = [SELECT Id,                                 
                                                          Parent_AGN__c,
                                                          State_AGN__c,
                                                          State_License_Number_AGN__c,
                                                          Ship_To_AGN__c,
                                                          Sold_To_AGN__c,
                                                          Doctors_Email_AGN__c,
                                                          Customer_Group_AGN__c
                                                          FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =: ParentId 
                                                          AND Ship_To_AGN__c = true
                                                          AND State_License_Number_AGN__c != null];
        
        system.debug('ADDLIST>>>>>>'+custAdd );
        return custAdd;
    }      
    
    @AuraEnabled
    public static DocumentDetails getShipToAttachments(Id parentRecId){
        
        set<string> documentDescSet= new set<string>();
        list<Attachment>listOfSavedAttachments = new list<Attachment>();
        list<AttachmentWrapper> newAttachments = new list<AttachmentWrapper>();
        DocumentDetails attWithDetails = new DocumentDetails();
        Allergan_Customer_Registration_AGN__c parentRecordDetails = [SELECT ID,Province_AGN__c,Customer_Group_AGN__c FROM Allergan_Customer_Registration_AGN__c WHERE Id =: parentRecId LIMIT 1][0];
        
        //Allergan_Customer_Address_AGN__c = [SELECT Id, Sold_To_AGN__c FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =: ParentId AND Sold_To_AGN__c = true];
        /*
                newAttachments.add(new AttachmentWrapper(Label.AGN_OAM_Account_Owner_SigDoc, new Attachment(Description ='This attachement Reference to Sold To Account.'), true));
                documentDescSet.add(Label.AGN_OAM_Account_Owner_SigDoc);
        
         */
        
        List<Allergan_Customer_Address_AGN__c> addList = getCustomerAddressDetails(parentRecId); 
        
        if(addList.size()>0){
            set<String> duplicateRec = new set<String>();
            for(Integer i=0; i<addList.size(); i++){ 
                if(duplicateRec.contains(addList[i].State_License_Number_AGN__c)){
                    string s = addList[i].State_License_Number_AGN__c +'_'+ i;
                    addList[i].State_License_Number_AGN__c = s;        
                }
                duplicateRec.add(addList[i].State_License_Number_AGN__c);
                
                newAttachments.add(new AttachmentWrapper(Label.AGN_OAM_Additional_Document_for_Licence +' ( '+addList[i].State_License_Number_AGN__c +' )', new Attachment(Description ='This attachement Reference to ShipTo Sate Licence Number.'), true));
                documentDescSet.add(Label.AGN_OAM_Additional_Document_for_Licence+' ( '+addList[i].State_License_Number_AGN__c +' )');
                if(Label.AGN_OAM_ShipTo_Document_CG.contains(parentRecordDetails.Customer_Group_AGN__c)){
                    newAttachments.add(new AttachmentWrapper(Label.AGN_OAM_ShipTo_License_Doc_Pharmacy +' ( '+addList[i].State_License_Number_AGN__c +' )', new Attachment(Description ='This attachement Reference to ShipTo Sate Licence Number.'), true));
                    documentDescSet.add(Label.AGN_OAM_ShipTo_License_Doc_Pharmacy +'( '+addList[i].State_License_Number_AGN__c +' )');
                }else{
                    newAttachments.add(new AttachmentWrapper(Label.AGN_OAM_ShipTo_License_Doc +' ( '+addList[i].State_License_Number_AGN__c +' )', new Attachment(Description ='This attachement Reference to ShipTo Sate Licence Number.'), true));
                    documentDescSet.add(Label.AGN_OAM_ShipTo_License_Doc +'( '+addList[i].State_License_Number_AGN__c +' )');
                }
                
                if(addList[i].State_AGN__c.containsIgnoreCase('BC') && (addList[i].Customer_Group_AGN__c.containsIgnoreCase('DN')|| addList[i].Customer_Group_AGN__c.containsIgnoreCase('OM'))){
                    
                    newAttachments.add(new AttachmentWrapper(Label.AGN_OAM_BCDentest_Doc+'( '+addList[i].State_License_Number_AGN__c +' )', new Attachment(Description ='This attachement Reference to British Columbia Dentist Botox Training Certificate.'), true));
                    documentDescSet.add(Label.AGN_OAM_BCDentest_Doc+'( '+addList[i].State_License_Number_AGN__c +' )' );
                    
                }else if(addList[i].State_AGN__c.containsIgnoreCase('AB')){            
                    If(addList[i].Customer_Group_AGN__c.containsIgnoreCase('OM')){
                        newAttachments.add(new AttachmentWrapper(Label.AGN_OAM_ABDentalAssociation_Certificate+'( '+addList[i].State_License_Number_AGN__c +' )', new Attachment(Description ='This attachement Reference to Alberta Dental Association'), true));
                        documentDescSet.add(Label.AGN_OAM_ABDentalAssociation_Certificate+'( '+addList[i].State_License_Number_AGN__c +' )' );
                    }else if(addList[i].Customer_Group_AGN__c.containsIgnoreCase('DN')){
                        newAttachments.add(new AttachmentWrapper(Label.AGN_OAM_ABDentalAssociation_Certificate+'( '+addList[i].State_License_Number_AGN__c +' )' , new Attachment(Description ='This attachement Reference to Alberta Dental Association'), true));
                        documentDescSet.add(Label.AGN_OAM_ABDentalAssociation_Certificate+'( '+addList[i].State_License_Number_AGN__c +' )' );
                        newAttachments.add(new AttachmentWrapper(Label.AGN_OAM_ABDentest_College_lvl_Certificate+'( '+addList[i].State_License_Number_AGN__c +' )', new Attachment(Description ='This attachement Reference to Alberta dentists College Level 2 certificate...'), true));
                        documentDescSet.add(Label.AGN_OAM_ABDentest_College_lvl_Certificate+'( '+addList[i].State_License_Number_AGN__c +' )'); 
                    }            
                }                
                
            }
        }        
        
        
        for (AttachmentWrapper aw:newAttachments ){
            String communityBaseURL = AGN_OAMConstant.COMMUNITY_BASE_URL+AGN_OAMConstant.COMMUNITY_SUFFIX;
            /* if(aw.label.contains(Label.AGN_OAM_Account_Owner_SigDoc)){
                Id docId = getDocument(aw.label,'');                        
                aw.downloadLink = communityBaseURL+'/servlet/servlet.FileDownload?file='+docId;   
                aw.isDownload= true;
                if(string.isEmpty(aw.file.Id)){
                    attWithDetails.missingAttachment= true;
                }
            }else */
            if(aw.label.contains(Label.AGN_OAM_ShipTo_License_Doc)){               
                Id docId = getDocument('',aw.label);                        
                aw.downloadLink = communityBaseURL+'/servlet/servlet.FileDownload?file='+docId;   
                aw.isDownload= true;
                if(string.isEmpty(aw.file.Id)){
                    attWithDetails.missingAttachment= true;
                }
            }                
           else if(aw.label.contains(Label.AGN_OAM_ShipTo_License_Doc_Pharmacy)){
                Id docId = getDocument(aw.label,'');                        
                aw.downloadLink = communityBaseURL+'/servlet/servlet.FileDownload?file='+docId;   /* Ex: https://gcspeudev-allergancommunityeu.cs84.force.com/customerIT/servlet/servlet.FileDownload?file=   */
                aw.isDownload= true;
                if(string.isEmpty(aw.file.Id)){
                    attWithDetails.missingAttachment= true;
                }
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
            } 
        }
        system.debug('==newAttachments=='+ newAttachments);
        attWithDetails.AttachmentWrapperList= newAttachments;
        // attWithDetails.missingAttachment
        system.debug('==attWithDetails=='+ attWithDetails);        
        return attWithDetails;        
    }
    
    /* For Tax Exempted -- start   */
    
    @AuraEnabled
    public static DocumentDetails getTaxExemptedAttachment(Id parentRecId, string taxexempted){
        
        set<string> documentDescSet= new set<string>();
        list<Attachment>listOfSavedAttachments = new list<Attachment>();
        list<AttachmentWrapper> newAttachments = new list<AttachmentWrapper>();
        DocumentDetails attWithDetails = new DocumentDetails();
        Allergan_Customer_Registration_AGN__c parentRecordDetails = [SELECT ID FROM Allergan_Customer_Registration_AGN__c WHERE Id =: parentRecId LIMIT 1][0];
        
        // if(taxexempted != '' && taxexempted == '0'){
        newAttachments.add(new AttachmentWrapper(label.AGN_OAM_Proof_of_Tax_Exemption, new Attachment(Description ='This attachemnt reference to proof of Tax Exemption'), true));
        documentDescSet.add(label.AGN_OAM_Proof_of_Tax_Exemption);
        
        // } 
        
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
    
    
    /* For Tax Exempted -- End    */
    
    @AuraEnabled
    public static void deleteFile(Id fileId) {
        
        system.debug('== file to delete fileId =='+fileId);
        Attachment att = [
            SELECT Id 
            FROM Attachment
            WHERE Id =: fileId
        ];
        //------CheckMarx--Updated on 25/07/2020---------- 
        If(Attachment.sObjectType.getDescribe().isDeletable())
        {
            delete att;
        }
        else{
             throw new AGN_CommonException('Error: Insufficient Delete permission on Attachment [Class Name: AGN_OAMDocumentUploaderShipto_CA and Method Name: deleteFile]');
        }
        //---------------------------------------------
    }
    
    
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
        List<Attachment> tmpAttList = new List<Attachment>();        
        tmpAttList.add(attachmentFile);
        /*SObjectAccessDecision decisionOnAtt = Security.stripInaccessible(AccessType.UPSERTABLE,tmpAttList);
        if(decisionOnAtt.getRemovedFields().get('Attachment')!=null){
            throw new AGN_CommonException('Error: Insufficient Create/Edit  Access On Attachment [Class Name: AGN_OAMDocumentUploaderShipto_CA and Method Name: saveTheFile]');
        }
        else{
            upsert attachmentFile;
            return attachmentFile.Id;
        }*/
        String objCrAtt = 'Attachment';
        SObjectType ACRAttObjType = ((SObject)(Type.forName('Schema.'+objCrAtt).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tmpAttList,ACRAttObjType,'UPSERT');
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
            throw new AGN_CommonException('Error: Insufficient Edit Access On Attachment [Class Name: AGN_OAMDocumentUploaderShipto_CA and Method Name: appendToFile]');
        }  
        //----------------------------------------------
       
    }
    @AuraEnabled
    public static string savetestFile(){
        Case c=new Case();
        //------CheckMarx--Updated on 25/07/2020----------   
        if (Schema.sObjectType.Case.fields.CaseNumber.isAccessible()){
            c=[select CaseNumber, Id from Case limit 1];
            return c.CaseNumber;
        }
        return null;
    } 
    
    /* get documents for downLoad link  */
    public static string getDocument(string AccOwner, string ShipToLicense){
        // system.debug('@@@@DocName::::'+docName);
        list<Document> docId;
        if(AccOwner != ''){            
            docId =  [SELECT Id FROM Document WHERE Name =:Label.AGN_OAM_Account_Owner_SigDoc];
            
        }
        if(ShipToLicense != ''){
            docId =  [SELECT Id FROM Document WHERE Name =:Label.AGN_OAM_ShipTo_License_Doc]; 
        }
        if(docId.size()>0){
            return docId[0].Id; 
        }else{return null;}
        
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
        
        /* for Download button  */
        @AuraEnabled
        public string downloadLink {get;set;}        
        @AuraEnabled
        public boolean isDownload {get;set;}
        
        public AttachmentWrapper(string newLabel, Attachment newAttachment, boolean isTrue){
            this.label = newLabel;
            this.isRequired = isTrue;
            this.file = newAttachment;
            this.file.Description = newLabel.trim();
            this.inputFileHtmlId = newLabel.deleteWhitespace();
        }
        
    }
    public class DocumentDetails{
        @AuraEnabled
        public List<AttachmentWrapper> attachmentWrapperList {get;set;}
        @AuraEnabled
        public Boolean missingAttachment {get;set;}
        
        public DocumentDetails(){
            this.attachmentWrapperList = new list<AttachmentWrapper>();
            this.missingAttachment = false;
        }
    }
    
}