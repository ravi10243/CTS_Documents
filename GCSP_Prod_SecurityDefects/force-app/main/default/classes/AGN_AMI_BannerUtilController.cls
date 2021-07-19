/**************************************************************************************************************************
@ Class:          AGN_AMI_BannerUtilController
@ Version:        1.0
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
@ Purpose:        Controller class for AGN_AMI_BannerUtil vf page.
@ PMO:            CR-3336: Manage click behaviour and upload image as attachment of the records for rotating banner.
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 03.07.2020 / JOYDEV MONDOL / Created the class.
***************************************************************************************************************************/

public class AGN_AMI_BannerUtilController {
    
    /*Constants*/
    static final String       CLASSNAME    = 'AGN_AMI_BannerUtilController';
    static final String       METHODNAME1  = 'attachImage';
    static final String       METHODNAME2  = 'updateCallToAction';
    static final String       METHODNAME3  = 'updateBanner';
    
    // PMO#3487 - Added new fields for in list of fields
    static final List<String> BANNERFIELDS = new List<String> { 'Id', 'BannerImageId_AGN_AMI__c', 
                                                                'ButtonLabel_AGN_AMI__c', 'Behaviour_AGN_AMI__c',
                                                                'Link_AGN_AMI__c', 'TagLine_AGN_AMI__c', 
                                                                'Description_AGN_AMI__c', 'Vault_code_AGN_AMI__c',
                                                                'ButtonLabel_AGN_AMI__c', 'Button_Position_AGN_AMI__c', 
        														'Button_Color_AGN_AMI__c', 'Font_Color_AGN_AMI__c'};
    
    /*Properties*/
    public AMI_Banner_AGN__c banner      { get; set; }
    public Attachment        bannerImage { get; set; }
    public Boolean 			 refreshPage { get; set; }
    /**********************************************************************************************************************
    @ Constructor:    AGN_AMI_BannerUtilController
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        Initialises the class members.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 03.07.2020 / JOYDEV MONDOL / Created the constructor.
    ***********************************************************************************************************************/
    public AGN_AMI_BannerUtilController(ApexPages.StandardController controller) { 
        refreshPage = false;
        //get the current record with neccesary fields only
        if (!Test.isRunningTest()) { 
        controller.addFields(BANNERFIELDS);  
        }
        banner = (AMI_Banner_AGN__c)controller.getRecord();
        
        //fetch existing image attachment - create one if dosen't exist
        try {
            bannerImage = [SELECT Id, Name, Body 
                           FROM   Attachment 
                           WHERE  Id = :banner.BannerImageId_AGN_AMI__c];
                           
        } catch(Exception e) {
            bannerImage = new Attachment(ParentId = banner.Id);
        }        
    }
    
    /***********************************************************************************************************************
    @ Method:         attachImage
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        saves the attachment and updates the hidden field in banner record
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 03.07.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public Pagereference attachImage() {
        
        try {   
            //update/insert image attachment         
            upsert bannerImage;
            
            //update attachment id in banner for the first time only
            if(String.isEmpty(banner.BannerImageId_AGN_AMI__c)) {
                
                
                if(Schema.sObjectType.AMI_Banner_AGN__c.fields.BannerImageId_AGN_AMI__c.isUpdateable ()
                   && Schema.sObjectType.AMI_Banner_AGN__c.isUpdateable ()){
                       
                       banner.BannerImageId_AGN_AMI__c = bannerImage.Id;              
                       update Banner;
                   }
                
        	refreshPage = true;
            }
        } catch(Exception ex) {
            AGN_AMI_ErrorLogger.createExceptionsLog(ex, CLASSNAME, METHODNAME1);
        } 
        
        //remove the image blob to clear view state
        bannerImage.body = null;
        return ApexPages.currentPage();
    }
    
    /***********************************************************************************************************************
    @ Method:         updateCallToAction
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        saves the call to action details configured for the banner
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 03.07.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public Pagereference updateCallToAction() {
        
        try {   
            update banner;
            
        	refreshPage = true;
        } catch(Exception ex) {
            AGN_AMI_ErrorLogger.createExceptionsLog(ex, CLASSNAME, METHODNAME2);
        } 
        return ApexPages.currentPage();
    } 
    
    /***********************************************************************************************************************
    @ Method:         updateBanner
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        saves the banner
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 03.07.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public Pagereference updateBanner() {
        try {   
            update banner;
            
        	refreshPage = true;
        } catch(Exception ex) {
            AGN_AMI_ErrorLogger.createExceptionsLog(ex, CLASSNAME, METHODNAME3);
        } 
        return ApexPages.currentPage();
    }  
}