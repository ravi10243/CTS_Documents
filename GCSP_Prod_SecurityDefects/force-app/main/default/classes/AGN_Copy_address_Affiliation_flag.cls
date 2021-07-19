global class AGN_Copy_address_Affiliation_flag implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
     
        
       // String query = 'SELECT Act_No_Mail_AGN__c,Act_Preferred_Mail_Flag_AGN__c,Act_Pref_Visit_Flag_AGN__c,Alternate_Name_vod__c,Bill_To_AGN__c,Brick_Number_Xponent_1_AGN__c,Brick_Number_Xponent_2_AGN__c,Child_Account_Data_Provider_ID_AGN__c,Child_Account_Identifier_vod__c,Child_Account_ID_AGN__c,Child_Account_Search_LastFirst_vod__c,Child_Account_Status_AGN__c,Child_Account_Type_AGN__c,Child_Account_vod__c,Child_Account_vod__r.IsPersonAccount,Child_Affiliation_Count_vod__c,Child_Furigana_vod__c,Child_Name_vod__c,Child_Record_Type_vod__c,Child_Record_Type__c,Copy_Address_vod__c,Country_Code__c,CreatedById,CreatedDate,CurrencyIsoCode,Customer_Managed_AGN__c,Customer_Master_Status_vod__c,Display_on_Clinic_Locator_AGN__c,External_ID_AGN__c,External_ID_vod__c,External_Key_vod__c,Formatted_Name_Furigana_vod__c,Hierarchy_Type_vod__c,Id,IsDeleted,IsLocked,LastModifiedById,LastModifiedDate,Location_Identifier_vod__c,MayEdit,MDM_ID_AGN__c,Mobile_ID_vod__c,Name,Name_with_SAP_Id_AGN__c,Network_Primary_vod__c,OK_ExternalID__c,OK_Role__c,OwnerId,Parent_Account_Data_Provider_ID_AGN__c,Parent_Account_Identifier_vod__c,Parent_Account_Name_With_SAP_Info_AGN__c,Parent_Account_Status_AGN__c,Parent_Account_Type_AGN__c,Parent_Account_vod__c,Parent_Account_vod__r.IsPersonAccount,Parent_Affiliation_Count_vod__c,Parent_Child_Furigana_vod__c,Parent_Child_Name_vod__c,Parent_Furigana_vod__c,Parent_Name_vod__c,Parent_Record_Type_vod__c,Primary_vod__c,Privacy_Law_Status_AGN__c,Ship_To_AGN__c,Sold_To_AGN__c,SystemModstamp,Veeva_NWK_ID_vod__c,Work_Status_AGN__c,zvod_ChildAccount_TSF_vod__c FROM Child_Account_vod__c';
        
        String query = 'SELECT Id, Copy_Address_vod__c, Child_Account_vod__c, Parent_Account_vod__c, Country_Code__c, Child_Account_vod__r.Country_vod__r.Name FROM Child_Account_vod__c where Copy_Address_vod__c = true AND Child_Account_vod__r.IsPersonAccount =false AND Parent_Account_vod__r.IsPersonAccount=false AND Child_Account_vod__r.Country_vod__r.Name != null';
        
        return Database.getQueryLocator(query);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Child_Account_vod__c> childaccList) {
       
       
        System.debug('--------------Inside execute-----------------');
        System.debug('[childaccList]:' + childaccList);

        List<Child_Account_vod__c> cUpdate = new List<Child_Account_vod__c>();
        for(Child_Account_vod__c childacc : childaccList)
        {        
            // Update the Child_Account_vod__c 
            System.debug('[childacc]:' + childacc);
     
            
            String country = childacc.Child_Account_vod__r.Country_vod__r.Name;
            System.debug('[childacc--Country]:' + childacc.Child_Account_vod__r.Country_vod__r.Name);
            System.debug('[Copy_Address_Country_Code_AGN__c]:' + Allergan_Settings_AGN__c.getOrgDefaults().Copy_Address_Country_Code_AGN__c);
    
            
            if( Allergan_Settings_AGN__c.getOrgDefaults().Copy_Address_Country_Code_AGN__c == null || !Allergan_Settings_AGN__c.getOrgDefaults().Copy_Address_Country_Code_AGN__c.contains(country)){
                
                // if(childacc.Copy_Address_vod__c == true && childacc.Parent_Account_vod__r.IsPersonAccount == false && childacc.Child_Account_vod__r.IsPersonAccount == false){
                    // System.debug('ID::::'+childacc.Id+'--'+'PAR ID:'+childacc.Parent_Account_vod__c+'--'+childacc.Parent_Account_vod__r.IsPersonAccount+'--CHILD ID:'+childacc.Child_Account_vod__c+'--'+childacc.Child_Account_vod__r.IsPersonAccount);
                    
                    //AG CC(38)
                    if(Schema.sObjectType.Child_Account_vod__c.fields.Copy_Address_vod__c.isUpdateable()){   
                    childacc.Copy_Address_vod__c = false;
                    }
                    cUpdate.add(childacc);
                // }
            }
        }
       
        if(cUpdate.size()>0){
            try {
                    //AG CC 
                    if(Child_Account_vod__c.sObjectType.getDescribe().isUpdateable()){
                        update cUpdate;
                        }
            
            } catch(Exception e) {
                System.debug(e);
            }
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
  }
}