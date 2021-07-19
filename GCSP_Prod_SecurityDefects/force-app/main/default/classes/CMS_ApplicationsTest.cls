@isTest
public class CMS_ApplicationsTest {

	@isTest
    public static void test_getAllApplications(){
              	
        MDApplication__c mdApp = new MDApplication__c(MetadataDeveloperName__c='Test name');
        insert mdApp;
        
        LEXApplication__c lexApp = new LEXApplication__c(MD_Application__c= mdApp.Id);
        insert lexApp;
        
        CMS_Applications.getAllApplications();
    }
    @isTest
    public static void test_getApplicationById(){
        MDApplication__c mdApp = new MDApplication__c(MetadataDeveloperName__c='Test name');
        insert mdApp;
        
        LEXApplication__c lexApp = new LEXApplication__c(MD_Application__c= mdApp.Id);
        insert lexApp;
        
        CMS_Applications.getApplicationById(lexApp.Id);
    }
    @isTest
    public static void test_getApplicationForms(){
         MDApplication__c mdApp = new MDApplication__c(MetadataDeveloperName__c='Test name');
        insert mdApp;
        
        LEXApplication__c lexApp = new LEXApplication__c(MD_Application__c= mdApp.Id);
        insert lexApp;
        
        CMS_Applications.getApplicationForms(lexApp.Id);
    }
    @isTest
    public static void test_getMDForm(){
        LEXForm__c lexForm = new LEXForm__c();
        insert lexForm;
        CMS_Applications.getMDForm(lexForm.Id);
   
    }
    @isTest
    public static void test_updateFormStatus(){
       LEXForm__c lexForm = new LEXForm__c();
       insert lexForm;
       CMS_Applications.updateFormStatus(lexForm.Id);
    }
}