public with sharing class MyInsightsController {

    public MyInsightsController(ApexPages.StandardSetController controller) {
    }

    public MyInsightsController(ApexPages.StandardController controller) {
    }

    public MyInsightsController() {
    }

    public static Boolean getIsSandbox() {
        Map<String,boolean> result = VeevaOrgConfigurationService.getOrgConfigWithFeatures('sandbox');
        return result.get('sandbox');
    }

    public static String getOrgDomainUrl() {
        return URL.getOrgDomainUrl().toExternalForm();
    }
}