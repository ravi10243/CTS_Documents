/**************************************************************************************************************************
@ Class:          AGN_AMI_Community_page_Controller 
@ Version:        1.1
@ Author:         Sujan Guha (sujan.guha@cognizant.com) / Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        This is helper class for process builder, which is triggered when a case of AMI Clinical Gallery is approved
@ PMO:            CR-3257: Clinical Gallery Tab
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 15.06.2020 / Sujan Guha / Created the class.
@ Change history: 15.06.2020 / Ayush Basak / Added new methods.
***************************************************************************************************************************/

public without sharing class AGN_AMI_Community_page_Controller{
    
    public static String PROJECTSTATUS = 'Published';
    // Added Clinical Gallery Enhancment 
    private static String CATEGORY_FIELD = 'Category_AGN_AMI__c';
    private static String PRODUCT_FIELD = 'Product_AGN_AMI__c';
    private static String AREA_FIELD = 'Area_AGN_AMI__c';
    
    
    public String userLanguage {get; set;}
    public Account accRecord {get; set;}
    public Contact conRecord {get; set;}
    public String userCountryName {get;set;}
    public List<CheckboxList> categoryFormList {get; set;}
    public List<CheckboxList> categoryFilterList {get; set;}
    public Boolean isFilterEmpty {get; set;}
    public List<AMI_Project_AGN__c> project {get; set;}
    public String projectId {get; set;}
    public List<AMI_Project_Account_Relationship_AGN__c > projectRelation;
    // Added Clinical Gallery Enhancment 
    public List<checkboxList> productList {get; set;}
    public List<checkboxList> areaList {get; set;}
    
    /**********************************************************************************************************************
    @ Constructor:    AGN_AMI_Community_page_Controller 
    @ Version:        1.0
    @ Author:         Sujan Guha (sujan.guha@cognizant.com)
    @ Purpose:        Initialises the class members.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Sujan Guha / Created the constructor
    ***********************************************************************************************************************/
    
    public AGN_AMI_Community_page_Controller(){
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        accRecord = userDetails.accountRecord;
        conRecord = userDetails.contactRecord;
        userCountryName =  userDetails.userCountryName;
        categoryFilterList = fetchPicklist(CATEGORY_FIELD);
        productList = fetchPicklist(PRODUCT_FIELD);
        areaList = fetchPicklist(AREA_FIELD);
        getProjectInfo();
    }
    

    public Boolean getProjectExists(){
        List<AMI_Project_AGN__c> project = [SELECT ID 
                                            FROM AMI_Project_AGN__c 
                                            WHERE Published_Status_AGN_AMI__c = :PROJECTSTATUS 
                                            AND Country_AGN__r.Name = :userCountryName];
        return project.isEmpty();
    }    
    
    public Boolean getProjectExistsFilter(){
        List<AMI_Project_AGN__c> project = [SELECT ID 
                                            FROM AMI_Project_AGN__c 
                                            WHERE Published_Status_AGN_AMI__c = :PROJECTSTATUS 
                                            AND Country_AGN__r.Name = :userCountryName];
        if(!project.isEmpty()){
            return true;
        }
        else{
            return false;
        }
    }   
    
    
    /***********************************************************************************************************************
    @ Method:         refreshProjects
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        refreshes project list view based on checkbox selection.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the method.
    ***********************************************************************************************************************/
    
    public void refreshProjects(){
        getProjectInfo();
    }
    /***********************************************************************************************************************
    @ Method:         getProjectInfo
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        fetches published project for list view and also
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the method.
    @ Change history: 20.10.2020 / Ayush Basak / Updated the method to include product and area filter instead of category.
    ***********************************************************************************************************************/
    
    public void getProjectInfo(){
        system.debug('*******getProjectInfo********************');
        string areas = '';
        for(CheckboxList area : areaList){
            if(area.checked){
                areas = areas + '\'' + String.escapeSingleQuotes(area.value) + '\',';
            }   
        }
        areas = areas.removeEnd(','); 
        string products = '';
        for(CheckboxList product : productList){
            if(product.checked){
                products = products + '\'' + String.escapeSingleQuotes(product.value) + '\',';
            }    
        }
        products = products.removeEnd(','); 
        boolean productFilter = products != '';
        boolean areaFilter = areas != '';
        system.debug(products + areas);
        if(productFilter || areaFilter) {
            String qry='SELECT ID,Product_AGN_AMI__c,Area_AGN_AMI__c,Category_AGN_AMI__c,Description_AGN_AMI__c,Title_AGN_AMI__c,Preview_Description_AGN_AMI__c, Account_AGN_AMI__r.Name,Image_AGN_AMI__c,HCP_Image_AGN_AMI__c ' 
                + 'FROM AMI_Project_AGN__c ' 
                + 'WHERE Published_Status_AGN_AMI__c = \'Published\' ' 
                + 'AND Country_AGN__r.Name = \'' + String.escapeSingleQuotes(userCountryName) + '\' '
                + ((productFilter)?'AND Product_AGN_AMI__c INCLUDES(' + products + ') ' : '')
                + ((areaFilter)?'AND Area_AGN_AMI__c INCLUDES(' +  areas + ') ' : '')
                + 'ORDER BY Published_Date_AGN_AMI__c DESC NULLS LAST';
            project=Database.query(qry);
            
          for ( AMI_Project_AGN__c temp:project ){
                temp.Area_AGN_AMI__c = temp.Area_AGN_AMI__c.replace(';',',');
                temp.Product_AGN_AMI__c = temp.Product_AGN_AMI__c.replace(';',',');
            }

            
            isFilterEmpty = !(project.size()>0);
        } 
        else {
            project= new List<AMI_Project_AGN__c>();
            isFilterEmpty = !(project.size()>0);
        }
        
        system.debug(isFilterEmpty);
    }
    
    /***********************************************************************************************************************
    @ Method:         redirect
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        redirects Portal users to CommunityDetail page with appending Project Id to the url.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the method.
    ***********************************************************************************************************************/
    public PageReference redirect(){
         PageReference pageRef1 = new PageReference(System.Label.AGN_AMI_CG_Detail_Page);
        return pageRef1;  
    }
    
        
    public PageReference redirectProject(){
        System.debug('****redirect been called');
        projectId = ApexPages.currentPage().getParameters().get('projectId');
        System.debug('****sw ProjectId:**** ' +projectId);
       //PageReference pageRef = new PageReference('http://opsdev-allergancommunityeu.cs102.force.com/AMI/AGN_AMI_CommunityDetail_page?projectId='+projectId);
       
        PageReference pageRef = new PageReference(System.Label.AGN_AMI_CG_Detail_Page);
        pageRef.setRedirect(true);
        pageRef.getParameters().put('projectId',projectId);
        AGN_AMI_Community_page_Controller.updateViewCounts(accRecord.Id, projectId);
        return pageRef;    
    }
 /***********************************************************************************************************************
    @ Method:         fetchPicklist
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        Fetches Category values for Clinical Gallery project from Case. 
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
            options.add(new CheckboxList(f.getLabel(), f.getValue()));
        }       
        return options;
    }

    /***********************************************************************************************************************
    @ Method:         updateViewCounts
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        Updates project view count in AMI_Project_AGN__c and AMI_Project_Account_Relationship_AGN__c objects.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the method.
    ***********************************************************************************************************************/  
    
    public static void updateViewCounts(String accId, String projectId){
        System.debug('Project:  '+accId +projectId);
        
        AMI_Project_AGN__c project = [SELECT Id, Project_View_Count_AGN_AMI__c,Account_AGN_AMI__c FROM AMI_Project_AGN__c WHERE Id = :projectId LIMIT 1];
       
        project.Project_View_Count_AGN_AMI__c = (project.Project_View_Count_AGN_AMI__c != null ) ? (project.Project_View_Count_AGN_AMI__c + 1) : 1;
        
        List<AMI_Project_Account_Relationship_AGN__c> trackers = [SELECT Id, View_Count_AGN_AMI__c 
                                                           FROM AMI_Project_Account_Relationship_AGN__c
                                                           WHERE Account_AGN_AMI__c =:accId AND AMI_Project_AGN__c =: projectId];
        AMI_Project_Account_Relationship_AGN__c tracker;
        if(trackers.isEmpty()){
            tracker = new AMI_Project_Account_Relationship_AGN__c(Account_AGN_AMI__c = accId, 
                                                                  AMI_Project_AGN__c = projectId, 
                                                                  View_Count_AGN_AMI__c = 1);
        }
        else{
            tracker = trackers[0];
            tracker.View_Count_AGN_AMI__c++;
        }
        
        try{
            upsert tracker;
            update project;
        }
        catch(Exception ex){
            system.debug('Exception : '+ex.getMessage());
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Community_page_Controller','updateViewCounts');
        }
    }
/***********************************************************************************************************************
    @ Class:          CheckboxList
    @ Version:        1.0
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    @ Purpose:        Wrapper Class and Controller to initialize and display checkbox field Values
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2020 / Ayush Basak / Created the method.

***********************************************************************************************************************/    

    public class CheckboxList{
        public Boolean checked {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public CheckboxList(String label, String value){
            this.checked = false;
            this.label = label;
            this.value = value;
        }
    }
}