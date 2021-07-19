/**************************************************************************************************************************
@ Class:          AGN_AMI_ContentDelivery_Helper 
@ Version:        1.0
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        This is to update related record specifically AMI_Projects_AGN__c and AMI_InFocus_AGN__c with link from
the ContentDistribution
@ PMO:            CR-3334: Infocus tab introduction
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.07.2020 / Ayush Basak / Created the trigger.
***************************************************************************************************************************/
public without sharing class AGN_AMI_ContentDelivery_Helper {
    
    public static void linkUpdateHelper(List<ContentDistribution> insertList){
        
        Map<Id, id> infocusUpdateMap = new Map<id, id>();
        Map<Id, String> clinicalGallertUpdateMap = new Map<id, String>();
        for(ContentDistribution cd : insertList) {
            if(cd.RelatedRecordId != null) { 
                if(cd.RelatedRecordId.getsobjecttype().getDescribe().getName() == 'AMI_InFocus_AGN__c') { 
                    infocusUpdateMap.put(cd.Id, cd.RelatedRecordId);
                }
                if(cd.RelatedRecordId.getsobjecttype().getDescribe().getName() == 'AMI_Project_AGN__c') { 
                    clinicalGallertUpdateMap.put(cd.Id, cd.RelatedRecordId);
                }
            }
        }
        if(! infocusUpdateMap.isEmpty())
            AGN_AMI_ContentDelivery_Helper.updateInfocusLink(infocusUpdateMap);
        
        if(! clinicalGallertUpdateMap.isEmpty())
            AGN_AMI_ContentDelivery_Helper.updateCGLink(clinicalGallertUpdateMap);
    }
    
    public static void updateInfocusLink(Map<Id, Id> infocusUpdateMap) { 
        try {
            List<AMI_InFocus_AGN__c> updateInfocusList = new List<AMI_InFocus_AGN__c>();
            List<ContentDistribution> contents = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id IN : infocusUpdateMap.keySet()];
            Map<Id, String> contentMap = new Map<id, String>();
            for(ContentDistribution cd : contents) {
                contentMap.put(cd.Id, cd.DistributionPublicUrl);
            }
            System.debug(contents);
            for(id i : infocusUpdateMap.keySet()) {
                if(Schema.sObjectType.AMI_Project_AGN__c.fields.Content_Link_AGN_AMI__c.isUpdateable()){
                    AMI_InFocus_AGN__c temp = new AMI_InFocus_AGN__c(id = infocusUpdateMap.get(i), Video_URL_AGN__c = contentMap.get(i));
                    updateInfocusList.add(temp);
                }
            }
            
            if(! updateInfocusList.isEmpty()) {
                update updateInfocusList;
            }
        }
        catch(Exception ex) {
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_ContentDelivery_Helper','updateInfocusLink');
        }
    }
    
    public static void updateCGLink(Map<Id, Id> cgUpdateMap) { 
        try {
            List<AMI_Project_AGN__c> updateCGList = new List<AMI_Project_AGN__c>();
            List<ContentDistribution> contents = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id IN : cgUpdateMap.keySet()];
            Map<Id, String> contentMap = new Map<id, String>();
            for(ContentDistribution cd : contents) {
                contentMap.put(cd.Id, cd.DistributionPublicUrl);
            }
            
            for(id i : cgUpdateMap.keySet()) {
                if(Schema.sObjectType.AMI_Project_AGN__c.fields.Content_Link_AGN_AMI__c.isUpdateable()){
                    AMI_Project_AGN__c temp = new AMI_Project_AGN__c(id = cgUpdateMap.get(i), Content_Link_AGN_AMI__c = contentMap.get(i));
                    updateCGList.add(temp);                      
                }
            }
             
            if(! updateCGList.isEmpty()) {
                
                update updateCGList;
            }
        }
        catch(Exception ex) {
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_ContentDelivery_Helper','updateCGLink');
        }
    }
}