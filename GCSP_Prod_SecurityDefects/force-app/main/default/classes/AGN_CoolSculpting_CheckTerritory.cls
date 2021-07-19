/* 
 * 20 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team
 */
public class AGN_CoolSculpting_CheckTerritory {
    
    @invocableMethod
    public static void checkTerritory(List<GAS_Alignment_History_vts__c> gasHistoryList){
        
        System.debug('@@ Inside checkTerritory()'); 
        List<String> terrList = new List<String>();
        // Updated Object from Territory to Territory2 - TM2.0 Implementation
        List<Territory2> coolSculptingTerrList = new List<Territory2>();
        List<String> prospectAccList = new List<String>();
        List<String> nonProspectAccList = new List<String>();
        List<Account> updateAccList = new List<Account>();
        User GASUser = [SELECT Name, CompanyName, Email, FirstName, LastName, Phone,Is_CoolSculpting_User_AGN__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.debug('@@ Inside checkTerritory()    gasHistoryList.size: ' + gasHistoryList.size() + '     gasHistoryList: ' + gasHistoryList);
        try{
            for(GAS_Alignment_History_vts__c g : gasHistoryList){
                System.debug('@@ Inside for(). g: ' + g);
                if(g.New_Territory__c != null && g.New_Territory__c != ''){
                    if(g.New_Territory__c.contains(';')){
                        System.debug('@@ Inside for(). g contains ; ' + g.New_Territory__c);
                        terrList = g.New_Territory__c.split(';');                
                    }else{
                        System.debug('@@ Inside for(). g does not contain ; ' + g.New_Territory__c);
                        terrList.add(g.New_Territory__c);
                    }
                    //if(terrList.size()>0){
                    //System.debug('@@ Inside for(). terrList.size()>0 ; ' + terrList);
                    if ( GASUser.Is_CoolSculpting_User_AGN__c == TRUE && terrList.size()>0){
                        prospectAccList.add(g.Account__c);
                        //coolSculptingTerrList = [SELECT Name FROM Territory WHERE Coolsculpting_Territory_AGN__c = True];
                        // System.debug('@@ Inside for(). coolSculptingTerrList ; ' + coolSculptingTerrList);
                        // if(coolSculptingTerrList.size()>0){
                    }
                }
            }            
            
            for(Account acc : [select CoolSculpting_Status_AGN__c from Account where Id in :prospectAccList]){
                if(acc.CoolSculpting_Status_AGN__c == null){
                    acc.CoolSculpting_Status_AGN__c = 'CoolSculpting Prospect';
                    updateAccList.add(acc);
                }
            }
            update updateAccList;
            
        }catch(System.Exception e){
            system.debug('@@ Exception encountered: Cause:' + e.getCause() + '    Message: ' + e.getMessage() + '     Line Number: ' + e.getLineNumber() );
        }
    }    
}