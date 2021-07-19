// CLASS NOT USED

global class AGNGigyaAccountUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	global final List<Id> accountIds;
	private Integer totalCount = 0;
	private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();

	public AGNGigyaAccountUpdateBatch(List<Id> accountIds) {
		this.accountIds = accountIds;
	}

	public Database.QueryLocator start(Database.BatchableContext batchableContext) {
		return Database.getQueryLocator('SELECT Id, FirstName, LastName, PersonEmail, External_ID_vod__c ' +
		'FROM Account ' +
		'WHERE Id IN :accountIds');
	}

	public void execute(Database.BatchableContext batchableContext, List<Account> accounts) {
		totalCount = totalCount + accounts.size();

		for (Account account : accounts) {
			System.debug('processing:');
			List<Object> gigyaObjects = AGNGigyaRESTAccount.getUserIdsByAccountId(account.Id);
			System.debug(account);
			for (Object gigyaObject : gigyaObjects) {
				System.debug(gigyaObject);
				Map<String, Object> gigyaRecord = (Map<String, Object>) gigyaObject;
				try {
					AGNGigyaAccount gigyaAccount = new AGNGigyaAccount();
					gigyaAccount.setId(account.Id);
					gigyaAccount.setFirstName(account.FirstName);
					gigyaAccount.setLastName(account.LastName);
					gigyaAccount.setExternalId(account.External_ID_vod__c);
					gigyaAccount.setUserId(String.valueOf(gigyaRecord.get('UID')));
					AGNGigyaRESTAccount.setAccountInfo(gigyaAccount);
				} catch(AGNGigyaValidationException e) {
					e.errorDetail = e.errorDetail + '|account: ' + account + '|gigyaUID: ' + String.valueOf(gigyaRecord.get('UID'));
					validationExceptions.add(e);
				}
			}
		}
	}

	global void finish(Database.BatchableContext batchableContext){
		if(!validationExceptions.isEmpty()) {
			AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
			System.debug('>>> EXCEPTION <<<');
			System.debug(validationExceptions[0]);
			throw validationExceptions[0];
		} else {
			AGNInterfacePublishEvent.logBatchApex(batchableContext, totalCount);
		}
	}

}