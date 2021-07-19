public class AGN_CustomerRegistrationQueueableUtils implements Queueable, Database.AllowsCallouts {
    
    private Account accounts;
    private Contact con;
    private Allergan_Customer_Registration_AGN__c acr;
    
    public AGN_CustomerRegistrationQueueableUtils(Allergan_Customer_Registration_AGN__c customer, Account acc) {
        this.accounts = acc;
        this.acr = customer;
    }   
    public AGN_CustomerRegistrationQueueableUtils(Allergan_Customer_Registration_AGN__c customer, Contact con) {
        this.con= con;
        this.acr = customer;
    }
    public void execute(QueueableContext context) {
        //AGN_CustomerRegistrationUtils.createOktaUserSendLink(acr,accounts);
        AGN_CustomerRegistrationUtils.createOktaUserSendLink(acr,con); 
    }
}