@isTest
global class AGN_AMI_Strata_MockHttpResponseGenerator implements HttpCalloutMock{
  global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[ { "veevaId": "2233","survey.rating": 3}]');
        res.setStatusCode(200);
        return res;
    }
}