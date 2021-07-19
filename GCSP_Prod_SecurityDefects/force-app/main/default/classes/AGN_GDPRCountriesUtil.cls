public class AGN_GDPRCountriesUtil {

    public static Set<String> getCountryCodes() {
        Set<String> COUNTRIES = new Set<String>();
        String countriesString = Label.AGNGDPRCountries;
        if (countriesString != null && !String.isEmpty(countriesString)) {
            for (String code : countriesString.split(';')) {
                COUNTRIES.add(code);
            }
        }
        return COUNTRIES;
    }

        public static Set<String> getConsentCountryCodes() {
            Set<String> COUNTRIES = new Set<String>();
            String countriesString = Label.AGNGDPRConsentCountries;
            if (countriesString != null && !String.isEmpty(countriesString)) {
                for (String code : countriesString.split(';')) {
                    COUNTRIES.add(code);
                }
            }
            return COUNTRIES;
        }

    public static Set<String> getCyprusCities() {
        Set<String> CYPRUS = new Set<String>();
        String citiesString = Label.AGNGDPRCyprusCities;
        if (citiesString != null && !String.isEmpty(citiesString)) {
            for (String code : citiesString.split(';')) {
                CYPRUS.add(code);
            }
        }
        return CYPRUS;
    }

    public static Set<String> getSelfManagedCountries() {
        Set<String> smc = new Set<String>();
        String smcString = Label.AGN_Self_Managed_Countries;
        if (smcString != null && !String.isEmpty(smcString)) {
            for (String code : smcString.split(';')) {
                smc.add(code);
            }
        }
        return smc;
    }

    public static Boolean accountHasCyprusAddressCity(Id accountId) {
        Set<String> cyprusCities = getCyprusCities();
        try {
            Id a = [SELECT Id FROM Address_vod__c WHERE Account_vod__c = :accountId AND City_vod__c IN :cyprusCities AND Country_Code__c NOT IN ('RU') LIMIT 1].Id;
            return a != null;
        } catch (Exception e) {
            return false;
        }
    }

    public static Set<Id> getAccountIdsInCyprus(Set<Id> accountIds) {
        Set<String> cyprusCities = getCyprusCities();
        try {
            Set<Id> result = new Set<Id>();
            List<Address_vod__c> l = [SELECT Account_vod__c FROM Address_vod__c WHERE Account_vod__c IN :accountIds AND City_vod__c IN :cyprusCities AND Country_Code__c NOT IN ('RU')];
            for (Address_vod__c a : l) {
                result.add(a.Account_vod__c);
            }
            return result;
        } catch (Exception e) {
            return new Set<Id>();
        }
    }


}