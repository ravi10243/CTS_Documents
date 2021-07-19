/**
* @version: 1.0
    //Purpose - Sync Selector for Offline record download
    //Author  - Cognizant: R004- Release Requirement No--261
*/

global with sharing class accountSyncSelectorCtlr_AGN {
  
  public Integer numberSelected { get {
    User u = [select UserRole.Name, Profile.Name from User where id = : UserInfo.getUserId()];
    String rl = u.userrole.Name;
    String prfl = u.Profile.Name;
    List<TSF_vod__c> tsf = new List<TSF_vod__c>();

    //R009 : 993
    if (prfl == 'SMB Management Sales - Platform'){
        tsf = [SELECT Id
                  FROM TSF_vod__c
                  WHERE Mngr_Download_To_iRep_AGN__c = true
                  AND Territory_vod__c = :rl];
    }
    Else {
        tsf = [SELECT Id
                  FROM TSF_vod__c
                  WHERE Target_Manager_SMB__c = true
                  AND Territory_vod__c = :rl];
    }
    return tsf.size();
  }}

  public string selectedKeys {get; set;}
  
  public accountSyncSelectorCtlr_AGN(){
    selectedKeys = '{}';
  }

  public PageReference save() {
    // Get current user territory
    User u = [select UserRole.Name, Profile.Name from User where id = : UserInfo.getUserId()];
    String rl = u.userrole.Name;
    String prfl = u.Profile.Name;

    // Get the changed keys
    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(selectedKeys);
    // And new items
    List<TSF_vod__c > tsf = new List<TSF_vod__c>();
    //R009 : 993
     if (prfl == 'SMB Management Sales - Platform'){
        for (Account a : [SELECT Id, External_ID_vod__c
              FROM Account
              WHERE Id in : m.keySet()]) {
              //AG CC
               if (Schema.sObjectType.TSF_vod__c.fields.Account_vod__c.isCreateable()){
                  tsf.add(new TSF_vod__c (
                    Account_vod__c = a.Id,
                    External_Id_vod__c = a.Id + '__' + rl,
                    AGN_External_ID__c = a.External_ID_vod__c + '__' + rl,
                    Mngr_Download_To_iRep_AGN__c =  Boolean.valueOf(m.get(a.Id)),
                    Name = rl,
                    Territory_vod__c = rl
                  ));
              }
          }
     }
    
    Else{
        for (Account a : [SELECT Id, External_ID_vod__c
              FROM Account
              WHERE Id in : m.keySet()]) {
              tsf.add(new TSF_vod__c (
                Account_vod__c = a.Id,
                External_Id_vod__c = a.Id + '__' + rl,
                AGN_External_ID__c = a.External_ID_vod__c + '__' + rl,
                Target_Manager_SMB__c =  Boolean.valueOf(m.get(a.Id)),
                Name = rl,
                Territory_vod__c = rl
              ));
            }
        }
    //AG CC
     if (Schema.sObjectType.TSF_vod__c.isCreateable() && Schema.sObjectType.TSF_vod__c.isUpdateable()){
        upsert tsf External_Id_vod__c;
    }

    // Clear the selected key list
    selectedKeys = '{}';

    return null;
  }
  
  @RemoteAction
  global static List<Map<String,String>> getAccounts(Id parentId, String filter) {
  SYSTEM.DEBUG('INISIDE GETACCOUNT');
    // Get current user territory
    User u = [SELECT UserRole.Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    String rl = u.userrole.Name;
    String prfl = u.Profile.Name;

    // Get my accounts currently being synced offline
    Map<Id,Boolean> syncOffline = new Map<Id,Boolean>();
    //R009 : 993
    if (prfl == 'SMB Management Sales - Platform'){
            for (TSF_vod__c a : [SELECT Account_vod__c, My_Target_vod__c
                      FROM TSF_vod__c
                      WHERE (Mngr_Download_To_iRep_AGN__c = true OR My_Target_vod__c = true)
                      AND Territory_vod__c = :rl]) {
              syncOffline.put(a.Account_vod__c, a.My_Target_vod__c);
            }}
     Else {
            for (TSF_vod__c a : [SELECT Account_vod__c, My_Target_vod__c
                      FROM TSF_vod__c
                      WHERE (Target_Manager_SMB__c = true OR My_Target_vod__c = true)
                      AND Territory_vod__c = :rl]) {
              syncOffline.put(a.Account_vod__c, a.My_Target_vod__c);
            }
         }  
    
    // Get working set of accounts
    List<Account> accountList;
    
    // Use different query for top level accounts to sub levels
    if (filter != null && filter.length() >= 3) {
      // Pulls out top 2000 HCOs matching the search
      List<List<SObject>> searchList = [FIND :filter IN ALL FIELDS RETURNING Account (Id WHERE IsPersonAccount = FALSE), Address_vod__c(Account_vod__c WHERE Account_vod__r.IsPersonAccount = FALSE)];
      
      // Combine search results for accounts & addresses
      List<Id> accountIds = new List<Id>();
      
      for (Account x : (List<Account>)searchList[0])
        accountIds.add(x.Id);
      
      for (Address_vod__c x : (List<Address_vod__c>)searchList[1])
        accountIds.add(x.Account_vod__c);
      
      // Do the SOQL
      accountList = [SELECT Id, Name, Sub_Type_AGN__c, RecordType.DeveloperName,
              (SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Country_vod__c, Zip_vod__c FROM Address_vod__r ORDER BY Primary_vod__c DESC LIMIT 1)
              FROM Account
              WHERE Id IN :accountIds
              AND Status_AGN__c = 'Active'
              ORDER BY Name
              LIMIT 1000];
    }
    else if (parentId == null) {
      accountList = [SELECT Id, Name, Sub_Type_AGN__c, RecordType.DeveloperName,
              (SELECT Name, Address_line_2_vod__c,  City_vod__c, State_vod__c, Country_vod__c, Zip_vod__c FROM Address_vod__r ORDER BY Primary_vod__c DESC LIMIT 1)
              FROM Account
              WHERE Primary_Parent_vod__r.Name= '' AND Status_AGN__c = 'Active'
              AND IsPersonAccount = FALSE
              ORDER BY Name];
    }
    else {
      accountList = [SELECT Id, Name, Sub_Type_AGN__c, RecordType.DeveloperName,
              (SELECT Name, Address_line_2_vod__c,  City_vod__c, State_vod__c, Country_vod__c, Zip_vod__c FROM Address_vod__r ORDER BY Primary_vod__c DESC LIMIT 1)
              FROM Account
              WHERE Id IN (SELECT Child_Account_vod__c
                  FROM Child_Account_vod__c
                  WHERE Parent_Account_vod__c = :parentId)
              AND Status_AGN__c = 'Active'
              ORDER BY Name];
    }
    
    List<Map<String,String>> accounts = new List<Map<String,String>>();
    
    for (Account a : accountList) {      
      String address = '';

      if (a.Address_vod__r.size() > 0)
        address = addressString(a.Address_vod__r[0]);
        
      Boolean isProfessional = a.recordtype.DeveloperName.contains('Professional');
      Boolean isOffline = syncOffline.containsKey(a.Id);
              
      accounts.add(
        new Map<String,String> {
          'title' => a.Name,
          'address' => address,
          'addClass' => isOffline ? 'sync-offline' : '',
          'key' => (String)a.Id,
          'isfolder' => isProfessional ? 'false' : 'true',
          'isLazy' => isProfessional ? 'false' : 'true',
          'icon' => isProfessional ? 'user.gif' : 'ada.gif',
          'select' => isOffline ? 'true' : 'false',
          'type' => a.Sub_Type_AGN__c,
          'istarget' => isOffline && syncOffline.get(a.Id) ? 'true' : 'false'
        }
      );
    }
    
    return accounts;
  }

  private static String addressString(Address_vod__c a){
    String temp = A.Name + ', ' + A.Address_line_2_vod__c + ', ' + ', ' + A.Country_vod__c + ', ' + A.State_vod__c  + ', ' + A.Zip_vod__c ;
    temp=temp.replace('null, ','');
    temp=temp.replace('null','');
    temp=temp.replace(', , ',', ');
    temp=temp.replace(', , ',', ');
    if(temp.lastIndexOf(', ') == temp.length ()-2){
      temp = temp.substring (0,temp.length()-2);
    }

    return temp;
  }
}