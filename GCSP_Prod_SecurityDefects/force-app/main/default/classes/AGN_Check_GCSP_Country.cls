/*-------------------------------------------------------------------------------------------------------
* @author         Namrata Kundu
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        
* @testClass     
* @Class Name    AGN_Check_GCSP_Country
* --------------------------------------------------------------------------------------------------------
* @description -  
*/
global class AGN_Check_GCSP_Country {

    webservice static Boolean isGCSPCountry(String country){
        List<AGN_GCSP_Settings__c> GCSPSettingList = AGN_GCSP_Settings__c.getall().values();
        for(AGN_GCSP_Settings__c gcspCountry : GCSPSettingList){
            if(country == gcspCountry.Name){
                if(gcspCountry.Community_Base_URL_AGN__c != NULL && gcspCountry.Okta_Base_URL_AGN__c != NULL){
                    return true; 
                }
            }
         }
        return false;
     }
    
    webservice static string callFlowMethod(String accountId, String country, String opptyId){
        String paramString = 
            'accountId=' + accountId +
            '&countryCode=' + country +
            '&retURL=/' + opptyId;
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        String retunUrl = baseUrl+'/flow/AGN_GCSP_NewRegistrationFlow?'+paramString;
        
        return retunUrl;
    }
}