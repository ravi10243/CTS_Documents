/****************************************************************************************************************
@ Class:          AGN_Account_Hierarchy_Helper 
@ Version:        1
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        This is the helper class for Account Hierarchy for account, built as part of HCO Harmonization.
                  This class is used to makes read and dml operations for all the components involved in Account
                  Hierarchy feature.
-----------------------------------------------------------------------------------------------------------------
@ Change history: 04.01.2021 / Ayush Basak / Created the class.
****************************************************************************************************************/
public without sharing class AGN_Account_Hierarchy_Helper {
    
    final static string LABEL_PREFIX = 'Label.';
    final static string LABEL_FIELD = 'label';
    final static string QUERY_SELECT = 'SELECT Id, '; 
    final static string QUERY_FROM = ' FROM '; 
    final static string QUERY_WHERE = ' WHERE '; 
    final static string QUERY_SECURITY = ' WITH SECURITY_ENFORCED'; 
    final static string QUERY_CONDITION_1 = ' = :accountId';
    final static string QUERY_CONDITION_2 = ' in :hierarchyBelowId OR Id in :hierarchyAboveId )'; 
    final static string QUERY_BRACKET_OPEN =  '(';
    
    private static List<Id> accountHierarchy;

    /************************************************************************************************************
    @ method:           getAccountTree 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This is an aura enabled method, consumed by agnAccountHierarchy Component
                        This method returns list of Ids of all the accounts above in the hierarchy of the Account
                        whose is Id is passed in the parameter
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 04.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    @AuraEnabled
    public static List<Id> getAccountTree(String recordId) {
        accountHierarchy = new List<Id>();
        try {
            // Delegate creation of list to private recursive method.
            AGN_Account_Hierarchy_Helper.getParentId(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
        return accountHierarchy;
    }

    /************************************************************************************************************
    @ method:           getParentId 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This is a private static method, invoked from exposed methods to create list of Ids of 
                        all the accounts above in the hierarchy of the Account whose is Id is passed in the 
                        parameter. Recursion exits once an account is found which does not have a primary parent
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 04.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    private static void getParentId(String recordId) {
        List<Account> accounts =  [SELECT Id, Primary_Parent_vod__c 
                                    FROM Account 
                                    WHERE Id=:recordId 
                                    AND isPersonAccount = false
                                    WITH SECURITY_ENFORCED];
        Account parentAccount = new Account();
        if(!accounts.isEmpty()) {
            parentAccount = accounts[0];
        }
        
        // Check if the Account has primary parent record. If yes, add to the list and make recursive call 
        // with the parent record id
        if(parentAccount.Primary_Parent_vod__c != null) {
            accountHierarchy.add(parentAccount.Primary_Parent_vod__c);
            getParentId(parentAccount.Primary_Parent_vod__c);
        }
    }

    /************************************************************************************************************
    @ method:           getTableConfigs 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This is a aura enabled method, which queries the metadata and gets the data table setup
                        for each of the available tables, and localizes based on user language.
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 13.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    @AuraEnabled
    public static List<Account_Hierarchy_Configuration_AGN__mdt> getTableConfigs() {
        List<Account_Hierarchy_Configuration_AGN__mdt> datatableConfig 
                                = [SELECT sObject_AGN__c, 
                                        Column_Configuration_AGN__c, 
                                        Hide_Label_AGN__c,
                                        Show_Label_AGN__c,
                                        Field_List_AGN__c, 
                                        Filter_Field_AGN__c, 
                                        JSON_Flattener_AGN__c 
                                        FROM Account_Hierarchy_Configuration_AGN__mdt 
                                        WHERE Active_AGN__c = true 
                                        WITH SECURITY_ENFORCED
                                        ORDER BY Sequence_AGN__c];
        try {
            // Calling supporting method to remove metadata for the sObject the user has no access to
            datatableConfig = AGN_Account_Hierarchy_Helper.permissionCheck(datatableConfig);
            // Calling supporting method to get localized metadata text labels
            datatableConfig = AGN_Account_Hierarchy_Helper.getLocalizations(datatableConfig);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
        return datatableConfig;
    }

    /************************************************************************************************************
    @ method:           getLocalizations 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This is a private supporting method which updates metadata strings with values from 
                        Custom Labels and thier translations 
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 13.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    private static List<Account_Hierarchy_Configuration_AGN__mdt> 
                                    getLocalizations(List<Account_Hierarchy_Configuration_AGN__mdt> configs) {
        List<Account_Hierarchy_Configuration_AGN__mdt> localizedConfigs 
                                        = new List<Account_Hierarchy_Configuration_AGN__mdt>();
        List<String> labels = new List<String>();
        String lang = UserInfo.getLanguage();

        // Looping through the metadata to check if Label reference are present in the column configuration
        for(Account_Hierarchy_Configuration_AGN__mdt ahc : configs){
            // Checking in Column Configuration field
            String buttonConfig = ahc.Column_Configuration_AGN__c;
            List<Object> columnConfig = (List<Object>)JSON.deserializeUntyped(buttonConfig);
            for(Object column : columnConfig) {
                Map<String, Object> columnMap = (Map<String, Object>)column;
                String label = String.valueOf(columnMap.get(LABEL_FIELD));
                if(label.startsWith(LABEL_PREFIX)) {
                    labels.add(label.substring(6));
                }
            }
            // Checking in Show Label field
            if(ahc.Show_Label_AGN__c.startsWith(LABEL_PREFIX)) {
                labels.add(ahc.Show_Label_AGN__c.substring(6));
            }
            // Checking in Hide Label field
            if(ahc.Hide_Label_AGN__c.startsWith(LABEL_PREFIX)) {
                labels.add(ahc.Hide_Label_AGN__c.substring(6));
            }
        }

        // Getting the Custom Label values and thier translations based on user language
        // And storing them in map with api name of the label as key and label value/translated value as value
        Map<String, String> localizationMap = new Map<String, String>();
        List<ExternalStringLocalization> localizations = [SELECT Value, ExternalString.Name  
                                                            FROM ExternalStringLocalization 
                                                            WHERE ExternalString.Name IN :labels 
                                                            AND Language = :lang];
        List<ExternalString> defaultLabels = [SELECT Value, Name  
                                                            FROM ExternalString 
                                                            WHERE Name IN :labels ];
        for(ExternalStringLocalization esl : localizations) {
            localizationMap.put(esl.ExternalString.Name, esl.Value);
        }
        
        for(ExternalString es : defaultLabels) {
            if(! localizationMap.containsKey(es.Name)){
                localizationMap.put(es.Name, es.Value);
            }   
        }

        // Looping through the metadata to update the Label reference with the values available in localizationMap
        for(Account_Hierarchy_Configuration_AGN__mdt ahc : configs){
            String buttonConfig = ahc.Column_Configuration_AGN__c;
            List<Object> columnConfig = (List<Object>)JSON.deserializeUntyped(buttonConfig);
            List<Object> updateColumnConfig = new List<Object>();
            for(Object column : columnConfig) {
                Map<String, Object> columnMap = (Map<String, Object>)column;
                String label = String.valueOf(columnMap.get(LABEL_FIELD));
                if(label.startsWith(LABEL_PREFIX)) {
                    String labelName = label.substring(6);
                    label = localizationMap.get(labelName);
                }
                columnMap.put(LABEL_FIELD,label);
                column = (Object)columnMap;
                updateColumnConfig.add(column);
            }
            buttonConfig = JSON.serialize(updateColumnConfig);
            ahc.Column_Configuration_AGN__c = buttonConfig;
            ahc.Show_Label_AGN__c = localizationMap.get(ahc.Show_Label_AGN__c.substring(6));
            ahc.Hide_Label_AGN__c = localizationMap.get(ahc.Hide_Label_AGN__c.substring(6));
            localizedConfigs.add(ahc);
        }
        return localizedConfigs;
    }

    /************************************************************************************************************
    @ method:           permissionCheck 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This is a private supporting method which removes metadata records based on the access 
                        to the custom object access 
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 13.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    private static List<Account_Hierarchy_Configuration_AGN__mdt> 
                        permissionCheck(List<Account_Hierarchy_Configuration_AGN__mdt> configs) {
        List<Account_Hierarchy_Configuration_AGN__mdt> permissionCheckedConfigs 
                        = new List<Account_Hierarchy_Configuration_AGN__mdt>();
        Map<String, Boolean> sObjectPermissions = new Map<String, Boolean>();
        // Getting list of available sObject for display
        for(Account_Hierarchy_Configuration_AGN__mdt ahc : configs) {
            sObjectPermissions.put(ahc.sObject_AGN__c, false);
        }

        // Checking permissions for the list of sObject
        for(String objName : sObjectPermissions.keySet()) {
            Boolean permission = Schema.getGlobalDescribe().get(objName).getDescribe().isAccessible();
            sObjectPermissions.put(objName, permission);
        }

        // Based on access for the sObject, considering only those which are accessible
        for(Account_Hierarchy_Configuration_AGN__mdt ahc : configs) {
            if(sObjectPermissions.containsKey(ahc.sObject_AGN__c) 
                    && sObjectPermissions.get(ahc.sObject_AGN__c)) {
                permissionCheckedConfigs.add(ahc);
            }
        }
        return permissionCheckedConfigs;
    }

    /************************************************************************************************************
    @ method:           getDataList 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This is an aura enabled generic method created to support quering and returning data 
                        from any child object of account, with any fields filtering based on the relationship 
                        field with account
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 06.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    @AuraEnabled
    public static List<sObject> getDataList(String accountId, String sObjectType){
        List<sObject> records;
        String query; 
        try {
            List<Account_Hierarchy_Configuration_AGN__mdt> configurations 
                            = [SELECT Field_List_AGN__c, sObject_AGN__c, Filter_Field_AGN__c, 
                                    Hierarchical_Field_AGN__c
                                    FROM Account_Hierarchy_Configuration_AGN__mdt 
                                    WHERE sObject_AGN__c = :sObjectType
                                    WITH SECURITY_ENFORCED 
                                    LIMIT 1];
            if(! configurations.isEmpty()) { 
                String fieldList = '';
                for(String field : configurations[0].Field_List_AGN__c.split(',')) {
                    system.debug(field);
                    if(field.trim().contains('.')) {
                        fieldList = fieldList + field.trim() + ',';
                    }
                    else if(Schema.getGlobalDescribe().get(configurations[0].sObject_AGN__c)
                            .getDescribe().fields.getMap().get(field.trim()).getDescribe().isAccessible()) {
                        fieldList = fieldList + field.trim() + ',';
                    }
                }
                fieldList = fieldList.substring(0,fieldList.length()-1);
                // Dynamic query based on the field list and filter field available in metadata
                query = QUERY_SELECT + fieldList 
                        + QUERY_FROM + configurations[0].sObject_AGN__c 
                        + QUERY_WHERE + configurations[0].Filter_Field_AGN__c + QUERY_CONDITION_1
                        + QUERY_SECURITY;
                System.debug(query);
                records = Database.query(String.escapeSingleQuotes(query));

                // If the metadata setup is set to return hierarchial data, the same query is re rerun 
                // to get parent and child record of current result set
                if(configurations[0].Hierarchical_Field_AGN__c != null) {
                    List<Id> hierarchyAboveId = new List<Id>();
                    List<Id> hierarchyBelowId = new List<Id>();
                    for(sObject s : records) {
                        hierarchyBelowId.add(s.Id);
                        if(s.get(configurations[0].Hierarchical_Field_AGN__c) != null) {
                            hierarchyAboveId.add(String.valueOf(
                                                    s.get(configurations[0].Hierarchical_Field_AGN__c)));
                        }
                    }
                    String hierarchyQuery = QUERY_SELECT + fieldList 
                                                + QUERY_FROM + configurations[0].sObject_AGN__c 
                                                + QUERY_WHERE + QUERY_BRACKET_OPEN 
                                                + configurations[0].Hierarchical_Field_AGN__c 
                                                + QUERY_CONDITION_2
                                                + QUERY_SECURITY;

                    List<sObject> hierarchyRecords = Database.query(String.escapeSingleQuotes(hierarchyQuery));
                    records.addAll(hierarchyRecords);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return records;
    }

    /************************************************************************************************************
    @ method:           getNodeDetail 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This is an aura enabled method, consumed by accountHierarchyNode Component. This method 
                        returns a wrapper class display the hierarchy and build the inforation to be displayed 
                        on individual node. It works with the Id of Account passed passed from component when 
                        invoked.
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 04.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    @AuraEnabled
    public static AccountHierarchyNode getNodeDetail(String recordId, String hierarchy){
        AccountHierarchyNode node;
        try {
            node = new AccountHierarchyNode(recordId, hierarchy);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return node;
    }

    /************************************************************************************************************
    @ Class:            AccountHierarchyNode 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This is a public wrapper class, used by accountHierarchyNode to structure itself with 
                        the information of account and the list of Ids of its children.
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 04.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    public class AccountHierarchyNode {
        @AuraEnabled
        public Account account;
        @AuraEnabled
        public List<Id> children; 

        /********************************************************************************************************
        @ Constructor:      AccountHierarchyNode 
        @ Version:          1.0
        @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
        @ Purpose:          To create the wrapper class instance, this constructor is can be invoked with 
                            Account Id. The constructor queries the details about the account and list of 
                            its child.
        --------------------------------------------------------------------------------------------------------
        @ Change history: 04.01.2021 / Ayush Basak / Created the method
        ********************************************************************************************************/
        AccountHierarchyNode(String accountId, String hierarchy) {
            if(accountId != null) {
                this.account = [SELECT Id, Name FROM Account WHERE Id =: accountId WITH SECURITY_ENFORCED];
                List<Id> tempChildren = new List<Id>(
                                                new Map<Id, Account>(
                                                    [SELECT Id 
                                                        FROM Account 
                                                        WHERE Primary_Parent_vod__c = :accountId 
                                                        AND isPersonAccount = false
                                                        WITH SECURITY_ENFORCED]
                                                ).keySet());
                this.children = new List<Id>();

                // Setting Account in the hierarchy line in 0th element
                Id tempId;
                for(Id id : tempChildren) {
                    if(hierarchy.contains(((String)id).substring(0,15))) {
                        this.children.add(id);
                        tempId = id;
                        break;
                    }
                }

                // Adding the rest of the children in the list
                if(!tempChildren.isEmpty() && tempId != null) {
                    tempChildren.remove(tempChildren.indexOf(tempId));
                }
                this.children.addAll(tempChildren);
            }
        }        
    }
}