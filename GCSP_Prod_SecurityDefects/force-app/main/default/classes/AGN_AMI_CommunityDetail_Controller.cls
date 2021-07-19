/**********************************************************************************************************************
@ Constructor:    AGN_AMI_CommunityDetail_Controller 
@ Version:        1.1
@ Author:         PALLAVI   (pallavi.p3@cognizant.com) / Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        Initialises the class members and fetching record of AMI_Project_AGN__c.
-----------------------------------------------------------------------------------------------------------------------
@ Change history: 06.06.2020 / PALLAVI / Created the class.
@ Change history: 06.06.2020 / Ayush Basak / Added new methods to the class.
***********************************************************************************************************************/

public without sharing class AGN_AMI_CommunityDetail_Controller {
    public static string CLOSED_STATUS = 'Closed';
    public static String CASE_RECORDTYPE_NAME = 'AGN AMI Clinical Gallery Info Request';
    public static String CASE_STATUS = 'Submitted';
    public static String CASE_SUBJECT_PREFIX = 'AMI Clinical Gallery Project Information Required';
    public static String CASE_ORIGIN = 'Web';
    public static String TASK_STATUS = 'Open';
    public static String TASK_PRIORITY = 'Normal'; 
    public static map<String, String> ADMIN_GROUPS = new Map<String, String>{
    	'GB' => 'AGN_AMI_Admin_GB',
        'ES' => 'AGN_AMI_Admin_ES',
    	'IT' => 'AGN_AMI_Admin_IT',
        'FR' => 'AGN_AMI_Admin_FR',
        'TR' => 'AGN_AMI_Admin_TR',
    	'DE' => 'AGN_AMI_Admin_DE',
        'SA' => 'AGN_AMI_Admin_SA',
        'AE' => 'AGN_AMI_Admin_AE'
    };
    
    public String userLanguage {get; set;}
    public AMI_Project_AGN__c pro{get;set;}
    public string category{get;set;}
    public string product{get;set;}
    public string area{get;set;}
    public Boolean requestInPlace {get; set;}
    public String proId;
    public Account accountRecord;
    public Contact contactRecord;
    public String userCountryCode;
    
    /**********************************************************************************************************************
    @ Constructor:    AGN_AMI_CommunityDetail_Controller 
    @ Version:        1.0
    @ Author:         PALLAVI   (pallavi.p3@cognizant.com)
    @ Purpose:        Initialises the class members and fetching record of AMI_Project_AGN__c.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 06.06.2020 / PALLAVI / Created the constructor.
    ***********************************************************************************************************************/
    
    public AGN_AMI_CommunityDetail_Controller(){
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        accountRecord = userDetails.accountRecord; 
        contactRecord = userDetails.contactRecord;
        userCountryCode = userDetails.userCountryName;
        proId =apexpages.currentpage().getparameters().get('projectId');
        
        pro=[select Content_Link_AGN_AMI__c,Product_AGN_AMI__c,Area_AGN_AMI__c,
             Title_AGN_AMI__c,Category_AGN_AMI__c,
             Job_Title_AGN_AMI__c,Description_AGN_AMI__c,
             Location_AGN_AMI__c,Account_AGN_AMI__r.Name,
             Preview_Description_AGN_AMI__c,HCP_Image_AGN_AMI__c,
             Image_AGN_AMI__c   
             FROM AMI_Project_AGN__c 
             WHERE Id =:proId ];
        product=pro.Product_AGN_AMI__c.replace(';',', ');  
        area=pro.Area_AGN_AMI__c.replace(';',', ');
        checkExistingRequest();
        
    }
    
     /**********************************************************************************************************************
    @ method:    	  contactPage 
    @ Version:        1.0
    @ Author:         Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:        Creates a case for the admins to be notified when an HCP clicks on Contact to gather more information 
					  on the project
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 06.06.2020 / Ayush Basak / Created the method
    ***********************************************************************************************************************/
    public void contactPage(){
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RECORDTYPE_NAME).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = caseRecordType,                               
                                Status = CASE_STATUS, 
                                Origin = CASE_ORIGIN, 
                                Clinical_Gallery_Project_AGN_AMI__c = proId, 
                                Subject = CASE_SUBJECT_PREFIX,
                                AccountId = accountRecord.Id, 
                                ContactId = contactRecord.Id, 
                                SuppliedEmail = contactRecord.Email); 
        List<User> admins=[SELECT Id 
                           FROM User 
                           WHERE isActive = true 
                           AND Id IN (SELECT UserOrGroupId 
                                      FROM GroupMember 
                                      WHERE Group.DeveloperName =: (ADMIN_GROUPS.get(userCountryCode)))];
        try{
            insert newCase;
            List<Task> tasks = new List<Task>();
            for(User u : admins)
            {
                Task task = new Task(Subject = CASE_SUBJECT_PREFIX + newCase.Title_Submitted_AGN_AMI__c, 
                                     Status = TASK_STATUS,
                                     Priority = TASK_PRIORITY,
                                     ReminderDateTime = datetime.now(), 
                                     IsReminderSet = true, 
                                     WhatId = newCase.Id, 
                                     ownerId = u.Id);
                tasks.add(task);
            }
            insert tasks;
            
            AGN_AMI_Case_Next.gotoNextStep(newCase.id);
            checkExistingRequest();
        }
        
        catch(Exception ex){
            system.debug('Exception : '+ex.getMessage());
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_CommunityDetail_Controller','contactPage');
        }
        
    }
    
     /**********************************************************************************************************************
    @ method:    	  checkExistingRequest 
    @ Version:        1.0
    @ Author:         Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:        Return Boolean based on whether HCP had requested more info on this project or not
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 06.06.2020 / Ayush Basak / Created the method
    ***********************************************************************************************************************/
    public void checkExistingRequest(){
        List<Case> pendingRequest = [Select id 
                                     from Case 
                                     where Account.Id = :accountRecord.Id 
                                     and RecordType.Name = :CASE_RECORDTYPE_NAME
                                     and Status != :CLOSED_STATUS 
                                     and Clinical_Gallery_Project_AGN_AMI__c = :proId];
        
        requestInPlace = (pendingRequest.isEmpty());
    }
    
    
	 /**********************************************************************************************************************
    @ method:    	  back 
    @ Version:        1.0
    @ Author:         PALLAVI  (pallavi.p3@cognizant.com)
    @ Purpose:        Redirecting to clinical gallery page
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 06.06.2020 / PALLAVI / Created the method
    ***********************************************************************************************************************/
    
    public PageReference back(){
        PageReference pr = new PageReference('/AMI/AGN_AMI_Community_Page');
        pr.setRedirect(true);
        return pr;   
    }
}