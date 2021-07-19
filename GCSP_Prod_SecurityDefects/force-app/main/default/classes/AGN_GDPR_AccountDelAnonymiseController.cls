public class AGN_GDPR_AccountDelAnonymiseController {
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String emailId {get; set;}
    public String emailInternalId {get; set;}
    public String  phoneNumber {get; set;}
    public List<Account> accountList {get; set;}
    public String selectedAccountId {get; set;}
    public String sfdcId {get; set;}
    public Map<String, String> accountMap = new Map<String, String>();


    public void AGN_GDPR_AccountDelAnonymiseController(){
        firstName = '';
        lastName = '';
        emailId = '';
        phoneNumber = '';
        emailInternalId = '';
        sfdcId = '';
        accountList = new List<Account>();
    }

    public PageReference searchResultsAccount(){
        List<String> queryString = new List<String>();

        String query = 'Select Id, Name, FirstName, LastName, PersonEmail, Email_Internal_AGN__c, PersonMobilePhone from Account where ';
        if(firstName != ''){
            String firstNameString = ' FirstName = \''+ firstName +'\'';
            queryString.add(firstNameString);
        }

        if(lastName != ''){
            String lastNameString = ' LastName = \''+ lastName +'\'';
            queryString.add(lastNameString);
        }

        if(emailId != ''){
            String emailIdString = ' PersonEmail = \''+ emailId +'\'';
            queryString.add(emailIdString);
        }

        if(emailInternalId != ''){
            String emailInternalIdString = ' Email_Internal_AGN__c = \''+ emailInternalId +'\'';
            queryString.add(emailInternalIdString);
        }

        if(phoneNumber != ''){
            String phoneNumberString = ' PersonMobilePhone = \''+ phoneNumber +'\'';
            queryString.add(phoneNumberString);
        }

        if(sfdcId != '' && sfdcId != null){
            String sfdcId = ' Id = \''+ sfdcId +'\'';
            queryString.add(sfdcId);
        }

        try{

            if(!queryString.isEmpty()){
                query += String.join(queryString, ' And ');
                system.debug('query:::: '+query);
                accountList = Database.query(query);

                for(Account account : accountList){
                    accountMap.put(account.Id, account.Name);
                }
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter atleast one field value in search criteria.');
                ApexPages.addMessage(myMsg);
                return null;
            }

        }
        catch(Exception ex){
            System.debug('exception in search:::: '+ex);

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No search results found.');
            ApexPages.addMessage(myMsg);
            return null;

        }

        return null;
    }
    public PageReference hardDelete() {
        new AGN_DeactivationHCPHelper(selectedAccountId).processDelete();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '[DEV] In order to run the process, decomment the first row of AGN_GDPR_AccountDelAnonymiseController.hardDelete() method'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deletion process started on ' + selectedAccountId));
        return null;
    }

    public PageReference anonymize() {
        new AGN_DeactivationHCPHelper(selectedAccountId).processAnonymize();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '[DEV] In order to run the process, decomment the first row of AGN_GDPR_AccountDelAnonymiseController.anonymize() method'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Anonymization process started on ' + selectedAccountId));
        return null;
    }

    public PageReference submitApproval(){

        try{

            System.debug('accountId:::: '+selectedAccountId);
            if(selectedAccountId != '' && selectedAccountId != ''){
                String accountName = (accountMap != null && accountMap.size() > 0 && accountMap.containsKey(selectedAccountId)) ? accountMap.get(selectedAccountId) : selectedAccountId;
                
                /* Commented this code as approval or DSR object is not used in current roll out. */
                //Data_Subject_Request_AGN__c dsr = new Data_Subject_Request_AGN__c(Name=accountName, Account__c=selectedAccountId);
                //insert dsr;

                return new PageReference('/'+selectedAccountId);
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Choose an account.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        catch(Exception ex){
            System.debug('exception in dsr creation::: '+ex);

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating Data subject request record.');
            ApexPages.addMessage(myMsg);
            return null;
        }

    }

}