/*
*---------------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev Roushan
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        1.0
* @created        
* @modified      19-Nov-2019
* @testClass     
* @Class Name    AGN_CCPA_GoogleCaptcha
* -------------------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 19-Nov-2019           
*  Apex Controller for VF Page AGN_CCPAGoogleCaptchaPage which is used to control the Captcha on Form 360.
*-------------------------------------------------------------------------------------------------------------------------------+
*/

public class AGN_CCPA_GoogleCaptcha {
    public String languagecode { get; set;}
    
    public AGN_CCPA_GoogleCaptcha()
    {
     	languagecode = ApexPages.currentPage().getParameters().get('lang');
        System.debug('languagecode'+ languagecode);
    }

}