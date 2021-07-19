public class AGN_ICL_SchedulePractitionerDelBatch implements Schedulable{
    public void execute(SchedulableContext SC) {
        AGN_ICL_PractitionerAutoDelete_Batch tempBatch = new AGN_ICL_PractitionerAutoDelete_Batch();
        database.executebatch(tempBatch,200);
    }
}