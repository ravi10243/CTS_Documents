/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* This class builds the request for Gigya REST web services.
*/

public class AGNGigyaRESTUrlBuilder {
	private static AGN_GIGYA_REST_API__c credentials = AGN_GIGYA_REST_API__c.getInstance('Gigya_Credentials');

	private String ENDPOINT;
	private String url;
	private String service;
	private HttpRequest request;

	public AGNGigyaRESTUrlBuilder(String service, String endpointPrefix) {
		ENDPOINT = 'https://' + endpointPrefix + '.' + credentials.Endpoint_Suffix__c + '/' + service;
		this.service = service;
		url = 'apiKey=' + credentials.AGN_Gigya_Api_Key__c;
		addParameter('userKey', credentials.AGN_Gigya_User_Key__c);
		addParameter('secret', credentials.AGN_Gigya_Api_Secret__c);
		request = new HttpRequest();
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		request.setHeader('Content-Length', '0');
	}

	public AGNGigyaRESTUrlBuilder(String service) {
		this(service, 'accounts');
	}

	public void addParameter(String key, String value) {
		url += '&' + key + '=' + value;
	}

	public HttpRequest getRequest() {
		request.setEndpoint(ENDPOINT);
		request.setBody(url);
		return request;
	}

	public HttpResponse execute() {
		//System.debug('URLBUILDER >> endpoint >> ' + ENDPOINT);
		// System.debug('URLBUILDER > body > ' + url);
		Http http = new Http();
		HttpResponse response = http.send(this.getRequest());
		AGNGigyaRESTHelper.getErrorObject(response);
		return response;
	}
}