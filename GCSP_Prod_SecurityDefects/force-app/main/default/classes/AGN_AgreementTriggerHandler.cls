/*
 * 	Author: GCSP Core Plus Team
 * 	Created Date: 22/06/2021
 *	Description: This is handler class for trigger AGN_AgreementTrigger
 */

public class AGN_AgreementTriggerHandler {
	public void onAfterUpdate(List<echosign_dev1__SIGN_Agreement__c> records) { 
        String allerganCustomerAddressId;
        if(records.size() > 0) {
        	allerganCustomerAddressId = records[0].Allergan_Customer_Address_agn__c + '';            
        }
        String regnAdobeSignStatus = '';
        allerganCustomerAddressId = String.escapeSingleQuotes(allerganCustomerAddressId);
        String allerganCustomerRegistrationId = [select id, Parent_AGN__c from Allergan_Customer_Address_agn__c where id =: allerganCustomerAddressId limit 1].Parent_AGN__c;
        allerganCustomerRegistrationId = String.escapeSingleQuotes(allerganCustomerRegistrationId);
        Allergan_Customer_Registration_agn__c regnToUpdate = [select id, Adobe_Sign_Status_for_Agreement_agn__c from Allergan_Customer_Registration_agn__c where id =: allerganCustomerRegistrationId];
        List<echosign_dev1__SIGN_Agreement__c> agreementList = [select id, echosign_dev1__Status__c from echosign_dev1__SIGN_Agreement__c where Allergan_Customer_Registration_agn__c =: allerganCustomerRegistrationId order by echosign_dev1__Status__c];
		// Check if document is Signed.
        for(echosign_dev1__SIGN_Agreement__c agreement : agreementList) {
            // If document status is 'Out for Signature' => Final status will stamp as 'Out for Signature'
            if(agreement.echosign_dev1__Status__c == 'Out for Signature') {
                regnAdobeSignStatus = 'Out for Signature';
                break;
            }
            // If document status is 'Waiting for Counter-Signature' or 'Signed' => Final status will stamp as 'Waiting for Counter-Signature'
            if(agreement.echosign_dev1__Status__c == 'Waiting for Counter-Signature') {
                regnAdobeSignStatus = 'Waiting for Counter-Signature';
                break;
            }
            // If all documents are 'Signed' => Final status will stamp as 'Signed'
            if(agreement.echosign_dev1__Status__c == 'Signed') {
                regnAdobeSignStatus = 'Signed';
            }            
        }
        regnToUpdate.Adobe_Sign_Status_for_Agreement_agn__c = regnAdobeSignStatus;
        if( String.isNotBlank(regnToUpdate.Adobe_Sign_Status_for_Agreement_agn__c)) {
            try {
            	update regnToUpdate;    
            } catch (Exception e) {
                System.debug('--> Error at ' + e.getLineNumber() + ' | Message: ' + e.getMessage());
            }
        	
        } 
    }
}