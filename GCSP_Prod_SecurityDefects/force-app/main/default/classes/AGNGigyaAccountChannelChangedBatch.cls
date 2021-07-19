global class AGNGigyaAccountChannelChangedBatch implements Database.Batchable<AGNGigyaAccountChannelChangedVariables>, Database.AllowsCallouts, Database.Stateful {
	private Integer totalCount = 0;
	private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
	private List<AGNGigyaAccountChannelChangedVariables> accountVars = new List<AGNGigyaAccountChannelChangedVariables>();

	public AGNGigyaAccountChannelChangedBatch(List<AGNGigyaAccountChannelChangedVariables> vars) {
		if (vars != null) {
			this.accountVars = vars;
		}
	}

	public List<AGNGigyaAccountChannelChangedVariables> start(Database.BatchableContext batchableContext){
		Set<Id> accountIds = new Set<Id>();

		for (AGNGigyaAccountChannelChangedVariables accountVar : accountVars) {
			accountIds.add(accountVar.accountId);
		}

		Map<String, Account> validAccountMap = new Map<String, Account>([SELECT Id
		FROM Account
		WHERE Id IN :accountIds
		AND Privacy_Law_Status_AGN__c = false
		]);

		Set<String> validAccountIds = validAccountMap.keySet();
		List<AGNGigyaAccountChannelChangedVariables> newAccountVars = new List<AGNGigyaAccountChannelChangedVariables>();
		for (AGNGigyaAccountChannelChangedVariables accountVar : accountVars) {
			if (validAccountIds.contains(accountVar.accountId)) {
				newAccountVars.add(accountVar);
			}
		}
		return newAccountVars;
	}

	public void execute(Database.BatchableContext batchableContext, List<AGNGigyaAccountChannelChangedVariables> accountVars) {
		totalCount = totalCount + accountVars.size();
		for (AGNGigyaAccountChannelChangedVariables var : accountVars) {
			try {
				if (AGNGigyaRESTHelper.isEmptyString(var.oldChannel) && AGNGigyaRESTHelper.isEmptyString(var.newChannel)) {
					continue;
				}
				if (AGNGigyaRESTHelper.isEmptyString(var.oldChannel)) {
				} else if (AGNGigyaRESTHelper.isEmptyString(var.newChannel)) {
					channelDeleted(var.isEmailBased, var.accountId, var.oldChannel);
				} else if (!var.oldChannel.equals(var.newChannel)) {
					channelUpdated(var.isEmailBased, var.accountId, var.oldChannel, var.newChannel);
				}
			} catch(AGNGigyaValidationException e) {
				e.errorDetail = e.errorDetail + '|account: ' + var.accountId + '|oldChannel: ' + var.oldChannel + '|newChannel: ' + var.newChannel;
				validationExceptions.add(e);
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

	private static void channelDeleted(Boolean isEmailBased, String accountId, String channel) {
		if (isEmailBased) {
			new AGNGigyaSubscriptionFactory().channelDeleted(accountId, channel);
		} else {
			new AGNGigyaPreferenceFactory().channelDeleted(accountId, channel);
		}
	}

	private static void channelUpdated(Boolean isEmailBased, String accountId, String oldChannel, String newChannel) {
		if (isEmailBased) {
			new AGNGigyaSubscriptionFactory().channelUpdated(accountId, oldChannel, newChannel);
		} else {
			new AGNGigyaPreferenceFactory().channelUpdated(accountId, oldChannel, newChannel);
		}
	}
}