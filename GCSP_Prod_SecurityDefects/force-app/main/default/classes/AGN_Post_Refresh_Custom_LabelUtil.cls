public class AGN_Post_Refresh_Custom_LabelUtil{
    public static void updateCustomLabel(AGN_Post_Activity_CustomLabel__mdt labelMetaInfo){
        List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>();
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomLabel csLabel = new MetadataService.CustomLabel();
        
        csLabel.fullName = labelMetaInfo.Custom_Label_Name__c;
        csLabel.language = labelMetaInfo.Language__c;
        csLabel.protected_x  = labelMetaInfo.isProtected__c;
        csLabel.shortDescription  = labelMetaInfo.Description__c;
        //csLabel.value = labelMetaInfo.URLValue__c;
        csLabel.value = labelMetaInfo.Value__c;
        
        allMetadataList.add(csLabel);
        List<MetadataService.SaveResult> results = service.updateMetadata(allMetadataList);
        for(MetadataService.SaveResult result: results){
            system.debug('update custom label=' +result.success);
        }
    }
    
    private static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
}