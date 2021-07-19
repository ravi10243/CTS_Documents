/**
* 
* AGN_CustomerUnAssignOktaGroupsBatch
*
* @author          Avijit Gorai
* @date            30-June-2019 
* @description     This batch apex will unassign Okta Groups from GCSP OAM User(inactive/going to be inactive)
* 30-06-2019 - AG - Initial Version
**/

global class AGN_CustomerUnAssignOktaGroupsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    private List<User> userList;
    
    global AGN_CustomerUnAssignOktaGroupsBatch(List<User> users){
        this.userList = users;
    }
    
    global List<User> start(Database.BatchableContext context){
        return this.userList;
    }
    
    global void execute(Database.BatchableContext bc, List<User> records) {
        
        for(User u : records){
            try {
                String oktaUserId = !String.isEmpty(u.Account.Okta_Id_AGN__c) ? u.Account.Okta_Id_AGN__c : u.Contact.Okta_Id_AGN__c;
                if(!String.isEmpty(oktaUserId)){
                    //"00g1ejknx1aUagHTf1d8","00g1eox23lscKXT1c1d8"
                    String oktaGroupIds = (String)AGN_GCSP_Settings__c.getValues(u.Country_Code__c).get('Okta_SF_Community_Group_Id_AGN__c');
                    AGN_OktaUtils oUtil = new AGN_OktaUtils(u.Country_Code__c, '');
                    //Calling Okta service to unassign groups
                    oUtil.removeUserFromGroups(oktaGroupIds, oktaUserId);
                }
            }
            catch (Exception e) {         
                System.debug('Error : ' + e.getMessage());           
            }
        }
    }   
    
    global void finish(Database.BatchableContext bc){    
    }
}