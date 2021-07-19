/**
* Global Account search
*
* @version 2.3 - jkelso - update Sept 30, 2014 (see notes below)
* @version 2.3 - mnaidu - update Jan 14, 2014 (see notes below)
* @version        2.0
* @version Update: 2.1 (7/31/13)
* @author         Veeva Technical Services (Jeff Kelso, Murugesh Naidu, Wayne Abbott)
* Update: mnaidu - 7/16/13 - Added Custom Filtering mechanism and migrated code to GAS Hierarchical Custom settings
* Update: jkelso - 8/9/13 - Added ability to align accounts to multiple territories
* @version Update 2.2 (9/19/2013)
* Upate: mnaidu - 9/19/2013 - This change applies ONLY to the Visualforce page "searchAccts.page". Added condition to identify at run time which is the field
* element to be hyperlinked in the results. Conditional check Coded in VF page so as to make this purely a VF page change so that it can be easy to integrate
* if not a pure GAS 2.2 implementation is used
* Update: mnaidu v2.3 - 1/9/14 - Performance improvement change: Updated the class (method excludeAccountsIfAny) to send the unfiltered accountIds to avoid full table scans when
* deciding accounts to be excluded/included
* Update: mnaidu v2.3 - 1/9/14 -  New feature to allow inclusive filters -  Updated the class (method excludeAccountsIfAny) to recognize Inclusive filters based on Custom setting value
* Update: mnaidu v2.3 - 2/17/14 - Updated excludeAccountsIfAny() method to handle situation where none of the accounts should be included if the criteria does not match the inclusive criteria
* Update: jkelso v2.3 - 9/30/14 - Added patch for SFDC Winter 15 defect that has not been applied to all instances yet. More info here: https://success.salesforce.com/issues_view?id=a1p30000000T5buAAC
* Update : R003 - Cognizant/AR - 12/18/2015 - to enable translation for GAS page
* Update : R004 - Cognizant/AR - 13/01/2016 - control visibility of 'Add to Territory' button by checking GAS_Hierarchical_Setting__c
* Update : R004 - Cognizant/AR - 29/01/2016 - R004- Release Requirement No--280-- Add TSF for Searched Account with Down Load to offline true
* 20 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team
* 13 May 2021 - PMO:3922 Logic updated to create OTA records on global account search -PS
*/
public class AGN_searchAccts{
    public String selectedRecordValue {get; set;}
    public ID act1 {set;get;}
    public String specName {get; set;}
    public Id specId {get; set;}
    public String specNameAGN {get; set;}
    public Id specIdAGN {get; set;}
    public String act2 {set;get;}
    public List<ResultHeader> resultHeaders {set;get;}
    public List<ResultHeader> resultHeadersOnekey {set;get;}
    public String wc {get;set;}
    public String userterrString {get;set;}
    public List <SearchField> acctSearchFields {set;get;}
    public List <SearchField> addrSearchFields {set;get;}
    List<Account> HCAlst = new List<Account>();
    private List<String> acctSearchFieldSet  ;
    private List<String> addrSearchFieldSet  ;
    private List<String> resultFieldSet  ;
    private Set <String> acctResultFields = new Set<String> () ;
    private Set <String> addrResultFields = new Set<String> () ;
    private Map<String, Schema.SObjectField> acctFieldMap ;
    private Map<String, Schema.SObjectField> addrFieldMap ;
    public Map <String,String> resFieldTypeMap = new Map <String,String> () ;
    private Map <String,String> resFieldLabelMap = new Map <String,String> () ;
    public static List<SelectOption> acctRecTypesPlist ;
    public static List<SelectOption> addrRecTypesPlist ;
    private Map <String,String> recTypeXlation = new Map <String,String> () ;
    
    public String parentSearch {set;get;}
    public String parentAcctField {set;get;}
    public String returnElemId {set;get;}
    
    public Boolean showAllAddrs {set;get;}
    public Boolean trackAlignmentHistory {get;set;}
    
    public SearchResult [] results {get;set;}
    
    public SearchResult [] resultsIMS {get;set;}
    
    public Paginate paginater {get;set;}
    public Paginate paginaterIMS {get;set;}
    public Map<String,Boolean> mapFieldToIsEnabled {get;set;}
    public Boolean showOnekey {set;get;}
    public Integer onekeyRecordCount {get;set;}
    public Integer onekeyRecordCountIMS {get;set;}
    public Boolean IsUserOnekeyEnabled {set;get;}
    public Boolean OnekeySearchDone {set;get;}
    public Boolean GASSearchDone {set;get;}
    public String OnekeyMessage {set;get;}
    public String OnekeyCountryCode {set;get;}
    public String OnekeyPromptMessage {set;get;}
    public String OnekeyNoteMessage {set;get;}
    public String OnekeySearchMessage {set;get;}
    public Integer flag_check=0;
    public Integer flag_PerCheck=0;
    public Database.SaveResult bus_sr;
    public Database.SaveResult per_sr;
    public String SelectedOnekeyCountryCode {set;get;}
    map<String,String> mapCreds;
    
    public List<List<SearchResult>> fullGenericList{get;set;}
    public List<List<SearchResult>> fullGenericListIMS{get;set;}
    
    public String sortKey {get;set;}
    public String sortDir {get;set;}
    
    // Custom Labels
    public String GAS_CANCEL {set;get;}
    public String GAS_SEARCH {set;get;}
    public String GAS_LOOKUP {set;get;}
    public String GAS_SFA {set;get;}
    public String GAS_SFPA {set;get;}
    public String GAS_EM {set;get;}
    public String GAS_SW {set;get;}
    public String GAS_CONTAINS {set;get;}
    public static String GAS_NONE {set;get;}
    public String GAS_RESULTS {set;get;}
    public String GAS_ATT {set;get;}
    public String GAS_RFT {set;get;}
    public String GAS_NOCRIT {set;get;}
    public String GAS_NAMESEARCH {set;get;}
    public String GAS_NOMATCH {set;get;}
    public String GAS_TOOMANY {set;get;}
    public String GAS_NOTALGN {set;get;}
    public String GAS_MANYALGN {set;get;}
    public String GAS_INTERR {set;get;}
    public String GAS_SUCCESS {set;get;}
    // 19R2
    public String GAS_EMAIL_SUCCESS {set;get;}
    // 19R2
    public String GAS_HCAMESSAGE{set;get;}
    public String GAS_REMOVE {set;get;}
    public String GAS_SELECT {set;get;}
    public String GAS_CLEAR {set;get;}
    public String GAS_REMOVE_CHECK {set;get;}
    public Boolean GAS_ALIGN_MULTIPLE {get;set;}
    public User theUser;
    public Integer remcchk;
    //R004
    public String GAS_Exclude_ATT{set;get;}
    //R008
    Public String GAS_Exclude_RFT{set;get;}
    Public String GAS_AffPrimary_Account{set;get;}
    public Boolean showATT {get;set;}
    public Boolean showRFT {get;set;}
    
    //R009
    public Boolean GASAff {get;set;}
    public Boolean GASAffHCO {get;set;}
    public Boolean GASAffHCP {get;set;}
    Public String GAS_ClusterCountry{set;get;}
    Public Boolean GASCC{get;set;}
    Public String GASClusterCheck;
    Public String GASClusterCountry ;
    Public String q;
    List<Account> AccPrimaryAffiliation = new List<Account>() ;
    Public List<Child_Account_vod__c> AffiliatedId = new List<Child_Account_vod__c>();
    //Release 09
    public String territoryname {get;set;}
    Public List<SelectOption> territoryhierarchy {get; set;}
    Public List<SelectOption> territoryhierarchy1 {get; set;}
    public User loggedInUser {get; set;}
    public String updateterritoryname {get;set;}
    public Boolean showterrassign {get;set;}
    
    public String strResult {get;set;}
    public String strRequest {get;set;}
    private Boolean IsHCP {get;set;}
    Integer Searchtype;
    
    //R17
    public static String selectedCountry{get;set;}
    
    
    public String getMsgPrompt(){
        
        String mainmsg=Label.AGN_Onekey_Main_Msg;
        mainmsg=mainmsg.replace('$mincount',String.valueof(((paginater.pageNum-1)*20)+1));
        mainmsg=mainmsg.replace('$maxcount',String.valueof(((paginater.totalResults>=(paginater.pageNum*20))? (paginater.pageNum*20) :((paginater.pageNum-1)*20)+Math.mod(paginater.totalResults,20)))) ;
        mainmsg=mainmsg.replace('$totalcount',String.valueof(paginater.totalResults));
        
        return mainmsg;
    }
    
    public String getMsgPromptIMS(){
        
        String mainmsg=Label.AGN_Onekey_Main_Msg;
        mainmsg=mainmsg.replace('$mincount',String.valueof(((paginaterIMS.pageNum-1)*20)+1));
        mainmsg=mainmsg.replace('$maxcount',String.valueof(((paginaterIMS.totalResults>=(paginaterIMS.pageNum*20))? (paginaterIMS.pageNum*20) :((paginaterIMS.pageNum-1)*20)+Math.mod(paginaterIMS.totalResults,20)))) ;
        mainmsg=mainmsg.replace('$totalcount',String.valueof(paginaterIMS.totalResults));
        
        return mainmsg;
    }
    
    
    // Constructor
    public AGN_searchAccts()
    {
        selectedRecordValue='';
        if(String.Valueof(specId) == ''){
            specName='';
        }
        if(String.Valueof(specIdAGN) == ''){
            specNameAGN='';
        }
        
        resultHeadersOnekey =new List<ResultHeader>();
        ResultHeader rhIMS ;
        rhIMS= new ResultHeader () ;
        rhIMS.label = System.Label.AGN_Onekey_FieldLabel_IndividualName ;
        resultHeadersOnekey.add (rhIMS) ;
        
        //Release #Added middleName column in the IMS result
        rhIMS= new ResultHeader () ;
        rhIMS.label = System.Label.AGN_Onekey_FieldLabel_MiddleName;
        resultHeadersOnekey.add (rhIMS) ;
        
        rhIMS = new ResultHeader () ;
        rhIMS.label = System.Label.AGN_Onekey_FieldLabel_WorkplaceName ;
        resultHeadersOnekey.add (rhIMS) ;
        
        //============== R14.2 Niladri =======================
        rhIMS = new ResultHeader () ;
        rhIMS.label = System.Label.AGN_Onekey_FieldLabel_Building_Label ;
        resultHeadersOnekey.add (rhIMS) ;
        
        /*rhIMS = new ResultHeader () ;
rhIMS.label = System.Label.AGN_Onekey_FieldLabel_Legal_Category ;
resultHeadersOnekey.add (rhIMS) ;*/
        //=======================================================
        
        rhIMS= new ResultHeader () ;
        rhIMS.label = System.Label.AGN_Onekey_FieldLabel_AddressLine ;
        resultHeadersOnekey.add (rhIMS) ;
        
        rhIMS= new ResultHeader () ;
        rhIMS.label = System.Label.AGN_Onekey_FieldLabel_City ;
        resultHeadersOnekey.add (rhIMS) ;
        
        
        rhIMS= new ResultHeader () ;
        rhIMS.label = System.Label.AGN_Onekey_FieldLabel_Country ;
        resultHeadersOnekey.add (rhIMS) ;
        
        rhIMS= new ResultHeader () ;
        rhIMS.label = System.Label.AGN_Onekey_FieldLabel_Speciality ;
        resultHeadersOnekey.add (rhIMS) ;
        
        rhIMS= new ResultHeader () ;
        rhIMS.label = System.Label.AGN_Onekey_FieldLabel_Type ;
        resultHeadersOnekey.add (rhIMS) ;
        
        
        
        IsHCP=true;
        showOnekey=false;
        this.paginater=null;
        OnekeySearchDone=false;
        GASSearchDone=false;
        OnekeyPromptMessage=System.Label.AGN_Onekey_Prompt_Msg;
        OnekeyNoteMessage=System.Label.AGN_Onekey_Note_Msg;
        OnekeySearchMessage=System.Label.AGN_Onekey_Search_Message;
        onekeyRecordCount=0;
        onekeyRecordCountIMs=0;
        
        // Release 09  Requirement No 866 @Ajay Singh!
        // Use of Territory and UserTerritory have been replaced by Territory2 and UserTerritory2Association - TM2.0 Implementation - Start
        loggedInUser = [select Id, Name, ProfileId,Country_Code__c,Cluster_User_AGN__c,MA_Medical_Affairs_AGN__c,MA_User_Country_Code_AGN__c,Onekey_Search_Enabled_AGN__c,Enable_Advance_GAS_AGN__c,GAS_ALL_HCO_Addition_AGN__c,GAS_ALL_HCP_Addition_AGN__c
                        FROM User WHERE Id = :UserInfo.getUserId() ];
        
        if (loggedInUser.Enable_Advance_GAS_AGN__c==true)
        {
            showterrassign= true;
        }
        
        List<UserTerritory2Association> utList = new List<UserTerritory2Association>();
        set<Id> utIds = new set<Id>();
        for (UserTerritory2Association ut :[select Territory2Id from UserTerritory2Association where UserId = :loggedInUser.Id AND Territory2.Territory2Model.State ='Active' ])
        {
            utList.add(ut);
            utIds.add(ut.Territory2Id);
        }
        IsUserOnekeyEnabled=loggedInUser.Onekey_Search_Enabled_AGN__c;
        list<Territory2>  childterritory= new list<Territory2>();
        set<Territory2>  Allchildterritory= new set<Territory2>();
        integer k=0;
        for(integer i = 0 ; i<= k ; i++)
        {
            childterritory = Database.query('select name,id from Territory2 where ParentTerritory2Id IN:utIds');
            utIds = new set<Id>();
            if(childterritory.size()>0)
            {
                Allchildterritory.addAll(childterritory);
                for (integer z=0; z<childterritory.size(); z++)
                {
                    utIds.add(childterritory[z].id);
                }
                
                k++;
            }
        }
        //R32020: Req no-- 2644 Logic added for sorting Territory Picklist field in Global Account Search Page.
        List<Territory2>  AllchildterritoryList= new List<Territory2>(Allchildterritory);//R32020: Req no-- 2644
        AllchildterritoryList.sort();//R32020: Req no-- 2644
        territoryhierarchy = new list<SelectOption>();
        territoryhierarchy1 = new list<SelectOption>();
        if (Allchildterritory.size()>999)
        {
            territoryhierarchy.add(new SelectOption('false',label.LOV_EXCEEDED));
            territoryhierarchy1 = new List<SelectOption> (territoryhierarchy);
            //territoryhierarchy1.sort(); //R32020: Req no-- 2644- Commented sorting part,because datasource already sorted.
        }
        else    
        {
            territoryhierarchy.add(new SelectOption('false','--Null--'));
            //territoryhierarchy.add(new SelectOption('A','--Null--')); 
            
            for(Territory2 pvl : AllchildterritoryList)//R32020: Req no-- 2644- Query from sorted List.
            {
                territoryhierarchy.add(new SelectOption(pvl.name,pvl.name));               
            }
            
            //territoryhierarchy.sort();            
            territoryhierarchy1 = new List<SelectOption> (territoryhierarchy);
            
        }
        
        // Use of Territory and UserTerritory have been replaced by Territory2 and UserTerritory2Association - TM2.0 Implementation - End
        // End of Release 09 Requirement No 866 @Ajay Singh
        
        
        results = new List<SearchResult> () ;
        parentSearch = ApexPages.currentPage().getParameters().get('parentSearch');
        parentAcctField = ApexPages.currentPage().getParameters().get('parentAcctField');
        returnElemId = ApexPages.currentPage().getParameters().get('returnElemId');
        String lang = UserInfo.getLanguage() ;
        
        //Get labels from Message_vod__c for user's language
        //mnaidu - 7/18/2013 - This will be moved to a Hierarchical Custom setting in GAS 2.1
        //BEGIN - Apurba Roy - 12/18/2015 - Added the below code to enable translation for Global Account Search
        Message_vod__c [] labels = [SELECT Name,Text_vod__c
                                    FROM Message_vod__c
                                    WHERE Language_vod__c = :lang AND
                                    Category_vod__c = 'Account' AND
                                    Name LIKE 'GAS%' AND
                                    Active_vod__c = true] ;
        Map <String,String> labelMap = new Map <String,String> () ;
        for (Message_vod__c label : labels) {
            labelMap.put(label.Name, String.escapeSingleQuotes(label.Text_vod__c)) ;
        }
        
        if(labels.size() == 0){
            lang = 'en_US';
            labels = [SELECT Name,Text_vod__c
                      FROM Message_vod__c
                      WHERE Language_vod__c = :lang AND
                      Category_vod__c = 'Account' AND
                      Name LIKE 'GAS%' AND
                      Active_vod__c = true] ;
            for (Message_vod__c label : labels) {
                labelMap.put(label.Name, String.escapeSingleQuotes(label.Text_vod__c));
            }
        }
        //END - Trasnlation code
        //Get values of custom settings
        //mnaidu - 7/16/2013 - We should leverage Hierarchy Custom settings for this as it is more suited to this type of transaction. Also should
        //give us the ability to have different search and results columns for different users
        //GASSettings__c gas = [select Account_Search_Field_Set__c,Address_Search_Field_Set__c,Result_Field_Set__c,Show_All_Addresses__c, Track_Alignment_History__c from GASSettings__c where name = 'Main'] ;
        //AGN_Settings__c settings = AGN_Settings__c.getOrgDefaults();
        AGN_Settings__c agnsettings = AGN_Settings__c.getInstance();//R0014
        GAS_Hierarchical_Setting__c gas = GAS_Hierarchical_Setting__c.getInstance();//this returns the appropriate settings for the user based on his user profile
        
        //BEGIN - Apurba Roy - 12/18/2015 - Added the below code to enable translation for Global Account Search
        /*GAS_CANCEL = gas.GAS_Message_Cancel__c ;
GAS_SEARCH = gas.GAS_Message_Search__c;
GAS_LOOKUP = gas.GAS_Message_Lookup__c ;
GAS_SFA = gas.GAS_Message_SFA__c ;
GAS_SFPA = gas.GAS_Message_SFPA__c ;
GAS_EM = gas.GAS_Message_EM__c ;
GAS_SW = gas.GAS_Message_STARTS_WITH__c ;
GAS_CONTAINS = gas.GAS_Message_CONTAINS__c ;
GAS_NONE = gas.GAS_Message_NONE__c ;
GAS_RESULTS = gas.GAS_Message_RESULTS__c ;
GAS_ATT = gas.GAS_Message_ATT__c ;
GAS_NOCRIT = gas.GAS_Message_NoCriteria__c;
GAS_NAMESEARCH = gas.GAS_Message_NameSearch__c ;
GAS_NOMATCH = gas.GAS_Message_NOMATCH__c ;
GAS_TOOMANY = gas.GAS_Message_TOO_MANY__c ;
GAS_NOTALGN = gas.GAS_Message_NOTALIGNED__c ;
GAS_MANYALGN = gas.GAS_Message_MANYALIGN__c;
GAS_INTERR = gas.GAS_Message_INTERR__c ;
GAS_SUCCESS = gas.GAS_Message_SUCCESS__c ;
GAS_SELECT = gas.GAS_Message_SELECT__c ;
GAS_CLEAR = gas.GAS_Message_CLEAR__c ;
GAS_ALIGN_MULTIPLE = gas.Align_Multiple_Territory__c;
// END - Translation Code
*/
        GAS_CANCEL = labelMap.get('GAS_CANCEL') ;
        GAS_SEARCH = labelMap.get('GAS_SEARCH') ;
        GAS_LOOKUP = labelMap.get('GAS_LOOKUP') ;
        GAS_SFA = labelMap.get('GAS_SFA') ;
        GAS_SFPA = labelMap.get('GAS_SFPA') ;
        GAS_EM = labelMap.get('GAS_EM') ;
        GAS_SW = labelMap.get('GAS_SW') ;
        GAS_CONTAINS = labelMap.get('GAS_CONTAINS') ;
        GAS_NONE = labelMap.get('GAS_NONE') ;
        GAS_RESULTS = labelMap.get('GAS_RESULTS') ;
        GAS_ATT = labelMap.get('GAS_ATT') ;
        GAS_RFT = labelMap.get('GAS_RFT') ;
        GAS_NOCRIT = labelMap.get('GAS_NOCRIT') ;
        GAS_NAMESEARCH = labelMap.get('GAS_NAMESEARCH') ;
        GAS_NOMATCH = labelMap.get('GAS_NOMATCH') ;
        GAS_TOOMANY = labelMap.get('GAS_TOOMANY') ;
        GAS_NOTALGN = labelMap.get('GAS_NOTALGN') ;
        GAS_MANYALGN = labelMap.get('GAS_MANYALGN') ;
        GAS_INTERR = labelMap.get('GAS_INTERR') ;
        GAS_SUCCESS = labelMap.get('GAS_SUCCESS') ;
        // 19R2
        GAS_EMAIL_SUCCESS = labelMap.get('GAS_EMAIL_SUCCESS');
        // 19R2
        GAS_HCAMESSAGE = labelMap.get('GAS_HCAMESSAGE') ;
        GAS_REMOVE = labelMap.get('GAS_REMOVE') ;
        GAS_SELECT = labelMap.get('GAS_SELECT') ;
        GAS_CLEAR = labelMap.get('GAS_CLEAR') ;
        GAS_REMOVE_CHECK = labelMap.get('GAS_REMOVE_CHECK') ;
        GAS_ALIGN_MULTIPLE = gas.Align_Multiple_Territory__c;
        //R004 - To control Visibility of Add to Territory Button.
        GAS_Exclude_ATT = agnsettings.GAS_Exclude_Add_to_Territory__c; //R0014
        String AuserCountry = [select Id,Country_Code__c,MA_User_Country_Code_AGN__c from user where id =: UserInfo.getUserId()].Country_Code__c;
        if (GAS_Exclude_ATT == null || !GAS_Exclude_ATT.contains(AuserCountry)) //GAS_Exclude_ATT == null||
            showATT = true;
        else
            showATT = false;
        //R008 - To control Visibility of Remove From Territory Button.
        GAS_Exclude_RFT = agnsettings.GAS_Exclude_Remove_From_Territory_AGN__c; //R0014
        String RuserCountry = [select Id,Country_Code__c,MA_User_Country_Code_AGN__c from user where id =: UserInfo.getUserId()].Country_Code__c;
        if (GAS_Exclude_RFT == null || !GAS_Exclude_RFT.contains(RuserCountry)) //GAS_Exclude_ATT == null||
            showRFT = true;
        else
            showRFT = false;
        
        /*Modified by Manoj Paul for Release 009 Req# 568

GAS_AffPrimary_Account = settings.Add_Primary_Affiliation_AGN__c;
String PrmyAffuserCountry = [select Id,Country_Code__c,MA_User_Country_Code_AGN__c from user where id =: UserInfo.getUserId()].Country_Code__c;
if (GAS_AffPrimary_Account == null || !GAS_AffPrimary_Account.contains(PrmyAffuserCountry)) //GAS_Exclude_ATT == null||
GASAff = false;
else
GASAff = true;*/
        
        
        if (loggedInUser.GAS_ALL_HCO_Addition_AGN__c==true)
        {
            GASAffHCO=true;
        }
        
        else
        {
            GASAffHCO=false;
        }
        
        if(loggedInUser.GAS_ALL_HCP_Addition_AGN__c==true)
        {
            GASAffHCP=true;
        }
        
        else
        {
            GASAffHCP=false;
        }
        
        system.debug('## GASAffHCO: ' + GASAffHCO + '          GASAffHCP: ' + GASAffHCP);
        
        /*-----------End of Modification--------------*/
        
        // Get Record Types for Accounts and Addresses
        // We need to use the translation table, and also filter by sObjectType
        acctRecTypesPlist = new List<SelectOption> () ;
        acctRecTypesPlist.add(new SelectOption('',GAS_NONE)) ;
        for (RecordTypeLocalization rtl : [select ParentId, Parent.Name, Value from RecordTypeLocalization where ParentId in (select Id FROM RecordType where SobjectType = 'Account' AND IsActive = true) and Language = :lang order by Value]) {
            acctRecTypesPlist.add(new SelectOption(rtl.ParentId,rtl.Value));
            recTypeXlation.put (rtl.Parent.Name, rtl.Value) ;
        }
        // Also need to pick up those Record Types not in RecordTypeLocalization
        for (RecordType rt :[select Id,Name from RecordType where SobjectType = 'Account' AND IsActive = true and Id not in (select ParentId FROM RecordTypeLocalization where Language = :lang)]) {
            acctRecTypesPlist.add(new SelectOption(rt.Id,rt.Name));
            recTypeXlation.put (rt.Name, rt.Name) ;
        }
        acctRecTypesPlist = SortOptionList(acctRecTypesPlist) ;
        // Address Record Types
        addrRecTypesPlist = new List<SelectOption> () ;
        addrRecTypesPlist.add(new SelectOption('',GAS_NONE)) ;
        for (RecordTypeLocalization rtl : [select ParentId, Parent.Name, Value from RecordTypeLocalization where ParentId in (select Id FROM RecordType where SobjectType = 'Address_vod__c' AND IsActive = true) and Language = :lang order by Value]) {
            addrRecTypesPlist.add(new SelectOption(rtl.ParentId,rtl.Value));
            recTypeXlation.put (rtl.Parent.Name, rtl.Value) ;
        }
        // Also need to pick up those Record Types not in RecordTypeLocalization
        for (RecordType rt :[select Id,Name from RecordType where SobjectType = 'Address_vod__c' AND IsActive = true and Id not in (select ParentId FROM RecordTypeLocalization where Language = :lang)]) {
            addrRecTypesPlist.add(new SelectOption(rt.Id,rt.Name));
            recTypeXlation.put (rt.Name, rt.Name) ;
        }
        addrRecTypesPlist = SortOptionList(addrRecTypesPlist) ;
        
        
        acctSearchFieldSet = gas.Account_Search_Field_Set__c.split(',') ;
        addrSearchFieldSet = gas.Address_Search_Field_Set__c.split(',') ;
        resultFieldSet = gas.Result_Field_Set__c.split(',') ;
        showAllAddrs = gas.Show_All_Addresses__c ;
        trackAlignmentHistory  = gas.Track_Alignment_History__c;
        
        // Set up search fields                
        acctSearchFields = new List <SearchField> () ;
        acctFieldMap = Schema.SObjectType.Account.fields.getMap();
        for (String f : acctSearchFieldSet) {
            Schema.DescribeFieldResult  dfr = acctFieldMap.get(f).getDescribe() ;
            acctSearchFields.add (new SearchField('Account',dfr,parentsearch)) ;
        }
        //Sujoy
        mapFieldToIsEnabled=new Map<String,Boolean>();
        if(acctSearchFields!=null && acctSearchFields.size()>0){
            for(SearchField sf:acctSearchFields){
                mapFieldToIsEnabled.put(sf.obj+'.'+sf.apiname,true);
            }
        }
        
        
        
        //Sujoy
        addrSearchFields = new List <SearchField> () ;
        addrFieldMap = Schema.SObjectType.Address_vod__c.fields.getMap();
        for (String f : addrSearchFieldSet) {
            Schema.DescribeFieldResult  dfr = addrFieldMap.get(f).getDescribe() ;
            addrSearchFields.add (new SearchField('Address_vod__c',dfr,parentsearch)) ;
        }
        //Sujoy
        
        //R17 Calling method to set State-Country dependency
        changeStateValues();
        //R17 end
        
        if(acctSearchFields!=null && acctSearchFields.size()>0){
            for(SearchField sf:addrSearchFields){
                mapFieldToIsEnabled.put(sf.obj+'.'+sf.apiname,true);
            }
        }
        // Parse resultFieldSet to get result Account and Address fields
        acctResultFields = new Set<String> () ;
        addrResultFields = new Set<String> () ;
        resultHeaders = new List<ResultHeader> () ;
        sortKey = '' ;
        sortDir = 'A' ;
        for (String rf : resultFieldSet) {
            if (sortKey == '') {
                // Set sortKey to first result field in list
                sortKey = rf;
            }
            if (rf.startsWith('ADD.')) {
                String dataType = addrFieldMap.get(rf.replace('ADD.', '')).getDescribe().getType().name() ;
                resFieldTypeMap.put (rf, dataType) ;
                String label = addrFieldMap.get(rf.replace('ADD.', '')).getDescribe().getLabel() ;
                if (dataType == 'Reference') {
                    // We need to add Relationship.Name to acctResultFields
                    String rel = addrFieldMap.get(rf.replace('ADD.', '')).getDescribe().getRelationshipName() ;
                    addrResultFields.add(rel + '.Name') ;
                    // Remove trailing ' ID' from label
                    label = label.replaceFirst(' ID$', '') ;
                }
                resFieldLabelMap.put (rf, label) ;
                addrResultFields.add (rf.replace('ADD.', '')) ;
                ResultHeader rh = new ResultHeader () ;
                rh.label = label ;
                rh.apiname = rf ;
                resultHeaders.add (rh) ;
            }
            else {
                String dataType = acctFieldMap.get(rf).getDescribe().getType().name() ;
                resFieldTypeMap.put (rf, dataType) ;
                String label = acctFieldMap.get(rf).getDescribe().getLabel();
                if (dataType == 'Reference') {
                    // We need to add Relationship.Name to acctResultFields
                    String rel = acctFieldMap.get(rf).getDescribe().getRelationshipName() ;
                    acctResultFields.add(rel + '.Name') ;
                    // Remove trailing ' ID' from label
                    label = label.replaceFirst(' ID$', '') ;
                }
                resFieldLabelMap.put (rf, label) ;
                acctResultFields.add (dataType.equalsignorecase('PICKLIST') ? 'toLabel('+rf+')' : rf) ;
                ResultHeader rh = new ResultHeader () ;
                rh.label = label ;
                rh.apiname = rf ;
                resultHeaders.add (rh) ;
            }
        }
        // Add the fields which we always need for Account and Address
        acctResultFields.add('Id') ;
        acctResultFields.add('FirstName') ;
        acctResultFields.add('LastName') ;
        acctResultFields.add('Name') ;
        acctResultFields.add('IsPersonAccount') ;
        addrResultFields.add('Id') ;
        addrResultFields.add('Account_vod__c') ;
        addrResultFields.add('Primary_vod__c') ;
        
        
        
        
    } //constructor ends //
    
