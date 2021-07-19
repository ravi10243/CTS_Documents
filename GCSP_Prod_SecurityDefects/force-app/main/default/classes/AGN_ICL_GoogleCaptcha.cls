public class AGN_ICL_GoogleCaptcha {
    
    public String languagecode { get; set;}
    
    public AGN_ICL_GoogleCaptcha()
    {
     	languagecode = ApexPages.currentPage().getParameters().get('lang');
    }

}