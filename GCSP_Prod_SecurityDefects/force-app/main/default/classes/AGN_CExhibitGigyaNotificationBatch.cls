public class AGN_CExhibitGigyaNotificationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
    private Integer totalCount = 0;
    private Set<Id> notificationIds;

    public AGN_CExhibitGigyaNotificationBatch(Set<Id> notificationIds) {
        this.notificationIds = notificationIds;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String query = 'SELECT Id, AGN_Customer_Signer_LastName__c, AGN_Customer_Signer_FirstName__c, ' +
        'AGN_Customer_Signer_Title__c, AGN_GDPR_Email_Notification_Received__c, ' +
        'AGN_GDPR_Email_Notification_Status__c, AGN_Customer_Signer_Email__c, ' +
        'AGN_Email_Template_Name__c, LastModifiedDate ' +
        'FROM AGN_GDPR_Notify_Contract_Exhibit__c ' +
        'WHERE Id IN :notificationIds ';

        return Database.getQueryLocator(query);
    }

    private Boolean match(AGN_GDPR_Notify_Contract_Exhibit__c veevaNotification, AGNGigyaNotification gigyaNotification) {
        return veevaNotification.AGN_GDPR_Email_Notification_Received__c == gigyaNotification.isNotificationReceived()
        && veevaNotification.AGN_GDPR_Email_Notification_Status__c == gigyaNotification.getNotificationStatus();
    }

    public void execute(Database.BatchableContext batchableContext, List<AGN_GDPR_Notify_Contract_Exhibit__c> veevaNotifications) {
        totalCount += veevaNotifications.size();
        System.debug('Processing ' + veevaNotifications.size() + ' records');

        for (AGN_GDPR_Notify_Contract_Exhibit__c veevaNotification : veevaNotifications) {

            List<AGNGigyaNotification> notificationsFromGigya = AGNGigyaRESTNotification.getAllNotificationsByAccountId(veevaNotification.Id);
            Boolean toSend = true;
            if (notificationsFromGigya != null && notificationsFromGigya.size() > 0) {
                AGNGigyaNotification gigyaNotification = notificationsFromGigya[0];
                if (match(veevaNotification, gigyaNotification)) {
                    toSend = false;
                    System.debug(veevaNotification.Id + '|The record has been already updated. It will not be sent to Gigya.');
                }
            }
            if (toSend) {
                AGNGigyaNotification notificationObject = new AGNGigyaNotification();
                notificationObject.setSalutation(veevaNotification.AGN_Customer_Signer_Title__c);
                notificationObject.setFirstName(veevaNotification.AGN_Customer_Signer_FirstName__c);
                notificationObject.setLastName(veevaNotification.AGN_Customer_Signer_LastName__c);
                notificationObject.setEmail(veevaNotification.AGN_Customer_Signer_Email__c);
                notificationObject.setSfdcId(veevaNotification.Id);
                notificationObject.setEmailTemplateName(veevaNotification.AGN_Email_Template_Name__c);
                notificationObject.setNotificationReceived(veevaNotification.AGN_GDPR_Email_Notification_Received__c);
                notificationObject.setNotificationStatus(veevaNotification.AGN_GDPR_Email_Notification_Status__c);
                //Added specific to Brazil line number 53
                notificationObject.setNotificationStatusBR(veevaNotification.AGN_GDPR_Email_Notification_Status__c);
                notificationObject.setVeevaCreatedDate(veevaNotification.LastModifiedDate);

                try {
                    AGNGigyaRESTNotification.setNotification(notificationObject);
                }
                catch(AGNGigyaValidationException e) {
                    e.errorDetail = e.errorDetail + '|Notify_CE:' + String.valueOf(veevaNotification.Id);
                    validationExceptions.add(e);
                }
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        if(!validationExceptions.isEmpty()){
            AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
        } else {
            AGNInterfacePublishEvent.logBatchApex(batchableContext, totalCount);
        }
    }
}