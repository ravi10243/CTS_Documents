/*
Modified by :ICL Project Team
Description: Updated the code with null check condition so that geolocation can be set to null for incorrect addresses.
Release :ICL Wave-3
*/

public class AGN_LocatorListingTriggerHandler {
    
    public static void setGeoLocation(List<Locator_Listing_AGN__c> triggerNewList, Map<Id, Locator_Listing_AGN__c> triggerOldMap, Boolean isInsert){  
        
        list<Id> locatorIds = new list<Id>();         
        for (Locator_Listing_AGN__c locator : triggerNewList){
            if (Limits.getFutureCalls() == Limits.getLimitFutureCalls())
                return;                
            Boolean needsGeo = isInsert;
            if (!needsGeo) {
                Locator_Listing_AGN__c oldLocator = triggerOldMap.get(locator.Id);
                needsGeo = locator.GeoLocation_AGN__Latitude__s == null ||
                    locator.GeoLocation_AGN__Longitude__s == null ||
                    locator.Street_AGN__c != oldLocator.Street_AGN__c || 
                    locator.City_AGN__c != oldLocator.City_AGN__c ||
                    locator.State_Providence_Region_AGN__c != oldLocator.State_Providence_Region_AGN__c ||
                    locator.Zip_Code_AGN__c != oldLocator.Zip_Code_AGN__c ||
                    locator.Country_AGN__c != oldLocator.Country_AGN__c;
            }
            
            if (needsGeo) locatorIds.add(locator.Id);
            if (locatorIds.size() == 5) {
                getGeolocation(locatorIds);
                locatorIds = new list<Id>{};
                    }
        }     
        if (locatorIds.size() > 0)
            getGeolocation(locatorIds);
        
    }
    
    @future (callout=true) 
    static public void getGeolocation(list<Id> locIds) {
        String privateKey = AGN_Settings__c.getOrgDefaults().GooglePrivateKey_AGN__c.replace('-','+').replace('_','/');
        String clientId = AGN_Settings__c.getOrgDefaults().GoogleClientID_AGN__c;
        
        list<Locator_Listing_AGN__c> locators = [SELECT Street_AGN__c,City_AGN__c,State_Providence_Region_AGN__c,Zip_Code_AGN__c,Country_AGN__c,GeoLocation_AGN__c FROM Locator_Listing_AGN__c WHERE Id IN :locIds];
        map<Id,Double> latMap = new map<Id,Double>();
        map<Id,Double> lonMap = new map<Id,Double>();
        for (Locator_Listing_AGN__c locator : locators) {
            String address = '';
            if (locator.Street_AGN__c != null) address += locator.Street_AGN__c +', ';
            if (locator.City_AGN__c != null) address += locator.City_AGN__c +', ';
            if (locator.State_Providence_Region_AGN__c != null) address += locator.State_Providence_Region_AGN__c +' ';
            if (locator.Zip_Code_AGN__c != null) address += locator.Zip_Code_AGN__c +', ';
            if (locator.Country_AGN__c != null) address += locator.Country_AGN__c;
            
            address = EncodingUtil.urlEncode(address,'UTF-8');
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&client='+clientId+'&signature=' + EncodingUtil.base64Encode(Crypto.generateMAC('hmacSHA1',Blob.valueOf('/maps/api/geocode/json?address='+address+'&client=gme-allerganinc'),EncodingUtil.base64Decode(privateKey))).replace('+','-').replace('/','_'));
            req.setMethod('GET');
            req.setTimeout(60000);
            
            try {
                String response;
                if (Test.isRunningTest()) {
                    response = '{"location" : {"lat" : 40,"lng" : -75}}';
                } else {
                    HttpResponse res = h.send(req);
                    response = res.getBody();
                }
                JSONParser parser = JSON.createParser(response);
                double lat = null;
                double lon = null;
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')){
                        parser.nextToken();
                        while (parser.nextToken() != JSONToken.END_OBJECT) {
                            String txt = parser.getText();
                            parser.nextToken();
                            if (txt == 'lat') lat = parser.getDoubleValue();
                            else if (txt == 'lng') lon = parser.getDoubleValue();
                        }
                        
                    }
                }
                
                if (lat != null) {
                    latMap.put(locator.Id,lat);
                    lonMap.put(locator.Id,lon);
                }
            } catch (Exception e) {

            }
        }
        list<Locator_Listing_AGN__c> updatedLocs = new list<Locator_Listing_AGN__c>{};
            for (Locator_Listing_AGN__c locator : locators) {
                
                 //Updated the code with null check condition so that geolocation can be set to null for incorrect addresses.
                
                if (latMap.containsKey(locator.Id) && latMap.get(locator.Id)!=null) {
                    locator.GeoLocation_AGN__Latitude__s = latMap.get(locator.Id);
                    locator.GeoLocation_AGN__Longitude__s = lonMap.get(locator.Id);
                    updatedLocs.add(locator);
                }
               else
                {
                    locator.GeoLocation_AGN__Latitude__s = null;
                    locator.GeoLocation_AGN__Longitude__s = null;
                    updatedLocs.add(locator);
                }
                
            }
           //End
        //------CheckMarx Phase2--Added on 24/09/2020----------   
                              //  String objLoc = 'Locator_Listing_AGN__c';
                              //  SObjectType locatorlistObjType = ((SObject)(Type.forName('Schema.'+objLoc).newInstance())).getSObjectType();
                              //  AGN_FLSCheck.check(updatedLocs,locatorlistObjType,'UPDATE');
      //------CheckMarx Phase2--Ends here---------- 

        update updatedLocs;
    }
    
    
    @future (callout=true)
    public static void refreshSiteCache(){
        string url = 'http://www.coolsculpting.com/api/RefreshLocationsCache';        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(url);
        request.setHeader('Content-Length', '0');
        Http http = new Http();        
        if(Test.isRunningTest())
            return;
        else
            http.send(request);
    }    
    
}