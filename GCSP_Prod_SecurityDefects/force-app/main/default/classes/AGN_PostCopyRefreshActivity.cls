/**
* The Refresh activity program will handle all the jobs
* responsible for post refresh activities in a sequential manner one after another.
*
* @author  Amit Das
* @version 1.0
* @since   2020-07-27 
*/
public class AGN_PostCopyRefreshActivity {
 //initiate the first batch
    public void startJobs(){
        //System.debug('Is Running in sandbox -- '+runningInASandbox());
        if(this.runningInASandbox()){
            AGN_Post_Copy_Util.clearJobRecordsReferences();
            AGN_BatchJobProcess_Queue queueJob = new AGN_BatchJobProcess_Queue(true);
            database.executeBatch(queueJob , 30);
        }
        
    }
    
    
    public boolean runningInASandbox() {
        boolean isRunningInSandBox = false;
        isRunningInSandBox = (Boolean)[SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        return isRunningInSandBox;
    } 
  
}