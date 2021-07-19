public class AGNGigyaNotificationBatch implements Database.Batchable<AGNGigyaNotification>, Database.AllowsCallouts, Database.Stateful {

    private static AGN_GIGYA_REST_API__c gigyaSettings = AGN_GIGYA_REST_API__c.getInstance('Gigya_Credentials');
    private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
    private Integer totalCount;
    private Datetime syncStartDatetime;

    public List<AGNGigyaNotification> start(Database.BatchableContext batchableContext){
        this.syncStartDatetime = System.now();

        Datetime lastSync = gigyaSettings.AGN_Last_Notification_Sync_DateTime__c;
        String lastSyncString = lastSync == null ? '' : String.valueOf(lastSync.getTime());
        return AGNGigyaRESTNotification.getAllNotifications(lastSyncString);
    }

    public void execute(Database.BatchableContext batchableContext, List<AGNGigyaNotification> gigyaNotifications){
      totalCount += gigyaNotifications.size();
        Map<Id, Account> gigyaVeevaAccounts = new Map<Id, Account>();
        List<String> populatedFields = new List<String>();
        for(AGNGigyaNotification gigyaNotification : gigyaNotifications) {
          try {
            // If we already have the account in the map, skip it
            system.debug('gigyaNotification.getSfdcId()=' + gigyaNotification.getSfdcId());
            if(String.isEmpty(gigyaNotification.getSfdcId())) continue;
            if(gigyaVeevaAccounts.containsKey(gigyaNotification.getSfdcId())) continue;

            // Any fields set on gigyaVersionOfAccount are later used to query Veeva's version of the account
            // This is done dynamically, using the populatedFields variable, to make sure that when the accounts
            // are compared using hash codes, we are comparing the exact same fields
            Account gigyaVersionOfAccount = new Account(
                Email_Template_Name_AGN__c        = this.getEmailTemplateName(gigyaNotification),
                GDPR_Notification_Received_AGN__c = gigyaNotification.isNotificationReceived(),
                GDPR_Notification_Status_AGN__c   = gigyaNotification.getNotificationStatus(),
                Id                                = gigyaNotification.getSfdcId()
            );
            gigyaVeevaAccounts.put(gigyaVersionOfAccount.Id, gigyaVersionOfAccount);

            // If we haven't added the fields yet, then add them - this will happen with the first account
            if(populatedFields.isEmpty() && gigyaVersionOfAccount.getPopulatedFieldsAsMap().size() > 1) {
                populatedFields.addAll(gigyaVersionOfAccount.getPopulatedFieldsAsMap().keySet());
            }
          } catch(AGNGigyaValidationException e) {
            e.errorDetail = e.errorDetail + '|gigyaNotification:' + String.valueOf(gigyaNotification);
            validationExceptions.add(e);
          }
        }

        if(populatedFields.isEmpty()) return;

        List<Account> accountsToUpdate = new List<Account>();
        for(Account account : (List<Account>)Database.query(this.getAccountQuery(populatedFields, gigyaVeevaAccounts))) {
            Account gigyaVersionOfAccount = gigyaVeevaAccounts.get(account.Id);

            // If the accounts have different hash codes, then we need to update Veeva
            if(System.hashCode(gigyaVersionOfAccount) != System.hashCode(account)) {
                accountsToUpdate.add(gigyaVersionOfAccount);
            }
        }
        update accountsToUpdate;
    }

    public void finish(Database.BatchableContext batchableContext){
        //Cognizant- CC - Line Number - 64
        if(Schema.sObjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_Notification_Sync_DateTime__c.isAccessible() && Schema.SobjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_Notification_Sync_DateTime__c.isupdateable()){
            gigyaSettings.AGN_Last_Notification_Sync_DateTime__c = this.syncStartDatetime;
        }        
        update gigyaSettings;
        if(!validationExceptions.isEmpty()){
          AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
        } else {
          AGNInterfacePublishEvent.logBatchApex(batchableContext, totalCount);
        }
    }

    private String getEmailTemplateName(AGNGigyaNotification gigyaNotification) {
        // Gigya allows more characters than Veeva, so we abbreviate the string if needed
        Integer emailTemplateNameMaxLength = Schema.Account.Email_Template_Name_AGN__c.getDescribe().getLength();
        String emailTemplateName           = gigyaNotification.getEmailTemplateName();

        if(emailTemplateName.length() > emailTemplateNameMaxLength) {
            emailTemplateName = emailTemplateName.abbreviate(emailTemplateNameMaxLength);
        }

        return emailTemplateName;
    }

    private String getAccountQuery(List<String> populatedFields, Map<Id, Account> gigyaVeevaAccounts) {
        List<Id> accountIds = new List<Id>(gigyaVeevaAccounts.keySet());
        String accountIdString = '\'' + String.join(accountIds, '\',\'') + '\'';

        // We dynamically generate the query string to make sure we query for the exact same fields that are mapped from Gigya
        String accountQuery = 'SELECT ' + String.join(populatedFields, ', ') + ' FROM Account WHERE Id IN (' + accountIdString + ')' +'AND Country_vod__r.Name NOT IN (\'RU\')';
        System.debug('accountQuery=' + accountQuery);
        return accountQuery;
    }

}