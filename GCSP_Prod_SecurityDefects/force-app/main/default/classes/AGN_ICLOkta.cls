public class AGN_ICLOkta {
    

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
        HttpResponse res = new HttpResponse();
        // Send the request, and return a response 
        try {
            res = h.send(req);
            //response = res.getBody();

            
        }catch(System.CalloutException cex) {
  
            throw cex;
        }
        catch(System.Exception ex) {

            throw ex;
        }
        return res;
    }
    
    public static HttpResponse GetUserDetails(String baseUrl, String apiKey, String oktaUser) {
        
        String url = baseUrl + '/api/v1/users/'+ oktaUser;

        
        HttpResponse response = doOktaCallOut(apiKey, url, 'GET', '');
        
        return response;
    }
    public static HttpResponse FirstTimeChgPWDSecurityQuestion(String reqBody, String baseUrl, String apiKey, String oktaUser) {
        
        String url = baseUrl + '/api/v1/users/'+ oktaUser +'?sendEmail=false';

        
        HttpResponse response;
        
        HttpRequest req = new HttpRequest();   
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization','SSWS ' + apiKey);
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setBody(reqBody);

        try {
            Http http = new Http();
            response = http.send(req);
   
        }
        catch(System.CalloutException cex) {
            throw cex; 
        }
        catch( System.Exception ex) {
            throw ex; 
        }
        return response;
    }
    public static HttpResponse CreateUserAsInactive(String reqBody, String baseUrl, String apiKey) {
        
        String url = baseUrl + '/api/v1/users?activate=false'; //creating the user as an inactive so that Okta does not send any email by default
        
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
            throw cex;
        }
        catch(System.Exception ex) {
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse SetPassword(String baseUrl, String apiKey, String userId, String reqBody) {
        //{{url}}/api/v1/users/{{userId}}/credentials/forgot_password?sendEmail=false
        
        String url = baseUrl + '/api/v1/users/'+ userId +'/credentials/forgot_password?sendEmail=false';

        
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
            throw cex;
        }
        catch(System.Exception ex) {
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse UpdateUser(String userId, String reqBody, String baseUrl, String apiKey) {
        
        String url = baseUrl + '/api/v1/users/'+ userId;
        
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
            throw cex;
        }
        catch(System.Exception ex) {
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse ActivateUser(String userId, String baseUrl, String apiKey) {
        
        String url = baseUrl + '/api/v1/users/'+ userId +'/lifecycle/activate?sendEmail=false'; //'sendEmail=false' forcing Okta not to send email
        
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
            throw cex;
        }
        catch(System.Exception ex) {
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse AddUserToGroup(String groupId, String userId, String baseUrl, String apiKey) {
        
        //{{url}}/api/v1/groups/{{groupId}}/users/{{userId}}
        
        String url = baseUrl + '/api/v1/groups/'+ groupId +'/users/'+ userId;
        
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
            throw cex;
        }
        catch(System.Exception ex) {
            throw ex;
        }
        return response;
    }
    
    public static HttpResponse CheckOktaLogin(String baseUrl, String apiKey, String bodyString) {
        
        String url = baseUrl + '/api/v1/sessions?additionalFields=cookieToken';
        
        HttpResponse response = doOktaCallOut(apiKey, url, 'POST', bodyString);
        
        return response;
    }
}