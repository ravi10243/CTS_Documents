//public class AGN_ICL_LocatorEmailWrapper {
public without sharing class AGN_ICL_LocatorEmailWrapper {  /* added without sharing for Spring'21 Release Updates */
    @AuraEnabled @InvocableVariable public Locator_Listing_AGN__c locObj;
    @AuraEnabled @InvocableVariable public String templateType;
    @AuraEnabled @InvocableVariable public String templateName;
    @AuraEnabled @InvocableVariable public String CountryCode;
}