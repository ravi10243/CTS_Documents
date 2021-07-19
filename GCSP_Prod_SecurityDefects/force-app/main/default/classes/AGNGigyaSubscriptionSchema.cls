/**
 * --------------
 * Allergan GDPR 
 * March 2018
 * --------------
 * This class identifies a Gigya Subscription Schema object.
 */

public class AGNGigyaSubscriptionSchema {
    public String description, type, subscriptionId;
    public Boolean required, doubleOptIn;
    
    public AGNGigyaSubscriptionSchema(){
    }
    
    public AGNGigyaSubscriptionSchema(String subscriptionId, String description) {
        this.subscriptionId = subscriptionId;
        this.description = description;
        this.type = 'subscription';
        this.required = false;
        this.doubleOptIn = false;
    }
}