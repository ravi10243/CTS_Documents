// 29-Jan 2016: Core Release R004 # 271:
// Controller for popup dialog page for the custom account lookup in DCR

public with sharing class AGN_Custom_Account_Lookup_Controller {
    
    public Account account {get;set;} // new account to create
    public List<Account> results{get;set;} // search results
    public string searchString{get;set;} // search keyword
    public string searchApprovalType{get;set;} // search keyword
    public boolean searchIsPersonAccount{get;set;} // search keyword
    
    public AGN_Custom_Account_Lookup_Controller() {
        account = new Account();
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        searchApprovalType = System.currentPageReference().getParameters().get('approvalType');
        searchIsPersonAccount = Boolean.valueOf(System.currentPageReference().getParameters().get('isPersonAccount'));
        runSearch();  
    }
    
    // performs the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }
    
    // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch(searchString,searchApprovalType,searchIsPersonAccount);
    }
    
    // run the search and return the records found. 
    private List<Account> performSearch(string searchString, string searchApprovalType,boolean searchIsPersonAccount) {
        
        String soql = 'SELECT Id, Name, Type_AGN__c,Status_AGN__c,Other_Name_AGN__c, (SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c,Country_vod__c, Zip_vod__c FROM Address_vod__r) FROM Account WHERE Id<>null';
        if(searchApprovalType != '' && searchApprovalType != null)
            if(searchApprovalType.contains('Data'))
                soql = soql +  ' AND External_ID_vod__c != \'\' AND IsPersonAccount=' + searchIsPersonAccount;
            else
                soql = soql +  ' AND External_ID_vod__c = \'\' AND IsPersonAccount=' + searchIsPersonAccount;
                
        if (searchString != '' && searchString != null){
            searchString = String.escapeSingleQuotes(searchString);}
                
        if(searchString != '' && searchString != null)
            soql = soql +  ' AND Name LIKE \'%' + searchString +'%\'';
        soql = soql + ' LIMIT 1000';
        System.debug(soql);
        return database.query(soql); 
    }
    
    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
    
}