global class AGN_VeevaMergeScheduler implements schedulable{
    global void execute(Schedulablecontext sc)
    {
        AGN_VeevaMergeJob mergeObj	= new AGN_VeevaMergeJob();
        Database.executeBatch(mergeObj,200);
    }
}