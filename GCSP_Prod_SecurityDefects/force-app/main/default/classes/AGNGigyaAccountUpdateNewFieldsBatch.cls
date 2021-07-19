/**
* --------------
* Allergan GDPR
* November 2018
* --------------
* This Batch class retrieves accounts from Gigya EPM
* gets the corresponding accounts in Veeva
* and push in Gigya the updated fields
*
* It is executed one time to push in Gigya new Veeva account fields for existing HCP.
*/
public class AGNGigyaAccountUpdateNewFieldsBatch implements Database.Batchable<AGNGigyaAccount>, Database.AllowsCallouts, Database.Stateful {
	private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
	private Map<String, Account> accountsMap = new Map<String, Account>();
	private Integer totalCount = 0;
	private String externalLastSyncCreatedTimestamp = '';
	private String lastSyncCreatedTimestampRecord = '';

	public AGNGigyaAccountUpdateNewFieldsBatch(String externalLastSyncCreatedTimestamp) {
		this.externalLastSyncCreatedTimestamp = externalLastSyncCreatedTimestamp;
	}

	public List<AGNGigyaAccount> start(Database.BatchableContext batchableContext) {
		List<AGNGigyaAccount> l = AGNGigyaRESTAccount.getUsersToUpdate(externalLastSyncCreatedTimestamp);
		Set<Id> accountIds = new Set<Id>();
		for (AGNGigyaAccount obj : l) {
			if (isValidId(obj.getId())) {
				accountIds.add(obj.getId());
			}
		}

		Account[] accounts = [SELECT Id, FirstName, LastName, PersonEmail, Country_Name_AGN__c, Status_AGN__c,
		Additional_Status_AGN__c, Email_Internal_AGN__c, External_ID_vod__c, External_ID2_AGN__c, Middle_vod__c,
		MDM_ID_AGN__c, Country_vod__r.Name, Specialty_Allergan_1_AGN__r.Name, Sub_Specialty_Allergan_AGN__r.Name, 
		Specialty_1_AGN__r.Name, Specialty_2_AGN__r.Name, Salutation, Privacy_Law_Status_AGN__c
		FROM Account WHERE Id IN :accountIds
		];
		for (Account account : accounts) {
			accountsMap.put(account.Id, account);
		}

		return l;
	}

	public void execute(Database.BatchableContext batchableContext, List<AGNGigyaAccount> gigyaAccounts) {
		totalCount += gigyaAccounts.size();
		System.debug('working on ' + gigyaAccounts.size() + ' gigyaAccounts');
		for (AGNGigyaAccount gigyaAccount : gigyaAccounts) {
			lastSyncCreatedTimestampRecord = gigyaAccount.getCreatedTimestamp();
			Account account = null;
			if (!String.isBlank(gigyaAccount.getId())) {
				account = accountsMap.get(gigyaAccount.getId());
			}
			System.debug('account|' + account);
			if (account != null) {
				System.debug('gigyaAccount|' + gigyaAccount);
				// consent process - start
				List<String> profileFieldsToEmpty = new List<String>();
				List<String> dataFieldsToEmpty = new List<String>();
				AGNGigyaAccount newGigyaAccount = AGNGigyaMCConsentUtil.getNewGigyaAccount(gigyaAccount, account, profileFieldsToEmpty, dataFieldsToEmpty);
				try {
					if (newGigyaAccount.isUpdated() || profileFieldsToEmpty.size() > 0 || dataFieldsToEmpty.size() > 0) {
						System.debug('D003/D005-2 - consent process - account updated|' + newGigyaAccount);
						AGNGigyaRESTAccount.setAccountInfo(newGigyaAccount, profileFieldsToEmpty, dataFieldsToEmpty);
					}
				} catch(AGNGigyaValidationException e) {
					e.errorDetail = e.errorDetail + '|account: ' + account + '|gigyaUID: ' + String.valueOf(gigyaAccount.getUserId());
					validationExceptions.add(e);
				}
				// consent process - end
			}
		}
	}

	public void finish(Database.BatchableContext batchableContext){
		System.debug('this.lastSyncCreatedTimestampRecord|' + this.lastSyncCreatedTimestampRecord);
		if(!validationExceptions.isEmpty()) {
			AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
			System.debug('>>> EXCEPTION <<<');
			System.debug(validationExceptions[0]);
			throw validationExceptions[0];
		} else {
			AGNInterfacePublishEvent.logBatchApex(batchableContext, totalCount);
		}
	}

	private Boolean isValidId(String id) {
		return !String.isEmpty(id) && (id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id);
	}

}