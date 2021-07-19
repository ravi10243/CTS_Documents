public class AGN_PostCopyValidateUtil {
    public static Boolean validateEmail(String email) {
        Boolean res = true;
        if(!Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})', email)){
            res = false;            
        }
        //System.debug('Validate email '+ res);
        return res;	
    }
    
    public static boolean isEligible(String email){
        return (email != null && email != '' && ! email.endsWithIgnoreCase('.invalid'));
    }
}