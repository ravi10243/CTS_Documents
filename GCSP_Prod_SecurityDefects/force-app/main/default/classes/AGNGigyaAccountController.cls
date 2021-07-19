public with sharing class AGNGigyaAccountController {

  public Id accountId {get; set;}
  public Account account {get; private set;}
  public List<AGNGigyaAccount> gigyaAccounts {get; private set;}
  public List<AGNGigyaConsent> gigyaConsents {get; private set;}
  public List<AGNGigyaNotification> gigyaNotifications {get; private set;}

  private ApexPages.StandardController stdController;

  public AGNGigyaAccountController() {
    //AK CC  
    //String idParm = ApexPages.currentPage().getParameters().get('id');
    this.accountId = String.isEmpty(ApexPages.currentPage().getParameters().get('id')) ? null : (Id)ApexPages.currentPage().getParameters().get('id');
	//AK CC
    this.getAccount();
    this.getGigyaAccounts();
    this.getSubscriptionsPreferences();
    this.getNotifications();
  }

  public PageReference loadAccount() {
    PageReference pageRef = ApexPages.currentPage();
    pageRef.getParameters().put('id', this.accountId);
    this.getAccount();
    this.getGigyaAccounts();
    this.getSubscriptionsPreferences();
    this.getNotifications();
    //pageRef.setRedirect(true);
    return pageRef;
  }

  public void gigyaToVeevaConsent() {
    //PageReference pageRef = ApexPages.currentPage();
    //pageRef.getParameters().put('id', this.accountId);
    Database.executebatch(new AGNGigyaMCConsentRetrieveBatch(), 10);
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Process started. Reload the Veeva Consent page after a while.'));
    //return pageRef;
  }

  public void veevaToGigyaNotification() {
    //PageReference pageRef = ApexPages.currentPage();
    //pageRef.getParameters().put('id', this.accountId);
    Database.executebatch(new AGN_GDPR_NOTIFICATION_INTEGRATION_GIGYA(), 10);
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Process started. Reload the Veeva Consent page after a while.'));
    //return pageRef;
  }

  public void veevaToGigyaAccountUpdate() {
    //PageReference pageRef = ApexPages.currentPage();
    //pageRef.getParameters().put('id', this.accountId);
    Database.executebatch(new AGNGigyaAccountUpdateIntegrationBatch(), 7);
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Process started. Reload the Veeva Consent page after a while.'));
    //return pageRef;
  }

  private void getAccount() {
    if(String.isEmpty(this.accountId)) return;

    Account[] accounts = [SELECT Id, Email_Internal_AGN__c, External_ID_vod__c, PersonEmail, FirstName, LastName, Name
    FROM Account
    WHERE Id = :this.accountId];
    if (accounts.size() > 0) {
      this.accountId = accounts[0].Id;
      this.account = accounts[0];
    }
  }

  private void getSubscriptionsPreferences() {
    if(String.isEmpty(this.accountId)) return;

    this.gigyaConsents = AGNGigyaConsentFactory.getConsentsByAccountId(this.accountId);
  }


  private void getGigyaAccounts() {
    if(String.isEmpty(this.accountId)) return;

    this.gigyaAccounts = AGNGigyaRESTAccount.getUsersByAccount(this.accountId);
    System.debug(this.gigyaAccounts);

  }

  private void getNotifications() {
    if(String.isEmpty(this.accountId)) return;

    this.gigyaNotifications = AGNGigyaRESTNotification.getAllNotificationsByAccountId(this.accountId);
  }

}