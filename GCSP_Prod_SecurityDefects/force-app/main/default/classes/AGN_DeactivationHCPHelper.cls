public class AGN_DeactivationHCPHelper {
    public final static String ACTION_DELETE = 'DELETE';
    public final static String ACTION_ANONYMIZE = 'ANONYMIZE';

    private Account account = null;
    private List<Call2_vod__c> recentCalls = null;
    private Account parentAccount = null;
    private Integer nCallSamples = 0;
    private Integer nContracts = 0;
    private Integer norders = 0;
    private Integer nMeetingsHavingCost = 0;
    private Integer nSiblings = 0;
    private Set<String> SELF_MANAGED_COUNTRY_CODES = new Set<String>();
    private final static String ANONIMISATION_TEXT_LABEL = 'GDPR DATA PROTECTION';
    private final static String ANONIMISATION_EMAIL_LABEL = 'GDPR@DATA-PROTECTION.com';
    private final static String ANONIMISATION_PHONE_LABEL = '0';

    public AGN_DeactivationHCPHelper(Id accountId) {
        SELF_MANAGED_COUNTRY_CODES = AGN_GDPRCountriesUtil.getSelfManagedCountries();
        System.debug('SELF_MANAGED_COUNTRY_CODES|' + SELF_MANAGED_COUNTRY_CODES);

        DateTime oneYearAgo = System.Now().addYears(-1);

        account = [SELECT Id, Name, FirstName, LastName, Middle_vod__c,
        Country_Code__c, Primary_Parent_vod__c,
        PersonMobilePhone, Phone, Phone_Internal_AGN__c,
        PersonEmail, Email_Internal_AGN__c, Fax_Internal_AGN__c
        FROM Account
        where Id = :accountId];
        if (account.Primary_Parent_vod__c != null) {
            parentAccount = [SELECT Id, Name, FirstName, LastName FROM Account WHERE Id = :account.Primary_Parent_vod__c];
        }
        //XXX Call_Datetime_vod__c?
        recentCalls = [SELECT Id, Name FROM Call2_vod__c WHERE Account_vod__c = :accountId AND Call_Datetime_vod__c >= :oneYearAgo];
        nCallSamples = [SELECT count() FROM Call2_Sample_vod__c WHERE Account_vod__c = :accountId LIMIT 1];
        //XXX Contract_Partner_vod__c? there are three Contracts tabs! Moreover, Contract Exhibit and Contract Package (related to CE)
        nContracts = [SELECT count() FROM Contract_Partner_vod__c WHERE Account_vod__c = :accountId LIMIT 1];
        //XXX Salesforce Order or Veeva Order?
        nOrders = [SELECT count() FROM Order_vod__c WHERE Account_vod__c = :accountId LIMIT 1];
        nMeetingsHavingCost = [SELECT count() FROM Meeting_Cost_AGN__c WHERE Medical_Event_AGN__r.Account_AGN__c = :accountId LIMIT 1];
        nSiblings = [SELECT count() FROM Child_Account_vod__c WHERE Parent_Account_vod__c = :account.Primary_Parent_vod__c];
        nSiblings -= 1; // to exclude himself
    }

    public void processDelete() {
        process(ACTION_DELETE);
    }

    public void processAnonymize() {
        process(ACTION_ANONYMIZE);
    }

    private void process(String action) {
        //TODO check if the country code field is the right one
        if (SELF_MANAGED_COUNTRY_CODES.contains(account.Country_Code__c)) {
            processSelfManagedData(action);
        } else {
            processIQVIAManagedData(action);
        }
    }

    private void processSelfManagedData(String action) {
        if(action == ACTION_ANONYMIZE) { // need to anonymise (beta)
            // if (needDataRetention()) { // need to retain data (beta-delta)
            //  if (isTheOnlyChild()) {
            //      setGDPRStatus(parentAccount);
            //  }
            //  anonymiseChildernObjects();
            //  setGDPRStatus(account);
            // } else { // no need to retain data (beta-gamma)
            if (isTheOnlyChild()) {
                deleteHCA();
            }
            anonymisePersonalData(account);
            anonymiseChildernObjects(account.id);
            setGDPRStatus(account);
            // }
        } else if(action == ACTION_DELETE) { // no need to anonymise (alpha)
            // if (needDataRetention()) { // need to retain data (alpha-delta)
            //  if (isTheOnlyChild()) {
            //      setGDPRStatus(parentAccount);
            //  }
            //  setGDPRStatus(account);
            // } else { // no need to retain data (alpha-gamma)
            if (isTheOnlyChild()) {
                deleteHCA();
            }
            deleteChildernObjects(account.Id, false);
            deleteHCP();
        } else {
            throw new AGN_customException(0, 'Action not found.');
        }
        //}
    }

    private void processIQVIAManagedData(String action) {
        if(action == ACTION_ANONYMIZE) { // need to anonymise (beta)
            // if (needDataRetention()) { // need to retain data (beta-delta)
            //  if (isTheOnlyChild()) {
            //      setGDPRStatus(parentAccount);
            //  }
            //  anonymiseChildernObjects();
            //  setGDPRStatus(account);
            // } else { // no need to retain data (beta-gamma)
            if (isTheOnlyChild()) {
                setGDPRStatus(parentAccount);
                deleteChildernObjects(parentAccount.id, true);
            }
            anonymisePersonalData(account);
            anonymiseChildernObjects(account.id);
            deleteChildernObjects(account.id, true);
            setGDPRStatus(account);
            // }
        } else if(action == ACTION_DELETE) { // no need to anonymise (alpha)
            // if (needDataRetention()) { // need to retain data (alpha-delta)
            //  if (isTheOnlyChild()) {
            //      setGDPRStatus(parentAccount);
            //  }
            //  setGDPRStatus(account);
            // } else { // no need to retain data (alpha-gamma)
            if (isTheOnlyChild()) {
                deleteHCA();
            }
            deleteChildernObjects(account.Id, false);
            deleteHCP();
        } else {
            throw new AGN_customException(0, 'Action not found.');
        }
    }

    /**
    * This method anonymises account's personal data
    * but no childern objects
    */
    private void anonymisePersonalData(Account account) {
        account acc = new Account();
        acc.LastName = ANONIMISATION_TEXT_LABEL;   
        acc.id = account.id;
        acc.FirstName = ANONIMISATION_TEXT_LABEL;
        //account.LastName = ANONIMISATION_TEXT_LABEL;
        acc.Middle_vod__c = ANONIMISATION_TEXT_LABEL;
        acc.PersonMobilePhone = ANONIMISATION_PHONE_LABEL;
        acc.Phone = ANONIMISATION_PHONE_LABEL;
        acc.Phone_Internal_AGN__c = ANONIMISATION_PHONE_LABEL;
        acc.PersonEmail = ANONIMISATION_EMAIL_LABEL;
        acc.Email_Internal_AGN__c = ANONIMISATION_EMAIL_LABEL;
        acc.Fax_Internal_AGN__c = ANONIMISATION_PHONE_LABEL;
        //XXX Consider to update the account when all operations are done
        update acc ;
       
    }

    /**
    * This method anonymises children objects
    */
    private void anonymiseChildernObjects(Id accountId) {
        // anonymising Multichannel_Consent_vod__c
        try {
            List<Multichannel_Consent_vod__c> l = [SELECT Channel_Value_vod__c
            FROM Multichannel_Consent_vod__c
            WHERE Account_vod__c = :accountId
            ];
            for (Multichannel_Consent_vod__c o : l) {
                o.Channel_Value_vod__c = ANONIMISATION_TEXT_LABEL;
            }
            update l;
        } catch (DmlException e) {
        }

        // anonymising Allergan_Customer_Registration_AGN__c
        try {
            List<Allergan_Customer_Registration_AGN__c> l = [SELECT First_Name_AGN__c,
            Email_AGN__c, Last_Name_AGN__c, Middle_Name_AGN__c, Phone_AGN__c
            FROM Allergan_Customer_Registration_AGN__c
            WHERE Account_AGN__c = :accountId
            ];
            for (Allergan_Customer_Registration_AGN__c o : l) {
                o.First_Name_AGN__c = ANONIMISATION_TEXT_LABEL;
                o.Email_AGN__c = ANONIMISATION_EMAIL_LABEL;
                o.Last_Name_AGN__c = ANONIMISATION_TEXT_LABEL;
                o.Middle_Name_AGN__c = ANONIMISATION_TEXT_LABEL;
                o.Phone_AGN__c = ANONIMISATION_PHONE_LABEL;
            }
            update l;
        } catch (DmlException e) {
        }

        // anonymising Allergan_Customer_Address_AGN__c
        try {
            List<Allergan_Customer_Address_AGN__c> l = [SELECT SAP_Name_2_AGN__c
            FROM Allergan_Customer_Address_AGN__c
            WHERE Account_AGN__c = :accountId
            ];
            for (Allergan_Customer_Address_AGN__c o : l) {
                o.SAP_Name_2_AGN__c = ANONIMISATION_TEXT_LABEL;
            }
            update l;
        } catch (DmlException e) {
        }

        // anonymising Sample_Order_Transaction_vod__c
        try {
            List<Sample_Order_Transaction_vod__c> l = [SELECT Account_Name_vod__c
            FROM Sample_Order_Transaction_vod__c
            WHERE Account_vod__c = :accountId
            ];
            for (Sample_Order_Transaction_vod__c o : l) {
                o.Account_Name_vod__c = ANONIMISATION_TEXT_LABEL;
            }
            update l;
        } catch (DmlException e) {
        }

        // anonymising Data_Change_Request_Line_vod__c
        try {
            List<Id> dcrIds = new List<Id>(new Map<Id, Data_Change_Request_vod__c>([
            select Id
            from Data_Change_Request_vod__c
            where Account_vod__c = :accountId]).keySet());
            List<Data_Change_Request_Line_vod__c> l = [SELECT New_Value_vod__c, Old_Value_vod__c
            FROM Data_Change_Request_Line_vod__c
            WHERE Id IN :dcrIds
            ];
            for (Data_Change_Request_Line_vod__c o : l) {
                o.New_Value_vod__c = ANONIMISATION_TEXT_LABEL;
                o.Old_Value_vod__c = ANONIMISATION_TEXT_LABEL;
            }
            update l;
        } catch (DmlException e) {
        }

        // anonymising Order_vod__c
        try {
            List<Order_vod__c> l = [SELECT Account_Name_vod__c
            FROM Order_vod__c
            WHERE Account_vod__c = :accountId
            ];
            for (Order_vod__c o : l) {
                o.Account_Name_vod__c = ANONIMISATION_TEXT_LABEL;
            }
            update l;
        } catch (DmlException e) {
        }

        // anonymising Sample_Limit_vod__c
        try {
            List<Sample_Limit_vod__c> l = [SELECT Name
            FROM Sample_Limit_vod__c
            WHERE Account_vod__c = :accountId
            ];
            for (Sample_Limit_vod__c o : l) {
                o.Name = ANONIMISATION_TEXT_LABEL;
            }
            update l;
        } catch (DmlException e) {
        }

        // anonymising Sample_Limit_Transaction_vod__c
        try {
            List<Sample_Limit_Transaction_vod__c> l = [SELECT Account_Name_vod__c, Sample_Limit_Name_vod__c
            FROM Sample_Limit_Transaction_vod__c
            WHERE Account_vod__c = :accountId
            ];
            for (Sample_Limit_Transaction_vod__c o : l) {
                o.Account_Name_vod__c = ANONIMISATION_TEXT_LABEL;
                o.Sample_Limit_Name_vod__c = ANONIMISATION_TEXT_LABEL;
            }
            update l;
        } catch (DmlException e) {
        }

        // anonymising Call2_vod__c
        try {
            List<Call2_vod__c> l = [SELECT Call_Comments_vod__c
            FROM Call2_vod__c
            WHERE Account_vod__c = :accountId
            ];
            for (Call2_vod__c o : l) {
                o.Call_Comments_vod__c = ANONIMISATION_TEXT_LABEL;
            }
            update l;
        } catch (DmlException e) {
        }
    }

    /**
    * This method set the Account' status to 'GDPR'
    */
    private void setGDPRStatus(Account a) {
         account acc= new Account();
        acc.Privacy_law_status_AGN__c = True;
        acc.id = a.id;
        //XXX Consider to update the account when all operations are done
        update acc;
    }

    /**
    * This method hard delete the HCP
    */
    private void deleteHCP() {
        delete account;
    }

    /**
    * This method hard delete the account's childern objects
    * If mantainCalls is true, calls will not be removed
    */
    private void deleteChildernObjects(Id accountId, Boolean mantainCalls) {

        if (!mantainCalls) {
            // removing calls
            List<Call2_vod__c> calls = [SELECT Id
            FROM Call2_vod__c
            WHERE Account_vod__c = :accountId
            ];
            delete calls;
        }

        // removing child accounts
        List<Child_Account_vod__c> childAccounts = [SELECT Id
        FROM Child_Account_vod__c
        where Child_Account_vod__c = :accountId
        ];
        delete childAccounts;

        // removing TSF
        List<TSF_vod__c> tsf = [SELECT Id
        FROM TSF_vod__c
        WHERE Account_vod__c = :accountId
        ];
        delete tsf;

        // removing medical events
        List<Medical_Event_vod__c> medicalEvent = [SELECT Id
        FROM Medical_Event_vod__c
        WHERE Account_vod__c = :accountId
        OR Account_AGN__c = :accountId
        ];
        delete medicalEvent;

        // removing addresses
        List<Address_vod__c> addresses = [SELECT Id
        FROM Address_vod__c
        WHERE Account_vod__c = :accountId
        OR Account_AGN__c = :accountId
        ];
        delete addresses;
    }

    /**
    * This method hard delete the HCA and all child entities
    */
    private void deleteHCA() {
        if (parentAccount != null) {
            deleteChildernObjects(parentAccount.Id, false);
            delete parentAccount;
        }
        throw new AGN_customException(0, 'to check');
    }

    /**
    * This method checks if the parent HCA has only one child
    */
    public Boolean isTheOnlyChild() {
        return nSiblings == 0;
    }

    /**
    * This method checks if account has any of following entities:
    *  call samples, contracts, orders, meeting attendees having cost
    * @return
    * true - data retention needed
    * false - otherwise
    */
    public Boolean needDataRetention() {
        return nCallSamples + nContracts + nOrders + nMeetingsHavingCost > 0;
    }

    /**
    * This method checks if there are any call with date less than 12 months
    *
    * @return
    *  true - anonymisation needed
    *  false - otherwise
    */
    public Boolean needAnonymise() {
        return recentCalls != null && recentCalls.size() > 0;
    }
}