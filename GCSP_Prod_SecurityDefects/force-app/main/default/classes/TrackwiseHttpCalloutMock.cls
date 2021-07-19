@isTest
global class TrackwiseHttpCalloutMock implements HttpCalloutMock{

    private String returnCode;
    private String prId;
    public TrackwiseHttpCalloutMock(String returnCode, String prId) {
        this.returnCode = returnCode;
        this.prId = prId;
    }
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        String body = '<?xml version="1.0"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope/" '+
            'soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding"> ' + 
			' <ns:createPRResponse xmlns:ns="http://api.sparta.com"> ' +
			' <ns:return> <ns:CPRWebService xmlns:ns="http://ows.sparta.com"> '+
			' <ReturnCode>'+this.returnCode +'</ReturnCode> <PrId>'+this.prId+'</PrId> <Message>2018-12-14 07:26:35.945 (250 ms) Web Serv</Message> ' +
            ' </ns:CPRWebService> </ns:return> </ns:createPRResponse> </soap:Envelope> ' ;
        response.setBody(body);
        return response;
    }
}