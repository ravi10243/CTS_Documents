/**
* Customer Self Registration Portal
* <p>
* OKTA Service class
*
* @author          Avijit Gorai 
* @version         1.0
* @date            06-OCT-2018 
* @description     OKTA Service class
* @Current Version 1.0
*/
public class AGN_Okta {
    
/**
* @author           Avijit Gorai
* @version          1.0
* @date             09-OCT-2018
* @description      Private method to do REST api call to OKTA
* @param            String apiKey - Okta Authorization APIKey
* @param            String endPoint - request endPoint
* @param            String method - Http method POST, GET, PUT etc.
* @param            String bodyString - request body
* @return           HttpResponse response - OKTA response returned in response of the http request
* @exception        exception has been handled in this method. In case of exception the response will be blank
*/

    private static HttpResponse doOktaCallOut(String apiKey, String endPoint, String method, String bodyString) {
        
        // Instantiate a new http object 
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        
        /* TODO: Add time out in configuration */
        req.setTimeout(10000);
        
        req.setHeader('Authorization', 'SSWS ' + apiKey);
        req.setHeader('Accept', 'application/json;charset=utf-8');
        req.setHeader('Content-Type', 'application/json;charset=utf-8');
        if(!String.isEmpty(bodyString)){
            req.setBody(bodyString);
        }
        req.setMethod(method.toUpperCase());
        system.debug('Check');
        HttpResponse res = new HttpResponse();
        system.debug('@@@Okta Request@@@' + req);
        // Send the request, and return a response 
        try {
            res = h.send(req);
            //response = res.getBody();
            system.debug('@@@Okta Response@@@' + res);
            
        }catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);
            throw cex;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            throw ex;
        }
        return res;
    }
    
    public static HttpResponse GetUserDetails(String baseUrl, String apiKey, String oktaUser) {
        
        String url = baseUrl + '/api/v1/users/'+ oktaUser;
        system.debug ('url is ' +url);
        
        HttpResponse response = doOktaCallOut(apiKey, url, 'GET', '');
        
        /*HttpRequest req = new HttpRequest();   
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization','SSWS ' + apiKey);
        req.setEndpoint(url);
        req.setMethod('GET');
        System.debug('@@@Okta Request@@@' + req);
        try {
            Http http = new Http();
            response = http.send(req); 
        }
        catch(System.CalloutException cex) {
            //System.debug('Callout Error: '+ cex);          
            throw cex; 
        }
        catch( System.Exception ex) {
            //System.debug('ERROR: '+ ex);
            throw ex; 
        }*/
        return response;
    }
    public static HttpResponse GetAssociatedOktaGroups(String baseUrl, String apiKey, String oktaUser) {
        
        String url = baseUrl + '/api/v1/users/'+ oktaUser +'/groups';
        system.debug ('url is ' +url);
        
        HttpResponse response = doOktaCallOut(apiKey, url, 'GET', '');
        
        return response;
    }
    public static HttpResponse FirstTimeChgPWDSecurityQuestion(String reqBody, String baseUrl, String apiKey, String oktaUser) {
        
        String url = baseUrl + '/api/v1/users/'+ oktaUser +'?sendEmail=false';
        system.debug ('url is ' +url);
        
        HttpResponse response;
        
        HttpRequest req = new HttpRequest();   
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization','SSWS ' + apiKey);
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setBody(reqBody);
        System.debug('@@@Okta Request@@@' + req);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug('@@@Okta Response@@@' + response);
        }
        catch(System.CalloutException cex) {
            //System.debug('Callout Error: '+ cex);          
            throw cex; 
        }
        catch( System.Exception ex) {
            //System.debug('ERROR: '+ ex);
            throw ex; 
        }
        return response;
    }
    public static HttpResponse CreateUserAsInactive(String reqBody, String baseUrl, String apiKey) {
        
        String url = baseUrl + '/api/v1/users?activate=false'; //creating the user as an inactive so that Okta does not send any email by default
        system.debug ('url is ' +url);
        
        HttpResponse response;
        
        HttpRequest req = new HttpRequest();   
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization','SSWS ' + apiKey);
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(reqBody);
        try {
            Http http = new Http();
            response = http.send(req);
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);
            throw cex;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse SetPassword(String baseUrl, String apiKey, String userId, String reqBody) {
        //{{url}}/api/v1/users/{{userId}}/credentials/forgot_password?sendEmail=false
        
        String url = baseUrl + '/api/v1/users/'+ userId +'/credentials/forgot_password?sendEmail=false';
        system.debug ('url is ' +url);
        
        HttpResponse response;
        
        HttpRequest req = new HttpRequest();   
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization','SSWS ' + apiKey);
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(reqBody);
        try {
            Http http = new Http();
            response = http.send(req);
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);
            throw cex;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse UpdateUser(String userId, String reqBody, String baseUrl, String apiKey) {
        
        String url = baseUrl + '/api/v1/users/'+ userId;
        system.debug ('url is ' +url);
        
        HttpResponse response;
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization','SSWS ' + apiKey);
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(reqBody);
        try {
            Http http = new Http();
            response = http.send(req);
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);
            throw cex;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse ActivateUser(String userId, String baseUrl, String apiKey) {
        
        String url = baseUrl + '/api/v1/users/'+ userId +'/lifecycle/activate?sendEmail=false'; //'sendEmail=false' forcing Okta not to send email
        system.debug ('url is ' +url);
        
        HttpResponse response;
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization','SSWS ' + apiKey);
        req.setEndpoint(url);
        req.setMethod('POST');
        try {
            Http http = new Http();
            response = http.send(req);
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);
            throw cex;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse AddUserToGroup(String groupId, String userId, String baseUrl, String apiKey) {
        
        //{{url}}/api/v1/groups/{{groupId}}/users/{{userId}}
        
        String url = baseUrl + '/api/v1/groups/'+ groupId +'/users/'+ userId;
        system.debug ('url is ' +url);
        
        HttpResponse response;
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization','SSWS ' + apiKey);
        req.setEndpoint(url);
        req.setMethod('PUT'); //Method => PUT
        try {
            Http http = new Http();
            response = http.send(req);
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);
            throw cex;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse removeUserFromGroup(String groupId, String userId, String baseUrl, String apiKey) {
        
        //{{url}}/api/v1/groups/{{groupId}}/users/{{userId}}
        
        String url = baseUrl + '/api/v1/groups/'+ groupId +'/users/'+ userId;
        system.debug ('url is ' +url);
        
        HttpResponse response;
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization','SSWS ' + apiKey);
        req.setEndpoint(url);
        req.setMethod('DELETE');
        try {
            Http http = new Http();
            response = http.send(req);
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);
            throw cex;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            throw ex;
        }
        return response;
    }
    public static HttpResponse CheckOktaLogin(String baseUrl, String apiKey, String bodyString) {
        
        String url = baseUrl + '/api/v1/sessions?additionalFields=cookieToken';
        system.debug ('url is ' +url);
        
        HttpResponse response = doOktaCallOut(apiKey, url, 'POST', bodyString);
        
        return response;
    }
}