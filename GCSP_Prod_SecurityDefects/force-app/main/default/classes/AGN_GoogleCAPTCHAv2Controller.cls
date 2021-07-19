public without sharing class AGN_GoogleCAPTCHAv2Controller {
    
    public String captchaKey{get;set;}    
    public String lang{get;set;}
    public String baseURL{get;set;}
    public PageReference getCaptchaKey()
    {
        captchaKey = AGN_OAMConstant.CAPTCHAKEY;
        lang = AGN_OAMConstant.USER_LANGUAGE;
        baseURL = AGN_OAMConstant.COMMUNITY_BASE_URL; //'https://gcspeudev-allergancommunityeu.cs84.force.com';
        return null;
    }
}