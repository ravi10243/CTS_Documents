global class AGN_CExhibitSignerNotificationSched implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AGN_CExhibitSignerNotificationBatch(), 100);
    }
}