    //R17 Method to set State-Country dependency
    public void changeStateValues()
    {
        GAS_Hierarchical_Setting__c gas = GAS_Hierarchical_Setting__c.getInstance();
        addrSearchFieldSet = gas.Address_Search_Field_Set__c.split(',') ;
        // Calling the wrapper class to set country state values
        addrSearchFields = new List <SearchField> () ;
        addrFieldMap = Schema.SObjectType.Address_vod__c.fields.getMap();
        for (String f : addrSearchFieldSet) {
            Schema.DescribeFieldResult  dfr = addrFieldMap.get(f).getDescribe() ;
            addrSearchFields.add (new SearchField('Address_vod__c',dfr,parentsearch)) ;
        }
        
    } 
    //R17 *end
    
    public void updateterritory()
    {
        if(territoryname=='false')
        {
            updateterritoryname='false';
        }
        else
        {
            updateterritoryname=territoryname;
        }
        showOnekey =false;
        GASSearchDone=false;
    }
    
    public PageReference sortResultsIMS() {
        String newSortKey = ApexPages.currentPage().getParameters().get('sortKey');
        if (newSortKey == sortKey) {
            // Just change sortDir
            if (sortDir == 'A') {
                sortDir = 'D' ;
            }
            else {
                sortDir = 'A' ;
            }
        }
        else {
            sortKey = newSortKey ;
            sortDir = 'A' ;
        }
        resultsIMS = SortSearchResults(resultsIMS, sortKey, sortDir) ;
        return null ;
    }
    
    public PageReference sortResults() {
        String newSortKey = ApexPages.currentPage().getParameters().get('sortKey');
        if (newSortKey == sortKey) {
            // Just change sortDir
            if (sortDir == 'A') {
                sortDir = 'D' ;
            }
            else {
                sortDir = 'A' ;
            }
        }
        else {
            sortKey = newSortKey ;
            sortDir = 'A' ;
        }
        results = SortSearchResults(results, sortKey, sortDir) ;
        return null ;
    }
    
