@IsTest
public class AGN_OktaUserSuccessResponse_Test {
    
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
        AGN_OktaUserSuccessResponse r = AGN_OktaUserSuccessResponse.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        AGN_OktaUserSuccessResponse.Recovery_question objRecovery_question = new AGN_OktaUserSuccessResponse.Recovery_question(System.JSON.createParser(json));
        System.assert(objRecovery_question != null);
        System.assert(objRecovery_question.question == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        AGN_OktaUserSuccessResponse.Profile objProfile = new AGN_OktaUserSuccessResponse.Profile(System.JSON.createParser(json));
        System.assert(objProfile != null);
        System.assert(objProfile.lastName == null);
        System.assert(objProfile.zipCode == null);
        System.assert(objProfile.ad_site_permissions == null);
        System.assert(objProfile.city == null);
        System.assert(objProfile.ad_system_permissions == null);
        System.assert(objProfile.secondEmail == null);
        System.assert(objProfile.ad_user_role == null);
        System.assert(objProfile.login == null);
        System.assert(objProfile.ad_associated_payer_accounts == null);
        System.assert(objProfile.firstName == null);
        System.assert(objProfile.ad_associated_shipto_accounts == null);
        System.assert(objProfile.mobilePhone == null);
        System.assert(objProfile.streetAddress == null);
        System.assert(objProfile.WorkdayID == null);
        System.assert(objProfile.countryCode == null);
        System.assert(objProfile.email == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        AGN_OktaUserSuccessResponse.Credentials objCredentials = new AGN_OktaUserSuccessResponse.Credentials(System.JSON.createParser(json));
        System.assert(objCredentials != null);
        System.assert(objCredentials.password == null);
        System.assert(objCredentials.recovery_question == null);
        System.assert(objCredentials.provider == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        AGN_OktaUserSuccessResponse.Password objPassword = new AGN_OktaUserSuccessResponse.Password(System.JSON.createParser(json));
        System.assert(objPassword != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        AGN_OktaUserSuccessResponse.Provider objProvider = new AGN_OktaUserSuccessResponse.Provider(System.JSON.createParser(json));
        System.assert(objProvider != null);
        System.assert(objProvider.type_Z == null);
        System.assert(objProvider.name == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        AGN_OktaUserSuccessResponse objAGN_OktaUserSuccessResponse = new AGN_OktaUserSuccessResponse(System.JSON.createParser(json));
        System.assert(objAGN_OktaUserSuccessResponse != null);
        System.assert(objAGN_OktaUserSuccessResponse.id == null);
        System.assert(objAGN_OktaUserSuccessResponse.status == null);
        System.assert(objAGN_OktaUserSuccessResponse.created == null);
        System.assert(objAGN_OktaUserSuccessResponse.activated == null);
        System.assert(objAGN_OktaUserSuccessResponse.statusChanged == null);
        System.assert(objAGN_OktaUserSuccessResponse.lastLogin == null);
        System.assert(objAGN_OktaUserSuccessResponse.lastUpdated == null);
        System.assert(objAGN_OktaUserSuccessResponse.passwordChanged == null);
        System.assert(objAGN_OktaUserSuccessResponse.profile == null);
        System.assert(objAGN_OktaUserSuccessResponse.credentials == null);
    }
}