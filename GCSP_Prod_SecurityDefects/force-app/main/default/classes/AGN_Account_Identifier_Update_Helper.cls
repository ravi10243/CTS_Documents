/**
***** @author- Akash
***** @date- 26/June/2019
***** @Release- 19R2 PMO2205
***** @Description- Apex  class created which act as a helper class for the Batch Apex. It contains the logic about what will be the data get updated in
                    Account Identifier field.
**/
public class AGN_Account_Identifier_Update_Helper {
    
    public static void getAccount(List<Account> accList){
        AGN_DCR_Account_Identifier_Values__c accIdentifierSettings = AGN_DCR_Account_Identifier_Values__c.getOrgDefaults();
        system.debug('~~~~ Inside AGN_Account_Identifier_Update_Helper.getAccount method');
        List<account> updateAccList = new List<account>();
        for(Account acc : accList){
            String result = '';
            if(accIdentifierSettings.DCR_Account_Identifier_Country_Code_AGN__c.contains(acc.country_vod__r.name)){
                result=result+acc.country_vod__r.name+'_';
            }
            if(accIdentifierSettings.DCR_Account_Identifier_IQVIA_ID_AGN__c.contains(acc.country_vod__r.name)
               && String.isNotBlank(acc.External_ID_vod__c)){
                   result=result+acc.External_ID_vod__c+'_';
               }
            if(accIdentifierSettings.DCR_Account_Identifier_SAP_ID_AGN__c.contains(acc.country_vod__r.name)
               && String.isNotBlank(acc.External_ID2_AGN__c)){
                   result=result+acc.External_ID2_AGN__c+'_';
               }
            if(accIdentifierSettings.DCR_Account_Identifier_Status_AGN__c.contains(acc.country_vod__r.name)
               && String.isNotBlank(acc.Status_AGN__c)){
                   if(acc.Status_AGN__c == 'Active')
                       result=result+'A_';       
                   else if(acc.Status_AGN__c == 'Inactive')
                       result=result+'IN_';       
                   else if(acc.Status_AGN__c == 'Pending Validation')
                       result=result+'PV_';       
               }
            if(accIdentifierSettings.DCR_Account_Identifier_Address_Line_AGN__c.contains(acc.country_vod__r.name)
               && String.isNotBlank(acc.Address_Line_1_AGN__c)){
                   result=result+acc.Address_Line_1_AGN__c+'_';
               }
            if(accIdentifierSettings.DCR_Account_Identifier_City_AGN__c.contains(acc.country_vod__r.name)
               && String.isNotBlank(acc.BillingCity)){
                   result=result+acc.BillingCity+'_';   
               }
            if(accIdentifierSettings.DCR_Account_Identifier_Postal_Code_AGN__c.contains(acc.country_vod__r.name)
               && String.isNotBlank(acc.BillingPostalCode)){
                   result=result+acc.BillingPostalCode+'_';  
               }
            result = result.substring(0, result.length()-1);
            if(!result.equals(acc.Account_Identifier_vod__c)){
                Account updateAccount = new Account();
                updateAccount.Id = acc.id;
                
                if(Schema.sObjectType.Account.fields.Account_Identifier_vod__c.isUpdateable()){// swar cc
                    updateAccount.Account_Identifier_vod__c = result;
                }
                updateAccList.add(updateAccount);
            }
        }
        try{
            if(updateAccList.size()>0){
                if(Account.sObjectType.getDescribe().isUpdateable()){// swar cc
                    update updateAccList;
                }
                system.debug('~~~~ Account updated succesfully-> '+updateAccList.size());
            }
        }
        catch(Exception e){
            system.debug('~~~~ Error message '+ e.getMessage()+'~~~~ Error line number '+ e.getLineNumber());
        }
    }
}