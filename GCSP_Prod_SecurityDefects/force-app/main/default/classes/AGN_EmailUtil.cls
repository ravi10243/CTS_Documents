/* @author         Cognizant
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version        1.1
* @created        
* @modified      Preeti Achary
* @testClass     
* @Class Name    AGN_EmailUtil
* ----------------------------------------------------------------------------------------------------------------------------
* @description -  Class to dynamically generate for various requirement of CCPA and GDPR. 
* Changes made : Added Line number: 71-79 in method getTaskEmailBody, as part of Release 3, Sprint 1, Production defect fixes.
                 Updated BO Daily Task notification email body text for CCPA, as provided by allergan.
 ------------------------------------------------------------------------------------------------------------------------------
*/
public class AGN_EmailUtil{
    public static string getTableEmailBody(Set<Asset_Register_AGN__c> newAssetList , Set<Asset_Register_AGN__c>existingAssetList, Set<Asset_Register_AGN__c> rejectedAssetList){
        
        String htmlBody = '';
        htmlBody = System.Label.AGN_CCPA_Weekly_Notification_Text;
        
        if(newAssetList !=null && !newAssetList.isEmpty()){
            //open table..
            htmlBody += '<table border="1" style="border-collapse: collapse"><caption>New Asset(s) – Approval required:</caption><tr><th>File System Name</th><th>Top Level Business Unit</th><th>Filing System Type</th><th>Application ID (EAL ID)</th><th>Date Created</th></tr>';
            htmlBody = fetchDynamicEmailBody(newAssetList , htmlBody);
             htmlBody += '</table>';
            
        }   
        //for Existing Data     
        //open table..
        if(existingAssetList !=null && !existingAssetList.isEmpty()){
            htmlBody += '<br/> <table border="1" style="border-collapse: collapse"><caption>Modified Asset(s) – Approval required:</caption><tr><th>File System Name</th><th>Top Level Business Unit</th><th>Filing System Type</th><th>Application ID (EAL ID)</th><th>Date Created</th></tr>';
            htmlBody = fetchDynamicEmailBody(existingAssetList , htmlBody);
            htmlBody += '</table>';
        }   
        // For Rejected Data
        if(rejectedAssetList !=null && !rejectedAssetList.isEmpty()){
            htmlBody += '<br/> <table border="1" style="border-collapse: collapse"><caption>Rejected Asset(s) – Sent back for correction :</caption><tr><th>File System Name</th><th>Top Level Business Unit</th><th>Filing System Type</th><th>Application ID (EAL ID)</th><th>Date Created</th></tr>';
            htmlBody = fetchDynamicEmailBody(rejectedAssetList , htmlBody);
             htmlBody += '</table>';
        }
       
        htmlBody += '<br/>Yours sincerely,<br/>Allergan’s US Privacy Office'; 
        system.debug('htmlBody***'+ htmlBody);    
        return htmlBody;
    }
    public static string getQuaterlyEmailBody(Set<Asset_Register_AGN__c> allAssetList){
        String htmlBody = System.Label.AGN_CCPA_Quaterly_Notification_Text;
        if(allAssetList !=null && !allAssetList.isEmpty()){
            //open table..
            htmlBody += '<table border="1" style="border-collapse: collapse"><p><br/></p><tr><th>File System Name</th><th>Filing System Status</th><th>Filing System Application Status</th><th>Top Level Business Unit</th><th>Filing System Regulation</th><th>Owner</th></tr>';
            //iterate over list and output columns/data into table rows...
            for(Asset_Register_AGN__c asset : allAssetList){
                String assetURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + asset.Id;
                String fileSystem = asset.Name; if(asset.Name == null){fileSystem = '[Not Provided]';}
                String filingStatus = asset.Asset_Status_AGN__c; if(asset.Asset_Status_AGN__c== null){filingStatus = '[Not Provided]';}
                String topBusinessUnit = asset.Top_Level_Business_Unit_GDPR_AGN__c; if(asset.Top_Level_Business_Unit_GDPR_AGN__c== null){topBusinessUnit = '[Not Provided]';}
                String applicationStatus = asset.Application_Status_AGN__c; if(asset.Application_Status_AGN__c== null){applicationStatus = '[Not Provided]';}
                String fileSystemType = asset.Recordtype.Name; if(asset.Recordtype.Name == null){fileSystemType = '[Not Provided]';}
                String ownerName= asset.Owner.Name; if(asset.Owner.Name== null){ownerName = '[Not Provided]';}
            
                htmlBody += '<tr><td><a href ='+ assetURL + '>'+ fileSystem +'</a></td><td>' + filingStatus + '</td><td>'  + applicationStatus  +'</td><td>'+ topBusinessUnit +'</td><td>'+ fileSystemType +'</td><td>'+ ownerName  +'</td></tr>';
            }
            htmlBody += '</table>';
        }
        htmlBody += '<br/><br/>Yours sincerely,<br/>Allergan’s US Privacy Office';   
        return htmlBody;  
    } 
    // Chanages made in line 70,79,81 as a part of Release 3 Sprint 1 Req ID - DSRm-37 "As BO I should see a "Regulation" column in the DSRm tasks assigned email"
    // Changes made in line 72-80 to include different task email body text for CCPA and GDPR. Defect D_49, Release 3, Sprint 1
    public static string getTaskEmailBody(Set<Business_Owner_Task_GDPR_AGN__c> allbusinessList,String taskType){
        String htmlBody;
        if(taskType =='CCPA')
        {
            htmlBody = System.Label.AGN_Daily_Task_Notification_CCPA_Text;   
        }
        if(taskType =='GDPR')
        {
            htmlBody = System.Label.AGN_Daily_Task_Notification_Text;   
        }   
        if(allbusinessList !=null && !allbusinessList.isEmpty()){
            //open table..
           //Line 85,97 to be removed and line 84,94,96 to be uncommented for the DSRM 37 releae 3 requirement
           //  htmlBody += '<table border="1" style="border-collapse: collapse"><p><br/></p><tr><th>Task Name</th><th>Task Subject</th><th>Task Status</th><th>Days To Close</th><th>Asset</th><th>Regulation</th></tr>';
             htmlBody += '<table border="1" style="border-collapse: collapse"><p><br/></p><tr><th>Task Name</th><th>Task Subject</th><th>Task Status</th><th>Days To Close</th><th>Asset</th></tr>';
            //iterate over list and output columns/data into table rows...
            for(Business_Owner_Task_GDPR_AGN__c botask : allbusinessList){
                String taskURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + botask.Id;
                String taskName = botask.Name; if(botask.Name == null){taskName = '[Not Provided]';}
                String taskSubject = botask.Task_Subject_GDPR_AGN__c; if(botask.Task_Subject_GDPR_AGN__c== null){taskSubject = '[Not Provided]';}
                String taskStatus = botask.Status_GDPR_AGN__c; if(botask.Status_GDPR_AGN__c== null){taskStatus = '[Not Provided]';}
                string daytoClose = String.valueOf(botask.Days_to_Close_GDPR_AGN__c); 
                String assetName= botask.Asset_GDPR_AGN__r.Name; if(botask.Asset_GDPR_AGN__r.Name == null){assetName = '[Not Provided]';}
              //  String regulation=botask.Case_Type_GDPR_AGN__c; if(botask.Case_Type_GDPR_AGN__c == null){regulation = '[Not Provided]';}
            
               // htmlBody += '<tr><td><a href ='+ taskURL + '>'+ taskName +'</a></td><td>' + taskSubject + '</td><td>'  + taskStatus +'</td><td>'+ daytoClose +'</td><td>'+ assetName  +'</td><td>'+ regulation +'</td></tr>';
                htmlBody += '<tr><td><a href ='+ taskURL + '>'+ taskName +'</a></td><td>' + taskSubject + '</td><td>'  + taskStatus +'</td><td>'+ daytoClose +'</td><td>'+ assetName  +'</td></tr>';
            }
            htmlBody += '</table>';
        }
        if(taskType =='CCPA')
        {
            htmlBody += '<br/><br/>Yours sincerely,<br/>Allergan’s US Privacy Office';   
        }
        if(taskType =='GDPR')
        {
            htmlBody += '<br/><br/>Yours sincerely,<br/>Allergan Support Team';   
        }   
        return htmlBody;  
    }
    public static string fetchDynamicEmailBody(Set<Asset_Register_AGN__c> assetSet , String htmlBody){
        String fileSystem;
        String topBusinessUnit;
        String fileSystemType;
        String appID;
        String DateCreated;
        String assetURL; 
        for(Asset_Register_AGN__c asset : assetSet){
            //Fetch assetURL
            assetURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + asset.Id; 
            //Fetch FileSystem
            fileSystem = String.isNotBlank(asset.Name)? asset.Name : '[Not Provided]'; 
            //Fetch topBusinessUnit
            topBusinessUnit = String.isNotBlank(asset.Top_Level_Business_Unit_GDPR_AGN__c) ? 
            asset.Top_Level_Business_Unit_GDPR_AGN__c : '[Not Provided]';
            //Fetch fileSystemType
            fileSystemType = String.isNotBlank(asset.File_system_Type_GDPR_AGN__c) ? 
            asset.File_system_Type_GDPR_AGN__c : '[Not Provided]';
            //Fetch appID
            appID = String.isNotBlank(asset.Application_ID_EAL_ID_AGN__c) ? 
            asset.Application_ID_EAL_ID_AGN__c : '[Not Provided]';
            //Fetch DateCreated
            DateCreated = String.valueOf(asset.Created_Date_AGN__c); 
            
            htmlBody += '<tr><td><a href ='+ assetURL + '>'+ fileSystem +'</a></td><td>' + topBusinessUnit + '</td><td>'  + fileSystemType +'</td><td>'+ appID  +'</td><td>'+ DateCreated +'</td></tr>';
        }
        system.debug('Email Body: ' + htmlBody);   
        return htmlBody;  
    }
}