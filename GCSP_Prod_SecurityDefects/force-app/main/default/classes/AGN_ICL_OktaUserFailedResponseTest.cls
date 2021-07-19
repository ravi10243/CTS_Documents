@isTest(SeeAllData=true)
global class AGN_ICL_OktaUserFailedResponseTest implements HttpCalloutMock {
    
    
      global HTTPResponse respond(HTTPRequest req) {
   
           
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'image/jpg');
        res.setStatusCode(200);
        return res;
    }

    static testmethod void method1()
    {
        AGN_ICL_OktaUserFailedResponse obj = new AGN_ICL_OktaUserFailedResponse();
        obj.errorCode='abcd';
        obj.errorSummary='abcd';
        obj.errorLink='abcd';
        obj.errorId='abcd';
        
        AGN_ICL_OktaUserFailedResponse.ErrorCauses obj2 = new AGN_ICL_OktaUserFailedResponse.ErrorCauses();
        obj2.errorSummary='xyz';
        Test.setMock(HttpCalloutMock.class, new AGN_ICL_OktaUserFailedResponseTest());
      AGN_ICL_OktaUserFailedResponse a=  AGN_ICL_OktaUserFailedResponse.parse('null');
    }
}