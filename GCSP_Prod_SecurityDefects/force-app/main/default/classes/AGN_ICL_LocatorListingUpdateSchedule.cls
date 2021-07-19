public class AGN_ICL_LocatorListingUpdateSchedule implements Schedulable{

    public void execute(SchedulableContext SC) {
        AGN_ICL_LocatorListingApproverUpdate updateLocateList= new AGN_ICL_LocatorListingApproverUpdate();
      database.executeBatch(updateLocateList,20);  
    }
}