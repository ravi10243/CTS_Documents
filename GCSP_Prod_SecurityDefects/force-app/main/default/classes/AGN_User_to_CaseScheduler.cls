/*
*------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev Roushan
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        2.0
* @created        
* @modified      24 March 2020
* @testClass      
* ----------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Feb-2020      
* Apex Scheduler class added for Req No: 121, Scheduler to class AGN_User_To_Case_Batch
*-------------------------------------------------------------------------------------------------------------------------+
*/
global class AGN_User_to_CaseScheduler implements Schedulable 
{
    global void execute(SchedulableContext sc)
    {
        AGN_User_To_Case_Batch b = new AGN_User_To_Case_Batch();
        database.executebatch(b,50);
    }
}