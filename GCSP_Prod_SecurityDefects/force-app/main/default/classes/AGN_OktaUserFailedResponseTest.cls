@IsTest
public class AGN_OktaUserFailedResponseTest {
	
	static testMethod void testParse() {
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
		AGN_OktaUserFailedResponse obj = AGN_OktaUserFailedResponse.parse(json);
         System.assert(obj != null);
	}
}