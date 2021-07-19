/**
 * Description: logic for login discovery by email 
 * @Author: Gaetan Barbeu
 * 
 * Modification Log
 * ==================================================
 * Version  Date            Author          Modification
 * -------  ----            ------          -------------
 * CR#      04.08.2020      Gaetan Barbeu
 * ==================================================
 */

global class AGN_AMI_AnatomyAppDiscLoginHandler implements Auth.LoginDiscoveryHandler {
    global PageReference login(String identifier, String startUrl, Map<String, String> requestAttributes) {
        if (identifier != null && isValidEmail(identifier)) {
            //Search for user by permission set assignment
            List<PermissionSetAssignment> anatomyAppPermList = new List<PermissionSetAssignment>([SELECT AssigneeId FROM PermissionSetAssignment 
                                                                                                                    WHERE Assignee.Email =:identifier 
                                                                                                                    AND  Assignee.IsActive = true
                                                                                                                    AND PermissionSet.Name =: Label.Anatomy_App_Permission_Set_Name
                                                                                                                    LIMIT 1]);
            system.debug('@@@'+anatomyAppPermList);
            if (!anatomyAppPermList.isEmpty()) {
                // User must have verified email before using this verification method. We cannot send messages to unverified emails. 
                // You can check if the user has email verified bit on and add the password verification method as fallback.
                List<TwoFactorMethodsInfo> verifiedInfo = [SELECT HasUserVerifiedEmailAddress FROM TwoFactorMethodsInfo WHERE UserId = :anatomyAppPermList.get(0).AssigneeId ];
                if (!verifiedInfo.isEmpty() && verifiedInfo[0].HasUserVerifiedEmailAddress == true) {
                    // Use email verification method if the user's email is verified.
                    return discoveryResult(anatomyAppPermList.get(0).AssigneeId, Auth.VerificationMethod.EMAIL, startUrl, requestAttributes);
                } else {
                    //Use password verification method as fallback if the user's email is unverified.
                    return discoveryResult(anatomyAppPermList.get(0).AssigneeId, Auth.VerificationMethod.PASSWORD, startUrl, requestAttributes);
                }
            } else {
                throw new Auth.LoginDiscoveryException('Access has not been enabled');
            }
        }
        throw new Auth.LoginDiscoveryException('Invalid Identifier');
    }

    //check if email has the right format
    private boolean isValidEmail(String identifier) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        // source: http://www.regular-expressions.info/email.html 
        Pattern EmailPattern = Pattern.compile(emailRegex);
        Matcher EmailMatcher = EmailPattern.matcher(identifier);
        if (EmailMatcher.matches()) { return true; }
        else { return false; }
    }

    private PageReference discoveryResult(String userId, Auth.VerificationMethod method, String startUrl, Map<String, String> requestAttributes) {
        //Only external users with an External Identity or community license can login using Site.passwordlessLogin
        if (method != null) {
            List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
            methods.add(method);
            PageReference pwdlessRedirect = Site.passwordlessLogin(userId, methods, startUrl);
            if (pwdlessRedirect != null) {
                return pwdlessRedirect;
            } else {
                throw new Auth.LoginDiscoveryException('No Passwordless Login redirect URL returned for verification method: ' + method);
            }
        } else {
            throw new Auth.LoginDiscoveryException('No method found');
        } 
    }
}