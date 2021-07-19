@isTest
global class AGN_AMI_SC_CountrySelectorControllerTest implements HttpCalloutMock { 
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       // System.assertEquals('https://geoip.maxmind.com/geoip/v2.1/country/'+'203.132.214.84', req.getEndpoint());
       // System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"continent":{"code":"AS","geoname_id":6255147,"names":{"fr":"Asie","ja":"アジア","pt-BR":"Ásia","ru":"Азия","zh-CN":"亚洲","de":"Asien","en":"Asia","es":"Asia"}},"country":{"iso_code":"IN","geoname_id":1269750,"names":{"ru":"Индия","zh-CN":"印度","de":"Indien","en":"United Kingdom","es":"India","fr":"Inde","ja":"インド","pt-BR":"Índia"}},"maxmind":{"queries_remaining":48931},"registered_country":{"iso_code":"IN","geoname_id":1269750,"names":{"fr":"Inde","ja":"インド","pt-BR":"Índia","ru":"Индия","zh-CN":"印度","de":"Indien","en":"India","es":"India"}},"traits":{"ip_address":"203.132.214.86"}}');
        res.setStatusCode(200);
        return res;
    }
    
    
    @isTest(SeeAllData=true)
    public static void testCountrySelectorController()
    {  
     AGN_AMI_SC_URL_Redirect_Setting__mdt aur = [Select label,AGN_AMI_Default_Language_AGN__c,AGN_AMI_Redirect_URL__c,AGN_AMI_Country_Code__c 
                                                    from AGN_AMI_SC_URL_Redirect_Setting__mdt 
                                                    where AGN_AMI_Country_Code__c = 'FR'];
     
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new AGN_AMI_SC_CountrySelectorControllerTest());
        System.currentPageReference().getHeaders().put('X-Salesforce-SIP', '203.132.214.84'); 
        System.currentPageReference().getParameters().put('country', 'FR');
        AGN_AMI_SC_CountrySelectorController countrySelectorController = new AGN_AMI_SC_CountrySelectorController(); 
        System.assertNotEquals(null, countrySelectorController);
        countrySelectorController.countryChange();
        countrySelectorController.getcountryList();
		countrySelectorController.getImageName();
		countrySelectorController.getDefCountryAMISCUser();
        countrySelectorController.countryRedirect(); 
        PageReference testpr1 = countrySelectorController.moveToCommunity();
        countrySelectorController.SelectOptn='2';
        PageReference testpr2 = countrySelectorController.moveToCommunity();
        countrySelectorController.SelectOptn='1';
        PageReference testpr3 = countrySelectorController.moveToCommunity();
        Test.stopTest();
    }
}