global class AGN_UpdateTaskStatus implements Database.Batchable<SObject>{
//Database.executeBatch(new AGN_UpdateTaskStatus(), 200);
  
  
   global Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator(
                [SELECT Id,OwnerId,Status,WhatId FROM Task WHERE Status != 'Completed' AND WhatId != Null]
            );
    }
    
    
   global void execute(Database.BatchableContext BC, List<Task> scope){
   
       Map<ID,Task> tasks = new Map<ID, Task>();
        //Task ID , object
        for(Task taskList : scope){
            tasks.put(taskList.id, (Task)taskList);
        }
        
        
        list<Task> Meeting_Task = new list<Task>();
        list<Task> ToT_Task = new list<Task>();
        list<Id> Meetings = new list<Id>();
        list<Id> TOTs = new list<Id>();
        for (Task taskList : scope){
            //Parent Object is Meeting
            if(taskList.WhatId.getSobjectType() == Medical_Event_vod__c.SobjectType)
            {
               Meetings.add(tasklist.WhatId);
            }
            //Parent Object is TOT
            if(taskList.WhatId.getSobjectType() == Time_Off_Territory_vod__c.SobjectType)
            {
                ToTs.add(tasklist.WhatId);
                system.debug('All tot...'+tasklist.WhatId);
            }
        }
        
        system.debug('All tot'+ToTs);
        Meeting_Task = [SELECT Id,OwnerId,Status,WhatId
                      FROM Task WHERE WhatId IN (SELECT Id FROM Medical_Event_vod__c WHERE ID = :Meetings 
                      AND Status_AGN__c IN ('Pending Approval','Pending Line Manager Approval','Approved'))];
        for (Task taskList2 : Meeting_Task){
              taskList2.Status = 'Completed';
         }
         
         ToT_Task = [SELECT Id,OwnerId,Status,WhatId
                      FROM Task WHERE WhatId IN (SELECT Id FROM Time_Off_Territory_vod__c WHERE ID = :ToTs AND STATUS_VOD__C IN ('Pending','Approved','Rejected'))];
        for (Task taskList3 : ToT_Task){
              taskList3.Status = 'Completed';
         }
        
        
        system.debug('Tasks tot'+ToT_Task);
         update Meeting_Task;
         update ToT_Task;
   }
   
   global void finish(Database.BatchableContext BC){
   }
   

}