global class AGN_Schedule_CopyAddressAffiliationFlag implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    AGN_Copy_address_Affiliation_flag b = new AGN_Copy_address_Affiliation_flag(); 
      database.executebatch(b);
    }
}