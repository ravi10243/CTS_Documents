/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* This class contains generic methods in order to support the other classes
*/

public class AGNGigyaRESTHelper {

  public static final String NOTIFICATION_SUBSCRIPTION_NAME = 'notification';

  private static final List<Integer> ERROR_CODE_NO_LOG = new List<Integer>{};

  public static Boolean isEmptyString(String s) {
      return s == null || s.length() == 0;
  }

  public static Boolean environmentEnabled() {
    AGN_GIGYA_REST_API__c credentials = AGN_GIGYA_REST_API__c.getInstance('Gigya_Credentials');
    return credentials != null && credentials.Enabled__c;
  }

  public static AGNGigyaError getErrorObject(HttpResponse response) {
    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    if (response.getStatusCode() == 200) {
      /*if (((Integer) m.get('statusCode')) == 200) {
        return null;
      }*/
      if (Integer.valueOf(m.get('statusCode')) == 200) {
        return null;
      }
    }
	AGNGigyaError res = new AGNGigyaError();

    res.code = (Integer) m.get('errorCode');
    res.message = (String) m.get('errorMessage');
    res.details = (String) m.get('errorDetails');

    String validationMessage = '';
    List<Object> vers = (List<Object>) m.get('validationErrors');
    if (vers != null && !vers.isEmpty()) {
      for (Object mTemp : vers) {
        Map<String, Object> mmm = (Map<String, Object>) mTemp;
        validationMessage += (String) mmm.get('message');
        //not necessary
        // if (mmm.get('fieldName') != null) {
        //   validationMessage += ' [' + String.valueOf(mmm.get('fieldName')) + ']';
        // }
        validationMessage += ', ';
      }
      validationMessage = validationMessage.left(validationMessage.length() - 2);
    }
    res.details += '|' + validationMessage;
    system.debug('res===='+res);
    system.debug('@@@res :'+ res.toString());

    throw new AGNGigyaValidationException(res.code,res.message,res.details);

  }

  public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < len) {
      Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
      randStr += chars.substring(idx, idx+1);
    }
    return randStr;
  }

  public static Boolean validateEmail(String email) {
    Boolean res = true;
    String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
    Pattern MyPattern = Pattern.compile(emailRegex);
    Matcher MyMatcher = MyPattern.matcher(email);
    if (!MyMatcher.matches()) {
      res = false;
    }
    return res;
  }
}