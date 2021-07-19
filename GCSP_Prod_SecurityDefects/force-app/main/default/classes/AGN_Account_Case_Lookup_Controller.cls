/*
Type Name: AGN_Account_Case_Lookup_Controller
Reason: Custom Account Look up functionality for new Case
03-08-2016 - SG - Initial Version
*/
public with sharing class AGN_Account_Case_Lookup_Controller {
    
    public List<AccountLookupWrapper> results{get;set;} // search results
    public string searchString{get;set;} // search keyword    
    public String searchPersonAccount{get;set;}
    public String searchBusinessAccount{get;set;}
    public String selectedAccount{get;set;}
    //Added by HCO+GCSP team to fetch contact list using SAP Attribute record//
    public String searchSAPAttrRecord{get;set;}
    //Added by HCO+GCSP team to fetch contact list using SAP Attribute record//
    public class AccountLookupWrapper{
        public Account acc {get;set;}
        public boolean shipTo {get;set;}
        public boolean soldTo {get;set;}
        
        public AccountLookupWrapper(Account a){
            acc = a;
        }
    }    
    
    public AGN_Account_Case_Lookup_Controller () {
        
        // get the current search string
        
        searchString = System.currentPageReference().getParameters().get('lksrch');        
        searchPersonAccount = System.currentPageReference().getParameters().get('personAccountID');
        searchBusinessAccount = System.currentPageReference().getParameters().get('businessAccountID');
        //Added by HCO+GCSP team to fetch contact list using SAP Attribute record//
        if(System.currentPageReference().getParameters().get('sapAttributeID') != null && 
           System.currentPageReference().getParameters().get('sapAttributeID') != ''){
        	searchSAPAttrRecord=System.currentPageReference().getParameters().get('sapAttributeID');
           }
        //Added by HCO+GCSP team to fetch contact list using SAP Attribute record//
        search();
        
    }
    
    // performs the keyword search
    public PageReference search() {
        
        results = performSearch(searchString);        
        return null;
    }
    
    private list<AccountLookupWrapper> performSearch(string searchString){
        
        list<AccountLookupWrapper> resultList = new list<AccountLookupWrapper>();
        
        if(searchPersonAccount <> null) {
            map<Id, Child_Account_vod__c> businessMap = new map<Id, Child_Account_vod__c>();
            string soqlbusiness = 'select  Parent_Account_vod__c, Ship_To_AGN__c, Sold_To_AGN__c from Child_Account_vod__c where Child_Account_vod__c ='+'\''+ String.escapeSingleQuotes(searchPersonAccount) +'\'' ;
            for(Child_Account_vod__c c : database.query(soqlbusiness)){
                businessMap.put(c.Parent_Account_vod__c, c);
            }
            
            if (!businessMap.keySet().isEmpty()){
                for (Account a : [select External_ID2_AGN__c, id,name,Type_AGN__c,(SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c,Country_vod__c, Zip_vod__c FROM Address_vod__r) from Account where id in :businessMap.keySet() and isPersonAccount = false]){
                    AccountLookupWrapper accWrap = new AccountLookupWrapper(a);                    
                    accWrap.soldTo = businessMap.get(a.Id).Sold_To_AGN__c;
                    accWrap.shipTo = businessMap.get(a.Id).Ship_To_AGN__c;
                    resultList.add(accWrap);
                }
            }
            else{
                for (Account a : [select External_ID2_AGN__c, id,name,Type_AGN__c,(SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c,Country_vod__c, Zip_vod__c FROM Address_vod__r) from Account where name like : '%'+ String.escapeSingleQuotes(searchString) +'%'  and isPersonAccount = false limit 10]){
                    AccountLookupWrapper accWrap = new AccountLookupWrapper(a);                    
                    resultList.add(accWrap);
                }
                
            }            
        }
        else if (searchBusinessAccount <> null){
            
            /* New lines of code added as a part of CoolSculpting implementation 
            string soqlperson;
            if(searchBusinessAccount == 'all'){
                soqlperson = 'select  Child_Account_vod__c, Ship_To_AGN__c, Sold_To_AGN__c from Child_Account_vod__c where Child_Account_vod__r.isPersonAccount = true Limit 1000';
            }else{
                soqlperson = 'select  Child_Account_vod__c, Ship_To_AGN__c, Sold_To_AGN__c from Child_Account_vod__c where Parent_Account_vod__c ='+'\''+String.escapeSingleQuotes(searchBusinessAccount)+'\'' ;
            }
            /* End of lines of code added as a part of CoolSculpting implementation */
            
            
            //string soqlperson = 'select  Child_Account_vod__c, Ship_To_AGN__c, Sold_To_AGN__c from Child_Account_vod__c where Parent_Account_vod__c ='+'\''+searchBusinessAccount+'\'' ;
            
            //New lines of code starts here :- Added by HCO+GCSP team to fetch contact list using SAP Attribute record//
            string soqlperson;
            system.debug('sapattRec------->'+searchSAPAttrRecord);
            id busaccId;
            
            if(searchSAPAttrRecord <> null && searchSAPAttrRecord <> '000000000000000'){
                busaccId= [select Id,Parent_Account_AGN__c from Customer_Detail_AGN__c where Id =:searchSAPAttrRecord AND SAP_Sold_To_AGN__c = true LIMIT 1].Parent_Account_AGN__c;
                system.debug('busaccid-------->' +busaccId);
               soqlperson= 'select  Child_Account_vod__c, Ship_To_AGN__c, Sold_To_AGN__c from Child_Account_vod__c where Parent_Account_vod__c =:busaccId AND Child_Account_vod__r.isPersonAccount = true' ;
            }
            else{
               if(searchBusinessAccount == 'all'){
                soqlperson = 'select  Child_Account_vod__c, Ship_To_AGN__c, Sold_To_AGN__c from Child_Account_vod__c where Child_Account_vod__r.isPersonAccount = true Limit 1000';
            }
               else
                {
                    soqlperson = 'select  Child_Account_vod__c, Ship_To_AGN__c, Sold_To_AGN__c from Child_Account_vod__c where Parent_Account_vod__c ='+'\''+String.escapeSingleQuotes(searchBusinessAccount)+'\'' ;
                }
                
            }
            //New lines of code ends here :- Added by HCO+GCSP team to fetch contact list using SAP Attribute record//
            
            map<Id, Child_Account_vod__c> personMap =new map<Id, Child_Account_vod__c>();
            for(Child_Account_vod__c c : database.query(soqlperson)){
                personMap.put(c.Child_Account_vod__c, c);
            }
            
            if (!personMap.keySet().isEmpty()){
                for (Account a : [select External_ID2_AGN__c, id,name,Type_AGN__c,(SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c,Country_vod__c, Zip_vod__c FROM Address_vod__r) from Account where id in :personMap.keySet() and isPersonAccount = true limit 1000]){
                    AccountLookupWrapper accWrap = new AccountLookupWrapper(a);
                    accWrap.soldTo = personMap.get(a.Id).Sold_To_AGN__c;
                    accWrap.shipTo = personMap.get(a.Id).Ship_To_AGN__c;
                    resultList.add(accWrap);
                }
                /* New lines of code added as a part of CoolSculpting implementation */
                if(searchBusinessAccount == 'all' && searchString != null && searchString != ''){
                    resultList.clear();
                    for (Account a : [select External_ID2_AGN__c, id,name,Type_AGN__c,(SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c,Country_vod__c, Zip_vod__c FROM Address_vod__r) from Account where name like : '%'+ String.escapeSingleQuotes(searchString) +'%'  and isPersonAccount = true limit 10]){
                        AccountLookupWrapper accWrap = new AccountLookupWrapper(a);
                        resultList.add(accWrap);
                    }
                }
                /* End of lines of code added as a part of CoolSculpting implementation */
            }
            else{
                for (Account a : [select External_ID2_AGN__c, id,name,Type_AGN__c,(SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c,Country_vod__c, Zip_vod__c FROM Address_vod__r) from Account where name like : '%'+ String.escapeSingleQuotes(searchString) +'%'  and isPersonAccount = true limit 10]){
                    AccountLookupWrapper accWrap = new AccountLookupWrapper(a);
                    resultList.add(accWrap);
                }
            }                        
        }
        
        return resultList;        
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