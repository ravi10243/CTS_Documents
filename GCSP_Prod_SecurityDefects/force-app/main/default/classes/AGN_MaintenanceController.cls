public class AGN_MaintenanceController{
    
    public String appName {get; set;}
    public String userCountryCode {get; set;} 
    public boolean isPortalUnderMaintenance {get;set;}
    
    public AGN_MaintenanceController(){        
    }
    
    public Boolean getSettings(){        
        if(appName == 'ICL'){
            system.debug('!!!Debug111!!!' + isPortalUnderMaintenance );
            isPortalUnderMaintenance = AGN_ICL_Settings__c.getValues(ApexPages.currentPage().getParameters().get('country')).AGN_ICL_Maintenance_Alert__c;          
        }
        else if(appName == 'Coolnet'){
            
            User currentUser = [Select id,Country_Code__c,Profile.UserLicense.Name from User where Id=: UserInfo.getUserId()];
			String countryValue;
            System.debug('current user --- '+ currentUser);
            if('Guest User License'.equals(currentUser.Profile.UserLicense.Name)){
                if(ApexPages.currentPage().getParameters().get('countryCode') != null){
                countryValue = [Select name from CoolNet_AGN_Redirection_Link__c where Country_AGN__c= :ApexPages.currentPage().getParameters().get('countryCode')].name;
                //isPortalUnderMaintenance = CoolNet_AGN_Redirection_Link__c.getValues(countryCode).AGN_Coolnet_Maintenance_Alert__c;
              }
            }
            else{
                if(AGN_MaintenanceController.isMenaCountry()){
                    User currentUserInfo = [Select Country_Code__c,MA_User_Country_Code_AGN__c  From User Where Id =: Userinfo.getUserid() AND isActive = TRUE LIMIT 1];
                    countryValue = [Select name from CoolNet_AGN_Redirection_Link__c where Country_AGN__c=: currentUserInfo.MA_User_Country_Code_AGN__c].name;
                    System.debug('Country value '+countryValue );
                }
                	
                else{
                    countryValue = [Select name from CoolNet_AGN_Redirection_Link__c where Country_AGN__c=: currentUser.Country_Code__c].name;
                }
                  
            }
            
            //String countryCode = [Select name from CoolNet_AGN_Redirection_Link__c where Country_AGN__c= :ApexPages.currentPage().getParameters().get('countryCode')].name;
            isPortalUnderMaintenance = CoolNet_AGN_Redirection_Link__c.getValues(countryValue).AGN_Coolnet_Maintenance_Alert__c;
            
        }
        else if(appName == 'OAM'){
            system.debug('!!!Prince!!!' + isPortalUnderMaintenance );
            User u = [select Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];             
            isPortalUnderMaintenance = OAM_User_Settings__c.getValues(u.Country_Code__c).AGN_OAM_Maintenance_Alert__c;        
        }
        return isPortalUnderMaintenance;  
    } 
    
     public static boolean isMenaCountry(){
        List<User> currentUserInfo = [Select Country_Code__c From User Where Id =: Userinfo.getUserid()];
        return ('XM'.equals(currentUserInfo[0].Country_Code__c))? true:false;
    }
}