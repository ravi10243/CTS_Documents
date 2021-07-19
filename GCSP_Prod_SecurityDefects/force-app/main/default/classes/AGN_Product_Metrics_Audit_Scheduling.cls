//******************* 31st March,2016:Cognizant: Release006: Requirement:470:*******************

global class AGN_Product_Metrics_Audit_Scheduling implements Schedulable{
   global void execute(SchedulableContext sc) {
        AGN_Product_Metrics_Audit b = new AGN_Product_Metrics_Audit();
        database.executebatch(b,10);
        AGN_Address_Audit c = new AGN_Address_Audit ();
        database.executebatch(c,10);
        AGN_Account_Audit d = new AGN_Account_Audit ();
        database.executebatch(d,10);
        AGN_Child_Account_Audit e = new AGN_child_Account_Audit ();
        database.executebatch(e,10);
    }
}