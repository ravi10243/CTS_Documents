/** 
 * This is a utility class that contains functions that will be used
 * in multiple classes.
 */
public with sharing class AGN_OpportunityUtility {
  
  /**
   * Extract and return values from an Id field.
   *
   * @param objs List of any sObject type.
   * @param fieldName Full API name of a field on the sObject type.
   * @return A possibly empty set of ids, with null removed.
   */
  public static Set<Id> extractIds(sObject[] objs, String fieldName) {
 
      Set<Id> result = new Set<Id>();
      for (sObject obj : objs) {
        result.add((Id) obj.get(fieldName));
      }
      result.remove(null);
      return result;
  } 
  
   /**
     * Extract and return values from an Id field.
     *
     * @param objects   List of any sObject type.
     * @param fieldName Full API name of a field on the sObject type.
     * @return A possibly empty set of ids, with null removed.
     */
    public static Set<String> extractStrings (List<sObject> objects, String fieldName) {
        Set<String> result = new Set<String>();
        for (sObject obj : objects) {
            result.add((String) obj.get(fieldName));
        }
        result.remove(null);
        return result;
    }
    
    /**
     * Validates an incoming email using a regular expression.
     *
     * @param email    The email to be validated.
     * @return       If the email passes the match returns true else returns false.
     */
    public static boolean isValidEmail(String email){
      String emailRegex =  '^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$'; 
      Pattern MyPattern = Pattern.compile(emailRegex);
      Matcher MyMatcher = MyPattern.matcher(email);
      if(!MyMatcher.matches()){
        return false;
      }
      else{
        return true;
      }
    }
}