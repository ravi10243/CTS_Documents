/**
 * @description       : Site landing Controller.
 * @author            : GCSP Core Plus Dev team
 * @group             : 
 * @last modified on  : 04-15-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   13-01-2021   GCSP Core Plus Dev team   Initial Version
**/
public without sharing class AGN_GCSP_CommunitiesLandingController {
    public AGN_GCSP_CommunitiesLandingController () {
    }
    
    
    /**
    * @description : forwarding to the registration step.
    * @author GCSP Core Plus Dev team | 13-01-2021 
    * @return PageReference 
    **/
    public PageReference forwardToStartPage() {
        
        String urlToRedirect;
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        //final String COMMUNITY_BASE_URL = commonOktaConfig.Community_Base_URL_AGN__c;
        //final String COMMUNITY_SUFFIX = commonOktaConfig.Community_Suffix_AGN__c;
        String userLanguage = '';
        String userCountry = '';
        if(ApexPages.currentPage().getParameters().get('language') != null){
            userLanguage = ApexPages.currentPage().getParameters().get('language');
        }else{
         
            userLanguage = UserInfo.getLocale();
            //userLanguage = UserInfo.getLanguage();
        }
        system.debug('==========userLanguage========'+userLanguage);
        User userRecord = [select Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        if(ApexPages.currentPage().getParameters().get('country') != null){
            userCountry = ApexPages.currentPage().getParameters().get('country');
        }else{
            userCountry = userRecord.Country_Code__c;
        }
        
        //Site URL
        final String COMMUNITY_BASE_URL = (String)AGN_GCSP_Settings__c.getValues(userCountry).get('Community_Base_URL_AGN__c');
          
        final String COMMUNITY_SUFFIX = (String)AGN_GCSP_Settings__c.getValues(userCountry).get('Community_Suffix_AGN__c');
        
        String RegStepNo = AGN_GCSP_Utilities.getADRegStepInfos();
        
        String urlRedirectPage = '';
        
        
        if(String.isEmpty(COMMUNITY_SUFFIX) || COMMUNITY_SUFFIX.equals('/') ) {
            urlToRedirect = COMMUNITY_BASE_URL;
        }
        else{
            urlToRedirect = COMMUNITY_BASE_URL + COMMUNITY_SUFFIX;
        }
        
        
        if(String.isNotEmpty(RegStepNo))
        {
            //&& RegStepNo != '5'
            Switch on RegStepNo {
                When '1' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step1_Registration_Page_AGN__c; 
                }
                
                When '2' {
                    urlRedirectPage = commonOktaConfig.OAM_Step2_Registration_Page_AGN__c;
                }
                
                When '3' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step3_Registration_Page_AGN__c;
                }
                
                When '4' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step4_Registration_Page_AGN__c;
                }
                
                When '5' {
                    urlRedirectPage = commonOktaConfig.OAM_Step4_Registration_Page_AGN__c;
                }
                
            }
            
            if(RegStepNo.equalsIgnoreCase('Complete')){
                urlRedirectPage = '/s';
            }
            
            //urlRedirectPage = String.isEmpty(urlRedirectPage) ? commonOktaConfig.OAM_Step4_Registration_Page_AGN__c : '/s';
       		urlToRedirect +=  urlRedirectPage+'?country='+userCountry+'&language='+userLanguage;
            //+'?language=' + AGN_GCSP_Utilities.getUserLocale;
        
        }
        else{
            string landingPage = !String.isEmpty(commonOktaConfig.Redirection_Page__c) ? commonOktaConfig.Redirection_Page__c : ''; 
			urlToRedirect += '/'+landingPage+'?country='+userCountry+'&language='+userLanguage;
            //+'/'+ '?language=' + AGN_GCSP_Utilities.getUserLocale;
            //AGN_GCSP_CustomerPortalOktaLogin/'
		} 
        PageReference pageRef = new PageReference(urlToRedirect);
        pageRef.setRedirect(true);
        if(String.isNotBlank(userCountry)){
            pageRef.getParameters().put('country',userCountry); 
        }
        if(String.isNotBlank(userLanguage)){
            pageRef.getParameters().put('language',userLanguage); 
        }
        
        return new PageReference(urlToRedirect);
            //
    }
}