    public PageReference doSearch() {
        system.debug('specId===========>'+specId);
        system.debug('specId===========>'+specName);
        system.debug('specIdAGN===========>'+specIdAGN);
        system.debug('specIdAGN===========>'+specNameAGN);
        if(String.Valueof(specId) == ''){
            specName='';
        }
        if(String.Valueof(specIdAGN) == ''){
            specNameAGN='';
        }
        try {
            showOnekey=false;
            //this.paginater=null;
            OnekeySearchDone=false;
            OnekeyMessage='';
            
            
            mapFieldToIsEnabled.put('Account.Distribution_ID_AGN__c',true);
            mapFieldToIsEnabled.put('Account.External_ID2_AGN__c',true);
            //R14.2
            mapFieldToIsEnabled.put('Account.Name_with_SAP_Id_AGN__c',true);
            mapFieldToIsEnabled.put('Address_vod__c.Brick_vod__c',true);
            mapFieldToIsEnabled.put('Address_vod__c.Phone_vod__c',true);
            mapFieldToIsEnabled.put('Address_vod__c.RecordTypeId',true);
            mapFieldToIsEnabled.put('Account.RecordTypeId',true);
            mapCreds=new map<String,String>();
            List<OneKey_Search_Settings_AGN__c> lstCredentials=[select Veeva_Field_Name_AGN__c,Category_AGN__c from OneKey_Search_Settings_AGN__c
                                                                where Category_AGN__c in('Login.Countries')];
            if(lstCredentials!=null && lstCredentials.size()>0){
                for(OneKey_Search_Settings_AGN__c obj : lstCredentials){
                    mapCreds.put(obj.Category_AGN__c,obj.Veeva_Field_Name_AGN__c);
                }
            }
            
            resultsIMS = new List<SearchResult> () ;
            
            results = new List<SearchResult> () ;
            Set <Id> gotAccts = new Set<Id> ();
            List <ID> acctIds = new List <String> () ;
            List <ID> acctIdsap = new List <String> () ;
            String whereClause = '' ;
            String whereClauseSAP = '' ;
            Boolean searchAddrFirst = false ;
            String prefix = '' ;
            // Determine if user has enetered any values for address search fields
            for (SearchField sf : addrSearchFields) {
                if (sf.value != '' && sf.value != 'null' && sf.value != null) {
                    searchAddrFirst = true  ;
                    prefix = 'Account_vod__r.' ;
                    break ;
                }
            }
            // Boolean got_csz = false; // Got City, State or Zip
            // Boolean got_noncsz = false; // Other than City, State or Zip
            Boolean got_pname = false; // Got person name
            Boolean got_name = false; // Got full name
            
            //R012//Countries using SAP Customer Order (SAP ID) interface
            Boolean SapSearch = false;
            String prefixSAP = '' ;
            AGN_Settings__c gasSAP = AGN_Settings__c.getInstance();
            String SAPcountry = gasSAP.GAS_SAP_Order_Search_AGN__c;
            for (SearchField sf : acctSearchFields) {
                if (sf.apiname == 'External_ID2_AGN__c' && sf.value != '' && sf.value != 'null' && sf.value != null && SAPcountry.contains(loggedInUser.Country_Code__c))
                {
                    SapSearch = true;
                    prefixSAP = 'Account_AGN__r.';
                    break;
                }
            }
            
            System.debug('address search fields:'+addrSearchFields);
            // Combine the search fields
            List <SearchField> allSearchFields = new List <SearchField> () ;
            allSearchFields.addAll(acctSearchFields) ;
            allSearchFields.addAll(addrSearchFields) ;
            Boolean nocriteria=true;
            Boolean hasPrimaryBusiness=false;
            // Go thru each search field
            String selCon='';
            for (SearchField sf : allSearchFields) {
                if (sf.value != '' && sf.value != 'null' && sf.value != null) {
                    String field = sf.apiname ;
                    String fieldSAP = sf.apiname ; //R012
                    String op = '=' ;
                    String value = sf.value.trim();
                    // Escape any quotes in the value
                    //JK - changing to use escapeSingleQuotes method
                    //value = value.replace('\'', '\\\'') ;
                    value = String.escapeSingleQuotes(value);
                    //R012/*
                    if (sf.obj == 'Account') {
                        field = prefix + field ;
                    }
                    if (sf.obj == 'Account' && SapSearch == true ) {
                        fieldSAP = prefixSAP + fieldSAP;
                    }
                    
                    //R012*/
                    if (sf.opt_value == 'Starts With') {
                        op = 'like' ;
                        value = value + '%' ;
                    }
                    if (sf.opt_value == 'Contains') {
                        op = 'like' ;
                        value = '%' + value + '%' ;
                    }
                    
                    if (sf.is_phone) {
                        op = 'like' ;
                        value = getPhoneRegex(value) ;
                    }
                    
                    // Put quotes around val for relevant types
                    if(!sf.no_quote) {
                        value = '\'' + value + '\'' ;
                    }
                    //R012/*
                    if (sf.obj == 'Account' || sf.obj == 'Address_vod__c')  {
                        if (whereClause != '') {
                            whereClause += ' AND ' ;
                        }
                        whereClause += ' ' + field + ' ' + op + ' ' + value;
                        System.debug('field: '+field+','+'op: '+op+','+'value: '+value);
                    }
                    if (sf.obj == 'Account' && SapSearch == true) {
                        if (whereClauseSAP != '') {
                            whereClauseSAP += ' AND ' ;
                        }
                        if (sf.apiname == 'External_ID2_AGN__c') {
                            whereClauseSAP += ' ' + '( Ship_to_Number_AGN__c ' + op + ' ' + value + ' OR Sold_to_Number_AGN__c ' + op + ' ' + value + ')';
                        }
                        else {
                            whereClauseSAP += ' ' + fieldSAP + ' ' + op + ' ' + value;
                        }
                    }
                    //*/
                    if (sf.obj == 'Account') {
                        if (sf.apiname == 'Name') {
                            got_name = true ;
                        }
                        if (sf.apiname == 'FirstName' || sf.apiname == 'LastName') {
                            got_pname = true ;
                        }
                    }
                    
                    if (sf.apiname == 'Country_vod__c' ) {
                        if(sf.plist!=null && sf.plist.size()>0){
                            for(SelectOption tempdata:sf.plist){
                                if(tempdata.getValue()==sf.value){
                                    selCon =tempdata.getLabel() ;
                                }
                            }
                        }
                    }
                    System.debug('Selected Country: '+selCon);
                    if (sf.apiname == 'IsPersonAccount' ) {
                        if(sf.value=='true'){
                            IsHCP=true;
                        }else{
                            IsHCP=false;
                        }
                    }
                    // Release 14 #middleName check veeva  to check if any value
                    if (sf.obj == 'Account' && (sf.apiname == 'Name' || sf.apiname == 'FirstName' || sf.apiname == 'Middle_vod__c' || sf.apiname == 'LastName' || sf.apiname == 'Primary_Parent_vod__c' || sf.apiname == 'Country_vod__c' || sf.apiname == 'Distribution_ID_AGN__c' || sf.apiname == 'External_ID2_AGN__c' || sf.apiname == 'Name_with_SAP_Id_AGN__c') && sf.value!=null) {
                        nocriteria=false;
                    }
                    if (sf.obj == 'Address_vod__c' && (sf.apiname == 'Name' || sf.apiname == 'City_vod__c' || sf.apiname == 'Zip_vod__c' || sf.apiname == 'Brick_vod__c' || sf.apiname == 'State_vod__c') && sf.value!=null) {
                        nocriteria=false;
                    }
                    if ((specName!=null && specName!='') ||  (specNameAGN!=null && specNameAGN!='')) {
                        nocriteria=false;
                    }
                    if (sf.obj == 'Account' && (sf.apiname == 'Status_AGN__c') && sf.value!='Active' && sf.value!='') {
                        nocriteria=false;
                    }
                    if (sf.obj == 'Account' && (sf.apiname == 'Primary_Parent_vod__c') && sf.value!='') {
                        hasPrimaryBusiness=true;
                    }
                }
            }
            wc = whereClause ;
            system.debug('Where....'+whereClause);
            system.debug('WhereSAP....'+whereClauseSAP);
            system.debug('nocriteria....'+nocriteria);
            /*if (whereClause == '' && whereClauseSAP == '') {
this.paginater = new Paginate(0, 0);
this.paginaterIMS = new Paginate(0, 0);
ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING,'Veeva : '+ GAS_NOCRIT));
return null ;
}*/
            if (nocriteria) { //R012
                this.paginater = new Paginate(0, 0);
                this.paginaterIMS = new Paginate(0, 0);
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING,'Veeva : '+ GAS_NOCRIT));
                if(IsUserOnekeyEnabled && parentSearch != '1'){
                    doOnekeySearch();
                }
                return null ;
            }
            if (!IsHCP && hasPrimaryBusiness ) { //R012
                this.paginater = new Paginate(0, 0);
                this.paginaterIMS = new Paginate(0, 0);
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING,'Veeva : '+ System.Label.AGN_Onekey_Msg_Invalid_HCO_Search));
                if(IsUserOnekeyEnabled && parentSearch != '1'){
                    doOnekeySearch();
                }
                return null ;
            }
            if (got_pname == true && got_name == true) {
                this.paginater = new Paginate(0, 0);
                this.paginaterIMS = new Paginate(0, 0);
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'Veeva : '+GAS_NAMESEARCH));
                if(IsUserOnekeyEnabled && parentSearch != '1'){
                    doOnekeySearch();
                }
                return null ;
            }
            if(!isHCP && got_pname){
                
                this.paginater = new Paginate(0, 0);
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'Veeva : '+ System.Label.AGN_Onekey_Msg_HCO_Search));
                if(IsUserOnekeyEnabled && parentSearch != '1'){
                    doOnekeySearch();
                }
                return null;
            }
            if (whereClause != '' && String.Valueof(specId) != '' ) {
                if (searchAddrFirst){
                    whereClause=whereClause+' and (Account_vod__r.Specialty_1_AGN__c=\''+specId+'\' OR Account_vod__r.Specialty_2_AGN__c=\''+specId+'\' OR Account_vod__r.Specialty_3_AGN__c=\''+specId+'\')';
                }else{
                    whereClause=whereClause+' and (Specialty_1_AGN__c=\''+specId+'\' OR Specialty_2_AGN__c=\''+specId+'\' OR Specialty_3_AGN__c=\''+specId+'\')';
                }
            }
            if (whereClause != '' && String.Valueof(specIdAGN) != '' ) {
                if (searchAddrFirst){
                    whereClause=whereClause+' and (Account_vod__r.Specialty_Allergan_1_AGN__c=\''+specIdAGN+'\' OR Account_vod__r.Specialty_Allergan_1_AGN__c=\''+specIdAGN+'\')';
                }else{
                    whereClause=whereClause+' and (Specialty_Allergan_1_AGN__c=\''+specIdAGN+'\' OR Specialty_Allergan_1_AGN__c=\''+specIdAGN+'\')';
                }
            }
            
            // if (got_csz == true && got_noncsz == false) {
            // ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'When enterting city, state or zip, at least one other search criteria must be provided'));
            // return null ;
            // }
            if (searchAddrFirst) {
                for (Address_vod__c ad : Database.query('select Account_vod__c, Account_vod__r.IsPersonAccount from Address_vod__c where ' + whereClause)) {
                    acctIds.add(ad.Account_vod__c) ;
                }
            }
            else {
                String resFields = joinStrings(acctResultFields,',') ;
                // Add Formatted_Name_vod__c if it's not there
                if (!resFields.contains('Formatted_Name_vod__c')) {
                    resFields += ',Formatted_Name_vod__c' ;
                }
                for (Account a : Database.query('select Id,IsPersonAccount from Account where ' + whereClause + ' order by Name,Id limit 2000')) {
                    acctIds.add(a.Id) ;
                }
            }
            system.debug('searchAddrFirst....'+searchAddrFirst+' acctIds '+acctIds);
            //R012/*
            if (SapSearch == true) {
                for (SAP_Customer_Order_AGN__c sap : Database.query('select Account_AGN__c, Account_AGN__r.IsPersonAccount from SAP_Customer_Order_AGN__c where ' + whereClauseSAP + ' order by Name,Id limit 2000')) {
                    acctIdsap.add(sap.Account_AGN__c) ;
                }
            }
            system.debug('Accounts...'+acctIds);
            system.debug('AccountSAP...'+acctIdsap);
            
            //*/
            
            //R012 : For countries using SAP Customer Order, we will have 2 list of account results - 1-account and address, 2-account and SAP ID
            //We will merge these two lists and get the common account Ids from both
            if ( acctIdsap.size()>0 && acctIds.size()>0)
            {
                List<ID> allacctIds = new List <String> () ;
                if (acctIdsap.size() > acctIds.size())
                {
                    for (Id acnt : acctIdsap ) {
                        for (Id acnt2 : acctIds) {
                            if ( acnt == acnt2 ) {
                                allacctIds.add(acnt);
                                break;
                            }
                        }
                        
                    }
                    
                }
                else {
                    for (Id acnt : acctIds ) {
                        for (Id acnt2 : acctIdsap) {
                            if ( acnt == acnt2 ) {
                                allacctIds.add(acnt);
                                break;
                            }
                        }
                        
                    }
                }
                acctIds.clear();
                acctIds.addAll(allacctIds);
            }
            else {
                if ( acctIdsap.size()>0 && acctIds.size() == 0)
                {
                    acctIds.clear();
                    acctIds.addAll(acctIdsap);
                }
            }
            
            system.debug('AccountsALL...'+acctIds);
            wc = 'at 1' ;
            // Error if nothing found
            
            if (acctIds.size() == 0) {
                
                showOnekey=true;
                if(mapCreds.containskey('Login.Countries') && mapCreds.get('Login.Countries')!=null && mapCreds.get('Login.Countries')!='' && selCon!=''){
                    if(!mapCreds.get('Login.Countries').contains(selCon)){
                        showOnekey=false;
                    }
                }  /*
if(IsUserOnekeyEnabled==true){
mapFieldToIsEnabled.put('Account.Distribution_ID_AGN__c',false);
mapFieldToIsEnabled.put('Account.External_ID2_AGN__c',false);
mapFieldToIsEnabled.put('Address_vod__c.Brick_vod__c',false);
mapFieldToIsEnabled.put('Address_vod__c.Phone_vod__c',false);
mapFieldToIsEnabled.put('Address_vod__c.RecordTypeId',false);
mapFieldToIsEnabled.put('Account.RecordTypeId',false);
for (SearchField sf : allSearchFields) {
if (sf.apiname == 'Distribution_ID_AGN__c' ) {
sf.value='' ;
}
if (sf.apiname == 'External_ID2_AGN__c' ) {
sf.value='' ;
}
if (sf.apiname == 'Brick_vod__c' ) {
sf.value='' ;
}
if (sf.apiname == 'Phone_vod__c' ) {
sf.value='' ;
}
if (sf.apiname == 'RecordTypeId' && sf.obj=='Address_vod__c' ) {
sf.value='' ;
}
if (sf.apiname == 'RecordTypeId' && sf.obj=='Account' ) {
sf.value='' ;
}
}
}*/
                
                if(IsUserOnekeyEnabled){
                    doOnekeySearch();
                }
                this.paginater = new Paginate(0, 0);
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'Veeva : '+GAS_NOMATCH));
                return null;
            }
            // If this is a search for parent, remove the account IDs we have found which are not parents.  We can do this
            // by using a GROUP BY clause which counts child accounts per parent.  This query will not return those Accounts
            // which have no child accounts.  Since we can't have more than 1000 elements in :acctIds, error out if we have more than 1000
            if (parentSearch == '1' && acctIds.size() > 1000) {
                
                this.paginater = new Paginate(0, 0);
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'Veeva : '+ GAS_TOOMANY));
                return null;
            }
            Set <ID> distinctAcctIds = new Set<ID>() ;
            if (parentSearch == '1') {
                String query = 'select ' + parentAcctField + ', Count(Id) from Account where Primary_Parent_vod__c  in :acctIds group by ' + parentAcctField + '' ;
                AggregateResult[] groupedResults = database.query(query);
                for (AggregateResult ar : groupedResults)  {
                    distinctAcctIds.add((String)ar.get('Primary_Parent_vod__c')) ;
                }
            }
            else {
                distinctAcctIds.addAll(acctIds) ;
            }
            /*           // Maximum of 20 distinct Accounts
//mnaidu - commenting this section to allow users to use max size using a custom setting attribute
if (distinctAcctIds.size() > 20) {
ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, GAS_TOOMANY));
return null;
}
*/
            // We now do a Parent to Child query to get the Accounts we want, along with their addresses.  Order addresses by Primary Address
            
            String resFields = joinStrings(acctResultFields,',') ;
            // Add Formatted_Name_vod__c if it's not there
            if (!resFields.contains('Formatted_Name_vod__c')) {
                resFields += ',Formatted_Name_vod__c' ;
            }
            
            //mnaidu 7/16/2013 - GAS 2.1 enhancement
            //remove the account ids that need to be excluded
            if(GAS_Hierarchical_Setting__c.getInstance().Do_Criteria_Based_Filtering__c){
                acctIds = excludeAccountsIfAny(acctIds);
            }
            // Error if nothing found
            
            if (acctIds.size() == 0) {
                showOnekey=true;
                if(mapCreds.containskey('Login.Countries') && mapCreds.get('Login.Countries')!=null && mapCreds.get('Login.Countries')!='' && selCon!=''){
                    if(!mapCreds.get('Login.Countries').contains(selCon)){
                        showOnekey=false;
                    }
                } /*
if(IsUserOnekeyEnabled==true){
mapFieldToIsEnabled.put('Account.Distribution_ID_AGN__c',false);
mapFieldToIsEnabled.put('Account.External_ID2_AGN__c',false);
mapFieldToIsEnabled.put('Address_vod__c.Brick_vod__c',false);
mapFieldToIsEnabled.put('Address_vod__c.Phone_vod__c',false);
mapFieldToIsEnabled.put('Address_vod__c.RecordTypeId',false);
mapFieldToIsEnabled.put('Account.RecordTypeId',false);
for (SearchField sf : allSearchFields) {
if (sf.apiname == 'Distribution_ID_AGN__c' ) {
sf.value='' ;
}
if (sf.apiname == 'External_ID2_AGN__c' ) {
sf.value='' ;
}
if (sf.apiname == 'Brick_vod__c' ) {
sf.value='' ;
}
if (sf.apiname == 'Phone_vod__c' ) {
sf.value='' ;
}
if (sf.apiname == 'RecordTypeId' && sf.obj=='Address_vod__c' ) {
sf.value='' ;
}
if (sf.apiname == 'RecordTypeId' && sf.obj=='Account' ) {
sf.value='' ;
}
}
}*/
                if(IsUserOnekeyEnabled){
                    doOnekeySearch();
                }
                this.paginater = new Paginate(0, 0);
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'Veeva : '+GAS_NOMATCH));
                return null;
            }
            
            //mnaidu - GAS 2.2 - Allows users to regulate max display size based on custom setting
            if (acctIds!=null && acctIds.size() > (Integer) GAS_Hierarchical_Setting__c.getInstance().MAX_Allowed_Distinct_Accounts__c) {
                this.paginater = new Paginate(0, 0);
                if(IsUserOnekeyEnabled){
                    doOnekeySearch();
                }
                String warnMessage = GAS_TOOMANY + ' ( Found '+ acctIds.size() + ', Allowed ' + (Integer) GAS_Hierarchical_Setting__c.getInstance().MAX_Allowed_Distinct_Accounts__c +' )';
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'Veeva : '+warnMessage));
                return null;
            }
            
            String q = 'select ' + resFields + ', (select ' + joinStrings(addrResultFields,',') + ' from Address_vod__r order by Primary_vod__c desc, CreatedDate) from Account where Id in :acctIds' ;
            System.debug('addrResultFields: =========>>>'+addrResultFields);
            for (Account a : Database.query(q)) {
                SearchResult mainSR ;
                Integer ix = 0 ;
                if (a.Address_vod__r.size() > 0) {
                    for (Address_vod__c ad : a.Address_vod__r) {
                        // Build the searchResults
                        SearchResult sr = new SearchResult () ;
                        sr.acctId = a.Id ;
                        sr.addrId = a.Address_vod__r[ix].Id ;
                        sr.isSelected = false ;
                        sr.accStatus = a.Status_AGN__c ;
                        // Now get field values
                        sr.srFields = new List<SearchResultField> () ;
                        for (String rf : resultFieldSet) {
                            SearchResultField srf = new SearchResultField () ;
                            srf.apiname = rf ;
                            String typex  = resFieldTypeMap.get(rf) ;
                            if (rf.startsWith('ADD.')) {
                                srf.value = getObjValue(a.Address_vod__r[ix], rf, typex) ;
                                srf.label = resFieldLabelMap.get(rf) ;
                                srf.is_Addr = true ;
                                srf.is_Acct = false ;
                            }
                            else {
                                srf.value = getObjValue(a, rf, typex) ;
                                srf.label = resFieldLabelMap.get(rf) ;
                                // Use Formatted_Name_vod__c for Name
                                
                                if (rf == 'Name') {
                                    srf.value = getObjValue(a, 'Formatted_Name_vod__c', 'String') ;
                                }
                                srf.is_Addr = false ;
                                srf.is_Acct = true ;
                            }
                            // The rawvalue of the srf will be used for sorting
                            srf.rawvalue = srf.value ;
                            if ((typex == 'Date' || typex == 'Datetime') && srf.value != '') {
                                // For sorting purposes, store rawvalue of Date/Datetime as seconds since epoch
                                String dtval = srf.value ;
                                if (typex == 'Date') {
                                    dtval = Datetime.newInstance(Date.parse(srf.value), Time.newInstance(0, 0, 0, 0)).format() ;
                                }
                                srf.rawvalue = (String) Datetime.parse(dtval).getTime().format() ;
                            }
                            sr.srFields.add(srf) ;
                        }
                        sr.acctName = a.Name ;
                        if (ix == 0) {
                            sr.otherAddrs = new List<SearchResult> () ;
                            mainSR = sr ;
                            results.add(mainSR) ;
                        }
                        else {
                            mainSR.otherAddrs.add(sr) ;
                        }
                        ix++ ;
                        // If we are not showing all addresses, and we are done with the first, then break out of loop
                        if (!showAllAddrs) {
                            break ;
                        }
                    }
                }
                else {
                    // No address, just get and set Account info
                    SearchResult sr = new SearchResult () ;
                    sr.acctId = a.Id ;
                    sr.addrId = '' ;
                    sr.isSelected = false ;
                    sr.accStatus = a.Status_AGN__c ;
                    // Now get field values
                    sr.srFields = new List<SearchResultField> () ;
                    for (String rf : resultFieldSet) {
                        SearchResultField srf = new SearchResultField () ;
                        srf.apiname = rf ;
                        String typex  = resFieldTypeMap.get(rf) ;
                        if (rf.startsWith('ADD.')) {
                            srf.value = '' ;
                            srf.label = resFieldLabelMap.get(rf) ;
                            srf.is_Addr = true ;
                            srf.is_Acct = false ;
                        }
                        else {
                            srf.value = getObjValue(a, rf, typex) ;
                            srf.label = resFieldLabelMap.get(rf) ;
                            // Use Formatted_Name_vod__c for Name
                            if (rf == 'Name') {
                                srf.value = getObjValue(a, 'Formatted_Name_vod__c', 'String') ;
                            }
                            srf.is_Addr = false ;
                            srf.is_Acct = true ;
                        }
                        // The rawvalue of the srf will be used for sorting
                        srf.rawvalue = srf.value ;
                        if ((typex == 'Date' || typex == 'Datetime') && srf.value != '') {
                            // For sorting purposes, store rawvalue of Date/Datetime as seconds since epoch
                            String dtval = srf.value ;
                            if (typex == 'Date') {
                                dtval = Datetime.newInstance(Date.parse(srf.value), Time.newInstance(0, 0, 0, 0)).format() ;
                            }
                            srf.rawvalue = (String) Datetime.parse(dtval).getTime().format() ;
                        }
                        sr.srFields.add(srf) ;
                    }
                    sr.acctName = a.Name ;
                    sr.otherAddrs = new List<SearchResult> () ;
                    mainSR = sr ;
                    results.add(mainSR) ;
                }
            }
            // Sort.  Initial sort is by first result field, which has already been set in constructor
            results = SortSearchResults(results, sortKey, sortDir) ;
            if(results.size()>0){
                GASSearchDone=true;
                if(mapCreds.containskey('Login.Countries') && mapCreds.get('Login.Countries')!=null && mapCreds.get('Login.Countries')!='' && selCon!=''){
                    if(!mapCreds.get('Login.Countries').contains(selCon)){
                        GASSearchDone=false;
                    }
                }
            }
            
            onekeyRecordCount=results.size();
            PaginationDemoController();
            if(IsUserOnekeyEnabled){
                doOneKeySearch();
            }
        }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public void saveOneKeyData() {
        
        showOnekey=false;
        String AccId='';
        OnekeyMessage='';
        String strOneKeyId='';
        String oksCountryCode = '';
        if(resultsIMS!=null && resultsIMS.size()>0){
            List<String> lstOneKeyId=new List<String>();
            for (SearchResult sr : resultsIMS) {
                if (sr.isSelected == true) {
                    lstOneKeyId.add(sr.acctName.substring(0,sr.acctName.indexof(':'))) ;
                    OnekeyCountryCode=sr.acctName.substring(sr.acctName.indexof(':')+1);
                    oksCountryCode=OnekeyCountryCode;
                }
            }
            system.debug('lstOneKeyId=======>'+lstOneKeyId);
            system.debug('OnekeyCountryCode=======>'+OnekeyCountryCode);
            List<OneKey_Search_Settings_AGN__c> oksMapping = [select Veeva_Field_Name_AGN__c,OneKey_Field_Name_AGN__c from OneKey_Search_Settings_AGN__c where IMS_Country_Mapping_AGN__c=true AND Category_AGN__c='IMS Save Mapping'];
            JSONGenerator gen = JSON.createGenerator(true);
            
            
            gen.writeStartObject();
            String repCountry='';
            if(IsHCP){
                gen.writestringField('entityType', 'Activity');
            }else{
                gen.writestringField('entityType', 'WorkPlace');
            }
            gen.writestringField('resultSize', '2');
            system.debug('OnekeyCountryCode=====>'+OnekeyCountryCode);
            if(OnekeyCountryCode !=null && OnekeyCountryCode!=''){
                //Country Code Logic Added
                List<OneKey_Search_Settings_AGN__c> countryMapList = [select Field_Type_AGN__c,OneKey_Field_Name_AGN__c,Veeva_Field_Name_AGN__c from OneKey_Search_Settings_AGN__c where IMS_Country_Mapping_AGN__c = true AND Category_AGN__c='IMS Country Mapping'];
                if(countryMapList.size() > 0){
                    for(OneKey_Search_Settings_AGN__c oneKey : countryMapList){
                        if(oneKey.Veeva_Field_Name_AGN__c.contains(OnekeyCountryCode)){
                            repCountry = OnekeyCountryCode;
                            OnekeyCountryCode = oneKey.OneKey_Field_Name_AGN__c;
                            break;
                        }
                    }
                }
                //End
                gen.writestringField('codBase', 'W'+OnekeyCountryCode);
                system.debug('OnekeyCountryCode After Change=====>'+OnekeyCountryCode);
            }
            gen.writeFieldName('fields');
            gen.writeStartArray();
            
            gen.writeStartObject();
            gen.writestringField('name', 'onekeyEid');
            
            gen.writestringField('method', 'EXACT');
            gen.writeFieldName('values');
            gen.writeStartArray();
            for(String strTemp:lstOneKeyId){
                gen.writeStartObject();
                gen.writestringField('values', strTemp);
                strOneKeyId=strTemp;
                gen.writeEndObject();
            }
            gen.writeEndArray();
            gen.writeEndObject();
            
            gen.writeEndArray();
            
            gen.writeEndObject();
            
            strResult=  gen.getAsString();
            String jsonaccnt = gen.getAsString();
            integer indexa=0;
            jsonaccnt=jsonaccnt.deleteWhitespace();
            
            String lastpart='';
            while(jsonaccnt.indexof('{"values":')>=0){
                indexa=jsonaccnt.indexof('{"values":');
                
                lastpart=jsonaccnt.substring(indexa+10,jsonaccnt.length());
                lastpart=lastpart.substring(0,lastpart.indexOf('}'))+lastpart.substring(lastpart.indexOf('}')+1);
                jsonaccnt=jsonaccnt.substring(0,indexa)+lastpart;
            }
            
            
            JSONGenerator gen1 = JSON.createGenerator(true);
            
            
            gen1.writeStartArray();
            gen1.writeStartObject();
            gen1.writestringField('onekeyEid', strOneKeyId);
            if(IsHCP){
                gen1.writestringField('entityType', 'Activity');
            }else{
                gen1.writestringField('entityType', 'WorkPlace');
            }
            gen1.writestringField('alignmentId', 'null');
            gen1.writestringField('territoryId', 'null');
            gen1.writeEndObject();
            gen1.writeEndArray();
            
            
            //below line added to skip the web service call execution during test class run.
            HttpRequest req = new HttpRequest();
            HTTPResponse res = new HTTPResponse();
            HTTPResponse res1 = new HTTPResponse();
            // set up the HTTP request with a method, endpoint, header, and body
            
            req.setMethod('POST');
            
            req.setEndpoint(string.valueof(mapCreds.get('Login.URL')));
            
            
            req.setHeader('Content-Type', 'application/json; charset=utf-8');
            
            String username = mapCreds.get('Login.Username');
            String password = mapCreds.get('Login.Password');
            
            system.debug('Username' + username);
            system.debug('Password' + password);
            
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            
            
            req.setTimeout(120000);
            req.setBody(jsonaccnt);
            
            Http http = new Http();
            req.setHeader('Authorization', authorizationHeader);
            
            
            res = http.send(req);
            strRequest =jsonaccnt;
            
            
            strResult= res.getBody();
            
            JSONParser parser = JSON.createParser(res.getBody());
            
            String strFullResponse=res.getBody();
            system.debug('strFullResponse++++++++>>>>'+strFullResponse);
            
            req.setEndpoint(string.valueof(mapCreds.get('SubmitKey.URL')));
            req.setBody((gen1.getAsString()));
            res1 = http.send(req);
            
            strRequest =gen1.getAsString();
            strResult= res1.getBody();
            
            List<String> strTokenList=new List<String>();
            String strRestToken='';
            String strCurrentToken='';
            while(strFullResponse.indexof('onekeyEid')>=0){
                strCurrentToken=strFullResponse.substring(strFullResponse.indexof('onekeyEid')-2,strFullResponse.indexof('}}}}')+4);
                strFullResponse=strFullResponse.substring(strFullResponse.indexof('}}}}')+5);
                strTokenList.add(strCurrentToken);
            }
            system.debug('strTokenList '+strTokenList);
            
            List<OneKey_Search_Settings_AGN__c> lstMapping=[select OneKey_Field_Name_AGN__c,Veeva_Field_Name_AGN__c,Field_Type_AGN__c,Veeva_Object_Name_AGN__c,Category_AGN__c,LOV_Code_AGN__c from OneKey_Search_Settings_AGN__c];
            system.debug('lstMapping '+lstMapping);
            User user_country=[select Country_Code__c,MA_User_Country_Code_AGN__c,Cluster_User_AGN__c from User where id =: UserInfo.getUserId()];
            user_country.Country_Code__c= repCountry;
            
            List<Map<String,String>> listmapSFDCFieldToValueIndividual=new List<Map<String,String>>();
            List<Map<String,String>> listmapSFDCFieldToValueWorkplace=new List<Map<String,String>>();
            List<Map<String,String>> listmapSFDCFieldToValueActivity=new List<Map<String,String>>();
            List<Map<String,String>> listmapSFDCFieldToValueAddress=new List<Map<String,String>>();
            String strOneKeyFieldName='';
            String strSFDCFieldName='';
            String strOneKeyFieldValue='';
            String strFieldType='';
            String typeCorporateLabel_individual='';
            String typeCorporateLabel_workplace='';
            
            Map<String,String> mapSFDCFieldToValueIndividual;
            Map<String,String> mapSFDCFieldToValueWorkplace;
            Map<String,String> mapSFDCFieldToValueActivity;
            Map<String,String> mapSFDCFieldToValueAddress;
            
            Map<String,String> mapSFDCFieldToValueIndividualTranslate;
            Map<String,String> mapSFDCFieldToValueWorkplaceTranslate;
            Map<String,String> mapSFDCFieldToValueActivityTranslate;
            Map<String,String> mapSFDCFieldToValueAddressTranslate;
            
            Map<String,String> mapSFDCFieldToValueIndividualDoubleTranslate;
            Map<String,String> mapSFDCFieldToValueWorkplaceDoubleTranslate;
            Map<String,String> mapSFDCFieldToValueActivityDoubleTranslate;
            Map<String,String> mapSFDCFieldToValueAddressDoubleTranslate;
            
            Map<String,String> oneKeyIndivdual= new Map<String,String>();
            Map<String,String> oneKeyWorkplace= new  Map<String,String>();
            Map<String,String> oneKeyActivity= new  Map<String,String>();
            Map<String,String> oneKeyAddress= new  Map<String,String>();
            
            String flag='';
            String flag_brick='';
            //String in_clause='';
            //Map<One_Key_Translate_AGN__c,String> field_clause=new Map<String,String>();
            Set<String> in_clause1=new Set<String>();
            Set<String> in_clauseDT=new Set<String>();
            
            if(lstMapping!= null && lstMapping.size()>0 && strTokenList!= null && strTokenList.size()>0){
                for(String strTempToken : strTokenList) {
                    
                    mapSFDCFieldToValueIndividual=new Map<String,String>();
                    mapSFDCFieldToValueWorkplace=new Map<String,String>();
                    mapSFDCFieldToValueActivity=new Map<String,String>();
                    mapSFDCFieldToValueAddress=new Map<String,String>();
                    
                    mapSFDCFieldToValueIndividualTranslate=new Map<String,String>();
                    mapSFDCFieldToValueWorkplaceTranslate=new Map<String,String>();
                    mapSFDCFieldToValueActivityTranslate=new Map<String,String>();
                    mapSFDCFieldToValueAddressTranslate=new Map<String,String>();
                    
                    mapSFDCFieldToValueIndividualDoubleTranslate=new Map<String,String>();
                    mapSFDCFieldToValueWorkplaceDoubleTranslate=new Map<String,String>();
                    mapSFDCFieldToValueActivityDoubleTranslate=new Map<String,String>();
                    mapSFDCFieldToValueAddressDoubleTranslate=new Map<String,String>();
                    
                    
                    
                    for(OneKey_Search_Settings_AGN__c strTemp : lstMapping){
                        strOneKeyFieldName=strTemp.OneKey_Field_Name_AGN__c;
                        strSFDCFieldName=strTemp.Veeva_Field_Name_AGN__c;
                        strOneKeyFieldValue='';
                        strFieldType=strTemp.Field_Type_AGN__c ;
                        JSONParser parsertemp=JSON.createParser(strTempToken);
                        while(parsertemp.nextToken() != null){
                            if(parsertemp.getText().toUpperCase() == 'INDIVIDUAL' || flag.equals('INDIVIDUAL'))
                            {
                                flag='INDIVIDUAL';
                                if(parsertemp.getCurrentToken() == JSONToken.FIELD_NAME)
                                    oneKeyIndivdual.put(parsertemp.getText(),'');
                            }
                            if(parsertemp.getText().toUpperCase() == 'ACTIVITY' || flag.equals('ACTIVITY'))
                            {
                                flag='ACTIVITY';
                                if(parsertemp.getCurrentToken() == JSONToken.FIELD_NAME)
                                    oneKeyActivity.put(parsertemp.getText(),'');
                            }
                            if(parsertemp.getText().toUpperCase() == 'WORKPLACE' || flag.equals('WORKPLACE'))
                            {
                                flag='WORKPLACE';
                                if(parsertemp.getCurrentToken() == JSONToken.FIELD_NAME)
                                    oneKeyWorkplace.put(parsertemp.getText(),'');
                            }
                            if(parsertemp.getText().toUpperCase() == 'WORKPLACEADDRESSES' || flag.equals('ADDRESS'))
                            {
                                flag='ADDRESS';
                                if(parsertemp.getText()=='UG1')
                                    flag_brick='UG1';
                                if(parsertemp.getText()=='UG2')
                                    flag_brick='UG2';
                                if(parsertemp.getText()=='UG3')
                                    flag_brick='UG3';
                                if(parsertemp.getText()=='UG4')
                                    flag_brick='UG4';
                                if(parsertemp.getCurrentToken() == JSONToken.FIELD_NAME)
                                    oneKeyAddress.put(parsertemp.getText(),'');
                                
                            }
                            
                            
                            if ((parsertemp.getCurrentToken() == JSONToken.FIELD_NAME) &&  (parsertemp.getText() == strOneKeyFieldName)){
                                parsertemp.nextToken();
                                if(parsertemp.getText()!=''){
                                    strOneKeyFieldValue=parsertemp.getText();
                                    if(flag=='INDIVIDUAL' && strOneKeyFieldName.equalsIgnoreCase('typeCorporateLabel')){
                                        typeCorporateLabel_individual=strOneKeyFieldValue;
                                    }
                                    if(flag=='WORKPLACE' && strOneKeyFieldName.equalsIgnoreCase('typeCorporateLabel')){
                                        typeCorporateLabel_workplace=strOneKeyFieldValue;
                                    }
                                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate') || strTemp.Category_AGN__c.equalsIgnoreCase('Translate.Global'))
                                    {
                                        if(strFieldType.trim().toUpperCase()=='INDIVIDUAL')
                                        {
                                            if(flag.equalsIgnoreCase('INDIVIDUAL'))
                                            {
                                                if(oneKeyIndivdual!=null && oneKeyIndivdual.containsKey(strOneKeyFieldName))
                                                {
                                                    String oneKeySearchValue='';
                                                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate'))
                                                    {
                                                        oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'W'+OnekeyCountryCode+'.'+strOneKeyFieldValue;
                                                        /*  if(user_country.Country_Code__c.equals('GB'))
oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'WUK.'+strOneKeyFieldValue;
else
oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'W'+user_country.Country_Code__c+'.'+strOneKeyFieldValue; */
                                                        in_clause1.add(oneKeySearchValue);
                                                        mapSFDCFieldToValueIndividualTranslate.put(strTemp.OneKey_Field_Name_AGN__c,oneKeySearchValue);
                                                    }
                                                    else if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate.Global'))
                                                    {
                                                        oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+strOneKeyFieldValue;
                                                        in_clause1.add(oneKeySearchValue);
                                                        mapSFDCFieldToValueIndividualTranslate.put(strTemp.OneKey_Field_Name_AGN__c,oneKeySearchValue);
                                                    }
                                                    mapSFDCFieldToValueIndividual.put(strSFDCFieldName,strOneKeyFieldValue);
                                                }
                                            }
                                        }
                                        if(strFieldType.trim().toUpperCase()=='WORKPLACE')
                                        {
                                            if(flag.equalsIgnoreCase('WORKPLACE'))
                                            {
                                                if(oneKeyWorkplace!=null && oneKeyWorkplace.containsKey(strOneKeyFieldName))
                                                {
                                                    String oneKeySearchValue='';
                                                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate'))
                                                    {
                                                        oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'W'+OnekeyCountryCode+'.'+strOneKeyFieldValue;
                                                        /*  if(user_country.Country_Code__c.equals('GB'))
oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'WUK.'+strOneKeyFieldValue;
else
oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'W'+user_country.Country_Code__c+'.'+strOneKeyFieldValue; */
                                                        in_clause1.add(oneKeySearchValue);
                                                        mapSFDCFieldToValueWorkplaceTranslate.put(strTemp.OneKey_Field_Name_AGN__c,oneKeySearchValue);
                                                    }
                                                    else if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate.Global'))
                                                    {
                                                        oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+strOneKeyFieldValue;
                                                        in_clause1.add(oneKeySearchValue);
                                                        mapSFDCFieldToValueWorkplaceTranslate.put(strTemp.OneKey_Field_Name_AGN__c,oneKeySearchValue);
                                                    }
                                                    mapSFDCFieldToValueWorkplace.put(strSFDCFieldName,strOneKeyFieldValue);
                                                }
                                            }
                                        }
                                        if(strFieldType.trim().toUpperCase()=='ACTIVITY')
                                        {
                                            if(flag.equalsIgnoreCase('ACTIVITY'))
                                            {
                                                if(oneKeyActivity!=null && oneKeyActivity.containsKey(strOneKeyFieldName))
                                                {
                                                    String oneKeySearchValue='';
                                                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate'))
                                                    {
                                                        oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'W'+OnekeyCountryCode+'.'+strOneKeyFieldValue;
                                                        /*  if(user_country.Country_Code__c.equals('GB'))
oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'WUK.'+strOneKeyFieldValue;
else
oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'W'+user_country.Country_Code__c+'.'+strOneKeyFieldValue; */
                                                        in_clause1.add(oneKeySearchValue);
                                                        mapSFDCFieldToValueActivityTranslate.put(strTemp.OneKey_Field_Name_AGN__c,oneKeySearchValue);
                                                    }
                                                    else if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate.Global'))
                                                    {
                                                        oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+strOneKeyFieldValue;
                                                        in_clause1.add(oneKeySearchValue);
                                                        mapSFDCFieldToValueActivityTranslate.put(strTemp.OneKey_Field_Name_AGN__c,oneKeySearchValue);
                                                    }
                                                    mapSFDCFieldToValueActivity.put(strSFDCFieldName,strOneKeyFieldValue);
                                                }
                                            }
                                        }
                                        if(strFieldType.trim().toUpperCase()=='ADDRESS')
                                        {
                                            if(flag.equalsIgnoreCase('ADDRESS'))
                                            {
                                                if(oneKeyAddress!=null && oneKeyAddress.containsKey(strOneKeyFieldName))
                                                {
                                                    String oneKeySearchValue='';
                                                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate'))
                                                    {
                                                        oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'W'+OnekeyCountryCode+'.'+strOneKeyFieldValue;
                                                        /*  if(user_country.Country_Code__c.equals('GB'))
oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'WUK.'+strOneKeyFieldValue;
else
oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+'W'+user_country.Country_Code__c+'.'+strOneKeyFieldValue; */
                                                        in_clause1.add(oneKeySearchValue);
                                                        mapSFDCFieldToValueAddressTranslate.put(strTemp.OneKey_Field_Name_AGN__c,oneKeySearchValue);
                                                    }
                                                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate.Global'))
                                                    {
                                                        oneKeySearchValue=strTemp.LOV_Code_AGN__c+'.'+strOneKeyFieldValue;
                                                        in_clause1.add(oneKeySearchValue);
                                                        mapSFDCFieldToValueAddressTranslate.put(strTemp.OneKey_Field_Name_AGN__c,oneKeySearchValue);
                                                    }
                                                    if(strTemp.Veeva_Field_Name_AGN__c.equals('Brick_vod__c'))
                                                    {
                                                        if(strTemp.Veeva_Object_Name_AGN__c!=null)
                                                        {
                                                            if(strTemp.Veeva_Object_Name_AGN__c.contains(user_country.Country_Code__c) && flag_brick.equalsIgnoreCase(strTemp.LOV_Code_AGN__c))
                                                            {
                                                                in_clause1.add(oneKeySearchValue);
                                                                mapSFDCFieldToValueAddress.put(strSFDCFieldName,strOneKeyFieldValue);
                                                                mapSFDCFieldToValueAddressTranslate.put(strTemp.OneKey_Field_Name_AGN__c,oneKeySearchValue);
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        if(strTemp.OneKey_Field_Name_AGN__c.equalsIgnoreCase('country'))
                                                        {
                                                            if(user_country.Country_Code__c.equals('GB'))
                                                                mapSFDCFieldToValueAddress.put(strSFDCFieldName,'GB');
                                                            else{
                                                                mapSFDCFieldToValueAddress.put(strSFDCFieldName,strOneKeyFieldValue);
                                                            }
                                                        }
                                                        else{
                                                            mapSFDCFieldToValueAddress.put(strSFDCFieldName,strOneKeyFieldValue);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Lookup') || strTemp.Category_AGN__c.equalsIgnoreCase('Direct'))
                                    {
                                        if(flag.equalsIgnoreCase('INDIVIDUAL') && strFieldType.trim().toUpperCase()=='INDIVIDUAL')
                                        {
                                            if(oneKeyIndivdual!=null && oneKeyIndivdual.containsKey(strOneKeyFieldName))
                                            {
                                                mapSFDCFieldToValueIndividual.put(strSFDCFieldName,strOneKeyFieldValue);
                                            }
                                        }
                                        if(flag.equalsIgnoreCase('WORKPLACE') && strFieldType.trim().toUpperCase()=='WORKPLACE')
                                        {
                                            if(oneKeyWorkplace!=null && oneKeyWorkplace.containsKey(strOneKeyFieldName))
                                            {
                                                mapSFDCFieldToValueWorkplace.put(strSFDCFieldName,strOneKeyFieldValue);
                                            }
                                        }
                                        if(flag.equalsIgnoreCase('ACTIVITY') && strFieldType.trim().toUpperCase()=='ACTIVITY')
                                        {
                                            if(oneKeyActivity!=null && oneKeyActivity.containsKey(strOneKeyFieldName))
                                            {
                                                mapSFDCFieldToValueActivity.put(strSFDCFieldName,strOneKeyFieldValue);
                                            }
                                        }
                                        if(flag.equalsIgnoreCase('ADDRESS') && strFieldType.trim().toUpperCase()=='ADDRESS')
                                        {
                                            if(oneKeyAddress!=null && oneKeyAddress.containsKey(strOneKeyFieldName))
                                            {
                                                if(strTemp.Category_AGN__c.equalsIgnoreCase('Lookup') && strSFDCFieldName=='Country_vod__c' && oksMapping.size()>0){
                                                    for(OneKey_Search_Settings_AGN__c ok : oksMapping){
                                                        if(oksCountryCode.contains(ok.OneKey_Field_Name_AGN__c)){
                                                            mapSFDCFieldToValueAddress.put(strSFDCFieldName,ok.Veeva_Field_Name_AGN__c);
                                                            break;
                                                        }else{
                                                            mapSFDCFieldToValueAddress.put(strSFDCFieldName,strOneKeyFieldValue);
                                                        }
                                                    }
                                                }else{
                                                    mapSFDCFieldToValueAddress.put(strSFDCFieldName,strOneKeyFieldValue);
                                                }
                                            }
                                        }
                                    }
                                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Double Translate'))
                                    {
                                        if(flag.equalsIgnoreCase('INDIVIDUAL') && strFieldType.trim().toUpperCase()=='INDIVIDUAL')
                                        {
                                            if(oneKeyIndivdual!=null && oneKeyIndivdual.containsKey(strOneKeyFieldName))
                                            {
                                                in_clauseDT.add(strOneKeyFieldValue);
                                                mapSFDCFieldToValueIndividual.put(strSFDCFieldName,strOneKeyFieldValue);
                                                mapSFDCFieldToValueIndividualDoubleTranslate.put(strTemp.OneKey_Field_Name_AGN__c,strOneKeyFieldValue);
                                            }
                                        }
                                        if(flag.equalsIgnoreCase('WORKPLACE') && strFieldType.trim().toUpperCase()=='WORKPLACE')
                                        {
                                            if(oneKeyWorkplace!=null && oneKeyWorkplace.containsKey(strOneKeyFieldName))
                                            {
                                                in_clauseDT.add(strOneKeyFieldValue);
                                                mapSFDCFieldToValueWorkplace.put(strSFDCFieldName,strOneKeyFieldValue);
                                                mapSFDCFieldToValueWorkplaceDoubleTranslate.put(strTemp.OneKey_Field_Name_AGN__c,strOneKeyFieldValue);
                                            }
                                        }
                                        if(flag.equalsIgnoreCase('ACTIVITY') && strFieldType.trim().toUpperCase()=='ACTIVITY')
                                        {
                                            if(oneKeyActivity!=null && oneKeyActivity.containsKey(strOneKeyFieldName))
                                            {
                                                in_clauseDT.add(strOneKeyFieldValue);
                                                mapSFDCFieldToValueActivity.put(strSFDCFieldName,strOneKeyFieldValue);
                                                mapSFDCFieldToValueActivityDoubleTranslate.put(strTemp.OneKey_Field_Name_AGN__c,strOneKeyFieldValue);
                                            }
                                        }
                                        if(flag.equalsIgnoreCase('ADDRESS') && strFieldType.trim().toUpperCase()=='ADDRESS')
                                        {
                                            if(oneKeyAddress!=null && oneKeyAddress.containsKey(strOneKeyFieldName))
                                            {
                                                in_clauseDT.add(strOneKeyFieldValue);
                                                mapSFDCFieldToValueAddress.put(strSFDCFieldName,strOneKeyFieldValue);
                                                mapSFDCFieldToValueAddressDoubleTranslate.put(strTemp.OneKey_Field_Name_AGN__c,strOneKeyFieldValue);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    system.debug('mapSFDCFieldToValueActivity '+mapSFDCFieldToValueActivity);
                    system.debug('mapSFDCFieldToValueIndividual '+mapSFDCFieldToValueIndividual);
                    system.debug('mapSFDCFieldToValueWorkplace '+mapSFDCFieldToValueWorkplace);
                    system.debug('mapSFDCFieldToValueAddress '+mapSFDCFieldToValueAddress);
                    system.debug('mapSFDCFieldToValueAddressTranslate '+mapSFDCFieldToValueAddressTranslate);
                    system.debug('mapSFDCFieldToValueActivity.size() '+mapSFDCFieldToValueActivity.size());
                    system.debug('mapSFDCFieldToValueIndividual.size() '+mapSFDCFieldToValueIndividual.size());
                    system.debug('mapSFDCFieldToValueWorkplace.size() '+mapSFDCFieldToValueWorkplace.size());
                    system.debug('mapSFDCFieldToValueAddress.size() '+mapSFDCFieldToValueAddress.size());
                    if(mapSFDCFieldToValueIndividual.size() > 0)
                        listmapSFDCFieldToValueIndividual.add(mapSFDCFieldToValueIndividual);
                    if(mapSFDCFieldToValueWorkplace.size() > 0 )
                        listmapSFDCFieldToValueWorkplace.add(mapSFDCFieldToValueWorkplace);
                    if(mapSFDCFieldToValueActivity.size() > 0 )
                        listmapSFDCFieldToValueActivity.add(mapSFDCFieldToValueActivity);
                    if(mapSFDCFieldToValueAddress.size() > 0 )
                        listmapSFDCFieldToValueAddress.add(mapSFDCFieldToValueAddress);
                    
                }
                
            }
            system.debug('oneKeyIndivdual '+oneKeyIndivdual);
            system.debug('oneKeyAddress '+oneKeyAddress);
            system.debug('oneKeyActivity '+oneKeyActivity);
            system.debug('oneKeyWorkplace '+oneKeyWorkplace);
            Map<String,String> MapOnekeyValueToVeevaValue=new Map<String,String>();
            String strValueList='';
            //Query for address record type
            String recordTypeId = [select id from RecordType where SobjectType ='Address_vod__c' AND DeveloperName='CompanyMaintained' ].id;
            
            //Query for Translate
            List<One_Key_Translate_AGN__c> listOfValues = new List<One_Key_Translate_AGN__c>([select COD_ID_CEGEDIM_AGN__c,COD_LONG_LBL_AGN__c from One_Key_Translate_AGN__c where COD_ID_CEGEDIM_AGN__c IN : in_clause1]);
            System.debug('================ One Key Translate Value ================'+listOfValues);
            
            //Query for Double Translate
            List<One_Key_Double_Translate_AGN__c> listOfValuesDT2 = new List<One_Key_Double_Translate_AGN__c>([select CGDM_TYP_AGN__c,COUNTRY_AGN__c,LOV_TYPE_AGN__c,VEEVA_TYP_AGN__c from One_Key_Double_Translate_AGN__c where CGDM_TYP_AGN__c IN : in_clauseDT]);
            
            //Differentiate Lookup,Translate & Double Translate
            Map<String,String> lookupElse = new Map<String,String>();
            Map<String,String> translateElse = new Map<String,String>();
            for(OneKey_Search_Settings_AGN__c strTemps : lstMapping)
            {
                if(strTemps.Category_AGN__c.equalsIgnoreCase('Lookup') && strTemps.Field_Type_AGN__c.equalsIgnoreCase('Individual'))
                {
                    lookupElse.put('Individual_'+strTemps.Veeva_Field_Name_AGN__c,strTemps.Veeva_Field_Name_AGN__c);
                }
                if(strTemps.Category_AGN__c.equalsIgnoreCase('Lookup') && strTemps.Field_Type_AGN__c.equalsIgnoreCase('Workplace'))
                {
                    lookupElse.put('Workplace_'+strTemps.Veeva_Field_Name_AGN__c,strTemps.Veeva_Field_Name_AGN__c);
                }
                if(strTemps.Category_AGN__c.equalsIgnoreCase('Lookup') && strTemps.Field_Type_AGN__c.equalsIgnoreCase('Activity'))
                {
                    lookupElse.put('Activity_'+strTemps.Veeva_Field_Name_AGN__c,strTemps.Veeva_Field_Name_AGN__c);
                }
                if(strTemps.Category_AGN__c.equalsIgnoreCase('Lookup') && strTemps.Field_Type_AGN__c.equalsIgnoreCase('Address'))
                {
                    if(strTemps.Veeva_Field_Name_AGN__c=='Country_vod__c' && oksMapping.size()>0){
                        for(OneKey_Search_Settings_AGN__c ok : oksMapping){
                            if(oksCountryCode.contains(ok.OneKey_Field_Name_AGN__c)){
                                lookupElse.put('Address_'+ok.Veeva_Field_Name_AGN__c,ok.Veeva_Field_Name_AGN__c);
                                break;
                            }
                        }
                    }else{
                        lookupElse.put('Address_'+strTemps.Veeva_Field_Name_AGN__c,strTemps.Veeva_Field_Name_AGN__c);
                    }
                }
                if((strTemps.Category_AGN__c.contains('Translate') || strTemps.Category_AGN__c.contains('translate')) && strTemps.Field_Type_AGN__c.equalsIgnoreCase('Individual'))
                {
                    translateElse.put('Individual_'+strTemps.Veeva_Field_Name_AGN__c,strTemps.Veeva_Field_Name_AGN__c);
                }
                if((strTemps.Category_AGN__c.contains('Translate') || strTemps.Category_AGN__c.contains('translate')) && strTemps.Field_Type_AGN__c.equalsIgnoreCase('Workplace'))
                {
                    translateElse.put('Workplace_'+strTemps.Veeva_Field_Name_AGN__c,strTemps.Veeva_Field_Name_AGN__c);
                }
                if((strTemps.Category_AGN__c.contains('Translate') || strTemps.Category_AGN__c.contains('translate')) && strTemps.Field_Type_AGN__c.equalsIgnoreCase('Activity'))
                {
                    translateElse.put('Activity_'+strTemps.Veeva_Field_Name_AGN__c,strTemps.Veeva_Field_Name_AGN__c);
                }
                if((strTemps.Category_AGN__c.contains('Translate') || strTemps.Category_AGN__c.contains('translate')) && strTemps.Field_Type_AGN__c.equalsIgnoreCase('Address'))
                {
                    translateElse.put('Address_'+strTemps.Veeva_Field_Name_AGN__c,strTemps.Veeva_Field_Name_AGN__c);
                }
            }
            String user_countryGB='';
            if(user_country.Country_Code__c.equals('GB'))
                user_countryGB ='UK';
            else
                user_countryGB=user_country.Country_Code__c;
            //Doule Translate Logic
            for(One_Key_Double_Translate_AGN__c temp : listOfValuesDT2)
            {
                for(OneKey_Search_Settings_AGN__c strTemp : lstMapping)
                {
                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Double Translate'))
                    {
                        if(strTemp.Field_Type_AGN__c.equalsIgnoreCase('Individual'))
                        {
                            if(mapSFDCFieldToValueIndividualDoubleTranslate != null && mapSFDCFieldToValueIndividualDoubleTranslate.containsKey(strTemp.OneKey_Field_Name_AGN__c)){
                                String oneKeyValue=mapSFDCFieldToValueIndividualDoubleTranslate.get(strTemp.OneKey_Field_Name_AGN__c);
                                if(oneKeyValue.equals(temp.CGDM_TYP_AGN__c) && temp.COUNTRY_AGN__c.equals(OnekeyCountryCode) && !temp.LOV_TYPE_AGN__c.equals('RecordtypeId'))
                                {
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(strTemp.Veeva_Field_Name_AGN__c))
                                    {
                                        strValueList='';
                                        strValueList=MapOnekeyValueToVeevaValue.get(strTemp.Veeva_Field_Name_AGN__c)+'Individual- '+mapSFDCFieldToValueIndividual.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.VEEVA_TYP_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                    else
                                    {
                                        strValueList='';
                                        strValueList='Individual- '+mapSFDCFieldToValueIndividual.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.VEEVA_TYP_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                }
                            }
                        }
                        if(strTemp.Field_Type_AGN__c.equalsIgnoreCase('Workplace'))
                        {
                            if(mapSFDCFieldToValueWorkplaceDoubleTranslate!=null && mapSFDCFieldToValueWorkplaceDoubleTranslate.containsKey(strTemp.OneKey_Field_Name_AGN__c)){
                                String oneKeyValue=mapSFDCFieldToValueWorkplaceDoubleTranslate.get(strTemp.OneKey_Field_Name_AGN__c);
                                if(oneKeyValue.equals(temp.CGDM_TYP_AGN__c) && temp.COUNTRY_AGN__c.equals(OnekeyCountryCode) && !temp.LOV_TYPE_AGN__c.equals('RecordtypeId'))
                                {
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(strTemp.Veeva_Field_Name_AGN__c))
                                    {
                                        strValueList=MapOnekeyValueToVeevaValue.get(strTemp.Veeva_Field_Name_AGN__c)+'Workplace- '+mapSFDCFieldToValueWorkplace.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.VEEVA_TYP_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                    else
                                    {
                                        strValueList='';
                                        strValueList='Workplace- '+mapSFDCFieldToValueWorkplace.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.VEEVA_TYP_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                }
                            }
                        }
                        if(strTemp.Field_Type_AGN__c.equalsIgnoreCase('Activity'))
                        {
                            if(mapSFDCFieldToValueActivityDoubleTranslate!=null && mapSFDCFieldToValueActivityDoubleTranslate.containsKey(strTemp.OneKey_Field_Name_AGN__c)){
                                String oneKeyValue=mapSFDCFieldToValueActivityDoubleTranslate.get(strTemp.OneKey_Field_Name_AGN__c);
                                if(oneKeyValue.equals(temp.CGDM_TYP_AGN__c) && temp.COUNTRY_AGN__c.equals(OnekeyCountryCode) && !temp.LOV_TYPE_AGN__c.equals('RecordtypeId'))
                                {
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(strTemp.Veeva_Field_Name_AGN__c))
                                    {
                                        strValueList='';
                                        strValueList=MapOnekeyValueToVeevaValue.get(strTemp.Veeva_Field_Name_AGN__c)+'Activity- '+mapSFDCFieldToValueActivity.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.VEEVA_TYP_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                    else
                                    {
                                        strValueList='';
                                        strValueList='Activity- '+mapSFDCFieldToValueActivity.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.VEEVA_TYP_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                }
                            }
                        }
                        if(strTemp.Field_Type_AGN__c.equalsIgnoreCase('Address'))
                        {
                            if(mapSFDCFieldToValueAddressDoubleTranslate!=null && mapSFDCFieldToValueAddressDoubleTranslate.containsKey(strTemp.OneKey_Field_Name_AGN__c)){
                                String oneKeyValue=mapSFDCFieldToValueAddressDoubleTranslate.get(strTemp.OneKey_Field_Name_AGN__c);
                                if(oneKeyValue.equals(temp.CGDM_TYP_AGN__c) && temp.COUNTRY_AGN__c.equals(OnekeyCountryCode) && !temp.LOV_TYPE_AGN__c.equals('RecordtypeId'))
                                {
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(strTemp.Veeva_Field_Name_AGN__c))
                                    {
                                        strValueList=MapOnekeyValueToVeevaValue.get(strTemp.Veeva_Field_Name_AGN__c)+'Address- '+mapSFDCFieldToValueAddress.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.VEEVA_TYP_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                    else
                                    {
                                        strValueList='';
                                        strValueList='Address- '+mapSFDCFieldToValueAddress.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.VEEVA_TYP_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            
            //Translate Logic
            for(One_Key_Translate_AGN__c temp : listOfValues)
            {
                for(OneKey_Search_Settings_AGN__c strTemp : lstMapping)
                {
                    if(strTemp.Category_AGN__c.equalsIgnoreCase('Translate') || strTemp.Category_AGN__c.equalsIgnoreCase('Translate.Global'))
                    {
                        if(strTemp.Field_Type_AGN__c.equalsIgnoreCase('Individual'))
                        {
                            if(mapSFDCFieldToValueIndividualTranslate.containsKey(strTemp.OneKey_Field_Name_AGN__c))
                            {
                                String value=mapSFDCFieldToValueIndividualTranslate.get(strTemp.OneKey_Field_Name_AGN__c);
                                if(value.equals(temp.COD_ID_CEGEDIM_AGN__c))
                                {
                                    if(MapOnekeyValueToVeevaValue.containsKey(strTemp.Veeva_Field_Name_AGN__c))
                                    {
                                        strValueList='';
                                        strValueList=MapOnekeyValueToVeevaValue.get(strTemp.Veeva_Field_Name_AGN__c)+'Individual- '+mapSFDCFieldToValueIndividual.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.COD_LONG_LBL_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                    else
                                    {
                                        strValueList='';
                                        strValueList='Individual- '+mapSFDCFieldToValueIndividual.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.COD_LONG_LBL_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                }
                            }
                        }
                        if(strTemp.Field_Type_AGN__c.equalsIgnoreCase('Workplace'))
                        {
                            if(mapSFDCFieldToValueWorkplaceTranslate.containsKey(strTemp.OneKey_Field_Name_AGN__c))
                            {
                                String value=mapSFDCFieldToValueWorkplaceTranslate.get(strTemp.OneKey_Field_Name_AGN__c);
                                if(value.equals(temp.COD_ID_CEGEDIM_AGN__c))
                                {
                                    if(MapOnekeyValueToVeevaValue.containsKey(strTemp.Veeva_Field_Name_AGN__c))
                                    {
                                        strValueList='';
                                        strValueList=MapOnekeyValueToVeevaValue.get(strTemp.Veeva_Field_Name_AGN__c)+'Workplace- '+mapSFDCFieldToValueWorkplace.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.COD_LONG_LBL_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                    else
                                    {
                                        strValueList='';
                                        strValueList='Workplace- '+mapSFDCFieldToValueWorkplace.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.COD_LONG_LBL_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                }
                            }
                        }
                        if(strTemp.Field_Type_AGN__c.equalsIgnoreCase('Activity'))
                        {
                            if(mapSFDCFieldToValueActivityTranslate.containsKey(strTemp.OneKey_Field_Name_AGN__c))
                            {
                                String value=mapSFDCFieldToValueActivityTranslate.get(strTemp.OneKey_Field_Name_AGN__c);
                                if(value.equals(temp.COD_ID_CEGEDIM_AGN__c))
                                {
                                    if(MapOnekeyValueToVeevaValue.containsKey(strTemp.Veeva_Field_Name_AGN__c))
                                    {
                                        strValueList='';
                                        strValueList=MapOnekeyValueToVeevaValue.get(strTemp.Veeva_Field_Name_AGN__c)+'Activity- '+mapSFDCFieldToValueActivity.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.COD_LONG_LBL_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                    else
                                    {
                                        strValueList='';
                                        strValueList='Activity- '+mapSFDCFieldToValueActivity.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.COD_LONG_LBL_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                }
                            }
                        }
                        if(strTemp.Field_Type_AGN__c.equalsIgnoreCase('Address'))
                        {
                            if(mapSFDCFieldToValueAddressTranslate.containsKey(strTemp.OneKey_Field_Name_AGN__c))
                            {
                                String value=mapSFDCFieldToValueAddressTranslate.get(strTemp.OneKey_Field_Name_AGN__c);
                                if(value.equals(temp.COD_ID_CEGEDIM_AGN__c))
                                {
                                    if(MapOnekeyValueToVeevaValue.containsKey(strTemp.Veeva_Field_Name_AGN__c))
                                    {
                                        strValueList='';
                                        strValueList=MapOnekeyValueToVeevaValue.get(strTemp.Veeva_Field_Name_AGN__c)+'Address- '+mapSFDCFieldToValueAddress.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.COD_LONG_LBL_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                    else
                                    {
                                        strValueList='';
                                        strValueList='Address- '+mapSFDCFieldToValueAddress.get(strTemp.Veeva_Field_Name_AGN__c)+':'+temp.COD_LONG_LBL_AGN__c+',';
                                        MapOnekeyValueToVeevaValue.put(strTemp.Veeva_Field_Name_AGN__c,strValueList);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            //Lookup logic
            String lookupFlag='';
            
            for(OneKey_Search_Settings_AGN__c strTemps : lstMapping)
            {
                lookupFlag='';
                if(strTemps.Category_AGN__c.equalsIgnoreCase('Lookup'))
                {
                    if(strTemps.Field_Type_AGN__c.equalsIgnoreCase('Individual'))
                    {
                        if(mapSFDCFieldToValueIndividual!=null && mapSFDCFieldToValueIndividual.containsKey(strTemps.Veeva_Field_Name_AGN__c))
                        {
                            String objname = strTemps.Veeva_Object_Name_AGN__c;
                            system.debug('objname individual '+objname);
                            String queryStr='';
                            if(objname.contains('Specialty') || objname.contains('specialty'))
                                queryStr='select id,name from ' + objname + ' where Code_AGN__c LIKE \'SP.W'+OnekeyCountryCode+'.%\'';
                            else
                                queryStr='select id,name from ' + objname;
                            system.debug('queryStr=======>'+queryStr);
                            for (List<sObject> ox : Database.query(queryStr))
                            {
                                system.debug('ox individual '+ox);
                                String oneKeyValue=mapSFDCFieldToValueIndividual.get(strTemps.Veeva_Field_Name_AGN__c);
                                for(sObject val : ox)
                                {
                                    String fieldName='';
                                    fieldName = (String)val.get('Name');
                                    if(oneKeyValue.equalsIgnoreCase(fieldName))
                                    {
                                        if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(strTemps.Veeva_Field_Name_AGN__c))
                                        {
                                            strValueList='';
                                            strValueList=MapOnekeyValueToVeevaValue.get(strTemps.Veeva_Field_Name_AGN__c);
                                            strValueList=strValueList+'Individual- '+mapSFDCFieldToValueIndividual.get(strTemps.Veeva_Field_Name_AGN__c)+':'+(String)val.get('Id')+',';
                                            MapOnekeyValueToVeevaValue.put(strTemps.Veeva_Field_Name_AGN__c,strValueList);
                                            lookupFlag='Match';
                                            break;
                                        }
                                        else
                                        {
                                            strValueList='';
                                            strValueList='Individual- '+mapSFDCFieldToValueIndividual.get(strTemps.Veeva_Field_Name_AGN__c)+':'+(String)val.get('Id')+',';
                                            MapOnekeyValueToVeevaValue.put(strTemps.Veeva_Field_Name_AGN__c,strValueList);
                                            lookupFlag='Match';
                                            break;
                                        }
                                    }
                                }
                                if(lookupFlag.equals('Match'))
                                    break;
                            }
                        }
                    }
                    if(strTemps.Field_Type_AGN__c.equalsIgnoreCase('Workplace'))
                    {
                        if(mapSFDCFieldToValueWorkplace!=null && mapSFDCFieldToValueWorkplace.containsKey(strTemps.Veeva_Field_Name_AGN__c))
                        {
                            String objname = strTemps.Veeva_Object_Name_AGN__c;
                            String queryStr='';
                            if(objname.contains('Specialty') || objname.contains('specialty'))
                                queryStr='select id,name from ' + objname + ' where Code_AGN__c LIKE \'SP.W'+OnekeyCountryCode+'.%\'';
                            else
                                queryStr='select id,name from ' + objname;
                            for (List<sObject> ox : Database.query(queryStr))
                            {
                                system.debug('ox individual '+ox);
                                String oneKeyValue=mapSFDCFieldToValueWorkplace.get(strTemps.Veeva_Field_Name_AGN__c);
                                for(sObject val : ox)
                                {
                                    String fieldName='';
                                    fieldName = (String)val.get('Name');
                                    if(oneKeyValue.equalsIgnoreCase(fieldName))
                                    {
                                        if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(strTemps.Veeva_Field_Name_AGN__c))
                                        {
                                            strValueList='';
                                            strValueList=MapOnekeyValueToVeevaValue.get(strTemps.Veeva_Field_Name_AGN__c);
                                            strValueList=strValueList+'Workplace- '+mapSFDCFieldToValueWorkplace.get(strTemps.Veeva_Field_Name_AGN__c)+':'+(String)val.get('Id')+',';
                                            MapOnekeyValueToVeevaValue.put(strTemps.Veeva_Field_Name_AGN__c,strValueList);
                                            lookupFlag='Match';
                                            break;
                                        }
                                        else
                                        {
                                            strValueList='';
                                            strValueList='Workplace- '+mapSFDCFieldToValueWorkplace.get(strTemps.Veeva_Field_Name_AGN__c)+':'+(String)val.get('Id')+',';
                                            MapOnekeyValueToVeevaValue.put(strTemps.Veeva_Field_Name_AGN__c,strValueList);
                                            lookupFlag='Match';
                                            break;
                                        }
                                    }
                                }
                                if(lookupFlag.equals('Match'))
                                    break;
                            }
                        }
                    }
                    if(strTemps.Field_Type_AGN__c.equalsIgnoreCase('Activity'))
                    {
                        if(mapSFDCFieldToValueActivity !=null && mapSFDCFieldToValueActivity.containsKey(strTemps.Veeva_Field_Name_AGN__c))
                        {
                            String objname = strTemps.Veeva_Object_Name_AGN__c;
                            String queryStr='';
                            if(objname.contains('Specialty') || objname.contains('specialty'))
                                queryStr='select id,name from ' + objname + ' where Code_AGN__c LIKE \'SP.W'+OnekeyCountryCode+'.%\'';
                            else
                                queryStr='select id,name from ' + objname;
                            for (List<sObject> ox : Database.query(queryStr))
                            {
                                system.debug('ox individual '+ox);
                                String oneKeyValue=mapSFDCFieldToValueActivity.get(strTemps.Veeva_Field_Name_AGN__c);
                                for(sObject val : ox)
                                {
                                    String fieldName='';
                                    fieldName = (String)val.get('Name');
                                    if(oneKeyValue.equalsIgnoreCase(fieldName))
                                    {
                                        if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(strTemps.Veeva_Field_Name_AGN__c))
                                        {
                                            strValueList='';
                                            strValueList=MapOnekeyValueToVeevaValue.get(strTemps.Veeva_Field_Name_AGN__c);
                                            strValueList=strValueList+'Activity- '+mapSFDCFieldToValueActivity.get(strTemps.Veeva_Field_Name_AGN__c)+':'+(String)val.get('Id')+',';
                                            MapOnekeyValueToVeevaValue.put(strTemps.Veeva_Field_Name_AGN__c,strValueList);
                                            lookupFlag='Match';
                                            break;
                                        }
                                        else
                                        {
                                            strValueList='';
                                            strValueList='Activity- '+mapSFDCFieldToValueActivity.get(strTemps.Veeva_Field_Name_AGN__c)+':'+(String)val.get('Id')+',';
                                            MapOnekeyValueToVeevaValue.put(strTemps.Veeva_Field_Name_AGN__c,strValueList);
                                            lookupFlag='Match';
                                            break;
                                        }
                                    }
                                }
                                if(lookupFlag.equals('Match'))
                                    break;
                            }
                        }
                    }
                    if(strTemps.Field_Type_AGN__c.equalsIgnoreCase('Address'))
                    {
                        if(mapSFDCFieldToValueAddress!=null && mapSFDCFieldToValueAddress.containsKey(strTemps.Veeva_Field_Name_AGN__c))
                        {
                            String objname = strTemps.Veeva_Object_Name_AGN__c;
                            String queryStr='';
                            if(objname.contains('Specialty') || objname.contains('specialty'))
                                queryStr='select id,name from ' + objname + ' where Code_AGN__c LIKE \'SP.W'+OnekeyCountryCode+'.%\'';
                            else
                                queryStr='select id,name from ' + objname;
                            for (List<sObject> ox : Database.query(queryStr))
                            {
                                for(sObject val : ox)
                                {
                                    String oneKeyValue=mapSFDCFieldToValueAddress.get(strTemps.Veeva_Field_Name_AGN__c);
                                    String fieldName='';
                                    fieldName = (String)val.get('Name');
                                    if(oneKeyValue.equalsIgnoreCase(fieldName))
                                    {
                                        if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(strTemps.Veeva_Field_Name_AGN__c))
                                        {
                                            strValueList='';
                                            strValueList=MapOnekeyValueToVeevaValue.get(strTemps.Veeva_Field_Name_AGN__c);
                                            strValueList=strValueList+'Address '+mapSFDCFieldToValueAddress.get(strTemps.Veeva_Field_Name_AGN__c)+':'+(String)val.get('Id')+',';
                                            MapOnekeyValueToVeevaValue.put(strTemps.Veeva_Field_Name_AGN__c,strValueList);
                                            lookupFlag='Match';
                                            break;
                                        }
                                        else
                                        {
                                            strValueList='';
                                            strValueList='Address '+mapSFDCFieldToValueAddress.get(strTemps.Veeva_Field_Name_AGN__c)+':'+(String)val.get('Id')+',';
                                            MapOnekeyValueToVeevaValue.put(strTemps.Veeva_Field_Name_AGN__c,strValueList);
                                            lookupFlag='Match';
                                            break;
                                        }
                                    }
                                }
                                if(lookupFlag.equals('Match'))
                                    break;
                            }
                        }
                    }
                }
            }
            system.debug('value of MapOnekeyValueToVeevaValue final value ' +MapOnekeyValueToVeevaValue);
            RecordType rtPersonAcc=[SELECT id,DeveloperName FROM RecordType WHERE SobjectType='Account' and DeveloperName='Professional_vod'];
            RecordType rtBusinessAcc = [SELECT id,DeveloperName FROM RecordType WHERE SobjectType='Account' and DeveloperName='Hospital_vod'];
            
            List<Recordtype> lstRecType =[select id,DeveloperName from RecordType WHERE SobjectType='Account'];
            Map<String,Id> mapRecNameToId=new Map<String,Id>();
            if(lstRecType!=null && lstRecType.size()>0){
                for(Recordtype rectemp : lstRecType){
                    mapRecNameToId.put(rectemp.DeveloperName,rectemp.id);
                }
            }
            
            List<One_Key_Double_Translate_AGN__c> lstDblTranslate =[select CGDM_TYP_AGN__c,COUNTRY_AGN__c,LOV_TYPE_AGN__c,VEEVA_TYP_AGN__c from One_Key_Double_Translate_AGN__c WHERE COUNTRY_AGN__c=:user_country.Country_Code__c and LOV_TYPE_AGN__c='RecordtypeId'];
            Map<String,ID> mapCGDMTypeToId=new Map<String,Id>();
            if(lstDblTranslate!=null && lstDblTranslate.size()>0){
                for(One_Key_Double_Translate_AGN__c dblTranslate : lstDblTranslate){
                    if(mapRecNameToId.Containskey(dblTranslate.VEEVA_TYP_AGN__c)){
                        mapCGDMTypeToId.put(dblTranslate.CGDM_TYP_AGN__c,mapRecNameToId.get(dblTranslate.VEEVA_TYP_AGN__c));
                    }
                }
            }
            String tempVal='';
            String tempFieldValue='';
            List<Account> busAcc;
            List<Account> perAcc;
            List<Account> lstPersonAccount;
            
            if(listmapSFDCFieldToValueIndividual!=null && listmapSFDCFieldToValueIndividual.size()>0){
                
                if(listmapSFDCFieldToValueIndividual!=null && listmapSFDCFieldToValueIndividual.size()>0){
                    lstPersonAccount=new List<Account>();
                    String field_con='';
                    for(Map<String,String> mapTempFieldToValue : listmapSFDCFieldToValueIndividual){
                        Account objAccount=New Account();
                        tempVal='';
                        tempFieldValue='';
                        for (String fieldName : mapTempFieldToValue.keySet()){
                            tempFieldValue=mapTempFieldToValue.get(fieldName);
                            system.debug('tempFieldValue Person Account=====>'+tempFieldValue);
                            if(MapOnekeyValueToVeevaValue.containsKey(fieldName)){
                                tempVal=MapOnekeyValueToVeevaValue.get(fieldName);
                                system.debug('tempVal Person Account=====>'+tempVal);
                                if(tempVal.indexof(tempFieldValue)>=0){
                                    tempFieldValue=tempVal.Substring((tempVal.indexof(tempFieldValue)+tempFieldValue.length()+1),tempVal.indexof(',',tempVal.indexof(tempFieldValue)));
                                    system.debug('tempFieldValue Person Account inside if=====>'+tempFieldValue);
                                }
                            }
                            if(fieldName.equals('External_ID_vod__c'))
                                field_con = tempFieldValue;
                            if(fieldName.equalsIgnoreCase('Status_AGN__c')){
                                if(tempFieldValue.equalsIgnoreCase('Valid')){
                                    objAccount.put('Status_AGN__c','Active');
                                }else if(tempFieldValue.equalsIgnoreCase('Invalid')){
                                    objAccount.put('Status_AGN__c','Inactive');
                                }else if(tempFieldValue.equalsIgnoreCase('Provisional')){
                                    objAccount.put('Status_AGN__c','Pending Validation');
                                }else{
                                    objAccount.put(fieldName,tempFieldValue);
                                }
                            }
                            else if(!fieldName.equalsIgnoreCase('Primary_Parent_vod__c')){
                                if(lookupElse!=null && lookupElse.containsKey('Individual_'+fieldName))
                                {
                                    String looktmp = lookupElse.get('Individual_'+fieldName);
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(looktmp))
                                    {
                                        String v2o=MapOnekeyValueToVeevaValue.get(fieldName);
                                        if(v2o.contains('Individual'))
                                            objAccount.put(fieldName,tempFieldValue);
                                    }
                                }else if(translateElse!=null && translateElse.containsKey('Individual_'+fieldName)){
                                    String translatetmp = translateElse.get('Individual_'+fieldName);
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(translatetmp))
                                    {
                                        String v2o=MapOnekeyValueToVeevaValue.get(fieldName);
                                        if(v2o.contains('Individual'))
                                            objAccount.put(fieldName,tempFieldValue);
                                    }
                                }
                                else
                                {
                                    objAccount.put(fieldName,tempFieldValue);
                                }
                            }
                            if(user_country.Cluster_User_AGN__c==True)
                                objAccount.put('Country_Code__c',user_country.MA_User_Country_Code_AGN__c);
                            
                            String country = MapOnekeyValueToVeevaValue.get('Country_vod__c');
                            String tmpvalue = mapSFDCFieldToValueAddress.get('Country_Code__c');
                            if(oksMapping.size()>0){
                                for(OneKey_Search_Settings_AGN__c ok : oksMapping){
                                    system.debug('ok=========>'+ok);
                                    if(tmpvalue.contains(ok.OneKey_Field_Name_AGN__c)){
                                        system.debug('tmpvalue=========>'+tmpvalue);
                                        tmpvalue = ok.Veeva_Field_Name_AGN__c;
                                        system.debug('tmpvalue after=========>'+tmpvalue);
                                        break;
                                    }
                                }
                            }
                            //String tmpvalue = mapSFDCFieldToValueAddress.get('Country_vod__c');
                            tmpvalue = country.Substring((country.indexof(tmpvalue)+tmpvalue.length()+1),country.indexof(',',country.indexof(tmpvalue)));
                            objAccount.put('Country_vod__c',tmpvalue);
                            
                        }
                        if(typeCorporateLabel_individual!='' && mapCGDMTypeToId.containsKey(typeCorporateLabel_individual)){
                            objAccount.recordtypeid=mapCGDMTypeToId.GET(typeCorporateLabel_individual);
                        }else{
                            objAccount.recordtypeid=rtPersonAcc.id;
                        }
                        objAccount.Do_not_Visit_AGN__c=false;
                        lstPersonAccount.add(objAccount);
                        perAcc=[select id,External_ID_vod__c from Account where External_ID_vod__c =: field_con limit 2000];
                        system.debug('busAcc====> before '+busAcc+'  AND perAcc====> before '+perAcc);
                    }
                }
            }
            List<Account> lstBusinessAccount;
            if(listmapSFDCFieldToValueWorkplace!=null && listmapSFDCFieldToValueWorkplace.size()>0){
                if(listmapSFDCFieldToValueWorkplace!=null && listmapSFDCFieldToValueWorkplace.size()>0){
                    lstBusinessAccount=new List<Account>();
                    String field_con='';
                    for(Map<String,String> mapTempFieldToValue : listmapSFDCFieldToValueWorkplace){
                        Account objAccount=New Account();
                        tempVal='';
                        tempFieldValue='';
                        for (String fieldName : mapTempFieldToValue.keySet()){
                            tempFieldValue=mapTempFieldToValue.get(fieldName);
                            System.debug('========== R14.2 tempFieldValue =========== Before ========= ');
                            if(MapOnekeyValueToVeevaValue.containsKey(fieldName)){
                                tempVal=MapOnekeyValueToVeevaValue.get(fieldName);
                                System.debug('========== R14.2 tempVal =========== '+tempVal);
                                if(tempVal.indexof(tempFieldValue)>=0){
                                    tempFieldValue=tempVal.Substring((tempVal.indexof(tempFieldValue)+tempFieldValue.length()+1),tempVal.indexof(',',tempVal.indexof(tempFieldValue)));
                                    System.debug('========== R14.2 tempFieldValue =========== After ========== '+tempFieldValue);
                                }
                            }
                            if(fieldName.equals('External_ID_vod__c'))
                                field_con = tempFieldValue;
                            if(fieldName.equalsIgnoreCase('Status_AGN__c')){
                                if(tempFieldValue.equalsIgnoreCase('Valid')){
                                    objAccount.put('Status_AGN__c','Active');
                                }
                                else if(tempFieldValue.equalsIgnoreCase('Invalid')){
                                    objAccount.put('Status_AGN__c','Inactive');
                                }
                                else if(tempFieldValue.equalsIgnoreCase('Provisional')){
                                    objAccount.put('Status_AGN__c','Pending Validation');
                                }else{
                                    objAccount.put(fieldName,tempFieldValue);
                                }
                            }else if(fieldName.equalsIgnoreCase('name') && tempFieldValue.equalsIgnoreCase('null')){
                                objAccount.put(fieldName,typeCorporateLabel_workplace+' Workplace');
                            }
                            else
                            {
                                if(lookupElse!=null && lookupElse.containsKey('Workplace_'+fieldName))
                                {
                                    String looktmp = lookupElse.get('Workplace_'+fieldName);
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(looktmp))
                                    {
                                        String v2o=MapOnekeyValueToVeevaValue.get(fieldName);
                                        if(v2o.contains('Workplace'))
                                            objAccount.put(fieldName,tempFieldValue);
                                    }
                                }else if(translateElse!=null && translateElse.containsKey('Workplace_'+fieldName)){
                                    String translatetmp = translateElse.get('Workplace_'+fieldName);
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(translatetmp))
                                    {
                                        String v2o=MapOnekeyValueToVeevaValue.get(fieldName);
                                        if(v2o.contains('Workplace'))
                                            objAccount.put(fieldName,tempFieldValue);
                                    }
                                }
                                else
                                {
                                    objAccount.put(fieldName,tempFieldValue);
                                }
                            }
                            if(user_country.Cluster_User_AGN__c==True)
                                objAccount.put('Country_Code__c',user_country.MA_User_Country_Code_AGN__c);
                            String country = MapOnekeyValueToVeevaValue.get('Country_vod__c');
                            //String tmpvalue = mapSFDCFieldToValueAddress.get('Country_vod__c');
                            String tmpvalue = mapSFDCFieldToValueAddress.get('Country_Code__c');
                            if(oksMapping.size()>0){
                                for(OneKey_Search_Settings_AGN__c ok : oksMapping){
                                    if(tmpvalue.contains(ok.OneKey_Field_Name_AGN__c)){
                                        tmpvalue = ok.Veeva_Field_Name_AGN__c;
                                        break;
                                    }
                                }
                            }
                            tmpvalue = country.Substring((country.indexof(tmpvalue)+tmpvalue.length()+1),country.indexof(',',country.indexof(tmpvalue)));
                            objAccount.put('Country_vod__c',tmpvalue);
                        }
                        if(typeCorporateLabel_workplace!='' && mapCGDMTypeToId.containsKey(typeCorporateLabel_workplace)){
                            objAccount.recordtypeid=mapCGDMTypeToId.GET(typeCorporateLabel_workplace);
                        }else{
                            objAccount.recordtypeid=rtBusinessAcc.id;
                        }
                        objAccount.Do_not_Visit_AGN__c=false;
                        lstBusinessAccount.add(objAccount);
                    }
                    busAcc=[select id,External_ID_vod__c from Account where External_ID_vod__c =: field_con limit 2000];
                    system.debug('busAcc====>'+busAcc+'  AND perAcc====>'+perAcc);
                }
                if(busAcc.size() > 0)
                {
                    if(perAcc != NULL && perAcc.size()==0)
                    {
                        try{
                            per_sr=Database.insert(lstPersonAccount[0]);
                        }catch(DmlException e){
                            system.debug('The following exception has occurred: ' + e.getMessage());
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.AGN_Onekey_ErrMsg_Unexpected_Error));
                        }
                    }
                }
                else if(busAcc.size()==0)
                {
                    if(perAcc != NULL && perAcc.size()==0)
                    {
                        try{
                            per_sr=Database.insert(lstPersonAccount[0]);
                            bus_sr=Database.insert(lstBusinessAccount[0]);
                        }catch(DmlException e){
                            system.debug('The following exception has occurred: ' + e.getMessage());
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.AGN_Onekey_ErrMsg_Unexpected_Error));
                        }
                    }
                    if(perAcc == NULL || perAcc.size() > 0 )
                    {
                        try{
                            bus_sr=Database.insert(lstBusinessAccount[0]);
                        }catch(DmlException e){
                            system.debug('The following exception has occurred: ' + e.getMessage());
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.AGN_Onekey_ErrMsg_Unexpected_Error));
                        }
                    }
                    //insert lstBusinessAccount;
                    AccId=lstBusinessAccount[0].id;
                }
            }
            system.debug('busAcc.size===>'+busAcc.size()+'perAcc===>'+perAcc+'busAcc data===>'+busAcc);
            if((perAcc!=null && busAcc!=null && perAcc.size() > 0 && busAcc.size()==0) || (perAcc==null && busAcc.size()==0)){
                
                AccId=lstBusinessAccount[0].id;
                system.debug('AccId==>'+AccId);
            }
            if(busAcc != NULL && busAcc.size() > 0 && perAcc==NULL)
                AccId=busAcc[0].id;
            if(perAcc!=null && busAcc!=null && perAcc.size() > 0 && busAcc.size()>0)
                AccId=perAcc[0].id;
            if(perAcc !=null && perAcc.size() == 0 )
                AccId=lstPersonAccount[0].id;
            
            for (SearchResult sr : resultsIMS) {
                if (sr.isSelected == true) {
                    sr.acctId=AccId ;
                    break ;
                }
            }
            
            List<Address_vod__c> lstBusinessAccountAddress;
            String countryId='';
            String ExternalAccID ='';//DOMTOM Address_vod ExternalID update
            if(lstBusinessAccount!=null && lstBusinessAccount.size()>0 && listmapSFDCFieldToValueAddress!=null && listmapSFDCFieldToValueAddress.size()>0){
                if(listmapSFDCFieldToValueAddress!=null && listmapSFDCFieldToValueAddress.size()>0){
                    lstBusinessAccountAddress=new List<Address_vod__c>();
                    for(Map<String,String> mapTempFieldToValue : listmapSFDCFieldToValueAddress){
                        Address_vod__c objAccountAddress=New Address_vod__c();
                        tempVal='';
                        tempFieldValue='';
                        for (String fieldName : mapTempFieldToValue.keySet()){
                            tempFieldValue=mapTempFieldToValue.get(fieldName);
                            system.debug('tempFieldValue=====>'+tempFieldValue+'  '+fieldName);
                            if(MapOnekeyValueToVeevaValue.containsKey(fieldName)){
                                tempVal=MapOnekeyValueToVeevaValue.get(fieldName);
                                system.debug('tempFieldValue=====>'+tempVal+'  '+fieldName);
                                if(tempVal.indexof(tempFieldValue)>=0){
                                    tempFieldValue=tempVal.Substring((tempVal.indexof(tempFieldValue)+tempFieldValue.length()+1),tempVal.indexof(',',tempVal.indexof(tempFieldValue)));
                                    system.debug('tempFieldValue inside if=====>'+tempFieldValue);
                                }
                            }
                            if(lstBusinessAccount.size()>0){
                                ExternalAccID = lstBusinessAccount[0].External_ID_vod__c;
                            }//DOMTOM Address_vod ExternalID update
                            
                            if(fieldName.equals('Brick_vod__c'))
                            {
                                String brick=mapSFDCFieldToValueAddress.get('Brick_vod__c')+' '+tempFieldValue;
                                objAccountAddress.put(fieldName,brick);
                            }
                            else if(!fieldName.equals('Country_vod__c'))
                            {
                                if(lookupElse!=null && lookupElse.containsKey('Address_'+fieldName))
                                {
                                    String looktmp = lookupElse.get('Address_'+fieldName);
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(looktmp))
                                    {
                                        String v2o=MapOnekeyValueToVeevaValue.get(fieldName);
                                        if(v2o.contains('Address')){
                                            objAccountAddress.put(fieldName,tempFieldValue);
                                        }
                                    }
                                }else if(translateElse!=null && translateElse.containsKey('Address_'+fieldName)){
                                    String translatetmp = translateElse.get('Address_'+fieldName);
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(translatetmp))
                                    {
                                        String v2o=MapOnekeyValueToVeevaValue.get(fieldName);
                                        if(v2o.contains('Address')){
                                            objAccountAddress.put(fieldName,tempFieldValue);
                                        }
                                    }
                                }
                                else
                                {
                                    objAccountAddress.put(fieldName,tempFieldValue);
                                    system.debug('fieldName++tempFieldValue : '+fieldName+'  '+tempFieldValue);
                                }
                            }
                            else if(fieldName.equals('Country_vod__c')){
                                countryId=tempFieldValue;
                            }
                            if(fieldName.equalsIgnoreCase('address_type_vod__c') && tempFieldValue.equalsIgnoreCase('Primary address')){
                                objAccountAddress.put('Primary_vod__c',True);
                                objAccountAddress.put('RecordTypeId',recordTypeId);
                            }
                            
                        }
                        
                        objAccountAddress.Account_vod__c=lstBusinessAccount[0].id;
                        lstBusinessAccountAddress.add(objAccountAddress);
                    }
                    if(mapSFDCFieldToValueAddress!=null && mapSFDCFieldToValueAddress.containsKey('Country_vod__c'))
                    {
                        List<Country_vod__c> add = [select toLabel(Country_Name_vod__c) from Country_vod__c where id=:countryId];
                        if(add.size()>0){
                            lstBusinessAccountAddress[0].Country_vod__c=add[0].Country_Name_vod__c;
                        }
                    }
                    if(mapSFDCFieldToValueAddress!=null && mapSFDCFieldToValueAddress.containsKey('External_ID_vod__c')){
                        
                        lstBusinessAccountAddress[0].External_ID_vod__c = ExternalAccID+':'+mapSFDCFieldToValueAddress.get('External_ID_vod__c');
                        //DOMTOM Address_vod ExternalID update
                    }
                    if(busAcc.size()==0)
                    {
                        try{
                            insert lstBusinessAccountAddress;
                        }catch(DmlException e){
                            system.debug('The following exception has occurred: ' + e.getMessage());
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.AGN_Onekey_ErrMsg_Unexpected_Error));
                        }
                    }
                }
            }
            List<Child_Account_vod__c> childAcc;
            Boolean insert_child;
            List<Child_Account_vod__c> lstChildAccount;
            if(lstPersonAccount!=null && lstPersonAccount.size()>0 && lstBusinessAccount!=null && lstBusinessAccount.size()>0){
                lstChildAccount=new List<Child_Account_vod__c>();
                if(listmapSFDCFieldToValueActivity!=null && listmapSFDCFieldToValueActivity.size()>0){
                    for(Map<String,String> mapTempFieldToValue : listmapSFDCFieldToValueActivity){
                        Child_Account_vod__c objChildAccount=New Child_Account_vod__c();
                        for (String fieldName : mapTempFieldToValue.keySet()){
                            tempFieldValue=mapTempFieldToValue.get(fieldName);
                            if(MapOnekeyValueToVeevaValue.containsKey(fieldName)){
                                tempVal=MapOnekeyValueToVeevaValue.get(fieldName);
                                
                                if(tempVal.indexof(tempFieldValue)>=0){
                                    tempFieldValue=tempVal.Substring((tempVal.indexof(tempFieldValue)+tempFieldValue.length()+1),tempVal.indexof(',',tempVal.indexof(tempFieldValue)));
                                }
                            }
                            if(!fieldName.equals('Primary_Parent_vod__c'))
                            {
                                if(lookupElse!=null && lookupElse.containsKey('Activity_'+fieldName))
                                {
                                    String looktmp = lookupElse.get('Activity_'+fieldName);
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(looktmp))
                                    {
                                        String v2o=MapOnekeyValueToVeevaValue.get(fieldName);
                                        if(v2o.contains('Activity'))
                                            objChildAccount.put(fieldName,tempFieldValue);
                                    }
                                }else if(translateElse!=null && translateElse.containsKey('Activity_'+fieldName)){
                                    String translatetmp = translateElse.get('Activity_'+fieldName);
                                    if(MapOnekeyValueToVeevaValue!=null && MapOnekeyValueToVeevaValue.containsKey(translatetmp))
                                    {
                                        String v2o=MapOnekeyValueToVeevaValue.get(fieldName);
                                        if(v2o.contains('Activity'))
                                            objChildAccount.put(fieldName,tempFieldValue);
                                    }
                                }
                                else
                                {
                                    objChildAccount.put(fieldName,tempFieldValue);
                                }
                            }
                            
                        }
                        if(perAcc.size() > 0)
                            objChildAccount.Child_Account_vod__c=perAcc[0].id;
                        if(perAcc.size() == 0)
                            objChildAccount.Child_Account_vod__c=lstPersonAccount[0].id;
                        if(busAcc.size() > 0)
                            objChildAccount.Parent_Account_vod__c=busAcc[0].id;
                        if(busAcc.size() == 0)
                            objChildAccount.Parent_Account_vod__c=lstBusinessAccount[0].id;
                        objChildAccount.Copy_Address_vod__c=True;
                        lstChildAccount.add(objChildAccount);
                    }
                }else{
                    Child_Account_vod__c objChildAccount=New Child_Account_vod__c();
                    if(perAcc.size() > 0)
                        objChildAccount.Child_Account_vod__c=perAcc[0].id;
                    if(perAcc.size() == 0)
                        objChildAccount.Child_Account_vod__c=lstPersonAccount[0].id;
                    if(busAcc.size() > 0)
                        objChildAccount.Parent_Account_vod__c=busAcc[0].id;
                    if(busAcc.size() == 0)
                        objChildAccount.Parent_Account_vod__c=lstBusinessAccount[0].id;
                    objChildAccount.Copy_Address_vod__c=True;
                    lstChildAccount.add(objChildAccount);
                }
                if(perAcc.size() > 0 && busAcc.size() > 0)
                {
                    List<Child_Account_vod__c> llist= [select Child_Account_vod__c,Parent_Account_vod__c from Child_Account_vod__c where Child_Account_vod__c=:perAcc[0].id AND Parent_Account_vod__c=:busAcc[0].id];
                    if(llist.size()==0)
                    {
                        try{
                            insert lstChildAccount;
                        }catch(DMLException e){
                            system.debug('The following exception has occurred: ' + e.getMessage());
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.AGN_Onekey_ErrMsg_Unexpected_Error));
                        }
                    }
                }
                else
                {
                    try{
                        insert lstChildAccount;
                    }catch(DmlException e){
                        system.debug('The following exception has occurred: ' + e.getMessage());
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.AGN_Onekey_ErrMsg_Unexpected_Error));
                    }
                }
                if(busAcc.size()==0)
                {
                    if(perAcc.size()==0)
                    {
                        if(mapSFDCFieldToValueActivity!=null && mapSFDCFieldToValueActivity.containsKey('Primary_Parent_vod__c'))
                        {
                            String priAff=mapSFDCFieldToValueActivity.get('Primary_Parent_vod__c');
                            if(priAff.equalsIgnoreCase('True'))
                            {
                                lstPersonAccount[0].Primary_Parent_vod__c=lstBusinessAccount[0].id;
                                try{
                                    update lstPersonAccount;
                                }catch(Exception e){
                                    system.debug('The following exception has occurred: ' + e.getMessage());
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.AGN_Onekey_ErrMsg_Unexpected_Error));
                                }
                            }
                        }
                    }
                    if(perAcc.size() > 0 )
                    {
                        if(mapSFDCFieldToValueActivity!=null && mapSFDCFieldToValueActivity.containsKey('Primary_Parent_vod__c'))
                        {
                            String priAff=mapSFDCFieldToValueActivity.get('Primary_Parent_vod__c');
                            if(priAff.equalsIgnoreCase('True'))
                            {
                                List<Account> perAccUpdate = [select id,Primary_Parent_vod__c from Account where id =: perAcc[0].id];
                                perAccUpdate[0].Primary_Parent_vod__c=lstBusinessAccount[0].id;
                                try{
                                    update perAccUpdate;
                                }catch(Exception e){
                                    system.debug('The following exception has occurred: ' + e.getMessage());
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.AGN_Onekey_ErrMsg_Unexpected_Error));
                                }
                            }
                        }
                    }
                }
                
                
            }
        }
    }
    
    public void doOneKeySearch() {
        
        system.debug('Inside===============');
        onekeyRecordCountIMS=0;
        showOnekey=false;
        OnekeySearchDone=true;
        GASSearchDone=false;
        
        resultsIMS = new List<SearchResult> () ;
        PaginationDemoControllerIMS();
        
        // Combine the search fields
        List <SearchField> allSearchFields = new List <SearchField> () ;
        allSearchFields.addAll(acctSearchFields) ;
        allSearchFields.addAll(addrSearchFields) ;
        
        
        String strFullname ='';
        String strFullnameCriteria ='';
        String strFirstname ='';
        String strFirstnameCriteria ='';
        String strLastname ='';
        String strLastnameCriteria ='';
        String strMiddleName ='';
        String strMiddlenameCriteria ='';
        String strCity ='';
        String strCityCriteria ='';
        String CountryCode =loggedInUser.Country_Code__c;
        String UserCountryCode =loggedInUser.MA_User_Country_Code_AGN__c;
        String selectedCountry ='';
        String strSpeciality ='';
        String strAddrLabel1 ='';
        String strAddrLabel1Criteria ='';
        String strPostalCode ='';
        String strPhone ='';
        String strPostalCodeCriteria ='';
        String strPrimaryBusinessAccount ='';
        String datastatus='';
        String strDistributionId ='';
        String strSapId ='';
        String strBrick ='';
        String strState ='';
        
        String strRecordType ='';
        String strSelectedRecordType ='';
        Searchtype=0; // 0-No Selection,1-Business Acc Search,2-Person Acc Search
        
        for (SearchField sf : allSearchFields) {
            if (sf.value != '' && sf.value != 'null' && sf.value != null) {
                
                
                if (sf.apiname == 'Name' && sf.obj== 'Account' ) {
                    strFullname =sf.value ;
                    strFullnameCriteria=sf.opt_value;
                }
                if (sf.apiname == 'FirstName' ) {
                    strFirstname =sf.value ;
                    strFirstnameCriteria=sf.opt_value;
                }
                if (sf.apiname == 'Lastname' ) {
                    strLastname =sf.value ;
                    strLastnameCriteria=sf.opt_value;
                }
                if (sf.apiname == 'Middle_vod__c' ) {
                    strMiddleName =sf.value ;
                    strMiddlenameCriteria=sf.opt_value;
                }
                if (sf.apiname == 'City_vod__c' ) {
                    strCity =sf.value ;
                    strCityCriteria=sf.opt_value;
                }
                
                if (sf.apiname == 'Specialty_1_AGN__c' ) {
                    
                    if(sf.plist!=null && sf.plist.size()>0){
                        for(SelectOption tempdata:sf.plist){
                            if(tempdata.getValue()==sf.value){
                                strSpeciality =tempdata.getLabel() ;
                            }
                        }
                    }
                    
                }
                strSpeciality=specName;
                if (sf.apiname == 'Name' && sf.obj== 'Address_vod__c' ) {
                    strAddrLabel1 =sf.value ;
                    strAddrLabel1Criteria=sf.opt_value;
                }
                if (sf.apiname == 'Zip_vod__c' ) {
                    strPostalCode =sf.value ;
                    strPostalCodeCriteria=sf.opt_value;
                }
                
                if (sf.apiname == 'Primary_Parent_vod__c' ) {
                    strPrimaryBusinessAccount =sf.value ;
                }
                
                if (sf.apiname == 'Country_vod__c' ) {
                    if(sf.plist!=null && sf.plist.size()>0){
                        for(SelectOption tempdata:sf.plist){
                            if(tempdata.getValue()==sf.value){
                                selectedCountry =tempdata.getLabel();
                                system.debug('selectedCountry ====>>'+selectedCountry);
                                
                            }
                        }
                    }
                }
                /*
if (sf.apiname == 'Distribution_ID_AGN__c' ) {
sf.value='' ;
}
if (sf.apiname == 'External_ID2_AGN__c' ) {
sf.value='' ;
}
if (sf.apiname == 'Brick_vod__c' ) {
sf.value='' ;
}
if (sf.apiname == 'Phone_vod__c' ) {
sf.value='' ;
}
if (sf.apiname == 'RecordTypeId' && sf.obj=='Address_vod__c' ) {
sf.value='' ;
}
if (sf.apiname == 'RecordTypeId' && sf.obj=='Account' ) {
sf.value='' ;
}
*/
                if (sf.apiname == 'IsPersonAccount' ) {
                    if(sf.value=='true'){
                        IsHCP=true;
                    }else{
                        IsHCP=false;
                    }
                }
                if (sf.apiname == 'Status_AGN__c' ) {
                    datastatus=sf.value;
                }
                if (sf.apiname == 'Distribution_ID_AGN__c' ) {
                    strDistributionId=sf.value;
                }
                if (sf.apiname == 'External_ID2_AGN__c' ) {
                    strSapId=sf.value;
                }
                if (sf.apiname == 'Brick_vod__c' ) {
                    strBrick=sf.value;
                }
                if (sf.apiname == 'State_vod__c' ) {
                    strState=sf.value;
                    system.debug('selectedState ====>>'+strState);
                }
                
                
            }
            
        }
        
        
        if(selectedCountry != ''){
            selectedCountry=[select Alpha_2_Code_vod__c from Country_vod__c where toLabel(Country_Name_vod__c )=:selectedCountry].Alpha_2_Code_vod__c;
            if(selectedCountry=='IE'){
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING,'IMS : '+Label.AGN_Onekey_Ireland_Msg));
                return;
            }
        }
        List<OneKey_Search_Settings_AGN__c> countryMapList = [select Field_Type_AGN__c,OneKey_Field_Name_AGN__c,Veeva_Field_Name_AGN__c from OneKey_Search_Settings_AGN__c where IMS_Country_Mapping_AGN__c = true AND Category_AGN__c='IMS Country Mapping' order by Field_Sequence_AGN__c];//DOMTOM order by change
        System.debug('countryMapList ====>' +countryMapList);
        String repCountry='';
        
        
        if(strPrimaryBusinessAccount!=null && strPrimaryBusinessAccount!=''){
            List<Account> lstAcc=[select External_ID_vod__c from Account where Id=:strPrimaryBusinessAccount LIMIT 1];
            if(lstAcc !=null && lstAcc.size()>0){
                if(lstAcc[0].External_ID_vod__c!=null && lstAcc[0].External_ID_vod__c !=''){
                    strPrimaryBusinessAccount=lstAcc[0].External_ID_vod__c;
                }
            }
        }/*
if(strDistributionId!='' || strSapId!='' || strBrick!='' || strState!='' || specNameAGN!=''){
String fieldnames='';
if(strDistributionId!=''){
fieldnames='Distribution ID';
}
if(strSapId!=''){
fieldnames+=(fieldnames!=''?',SAP ID':'SAP ID');
}
if(specNameAGN!=''){
fieldnames+=(fieldnames!=''?',Allergan Specialty':'Allergan Specialty');
}
if(strBrick!=''){
fieldnames+=(fieldnames!=''?',Brick':'Brick');
}
if(strState!=''){
fieldnames+=(fieldnames!=''?',State':'State');
}
this.paginaterIMS = new Paginate(0, 0);
ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING,'IMS : '+(isHCP?Label.AGN_Onekey_Msg_Invalid_HCP_Search:Label.AGN_Onekey_Msg_Invalid_HCO_Search_2)+' '+fieldnames));
return ;
}*/
        if(strFullname=='' && strFirstname=='' && strMiddleName =='' && strLastname=='' && strCity=='' && strState=='' && strSpeciality=='' && strAddrLabel1=='' && strPostalCode=='' && strPrimaryBusinessAccount=='' && strRecordType=='' && selectedCountry=='' && specName=='' && specNameAGN=='' && strDistributionId=='' && strSapId=='' && strBrick=='' && (datastatus.equalsIgnoreCase('Active') || datastatus=='')){
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING,'IMS : '+System.Label.AGN_Onekey_ErrMsg_NoSearchCriteria));
            this.paginaterIMS = new Paginate(0, 0);
            return;
        }
        if(strFullname!='' && (strFirstname!='' || strLastname!='')){
            this.paginaterIMS = new Paginate(0, 0);
            
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ GAS_NAMESEARCH));
            return;
        }
        if(!isHCP && (strFirstname!='' || strLastname!='')){
            this.paginaterIMS = new Paginate(0, 0);
            
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_Msg_HCO_Search));
            return;
        }
        
        if(!isHCP && (strPrimaryBusinessAccount!='')){
            this.paginaterIMS = new Paginate(0, 0);
            
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_Msg_Invalid_HCO_Search));
            return;
        }
        
        system.debug('CountryCode=====>'+CountryCode);
        List<Country_vod__c> lstCluster;
        
        if(loggedInUser.MA_Medical_Affairs_AGN__c!='Yes'){
            if(loggedInUser.Cluster_User_AGN__c){
                if(selectedCountry!=''){
                    if(CountryCode!=null && CountryCode!=''){
                        lstCluster=[select Alpha_2_Code_vod__c from Country_vod__c where Alpha_2_Code_vod__c =:selectedCountry and Cluster_Country_AGN__c=:CountryCode ];
                        if(lstCluster.size()==0){
                            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_ErrMsg_NoRecords));
                            this.paginaterIMS = new Paginate(0, 0);
                            return ;
                        }
                    }else{
                        ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_ErrMsg_NoRecords));
                        this.paginaterIMS = new Paginate(0, 0);
                        return ;
                    }
                }else{
                    if(CountryCode!=null && CountryCode!=''){
                        lstCluster=[select Alpha_2_Code_vod__c from Country_vod__c where Cluster_Country_AGN__c=:CountryCode ];
                        if(lstCluster!=null && lstCluster.size()>0){
                            for(Country_vod__c  temp:lstCluster ){
                                selectedCountry=selectedCountry+temp.Alpha_2_Code_vod__c+',';
                            }
                        }else{
                            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_ErrMsg_Cluster_Country));
                            this.paginaterIMS = new Paginate(0, 0);
                            return ;
                        }
                    }
                }
            }else{
                if(selectedCountry==''){
                    selectedCountry=CountryCode;
                }else if(selectedCountry!=CountryCode){
                    if(selectedCountry != 'IE' && selectedCountry != 'GB' && selectedCountry != 'AN' && selectedCountry != 'NZ'){
                        ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_ErrMsg_NoRecords));
                        this.paginaterIMS = new Paginate(0, 0);
                        return ;
                    }
                }
            }
        }else{
            if(selectedCountry==''){
                selectedCountry=UserCountryCode;
            }
        }
        set<String> setCountryList=new Set<String>();
        system.debug('selectedCountry Before Logic========>'+selectedCountry);
        if(selectedCountry !=null && selectedCountry!=''){
            //Country Code Logic added
            if(countryMapList.size() > 0){
                for(OneKey_Search_Settings_AGN__c oneKey : countryMapList){
                    System.debug('oneKey ====>'+oneKey);
                    if(oneKey.Veeva_Field_Name_AGN__c.contains(selectedCountry) || selectedCountry.contains(oneKey.Veeva_Field_Name_AGN__c)){
                        repCountry = selectedCountry;
                        selectedCountry=oneKey.OneKey_Field_Name_AGN__c;
                        System.debug('==== OneKey_Field_Name_AGN__c ==== '+selectedCountry); //R14.1
                        break;
                    }
                }
            }
            System.debug('======== I am here ============'); //R14.1                    
            //end
            //selectedCountry =selectedCountry.replace('GB','UK');
            if(selectedCountry.indexof(',')>0){ 
                String[] arrTest = selectedCountry.split(',');
                for(String strTemp:arrTest ){
                    if(strTemp!=''){
                        setCountryList.add(strTemp);
                    }
                }
            }
            else{
                setCountryList.add(selectedCountry);
            }
            
            if(specName!=null && specName!=''){
                List<One_Key_Translate_AGN__c> lstSpecialityMapping=[select COD_ID_CEGEDIM_AGN__c from One_Key_Translate_AGN__c where LIS_COUNTRY_ID_AGN__c in:setCountryList and COD_SHORT_LBL_AGN__c =:specName LIMIT 1];
                if(lstSpecialityMapping !=null && lstSpecialityMapping.size()>0 && lstSpecialityMapping[0].COD_ID_CEGEDIM_AGN__c !=null && lstSpecialityMapping[0].COD_ID_CEGEDIM_AGN__c!=''){
                    strSpeciality=lstSpecialityMapping[0].COD_ID_CEGEDIM_AGN__c.substring(lstSpecialityMapping[0].COD_ID_CEGEDIM_AGN__c.lastindexof('.')+1);
                    System.debug('=================== One Key Translate COD_ID_CEGEDIM_AGN__c value ================= '+strSpeciality); //R14.1
                }
            }
        }
        
        RecordType rtPersonAcc1=[SELECT id,DeveloperName FROM RecordType WHERE SobjectType='Account' and DeveloperName='Professional_vod'];
        RecordType rtPersonAcc2 = [SELECT id,DeveloperName FROM RecordType WHERE SobjectType='Account' and DeveloperName='PersonAccount'];
        List<One_Key_Double_Translate_AGN__c> lstDblTranslate ;
        Set<String> setTypeCodes;
        List<One_Key_Translate_AGN__c> lstSnglTranslate = [SELECT COD_ID_CEGEDIM_AGN__c,COD_LONG_LBL_AGN__c FROM One_Key_Translate_AGN__c WHERE LIS_COUNTRY_ID_AGN__c=:selectedCountry and LIS_CODE_AGN__c='TET'];
        
        mapCreds=new map<String,String>();
        
        String loginUN = Label.AGN_Login_Username;
        String loginPwd = Label.AGN_Login_Password;
        String loginURL = 'Login.URL';
        String subKeyURL = 'SubmitKey.URL';
        String pageCount = 'Page.Recordcount';
        
        
        set<String> categoryLabel = new set<String>{loginUN,loginPwd,loginURL,subKeyURL,pageCount};
            List<OneKey_Search_Settings_AGN__c> lstCredentials=[select Veeva_Field_Name_AGN__c,Category_AGN__c from OneKey_Search_Settings_AGN__c
                                                                where Category_AGN__c in :categoryLabel];
        if(lstCredentials!=null && lstCredentials.size()>0){
            for(OneKey_Search_Settings_AGN__c obj : lstCredentials){
                mapCreds.put(obj.Category_AGN__c,obj.Veeva_Field_Name_AGN__c);
            }
        }
        if(!(mapCreds.containskey(loginUN) && mapCreds.containskey(loginPwd) && mapCreds.containskey(loginURL))){
            this.paginaterIMS = new Paginate(0, 0);
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_ErrMsg_Credentials));
            return;
        }
        
        if(datastatus.equalsIgnoreCase('Pending Validation') || datastatus.equalsIgnoreCase('Unassigned') || datastatus.equalsIgnoreCase('Inactive')){
            this.paginaterIMS = new Paginate(0, 0);
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING,'IMS : '+datastatus+' '+System.Label.AGN_Onekey_Status_Msg));
            
            return ;
        }
        
        
        
        system.debug('CountryCode=====>'+CountryCode);
        JSONGenerator gen = JSON.createGenerator(true);
        SelectedOnekeyCountryCode=selectedCountry;
        gen.writeStartObject();
        if(IsHCP){
            gen.writestringField('entityType', 'Activity');
        }else{
            gen.writestringField('entityType', 'WorkPlace');
        }
        if(mapCreds.containskey('Page.Recordcount')){
            gen.writestringField('resultSize', mapCreds.get('Page.Recordcount'));
        }else{
            gen.writestringField('resultSize', '20');
        }
        if(selectedCountry !=null && selectedCountry!=''){
            if(selectedCountry.indexof(',')>0){
                String[] arrTest = selectedCountry.split(',');
                for(String strTemp:arrTest ){
                    if(strTemp!=''){
                        gen.writestringField('codBase', 'W'+strTemp);
                        System.debug('========= codBase in IF =========== '+'W'+strTemp); //R14.1
                    }
                }
            }
            else{
                gen.writestringField('codBase', 'W'+selectedCountry);
                System.debug('========= codBase in Else =========== '+'W'+selectedCountry); //R14.1
            }
        }
        system.debug('CountryCode=====>'+CountryCode);
        OnekeyCountryCode=CountryCode;
        system.debug('OnekeyCountryCode=====>'+OnekeyCountryCode);
        //selectedCountry =selectedCountry.replace(selectedCountry,repCountry);
        gen.writeFieldName('fields');
        gen.writeStartArray();
        
        if(strFullname !=''){
            
            gen.writeStartObject();
            if(IsHCP){
                gen.writestringField('name', 'individual.firstNameLastName');
            }else{
                gen.writestringField('name', 'workplace.usualName');
            }
            if(strFullnameCriteria=='Exact Match'){
                gen.writestringField('method', 'EXACT');
            }else if(strFullnameCriteria=='Starts With'){
                gen.writestringField('method', 'STARTS_WITH');
            }else{
                gen.writestringField('method', 'CONTAINS');
            }
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writestringField('values', strFullname );
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }
        
        if(strFirstname !='' && IsHCP){
            
            gen.writeStartObject();
            gen.writestringField('name', 'individual.firstName');
            if(strFirstnameCriteria=='Exact Match'){
                gen.writestringField('method', 'EXACT');
            }else if(strFirstnameCriteria=='Starts With'){
                gen.writestringField('method', 'STARTS_WITH');
            }else{
                gen.writestringField('method', 'CONTAINS');
            }
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writestringField('values', strFirstname );
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }
        //*start Release 14 #IMS middle name search criteria
        if(strMiddleName !='' && IsHCP){
            
            gen.writeStartObject();
            gen.writestringField('name', 'individual.middleName');
            if(strMiddlenameCriteria=='Exact Match'){
                gen.writestringField('method', 'EXACT');
            }else if(strMiddlenameCriteria=='Starts With'){
                gen.writestringField('method', 'STARTS_WITH');
            }else{
                gen.writestringField('method', 'CONTAINS');
            }
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writestringField('values', strMiddleName);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }
        //*end Release 14 #IMS middle name search criteria
        if(strLastname !='' && IsHCP){
            
            gen.writeStartObject();
            gen.writestringField('name', 'individual.lastName');
            if(strLastnameCriteria=='Exact Match'){
                gen.writestringField('method', 'EXACT');
            }else if(strLastnameCriteria=='Starts With'){
                gen.writestringField('method', 'STARTS_WITH');
            }else{
                gen.writestringField('method', 'CONTAINS');
            }
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writestringField('values', strLastname );
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            
        }
        
        if(strCity !=''){
            gen.writeStartObject();
            gen.writestringField('name', 'address.villageLabel');
            if(strCityCriteria=='Exact Match'){
                gen.writestringField('method', 'EXACT');
            }else if(strCityCriteria=='Starts With'){
                gen.writestringField('method', 'STARTS_WITH');
            }else{
                gen.writestringField('method', 'CONTAINS');
            }
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writestringField('values', strCity);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }
        
        if(strSpeciality !=''){
            
            gen.writeStartObject();
            if(isHCP){
                gen.writestringField('name', 'individual.speciality1');
            }else{
                gen.writestringField('name', 'workplace.speciality1');
            }
            gen.writestringField('method', 'CONTAINS');
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writestringField('values', strSpeciality );
            System.debug('======= Specialty ======= '+strSpeciality); //R14.1
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            
        }
        
        if(strAddrLabel1 !=''){
            gen.writeStartObject();
            gen.writestringField('name', 'address.longLabel');
            if(strAddrLabel1Criteria=='Exact Match'){
                gen.writestringField('method', 'EXACT');
            }else if(strAddrLabel1Criteria=='Starts With'){
                gen.writestringField('method', 'STARTS_WITH');
            }else{
                gen.writestringField('method', 'CONTAINS');
            }
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writestringField('values', strAddrLabel1 );
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }
        if(strPostalCode !=''){
            gen.writeStartObject();
            gen.writestringField('name', 'address.longPostalCode');
            if(strPostalCodeCriteria=='Exact Match'){
                gen.writestringField('method', 'EXACT');
            }else if(strPostalCodeCriteria=='Starts With'){
                gen.writestringField('method', 'STARTS_WITH');
            }else{
                gen.writestringField('method', 'CONTAINS');
            }
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writestringField('values', strPostalCode );
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            
        }
        
        if(strPrimaryBusinessAccount !=''){
            gen.writeStartObject();
            gen.writestringField('name', 'workplace.workplaceEid');
            gen.writestringField('method', 'CONTAINS');
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writestringField('values', strPrimaryBusinessAccount );
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }
        
        gen.writeStartObject();
        if(IsHCP){
            gen.writestringField('name', 'activity.statusCode');
        }else{
            gen.writestringField('name', 'workplace.statusCode');
        }
        gen.writestringField('method', 'EXACT');
        gen.writeFieldName('values');
        gen.writeStartArray();
        
        if(datastatus=='Active' || datastatus==''){
            gen.writeStartObject();
            gen.writestringField('values', '3' );
            gen.writeEndObject();
        }
        
        if(datastatus=='Inactive'){
            gen.writeStartObject();
            gen.writestringField('values', '9' );
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        
        
        gen.writeEndArray();
        
        gen.writeEndObject();
        
        strResult=  gen.getAsString();
        String jsonaccnt = gen.getAsString();
        integer indexa=0;
        //jsonaccnt=jsonaccnt.deleteWhitespace();
        jsonaccnt= jsonaccnt.replaceAll( '\\s+', '^');
        
        String lastpart='';
        while(jsonaccnt.indexof('{^"values"^:')>=0){
            indexa=jsonaccnt.indexof('{^"values"^:');
            
            lastpart=jsonaccnt.substring(indexa+13,jsonaccnt.length());
            lastpart=lastpart.substring(0,lastpart.indexOf('}'))+lastpart.substring(lastpart.indexOf('}')+1);
            jsonaccnt=jsonaccnt.substring(0,indexa)+lastpart;
        }
        jsonaccnt= jsonaccnt.replaceAll('\\^', ' ');
        
        
        HttpRequest req = new HttpRequest();
        HTTPResponse res = new HTTPResponse();
        
        req.setMethod('POST');
        
        req.setEndpoint(string.valueof(mapCreds.get('Login.URL')));
        
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        
        String username = mapCreds.get('Login.Username');
        String password = mapCreds.get('Login.Password');
        
        system.debug('Username' + username);
        system.debug('Password' + password);
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        //req.setHeader('Accept-Encoding', 'gzip');
        req.setTimeout(120000);
        
        req.setBody(jsonaccnt);
        // create a new HTTP object
        Http http = new Http();
        req.setHeader('Authorization', authorizationHeader);
        
        // create a new HTTP response for receiving the remote response
        // then use it to send the configured HTTPrequest
        
        res = http.send(req);
        strRequest =jsonaccnt;
        
        
        strResult= res.getBody();
        system.debug('Onekey JSON Request : ' + jsonaccnt);
        system.debug('Onekey JSON Response : ' + strResult);
        
        JSONParser parser = JSON.createParser(res.getBody());
        String indName='';
        String managerName = '';
        String final_workplace_name = '';
        //-------------------------------- Release 14
        String fname = '';
        String mname = '';
        String lname = '';
        //--------------------------------
        String specialityValue='';
        String affiliationType='';
        String individualType='';
        String addr='';
        String country='';
        String output_City='';
        SearchResult sr;
        String onkeyId='';
        String workplace_name='';
        String workplace_type='';
        String postal_code='';
        
        //========== R19.3 Niladri =====================      
        String workplace_official_name = '';
        //==============================================
        
        //========== R14.2 Niladri =====================
        String buildingLabel = '';
        String legalCategory = '';
        String structureType = '';       
        //==============================================
        String strResultList='';
        
        //========== Release 14.1 Niladri ==============
        String identifier = 'global';
        List<User> loggedInUser = [select Id, Name, Country,Country_Code__c FROM User WHERE Id =: UserInfo.getUserId()];        
        System.debug('=============== Country Code : '+loggedInUser[0].Country_Code__c);       
        
        AGN_Settings__c ac = AGN_Settings__c.getInstance();
        System.debug('==== Value ====== '+ac.IMS_Speciality_Localization_AGN__c);
        String data = ac.IMS_Speciality_Localization_AGN__c;        
        List<String> lstCountryCode = data.split(',');        
        System.debug(lstCountryCode);
        for(String gc : lstCountryCode){
            if(loggedInUser[0].Country_Code__c == gc){
                identifier = 'local';
            }            
        }                        
        System.debug('========= identifier ========= '+identifier);
        
        /*
rh = new ResultHeader () ;
rh.label = System.Label.AGN_Onekey_FieldLabel_AffiliationType ;
resultHeadersOnekey.add (rh) ;
*/
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'resultSize')){
                    parser.nextToken();
                    if(parser.getText()!=''){
                        onekeyRecordCountIMS=Integer.valueof(parser.getText());
                        if(onekeyRecordCountIMS==0){
                            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_ErrMsg_NoRecords));
                            this.paginaterIMS = new Paginate(0, 0);
                        }
                    }
                }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'success')){
                parser.nextToken();
                if(parser.getText()!=''){
                    if(parser.getText().equalsIgnoreCase('false')){
                        while (parser.nextToken()!= null) {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')){
                                parser.nextToken();
                                if(parser.getText()!=''){
                                    String errorcode=parser.getText();
                                    if(errorcode=='OKWS-2000'){
                                        ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_Msg_No_Country_Access+' : '+selectedCountry));
                                        this.paginaterIMS = new Paginate(0, 0);
                                        return;
                                    }else if(errorcode=='OKWS-3514'){
                                        ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_Msg_Invalid_Primary_Business_Acc));
                                        this.paginaterIMS = new Paginate(0, 0);
                                        return;
                                    }else{
                                        ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'IMS : '+ System.Label.AGN_Onekey_ErrMsg_Unexpected_Error));
                                        this.paginaterIMS = new Paginate(0, 0);
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'results')) {
                
                while (parser.nextToken()!= JSONToken.END_ARRAY) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&  (parser.getText() == 'onekeyEid')){
                        parser.nextToken();
                        if(parser.getText()!=''){
                            onkeyId=parser.getText();
                        }
                    }
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&  (parser.getText() == 'individual')){
                        indName='';
                        mname='';
                        addr='';
                        sr=new SearchResult();
                        sr.srFields = new List<SearchResultField> () ;
                        SearchResultField srfName=new SearchResultField ();
                        SearchResultField srfMiddleName=new SearchResultField ();
                        SearchResultField srfSpeciality1=new SearchResultField ();
                        SearchResultField srfIndividualType=new SearchResultField ();
                        SearchResultField srfAddrLine1=new SearchResultField ();
                        SearchResultField srfCity=new SearchResultField ();
                        SearchResultField srfCode=new SearchResultField ();
                        SearchResultField srfCountry=new SearchResultField ();
                        SearchResultField srfWorkplace=new SearchResultField ();
                        SearchResultField srfAffiliationType=new SearchResultField ();
                        
                        //================ R19.3 Niladri ====================
                        SearchResultField srfworkplaceofficialname = new SearchResultField ();
                        
                        //================ R14.2 Niladri ====================
                        SearchResultField srfbuildingLabel = new SearchResultField ();
                        SearchResultField srfLegalCategoryLabel = new SearchResultField ();
                        
                        if(parser.nextToken()==JSONToken.START_OBJECT){
                            while (parser.nextToken()!= JSONToken.END_OBJECT) {
                                
                                if(parser.getText() == 'firstName'){
                                    parser.nextToken();
                                    
                                    //indName=parser.getText();
                                    fname=parser.getText();
                                }
                                
                                // Release 14 20.12.17
                                if(parser.getText() == 'middleName')
                                {
                                    parser.nextToken();
                                    if(parser.getText() != null && parser.getText() != 'null'){
                                        mname = parser.getText();
                                        // indName =indName+' '+parser.getText();
                                    }
                                }
                                
                                if(parser.getText() == 'lastName'){
                                    if(parser.nextToken() != null){
                                        lname = parser.getText();
                                    }
                                }
                                indName = fname + ' ' + lname;
                                
                                /* if(mname != null && mname != ''){
indName = fname + ' ' + mname + ' ' + lname;
System.debug('============ Name with Middle Name ========= '+indName);
} else
{
indName = fname + ' ' + lname;
System.debug('============ Name without Middle Name ========= '+indName);
} */                                                               
                                
                                //----- Release 14.1 Niladri
                                if(identifier == 'global' ){
                                    if(parser.getText() == 'SP,1'){
                                        while (parser.nextToken()!= JSONToken.END_OBJECT) {
                                            if(parser.getText() == 'Corporatelabel'){                                            
                                                parser.nextToken();
                                                specialityValue=parser.getText();    
                                            }    
                                        }
                                    }
                                } else if(identifier == 'local'){
                                    if(parser.getText() == 'SP,1'){
                                        while (parser.nextToken()!= JSONToken.END_OBJECT) {                                            
                                            if(parser.getText() == 'label'){
                                                parser.nextToken();
                                                specialityValue=parser.getText();   
                                            }    
                                        }
                                    }    
                                }
                            }
                        }
                        while (parser.nextToken()!= null) {
                            
                            if(parser.getText() == 'typeCode'){
                                parser.nextToken();
                                workplace_type=parser.getText();
                                
                            }
                            
                            //----- Release 14.1 Niladri
                            
                            //========= R14.2 Niladri ==============
                            if(parser.getText() == 'CAJ,1'){
                                while (parser.nextToken()!= JSONToken.END_OBJECT) {
                                    if(parser.getText() == 'Corporatelabel'){                                            
                                        parser.nextToken();
                                        legalCategory = parser.getText();    
                                    }    
                                }
                            }
                            
                            if(parser.getText() == 'buildingLabel'){
                                parser.nextToken();
                                buildingLabel = parser.getText();
                            }   
                            
                            if(parser.getText() == 'structureTypeCorporateLabel'){
                                parser.nextToken();
                                structureType = parser.getText();
                            }   
                            
                            //R14.2 Niladri
                            if(loggedInUser[0].Country_Code__c == 'GB'){
                                individualType = legalCategory + '-' + structureType;                                 
                            }else{
                                if(identifier == 'global' ){
                                    if(parser.getText() == 'typeCorporateLabel'){                                
                                        parser.nextToken();
                                        individualType=parser.getText();
                                    }
                                } else if(identifier == 'local' ){                                  
                                    if(parser.getText() == 'typeLabel'){
                                        parser.nextToken();
                                        individualType=parser.getText();
                                    }                                
                                }
                            }                                
                            //if(!isHCP && parser.getText() == 'corporateLabel'){
                            if(!isHCP && parser.getText() == 'label'){
                                parser.nextToken();
                                specialityValue=parser.getText();
                            }
                            
                            if(parser.getText() == 'addressLongLabel'){
                                parser.nextToken();
                                
                                addr=parser.getText();
                            }
                            
                            
                            if(parser.getText() == 'villageLabel'){
                                parser.nextToken();
                                
                                output_City=parser.getText();
                            }
                            if(parser.getText() == 'country'){
                                parser.nextToken();
                                
                                country=parser.getText();
                                country=country.replace('UK','GB');
                            }
                            //========= R14.2 Niladri ==============
                            
                            /* if(parser.getText() == 'CAJ,1'){
while (parser.nextToken()!= JSONToken.END_OBJECT) {
if(parser.getText() == 'Corporatelabel'){                                            
parser.nextToken();
legalCategory = parser.getText();    
}    
}
}

if(parser.getText() == 'buildingLabel'){
parser.nextToken();
buildingLabel = parser.getText();
}   

if(parser.getText() == 'structureTypeCorporateLabel'){
parser.nextToken();
structureType = parser.getText();
}  */ 
                            //=======================================
                            if(parser.getText() == 'usualName'){
                                parser.nextToken();
                                
                                workplace_name=parser.getText();
                                System.debug('======= workplace_name ======= '+workplace_name);
                                if(workplace_name.equalsIgnoreCase('null')){
                                    workplace_name='WORKPLACE';
                                }
                            }
                            
                            // *start Release 14 #primary parent name fetched from oneKey
                            if(parser.getText() == 'managerWorkplaceUsualName')
                            {
                                parser.nextToken();
                                managerName=parser.getText();
                            }                                                        
                            // concat primary parent name with business account of Department type
                            //R19.3 Niladri ------ PMO-2202
                            if(!GAS_Hierarchical_Setting__c.getOrgDefaults().IMS_WKP_Official_Name_Country_Code__c.contains(OnekeyCountryCode)){
                                if(managerName!='null'){
                                    final_workplace_name = workplace_name+'-'+managerName;                                    
                                }else{
                                    final_workplace_name=workplace_name+'';                                    
                                }
                            }                                
                            
                            //====== R19.3 Niladri ------ PMO-2202 
                            if(parser.getText() == 'officialName'){
                                parser.nextToken();
                                workplace_official_name = parser.getText();                               
                                if(workplace_official_name != 'null'){
                                    final_workplace_name = workplace_official_name;                                   
                                }
                            } 
                            //====== R19.3 Niladri ------ PMO-2202 
                            if(GAS_Hierarchical_Setting__c.getOrgDefaults().IMS_WKP_Official_Name_Country_Code__c.contains(OnekeyCountryCode)){
                                if(workplace_official_name == 'null' || workplace_official_name == null){
                                    // concat primary parent name with business account of Department type
                                    if(managerName!='null'){                                    
                                        final_workplace_name = workplace_name+'-'+managerName;                                    
                                    }else if(managerName=='null' || managerName== null){                                    
                                        final_workplace_name = workplace_name ;                                    
                                    }
                                } 
                            }               
                            
                            //final_workplace_name=workplace_name+'-'+buildingLabel;
                            // *end Release 14 #primary parent name fetched from oneKey
                            if(parser.getText() == 'typeCodeCorporateLabel'){
                                parser.nextToken();
                                affiliationType=parser.getText();
                                parser.nextToken();
                                parser.nextToken();
                                parser.nextToken();
                                parser.nextToken();
                                break;
                            }
                            
                        }
                        
                        System.debug('========== buildingLabel ============ '+buildingLabel);
                        System.debug('========== legalCategory ============ '+legalCategory);                       
                        System.debug('========== structureType ============ '+structureType);
                        System.debug('========= final_workplace_name ======== '+final_workplace_name);
                        
                        sr.acctName = onkeyId +':'+country ;
                        
                        
                        srfName.value=indName ;
                        sr.srFields.add(srfName);
                        // Release 14 #middleName display IMS
                        srfMiddleName.value = mname;
                        sr.srFields.add(srfMiddleName);
                        
                        if(workplace_official_name != 'null'){
                            srfworkplaceofficialname.value= final_workplace_name;
                            System.debug('========= srfworkplaceofficialname.value ======== '+srfworkplaceofficialname.value);
                            sr.srFields.add(srfworkplaceofficialname);
                        }
                        if(workplace_name != 'null'){
                            srfWorkplace.value= final_workplace_name;
                            System.debug('========= srfWorkplace.value ======== '+srfWorkplace.value);
                            sr.srFields.add(srfWorkplace);
                        }
                        //============= R14.2 Niladri ============
                        srfbuildingLabel.value= buildingLabel;
                        sr.srFields.add(srfbuildingLabel);
                        
                        /*srfLegalCategoryLabel.value= legalCategory;
sr.srFields.add(srfLegalCategoryLabel);*/
                        
                        
                        srfAddrLine1.value=addr;
                        sr.srFields.add(srfAddrLine1);
                        
                        srfCity.value=output_City;
                        sr.srFields.add(srfCity);
                        
                        
                        srfCountry.value=country;
                        sr.srFields.add(srfCountry);
                        
                        
                        srfSpeciality1.value=specialityValue ;
                        sr.srFields.add(srfSpeciality1);
                        
                        srfIndividualType.value=individualType ;
                        sr.srFields.add(srfIndividualType);
                        
                        
                        /*
srfAffiliationType.value=affiliationType;
sr.srFields.add(srfAffiliationType);
*/
                        resultsIMS.add(sr);
                        system.debug('<=========IMS Result=========>'+resultsIMS);
                    }
                    
                    
                }
            }
            
        }
        onekeyRecordCountIMS=resultsIMS.size();
        PaginationDemoControllerIMS();
        
    }
    public void PaginationDemoController(){
        //Get the data we need to paginate
        
        List<SearchResult> resultsList = results;
        //Set the page size
        Integer pageSize = 20;
        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        
        this.paginater = new Paginate(resultsList.size()>100?100:resultsList.size(), pageSize);
        
        //These lists hold the data
        this.fullGenericList = new List<List<SearchResult>>();
        this.results = new List<SearchResult>();
        //Break out the full list into a list of lists
        if(resultsList.size() > 0){
            List<SearchResult> tempCC = new List<SearchResult>();
            Integer i = 0;
            for(SearchResult cc : resultsList){
                tempCC.add(cc);
                i++;
                if(i == pageSize){
                    this.fullGenericList.add(tempCC);
                    tempCC = new List<SearchResult>();
                    i = 0;
                }
            }
            if(!tempCC.isEmpty()){
                this.fullGenericList.add(tempCC);
            }
            //Gets the correct list of data to show on the page
            this.results = this.fullGenericList.get(this.paginater.index);
        }
    }
    public PageReference previousPage(){
        this.paginater.decrement();
        return changeData();
    }
    public PageReference nextPage(){
        this.paginater.increment();
        return changeData();
    }
    public PageReference updatePage(){
        this.paginater.updateNumbers();
        return changeData();
    }
    public PageReference changeData(){
        this.results = this.fullGenericList.get(this.paginater.index);
        return null;
    }
    public List<CustomClass> populateData(){
        List<CustomClass> customClassList = new List<CustomClass>();
        for(Integer i = 1; i < 50; i++){
            customClassList.add(new CustomClass(i, 'Name:  ' + String.valueOf(i)));
        }
        return customClassList;
    }
    public class CustomClass{
        public Integer num{get;set;}
        public String name{get;set;}
        public CustomClass(Integer num, String name){
            this.num = num;
            this.name = name;
        }
    }
    
    
    
    public void PaginationDemoControllerIMS(){
        //Get the data we need to paginate
        
        List<SearchResult> resultsList = resultsIMS;
        //Set the page size
        Integer pageSize = 20;
        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        
        this.paginaterIMS = new Paginate(resultsList.size()>100?100:resultsList.size(), pageSize);
        
        //These lists hold the data
        this.fullGenericListIMS = new List<List<SearchResult>>();
        this.resultsIMS = new List<SearchResult>();
        //Break out the full list into a list of lists
        if(resultsList.size() > 0){
            List<SearchResult> tempCC = new List<SearchResult>();
            Integer i = 0;
            for(SearchResult cc : resultsList){
                tempCC.add(cc);
                i++;
                if(i == pageSize){
                    this.fullGenericListIMS.add(tempCC);
                    tempCC = new List<SearchResult>();
                    i = 0;
                }
            }
            if(!tempCC.isEmpty()){
                this.fullGenericListIMS.add(tempCC);
            }
            //Gets the correct list of data to show on the page
            this.resultsIMS = this.fullGenericListIMS.get(this.paginaterIMS.index);
        }
    }
    public PageReference previousPageIMS(){
        this.paginaterIMS.decrement();
        return changeDataIMS();
    }
    public PageReference nextPageIMS(){
        this.paginaterIMS.increment();
        return changeDataIMS();
    }
    public PageReference updatePageIMS(){
        this.paginaterIMS.updateNumbers();
        return changeDataIMS();
    }
    public PageReference changeDataIMS(){
        this.resultsIMS = this.fullGenericListIMS.get(this.paginaterIMS.index);
        return null;
    }
    
    // This method has been updated with use of Territory and UserTerritory been replaced by Territory2 and UserTerritory2Association 
    // TM2.0 Implementation 
    public PageReference addToTerritory()
    {
        
        system.debug('## Entered addToTerritory.  GASAffHCP: ' + GASAffHCP + '          GASAffHCO: ' + GASAffHCO);
        
        if(String.Valueof(specId) == ''){
            specName='';
        }
        if(String.Valueof(specIdAGN) == ''){
            specNameAGN='';
        }
        GASSearchDone=false;
        
        String newAcctId  = '';
        if (results.size() == 0){
            if( IsUserOnekeyEnabled && resultsIMS.size() == 0) {
                return null;
                
            }else if(IsUserOnekeyEnabled == false){
                return null;
            }
        }
        
        
        // Find the selected Account
        Map<String,String> pickMap = new Map<String,String>();
        for (SearchResult sr : results) {
            if (sr.isSelected == true) {
                Schema.DescribeFieldResult fieldResult = Account.Status_AGN__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry pl : ple){
                    pickMap.put(pl.getLabel(), pl.getValue());
                }
                if(sr.accStatus!=null && pickMap!=null && pickMap.containsKey(sr.accStatus)){
                    String statusValue = pickMap.get(sr.accStatus);
                    //if(statusValue != Null && statusValue != 'Active'){//R32020: Req No:-2201 comeented active filter.
                    //R32020: Req No:-2201  Now User can able to add inactive accunts to their territory from GAS Page.
                    if((statusValue != Null ) && !(statusValue == 'Active'||statusValue == 'Inactive')){
                        system.debug('sr.accStatus====>'+sr.accStatus);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Veeva : '+Label.AGN_Onekey_Inactive_Msg+' '+sr.accStatus+' Account'));
                        
                        return null ;
                    }
                }
                newAcctId = sr.acctId ;
                break ;
            }
        }
        
        for (SearchResult sr : resultsIMS) {
            
            system.debug('## sr: ' + sr);
            
            if (sr.isSelected == true) {
                saveOneKeyData();
                newAcctId = sr.acctId ;
                
                /* R14: Below 2 lines of code has been introduced to bypass Add All HCO and Add All HCP functionality in case of adding an account from IMS */
                
                system.debug('## R14 changes started.  GASAffHCP: ' + GASAffHCP + '          GASAffHCO: ' + GASAffHCO);
                
                GASAffHCP = false;
                GASAffHCO = false;
                
                /* ************End of Changes for R14************ */
                
                system.debug('## R14 changes ended.  GASAffHCP: ' + GASAffHCP + '          GASAffHCO: ' + GASAffHCO);
                
                system.debug('newAcctId======>'+newAcctId+' sr.acctId=====>'+sr.acctId);
                break;  
            }
        }
        if (newAcctId == '') {
            return null ;
        }
        
        
        // Get the territory for the user
        //jkelso - 8/12/13 - build list of multiple territories and territory Ids
        List<UserTerritory2Association> utList = new List<UserTerritory2Association>();
        List<Id> utIds = new List<Id>();
        for (UserTerritory2Association ut :[select Territory2Id from UserTerritory2Association where UserId = :UserInfo.getUserId() AND Territory2.Territory2Model.State ='Active']) {
            utList.add(ut);
            utIds.add(ut.Territory2Id);
        }
        if (utList.size() == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GAS_NOTALGN));
            return null ;
        }
        //jkelso - 8/12/13 - new custom setting to allow align of multiple territory
        else if (utList.size() > 1 && !GAS_ALIGN_MULTIPLE) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GAS_MANYALGN));
            return null ;
        }
        // Get the name of the Territory
        List<String> userTerrNames = new List<String>();
        String terrString = '';
        //jkelso - 8/12/13 - build string of multiple territories
        for (Territory2 t : [SELECT Name FROM Territory2 WHERE ID IN :utIds]) {
            userTerrNames.add(t.Name);
            terrString += t.Name + ';';
        }
        terrString  = terrString.Substring(0,terrString.length()-1);
        //PMO 3922 :extra variable is added to store user territory
        String userTerritory = terrString;
        
        // Release 09 Requirement no: 866
        if(updateterritoryname!='false' && updateterritoryname!=null)
        {
            terrString=updateterritoryname;
            userTerritory = updateterritoryname;
            userTerrNames = new List<String>();
            userTerrNames.add(terrString);
        }
        String userterrString= terrString;
        // END OF Release 09 Requirement no: 866
        
        // Now check for existing territories for the Account
        List <ObjectTerritory2Association> asList = [select ObjectId,Territory2Id, AssociationCause 
                                                     from ObjectTerritory2Association 
                                                     where ObjectId =  :newAcctId];
        
        if (asList.size() > 0) {
            // Get all the UserOrGroupIds, and store in a List
            // Removed as part of TM2.0 Implementation
            /*
List<Id> idlist1 = new List<Id> () ;
Set<Id> manuallyAssignedGrpIDs = new Set<ID>();//mnaidu - 4/28/13 - capture what's manually assigned
for (AccountShare ash : asList) {
idlist1.add(ash.UserOrGroupId) ;
if(ash.RowCause=='TerritoryManual'){
manuallyAssignedGrpIDs.add(ash.UserOrGroupId);   //mnaidu - 4/28/13 - capture what's manually assigned
}
}
*/
            // Now let's get the IDs of the Territories
            List<Id> idlist2 = new List<Id> () ;
            Set<Id> manuallyAssignedTerrIDs = new Set<ID>();//mnaidu - 4/28/13 - capture what's manually assigned
            //List<Group> groupList = [select RelatedId from group where Id in :idlist1] ;
            for (ObjectTerritory2Association ot2a : asList) {
                idlist2.add(ot2a.Territory2Id) ;
                if(ot2a.AssociationCause=='Territory2Manual'){
                    manuallyAssignedTerrIDs.add(ot2a.Territory2Id); //mnaidu - 4/28/13 - capture what's manually assigned
                }
            }
            // Finally, get the names
            List <Territory2> terrList = [select Id, Name from Territory2 where Id in :idlist2] ;
         
            for (Territory2 t : terrList)
            {
                // If the Territory is already there, output a warning and exit
                for (String utn : userTerrNames) {
                    if (t.Name == utn) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,GAS_INTERR)); // CUSTOMER ALREADY IN TERRITORY
                        return null ;
                    }
                }
                if(manuallyAssignedTerrIDs.contains(t.Id))  // @ajay  t is all the territory manually assigned to accshare
                { //mnaidu - 4/28/13 - only add to the terrString if this is Manually already assigned
                    terrString = terrString + ';' + t.Name ;
                }
            }
        }
        //Insert TSF - Parent Account - below check 'GAS_ALIGN_MULTIPLE' commented on 29/01/2016
        //If(!GAS_ALIGN_MULTIPLE){
        String usersTerr  = userterrnames[0];
        List<TSF_vod__c> tsfList = new List<TSF_vod__c>([select id from TSF_vod__c where Territory_vod__c = :usersTerr  AND account_vod__c = :newAcctId]);
        TSF_vod__c tsf;
        //String addedTerritory = terrString;
        If(tsfList.isEmpty())
        {
            String TSFname = '';
            TSFname = usersTerr;
            If(TSFname.length() == 80)
            {
                TSFname = TSFname.substring(0,80);
            }
            TSF_vod__c newTSF = new TSF_vod__c();
            //AS CC
            if (Schema.sObjectType.TSF_vod__c.fields.account_vod__c.isCreateable())
            {
                newTSF.account_vod__c = newAcctId;
            }
            if (Schema.sObjectType.TSF_vod__c.fields.territory_vod__c.isCreateable())
            {
                newTSF.territory_vod__c = usersTerr;
            }
            if (Schema.sObjectType.TSF_vod__c.fields.name.isCreateable())
            {
                newTSF.name = TSFname;
            }
            if (Schema.sObjectType.TSF_vod__c.fields.Target_Manager_SMB__c.isCreateable())
            {
                newTSF.Target_Manager_SMB__c = true;
            }
            system.debug('newTSF=====>'+newTSF);
            if (Schema.sObjectType.TSF_vod__c.isCreateable() )
            {
                insert newTSF;
            }
            //AS CC
            
        }
        else if (tsfList.size()==1)
        {
            tsf = tsfList[0] ;
            //AS CC
            if (Schema.sObjectType.TSF_vod__c.fields.Target_Manager_SMB__c.isUpdateable())
            {
                tsf.Target_Manager_SMB__c = true;
            }
            if (Schema.sObjectType.TSF_vod__c.isUpdateable() )
            {
                update (tsf) ;
            }
            //AS CC
        }
        else
        {
            //keep it blank
        }
        //}    //END Adding
        GAS_Alignment_History_vts__c history = new GAS_Alignment_History_vts__c();
        
        try{
            
            //track that Account to be aligned
            history.Account__c = newAcctId;
            history.New_Territory__c = terrString;
            // Now let's see if the Account Territory Loader already exists
            List <Account_Territory_Loader_vod__c> atlList = [select Id, Territory_vod__c from Account_Territory_Loader_vod__c where Account_vod__c = :newAcctId] ;
            if (atlList.size() == 1)
            {
                Account_Territory_Loader_vod__c atl = atlList[0] ;
                
                //track ATL and old territory string
                history.Account_Territory_Loader__c = atl.Id;
                history.Old_Territory__c = atl.Territory_vod__c;
                //set new ATL territory
                //PMO:3922 ATL field is changed from Territory_vod__c to Territory_To_Add_vod__c to update the missing record in OTA object
                atl.Territory_To_Add_vod__c = userTerritory;  
                update (atl) ;
                //calling Method ParentChildAddToTerritory for Territory Allignment to related Parent/ Child Account
                ParentChildAddToTerritory(newAcctId,terrString,usersTerr,trackAlignmentHistory,GASAffHCO,GASAffHCP,userterrString );
                //insert history record
                if (trackAlignmentHistory) {
                    insert history;
                }
                
            }
            else {
                Account_Territory_Loader_vod__c atl = new Account_Territory_Loader_vod__c();
                atl.Account_vod__c=newAcctId;
                atl.External_ID_vod__c=newAcctId;
                atl.Territory_vod__c=terrString;
                insert (atl) ;
                //calling Method ParentChildAddToTerritory for Territory Allignment to related Parent/ Child Account
                ParentChildAddToTerritory(newAcctId,terrString,usersTerr,trackAlignmentHistory,GASAffHCO,GASAffHCP,userterrString );
                //track history
                history.Account_Territory_Loader__c = atl.Id;
                if (trackAlignmentHistory) {
                    insert history;
                }
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,GAS_SUCCESS));
            
            //  ************ 19R2 Started ************ 
            addToTerritory_EmailTo_Manager(newAcctId,userterrString,GAS_EMAIL_SUCCESS);
            // ************ 19R2 End ************ 
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
        
        return null ;
    }
    /*--------------------------------------------------------------------------------------------------*/
    /**
***** @author = Manoj Paul
***** @date = July 29, 2016
***** @param - List of Account Ids to process, terrString, usersTerr, trackAlignmentHistory
***** @return - Update ATL ,TSF,GAS History and return Success/failure Message
***** @Release009 : Requiremnt ID : 568
***** Sep 23, 2016 - Change in the Add to Territory functionality of GAS
**/
    public  Boolean ParentChildAddToTerritory(String AcctId,String terrString,String usersTerr,Boolean trackAlignmentHistory,Boolean GASAffHCO,Boolean GASAffHCP,String userterrString)
    {
        // Get RecordType name from the selected Account in GAS. Based on the record type, fetching all the related HCO and HCP.
        Boolean TSFEmpty;
        Boolean ATLEmpty;
        String AccRecType;
        Set<ID> AffIdrecord = new Set<ID>();
        AccRecType = [SELECT RecordType.name FROM Account where Id =:AcctId].RecordType.name;
        //condition to fetch related child/parent Accounts for Selected Account from GAS for Operation "Add To Territory"
        
        system.debug('## Inside ParentChildAddToTerritory.  GASAffHCP: ' + GASAffHCP + '          GASAffHCO: ' + GASAffHCO);
        
        if((AccRecType == 'Professional_vod')&& (!GASAffHCO))
        {
            for(Child_Account_vod__c PrecAffId :[Select Parent_Account_vod__c from Child_Account_vod__c where (Child_Account_vod__r.id =:AcctId AND Primary_vod__c ='Yes')])
            {
                AffIdrecord.add(PrecAffId.Parent_Account_vod__c);
            }
        }
        
        else if((AccRecType == 'Professional_vod')&& (GASAffHCO))
        {
            for(Child_Account_vod__c PrecAffId :[Select Parent_Account_vod__c from Child_Account_vod__c where (Child_Account_vod__r.id =:AcctId)])
            {
                AffIdrecord.add(PrecAffId.Parent_Account_vod__c);
            }
        }
        
        else if((AccRecType != 'Professional_vod')&& (GASAffHCP))
        {
            for(Child_Account_vod__c CrecAffId : [Select Child_Account_vod__c from Child_Account_vod__c where (Parent_Account_vod__r.id =:AcctId)])
            {
                AffIdrecord.add(CrecAffId.Child_Account_vod__c);
            }
        }
        
        
        
        system.debug('## Inside ParentChildAddToTerritory.  AffIdrecord: ' + AffIdrecord);
        
        
        //--------------------------------------------------- ATL---------------------------------------------------------------------------------------
        Map <ID,Account_Territory_Loader_vod__c> ATLMap =  new Map <ID,Account_Territory_Loader_vod__c>();
        for(Account_Territory_Loader_vod__c atl: [select Id,Account_vod__c,Territory_vod__c
                                                  FROM Account_Territory_Loader_vod__c
                                                  WHERE Account_vod__c IN :AffIdrecord
                                                 ])
        {
            
            ATLMap.put(atl.Account_vod__c,atl);
        }
        
        List<Account_Territory_Loader_vod__c> atlfinalupdate = new List<Account_Territory_Loader_vod__c>();
        List<Account_Territory_Loader_vod__c> atlfinalinsert = new List<Account_Territory_Loader_vod__c>();
        List<GAS_Alignment_History_vts__c> finalhistory = new List<GAS_Alignment_History_vts__c>();
        
        List<ID> accupdate = new List<ID>();
        for (ID xyz : AffIdrecord)
        {
            GAS_Alignment_History_vts__c history = new GAS_Alignment_History_vts__c();
            Account_Territory_Loader_vod__c atlupadte = new Account_Territory_Loader_vod__c();
            Boolean contains = ATLMap.containsKey(xyz);
            if(contains==true)
            {
                atlupadte=ATLMap.get(xyz);
                atlupadte.Territory_To_Add_vod__c = userterrString ;
                atlfinalupdate.add(atlupadte);
                history.Account__c = xyz;
                history.Old_Territory__c = atlupadte.Territory_vod__c;
                String oldter= atlupadte.Territory_vod__c;
                history.Account_Territory_Loader__c = atlupadte.Id;
                history.New_Territory__c = oldter + userterrString ;
                finalhistory.add(history);
            }
        }
        
        
        update atlfinalupdate;
        
        
        for (ID xyz : AffIdrecord)
        {
            Boolean contains = ATLMap.containsKey(xyz);
            if(contains==false)
            {
                accupdate.add(xyz);    // account that does not have atl.
            }
            
        }
        
        for(ID xyz2 : accupdate)
        {
            
            Account_Territory_Loader_vod__c atlinsert = new Account_Territory_Loader_vod__c();
            atlinsert.Account_vod__c=xyz2;
            atlinsert.External_ID_vod__c=xyz2;
            atlinsert.Territory_vod__c=userterrString;
            atlfinalinsert.add(atlinsert);
            
            
        }
        
        upsert atlfinalinsert;   // CREATING ATL for those account that does not have atl.
        
        
        Map <ID,Account_Territory_Loader_vod__c> ATLnewMap =  new Map <ID,Account_Territory_Loader_vod__c>();
        for(Account_Territory_Loader_vod__c atl: [select Id,Account_vod__c,Territory_vod__c
                                                  FROM Account_Territory_Loader_vod__c
                                                  WHERE Account_vod__c IN :accupdate
                                                 ])
        {
            
            ATLnewMap.put(atl.Account_vod__c,atl);
        }
        
        for (ID xyz6 : accupdate)
        {
            GAS_Alignment_History_vts__c history = new GAS_Alignment_History_vts__c();
            Account_Territory_Loader_vod__c atlcheck = new Account_Territory_Loader_vod__c();
            Boolean contains = ATLnewMap.containsKey(xyz6);
            if(contains==true)
            {
                atlcheck=ATLnewMap.get(xyz6);
                history.Account__c = xyz6;
                history.Old_Territory__c = atlcheck.Territory_vod__c;
                String oldter= atlcheck.Territory_vod__c;
                history.Account_Territory_Loader__c = atlcheck.Id;
                history.New_Territory__c = oldter + userterrString ;
                finalhistory.add(history);
            }
        }
        
        upsert finalhistory;
        
        
        //--------------------------------------------------- ATL---------------------------------------------------------------------------------------
        
        //--------------------------------------------------- TSF---------------------------------------------------------------------------------------
        
        Map <ID,TSF_vod__c> TSFMap =  new Map <ID,TSF_vod__c>();
        for(TSF_vod__c tsf: [select Id,Account_vod__c
                             FROM TSF_vod__c
                             WHERE Account_vod__c IN :AffIdrecord AND Territory_vod__c = :usersTerr
                            ])
        {
            
            TSFMap.put(tsf.Account_vod__c,tsf);
        }
        
        List<TSF_vod__c> tsffinalupdate = new List<TSF_vod__c>();
        List<TSF_vod__c> tsffinalinsert = new List<TSF_vod__c>();
        List<ID> tsfupdate = new List<ID>();
        for (ID xyz3 : AffIdrecord)
        {
            
            TSF_vod__c tsfupdat = new TSF_vod__c();
            Boolean contains = TSFMap.containsKey(xyz3);
            if(contains==true)
            {
                tsfupdat=TSFMap.get(xyz3);
                //AS CC
                if (Schema.sObjectType.TSF_vod__c.fields.Target_Manager_SMB__c.isUpdateable())
                {
                    tsfupdat.Target_Manager_SMB__c = true ;
                }
                tsffinalupdate.add(tsfupdat);
            }
        }
        
        //AS CC
        if (Schema.sObjectType.TSF_vod__c.isUpdateable() )
        {
            update tsffinalupdate;
        }
        
        
        for (ID xyz4 : AffIdrecord)
        {
            Boolean contains = TSFMap.containsKey(xyz4);
            if(contains==false)
            {
                tsfupdate.add(xyz4);
            }
        }
        
        String TSFname = '';
        TSFname = usersTerr;
        If(TSFname.length() == 80)
        {
            TSFname = TSFname.substring(0,80);
        }
        for(ID xyz5 : tsfupdate)
        {
            TSF_vod__c tsfinsert = new TSF_vod__c();
            //AS CC
            if (Schema.sObjectType.TSF_vod__c.fields.account_vod__c.isCreateable() )
            {
                tsfinsert.account_vod__c=xyz5;
            }
            if (Schema.sObjectType.TSF_vod__c.fields.territory_vod__c.isCreateable() &&
                Schema.sObjectType.TSF_vod__c.fields.territory_vod__c.isUpdateable())
            {
                tsfinsert.territory_vod__c=usersTerr;
            }
            if (Schema.sObjectType.TSF_vod__c.fields.name.isCreateable() &&
                Schema.sObjectType.TSF_vod__c.fields.name.isUpdateable())
            {
                tsfinsert.name=TSFname;
            }
            if (Schema.sObjectType.TSF_vod__c.fields.Target_Manager_SMB__c.isCreateable() &&
                Schema.sObjectType.TSF_vod__c.fields.Target_Manager_SMB__c.isUpdateable())
            {
                tsfinsert.Target_Manager_SMB__c = true ;
            }
            //AS CC
            tsffinalinsert.add(tsfinsert);
            
        }
        //AS CC
        if (Schema.sObjectType.TSF_vod__c.isCreateable() && Schema.sObjectType.TSF_vod__c.isUpdateable())
        {
            upsert tsffinalinsert;
        }
        
        //--------------------------------------------------- TSF---------------------------------------------------------------------------------------
        
        
        return null;
    }
    
  
    /*
***** @author = Manoj Paul
***** @date = July 29, 2016
***** @param - List of Account Ids to process
***** @return - Update ATL ,TSF,GAS History and return Success/failure Message
***** @Release008 : Requiremnt ID : 932
***** Feb 29, 2016 - Added new Requirement to Drop Territory functionality
**/
    // This method has been updated with use of Territory and UserTerritory been replaced by Territory2 and UserTerritory2Association 
    // TM2.0 Implementation
    public PageReference removeFromTerritory()
    {
        if(String.Valueof(specId) == ''){
            specName='';
        }
        if(String.Valueof(specIdAGN) == ''){
            specNameAGN='';
        }
        Integer i;
        String newAcctId  = '';
        GASSearchDone=false;
        if (results == null || results.size() == 0)
        {
            return null ;
        }
        
        // Find the selected Account
        Map<String,String> pickMap = new Map<String,String>();
        for (SearchResult sr : results) {
            //======Start=====//
            if (sr.isSelected == true) {
                Schema.DescribeFieldResult fieldResult = Account.Status_AGN__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry pl : ple){
                    pickMap.put(pl.getLabel(), pl.getValue());
                }
                if(sr.accStatus!=null && pickMap!=null && pickMap.containsKey(sr.accStatus)){
                    String statusValue = pickMap.get(sr.accStatus);
                    if(statusValue != Null && statusValue != 'Active'){
                        system.debug('sr.accStatus====>'+sr.accStatus);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Veeva : '+Label.AGN_Onekey_Inactive_Remove_Msg+' '+sr.accStatus+' Account'));
                        return null ;
                    }
                }
                newAcctId = sr.acctId ;
                break ;
            }
            //END
        }
        if (newAcctId == '') {
            return null ;
        }
        
        List<Account> HCAlst = new List<Account>();
        //HCAlst = [SELECT Id,RecordType.name FROM Account where Id =:newAcctId AND RecordType.name !='Professional_vod'];
        HCAlst = [SELECT Id,RecordType.name FROM Account where Id =:newAcctId];
        /*if(HCAlst.size() > 0)
{
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GAS_HCAMESSAGE));
return null;
}*/
        
        // Get the territory for the user so that it can be stored in the GAS History
        // build list of multiple territories and territory Ids
        List<UserTerritory2Association> utList = new List<UserTerritory2Association>();
        List<Id> utIds = new List<Id>();
        for (UserTerritory2Association ut :[select Territory2Id from UserTerritory2Association where UserId = :UserInfo.getUserId() AND Territory2.Territory2Model.State ='Active']) {
            utList.add(ut);
            utIds.add(ut.Territory2Id);
        }
        if (utList.size() == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GAS_NOTALGN));
            return null ;
        }
        
        // new custom setting to allow align of multiple territory
        else if (utList.size() > 1 && !GAS_ALIGN_MULTIPLE) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GAS_MANYALGN));
            return null ;
        }
        
        // Get the name of the Territory
        List<String> userTerrNames = new List<String>();
        String terrString = '';
        //build string of multiple territories
        for (Territory2 t : [SELECT Name FROM Territory2 WHERE ID IN :utIds]) {
            userTerrNames.add(t.Name);
            terrString += t.Name + ';';
        }
        terrString  = terrString.Substring(0,terrString.length()-1);
        // Now check for existing territories for the Account
        
        // Release 09 Requirement no: 866
        if(updateterritoryname!='false' && updateterritoryname!=null)
        {
            terrString=updateterritoryname;
            userTerrNames = new List<String>();
            userTerrNames.add(terrString);
        }
        // END OF Release 09 Requirement no: 866
        
        List <ObjectTerritory2Association> asList = [select ObjectId,Territory2Id, AssociationCause 
                                                     from ObjectTerritory2Association 
                                                     where ObjectId =  :newAcctId]; //and RowCause in ('TerritoryManual')- check for any kinds of alignment
        if (asList.size() > 0)
        {
            // Get all the UserOrGroupIds, and store in a List
            // Removed as part of TM2.0 Implementation
            /*
List<Id> idlist1 = new List<Id> () ;
Set<Id> manuallyAssignedGrpIDs = new Set<ID>();

for (AccountShare ash : asList) {
idlist1.add(ash.UserOrGroupId) ;
if(ash.RowCause=='TerritoryManual'){
manuallyAssignedGrpIDs.add(ash.UserOrGroupId);   //- capture what's manually assigned
}
}
*/
            // Now let's get the IDs of the Territories
            List<Id> idlist2 = new List<Id> () ;
            Set<Id> manuallyAssignedTerrIDs = new Set<ID>();//- capture what's manually assigned
            //List<Group> groupList = [select RelatedId from group where Id in :idlist1] ;
            for (ObjectTerritory2Association ash : asList) {
                idlist2.add(ash.Territory2Id) ;
                if(ash.AssociationCause=='Territory2Manual'){
                    manuallyAssignedTerrIDs.add(ash.Territory2Id); //- capture what's manually assigned
                }
            }
            // Finally, get the names
            List <Territory2> terrListcheck = [select Id, Name from Territory2 where Id in :idlist2] ;
            List <Territory2> terrList = [select Id, Name from Territory2 where Id in :utIds] ;
            remcchk=0;
            for (Territory2 t : terrListcheck)
            {
                
                // If the Territory is already there, output a warning and exit
                for (String utn : userTerrNames)
                {
                    if (t.Name == utn)
                    {
                        remcchk++;
                        
                    }
                }
                
            }
            if (remcchk==0)
            {
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,GAS_REMOVE_CHECK));
                return null ;
            }
        }
        
        //Insert TSF - Parent Account - below check 'GAS_ALIGN_MULTIPLE' commented on 29/01/2016
        //If(!GAS_ALIGN_MULTIPLE)
        String usersTerr  = userterrnames[0];
        
        List<TSF_vod__c> tsfList = new List<TSF_vod__c>([select id,Target_Manager_SMB__c from TSF_vod__c where Territory_vod__c = :usersTerr  AND account_vod__c = :newAcctId]);
        //New list has been instantiated to get the list of deleted TSF records inside for Loop and finally delete outside the loop.
        List<TSF_vod__c> deltsflist = new List<TSF_vod__c>();
        //TSF_vod__c tsf;
        if (tsfList.size()>0)
        {
            for(TSF_vod__c tsf : tsfList )
            {
                //tsf = tsfList[i] ;
                if(tsf.Target_Manager_SMB__c=True)
                {
                    deltsflist.add(tsf);
                }
            }
            //AS CC
            if(TSF_vod__c.sObjectType.getDescribe().isDeletable())
            {
                delete(deltsflist) ;
            }
        }
        
        //END Adding
        GAS_Alignment_History_vts__c history = new GAS_Alignment_History_vts__c();
        
        try{
            
            //track that Account to be aligned
            history.Account__c = newAcctId;
            
            //Modified code for Bug Fix for Remove from Territory
            String newHisTerrStrbefore = '';
            String newHisTerrStrafter = '';
            
            // Now let's see if the Account Territory Loader already exists
            List <Account_Territory_Loader_vod__c> atlList = [select Id, Territory_vod__c,Territory_to_Drop_vod__c from Account_Territory_Loader_vod__c where Account_vod__c = :newAcctId] ;
            if (atlList.size() == 1)
            {
                Account_Territory_Loader_vod__c atl = atlList[0] ;
                //track ATL and old territory string
                history.Account_Territory_Loader__c = atl.Id;
                history.Old_Territory__c = atl.Territory_vod__c;
                newHisTerrStrbefore = atl.Territory_vod__c;
                newHisTerrStrafter = newHisTerrStrbefore.remove(';'+terrString);
                history.New_Territory__c = newHisTerrStrafter;
                //set new ATL territory
                atl.Territory_to_Drop_vod__c = terrString ;
                update (atl) ;
                //insert history record
                if (trackAlignmentHistory) {
                    insert history;
                }
                
            }
            else {
                
                Account_Territory_Loader_vod__c atl = new Account_Territory_Loader_vod__c();
                atl.Account_vod__c=newAcctId;
                atl.External_ID_vod__c=newAcctId;
                atl.Territory_vod__c=terrString;
                
                insert (atl) ;
                
                //track history
                history.Account_Territory_Loader__c = atl.Id;
                if (trackAlignmentHistory) {
                    insert history;
                }
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,GAS_REMOVE));
            
            //  ************ 19R2 Started ************ 
            removeFromTerritory_EmailTo_Manager(newAcctId,terrString,GAS_EMAIL_SUCCESS);
            // ************ 19R2 End ************ 
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
        
        return null ;
    }
    
    //==================================End of Release 008 : Requiremnt ID: 932Modification==================================
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/apex/AGN_searchAccts');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    
    private static String joinStrings (Set<String> ss, String delim) {
        String retVal = '' ;
        for (String s : ss) {
            if (retVal != '')  {
                retVal += delim ;
            }
            retVal += s ;
        }
        return retVal ;
    }
    
    private static String getPhoneRegex (String inph) {
        
        Pattern pt = Pattern.compile('[^0-9]');
        String [] res = pt.split(inph) ;
        String digits = '' ;
        for (Integer i = 0 ; i < res.size(); i++) {
            digits = digits + res[i] ;
        }
        String retval= '';
        
        if (digits.length() == 10) {
            retval = '%' + digits.substring(0,3) + '%' + digits.substring(3,6) + '%' + digits.substring (6,10) + '%' ;
        }
        else if (digits.length() == 7) {
            retval = '%' + digits.substring(0,3) + '%' + digits.substring(3,7) + '%' ;
        }
        else if (digits.length() == 4) {
            retval = '%' + digits ;
        }
        else {
            retval = digits ;
        }
        return retval ;
    }
    
    private String getObjValue (sObject so, String fname, String typex) {
        
        if (typex == 'Reference') {
            // Get relationship name
            String relship ;
            String fnameLcase;
            if (fname.startsWith('ADD.')) {
                //jk - winter 15 patch
                fnameLcase = fname.replace('ADD.', '').toLowerCase();
                relship = addrFieldMap.get(fnameLcase).getDescribe().getRelationshipName() ;
            }
            else {
                //jk - winter 15 patch
                fnameLcase = fname.toLowerCase();
                relship = acctFieldMap.get(fnameLcase).getDescribe().getRelationshipName() ;
            }
            // Display Name field of lookup value
            SObject so2 = so.getSObject(relship);
            if (!fname.contains('RecordTypeId') && so2 != null) {
                return (String) so2.get('Name') ;
            }
            else if (fname.contains('RecordTypeId') && so2 != null) {
                // We have the value, we need to translate it
                return recTypeXlation.get((String) so2.get('Name'));
            }
            return '' ;
        }
        if (fname.startsWith('ADD.')) {
            fname = fname.replace('ADD.', '') ;
        }
        if (typex == 'Boolean') {
            Boolean b = (Boolean) so.get(fname) ;
            return (b == true ? '[X]' : '[ ]') ;
        }
        else if (typex == 'Date') {
            Date d = (Date) so.get(fname) ;
            if (d != null) {
                return d.format() ;
            }
            else {
                return '' ;
            }
        }
        else if (typex == 'Datetime') {
            Datetime d = (Datetime) so.get(fname) ;
            if (d != null) {
                return d.format() ;
            }
            else {
                return '' ;
            }
        }
        else {
            
            return (String) so.get(fname) ;
        }
    }
    
    
    private List<SelectOption> SortOptionList(List<SelectOption> ListToSort) {
        
        // Simple quick sort : see http://improveit360.blogspot.com/2010/09/implementing-quicksort-to-sort-list-of.html
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
        
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = ListToSort.size() / 2;
        
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(SelectOption x : ListToSort)
        {
            if(x.getLabel() <= pivotValue.getLabel())
                Less.add(x);
            else if(x.getLabel() > pivotValue.getLabel()) Greater.add(x);
        }
        List<SelectOption> xList = new List<SelectOption> ();
        xList.addAll(SortOptionList(Less));
        xList.add(pivotValue);
        xList.addAll(SortOptionList(Greater));
        // Dedupe
        List<SelectOption> returnList = new List<SelectOption> ();
        Set<String> labelSet = new Set<String> () ;
        returnList.add(new SelectOption('',GAS_NONE)) ;
        labelSet.add(GAS_NONE) ;
        for(SelectOption x : xList) {
            if (!labelSet.contains(x.getLabel())) {
                returnList.add(x) ;
                labelSet.add(x.getLabel()) ;
            }
        }
        return returnList;
    }
    
    //mnaidu 7/16/2013 - GAS 2.1 enhancement
    //remove the account ids that need to be excluded
    /**
***** @author = Murugesh Naidu
***** @date = July 17, 2013
***** @param - List of Account Ids to process
***** @return - List of Account Ids after exclusion criteria applied
***** GAS 2.1 enhancements
***** Feb 17, 2014 - Added fix to return empty set (zero accounts) if mode is Retain and no accounts are to be included
**/
    private List<ID> excludeAccountsIfAny(List<ID> accountIds){
        
        if(accountIds==null || accountIds.size() == 0){
            return accountIds;
        }
        Set<ID> originalAcctIds = new Set<ID> ();
        //mnaidu - 1/9/2014 - additionally pass the "accountIds" to avoid full table scans
        Set<ID> idsToIncludeExclude = GASUtilities.getAccountIdsToExclude(UserInfo.getUserId(), accountIds);
        //mnaidu - 1/9/2014 - check to see if the filters are supposed to be retain the filter results
        // or exclude the filter results from the general unfiltered search
        Boolean retain = (GAS_Hierarchical_Setting__c.getInstance().Enable_CB_Filter_Retain_Mode__c == null)
            ? false : GAS_Hierarchical_Setting__c.getInstance().Enable_CB_Filter_Retain_Mode__c ;
        if(retain && (idsToIncludeExclude == null || idsToIncludeExclude.size() == 0)){
            //no accounts should be shown
            accountIds.clear();
            return accountIds;
        }
        if(idsToIncludeExclude!=null && idsToIncludeExclude.size() > 0){
            originalAcctIds.addAll(accountIds);
            if(retain){
                originalAcctIds.retainAll(idsToIncludeExclude);
            }
            else{
                originalAcctIds.removeAll(idsToIncludeExclude);
            }
            
            accountIds.clear();
            accountIds.addAll(originalAcctIds);
        }
        return accountIds;
    }
    
    private List<SearchResult> SortSearchResults (List<SearchResult> ListToSort, String keyField, String sortDir) {
        
        if (keyField != '') {
            // Set key field for each SearchResult
            for(SearchResult x : ListToSort) {
                for (SearchResultField y : x.srFields) {
                    // Find the keyField
                    if (y.apiname == keyField) {
                        x.key = y.rawvalue ;
                        break ;
                    }
                }
            }
        }
        
        // Ok, now we have the keys, can do a simple quick sort. See : http://improveit360.blogspot.com/2010/09/implementing-quicksort-to-sort-list-of.html
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
        
        List<SearchResult> Less = new List<SearchResult>();
        List<SearchResult> Greater = new List<SearchResult>();
        integer pivot = ListToSort.size() / 2;
        
        // save the pivot and remove it from the list
        SearchResult pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        if (sortDir == 'A') { // Ascending
            for(SearchResult x : ListToSort)
            {
                if(x.key <= pivotValue.key)
                    Less.add(x);
                else if(x.key > pivotValue.key) Greater.add(x);
            }
        }
        else { // Descending
            for(SearchResult x : ListToSort)
            {
                if(x.key <= pivotValue.key)
                    Greater.add(x);
                else if(x.key > pivotValue.key) Less.add(x);
            }
        }
        List<SearchResult> returnList = new List<SearchResult> ();
        returnList.addAll(SortSearchResults(Less, '', sortDir));
        returnList.add(pivotValue);
        returnList.addAll(SortSearchResults(Greater, '', sortDir));
        return returnList;
    }
    
    public class SearchResult {
        
        public String acctId {get;set;}
        public String acctName {get;set;}
        public String addrId {get;set;}
        public Boolean isSelected {get;set;}
        public String key {set;get;}
        public List<SearchResultField> srFields {get;set;}
        public List<SearchResult> otherAddrs {get;set;}
        public String accStatus {get;set;}
    }
    
    public class SearchResultField {
        
        public String apiname {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String rawvalue {get;set;}
        public Boolean is_Acct {get;set;}
        public Boolean is_Addr {get;set;}
    }
    
    public class SearchField  {
        
        public String obj {get;set;}
        public String label {get;set;}
        public String apiname {get;set;}
        public String value {get;set;}
        public String alvalue {get;set;}
        public String opt_value {get;set;}
        public Boolean is_picklist {get;set;}
        public Boolean is_reference {get;set;}
        public Boolean is_phone {get;set;}
        public Boolean is_bool {get;set;}
        public Boolean is_acctlookup {get;set;}
        public Boolean has_es {get;set;}
        public Boolean has_cs {get;set;}
        public Boolean no_quote {get;set;}
        public Boolean no_opt {get;set;}
        public Boolean no_picklist {get;set;}
        public List<SelectOption> plist {set;get;}
        
        public Boolean isCountry {set;get;} //R17 used in vf page for seperate it's formation //
        public Boolean isState {set;get;} //R17 used in vf page for seperate it's formation //
        public String tempSelectedCountry = AGN_searchAccts.selectedCountry;  //R17//   
        public map<String,Set<String>> countryState;
        public GAS_Hierarchical_Setting__c gas;        
        Public String orgValue;
        Public List<GAS_Country_State_Mapping_AGN__mdt> allStates;
        
        public SearchField (String o, Schema.DescribeFieldResult dfr,String parentsearch) {
            obj = o ;
            label = dfr.getLabel() ;
            apiname = dfr.getName () ;
            value = '' ;
            opt_value = '' ;
            is_acctlookup = false ;
            is_reference = (dfr.getType().name() == 'Reference') ;
            is_picklist = (dfr.getType().name() == 'Picklist') ;
            is_phone = (dfr.getType().name() == 'Phone') ;
            is_bool = (dfr.getType().name() == 'Boolean') ;
            no_quote = (dfr.getType().name() == 'Boolean' ||
                        dfr.getType().name() == 'Currency' ||
                        dfr.getType().name() == 'Date' ||
                        dfr.getType().name() == 'Datetime' ||
                        dfr.getType().name() == 'Double' ||
                        dfr.getType().name() == 'Integer' ||
                        dfr.getType().name() == 'Percent' ||
                        dfr.getType().name() == 'Time') ;
            
            System.debug('selectedCountry in searchfield: '+tempSelectedCountry);    
            
            countryState = new Map<String,Set<String>>();                                
            gas = GAS_Hierarchical_Setting__c.getInstance();
            orgValue = gas.Region_AGN__c;          
            allStates = [select Country_AGN__c, State_AGN__c from GAS_Country_State_Mapping_AGN__mdt where Org_AGN__c =: orgValue];
            
            //To fetch all Country-Sate values from Gas country state metadata.
            for (GAS_Country_State_Mapping_AGN__mdt tempAdd : allStates) {
                
                if(countryState.isEmpty())
                {
                    
                    Set<String> tempState = new Set<String>();
                    tempState.add(tempAdd.State_AGN__c);
                    countryState.put((String)tempAdd.Country_AGN__c,tempState);
                }           
                else
                {
                    if(countryState.containsKey(tempAdd.Country_AGN__c))
                    {
                        Set<String> tempState1 = countryState.get(tempAdd.Country_AGN__c);
                        tempState1.add(tempAdd.State_AGN__c);
                        countryState.put((String)tempAdd.Country_AGN__c,tempState1);
                    }
                    else
                    {
                        Set<String> tempState = new Set<String>();
                        tempState.add(tempAdd.State_AGN__c);
                        countryState.put((String)tempAdd.Country_AGN__c,tempState);
                    }
                } 
                
            }  
            
            System.debug('countryState :'+countryState);
            
            List<String> keys = new List<String>(countryState.keySet());            
            Set<String> states = new Set<String>();
            
            if (is_picklist) {
                
                plist = new List<SelectOption> () ;
                List<Schema.PicklistEntry> P = dfr.getPicklistValues();
                // plist.add(new SelectOption('',AGN_searchAccts.GAS_NONE)) ;
                
                // R17 Setting Country-State dependency
                plist.add(new SelectOption('','-None-')) ;    
                System.debug('apiname: '+apiname);  
                if(apiname == 'State_vod__c')
                {
                    for(String cs:keys)
                    {
                        System.debug('CS: '+cs);
                        if(cs == tempSelectedCountry)
                        {   
                            
                            states = countryState.get(cs);
                            System.debug('inside country state checking: '+states);
                            break;                              
                        }
                    }
                    for(String str: states)
                    {
                        plist.add(new SelectOption(str,str));      
                        
                    }                     
                }  
                
                else
                {                      
                    for (Schema.PicklistEntry pe : P) 
                    {
                        plist.add(new SelectOption(pe.getValue(),pe.getLabel()));     
                    }
                    
                } 
            }
            
            if(apiname=='State_vod__c'){
                
                isState =true;
                
            }
            //R17 end
            
            if(apiname=='Status_AGN__c'){
                // value='Active';
                
            }
            
            if(apiname=='IsPersonAccount'){
                
                plist = new List<SelectOption> () ;
                List<Schema.PicklistEntry> P = dfr.getPicklistValues();
                
                if(parentsearch !='1'){
                    plist.add(new SelectOption('true',System.Label.One_Key_Person_Account));
                }
                plist.add(new SelectOption('false',System.Label.One_Key_Business_Account));
                
                
                
                is_picklist=true;
                label= System.Label.One_Key_Search_Type;
            }
            
            
            
            if (is_reference) {
                // Make it a picklist of names
                is_picklist = true ;
                // Remove trailing ' ID' from label
                label = label.replaceFirst(' ID$', '') ;
                List <Schema.sObjectType> sobjs = dfr.getReferenceTo() ;
                String objName = sobjs[0].getDescribe().getName() ;
                
                
                if (objName == 'RecordType') {
                    // Already calculated
                    plist = obj == 'Account' ? AGN_searchAccts.acctRecTypesPlist.clone()  : AGN_searchAccts.addrRecTypesPlist.clone() ;
                }
                
                
                
                else if (objName != 'Account') {
                    // All other references
                    plist = new List<SelectOption> () ;
                    plist.add(new SelectOption('',AGN_searchAccts.GAS_NONE)) ;
                    String query;
                    if(objName=='Country_vod__c'){
                        isCountry = true;//R17//
                        query = 'select Id,Name,toLabel(Country_Name_vod__c) from ' + objName + ' order by Country_Name_vod__c' ;
                    }else{
                        query = 'select Id,Name from ' + objName + ' order by Name' ;
                    }
                    for (sObject ox : Database.query(query)) {
                        if(objName=='Country_vod__c'){
                            if(ox.get('Country_Name_vod__c')!=null){
                                plist.add(new SelectOption((String)ox.get('Id'), (String)ox.get('Country_Name_vod__c'))) ;
                            }
                        }else{
                            plist.add(new SelectOption((String)ox.get('Id'), (String)ox.get('Name'))) ;
                        }
                    }
                }
                else {
                    // objName is Account.  We don't want to display thousands or more Account names in a picklist,
                    // so we handle this by creating a link to aonther search page.
                    is_acctlookup = true ;
                }
                
            }
            // Release 14 #middleName check to display Exact Match & Starts With
            has_es = (obj == 'Account' && (apiname == 'Name' || apiname == 'FirstName' || apiname == 'Middle_vod__c' || apiname == 'LastName' || apiname == 'Distribution_ID_AGN__c' || apiname == 'External_ID2_AGN__c' || apiname == 'Name_with_SAP_Id_AGN__c')) ;
            //has_cs = (obj == 'Address_vod__c' && apiname == 'Name') ;
            has_cs = (obj == 'Address_vod__c' && (apiname == 'Name' || apiname == 'City_vod__c' || apiname == 'Zip_vod__c' || apiname == 'Brick_vod__c' || apiname == 'Phone_vod__c')) ;
            if (has_es) {
                opt_value = 'Exact Match' ;
            }
            if (has_cs) {
                opt_value = 'Starts With' ;
            }
            no_opt = !has_cs && !has_es && !is_acctlookup;
            no_picklist = !is_picklist ; 
            
        }
        
    }
    
    public class ResultHeader {
        
        public String label {set;get;}
        public String apiname {set;get;}
        
    }
    
    public class Paginate {
        public Integer index {get;set;}
        public Integer pageNum {get;set;}
        public Integer totalPage {get;set;}
        public Integer totalResults {get;set;}
        public List<Pager> pageList {get;set;}
        public Boolean showPrevious {get;set;}
        public Boolean showNext {get;set;}
        public Boolean isAll {get;set;}
        public Paginate(Integer listSize, Integer pageSize){
            this.totalResults = listSize;
            pageSize = (pageSize > 0)?pageSize:10;
            this.totalPage = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
            this.pageNum = 1;
            this.index = 0;
            this.isAll = (listSize == pageSize)?true:false;
            updateNumbers();
        }
        public void updateNumbers(){
            this.pageList = new List<Pager>();
            for(Integer i = 1; i < (this.totalPage + 1); i++){
                Boolean b = (i == pageNum)?true:false;
                this.pageList.add(new Pager(i, b));
            }
            this.showPrevious = (this.pageNum == 1)?false:true;
            this.showNext = (this.pageNum == this.totalPage)?false:true;
            this.index = this.pageNum - 1;
        }
        public void decrement(){
            this.pageNum = this.pageNum - 1;
            updateNumbers();
        }
        public void increment(){
            this.pageNum++;
            updateNumbers();
        }
        
    }
    public class Pager{
        public Integer pageNum {get;set;}
        public Boolean isActive {get;set;}
        public Pager(Integer num, Boolean active){
            this.pageNum = num;
            this.isActive = active;
        }
    }
    
    /**
***** @author- Akash
***** @date- 9/April/2019
***** @param- Account Id, userterrString,gas veeva message is passed to display in email
***** @return- Success/failure Message
***** @Release- 19R2 PMO2204
***** @Description- Method for sending email to manager for specific countries when user adding account to territory
**/    
    public static void addToTerritory_EmailTo_Manager(String newAcctId,String userterrString,String GAS_EMAIL_SUCCESS){
        List<User> userList = [SELECT Country_Code__c,Email,Id,ManagerId,Manager.Name,Manager.Email,MA_User_Country_Code_AGN__c,
                               Name,Profile.Name FROM User 
                               WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String UserCountryCode = userList[0].Country_Code__c;
        String MAUserCountryCode = userList[0].MA_User_Country_Code_AGN__c;
        String UserProfile = userList[0].Profile.Name;
        String ManagerName = userList[0].Manager.Name;
        String UserName = userList[0].Name;
        List<Account> AccList = [Select Name,External_ID2_AGN__c from Account Where Id =: newAcctId LIMIT 1];
        String AccName = AccList[0].Name;
        String SAP_Id = AccList[0].External_ID2_AGN__c;
        String ProfileList = 'SMB Management Sales - Platform,SMB Primary Care Sales - Platform,AGN Management Sales - Salesforce,AGN Sales Representative - Salesforce,AGN Business Consultant,AGN Market Access User Profile,AGN Trainer User';
        String EmailBody = '<html><head><style>table, th, td {border: 1px solid black;}</style></head><body><p>'+
            Label.AGN_GAS_Hi +' ' +ManagerName+', </p><p>'+
            Label.AGN_GAS_User +' ' +UserName +' ' + Label.AGN_GAS_ATT_EmailBody +
            '</p><br/><table style="width:100%"><tr><th>'+ Label.AGN_GAS_UserName +
            '</th><th>'+ Label.AGN_GAS_Territory +'</th><th>'+ Label.AGN_GAS_AccountName +
            '</th><th>'+ Label.AGN_GAS_SAPId +'</th><th>'+ Label.AGN_GAS_Date +'</th></tr><tr><td>'+UserName+'</td><td>'
            +userterrString+'</td><td>'+AccName+'</td><td>'+SAP_Id+'</td><td>'+System.today().format()+
            +'</td></tr></table>'
            +'<br/><p>'+ Label.AGN_GAS_ThankYou +'</p></body></html>';
        List<String> sendingTo = new List<String>();
        sendingTo.add(userList[0].Manager.Email);
        if(UserCountryCode == null)
            UserCountryCode = 'Blank';
        if(MAUserCountryCode == null)
            MAUserCountryCode = 'Blank';
        System.debug('~~UserCountryCode -> '+UserCountryCode);
        System.debug('~~MAUserCountryCode -> '+MAUserCountryCode);
        System.debug('ATT_Manger_Notification_Country_Code_AGN__c  -> '+GAS_Hierarchical_Setting__c.getOrgDefaults().ATT_Manger_Notification_Country_Code_AGN__c);
        if((GAS_Hierarchical_Setting__c.getOrgDefaults().ATT_Manger_Notification_Country_Code_AGN__c.contains(UserCountryCode)
            || GAS_Hierarchical_Setting__c.getOrgDefaults().ATT_Manger_Notification_Country_Code_AGN__c.contains(MAUserCountryCode) )           
           && ProfileList.contains(UserProfile)) 
        {
            System.debug(' inside IF addToTerritory_EmailTo_Manager');
            Messaging.SingleEmailMessage sendEmailToManager = new Messaging.SingleEmailMessage();
            sendEmailToManager.setToAddresses(sendingTo);
            sendEmailToManager.setSubject(Label.AGN_GAS_Attention +' ' +UserName +' ' + Label.AGN_GAS_ATT_Subject);
            sendEmailToManager.setHtmlBody(EmailBody);
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { sendEmailToManager });
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,GAS_EMAIL_SUCCESS));
            }catch(exception e){
                apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
            }
        }
    }
    // ~~~~~~~~~~~~ addToTerritory_EmailTo_Manager method END ~~~~~~~~~~~~
    
    
    /**
***** @author- Akash
***** @date- 9/April/2019
***** @param- Account Id, userterrString,gas veeva message is passed to display in email
***** @return- Success/failure Message
***** @Release- 19R2 PMO2204
***** @Description- Method for sending email to manager for specific countries when user removing account from territory
**/ 
    public static void removeFromTerritory_EmailTo_Manager(String newAcctId,String userterrString,String GAS_EMAIL_SUCCESS){
        List<User> userList = [SELECT Country_Code__c,Email,Id,ManagerId,Manager.Name,Manager.Email,MA_User_Country_Code_AGN__c,
                               Name,Profile.Name FROM User 
                               WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String UserCountryCode = userList[0].Country_Code__c;
        String MAUserCountryCode = userList[0].MA_User_Country_Code_AGN__c;
        String UserProfile = userList[0].Profile.Name;
        String ManagerName = userList[0].Manager.Name;
        String UserName = userList[0].Name;
        List<Account> AccList = [Select Name,External_ID2_AGN__c from Account Where Id =: newAcctId LIMIT 1];
        String AccName = AccList[0].Name;
        String SAP_Id = AccList[0].External_ID2_AGN__c;
        String ProfileList = 'SMB Management Sales - Platform,SMB Primary Care Sales - Platform,AGN Management Sales - Salesforce,AGN Sales Representative - Salesforce,AGN Business Consultant,AGN Market Access User Profile,AGN Trainer User';
        String EmailBody = '<html><head><style>table, th, td {border: 1px solid black;}</style></head><body><p>'+
            Label.AGN_GAS_Hi +' ' +ManagerName+', </p><p>'+
            Label.AGN_GAS_User +' ' +UserName +' ' + Label.AGN_GAS_RFT_EmailBody +
            '</p><br/><table style="width:100%"><tr><th>'+ Label.AGN_GAS_UserName +
            '</th><th>'+ Label.AGN_GAS_Territory +'</th><th>'+ Label.AGN_GAS_AccountName +
            '</th><th>'+ Label.AGN_GAS_SAPId +'</th><th>'+ Label.AGN_GAS_Date +'</th></tr><tr><td>'+UserName+'</td><td>'
            +userterrString+'</td><td>'+AccName+'</td><td>'+SAP_Id+'</td><td>'+System.today().format()+
            +'</td></tr></table>'
            +'<br/><p>'+ Label.AGN_GAS_ThankYou +'</p></body></html>';
        List<String> sendingTo = new List<String>();
        sendingTo.add(userList[0].Manager.Email);
        if(UserCountryCode == null)
            UserCountryCode = 'Blank';
        if(MAUserCountryCode == null)
            MAUserCountryCode = 'Blank';
        System.debug('~~UserCountryCode -> '+UserCountryCode);
        System.debug('~~MAUserCountryCode -> '+MAUserCountryCode);
        System.debug('ATT_Manger_Notification_Country_Code_AGN__c  -> '+GAS_Hierarchical_Setting__c.getOrgDefaults().ATT_Manger_Notification_Country_Code_AGN__c);
        if((GAS_Hierarchical_Setting__c.getOrgDefaults().ATT_Manger_Notification_Country_Code_AGN__c.contains(UserCountryCode)
            || GAS_Hierarchical_Setting__c.getOrgDefaults().ATT_Manger_Notification_Country_Code_AGN__c.contains(MAUserCountryCode) )           
           && ProfileList.contains(UserProfile)) 
        {
            System.debug(' inside IF removeFromTerritory_EmailTo_Manager');
            Messaging.SingleEmailMessage sendEmailToManager = new Messaging.SingleEmailMessage();
            sendEmailToManager.setToAddresses(sendingTo);
            sendEmailToManager.setSubject(Label.AGN_GAS_Attention +' ' +UserName+' ' + Label.AGN_GAS_RFT_Subject);
            sendEmailToManager.setHtmlBody(EmailBody);
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { sendEmailToManager });
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,GAS_EMAIL_SUCCESS));
            }catch(exception e){
                apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
            }
            
        }
    }
    // ~~~~~~~~~~~~ removeFromTerritory_EmailTo_Manager method END ~~~~~~~~~~~~
    // ~~~~~~~~~~~~ 19R2 PMO2204 END ~~~~~~~~~~~~
    
}