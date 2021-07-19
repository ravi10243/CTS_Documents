public class AGNMergeChildObjBatchSchedule implements Schedulable{
    public void execute(SchedulableContext SC) {
        AGN_UpdateMergeChildobj mcBatch = new AGN_UpdateMergeChildobj();
        database.executeBatch(mcBatch,1);  
    }
}