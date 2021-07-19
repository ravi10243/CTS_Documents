public without sharing class AGN_OAMConstant {
   
    private static User uInfo{
        get{        
            return [SELECT Name,Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        }
    }
   
    public static string USERCOUNTRYCODE {
        get{          
            return uInfo.Country_Code__c;
        }
        
    }
    
    public static string USERLANGUAGE {
        get{          
            return UserInfo.getLanguage();
        }
    }
    
    public static string USERLOCAL {
        get{          
            return UserInfo.getLocale();
        }
    }
    
    public static final String USERNAME_SUFFIX =  (String)OAM_User_Settings__c.getValues(uInfo.Country_Code__c).get('Username_Suffix__c');//'agncustomerd17';
    public static final String USER_LANGUAGE = (String)OAM_User_Settings__c.getValues(uInfo.Country_Code__c).get('User_Language__c');
    public static final String USER_PROFILE = (String)OAM_User_Settings__c.getValues(uInfo.Country_Code__c).get('User_Profile__c');
    
    //public static final String RECORD_OWNER = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('CR_Record_Owner__c');
    //public static final String OWNER_ID = [SELECT ID FROM User where Username =: RECORD_OWNER LIMIT 1].Id;
    
    public static final String OWNER_ID = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('CR_Record_Owner__c');   

    public static final String OKTABASEURL = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Okta_Base_URL_AGN__c');
    public static final String OKTAAPIKEY = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Okta_API_Key_AGN__c');
    public static final String OKTASFCOMMUNITYGROUPID = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Okta_SF_Community_Group_Id_AGN__c');
    public static final String OKTAREDIRECTURL = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Okta_Redirect_URL_AGN__c');

    
    public static final String PRIVATEKEY = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Encrypt_Decrypt_Private_Key_AGN__c');
    public static final Decimal TOKENVALIDTILL = (Decimal)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Activation_Token_Valid_Till_AGN__c');
    
    public static final String SENDEREMAILADDRESS = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Sender_Email_AGN__c');
    
    //google recaptcha properties
    public static final String CAPTCHABASEURL = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('reCaptcha_End_Point__c');
    public static final String CAPTCHASECRET = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('reCaptcha_Secret__c');
    public static final String CAPTCHAKEY = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('reCaptcha_Site_Key__c');
        
    public static final String DEFAULT_OKTA_RECOVERY_QUETION = 'Name of this company?';
    public static final String DEFAULT_OKTA_RECOVERY_ANSWER = 'ALLERGAN';
    
    public static final String COMMUNITY_BASE_URL = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Community_Base_URL_AGN__c');
    public static final String COMMUNITY_SUFFIX = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Community_Suffix_AGN__c');  
    
    public static final String ALLERGAN_DIRECT_OKTA_SSO_URL = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('E_Commerce_SSO_URL_AGN__c');  
    
    public static final Boolean OKTA_USER_SAMEAS_PORTAL_USER = false; //If false, Okta User will be equal to Email of Community User
    
}