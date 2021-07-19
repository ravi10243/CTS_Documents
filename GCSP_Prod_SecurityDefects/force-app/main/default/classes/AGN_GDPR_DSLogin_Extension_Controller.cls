/* 
@Class name : AGN_GDPR_DSLogin_Extension_Controller
@Createdate : 12.07.2019
@modified date: 30.03.2020
@Author : GDPR Case management Project Team
@Description: It is controller class to check if Portal user is active and extends days of access based on number of requests.
@Change done: DSRm Release 2 , requirement No: DSRm 25
*/


public class AGN_GDPR_DSLogin_Extension_Controller 
{
    public string selectedLang{get;set;}
    public List<DS_Email_Verification_GDPR_AGN__c> dsEmailVerify { get; set;}
    public String dsEmailVerifyID { get; set; }
    public List<Case> caseObj { get; set; }
    public Boolean isExtended {get; set;}
    public Boolean alreadyExtended {get; set;}
    
    public AGN_GDPR_DSLogin_Extension_Controller(){
        
    }
    
    public void doExtendLogin()
    {
        isExtended =  false;
        alreadyExtended = false;
        dsEmailVerifyID = apexpages.currentpage().getparameters().get('RecordInfo');
        User objUser = new User();
        system.debug('==> The Username is: ' + dsEmailVerifyID);
        if(dsEmailVerifyID != null)
        {
            Integer dateToExtend;
            List<AGN_GDPR_LoginExtension__c> lstCSLogin = new List<AGN_GDPR_LoginExtension__c>();
            lstCSLogin = AGN_GDPR_LoginExtension__c.getall().values();
            
            
            dateToExtend = Integer.valueOf(lstCSLogin[0].Days_to_Extend_AGN_GDPR__c);
            
            List<user> lstUser = [Select Id, IsActive, Username, Access_Till_AGN_GDPR__c, Number_of_Notification_AGN_GDPR__c,First_Notification_AGN_GDPR__c,Second_Notification_AGN_GDPR__c 
                                  from User where Username =: dsEmailVerifyID];
            system.debug('==> The User details are: ' + lstUser);                        
            if(lstUser[0].IsActive == true )
            {
                isExtended = true;
                alreadyExtended = false;
                objUser.Id = lstUser[0].Id;
                system.debug('11==> The User details are: ' + lstUser[0].Access_Till_AGN_GDPR__c);
                system.debug('22==> The User details are: ' + lstUser[0].First_Notification_AGN_GDPR__c);
                system.debug('33==> The User details are: ' + lstUser[0].Second_Notification_AGN_GDPR__c);
                system.debug('44==> The User details are: ' + lstUser[0].Number_of_Notification_AGN_GDPR__c);
                if(lstUser[0].Access_Till_AGN_GDPR__c == null)
                {                   
                    objUser.Access_Till_AGN_GDPR__c = Date.today();
                }
                else if (lstUser[0].First_Notification_AGN_GDPR__c == true && lstUser[0].Second_Notification_AGN_GDPR__c == false && (lstUser[0].Number_of_Notification_AGN_GDPR__c == '0' ||lstUser[0].Number_of_Notification_AGN_GDPR__c == '1') )
                {
                    objUser.Access_Till_AGN_GDPR__c = lstUser[0].Access_Till_AGN_GDPR__c.addDays(dateToExtend);
                    objUser.Number_of_Notification_AGN_GDPR__c = '1';
                }
                else if(lstUser[0].First_Notification_AGN_GDPR__c == true && lstUser[0].Second_Notification_AGN_GDPR__c == true && lstUser[0].Number_of_Notification_AGN_GDPR__c == '1')
                {
                    objUser.Access_Till_AGN_GDPR__c = lstUser[0].Access_Till_AGN_GDPR__c.addDays(dateToExtend);
                    objUser.Number_of_Notification_AGN_GDPR__c = '2';
                }
                else
                {
                    alreadyExtended = true;
                    isExtended = false;
                }
                update objUser;
            }
            
        }
        
    }
}