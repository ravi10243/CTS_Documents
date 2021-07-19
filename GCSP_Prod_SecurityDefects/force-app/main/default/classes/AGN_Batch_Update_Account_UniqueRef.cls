/*
* This class queries the person accounts and updates the accounts with generated unique reference code.
*/
public class AGN_Batch_Update_Account_UniqueRef implements Database.Batchable<sObject>{
	private final String query;

    public AGN_Batch_Update_Account_UniqueRef(String q){
      query=q;
      //query = [Select Id, Consent_UniqueRef_AGN__c from Account where PersonEmail = null and Email_Internal_AGN__c = null and Status_AGN__c = 'Active'];  
   	}

   	public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope){
        //System.debug('scope: '+scope);
        List<Account> updateAccounts = new List<Account>();
        for(Account acc : (List<Account>)scope){
            acc.Consent_UniqueRef_AGN__c = createGUID();
            updateAccounts.add(acc);
        }
        //System.debug('update accounts: '+updateAccounts);
		update updateAccounts;
    }

   	public void finish(Database.BatchableContext BC){
   	}
    
    private String createGUID(){
        Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,10);
		system.debug('&&&&& '+guid); 
        
        return guid;
    }
}