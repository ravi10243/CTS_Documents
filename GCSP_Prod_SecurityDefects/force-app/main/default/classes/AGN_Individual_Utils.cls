public class AGN_Individual_Utils {
    
    public static Multichannel_Consent_vod__c createMultichannelRecord(String invdId, String recordTypeId, String accId, String emailOrPhoneId, Consent_Type_vod__c ct, String optType)
    {
        //AG CC
        if (Schema.sObjectType.Multichannel_Consent_vod__c.fields.RecordtypeId.isCreateable()){
            Multichannel_Consent_vod__c mConsent = new Multichannel_Consent_vod__c(
                     RecordtypeId = recordTypeId, 
                     Account_vod__c =  accId,
                     Channel_Value_vod__c = emailOrPhoneId,
                     Opt_Type_vod__c =  optType, 
                     Opt_Expiration_Date_vod__c = ((ct != null && optType == 'Opt_In_vod') ? calculateExpirationDate(ct.Consent_Expires_In_vod__c, ct.Consent_Custom_Duration_vod__c) : null),
                     Capture_Datetime_vod__c = System.now(),
                     Consent_Type_vod__c = ((ct != null) ? ct.Id : null),
                     Last_Device_vod__c = 'Online_vod',
                     Individual_ID_AGN__c = invdId                   
                     );
            return mConsent;
            }
        return null;
    }
    
    //Added a new Method Sep25,2018. 
    public static Multichannel_Consent_vod__c createMultichannelRecord(Id invdId, String recordTypeId, Id accId, String emailOrPhoneId, Consent_Type_vod__c ct, String optType, Consent_Line_vod__c cl)
    {
        System.debug('createMultichannelRecord***');
        Multichannel_Consent_vod__c mConsent = createMultichannelRecord(invdId,recordTypeId,accId,emailOrPhoneId,ct,optType); 
        mConsent.Consent_Line_vod__c = ((cl != null) ? cl.Id : null);
        mConsent.Content_Type_vod__c = ((cl != null && cl.Content_Type_vod__c != null) ? cl.Content_Type_vod__c : null);
        return mConsent; 
    }

    public static Date calculateExpirationDate(String consentDateValue, Decimal duration)
    {
        Date expiryDate = System.today();
        
        if(consentDateValue == 'Custom_Duration_vod' && duration != null && duration != 0)
        {
            expiryDate = expiryDate.addMonths(Integer.valueOf(duration));
        }
        else if(consentDateValue == 'One_Year_vod')
        {
            expiryDate = expiryDate.addYears(1);
        }
        else if(consentDateValue == 'End_Of_Calendar_Year_vod')
        {
            expiryDate = Date.newInstance(expiryDate.year(), 12, 31);
        }
        else if(consentDateValue == 'End_Of_Next_Calendar_Year_vod')
        {
            expiryDate = Date.newInstance(expiryDate.year()+1 , 12, 31);
        }
        else
            expiryDate = null;
             
        return expiryDate;      
    }
}