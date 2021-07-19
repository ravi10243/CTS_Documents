@isTest
global class AGN_OktaHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"user": ["ra@tr.com", "@eswar1234","When you buy your first Car?"]}');
        response.setStatusCode(200);
        return response; 
    }
}