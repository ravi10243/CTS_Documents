public class AGN_Post_Copy_Util {
    
    public static void insertJobRecord(Id value){
        AGN_Post_Refresh_BatchJob__c job = new AGN_Post_Refresh_BatchJob__c();
        job.JobId__c = String.valueOf(value);
        try{
          insert job;    
        }
        Catch(DmlException e){
            System.debug('Insert job operation has failed '+e.getMessage());
        }
        
    }
    public static void clearJobRecordsReferences(){
        try{
             List<AGN_Post_Refresh_BatchJob__c> toDel = new List<AGN_Post_Refresh_BatchJob__c>();
             toDel = [select id from AGN_Post_Refresh_BatchJob__c];
             delete toDel;
           }
           Catch(DMLException e){
               System.debug('DML operation failed while job records deleted '+ e.getMessage());    
           }
    }
    
    public static void sendJobStatusReportEmail(){
         List<AGN_Post_Refresh_BatchJob__c> jobsInfo = [Select JobId__c from AGN_Post_Refresh_BatchJob__c];
		 List<String> jobIds = new List<String>();
         for(AGN_Post_Refresh_BatchJob__c jobInfo : jobsInfo){
            jobIds.add(jobInfo.JobId__c);
         }
         /*jobIds.add('7073N00000Y535jQAB');
         jobIds.add('7073N00000XNMgJQAX');*/
         List<AsyncApexJob> apexJobs = [SELECT  ExtendedStatus,Id ,Status,ApexClass.Name, MethodName,NumberOfErrors,JobType, JobItemsProcessed, TotalJobItems, CreatedById,CreatedBy.Name,CreatedBy.Email,CreatedDate   
	                             FROM AsyncApexJob where Id in : jobIds   
	                             ];

		 System.debug('Apex Jobs --' +apexJobs);
         
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          String[] toAddress = new String[] {'DL-InternationApplicationSupport@allergan.com'};
          //system.debug('apexJob.CreatedBy.Email : '+apexJob.CreatedBy.Email);
          mail.setToAddresses(toAddress);
          mail.setSubject('Apex Job status report ');
          mail.setHtmlBody(AGN_Post_Copy_Util.getHtmlBody(apexJobs));
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         
    }
    
    public static String getHtmlBody(List<AsyncApexJob> jobsInfo){
        String htmlBody = '';
        htmlBody = '<table border="1" style="border-collapse: collapse"><caption>Batch Jobs Reports</caption><tr><th>Job Name</th><th>Status</th><th>Items Processed</th><th>Error Log</th><th>Owner</th></tr>';
        //iterate over list and output columns/data into table rows...
    	for(AsyncApexJob job : jobsInfo){
			String errorMsg = job.ExtendedStatus; if(job.ExtendedStatus == null){errorMsg = '[No error found.]';}
			htmlBody += '<tr><td>' + job.ApexClass.Name + '</td><td>' + job.Status + '</td><td>'+job.JobItemsProcessed+'</td><td>'+errorMsg+'</td><td>'+job.CreatedBy.Name+'</td></tr>';
        }
        htmlBody += '</table>';
        return htmlBody;
        
    }
    
}