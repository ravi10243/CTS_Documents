/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant
* @Name           AGN_TSF_Insert_Delete_schedule
* @version        1.0
* @created        2020-09-28
* @modified       2020-09-28
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes        
*/
global class AGN_TSF_Insert_Delete_schedule implements Schedulable {
	global void execute(SchedulableContext sc)
    {  
        AGN_TSF_Insert b = new AGN_TSF_Insert();
        database.executebatch(b,50);
    }
}