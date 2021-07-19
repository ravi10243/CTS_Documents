@isTest
global class AGN_OktaUtilsMockFailure implements HttpCalloutMock {
    //Implement http mock callout here
    global HTTPResponse respond(HTTPRequest request) {
     HttpResponse response = new HttpResponse();    
     String json = '{'+
        '    \"errorCode\": \"E0000001\",'+
        '    \"errorSummary\": \"Api validation failed: password\",'+
        '    \"errorLink\": \"E0000001\",'+
        '    \"errorId\": \"oaemr9uRyWIRLC55KlP0OMR0g\",'+
        '    \"errorCauses\": ['+
        '        {'+
        '            \"errorSummary\": \"password: Password requirements were not met. Password requirements: at least 8 characters, a lowercase letter, an uppercase letter, a number, no parts of your username.\"'+
        '        }'+
        '    ]'+
        '}';
        
        response.setHeader('Content-Type', 'application/json');
        response.setBody(json);
        response.setStatusCode(500);
        response.setStatus('Failure');
        return response; 
        
    }
}