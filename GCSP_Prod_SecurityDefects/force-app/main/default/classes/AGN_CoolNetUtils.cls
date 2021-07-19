public class AGN_CoolNetUtils {

    /*
    * Added part of MEA country roll out
    * Will return cluster country code if User country code matches with Setting value
    * else User's country code will be returned
    */
    public static String getUserCountryCode() {

        List<User> currentUserInfo = [Select Country_Code__c From User Where Id =: Userinfo.getUserid()];
        
        System.debug('User Country Code -> ' + currentUserInfo[0].Country_Code__c);

        if(String.isEmpty(currentUserInfo[0].Country_Code__c)){
            return currentUserInfo[0].Country_Code__c;
        }

        List<CoolNet_Cluster_Country_AGN__mdt> clusterCountryMapping = [Select Destination_Country_AGN__c 
                                                                        From CoolNet_Cluster_Country_AGN__mdt 
                                                                        Where DeveloperName =: currentUserInfo[0].Country_Code__c.toUppercase()];
        
        if(clusterCountryMapping.isEmpty()){
            return currentUserInfo[0].Country_Code__c;
        }
        else{
            System.debug('Clusert Country Code -> ' + clusterCountryMapping[0].Destination_Country_AGN__c);
            return clusterCountryMapping[0].Destination_Country_AGN__c;
        }
    }
}