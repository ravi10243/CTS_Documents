/**************************************************************************************************************************
@ Class:          AGN_AMI_Community_Form_Controller 
@ Version:        1.0
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        This is helper class for process builder, which is triggered when a case of AMI Clinical Gallery is approved
@ PMO:            CR-3257: Clinical Gallery Tab
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 15.06.2020 / Ayush Basak / Created the class.
@ Change history: 19.10.2020 / Ayush Basak / Updated the class to fetch products and treament area
***************************************************************************************************************************/
public class AGN_AMI_Community_Form_Controller 
{
    public static String CASE_RECORDTYPE_NAME = 'AGN AMI Clinical Gallery Request';
    public static String CASE_STATUS = 'Submitted';
    public static String CASE_SUBJECT_PREFIX = 'AMI Clinical Gallery Request - ';
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
        
    // Added Clinical Gallery Enhancment 
    private static String CATEGORY_FIELD = 'Category_AGN_AMI__c';
    private static String PRODUCT_FIELD = 'Product_AGN_AMI__c';
    private static String AREA_FIELD = 'Area_AGN_AMI__c';
    
    public Case newCase {get; set;}
    public Account accountDetail {get; set;}
    public Contact contactDetail {get; set;}
    public String userCountryCode {get; set;}
    public List<checkboxList> categoryList {get; set;}
    public String contactMode {get; set;}
    public String formIntro3 {get; set;}
    public String formSecondCheckBox{get; set;}
    // Added Clinical Gallery Enhancment 
    public List<checkboxList> productList {get; set;}
    public List<checkboxList> areaList {get; set;}
     public Boolean caseSubmitted{get; set;}
    
    /***********************************************************************************************************************
    @ Method:         constructor
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        Instantiates the case record that would created on form submission, fetch picklist values to be 
					  displayed on page
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the method.
	@ Change history: 19.10.2020 / Ayush Basak / Updated the method to invoke fetching of Product and Area values.
    ***********************************************************************************************************************/
    public AGN_AMI_Community_Form_Controller(){
        caseSubmitted =TRUE;
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RECORDTYPE_NAME).getRecordTypeId();
        newCase = new Case(RecordTypeId = caseRecordType, 
                           Status = CASE_STATUS, 
                           Origin = CASE_ORIGIN); 
        categoryList = fetchPicklist(CATEGORY_FIELD);
        productList = fetchPicklist(PRODUCT_FIELD);
        areaList = fetchPicklist(AREA_FIELD);
         AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        string userCountry =  userDetails.userCountryName;
        system.debug(userCountryCode);
        String downloadLink = AMI_Web_Visibility_Settings_AGN__c.getValues(userCountry).Download_AGN_AMI__c;
        String downloadLabel = '<b><a href=\'' + downloadLink + '\' target=\'_blank\'>' + System.Label.AGN_AMI_Clinical_Gallery_Intro3_Download + '</a></b>';
        formIntro3 = System.Label.AGN_AMI_Clinical_Gallery_Intro3.replace('{downloadLink}',downloadLabel);
        formSecondCheckBox = System.Label.AGN_AMI_Please_Tick_the_box_2.replace('{downloadLink}',downloadLabel);
    }
    
    /***********************************************************************************************************************
    @ Method:         fetchPicklist
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        fetch picklist values to be displayed on page
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the method.
	@ Change history: 19.10.2020 / Ayush Basak / Renamed and Updated the method to make the field name dynamic as parameter.
    ***********************************************************************************************************************/
    public List<checkboxList> fetchPicklist(String fieldName){
        List<checkboxList> options = new List<checkboxList>();
        
        //Schema.DescribeFieldResult fieldResult = Case.Category_AGN_AMI__c.getDescribe();
        Schema.DescribeFieldResult fieldResult =  Schema.SObjectType.Case.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new checkboxList(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    /***********************************************************************************************************************
    @ Method:         submitRequest
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        Creates case records when clicks on the submit button on the form as well as task records to send 
					  notifications to admin
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the method.
	@ Change history: 19.10.2020 / Ayush Basak / Updated - to inlcude area and product fields while creation 
					  and remove category field
    ***********************************************************************************************************************/
    public void submitRequest(){
        caseSubmitted =false;
        newCase.AccountId = accountDetail.Id;
        newCase.ContactId = contactDetail.Id;
        newCase.Subject = CASE_SUBJECT_PREFIX + newCase.Title_Submitted_AGN_AMI__c;
        
        /* Commented as part of Clinical Gallery Enhancement 
        newCase.Category_AGN_AMI__c = categories; */
        // Added as part of Clinical Gallery Enhancement - Start
        newCase.Area_AGN_AMI__c = getSelected(areaList);
        newCase.Product_AGN_AMI__c = getSelected(productList);
        // Added as part of Clinical Gallery Enhancement - End
        
        newCase.Mode_of_Contact_AGN_AMI__c = contactMode;
        newCase.SuppliedEmail = contactDetail.Email;
        
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
        }
        
        catch(Exception ex){
        	AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Community_Form_Controller','submitRequest');
        }
    } 
    
    /***********************************************************************************************************************
    @ Method:         getSelected
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        To return selected checkboxes in semi colon separated from list of inputs.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 19.10.2020 / Ayush Basak / Created method
    ***********************************************************************************************************************/
    public String getSelected(List<checkboxList> checkboxList){
        String selected = '';
        for(checkboxList checkbox : checkboxList){
            if(checkbox.checked){
                selected = selected + checkbox.value + ';';
            }
        }
        selected = selected.removeEnd(';');
        return selected;
    }
    
    /***********************************************************************************************************************
    @ Class:          checkboxList
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        This is wrapper class, created to support the display/capture of picklist in form of checkbox on the 
					  page
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the wrapper class.
	***********************************************************************************************************************/
    public class checkboxList{
        public Boolean checked {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public checkboxList(String label, String value){
            this.checked = false;
            this.label = label;
            this.value = value;
        }
        
    }
}