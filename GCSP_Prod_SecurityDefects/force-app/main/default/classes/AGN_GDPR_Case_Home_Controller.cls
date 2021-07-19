/*
*------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev Roushan
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        1.0
* @created        
* @modified      15-Nov-2019
* @testClass     
* @Class Name    AGN_GDPR_Case_Home_Controller
* ----------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019           
* Home Page Controller for AGN_GDPR_Case_Home VF PAGE for Community Users where they can view the attachments related
to their Caese fetch from their respective Business Owner Task.
*-------------------------------------------------------------------------------------------------------------------------+
*/

public without sharing class AGN_GDPR_Case_Home_Controller
{     
    public List<Business_Owner_Task_GDPR_AGN__c> Tasks {get; set;}
    public List<ContentDocumentLink> ConDocLink {get;set;}
    public List<ContentDocumentLink> ConDocLinks {get;set;}
    public List<ContentDocument> ConDoc {get;set;}
    public List<Case> CaseList {get; set;}
    public string myCaseNumber {get;set;}
    public string CurrStatus {get;set;}
    public string Role {get;set;}
    public string Email {get;set;}
    public String ReqType {get;set;}
    public string FullName {get;set;}
    public string FullAdd {get;set;}
    public string Phone {get;set;}
    public string City {get;set;}
    public string State {get;set;}
    public string Channel {get;set;}
    public Date InCloseDate {get;set;}
    public Date ExpCloseDate {get;set;}
    public String AccessTillDate {get;set;}
    public string ProConsent {get;set;}
    public string WitConsent {get;set;}
    public string AllIdentity {get;set;}
    public string RectReason {get;set;}
    public string PerDataWay {get;set;}
    public string Affiliation {get;set;}
    public string AddInfo {get;set;}
    public boolean displayPopup {get; set;}
    public boolean discalamerPopup {get; set;}
    public List<clsContentDocument> lstContentDoc {get; set;} 
    
    Case objCase = new Case();
    
    public AGN_GDPR_Case_Home_Controller ()
    {
        lstContentDoc = new List<clsContentDocument>();      
        id userId = UserInfo.getUserId();
        User userObj = [select id,email,ContactId,Access_Till_AGN_GDPR__c,FirstLogin_AGN__c,Name from User where id = :userId];
        
        FullName = userObj.Name;
        system.debug('The Logged in User is: '+userObj);
        
        if(userObj.FirstLogin_AGN__c   == false)
        {
            discalamerPopup = true;
        }
        else
        {
            discalamerPopup = false;
        }
        
        String AccessDate = String.valueOf(userObj.Access_Till_AGN_GDPR__c);
        system.debug('The Logged in User AccessDate : '+AccessDate );
        
        String day = AccessDate.substring(8,10);
        String month = AccessDate.substring(5,7);
        String Year = AccessDate.substring(0,4);
        
        system.debug('The Expired day of the User is: '+day);
        system.debug('The Expired month of the  User is: '+month);
        system.debug('The Expired year of the  User is: '+Year);
        
        AccessTillDate = day + '/' + month + '/' + year;
        
        
        //List of All Cases using DS email 
        CaseList = new List<Case>();
        CaseList = [Select Id,CaseNumber,Status,Role_with_Allergan_GDPR_AGN__c,
                    Data_Subject_Email_GDPR_AGN__c,Request_Type_GDPR_AGN_new__c,Request_Type_GDPR_AGN__c,
                    First_Name_GDPR_AGN__c, Last_Name_GDPR_AGN__c, Street_Address_GDPR_AGN__c,Expected_Case_Close_Date_Time_AGN__c, Data_Subject_Phone_GDPR_AGN__c,
                    Town_City_GDPR_AGN__c,State_GDPR_AGN__c,Case_Creation_Channel_GDPR_AGN__c,Initial_Closed_Date_AGN__c,
                    Provide_Consent_GDPR_AGN__c,Withdraw_Consent_GDPR_AGN__c,
                    Way_of_Indentify_GDPR_AGN__c,Rectification_changes_GDPR_AGN__c,
                    Personal_Data_GDPR_AGN__c,Affiliation_GDPR_AGN__c
                    from Case where Data_Subject_Email_GDPR_AGN__c = :userObj.email 
                    and Currently_Accessible_AGN__c = True and Status IN ('Task Completed','Closed')
                    and Request_Type_GDPR_AGN_new__c IN ('Portability','Access','Specific pieces of personal information (Access)') ];
        
        
        
        system.debug('The CaseList of the User is: '+CaseList);
        // Set of Case ID's to Query Business Owner Task
        Set<Id> csId = new Set<Id>();
        for(Case caseObj : CaseList)
        {
            csId.add(caseObj.Id);
        }
        System.debug('Case ID Set --> '+csId);
        
        //List of all Associated Tasks
        List<Business_Owner_Task_GDPR_AGN__c> BOTaskList =new  List<Business_Owner_Task_GDPR_AGN__c>();
        BOTaskList = [Select Id,Case_Type_GDPR_AGN__c,Name,Related_to_GDPR_AGN__c,Related_to_GDPR_AGN__r.CaseNumber,
                  Business_Owner_Comment_AGN_GDPR_Case__c,Status_GDPR_AGN__c,Task_Subject_GDPR_AGN__c 
                  FROM Business_Owner_Task_GDPR_AGN__c WHERE Related_to_GDPR_AGN__c in :csId];
        
        
        Set<Id> setBSTaskId = new Set<Id>();
        for(Business_Owner_Task_GDPR_AGN__c  objtsk : BOTaskList)
        {
            setBSTaskId.add(objtsk.Id); // Business Owner Task Id
        }
        
        System.debug('setBSTaskId --> ' + setBSTaskId);
        ConDocLinks = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :setBSTaskId];  
        System.debug('ConDocLinks --> ' + ConDocLinks);
        
        //Map to store CaseNumber Business Owner Task ID
        
        Map<ID,string> conDocMap = new Map<ID,string>();
        
        for(Business_Owner_Task_GDPR_AGN__c btask :BOTaskList)
        {
            conDocMap.put(btask.Id,btask.Related_to_GDPR_AGN__r.CaseNumber);
        }
          
        //Set to Store Content Documnet ID
        Set<Id> setConDocId = new Set<Id>(); 
        for(ContentDocumentLink objConDoc : ConDocLinks)
        {
            setConDocId.add(objConDoc.ContentDocumentId);
        }
        
        ConDoc = [SELECT Id,Title,createdDate FROM ContentDocument WHERE Id in :setConDocId];
        
        system.debug('ConDoc -->: ' +ConDoc);
        
        Map<Id, ContentDocument> mapConDoc = new Map<Id, ContentDocument>(); // Map for Content Document
        Map<Id, ContentVersion> mapConVer = new Map<Id, ContentVersion>(); // Map for Content Version
        for(ContentDocument objcon : ConDoc)
        {
            system.debug('ContentDocument Loop Id --> ' + objcon.Id);
            mapConDoc.put(objcon.Id, objcon);
        }
        
        system.debug('ConDoc Map --> ' + mapConDoc);
        
        //Iterating Content Document Verison 
        for(ContentVersion objconver : [SELECT Id, ContentDocumentId, FileExtension FROM ContentVersion where ContentDocumentId in : setConDocId and IsLatest = true])
        {
            system.debug('ContentDocumnetID loop --> ' + objconver.ContentDocumentId);
            mapConVer.put(objconver.ContentDocumentId, objconver);
        }
        
        system.debug('ConVer Map details ' + mapConVer);
        
        /* Iterating And assigning values to Variales to display on the page includes attachment name 
            case number and a download link content document Version ID */
        
        for(ContentDocumentLink objConDoc : ConDocLinks)
        {
            system.debug('ContentDocumentLink Loop --> ' + objConDoc.ContentDocumentId);
            
            clsContentDocument objcls = new clsContentDocument();
            
            system.debug('ContentDocument: ' + mapConDoc.get(objConDoc.ContentDocumentId));
            
            ContentDocument objcd = mapConDoc.get(objConDoc.ContentDocumentId);
            
            objcls.strTitle = objcd.Title;
            
            system.debug('ContentVersion:' + mapConVer.get(objConDoc.ContentDocumentId));
            
            ContentVersion objcv = new ContentVersion();
            
            objcv = mapConVer.get(objConDoc.ContentDocumentId);
            
            objcls.VersionId = objcv.Id;
            
            objcls.CaseNumber = conDocMap.get(objConDoc.LinkedEntityId);
            
            lstContentDoc.add(objcls);
        }
        system.debug('List of ConDoc' + lstContentDoc);
        
    }
    
    //Closing Disclamer Login popup on first Login and Updating the User Object Field
    public void closedisclamerPopup() 
    {      
        discalamerPopup = false;  
        try
        {
            Id userId = UserInfo.getUserId();
            User up = [select id, email, ContactId, Access_Till_AGN_GDPR__c ,FirstLogin_AGN__c   from User where id = : userId];
            up.FirstLogin_AGN__c = true;
            Update up;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }  
    
    public class clsContentDocument
    {
        public Id VersionId {get; set;}
        public string strDocumentId {get; set;}
        public date dtCreatedDate {get; set;}      
        public string strTitle {get;set;}
        public string CaseNumber {get;set;}
        public string ReqType{get;set;}
        public string RolewithAgn{get;set;}
    }   
    
}