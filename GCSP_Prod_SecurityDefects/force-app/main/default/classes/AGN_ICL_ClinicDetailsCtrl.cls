//public class AGN_ICL_ClinicDetailsCtrl {
public without sharing class AGN_ICL_ClinicDetailsCtrl { /* added without sharing for Spring'21 Release Updates */  
    @AuraEnabled
    public static Account fetchClinicDetails(Id userIds){
        User usr = [Select Id from User where Id =:userIds];
        Account acc = [select Id,FirstName,LastName,PersonEmail,Phone from Account where Primary_Parent_vod__c =:userIds];//usr.contact.id
        //Account acc = [select Id,FirstName,LastName,PersonEmail,Phone from Account where Id=:usr.account.Id];
        return acc;  
    }
     @AuraEnabled
 public static List < String > getselectOptions(sObject objObject, string fld) {
  List < String > allOpts = new list < String > ();
  // Get the object type of the SObject.
  Schema.sObjectType objType = objObject.getSObjectType();
 
  // Describe the SObject using its object type.
  Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
 
  // Get a map of fields for the SObject
  map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
 
  // Get the list of picklist values for this field.
  list < Schema.PicklistEntry > values =
   fieldMap.get(fld).getDescribe().getPickListValues();
 
  // Add these values to the selectoption list.
  for (Schema.PicklistEntry a: values) {
   allOpts.add(a.getValue());
  }
  allOpts.sort();
  return allOpts;
 }
 @AuraEnabled
    public static Locator_Listing_AGN__c fetchClinicDetails1(){ 
        
        Locator_Listing_AGN__c loc = [select Id,Name,Brand_AGN__c,Clinic_Experience_AGN__c,Enquiriy_Email_AGN__c,Offer_Evenings_AGN__c,Website_AGN__c,Google_Url_AGN__c,Street_AGN__c,City_AGN__c,Country_AGN__c,Zip_Code_AGN__c,State_Providence_Region_AGN__c,Monday_Close_Hours_AGN__c,Monday_Open_Hours_AGN__c from Locator_Listing_AGN__c where Account_AGN__c='0015E00000iG1tF'];
        return loc;  
    }  
}