/* AGN_Training_Program_Batch_Process
* Created Date: 8 December 2015
* Purpose: Created as a part of Core Release R003
* Batch process to calculate target completion of Training Programs
* 19 February 2016: Modified as a part of Core Release R005
* Purpose: Included new method to insert Training Attendee Product records
*/

global without sharing class AGN_Training_Program_Batch_Process implements Database.Batchable<sObject>, Schedulable{
    
    global string query;
    global Date meetingStartDate;
    global Date meetingEndDate;
    
    global AGN_Training_Program_Batch_Process(){
        String status = 'Completed';
        query = 'SELECT Id, Training_Program_AGN__c, Status_AGN__c, Program_Target_Calculated_AGN__c, OwnerId, Start_Date_vod__c, Start_Time_vod__c, End_Date_vod__c, End_Time_vod__c, Country_Code__c' +
            ' FROM Medical_Event_vod__c WHERE Program_Target_Calculated_AGN__c = FALSE AND Status_AGN__c = \'' + String.escapeSingleQuotes(status) + '\'' +
            ' AND Training_Program_AGN__c != null';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){        
        system.debug('@@ Query: '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Medical_Event_vod__c> scope){
        
        List<Medical_Event_vod__c> meetingsToUpdate = new List<Medical_Event_vod__c>();
        String updProgram;
        String updProgramAllocation;
        String insProgramTarget;
        String insTrainingAttendeeProducts;
        SavePoint sp;
        
        for(Medical_Event_vod__c meeting : scope){            
            
            if(meeting.Start_Date_vod__c != null){
                meetingStartDate = meeting.Start_Date_vod__c;
            }
            else{
                meetingStartDate = meeting.Start_Time_vod__c.Date();
            }
            if(meeting.End_Date_vod__c != null){
                meetingEndDate = meeting.End_Date_vod__c;
            }    
            else{
                meetingEndDate = meeting.End_Time_vod__c.Date();
            }
            system.debug('$$$$$$$ meetingStartDate: '+meetingStartDate + '       meetingEndDate: ' + meetingEndDate);            
            
            
            List<Event_Attendee_vod__c> meetingAttendee = new List<Event_Attendee_vod__c>();
            meetingAttendee = [select Id, Medical_Event_vod__c, Account_vod__c, User_vod__c, Status_vod__c from Event_Attendee_vod__c 
                               where Medical_Event_vod__c = :meeting.Id 
                               AND (Status_vod__c = 'Attended' OR Status_vod__c = 'Signed_vod')
                               AND Account_vod__c != null
                               AND User_vod__c = null
                              ];
            
            if(meetingAttendee.size() > 0 || meetingAttendee != null){
                sp = Database.setSavepoint();
                updProgram = calculateProgramTargetAchieved(meeting, meetingAttendee);            
                if(updProgram == 'SUCCESS'){
                    updProgramAllocation = calculateProgramAllocationTargetAchieved(meeting, meetingAttendee);                
                    insProgramTarget = createProgramTarget(meeting, meetingAttendee);
                    // 19Feb2016: New line of code for Core Release R005
                    insTrainingAttendeeProducts = createTrainingAttendeeProduct(meeting);
                    // 19Feb2016: End of new line of code
                }
                
                system.debug('@@@ updProgram: '+updProgram+'   updProgramAllocation: '+updProgramAllocation+'   insProgramTarget:'+insProgramTarget+'   insTrainingAttendeeProducts: '+insTrainingAttendeeProducts);
                
                if (updProgram == 'SUCCESS' && updProgramAllocation == 'SUCCESS' && 
                    insProgramTarget == 'SUCCESS' && insTrainingAttendeeProducts == 'SUCCESS'){
                        if (Schema.sObjectType.Medical_Event_vod__c.fields.Program_Target_Calculated_AGN__c.isUpdateable()){  //cc_AD
                            meeting.Program_Target_Calculated_AGN__c = TRUE;
                        }     
                       
                    meetingsToUpdate.add(meeting);
                    sp = null;
                        
                }else{
                    Database.rollback(sp);
                    continue;
                }
            }
        }
        try{
            if(Schema.SObjectType.Medical_Event_vod__c.isUpdateable()){  //cc_AD
               Database.update(meetingsToUpdate);
            }
        }catch(System.DmlException e){
            system.debug('Exception while updating Program Target Calculated boolean in Meeting Record. Exception: '+ e);
        }        
    }
    
    global void execute(SchedulableContext SC){
        AGN_Training_Program_Batch_Process trainingBatch = new AGN_Training_Program_Batch_Process();
        Database.executeBatch(trainingBatch, 10);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    //Method to calculate Target achieved actual in Training Program record
    global String calculateProgramTargetAchieved(Medical_Event_vod__c meeting, List<Event_Attendee_vod__c> meetingAttendee){
        system.debug('@@@ calculateProgramTargetAchieved');
        String saveResult;
        Training_Program_AGN__c tProgram = [select Id, Name, Target_Achieved_Actual_AGN__c, Total_Target_AGN__c
                                            FROM Training_Program_AGN__c where Id = :meeting.Training_Program_AGN__c
                                            limit 1];
        if(tProgram.Target_Achieved_Actual_AGN__c != null){
            if (Schema.sObjectType.Training_Program_AGN__c.fields.Target_Achieved_Actual_AGN__c.isUpdateable()){  //cc_AD
               tProgram.Target_Achieved_Actual_AGN__c = tProgram.Target_Achieved_Actual_AGN__c + meetingAttendee.size();
            }    
         }
        
        else{
            if (Schema.sObjectType.Training_Program_AGN__c.fields.Target_Achieved_Actual_AGN__c.isUpdateable()){  //cc_AD
                tProgram.Target_Achieved_Actual_AGN__c = meetingAttendee.size();
            }    
        }
            
        
        try{
            if(Schema.SObjectType.Training_Program_AGN__c.isUpdateable()){  //cc_AD
                Database.SaveResult sr = Database.update(tProgram);
                if(sr.isSuccess()){
                    saveResult = 'SUCCESS';
                }    
                else{
                    saveResult = 'FAILED';
                }    
            }
        }catch(System.DmlException e){
            system.debug('Exception while updating Target Achieved in Training Program record ('+tProgram.Name+'). Exception: '+ e);
            saveResult = 'FAILED';
        }      
        return saveResult;        
    }
    
    //Method to calculate Target achieved actual in Program Target Allocation record
    global String calculateProgramAllocationTargetAchieved(Medical_Event_vod__c meeting, List<Event_Attendee_vod__c> meetingAttendee){
        system.debug('@@@ calculateProgramAllocationTargetAchieved');
        String saveResult;      
        List<Program_Target_Allocation_AGN__c> tAllocation = new List<Program_Target_Allocation_AGN__c>();
        List<Program_Target_Allocation_AGN__c> tAllocationToUpdate = new List<Program_Target_Allocation_AGN__c>();
        
        /*tAllocation = [SELECT Id, Allocated_User_AGN__c, Allocated_Target_AGN__c, Target_Achieved_Actual_AGN__c
                       FROM Program_Target_Allocation_AGN__c
                       WHERE Parent_Program_AGN__c = :meeting.Training_Program_AGN__c AND Allocated_User_AGN__c = :meeting.OwnerId
                       AND Start_Date_AGN__c <= :meeting.Start_Date_vod__c AND End_Date_AGN__c >= :meeting.End_Date_vod__c
                      ];*/
        
        tAllocation = [SELECT Id, Allocated_User_AGN__c, Allocated_Target_AGN__c, Target_Achieved_Actual_AGN__c
                       FROM Program_Target_Allocation_AGN__c
                       WHERE Parent_Program_AGN__c = :meeting.Training_Program_AGN__c AND Allocated_User_AGN__c = :meeting.OwnerId
                       AND Start_Date_AGN__c <= :meetingStartDate AND End_Date_AGN__c >= :meetingEndDate
                      ];
        
        if(tAllocation.size() > 0 || tAllocation != null){
            for(Program_Target_Allocation_AGN__c allocation : tAllocation){
                if(allocation.Target_Achieved_Actual_AGN__c != null){
                    if (Schema.sObjectType.Program_Target_Allocation_AGN__c.fields.Target_Achieved_Actual_AGN__c.isUpdateable()){  //cc_AD
                      allocation.Target_Achieved_Actual_AGN__c = allocation.Target_Achieved_Actual_AGN__c + meetingAttendee.size();
                     }   
                }
                else{
                    if (Schema.sObjectType.Program_Target_Allocation_AGN__c.fields.Target_Achieved_Actual_AGN__c.isUpdateable()){   //cc_AD
                        allocation.Target_Achieved_Actual_AGN__c = meetingAttendee.size();
                      }  
                }
                    
                
                tAllocationToUpdate.add(allocation);
            }
            try{
                if(Schema.SObjectType.Program_Target_Allocation_AGN__c.isUpdateable()){  //cc_AD
                    Database.update(tAllocationToUpdate);
                    saveResult = 'SUCCESS';
                }
                
            }catch(System.DmlException e){
                system.debug('Exception while updating Target Achieved in Program Allocation Record records. Exception: '+ e);
                saveResult = 'FAILED';
            }
            return saveResult;
        }else{
            saveResult = 'SUCCESS';
            return saveResult;
        }        
    }
    
    //Method to create Training Program Attendee records
    global String createProgramTarget(Medical_Event_vod__c meeting, List<Event_Attendee_vod__c> meetingAttendee){
        system.debug('@@@ createProgramTarget');
        String saveResult;
        List<Training_Program_Target_AGN__c> programTargetToInsert = new List<Training_Program_Target_AGN__c>();        
        Training_Program_Target_AGN__c pTarget = new Training_Program_Target_AGN__c();
        
        for(Event_Attendee_vod__c mAtt : meetingAttendee){            
            pTarget = new Training_Program_Target_AGN__c();
            if (Schema.sObjectType.Training_Program_Target_AGN__c.fields.Training_Program_AGN__c.isCreateable()){ //cc_AD
                pTarget.Training_Program_AGN__c = meeting.Training_Program_AGN__c;
            }    
            if (Schema.sObjectType.Training_Program_Target_AGN__c.fields.Targeted_Account_AGN__c.isCreateable()){   //cc_AD
                pTarget.Targeted_Account_AGN__c = mAtt.Account_vod__c;
            }    
            if (Schema.sObjectType.Training_Program_Target_AGN__c.fields.Program_Meeting_AGN__c.isCreateable()){  //cc_AD
                pTarget.Program_Meeting_AGN__c = meeting.Id;
            }    
            //pTarget.Meeting_Start_Date_AGN__c = meeting.Start_Date_vod__c;
            if (Schema.sObjectType.Training_Program_Target_AGN__c.fields.Meeting_Start_Date_AGN__c.isCreateable()){  //cc_AD
                pTarget.Meeting_Start_Date_AGN__c = meetingStartDate;
            }    
            //pTarget.Meeting_End_Date_AGN__c = meeting.End_Date_vod__c;
            if (Schema.sObjectType.Training_Program_Target_AGN__c.fields.Meeting_End_Date_AGN__c.isCreateable()){    //cc_AD
                pTarget.Meeting_End_Date_AGN__c = meetingEndDate;
            }    
            if (Schema.sObjectType.Training_Program_Target_AGN__c.fields.Country_Code_AGN__c.isCreateable()){   //cc_AD
                pTarget.Country_Code_AGN__c = meeting.Country_Code__c;
            }    
            programTargetToInsert.add(pTarget);
        }
        
        //Update to prevent addition of duplicate training Program target-16.08.2017
        
       list<Training_Program_Target_AGN__c> tp=[select id from Training_Program_Target_AGN__c where 
         Targeted_Account_AGN__c=: pTarget.Targeted_Account_AGN__c and Program_Meeting_AGN__c=:pTarget.Program_Meeting_AGN__c];
         if(tp.IsEmpty())
         {
                try{
                     if(Schema.sObjectType.Training_Program_Target_AGN__c.isCreateable()){ //cc_AD
                           Database.insert(programTargetToInsert);
                           saveResult = 'SUCCESS';
                     }
                 }catch(System.DmlException e){
            		system.debug('Exception while inserting Program Target records. Exception: '+ e);
            		saveResult = 'FAILED';
        }
        }//end of if
        
        return saveResult;        
    }

    /* 19Feb2016: Inserted new method createTrainingAttendeeProduct() as a part of Core Release R005 */ 
    // Method to create Training Attendee Product records for each Training Attendee and for each Training Product
    global String createTrainingAttendeeProduct(Medical_Event_vod__c meeting){
        system.debug('@@@ createTrainingAttendeeProduct');
        String saveResult;
        List<Meeting_Products_AGN__c> trainingProducts = new List<Meeting_Products_AGN__c>();
        List<Training_Program_Target_AGN__c> trainingAttendees = new List<Training_Program_Target_AGN__c>();
        List<Training_Attendee_Product_AGN__c> trngAttProductList = new List<Training_Attendee_Product_AGN__c>();
        Training_Attendee_Product_AGN__c trngAttProduct = new Training_Attendee_Product_AGN__c();
        
        trainingProducts = [select Product_AGN__c from Meeting_Products_AGN__c where Meeting_AGN__c = :meeting.Id];
        trainingAttendees = [select Id from Training_Program_Target_AGN__c where Program_Meeting_AGN__c = :meeting.Id];
        
        system.debug('@@@ createTrainingAttendeeProduct. trainingProducts: '+trainingProducts+'    trainingAttendees: '+trainingAttendees);
        
        for(Training_Program_Target_AGN__c trngAtt : trainingAttendees){
            system.debug('@@@ createTrainingAttendeeProduct. inside for trngAtt: '+trngAtt);            
            for(Meeting_Products_AGN__c trngProduct : trainingProducts){
                system.debug('@@@ createTrainingAttendeeProduct. inside for trngProduct: '+trngProduct);
                trngAttProduct = new Training_Attendee_Product_AGN__c();
                if (Schema.sObjectType.Training_Attendee_Product_AGN__c.fields.Product_AGN__c.isCreateable()){ //cc_AD
                    trngAttProduct.Product_AGN__c = trngProduct.Product_AGN__c;
                }    
                if (Schema.sObjectType.Training_Attendee_Product_AGN__c.fields.Training_Program_Attendee_AGN__c.isCreateable()){  //cc_AD
                    trngAttProduct.Training_Program_Attendee_AGN__c = trngAtt.Id;
                }    
                trngAttProductList.add(trngAttProduct);
            }
        }
        
        try{
            if(Schema.sObjectType.Training_Attendee_Product_AGN__c.isCreateable()){  //cc_AD
               Database.insert(trngAttProductList);
               saveResult = 'SUCCESS'; 
            }
                
        }catch(System.DmlException e){
            system.debug('Exception while inserting Training Attendee Product records. Exception: '+ e);
            saveResult = 'FAILED';
        }
        return saveResult; 
    }      
    /* 19Feb2016: End of changes for Core Release R005 */
    
}