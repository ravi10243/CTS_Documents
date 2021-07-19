/*-------------------------------------------------------------------------------------------------------
* @author         Namrata Kundu
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        
* @testClass     
* @Class Name    GCSP_Batch_Update_User_On_Case_Close_AGN
* --------------------------------------------------------------------------------------------------------
* @description -  Case should be automatically closed after 30 days, which are in registration step 1 
                  and deactivate guest user.

*/

public class GCSP_Batch_Update_User_On_Case_Close_AGN implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext context) {
         Integer caseCloseCount= Integer.valueOf(AGN_GCSP_Settings__c.getValues('AN')?.get('days_to_close_case__c'));
         return Database.getQueryLocator([SELECT Email_AGN__c,Id,Case_AGN__c FROM Allergan_Customer_Registration_AGN__c WHERE Online_Registration_Step_AGN__c <= '4'AND Online_Registration_Status_AGN__c !='Completed' AND Country_Code_AGN__c IN ('AU','AN','NZ') AND GCSP_Case_Age_Count_Agn__c = :caseCloseCount]);
    }
    
    public void execute(Database.BatchableContext context, List<Allergan_Customer_Registration_AGN__c> scope){  
        system.debug('## Inside GCSP_Batch_Close_Case_After_30Days_AGN.execute()'+scope);
        List<String> userNameList = new List<String>();
        String userName;
        for(Allergan_Customer_Registration_AGN__c registrationObj: scope){
            userName = registrationObj.Email_AGN__c +'.agn';
            userNameList.add(userName);
        }
       system.debug('## List of usernames to deactivate'+userNameList);
       List<User> listOfUsers =[SELECT Email,Id,IsActive,Username,Country_Code__c FROM User WHERE Profile_Name_vod__c = 'Allergan Customer Community (ANZ)' AND IsActive = true and Username IN :userNameList];
       Map<id,User> userMap = new Map<id,User>();
       String dateValue = string.valueof(System.now());
       dateValue = dateValue.replaceAll('\\D','');
       System.debug('list of users count'+listOfUsers.size()); 
       for(User userObj:listOfUsers){
           userObj.IsActive = false;
           System.debug('system.now format'+dateValue); 
           userObj.Username = 'INVALIDUSER'+dateValue+userObj.Username;
           userMap.put(userObj.ID,userObj);
		   System.debug('Mail sent'+userMap);
        }
		if(userMap.size()>0){
			update userMap.values();
           System.debug('UserMap updated successfully');  
		}
        System.debug('Outside if');  
    }
    public void finish(Database.BatchableContext context) {
    }

}