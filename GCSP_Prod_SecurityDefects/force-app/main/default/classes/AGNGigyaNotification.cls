/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* Gigya Notification Object
*/

public class AGNGigyaNotification {

    private String
    email = '',
    externalId = '',
    firstName = '',
    notificationStatus = '',
    notificationStatusforBR = '',
    lastName = '',
    middleName = '',
    salutation = '',
    createdTime = '',
    emailTemplateName = '',
    externalId2 = '',
    countryCode = '',
    countryName = '',
    secondaryEmail = '',
    status = '',
    additionalStatus = '',
    specialty1 = '',
    specialty2 = '',
    sfdcId = '',
    createdTimestamp = '',
    emailSentDate = '',
    oid = 'auto'
    ;

    private Map<String, Object> rawData;

    private Boolean notificationReceived = null;
    //private Boolean brNotificationReceived = null;
    private Boolean privacyLawStatus = false;
    private Boolean updated = false;
    private DateTime veevaCreatedDate;
    private DateTime emailSentRecDate;

    public Map<String, Object> getRawData() { return rawData; }
    public String getEmail() { return email; }
    public String getExternalId() { return externalId; }
    public String getFirstName() { return firstName; }
    public Boolean isNotificationReceived() { return notificationReceived; }
    //public Boolean isNotificationReceivedforBR() { return brNotificationReceived; }
    public Boolean isUpdated() { System.debug('--- isupdated? ' + updated); return updated; }
    public Boolean getNotificationReceived() { return notificationReceived; }
    public String getNotificationStatus() { return notificationStatus; }
    public String getNotificationStatusBR() { return notificationStatusforBR; }
    public String getLastName() { return lastName; }
    public String getMiddleName() { return middleName; }
    public String getSalutation() { return salutation; }
    public String getCreatedTime() { return createdTime; }
    public String getEmailTemplateName() { return emailTemplateName; }
    public String getSfdcId() { return sfdcId; }
    public String getUserId() { return sfdcId; }
    public String getExternalId2() { return externalId2; }
    public String getEmailSentDate() { return emailSentDate; }
    public String getCountryCode() { return countryCode; }
    public String getCountryName() { return countryName; }
    public String getSecondaryEmail() { return secondaryEmail; }
    public String getStatus() { return status; }
    public String getAdditionalStatus() { return additionalStatus; }
    public String getSpecialty1() { return specialty1; }
    public String getSpecialty2() { return specialty2; }
    public String getOid() { return oid; }
    public String getCreatedTimestamp() { return createdTimestamp; }
    public Boolean getPrivacyLawStatus() { return privacyLawStatus; }
    public DateTime getVeevaCreatedDate() { return veevaCreatedDate; }
    public DateTime getemailSentRecDate(){ return emailSentRecDate;}

    public AGNGigyaNotification() {
        updated = false;
    }
    public void setRawData(Map<String, Object> value) {
            this.rawData = value;
    }
    public void setEmail(String email) {
        if (!String.isEmpty(email) && AGNGigyaRESTHelper.validateEmail(email)) {
            this.email = String.escapeSingleQuotes(email);
            updated = true;
        }
    }
    public void setExternalId(String externalId) {
        if (!String.isEmpty(externalId)) {
            this.externalId = externalId;
            updated = true;
        }
    }
    public void setFirstName(String firstName) {
        if (!String.isEmpty(firstName)) {
            this.firstName = String.escapeSingleQuotes(firstName).replace('&', '%26');
            updated = true;
        }
    }
    public void setNotificationReceived(Boolean notificationReceived) {
        if (notificationReceived != null) {
            this.notificationReceived = notificationReceived;
            updated = true;
        }
    }
   
    //Added specfic to Brazil
    public void setNotificationStatusBR(String notificationStatusBr) {
        if (!String.isEmpty(notificationStatusBr)) {
            this.notificationStatusforBR = notificationStatusBr;
            updated = true;
        }
    }
    public void setNotificationStatus(String notificationStatus) {
        if (!String.isEmpty(notificationStatus)) {
            this.notificationStatus = notificationStatus;
            updated = true;
        }
    }
    public void setLastName(String lastName) {
        if (!String.isEmpty(lastName)) {
            this.lastName = String.escapeSingleQuotes(lastName).replace('&', '%26');
            updated = true;
        }
    }
    public void setMiddleName(String middleName) {
        if (!String.isEmpty(middleName)) {
            this.middleName = String.escapeSingleQuotes(middleName).replace('&', '%26');
            updated = true;
        }
    }
    public void setSalutation(String salutation) {
        if (!String.isEmpty(salutation)) {
            this.salutation = String.escapeSingleQuotes(salutation).replace('&', '%26');
            updated = true;
        }
    }
    public void setCreatedTime(String createdTime) {
        if (!String.isEmpty(createdTime)) {
            this.createdTime = createdTime;
            updated = true;
        }
    }
    public void setEmailSentDate(String value) {
        if (!String.isEmpty(value)) {
            this.emailSentDate = value;
            updated = true;
        }
    }
    public void setEmailTemplateName(String emailTemplateName) {
        if (!String.isEmpty(emailTemplateName)) {
            this.emailTemplateName = emailTemplateName;
            updated = true;
        }
    }
    public void setVeevaCreatedDate(DateTime veevaCreatedDate) {
        if (veevaCreatedDate != null) {
            this.veevaCreatedDate = veevaCreatedDate;
            updated = true;
        }
    }
    public void setemailSentRecDate(DateTime receivedDate) {
        if (receivedDate != null) {
            this.emailSentRecDate = receivedDate;
            updated = true;
        }
    }
    public void setSfdcId(String sfdcId) {
        if (!String.isEmpty(sfdcId)) {
            this.sfdcId = sfdcId;
            updated = true;
        }
    }
    public void setExternalId2(String value) {
        if (!String.isEmpty(value)) {
            this.externalId2 = value;
            updated = true;
        }
    }
    public void setCountryCode(String value) {
        if (!String.isEmpty(value)) {
            this.countryCode = value;
            updated = true;
        }
    }
    public void setCountryName(String value) {
        if (!String.isEmpty(value)) {
            this.countryName = String.escapeSingleQuotes(value).replace('&', '%26');
            updated = true;
        }
    }
    public void setSecondaryEmail(String value) {
        if (!String.isEmpty(value)) {
            this.secondaryEmail = value;
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
    public void setPrivacyLawStatus(Boolean value) {
        if (value != null) {
            this.privacyLawStatus = value;
            updated = true;
        }
    }
    public void setOid(String value) {
        if (!String.isEmpty(value)) {
            this.oid = value;
        }
    }
    public void setCreatedTimestamp(String value) {
        if (!String.isEmpty(value)) {
            this.createdTimestamp = value;
        }
    }
}