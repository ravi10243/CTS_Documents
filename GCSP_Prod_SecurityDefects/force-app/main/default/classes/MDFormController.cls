/*******************************************************************************
* @author         :    Rizwan Mahmood
* @date           :    April 2019
* @description    :    Controller for MD Form object to be ued for ListViewMDForm
* @Revisions      :    
*******************************************************************************/
public class MDFormController {
            /*******************************************************************************
    * @author         :    Rizwan Mahmood
    * @date           :    April 2019 
    * @description    :    Get all the MD Forms
    * @param          :    None 
    * @return         :    List of all MDForm__c 
    *******************************************************************************/
	@AuraEnabled
    public static List<MDForm__c> GetMDForms() {
		return [SELECT id, name, status__c FROM MDForm__c ORDER BY name ASC];
    }
    
    /*******************************************************************************
    * @author         :    Gunwant Patidar
    * @date           :    April 2019 
    * @description    :    get Record Type id of MD form
    * @param          :    name of record type 
    * @return         :    record type id of MDForm__c 
    *******************************************************************************/
	@AuraEnabled
    public static Id getMdFormRecordTypeId(string recTypeDevName) {
		return [SELECT Id FROM RecordType WHERE DeveloperName =: recTypeDevName].Id;
    }
}