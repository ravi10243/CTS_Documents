@istest
public class AGN_AMI_UserErrorLog_Test {
   
    static testmethod void testQueueable_AGN_AMI_UserError() {
        integer i=5;
        try{
          i = i/0  ; 
        }
        Catch(Exception ex){
            String errorCode = 'createCustomerUser';
            String className ='AGN_AMI_Utility_class';
            String status ='open';
            AGN_AMI_UserErrorLog userErrorLog = new AGN_AMI_UserErrorLog(ex,errorCode,className,status);
            Test.startTest();   
            System.enqueueJob(userErrorLog);
            Test.stopTest();
        }
        
    }
    
}