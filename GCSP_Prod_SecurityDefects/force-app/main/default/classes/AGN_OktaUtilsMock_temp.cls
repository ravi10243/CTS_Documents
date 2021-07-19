@isTest
global class AGN_OktaUtilsMock_temp implements HttpCalloutMock  {
    
     global HTTPResponse respond(HTTPRequest req) {
         
         String json = '{"id":"00uwnwii9r1iBh7tQ0h7","status":"ACTIVE","created":"2021-01-29T04:28:46.000Z","activated":"2021-01-29T04:28:48.000Z",'+
             '"statusChanged":"2021-01-29T04:42:34.000Z","lastLogin":"2021-02-12T08:08:17.000Z","lastUpdated":"2021-01-29T04:42:34.000Z",'+
             '"passwordChanged":"2021-01-29T04:42:34.000Z","type":{"id":"oty1uf38mjIVFUGHKMBP"},"profile":{"firstName":"dsfsdeegs","lastName":"sdfsdf","mobilePhone":"9879798797","countryCode":"GB","secondEmail":null,'+
             '"ad_has_consented_gdpr":true,"title":"Dr.","login":"krishna9892@yopmail.com","email":"krishna9892@yopmail.com"},'+
             '"credentials":{"password":{},"recovery_question":{"question":"What is the food you least liked as a child?"},'+
             '"provider":{"type":"OKTA","name":"OKTA"}}}';       
      
        HttpResponse response = new HttpResponse();    
        response.setHeader('Content-Type', 'application/json');
        response.setBody(json);
        response.setStatusCode(200);
        response.setStatus('Success');
        return response; 
    }    

}