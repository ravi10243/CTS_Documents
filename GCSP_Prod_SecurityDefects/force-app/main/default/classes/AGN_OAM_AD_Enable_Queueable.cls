/**
* @className      AGN_OAM_AD_Enable_Queueable
* @author          Ravi
* @version         1.0
* @date            27-Nov-2019 
* @description     while Enable portal access to the customer this Queueable job is Create Portal users and Generate Emails to the Customers for password Reset. 
* @Current Version 1.0
*/

global class AGN_OAM_AD_Enable_Queueable implements Queueable, Database.AllowsCallouts {
    
    private list<Contact> conList;
    private String countryCode;
    private String userLocal;
    private String crRecordId;
    private String suffixUserName;
    private String existingUserList;
    private boolean isgenerateEmail = false;
    private Map<String, Boolean> isPasswordResetContactMap;
    
    public AGN_OAM_AD_Enable_Queueable(list<Contact> conList, String userLocal, String countryCode, String crRecordId, String existingUserList, String suffixUserName, Map<String, Boolean> isPasswordResetContactMap) {
        this.conList = conList;
        this.countryCode = countryCode;
        this.userLocal = userLocal;
        this.crRecordId = crRecordId;
        this.suffixUserName = suffixUserName;
        this.existingUserList = existingUserList;
        this.isPasswordResetContactMap = isPasswordResetContactMap;
        
    } 
    public AGN_OAM_AD_Enable_Queueable(list<Contact> conList, String userLocal, String countryCode, Map<String, Boolean> isPasswordResetContactMap, String crRecordId) {
        this.conList = conList;
        this.countryCode = countryCode;
        this.userLocal = userLocal;
        this.isgenerateEmail = true;
        this.isPasswordResetContactMap = isPasswordResetContactMap;
        this.crRecordId = crRecordId;
    } 
    
    public void execute(QueueableContext context) {  
        
        if(!isgenerateEmail){ //1st time job execution
            
            //create community User 
            AGN_GCSP_OktaProcessNew.createCommunityUser(JSON.serialize(conList), userLocal, countryCode, crRecordId, existingUserList, suffixUserName);
            
            //Calling the job one more time for Email generate to the Customers.
            System.enqueueJob(new AGN_OAM_AD_Enable_Queueable(conList,userLocal, countryCode,isPasswordResetContactMap,crRecordId));
            
        }else{
            // 2nd time job execution 
            for(Contact customerContact : conList){
                //Check email triggerd or not for the users
                if(isPasswordResetContactMap.get(customerContact.Id)){
                    customerContact.Community_Okta_Password_Reset_Token_AGN__c = AGN_GCSP_OktaProcessNew.sendExpiryLinkChangePassword(customerContact, userLocal, countryCode); // generate the mail to customer for password resset 
                }
                                    
            }  
            
            //update the Contact records with password reset token and okta id in DataBase.
            Database.SaveResult[] results = Database.Update(conList, false);
            
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess() || Test.isRunningTest()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                 
                        System.debug('Error Message ::::::>>' + err.getStatusCode() + '::::: ' + err.getMessage() + ':::::: ' + err.getFields());
                        
                        String errorId = AGN_OAM_LogService.getRandom(32);                        
                        //logging exception
                        OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                            ErrorId_AGN__c = errorId,               
                            ExceptionMessage_AGN__c = err.getMessage(),                       
                            RunningUserId_AGN__c = UserInfo.getUserId(),
                            Data_AGN__c = err.getStatusCode() + '-' + err.getFields(),
                            //Reference_Email_AGN__c = customerContact.Email,
                            Allergan_Customer_Registration_AGN__c = crRecordId
                        );            
                        //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
                        EventBus.publish(log);
                    }
                    
                }
            }
            
        }
        
    }
    
}