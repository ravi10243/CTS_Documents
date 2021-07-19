@isTest
global class AGN_ICLCountrySelector_Test implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
       
        System.assertEquals('https://geoip.maxmind.com/geoip/v2.1/country/203.132.214.84', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"continent":{"code":"AS","geoname_id":6255147,"names":{"fr":"Asie","ja":"アジア","pt-BR":"Ásia","ru":"Азия","zh-CN":"亚洲","de":"Asien","en":"Asia","es":"Asia"}},"country":{"iso_code":"IN","geoname_id":1269750,"names":{"ru":"Индия","zh-CN":"印度","de":"Indien","en":"United Kingdom","es":"India","fr":"Inde","ja":"インド","pt-BR":"Índia"}},"maxmind":{"queries_remaining":48931},"registered_country":{"iso_code":"IN","geoname_id":1269750,"names":{"fr":"Inde","ja":"インド","pt-BR":"Índia","ru":"Индия","zh-CN":"印度","de":"Indien","en":"India","es":"India"}},"traits":{"ip_address":"203.132.214.86"}}');
        res.setStatusCode(200);
        return res;
    }
 
     @isTest(SeeAllData=true)
    public static void test()
    {
        Test.Starttest();
        Test.setMock(HttpCalloutMock.class, new AGN_ICLCountrySelector_Test());
        AGN_ICL_Country_Settings__c aic=new AGN_ICL_Country_Settings__c ();
     
         
      System.currentPageReference().getHeaders().put('X-Salesforce-SIP', '203.132.214.84'); 
            
        AGN_ICLCountrySelector ai=new AGN_ICLCountrySelector();
       		
        	 ai.SelectOptn='Saudi';
             ai.country='UK';
             ai.moveToCommunity(); 
             ai.countryRedirect();
             ai.getcountryList();
             ai.getDefCountryICLUser();
             
        
        Test.StopTest();      
    }
   

}