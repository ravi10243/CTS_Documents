/*
Type Name: AGN_ErrorLogger
Reason: Helper class for creating error logs during integration, jobs etc.
13-03-2017 - SG - Initial Version
*/
public class AGN_ErrorLogger {
    
    public static list<Allergan_Error_Logger_AGN__c> errorLogs = new list<Allergan_Error_Logger_AGN__c>();
    
    // create logs for customer registration records
    public static void addCustomerRegsistrationError(string source, string type, string errorMessage, Id recordId, Id addressID){
        
        Allergan_Error_Logger_AGN__c err = addErrorLog(source, type, errorMessage);
        if (Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Customer_Registration_AGN__c.isCreateable()){  //cc_AD
            err.Customer_Registration_AGN__c = recordId;
			}
        if(addressID!=Null)
           if (Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Address_AGN__c.isCreateable()){ //cc_AD
               err.Address_AGN__c= addressID;
            }
        errorLogs.add(err);
    }
    //create logs for account records
    public static void addAccountError(string source, string type, string errorMessage, Id recordId){
        
        Allergan_Error_Logger_AGN__c err = addErrorLog(source, type, errorMessage);
        if (Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Account_AGN__c.isCreateable()){ //cc_AD
            err.Account_AGN__c = recordId;
        }
        errorLogs.add(err);
    }
    
    public static Allergan_Error_Logger_AGN__c addErrorLog(string source, string type, string errorMessage){
        
        Allergan_Error_Logger_AGN__c err = new Allergan_Error_Logger_AGN__c();
        if (Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Source_AGN__c.isCreateable()){   //cc_AD
           err.Source_AGN__c = source;
		   }
        if (Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Transaction_AGN__c.isCreateable()){   //cc_AD
           err.Transaction_AGN__c = type;
		   }
        if (Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Error_Message_AGN__c.isCreateable()){   //cc_AD
           err.Error_Message_AGN__c = errorMessage;
		   }
        return err;
    }
    
    //save all logs
    public static void saveLogs(){
	   if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.isCreateable()){ //cc_AD
          insert errorLogs;
		}
        errorLogs.clear();
    }

}