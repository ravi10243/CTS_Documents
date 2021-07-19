public with sharing class AGN_LoqateAddressLookupController {

    // TODO move to custom setting
    private static User uInfo{
        get{        
            return [SELECT Name,Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        }
    }
    private static final String FIND_API_ENDPOINT     =  (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Loqate_End_Point__c'); //'https://api.addressy.com/Capture/Interactive/Find/v1.00/json3.ws?Key={0}&Countries=CA'; 
    private static final String RETRIEVE_API_ENDPOINT =  'https://api.addressy.com/Capture/Interactive/Retrieve/v1.00/json3.ws?Key={0}'; 
    private static final String API_KEY               =  (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Loqate_API_Key_AGN__c');// 'PF39-UW17-XY31-EM11'; 
    
    @AuraEnabled
    public static List<String> getFullValidAddresses(String searchTerm, String containerId) {
        List<String> validAddressList = new List<String>();
        try{
            HttpRequest request = new HttpRequest();
            String endpoint = String.format(FIND_API_ENDPOINT, new List<String>{API_KEY}) + '&Text=' + searchTerm.replace(' ', '%20');
            if(!String.isBlank(containerId)) endpoint += '&Container=' + containerId;
            request.setEndpoint(endpoint);
            request.setHeader('Content-Type', 'application/json; charset=utf-8');
            request.setHeader('charset', 'utf-8');
            request.setMethod('GET');

            HttpResponse response = new Http().send(request);
            system.debug('#Response>>>>>>>>>>>>>>>>>>'+response.getBody());
            AddressSearchReponse searchResponse = new AddressSearchReponse();
            searchResponse.Results = (AddressSearchResults)Json.deserialize(response.getBody(), AddressSearchResults.class);
            searchResponse.Results.Items.sort();
            system.debug(searchResponse.Results.Items);
            if(searchResponse.Results != null && searchResponse.Results.Items != null && searchResponse.Results.Items.size() > 0){
                for(AddressSearchResultItem item : searchResponse.Results.Items){
                    //if(item.Type == 'Address'){
                        system.debug(item.Text +'=>'+item.Description);
                        String text = '';
                        if(String.isNotBlank(item.Text)){
                            if(item.Text.contains(',')){
                                text = item.Text.replace(',', '');
                            }else{
                                text = item.Text;
                            }
                        }
                        String description = '';
                        if(String.isNotBlank(item.Description)){
                            if(item.Description.contains(',')){
                                description = item.Description.replace(',', '');
                            }else{
                                description = item.Description;
                            }
                        }
                        if(item.Type != 'Address' && description.contains('Addresses')){
                            description = description.remove('Addresses');
                        }
                        system.debug('text>>>>>>>>>>>>>>>>>'+text);
                        system.debug('description>>>>>>>>>>>>>>>>>'+description);
                        String responseVal = text + ',' +  description;
                        system.debug('address>>>>>>>>>>>>>>>>>>>>>'+searchTerm);
                        system.debug('responseval>>>>>>>>>>>>>>>>>>'+responseVal);
                        validAddressList.add(responseVal);
                        
                    //}   
               }
            }
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return validAddressList;
    }
    
    public static string getEndpointByCountry(String country){
        String endpoint = (String)AGN_GCSP_Settings__c.getValues(country).get('Loqate_End_Point__c');
        return endpoint;
    }
    
    @AuraEnabled
    public static List<String> getValidAddresses(String searchTerm , String country) {
        String containerId = '';
        List<String> validAddressList = new List<String>();
        try{
            HttpRequest request = new HttpRequest();
            String lqendpoint = FIND_API_ENDPOINT;
            if(String.isNotBlank(country)){
                lqendpoint = getEndpointByCountry(country);
            }
            String endpoint = String.format(lqendpoint, new List<String>{API_KEY}) + '&Text=' + searchTerm.replace(' ', '%20');
            if(!String.isBlank(containerId)) endpoint += '&Container=' + containerId;
            request.setEndpoint(endpoint);
            request.setHeader('Content-Type', 'application/json; charset=utf-8');
            request.setHeader('charset', 'utf-8');
            request.setMethod('GET');

            HttpResponse response = new Http().send(request);
            system.debug('#Response>>>>>>>>>>>>>>>>>>'+response.getBody());
            AddressSearchReponse searchResponse = new AddressSearchReponse();
            searchResponse.Results = (AddressSearchResults)Json.deserialize(response.getBody(), AddressSearchResults.class);
            searchResponse.Results.Items.sort();
            system.debug(searchResponse.Results.Items);
            if(searchResponse.Results != null && searchResponse.Results.Items != null && searchResponse.Results.Items.size() > 0){
                for(AddressSearchResultItem item : searchResponse.Results.Items){
                    if(item.Type == 'Address'){
                        if(String.isNotBlank(item.Text)){
                           String text = item.Text;
                           validAddressList.add(text); 
                        } 
                    }
                       
               }
            }
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return validAddressList;
    }

    @AuraEnabled
    public static Boolean getSearchResults(String searchTerm, String containerId) {
        Boolean isReal = false;
        try {
            HttpRequest request = new HttpRequest();
            String endpoint = String.format(FIND_API_ENDPOINT, new List<String>{API_KEY}) + '&Text=' + searchTerm.replace(' ', '%20');
            if(!String.isBlank(containerId)) endpoint += '&Container=' + containerId;
            request.setEndpoint(endpoint);
            request.setHeader('Content-Type', 'application/json; charset=utf-8');
            request.setHeader('charset', 'utf-8');
            request.setMethod('GET');

            HttpResponse response = new Http().send(request);
            system.debug('#Response>>>>>>>>>>>>>>>>>>'+response.getBody());
            AddressSearchReponse searchResponse = new AddressSearchReponse();
            searchResponse.Results = (AddressSearchResults)Json.deserialize(response.getBody(), AddressSearchResults.class);
            searchResponse.Results.Items.sort();
            system.debug(searchResponse.Results.Items);
            if(searchResponse.Results != null && searchResponse.Results.Items != null && searchResponse.Results.Items.size() > 0){
                
                    for(AddressSearchResultItem item : searchResponse.Results.Items){
                        system.debug(item.Text +'=>'+item.Description);
                        String text = '';
                        if(String.isNotBlank(item.Text)){
                            if(item.Text.contains(',')){
                                text = item.Text.replace(',', '');
                            }else{
                                text = item.Text;
                            }
                        }
                        String description = '';
                        if(String.isNotBlank(item.Description)){
                            if(item.Description.contains(',')){
                                description = item.Description.replace(',', '');
                            }else{
                                description = item.Description;
                            }
                        }
                        system.debug('text>>>>>>>>>>>>>>>>>'+text);
                        system.debug('description>>>>>>>>>>>>>>>>>'+description);
                        String responseVal = text + ' ' +  description;
                        system.debug('address>>>>>>>>>>>>>>>>>>>>>'+searchTerm);
                        system.debug('responseval>>>>>>>>>>>>>>>>>>'+responseVal);
                        responseVal = responseVal.replaceAll( '\\s+', '');
                        searchTerm = searchTerm.replaceAll( '\\s+', '');
                        if(item.Type == 'Address' && responseVal.contains(searchTerm)){
                            isReal = true;
                            break;
                        }
                    }
               // }
            }
            //Boolean isReal = AGN_LoqateResponse.isRealAddress(searchTerm , response.getBody());
            //return isReal;
            //return false;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return isReal;
    }
    
    @AuraEnabled
    public static AGN_AddressDetails selectedResult(String selectedAddressId) {
        try {
            HttpRequest request = new HttpRequest();
            String endpoint = String.format(RETRIEVE_API_ENDPOINT, new List<String>{API_KEY}) + '&Id=' + selectedAddressId;
            request.setEndpoint(endpoint);
            request.setHeader('Content-Type', 'application/json; charset=utf-8');
            request.setHeader('charset', 'utf-8');
            request.setMethod('GET');

            HttpResponse response = new Http().send(request);

            AddressDetailResponse addressDetailResponse = (AddressDetailResponse)Json.deserialize(response.getBody(), AddressDetailResponse.class);
            system.debug(addressDetailResponse.Items[0]);
            return addressDetailResponse.Items[0];

        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void saveSelectedResult(Id recordId, String selectedAddressId) {
        try {
            HttpRequest request = new HttpRequest();
            String endpoint = String.format(RETRIEVE_API_ENDPOINT, new List<String>{API_KEY}) + '&Id=' + selectedAddressId;
            request.setEndpoint(endpoint);
            request.setHeader('Content-Type', 'application/json; charset=utf-8');
            request.setHeader('charset', 'utf-8');
            request.setMethod('GET');

            HttpResponse response = new Http().send(request);

            AddressDetailResponse addressDetailResponse = (AddressDetailResponse)Json.deserialize(response.getBody(), AddressDetailResponse.class);

            String street = addressDetailResponse.Items[0].Line1;
            if(!String.isBlank(addressDetailResponse.Items[0].Line2)) street += ', ' + addressDetailResponse.Items[0].Line2;

            SObject record = recordId.getSObjectType().newSObject();
            record.put(Schema.Contact.Id, recordId);
            record.put(Schema.Contact.MailingStreet, street);
            record.put(Schema.Contact.MailingCity, addressDetailResponse.Items[0].City);
            record.put(Schema.Contact.MailingPostalCode, addressDetailResponse.Items[0].PostalCode);
            record.put(Schema.Contact.MailingCountry, addressDetailResponse.Items[0].CountryName);
            update record;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class AddressSearchReponse {
        @AuraEnabled public List<DataTableColumn> Columns {get; private set;}
        @AuraEnabled public AddressSearchResults Results  {get; private set;}

        public AddressSearchReponse() {
            this.columns = new List<DataTableColumn>();
            //this.columns.add(new DataTableColumn('Type', 'Type', 75));
            this.columns.add(new DataTableColumn('Text', 'Address'));
            this.columns.add(new DataTableColumn('Description', 'Location'));
        }
    }

    private class AddressSearchResults {
        @AuraEnabled public List<AddressSearchResultItem> Items {get; private set;}
    }

    private class AddressSearchResultItem implements Comparable {
        @AuraEnabled public String Id          {get; private set;}
        @AuraEnabled public String Type        {get; private set;}
        @AuraEnabled public String Text        {get; private set;}
        @AuraEnabled public String Highlight   {get; private set;}
        @AuraEnabled public String Description {get; private set;}

        public Integer compareTo(Object compareTo) {
            AddressSearchResultItem compareToAddress = (AddressSearchResultItem)compareTo;

            if(this.Type > compareToAddress.Type) return 1;
            else if(this.Type == compareToAddress.Type) return 0;
            else return -1;
        }
    }

    private class DataTableColumn {
        @AuraEnabled public String fieldName    {get; private set;}
        @AuraEnabled public String label        {get; private set;}
        @AuraEnabled public String initialWidth {get; private set;}

        public DataTableColumn(String fieldName, String label) {
            this(fieldName, label, null);
        }

        public DataTableColumn(String fieldName, String label, Integer initialWidth) {
            this.fieldName    = fieldName;
            this.label        = label;
            this.initialWidth = initialWidth + 'px';
        }
    }

    private class AddressDetailResponse {
        @AuraEnabled List<AGN_AddressDetails> Items {get; private set;}        
    }

    /*private class AddressDetail {
        @AuraEnabled public String Id                   {get; private set;}
        @AuraEnabled public String DomesticId           {get; private set;}
        @AuraEnabled public String Language             {get; private set;}
        @AuraEnabled public String LanguageAlternatives {get; private set;}
        @AuraEnabled public String Department           {get; private set;}
        @AuraEnabled public String Company              {get; private set;}
        @AuraEnabled public String SubBuilding          {get; private set;}
        @AuraEnabled public String BuildingNumber       {get; private set;}
        @AuraEnabled public String BuildingName         {get; private set;}
        @AuraEnabled public String SecondaryStreet      {get; private set;}
        @AuraEnabled public String Street               {get; private set;}
        @AuraEnabled public String Block                {get; private set;}
        @AuraEnabled public String Neighbourhood        {get; private set;}
        @AuraEnabled public String District             {get; private set;}
        @AuraEnabled public String City                 {get; private set;}
        @AuraEnabled public String Line1                {get; private set;}
        @AuraEnabled public String Line2                {get; private set;}
        @AuraEnabled public String Line3                {get; private set;}
        @AuraEnabled public String Line4                {get; private set;}
        @AuraEnabled public String Line5                {get; private set;}
        @AuraEnabled public String AdminAreaName        {get; private set;}
        @AuraEnabled public String AdminAreaCode        {get; private set;}
        @AuraEnabled public String Province             {get; private set;}
        @AuraEnabled public String ProvinceName         {get; private set;}
        @AuraEnabled public String ProvinceCode         {get; private set;}
        @AuraEnabled public String PostalCode           {get; private set;}
        @AuraEnabled public String CountryName          {get; private set;}
        @AuraEnabled public String CountryIso2          {get; private set;}
        @AuraEnabled public String CountryIso3          {get; private set;}
        @AuraEnabled public String CountryIsoNumber     {get; private set;}
        @AuraEnabled public String SortingNumber1       {get; private set;}
        @AuraEnabled public String SortingNumber2       {get; private set;}
        @AuraEnabled public String Barcode              {get; private set;}
        @AuraEnabled public String POBoxNumber          {get; private set;}
        @AuraEnabled public String Label                {get; private set;}
        @AuraEnabled public String Type                 {get; private set;}
        @AuraEnabled public String DataLevel            {get; private set;}
        @AuraEnabled public String Field1               {get; private set;}
        @AuraEnabled public String Field2               {get; private set;}
        @AuraEnabled public String Field3               {get; private set;}
        @AuraEnabled public String Field4               {get; private set;}
        @AuraEnabled public String Field5               {get; private set;}
        @AuraEnabled public String Field6               {get; private set;}
        @AuraEnabled public String Field7               {get; private set;}
        @AuraEnabled public String Field8               {get; private set;}
        @AuraEnabled public String Field9               {get; private set;}
        @AuraEnabled public String Field10              {get; private set;}
        @AuraEnabled public String Field11              {get; private set;}
        @AuraEnabled public String Field12              {get; private set;}
        @AuraEnabled public String Field13              {get; private set;}
        @AuraEnabled public String Field14              {get; private set;}
        @AuraEnabled public String Field15              {get; private set;}
        @AuraEnabled public String Field16              {get; private set;}
        @AuraEnabled public String Field17              {get; private set;}
        @AuraEnabled public String Field18              {get; private set;}
        @AuraEnabled public String Field19              {get; private set;}
        @AuraEnabled public String Field20              {get; private set;}
               
    }*/

}