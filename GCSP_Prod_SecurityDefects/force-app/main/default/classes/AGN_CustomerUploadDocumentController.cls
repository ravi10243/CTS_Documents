public class AGN_CustomerUploadDocumentController {

    public string parentRecordId {get;set;}
    public Allergan_Customer_Registration_AGN__c parentRecord{get; set;}
    public string documentList {get;set;}
    public string [] documentNames {get;set;} 
    public string parentRecordState{get;set;}
    public string parentRecordCRM{get;set;}
    public List<SelectOption> getTaxOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Allergan_Customer_Registration_AGN__c.Tax_Exempted_AGN__c.getDescribe();     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }   
        return options;
    }

    /*public AttachmentWrapper taxAttachments{get{
        AttachmentWrapper att = new AttachmentWrapper('TaxDocument', new Attachment(Description = 'Copy of Tax Certificate'));
        return att;
        }set;}
    public string SelectedTaxoption{get; set;}
    public void setSelectedTaxoption(string opt)
    {
        parentRecord.Tax_Exempted_AGN__c=(opt=='true'?true:false);
      //parentRecord.Tax_Exempted_AGN__c=true;
    }*/

    private list<Attachment> listOfSavedAttachments;
    public list<AttachmentWrapper> newAttachments;
    private Attachment taxDocument;
    
    public AGN_CustomerUploadDocumentController(){
        list<Attachment> listOfSavedAttachments = new list<Attachment>();
    }

    public Attachment getTaxDocument(){
        taxDocument= new Attachment();
        if(listOfSavedAttachments!=null){
            for (Attachment att :listOfSavedAttachments){
                
                if(att.Description=='Copy of Tax Document')
                    taxDocument=att;
            }
        }
        return taxDocument;
    }
    
    public list<AttachmentWrapper> getNewAttachments(){

        set<string> documentDescSet= new set<string>();
        
        newAttachments = new list<AttachmentWrapper>();
        
        string [] documentNames = documentList.split(';');        
        for (integer i = 0; i < documentNames.size(); i++){
            newAttachments.add(new AttachmentWrapper(documentNames[i], new Attachment(Description = documentNames[i])));
            documentDescSet.add(documentNames[i]);
        }

        listOfSavedAttachments = [SELECT  Id,
                                          Name,
                                          Description,
                                          Body,
                                          BodyLength,
                                          ContentType,
                                          OwnerId,
                                          ParentId 
                                     FROM Attachment                                                         
                                    WHERE ParentId =:parentRecord.id ] ;
        if(listOfSavedAttachments!=null){
            for (Attachment att :listOfSavedAttachments){
                for(AttachmentWrapper aw:newAttachments){
                    
                   if(att.Description.Trim()==aw.attach.Description.Trim())
                   {
                        aw.attach=att;
                   }
                }            
            }
        }
        parentRecordState=parentRecord!=null && parentRecord.Physician_Registration_Reference_AGN__c!=null && parentRecord.Physician_Registration_Reference_AGN__c.contains('_') && !(String.IsBlank(parentRecord.Physician_Registration_Reference_AGN__c))?parentRecord.Physician_Registration_Reference_AGN__c.split('_')[1]:'';
        parentRecordCRM=parentRecord!=null && parentRecord.Physician_Registration_Reference_AGN__c!=null && parentRecord.Physician_Registration_Reference_AGN__c.contains('_') && !(String.IsBlank(parentRecord.Physician_Registration_Reference_AGN__c))?parentRecord.Physician_Registration_Reference_AGN__c.split('_')[0]:'';
        return newAttachments;
        
    }
    
    public void saveAttachments(){
        
        list<Attachment> attachments = new list<Attachment>();        
        parentRecord.Online_Registration_Step_AGN__c='4';
        
        //parentRecord.CRM_CRO__c=parentRecordState!=''?parentRecord.CRM_CRO__c+'-'+parentRecordState:parentRecord.CRM_CRO__c;
        if(!(String.IsBlank(parentRecordCRM) && String.IsBlank(parentRecordState)))
            parentRecord.Physician_Registration_Reference_AGN__c=parentRecordCRM+'_'+parentRecordState;
        
        
        for(AttachmentWrapper aw : newAttachments){
            
            if (aw.attach.Name != ''){

                aw.attach.OwnerId = UserInfo.getUserId();
                if (aw.attach.ParentId==null){
                    aw.attach.ParentId = parentRecord.id;
                }
                attachments.add(aw.attach);
            }
        }
        system.debug('==='+taxDocument.name );
        if(parentRecord.Tax_Exempted_AGN__c=='Y'){
            taxDocument.OwnerId = UserInfo.getUserId();
            if (taxDocument.ParentId== null){
                taxDocument.ParentId = parentRecord.id;
            }
            taxDocument.Description = 'Copy of Tax Document';
            system.debug('==='+taxDocument.name );
            attachments.add(taxDocument);
        }
       
        
        try{
            //upsert attachments;
            //------CheckMarx Phase2--Added on08/09/2020---------- 
            String objAtt1 = 'Attachment';
            SObjectType attObjType = ((SObject)(Type.forName('Schema.'+objAtt1).newInstance())).getSObjectType();
            AGN_FLSCheck.check(attachments,attObjType,'UPSERT');
            upsert attachments;
            //----------------------------------------------------  
            //update parentRecord;
            //------CheckMarx Phase2--Added on08/09/2020---------- 
            List<Allergan_Customer_Registration_AGN__c> tempCrRegList = new List<Allergan_Customer_Registration_AGN__c>();
            tempCrRegList.add(parentRecord);
            String objCrReg = 'Allergan_Customer_Registration_AGN__c';
            SObjectType crRegObjType = ((SObject)(Type.forName('Schema.'+objCrReg).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCrRegList,crRegObjType,'UPDATE');
            update parentRecord;
            //---------------------------------------------------- 
            List<Allergan_Customer_Address_AGN__c> craList= [SELECT Id, Tax_Classification_AGN__c from Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =: parentRecord.Id];
            if(!craList.isEmpty()){
                for(Allergan_Customer_Address_AGN__c cra :craList){
                    cra.Tax_Classification_AGN__c = parentRecord.Tax_Exempted_AGN__c;
                    cra.VAT_Number_AGN__c= parentRecord.VAT_AGN__c;
                }
                //------CheckMarx Phase2--Added on08/09/2020---------- 
                String objCrAddr = 'Allergan_Customer_Address_AGN__c';
                SObjectType crAddrObjType = ((SObject)(Type.forName('Schema.'+objCrAddr).newInstance())).getSObjectType();
                AGN_FLSCheck.check(craList,crAddrObjType,'UPDATE');
                update craList;
                //----------------------------------------------------  
                //update craList;
            }
            
        }
        catch(exception e){
            system.debug('Document Exception:'+e);
        }
    }
    
    
    public class AttachmentWrapper{
        
        public string label {get;set;}
        public Attachment attach {get;set;}
        
        public AttachmentWrapper(string newLabel, Attachment newAttachment){
            this.label = newLabel;
            this.attach = newAttachment;
        }
        
    }
        
}