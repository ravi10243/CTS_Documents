// AGN_DCR2_Launch_Create //

public without sharing class AGN_DCR2_Launch_Create {
    
    // ======== Public Variables ======== //
    public string PramAccType {get;set;}
    public string PramAccManaged {get;set;}
    public string PageMsg {get;set;}
    public boolean PersonAccountOptions {get;set;}
    public boolean BusinessAccountOptions {get;set;}
    public boolean ShowOutboundSearchForm {get; set;}
    public Account Acc {get; set;}
    public User LoggedInUser;
    public DCR_Config_Settings_AGN__c dcrSetting;


// ================================================================ //
    
    public AGN_DCR2_Launch_Create() {
        system.debug('== [AGN_DCR2_Launch_Create].[Constructor] ==');
        PramAccType = ApexPages.currentPage().getParameters().get('acctype');        // "Business" or "Person" Account
        PramAccManaged = ApexPages.currentPage().getParameters().get('managed');     // "Self" or "Data" Managed
        PersonAccountOptions = false;
        BusinessAccountOptions = false;
        ShowOutboundSearchForm = false;
        
        Acc = new Account();
        
    }
    
    
// ================================================================ //
    
    public PageReference LaunchDcrCreation() {
        system.debug('== [AGN_DCR2_Launch_Create].[LaunchDcrCreation].PramAccType =='+PramAccType+' ; PramAccManaged =='+PramAccManaged);
        
        dcrSetting = DCR_Config_Settings_AGN__c.getOrgDefaults();
        LoggedInUser = [SELECT Country_Code__c,Cluster_User_AGN__c,MA_Medical_Affairs_AGN__c FROM User WHERE Id = :UserInfo.getUserId()];
                system.debug('== [Query:LoggedInUser] =='+LoggedInUser);
        
        // ======== Launching Old DCR if Enhanced DCR is not deployed to the Market ======== //
        if(!(dcrSetting.DCR_Deployed_CountryCodes__c).contains(LoggedInUser.Country_Code__c)) {
            return new PageReference('/apex/AGN_DCR_Admin').setRedirect(true);
        }

        // ======== Fetching DCR Config Settings ======== //
        List<DCR_Configuration_Settings_AGN__c> dcrConfigSetting = AGN_DCR2_Utilities.FetchDCRConfigSettings(UserInfo.getUserId());
        
        if(dcrConfigSetting.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.AGN_DCR2_No_Setting_Found));
            // == 'No DCR Settings found.'
            return null;
        }
        
        // ======== If the information whether to load Self or Data Provider Managed is NOT available in the URL ======== //
        if(PramAccManaged == null) {
            system.debug('== [AGN_DCR2_Launch_Create].[LaunchDcrCreation].[PramAccManaged is null] ==');
            
            // ======== Giving Options to User if the User has Permission to Work on Both Self and Data Provider Managed DCRs ======== //
            if(dcrConfigSetting[0].Company_Managed_AGN__c == true && dcrConfigSetting[0].Data_Provider_Managed_AGN__c == true) {
                if(HasPermission(dcrConfigSetting[0])) {
                    if(PramAccType == 'person')
                        PersonAccountOptions = true;
                    else if(PramAccType == 'business')
                        BusinessAccountOptions = true;
                } else {
                    PageMsg = System.Label.AGN_DCR2_Creation_Not_Allowed_for_This_Type;
                    // == 'You are not allowed to create this type of DCR.'
                }
                return null;
            }
            
            // ======== Loading the DCR Page for New Account Creation if User Does Not have Permission for both Self and Data Provider Managed DCRs ======== //
            else {
                if(dcrConfigSetting[0].Company_Managed_AGN__c == true)
                    PramAccManaged = 'self';
                else
                    PramAccManaged = 'data';
                
                if(HasPermission(dcrConfigSetting[0])) {
                    return LaunchNewDcrPage();
                }
                else {
                    PageMsg = System.Label.AGN_DCR2_Creation_Not_Allowed_for_This_Type;
                    // == 'You are not allowed to create this type of DCR.'
                    return null;
                }
            }
            
        }
        
        // ======== If the information whether to load Self or Data Provider Managed is available in the URL ======== //
        else {
            system.debug('== [AGN_DCR2_Launch_Create].[LaunchDcrCreation].[PramAccManaged not null] ==');
            if(HasPermission(dcrConfigSetting[0])) {
                return LaunchNewDcrPage();
            }
            else {
                PageMsg = System.Label.AGN_DCR2_Creation_Not_Allowed_for_This_Type;
                // == 'You are not allowed to create this type of DCR.'
                return null;
            }
        }
    }
    
    
// ================================================================ //

    public PageReference LaunchNewDcrPage() {
        system.debug('== [AGN_DCR2_Launch_Create].[LaunchNewDcrPage] == PramAccType ==>'+PramAccType);
        string recordType;
        Id recordTypeId;
        string urlCountryParam;
        string countryFieldID;
        
        // ======== Fetching Record Type ID to launch the New DCR Page ======== //
        recordType = (PramAccType == 'person'  ?  'HCP - Create' : 'HCO - Create');
        recordType += (PramAccManaged == 'self'  ?  ' - Company Managed' : ' - Data Provider Managed');
        recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Account_AGN__c' AND Name = :recordType].id;
                system.debug('== [Query:recordTypeId] =='+recordTypeId);

        // ======== Fetching Country Code to launch the New DCR Page ======== //
        countryFieldID = (dcrSetting.DCR_ACC_FieldID_Country__c).subString(0,15);
        if(LoggedInUser.Cluster_User_AGN__c == false && LoggedInUser.MA_Medical_Affairs_AGN__c != 'Yes')
          urlCountryParam = countryFieldID+'='+LoggedInUser.Country_Code__c;

        // ======== Redirection to the New DCR Page ======== //
        Schema.DescribeSObjectResult destination = DCR_Account_AGN__c.SObjectType.getDescribe();
        string returnPageRef = '/'+destination.getKeyPrefix()+'/e?RecordType='+recordTypeId+'&CF'+urlCountryParam+'&nooverride=1';
        system.debug('== [AGN_DCR2_Launch_Create].[LaunchNewDcrPage].Returning:returnPageRef =='+returnPageRef);
        return new PageReference(returnPageRef).setRedirect(true);
    }
    
    
// ================================================================ //

    public boolean HasPermission(DCR_Configuration_Settings_AGN__c conf) {
        system.debug('== [AGN_DCR2_Launch_Create].[HasPermission] ==');

        if(PramAccType == 'person') {
            if(conf.HCP_Create_Allowed_AGN__c == true && (conf.DCR_Type_AGN__c == 'HCP Only' || conf.DCR_Type_AGN__c == 'Both HCP and HCO'))
                return true;
            else
                return false;
        }
        else if(PramAccType == 'business') 
        {
            if(conf.HCO_Create_Allowed_AGN__c == true && (conf.DCR_Type_AGN__c == 'HCO Only' || conf.DCR_Type_AGN__c == 'Both HCP and HCO'))
                return true;
            else
                return false;
        }
        return false;
    }
    
    
// ================================================================ //
    
    // ========   OUTBOUND SEARCH FORM   ======== //
         // == Currently not in use
         // == This for future scope of enhancement
    public void ShowSearchForm() {
        system.debug('== [AGN_DCR2_Launch_Create].[ShowSearchForm] ==');
        ShowOutboundSearchForm = true;
    }
    // --------   OUTBOUND SEARCH FORM   -------- //
    
}

// AGN_DCR2_Launch_Create //