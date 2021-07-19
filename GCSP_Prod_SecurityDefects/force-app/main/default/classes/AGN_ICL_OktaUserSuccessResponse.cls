public class AGN_ICL_OktaUserSuccessResponse {

    public class Recovery_question {
        public String question {get;set;} 

        public Recovery_question(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'question') {
                            question = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Profile {
        public String lastName {get;set;} 
        public String zipCode {get;set;} 
        public List<String> ad_site_permissions {get;set;} 
        public String city {get;set;} 
        public List<String> ad_system_permissions {get;set;} 
        public String secondEmail {get;set;} 
        public String ad_user_role {get;set;} 
        public String login {get;set;} 
        public List<String> ad_associated_payer_accounts {get;set;} 
        public String firstName {get;set;} 
        public List<String> ad_associated_shipto_accounts {get;set;} 
        public String mobilePhone {get;set;} 
        public String streetAddress {get;set;} 
        public String WorkdayID {get;set;} 
        public String countryCode {get;set;} 
        public String email {get;set;} 

        public Profile(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'lastName') {
                            lastName = parser.getText();
                        } else if (text == 'zipCode') {
                            zipCode = parser.getText();
                        } else if (text == 'ad_site_permissions') {
                            ad_site_permissions = arrayOfString(parser);
                        } else if (text == 'city') {
                            city = parser.getText();
                        } else if (text == 'ad_system_permissions') {
                            ad_system_permissions = arrayOfString(parser);
                        } else if (text == 'secondEmail') {
                            secondEmail = parser.getText();
                        } else if (text == 'ad_user_role') {
                            ad_user_role = parser.getText();
                        } else if (text == 'login') {
                            login = parser.getText();
                        } else if (text == 'ad_associated_payer_accounts') {
                            ad_associated_payer_accounts = arrayOfString(parser);
                        } else if (text == 'firstName') {
                            firstName = parser.getText();
                        } else if (text == 'ad_associated_shipto_accounts') {
                            ad_associated_shipto_accounts = arrayOfString(parser);
                        } else if (text == 'mobilePhone') {
                            mobilePhone = parser.getText();
                        } else if (text == 'streetAddress') {
                            streetAddress = parser.getText();
                        } else if (text == 'WorkdayID') {
                            WorkdayID = parser.getText();
                        } else if (text == 'countryCode') {
                            countryCode = parser.getText();
                        } else if (text == 'email') {
                            email = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Credentials {
        public Password password {get;set;} 
        public Recovery_question recovery_question {get;set;} 
        public Provider provider {get;set;} 

        public Credentials(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'password') {
                            password = new Password(parser);
                        } else if (text == 'recovery_question') {
                            recovery_question = new Recovery_question(parser);
                        } else if (text == 'provider') {
                            provider = new Provider(parser);
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Password {

        public Password(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Provider {
        public String type_Z {get;set;} // in json: type
        public String name {get;set;} 

        public Provider(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public String id {get;set;} 
    public String status {get;set;} 
    public String created {get;set;} 
    public String activated {get;set;} 
    public String statusChanged {get;set;} 
    public String lastLogin {get;set;} 
    public String lastUpdated {get;set;} 
    public String passwordChanged {get;set;} 
    public Profile profile {get;set;} 
    public Credentials credentials {get;set;} 

    public AGN_ICL_OktaUserSuccessResponse(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'id') {
                        id = parser.getText();
                    } else if (text == 'status') {
                        status = parser.getText();
                    } else if (text == 'created') {
                        created = parser.getText();
                    } else if (text == 'activated') {
                        activated = parser.getText();
                    } else if (text == 'statusChanged') {
                        statusChanged = parser.getText();
                    } else if (text == 'lastLogin') {
                        lastLogin = parser.getText();
                    } else if (text == 'lastUpdated') {
                        lastUpdated = parser.getText();
                    } else if (text == 'passwordChanged') {
                        passwordChanged = parser.getText();
                    } else if (text == 'profile') {
                        profile = new Profile(parser);
                    } else if (text == 'credentials') {
                        credentials = new Credentials(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    
    public static AGN_ICL_OktaUserSuccessResponse parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new AGN_ICL_OktaUserSuccessResponse(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    


    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }
}