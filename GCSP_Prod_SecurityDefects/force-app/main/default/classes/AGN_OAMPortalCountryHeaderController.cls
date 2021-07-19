public without sharing class AGN_OAMPortalCountryHeaderController {
    
    @AuraEnabled(cacheable=true)
    public static List<Object> fetchCountryList(){ 
        List<Country_vod__c> options = new List<Country_vod__c>();
        List<Object> optionsObject = new List<Object>();
        Set<String> uniqueCountry = new Set<String>();
        List<Customer_Type_Configuration_AGN__c> customerTypeConfigList = customerTypeConfig();        
        //system.debug('user country code : '+AGN_OAMConstant.USERCOUNTRYCODE);
        if(customerTypeConfigList !=null && !customerTypeConfigList.isEmpty()){
            if(AGN_OAMConstant.USERCOUNTRYCODE.equalsIgnoreCase('AN')){ // country code of Australia is AN (as per Veeva) not AU
                for(Customer_Type_Configuration_AGN__c custConfig : customerTypeConfigList)
                {
                    //system.debug('Customer_Country_AGN__r.Name : '+custConfig.Customer_Country_AGN__r.Name);
                    uniqueCountry.add(custConfig.Customer_Country_AGN__r.Name);            
                }
            }           
            else{
                for(Customer_Type_Configuration_AGN__c custConfig : customerTypeConfigList)
                {
                    //system.debug('custConfig.Country_Code_AGN__c : '+custConfig.Country_Code_AGN__c);
                    uniqueCountry.add(custConfig.Country_Code_AGN__c);            
                }
            }
            System.debug('uniqueCountry : '+uniqueCountry.size());
            
            options = [SELECT Id,
                       Alpha_2_Code_vod__c,
                       AGN_Country_Name__c
                       FROM Country_vod__c
                       WHERE Alpha_2_Code_vod__c IN:uniqueCountry ORDER BY AGN_Country_Name__c];
            
            optionsObject.add(options);
            optionsObject.add(customerTypeConfigList);
        }
        return optionsObject;
    }
    
    private static List<Customer_Type_Configuration_AGN__c> customerTypeConfig() {
        
        return [SELECT 
                Account_Record_Type_AGN__c,
                Category_AGN__c,
                Country_Code_AGN__c,
                Customer_Group_AGN__c ,
                Sub_Category__c,
                Specialty_Allergan_AGN__c,
                Sub_Specialty_Allergan_AGN__c,
                Category_Label_AGN__c,
                Sub_Category_Label_AGN__c,
                Province_AGN__c,
                Customer_Country_AGN__r.Name,
                Product_Interest_AGN__c 
                FROM Customer_Type_Configuration_AGN__c WHERE Country_Code_AGN__c=:AGN_OAMConstant.USERCOUNTRYCODE AND Applicable_For_Online_Registration_AGN__c = True];
    }    
   
}