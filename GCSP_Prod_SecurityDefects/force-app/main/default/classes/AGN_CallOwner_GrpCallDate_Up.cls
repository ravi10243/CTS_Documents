global class AGN_CallOwner_GrpCallDate_Up implements Schedulable{

    /* Cognizant: Release10 : 24/02/2017 - This class copies ownerId value from owner field to Call_Owner_AGN field in Call object, for BCs calls.
                             Once the field is populated, any further change to the ownerId field  */
    
        global void execute(SchedulableContext sc) {
            string clsId;
            set<string> inProgress = new set<string>{'Preparing','Processing'};
            list<ApexClass> cls = [Select Id from ApexClass Where Name='AGN_CallOwner_GrpCallDate_Up' Limit 1];
            if(cls!= null)
            clsId= cls[0].id;        
            list<AsyncApexJob> apexJob= [SELECT Id,
                                                Status, 
                                                ApexClassID 
                                           FROM AsyncApexJob 
                                          WHERE (ApexClassID =:clsId AND Status IN :inProgress )];
            
            if (apexJob.size()<=1){
            
            //////////////////////// Call Owner Update //////////////////////////////
            
            List<Call2_vod__c> BC_CallList = new List<Call2_vod__c>();  
            List<Call2_vod__c> CallOwnerList = new List<Call2_vod__c>();
            
            BC_CallList = [SELECT Id, OwnerId, Call_Owner_AGN__c, Service_Delivered_AGN__c,Override_Lock_vod__c, Contract_Exhibit__c FROM Call2_vod__c
                           WHERE Call_Owner_AGN__c='' AND Service_Delivered_AGN__c !='' AND Is_Parent_Call_vod__c = 1 
                           AND ((((Contract_Exhibit__r.Suspend__c = false AND Contract_Exhibit__r.Exhibit_Status__c ='Hours Completed' AND 
                                   Contract_Exhibit__r.Allow_post_expiry_Call_Reports__c = TRUE) OR (Contract_Exhibit__r.Suspend__c = false AND 
                                   Contract_Exhibit__r.Exhibit_Status__c ='Live - Customer Signed')) and contract_exhibit__c!='') Or
                                   (contract_exhibit__c='')) LIMIT 100];
            
            if (BC_CallList.size()>0) {
                for(Call2_vod__c m : BC_CallList) {            
                    
                       if (m.Call_Owner_AGN__c != m.OwnerId) {
                            if(Schema.sObjectType.Call2_vod__c.fields.Call_Owner_AGN__c.isUpdateable()){     // swar cc      
                                m.Call_Owner_AGN__c = m.OwnerId;
                            }
                            if(Schema.sObjectType.Call2_vod__c.fields.Override_Lock_vod__c.isUpdateable()){   // swar cc 
                                m.Override_Lock_vod__c = true;                    
                            }
                            CallOwnerList.add(m);                
                        }
                    } 
                    system.debug('Updated Call record count .....'+CallOwnerList.size());
                    if(Schema.sObjectType.Call2_vod__c.isUpdateable()){ // swar cc
                        update CallOwnerList;            
                    }
                }
            }
            //////////////////////// Group Call - Attendee Call Date update //////////////////////////////
            
            AGN_Settings__c orgVal = AGN_Settings__c.getOrgDefaults();
            List<Call2_vod__c> Parent_Calls = new List<Call2_vod__c>();
            List<Call2_vod__c> Child_Calls = new List<Call2_vod__c>();
            Map<Id,List<Call2_vod__c>> mapParent_Child = new Map<Id,List<Call2_vod__c>>();
            Datetime startDate = datetime.now();
            
            if (orgVal.Start_Time_CallDt_Update_AGN__c == null) 
                Parent_Calls = [SELECT Id, Name, Call_Type_AGN__c, Is_Parent_Call_vod__c, Status_vod__c, Call_Date_vod__c,Call_Datetime_vod__c, Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c 
                            FROM Call2_vod__c 
                            WHERE Status_vod__c = 'Submitted_vod' AND Call_Type_AGN__c = 'Group Call' AND Is_Parent_Call_vod__c = 1.0];
        
            else
                Parent_Calls = [SELECT Id, Name, Call_Type_AGN__c, Is_Parent_Call_vod__c, Status_vod__c, Call_Date_vod__c,Call_Datetime_vod__c, Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c 
                            FROM Call2_vod__c 
                               WHERE Status_vod__c = 'Submitted_vod' AND Call_Type_AGN__c = 'Group Call' AND Is_Parent_Call_vod__c = 1.0
                               AND (LastModifiedDate>= :orgVal.Start_Time_CallDt_Update_AGN__c )];
                               //AND LastModifiedDate<: startDate)];   
                               
            
            /*Child_Calls = [Select Id, Parent_Call_vod__c, Is_Parent_Call_vod__c, Call_Datetime_vod__c, Call_Date_vod__c,Override_Lock_vod__c
                            FROM Call2_vod__c
                            WHERE Status_vod__c = 'Submitted_vod' AND Call_Type_AGN__c = 'Group Call' AND Is_Parent_Call_vod__c = 0.0];*/
                
                
            if(Parent_Calls.size()>0) {  
                 
                Set<Id> ParentIds = new Set<Id>();
                for (Call2_vod__c c : Parent_Calls)
                {
                    ParentIds.add(c.Id);    
                }
                system.debug('Parent Calls...'+ParentIds);
             
                Child_Calls = [Select Id, Parent_Call_vod__c, Is_Parent_Call_vod__c, Call_Datetime_vod__c, Call_Date_vod__c,Override_Lock_vod__c
                            FROM Call2_vod__c
                            WHERE Status_vod__c = 'Submitted_vod' AND Call_Type_AGN__c = 'Group Call' AND Is_Parent_Call_vod__c = 0.0
                                    AND Parent_Call_vod__c IN :ParentIds];
                 
                if(Child_Calls.size()>0) {
                    for (Call2_vod__c c : Child_Calls)
                    {
                        if (mapParent_Child.containsKey(c.Parent_Call_vod__c)) {
                            mapParent_Child.get(c.Parent_Call_vod__c).add(c);
                        }
                        else {
                            mapParent_Child.put(c.Parent_Call_vod__c, new  List <Call2_vod__c> {c});
                        }
                    }
                }
                
                List<Call2_vod__c> UpchildCls =  new List<Call2_vod__c>();
                for (Call2_vod__c pcl : Parent_Calls)
                {
                    
                    String country = pcl.Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c;
                    //system.debug('Call...'+pcl.Id+'...account country code...'+country);
                    
                    if(orgVal.Group_Child_Call_Date_Sync__c.contains(country))
                    {
                        Boolean check = false;
                        Date pDt = date.newinstance(pcl.Call_Datetime_vod__c.year(), pcl.Call_Datetime_vod__c.month(), pcl.Call_Datetime_vod__c.day());
                        List<Call2_vod__c> childCls = new List<Call2_vod__c>();
                        if(mapParent_Child.get(pcl.Id)!= NULL)
                            childCls =  mapParent_Child.get(pcl.Id);
                        
                        if (childCls.size()>0){
                            for (Call2_vod__c ccl : childCls)
                            {   
                               Date cDt = date.newinstance(ccl.Call_Datetime_vod__c.year(), ccl.Call_Datetime_vod__c.month(), ccl.Call_Datetime_vod__c.day()); 
                               if (cDt <> pDt) {
                                   check = true;
                                   break;
                               }                   
                            }
                        }
                        if (check == true) {
                            for (Call2_vod__c ccl : childCls){
                                if(Schema.sObjectType.Call2_vod__c.fields.Call_Datetime_vod__c.isUpdateable()){    // swar cc  
                                    ccl.Call_Datetime_vod__c = pcl.Call_Datetime_vod__c;
                                 }
                                 if(Schema.sObjectType.Call2_vod__c.fields.Call_Date_vod__c.isUpdateable()){    // swar cc  
                                    ccl.Call_Date_vod__c = pcl.Call_Date_vod__c;
                                 }
                                 if(Schema.sObjectType.Call2_vod__c.fields.Override_Lock_vod__c.isUpdateable()){    // swar cc  
                                    ccl.Override_Lock_vod__c = True;
                                 }
                                 UpchildCls.add(ccl);
                            }
                        }   
                    }
                }
                system.debug('Updated Calls...'+UpchildCls.size());
                if(Schema.sObjectType.Call2_vod__c.isUpdateable()){    // swar cc  
                    update UpchildCls;
                }
                
                if(Schema.sObjectType.AGN_Settings__c.fields.Start_Time_CallDt_Update_AGN__c .isUpdateable()){    // swar cc  
                    orgVal.Start_Time_CallDt_Update_AGN__c = startDate;
                }
                
                if(Schema.sObjectType.AGN_Settings__c.isUpdateable()){ // swar cc  
                    update orgVal;
                }
               
           }
        
        }
                
    }