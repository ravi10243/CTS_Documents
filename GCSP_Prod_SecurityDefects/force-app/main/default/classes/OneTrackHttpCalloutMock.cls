@isTest
global class OneTrackHttpCalloutMock implements HttpCalloutMock
{
	private String returnCode;
    private String intakeId;
    private String message;
    private Boolean isUpdate;
    
    global OneTrackHttpCalloutMock(String returnCode, String intakeId, String message, Boolean isUpdate) {
        this.returnCode = returnCode;
        this.intakeId = intakeId;
        this.message=message;
        this.isUpdate=isUpdate;
    }
    global HttpResponse respond(HttpRequest request) 
    {
        if(isUpdate)
        {
            HttpResponse response = new HttpResponse();
        	String body = '<?xml version="1.0"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" '+
            'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema>" ' + '<soap:Body>' +
            ' <UpdateIntakeResponse xmlns="http://tempuri.org/UpdateIntake"> ' +
            ' <UpdateIntakeResult> '+
            ' <ReturnCode>'+this.returnCode +'</ReturnCode> <IntakeId>'+this.intakeId+'</IntakeId> <Message>'+this.message+'</Message> ' +
            ' </UpdateIntakeResult> </UpdateIntakeResponse> </soap:Body> </soap:Envelope> ' ;
        	response.setHeader('Content-Type', 'text/xml');
			response.setBody(body);
			response.setStatusCode(200);
        	System.debug('######Response: '+response);
        	return response;
        }
        else
        {
         	HttpResponse response = new HttpResponse();
        	String body = '<?xml version="1.0"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" '+
            'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema>" ' + '<soap:Body>' +
            ' <CreateIntakeResponse xmlns="http://tempuri.org/CreateIntake"> ' +
            ' <CreateIntakeResult> '+
            ' <ReturnCode>'+this.returnCode +'</ReturnCode> <IntakeId>'+this.intakeId+'</IntakeId> <Message>'+this.message+'</Message> ' +
            ' </CreateIntakeResult> </CreateIntakeResponse> </soap:Body> </soap:Envelope> ' ;
        	response.setHeader('Content-Type', 'text/xml');
			response.setBody(body);
			response.setStatusCode(200);
        	System.debug('######Response: '+response);
        	return response;   
        }
    }
}