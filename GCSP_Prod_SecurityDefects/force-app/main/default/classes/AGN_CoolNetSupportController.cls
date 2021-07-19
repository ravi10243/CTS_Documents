/******************************************************************************
    Name        :    AGN_CoolNetSupportController 
    Purpose     :    Custom Controller for AGN_CoolNetSupportPage
    Created By  :    Cognizant 
    Created     :    13/02/2018
    Modified    :    01/10/2018
******************************************************************************/

public class AGN_CoolNetSupportController {
    public List<Account> supportList;
    public String supportName {get; set;}
    public String supportEmail {get; set;}
    public String supportRegion {get; set;}
    Id userID;
    public List<Support_Page_AGN__c> linkofcountrycode;
    public  List<USer> usercountrycode;
    public String usercc;
    public String linkusercc {get; set;}
    public boolean linkacc {get;set;}
    /******************************************************************************
    Name        :    AGN_CoolNetSupportController_with section 
    Purpose     :    Constructor
    Return      :    void 
    Params      :    NA
    ******************************************************************************/
    public AGN_CoolNetSupportController ()
    {
        userID = [Select contact.AccountId from user where id =:Userinfo.getUserid()].contact.AccountId;
        system.debug('Arijit :' + userID);
        ////usercountrycode=[select country_code_agn__c from user where id=:Userinfo.getUserid()];
        //usercountrycode=[select Country_Code__c from user where id=:Userinfo.getUserid()]; //Commented by Avijit, reason : MEA Rollout
        ////usercc =usercountrycode.get(0).country_code_agn__c;
        //usercc =usercountrycode.get(0).Country_Code__c; //Commented by Avijit, reason : MEA Rollout
        usercc = AGN_CoolNetUtils.getUserCountryCode(); //Added by Avijit, reason : MEA Rollout    
        linkofcountrycode=[select Link_AGN__c,Active_AGN__c from Support_Page_AGN__c where name=:usercc];
        if(linkofcountrycode !=null ){     
          if(linkofcountrycode.size()>0 ){
        linkusercc=linkofcountrycode.get(0).link_AGN__c;
        linkacc=linkofcountrycode.get(0).Active_AGN__c;
          }
        }
        
        //userID = [Select contact.AccountId from user where id ='0053B000001QL1w'].contact.AccountId;
        supportList = [select Practice_Development_Manager_Lookup_AGN__r.Name,
                            PSS_Territory_AGN__c,
                            Practice_Development_Manager_Lookup_AGN__r.Email
                            from Account where id =: userID];
        
        if(supportList.size()>0)
        {
            supportName = supportList[0].Practice_Development_Manager_Lookup_AGN__r.Name;
            supportEmail = supportList[0].Practice_Development_Manager_Lookup_AGN__r.Email;
            supportRegion = supportList[0].PSS_Territory_AGN__c;
        }
        system.debug(Userinfo.getUserid());
        system.debug(supportName+'___'+supportEmail+'___'+supportRegion);
        system.debug(userId);
        system.debug('Query Result :' + supportList);
        //system.debug(usercountrycode);
        system.debug(usercc);
        system.debug(linkusercc);
    }
}