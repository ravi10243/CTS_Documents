global class AGN_MIR_Task_Create implements Database.Batchable<SObject>{
//Database.executeBatch(new AGN_MIR_Task_Create(), 200);
  
  
   global Database.QueryLocator start(Database.BatchableContext bc) {
        Date dToday= system.today()-7;  
        Date dTom= system.today()-6;
        DateTime StartTime = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
        DateTime EndTime = datetime.newInstance(dTom.year(), dTom.month(),dTom.day());
                  
           return Database.getQueryLocator(
                [SELECT Id, Status_vod__c, CreatedDate, CreatedById, Country_Code__c FROM Medical_Inquiry_vod__c WHERE  Status_vod__c = 'Saved_vod' 
                      AND CreatedDate >=:StartTime AND CreatedDate <:EndTime] ); 
    }
    
    
   global void execute(Database.BatchableContext BC, List<Medical_Inquiry_vod__c> scope){
   
       AGN_Settings__c settings = AGN_Settings__c.getOrgDefaults();
       String mirTsk_Country = settings.MIR_Task_Creation_AGN__c;
       List<Medical_Inquiry_vod__c> l_mir = new List<Medical_Inquiry_vod__c>(); 
        
        for(Medical_Inquiry_vod__c mir_rec : scope){
        
            if(mirTsk_Country.contains(mir_rec.Country_Code__c))
                l_mir.add(mir_rec);
              
            //tasks.put(taskList.id, (Task)taskList);
        }
        
        List<Task> mirTask = new List<Task>();
        for(Medical_Inquiry_vod__c mrec: l_mir){
        
            Task tsk = new Task();
            if(Schema.sObjectType.Task.fields.ActivityDate.isCreateable())   // AKJ cc	
            {
                tsk.ActivityDate = System.Today();
            }
            if(Schema.sObjectType.Task.fields.OwnerId.isCreateable())   // AKJ cc
            {
                tsk.OwnerId = mrec.CreatedById;
            }
            	
            if(Schema.sObjectType.Task.fields.Priority.isCreateable())   // AKJ cc
            {
                tsk.Priority = 'Normal';
            }
            if(Schema.sObjectType.Task.fields.Status.isCreateable())   // AKJ cc
            {
                tsk.Status = 'Not Started';
            }
            if(Schema.sObjectType.Task.fields.Subject.isCreateable())  // AKJ cc
            {
                tsk.Subject = 'Submit MIR Urgently';
            }
            if(Schema.sObjectType.Task.fields.WhatId.isCreateable())  // AKJ cc
            {
                tsk.WhatId = mrec.Id;
            }
            	
            
            mirTask.add(tsk);
            System.debug('MIR...'+tsk.WhatId);
        }
        if(Schema.sObjectType.Task.isCreateable())  // AKJ cc
        {
            insert mirTask;
        }
        System.debug('Task...'+mirTask);
   }
   
   global void finish(Database.BatchableContext BC){
   }
   

}