@IsTest public with sharing class AGN_GCSP_CommunitiesLanding_Test{
    @IsTest(SeeAllData=true) public static void testCommunitiesLandingController() {
        User user = AGN_CustReg_TestUtilityClass.createUser();
        System.runAs(user){
        User u = [select id from user where user.contact.customer_registration_agn__c = 'Complete' and country_code__c = 'DE' limit 1];
        
            System.runAs(u){
                // Instantiate a new controller with all parameters in the page
                AGN_GCSP_CommunitiesLandingController controller = new AGN_GCSP_CommunitiesLandingController();
                PageReference pageRef = controller.forwardToStartPage();
                //PageRef is either null or an empty object in test context
                if(pageRef != null){
                    String url = pageRef.getUrl();
                    if(url != null){
                        System.assertEquals(false, String.isEmpty(url));
                    }
                }
            }
        }
        System.runAs(user){
        User u = [select id from user where user.contact.customer_registration_agn__c = 'In Progress' and country_code__c = 'DE' limit 1];
        
            System.runAs(u){
                // Instantiate a new controller with all parameters in the page
                AGN_GCSP_CommunitiesLandingController controller = new AGN_GCSP_CommunitiesLandingController();
                PageReference pageRef = controller.forwardToStartPage();
                //PageRef is either null or an empty object in test context
                if(pageRef != null){
                    String url = pageRef.getUrl();
                    if(url != null){
                        System.assertEquals(false, String.isEmpty(url));
                    }
                }
            }
        }
    }
}