/**
 *
 * @Class Name: AGN_SPARK_ZincCode
 * @Created Date: 
 * @Description: Controller class for zinc code display Lightning component
 * @Author: 
 * @History     :  
 */
public Without Sharing class AGN_SPARK_ZincCode {  //added without sharing keyword for Spring '21 release
    
    /*
     * Method to fetch Zinc dode details from custom meta data
     */
    @AuraEnabled
    public static SPARK_Page_ZincCode_AGN__mdt getZincDetail(string pageName){
        SPARK_Page_ZincCode_AGN__mdt zincData = new SPARK_Page_ZincCode_AGN__mdt();        
        for(SPARK_Page_ZincCode_AGN__mdt znc : [SELECT Label,Date_of_Prep_AGN__c, Zinc_Code_AGN__c FROM SPARK_Page_ZincCode_AGN__mdt WHERE Label = :pageName LIMIT 1]){
            zincData = znc;
        }
        return zincData;
    }
}