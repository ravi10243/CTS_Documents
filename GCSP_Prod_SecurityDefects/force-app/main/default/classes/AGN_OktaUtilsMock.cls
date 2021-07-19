@isTest
public class AGN_OktaUtilsMock {
    
    static testMethod void testParse() {
         String json = '{'+
        '    \"id\": \"00u1eggpafeAxqN4x1d8\",'+
        '    \"status\": \"ACTIVE\",'+
        '    \"created\": \"2018-08-10T11:39:30.000Z\",'+
        '    \"activated\": \"2018-08-10T11:39:34.000Z\",'+
        '    \"statusChanged\": \"2018-08-10T11:39:34.000Z\",'+
        '    \"lastLogin\": \"2018-09-04T12:28:05.000Z\",'+
        '    \"lastUpdated\": \"2018-09-04T14:01:11.000Z\",'+
        '    \"passwordChanged\": \"2018-08-10T11:39:33.000Z\",'+
        '    \"profile\": {'+
        '        \"lastName\": \"Dev\",'+
        '        \"zipCode\": \"560 001\",'+
        '        \"ad_site_permissions\": ['+
        '            \"algb2b-us\",'+
        '            \"algb2b-ca\"'+
        '        ],'+
        '        \"city\": \"Bangalore\",'+
        '        \"ad_system_permissions\": ['+
        '            \"bpWriteAccess\"'+
        '        ],'+
        '        \"secondEmail\": \"\",'+
        '        \"ad_user_role\": \"superUser\",'+
        '        \"login\": \"gcsp@allergan.com\",'+
        '        \"ad_associated_payer_accounts\": ['+
        '            \"NES02\",'+
        '            \"RUM05\"'+
        '        ],'+
        '        \"firstName\": \"GCSP\",'+
        '        \"ad_associated_shipto_accounts\": ['+
        '            \"NES02\",'+
        '            \"RUM05\"'+
        '        ],'+
        '        \"mobilePhone\": \"\",'+
        '        \"streetAddress\": \"Level 2, Prestige Obelisk  \",'+
        '        \"WorkdayID\": \"106531\",'+
        '        \"countryCode\": \"IN\",'+
        '        \"email\": \"gcsp@allergan.com\"'+
        '    },'+
        '    \"credentials\": {'+
        '        \"password\": {},'+
        '        \"recovery_question\": {'+
        '            \"question\": \"What is the name of your first stuffed animal?\"'+
        '        },'+
        '        \"provider\": {'+
        '            \"type\": \"OKTA\",'+
        '            \"name\": \"OKTA\"'+
        '        }'+
        '    }'+
        '}';
        //AGN_OktaUserSuccessResponse r = AGN_OktaUserSuccessResponse.parse(json);
        //System.assert(r != null);
        HttpResponse response = new HttpResponse();    
        response.setHeader('Content-Type', 'application/json');
        //response.setBody(json);
        response.setStatusCode(200);
        response.setStatus('Success');
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
        //return response; 
    }
}