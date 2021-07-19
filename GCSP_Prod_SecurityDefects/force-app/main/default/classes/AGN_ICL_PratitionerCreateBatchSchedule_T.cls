@isTest
public class AGN_ICL_PratitionerCreateBatchSchedule_T {

    static testmethod void method1()
    {
        Test.startTest();

     AGN_ICL_PratitionerCreateBatchSchedule sh1 = new AGN_ICL_PratitionerCreateBatchSchedule();

     String sch = '0 0 2 * * ?';

     system.schedule('Test Territory Check', sch, sh1);

        Test.stopTest();
    }
}