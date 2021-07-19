public with sharing class TerritoryUtilitiesExtensionController {
    public TerritoryUtilitiesExtensionController(ApexPages.StandardSetController controller) {
    }

    public TerritoryUtilitiesExtensionController(ApexPages.StandardController controller) {
    }

    public TerritoryUtilitiesExtensionController() {
    }

    public static boolean getIsSandbox() {
        Map<String, boolean> result = VeevaOrgConfigurationService.getOrgConfigWithFeatures('sandbox');
        return result.get('sandbox');
    }
}