public class AGN_ICL_PratitionerCreateBatchSchedule implements Schedulable{
    
    public void execute(SchedulableContext SC) {
        AGN_ICL_Practitioner_Listing_Batch  createPractitioner= new AGN_ICL_Practitioner_Listing_Batch ();
      database.executeBatch(createPractitioner,20);  
    }

}