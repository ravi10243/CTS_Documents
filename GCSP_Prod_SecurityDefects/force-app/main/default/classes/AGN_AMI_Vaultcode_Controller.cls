/**************************************************************************************************************************
@ Class:          AGN_AMI_Vaultcode_Controller
@ Version:        1.0
@ Author:         Ambroz Khan (mdambroz.khan@cognizant.com)
@ Purpose:        Controller class for maintaining changes to vault code changes in metadata.
@ PMO:            CR-3468: Vault code changes for UK admin.
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 28.07.2020 / Ambroz Khan / Created the class.
***************************************************************************************************************************/
public class AGN_AMI_Vaultcode_Controller {
    public String userCountryCode {get; set;}
    public boolean isShow { get; set; }   
    public boolean isEdit {get; set;}
    public String URL = system.label.AGN_AMI_VaultcodeURL;
    public list<AMI_Page_Zinc_Mapping_AGN__mdt> zincdata {get; set;}
    public list<AMI_Page_Zinc_Mapping_AGN__mdt> copyZincdata {get; set;}
    
    private String userLanguage;
    private Map<String, String> oldValueMap; 
    private String zincs = 'ZINC_AGN__c';
    private String DateofPrep = 'Date_of_Preparation_AGN__c';
    private String Label = 'Label';
    private String clickedId = 'clickedId'; 
    private String isdtp = '&isdtp=null';
    private String isdtps = 'isdtp';
    private String UTFencoding = 'UTF-8';
        
    public AGN_AMI_Vaultcode_Controller(){  
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryCode = userDetails.userCountryName;
        getData();
        isEdit= false;
        isShow =true;
    }
    public PageReference save() {
        isEdit= false;
        isShow =true ;
        Map<String,Map<String, Object>> metadataRecordMap = new Map<String,Map<String, Object>>();
        for(AMI_Page_Zinc_Mapping_AGN__mdt zincMetadata : zincdata ){
            String updateZinc = (zincMetadata.ZINC_AGN__c!=null)?zincMetadata.ZINC_AGN__c.trim() : null;
            String updateDate = (zincMetadata.Date_of_Preparation_AGN__c!=null)?zincMetadata.Date_of_Preparation_AGN__c.trim() : null;
            if(oldValueMap.get(zincMetadata.DeveloperName) != (updateZinc + '_' + updateDate)) {
                Map<String, object> metadatafieldMap = new Map<String, object>();
                metadatafieldMap.put(zincs,zincMetadata.ZINC_AGN__c);    
                metadatafieldMap.put(Label,zincMetadata.Label);            
                metadatafieldMap.put(DateofPrep,zincMetadata.Date_of_Preparation_AGN__c);
                metadataRecordMap.put(zincMetadata.DeveloperName, metadatafieldMap);
                oldValueMap.put(zincMetadata.DeveloperName, zincMetadata.ZINC_AGN__c + '_' + zincMetadata.Date_of_Preparation_AGN__c);
            }
        } 
        try{
            AGN_AMI_CustomMetadataUtils.updateCustomMetadata('AMI_Page_Zinc_Mapping_AGN__mdt',metadataRecordMap,system.label.AGN_AMI_Vaultcode_deployedmessage);
            system.debug(metadataRecordMap);
            if(metadataRecordMap.keySet().size()>0)
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.CONFIRM,
                                                           system.label.AGN_AMI_Vaultcode_ProcessingConfirmation));
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        return null;
    }
    public PageReference edit() {
        isEdit= true;
        isShow =false;
        copyZincdata = zincdata;
        return null;
    }
    public PageReference cancel() {
        isEdit= false;
        isShow =true;
        zincdata = copyZincdata;
        getData();
        return null;
    }
    public PageReference goToEditPage () {
        String currentPage = ApexPages.currentPage().getURL() + isdtp;
        String currentPageEncoded = EncodingUtil.urlEncode(currentPage, UTFencoding);
        String clickedRecord = ApexPages.currentPage().getParameters().get(clickedId);
        PageReference pr;
        if(clickedRecord!=null)
        {
            pr = new PageReference('/'+clickedRecord+'/e?retURL='+currentPage);
        }
        return pr;
    }
    public PageReference refresh () {
        String clickedRecord = ApexPages.currentPage().getParameters().get(clickedId);
        PageReference pr = null;
        if(clickedRecord!=null)
        {
            pr = new PageReference(URL);
        }
        return pr;
    }
    public void getData() {
        oldValueMap = new Map<String, String>();
        zincdata = [SELECT  Country_AGN__c,Date_of_Preparation_AGN__c,
                    		Disclaimer_Text_AGN__c,Page_Label_AGN_AMI__c,DeveloperName,
                    		Page_Name_AGN__c,Report_Adverse_Event_Box_AGN__c,Type_AGN_AMI__c,ZINC_AGN__c, Label
                    FROM AMI_Page_Zinc_Mapping_AGN__mdt
                    WHERE Country_AGN__c = :userCountryCode
                    Order by Page_Label_AGN_AMI__c ASC];
        for(AMI_Page_Zinc_Mapping_AGN__mdt metadata : zincdata){
            oldValueMap.put(metadata.DeveloperName, metadata.ZINC_AGN__c + '_' + metadata.Date_of_Preparation_AGN__c);
        }
    }
}