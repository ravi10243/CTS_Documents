/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* This class is used in Account Updated process builder.
*/

public class AGNGigyaAccountUpdate {

  @InvocableMethod(label='Update Accounts on Gigya' description='This method updates the account on Gigya')
  public static void updateAccounts(List<Id> accountIds) {
    if(AGNGigyaRESTHelper.environmentEnabled() == false) return;

    Database.executebatch(new AGNGigyaAccountUpdateBatch(accountIds), 10);
    //AGNGigyaAccountUpdate.send(accountIds);
  }

  // @future(Callout=true)
  // public static void send(List<Id> accountIds) {
  //   List<Account> accounts = [
  //   SELECT Id, FirstName, LastName, PersonEmail, External_ID_vod__c
  //   FROM Account
  //   WHERE Id IN :accountIds
  //   ];
  //
  //   for (Account account : accounts) {
  //     List<Object> gigyaObjects = AGNGigyaRESTAccount.getUsersByAccountId(account.Id);
  //     for (Object gigyaObject : gigyaObjects) {
  //       Map<String, Object> gigyaRecord = (Map<String, Object>) gigyaObject;
  //       AGNGigyaAccount gigyaAccount = new AGNGigyaAccount();
  //       gigyaAccount.setId(account.Id);
  //       gigyaAccount.setFirstName(account.FirstName);
  //       gigyaAccount.setLastName(account.LastName);
  //       gigyaAccount.setExternalId(account.External_ID_vod__c);
  //       gigyaAccount.setUserId(String.valueOf(gigyaRecord.get('UID')));
  //       AGNGigyaRESTAccount.setAccountInfo(gigyaAccount);
  //     }
  //   }
  // }
}