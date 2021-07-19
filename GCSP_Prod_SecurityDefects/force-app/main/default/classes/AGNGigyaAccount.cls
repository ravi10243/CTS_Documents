/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* This class represents a Gigya Account object.
*/

public class AGNGigyaAccount {
    
    // Veeva Account Id
    private String accountId = '';
    // Gigya UID
    private String userId = '';
    private String username = '', firstName = '', lastName = '',
        email = '', secondaryEmail = '', externalId = '', phone = '',
        externalId2 = '', countryCode = '', countryName = '', salutation = '',
        status = '', additionalStatus = '', specialty1 = '', specialty2 = '',
        createdTimestamp = '', mdmId = '',distributionID = '', physicianRefNumber = '';
    private Boolean privacyLawStatus = false;
    //private Boolean brPrivacyLawStatus = false;
    private Boolean updated = false;
    private Map<String, Object> rawData = new Map<String, Object>();
    //    private List<String> tags = new List<String>();
    public String getId() { return accountId; }
    public Boolean isUpdated() { System.debug('--- isupdated? ' + updated); return updated; }
    public String getUsername() { return username; }
    public String getUserId() { return userId; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public String getEmail() { return email; }
    public String getSecondaryEmail() { return secondaryEmail; }
    public String getPhone() { return phone; }
    public String getExternalId() { return externalId; }
    public String getExternalId2() { return externalId2; }
    public String getMdmId() { return mdmId; }
    public String getCountryCode() { return countryCode; }
    //public String getBrCountryCode() { return BrCountryCode; }
    public String getCountryName() { return countryName; }
    public String getSalutation() { return salutation; }
    public String getStatus() { return status; }
    public String getAdditionalStatus() { return additionalStatus; }
    public String getSpecialty1() { return specialty1; }
    public String getSpecialty2() { return specialty2; }
    public String getdistributionID() { return distributionID; }
    public String getphysicianRefNumber(){return physicianRefNumber;}  
    public Boolean getPrivacyLawStatus() { return privacyLawStatus; }
    //public Boolean getbrPrivacyLawStatus() { return brPrivacyLawStatus; }
    public String getCreatedTimestamp() { return createdTimestamp; }
    public Map<String, Object> getRawData() { return rawData; }
    
    // to set the Veeva Account Id
    public void setId(String value) {
        if (!String.isEmpty(value)) {
            this.accountId = value;
            updated = true;
        }
    }
    // to set the Gigya UID
    public void setUserId(String userId) {
        if (!String.isEmpty(userId)) {
            this.userId = userId;
        }
    }
    public void setPhone(String phone) {
        if (!String.isEmpty(phone)) {
            this.phone = phone;
            updated = true;
        }
    }
    public void setRawData(Map<String, Object> rawData) {
        if (rawData != null) {
            this.rawData = rawData;
        }
    }
    public void setUsername(String username) {
        if (!String.isEmpty(username)) {
            this.username = username;
            updated = true;
        }
    }
    public void setFirstName(String firstName) {
        if (!String.isEmpty(firstName)) {
            this.firstName = String.escapeSingleQuotes(firstName).replace('&', '%26');
            updated = true;
        }
    }
    public void setLastName(String lastName) {
        if (!String.isEmpty(lastName)) {
            this.lastName = String.escapeSingleQuotes(lastName).replace('&', '%26');
            updated = true;
        }
    }
    public void setEmail(String email) {
        if (!String.isEmpty(email) && AGNGigyaRESTHelper.validateEmail(email)) {
            this.email = String.escapeSingleQuotes(email);
            updated = true;
        }
    }
    public void setSecondaryEmail(String secondaryEmail) {
        if (!String.isEmpty(secondaryEmail)) {
            this.secondaryEmail = secondaryEmail;
            updated = true;
        }
    }
    public void setExternalId(String externalId) {
        if (!String.isEmpty(externalId)) {
            this.externalId = externalId;
            updated = true;
        }
    }
    public void setExternalId2(String externalId2) {
        if (!String.isEmpty(externalId2)) {
            this.externalId2 = externalId2;
            updated = true;
        }
    }
    public void setCountryCode(String value) {
        if (!String.isEmpty(value)) {
            this.countryCode = value;
            updated = true;
        }
    }
   /* public void setBrCountryCode(String value) {
        if (!String.isEmpty(value)) {
            this.BrCountryCode = value;
            updated = true;
        }
    }*/
    public void setMdmId(String value) {
        if (!String.isEmpty(value)) {
            this.mdmId = value;
            updated = true;
        }
    }
    public void setCountryName(String value) {
        if (!String.isEmpty(value)) {
            this.countryName = value;
            updated = true;
        }
    }
    public void setSalutation(String value) {
        if (!String.isEmpty(value)) {
            this.salutation = value;
            updated = true;
        }
    }
    public void setStatus(String value) {
        if (!String.isEmpty(value)) {
            this.status = String.escapeSingleQuotes(value).replace('&', '%26');
            updated = true;
        }
    }
    public void setAdditionalStatus(String value) {
        if (!String.isEmpty(value)) {
            this.additionalStatus = String.escapeSingleQuotes(value).replace('&', '%26');
            updated = true;
        }
    }
    public void setSpecialty1(String value) {
        if (!String.isEmpty(value)) {
            this.specialty1 = String.escapeSingleQuotes(value).replace('&', '%26');
            updated = true;
        }
    }
    public void setSpecialty2(String value) {
        if (!String.isEmpty(value)) {
            this.specialty2 = String.escapeSingleQuotes(value).replace('&', '%26');
            updated = true;
        }
    }
    //Added specfic to Brazil
    public void setDistributionID(String value){
        if(!String.isEmpty(value)){
            this.distributionID = value;
            updated = true;
        }
    }
    //Added specfic to Brazil
    public void setphysicianRefNumber(String physician){
        if(!String.isEmpty(physician)){
            this.physicianRefNumber = physician;
            updated = true;
        }
    }
    public void setCreatedTimestamp(String value) {
        if (!String.isEmpty(value)) {
            this.createdTimestamp = value;
        }
    }
    public void setPrivacyLawStatus(Boolean value) {
        if (value != null) {
            this.privacyLawStatus = value;
            updated = true;
        }
    }
  /*  public void setbrPrivacyLawStatus(Boolean value) {
        if (value != null) {
            this.brPrivacyLawStatus = value;
            updated = true;
        }
    }*/
}