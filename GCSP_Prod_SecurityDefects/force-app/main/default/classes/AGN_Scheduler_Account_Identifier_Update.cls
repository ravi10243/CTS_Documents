/**
***** @author- Akash
***** @date- 26/June/2019
***** @Release- 19R2 PMO2205
***** @Description- Apex Scheduler created in order to schedule the account identifier batch class to run on specific time.
**/ 
global class AGN_Scheduler_Account_Identifier_Update implements Schedulable{
    global void execute(SchedulableContext sc){
        AGN_Batch_Account_Identifier_Update batchObj = new AGN_Batch_Account_Identifier_Update();
        Database.executeBatch(batchObj);
    }
}