/*****************************************************************************************************************************************************************
Apex  Class- AGN_ContractExhibitNotificationBatch
Description- This class is used to find unique email address and language records from contract exhibit object, which have been updated after
       lastsync date and load those unique records to object AGN_GDPR_Notify_Contract_Exhibit__c. 
       This class also check, if the loaded email address(irrespective of contract language) is already present in Account then update
       AGN_GDPR_Email_Notification_Status__c as success so that no email is triggered for such records  
Developer Name- Mansi Mittal
Development Date- 3 May 2018
********************************************************************************************************************************************************************/

public with sharing class AGN_ContractExhibitUniqueEmailFinder {
    public static Set<String> CEEmailToLang= new Set<String>();
    public static Set<String> accountEmailToLang = new Set<String>();
    public static List<AGN_GDPR_Notify_Contract_Exhibit__c> uniqueCEList= new List<AGN_GDPR_Notify_Contract_Exhibit__c>();
    
    
    public static void findUniqueEmailLangRecords(){
        DateTime lastSyncDate;List<Contract_Exhibit__c> CEList;
        
        try{
        lastSyncDate=[Select createdDate from AGN_GDPR_Notify_Contract_Exhibit__c order by CreatedDate desc].createdDate;
        }
        catch(Exception ex){
           lastSyncDate=null; 
        }
        
        //Extract CE records which were inserted after last sync
        if(lastSyncDate!=null){
          CEList = [SELECT Customer_Signer_Email__c , Contract_Language__c,Customer_Signer_Fullname__c   FROM Contract_Exhibit__c where Customer_Signer_Email__c!=null and CreatedDate>=:lastSyncDate-1 and Primary_Institution__r.Country_code__c in ('AT','BE','BG','HR','CY','CZ','DK','EE','FI','FR','DE','GR','HU','IS','IE','IT','LV','LI','LT','LU','MT','NL','NO','PL','PT','RO','SK','SI','ES','SE','CH','GB')]; 
        }
        else{
          CEList = [SELECT Customer_Signer_Email__c , Contract_Language__c,Customer_Signer_Fullname__c  FROM Contract_Exhibit__c where Customer_Signer_Email__c!=null and Primary_Institution__r.Country_code__c in ('AT','BE','BG','HR','CY','CZ','DK','EE','FI','FR','DE','GR','HU','IS','IE','IT','LV','LI','LT','LU','MT','NL','NO','PL','PT','RO','SK','SI','ES','SE','CH','GB')]; 
        }
        
        //Map of data currently existing in AGN_GDPR_Notify_Contract_Exhibit__c. This helps from inserting duplicate data in the table
        Map<String,AGN_GDPR_Notify_Contract_Exhibit__c> uniqueCEHashMap=new Map<String,AGN_GDPR_Notify_Contract_Exhibit__c>();
        for(AGN_GDPR_Notify_Contract_Exhibit__c notifyCE: [Select AGN_Customer_Signer_Email__c,AGN_Contract_Language__c,AGNEmailLang__c,AGN_BC_Name__c,AGN_Email_Template_Name__c 
                                                           from AGN_GDPR_Notify_Contract_Exhibit__c] ){
            uniqueCEHashMap.put(notifyCE.AGNEmailLang__c,notifyCE);
        }
        
        //Create set of new data, inserted after last sync. Insert this data into object 'AGN_GDPR_Notify_Contract_Exhibit__c'
        for(Contract_Exhibit__c ce:CEList){
            AGN_GDPR_Notify_Contract_Exhibit__c uniqueCE=new AGN_GDPR_Notify_Contract_Exhibit__c();
            String emailLang;
            if(ce.Contract_Language__c !=null){
                emailLang=ce.Customer_Signer_Email__c +ce.Contract_Language__c ;
            }
            else{
                emailLang=ce.Customer_Signer_Email__c +'English (UK & I)';
            }
            
            if(!CEEmailToLang.contains(emailLang) && !uniqueCEHashMap.containsKey(emailLang) ){
                CEEmailToLang.add(emailLang);
                //AG CC(55-58)
                if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.fields.AGN_Customer_Signer_Email__c.isCreateable()){
                    uniqueCE.AGN_Customer_Signer_Email__c=ce.Customer_Signer_Email__c;
                    }
                if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.fields.AGN_Contract_Language__c.isCreateable()){
                    uniqueCE.AGN_Contract_Language__c=ce.Contract_Language__c;
                    }
                if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.fields.AGN_BC_Name__c.isCreateable()){
                    uniqueCE.AGN_BC_Name__c=ce.Customer_Signer_Fullname__c;
                    }
                if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.fields.AGN_Contract_Language_Code__c.isCreateable()){
                    uniqueCE.AGN_Contract_Language_Code__c=ce.Contract_Language__c.split ( ' ' )[ 0 ];
                    }
                uniqueCEList.add(uniqueCE);
              }
        }
        //AG CC
        if(AGN_GDPR_Notify_Contract_Exhibit__c.sObjectType.getDescribe().isCreateable()){
            Insert uniqueCEList;
            }
        AGN_CheckBCINAccount.updateContractExhibit();
        
    }
    
}