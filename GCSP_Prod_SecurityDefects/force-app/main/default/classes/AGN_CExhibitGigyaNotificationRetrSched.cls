global class AGN_CExhibitGigyaNotificationRetrSched implements Schedulable {
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new AGN_CExhibitGigyaNotificationRetrBatch(), 100);
	}
}