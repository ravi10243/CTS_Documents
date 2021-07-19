global class AGNGigyaAccountUpdateIntegrationSched implements Schedulable {
    global void execute(SchedulableContext sc) {
        AGNGigyaAccountUpdateIntegrationBatch b = new AGNGigyaAccountUpdateIntegrationBatch();
        Database.executebatch(b, 9);
    }
}