global class AGN_CallOwnerPopulate implements Schedulable{

    /* Code review fix in progress -Swarnendu */
    
    /* Cognizant: Release10 : 24/02/2017 - This class copies ownerId value from owner field to Call_Owner_AGN field in Call object, for BCs calls.
                             Once the field is populated, any further change to the ownerId field  */
    
        global void execute(SchedulableContext sc) {
            string clsId;
            set<string> inProgress = new set<string>{'Preparing','Processing'};
            list<ApexClass> cls = [Select Id from ApexClass Where Name='AGN_CallOwnerPopulate' Limit 1];
            if(cls!= null)
            clsId= cls[0].id;        
            list<AsyncApexJob> apexJob= [SELECT Id,
                                                Status, 
                                                ApexClassID 
                                           FROM AsyncApexJob 
                                          WHERE (ApexClassID =:clsId AND Status IN :inProgress )];
            
            if (apexJob.size()<=1){
            
            List<Call2_vod__c> BC_CallList = new List<Call2_vod__c>();  
            List<Call2_vod__c> CallOwnerList = new List<Call2_vod__c>();
            
            BC_CallList = [SELECT Id, OwnerId, Call_Owner_AGN__c, Service_Delivered_AGN__c,Override_Lock_vod__c, Contract_Exhibit__c FROM Call2_vod__c
                           WHERE Call_Owner_AGN__c='' AND Service_Delivered_AGN__c !='' AND Is_Parent_Call_vod__c = 1 
                           AND ((((Contract_Exhibit__r.Suspend__c = false AND Contract_Exhibit__r.Exhibit_Status__c ='Hours Completed' AND 
                                   Contract_Exhibit__r.Allow_post_expiry_Call_Reports__c = TRUE) OR (Contract_Exhibit__r.Suspend__c = false AND 
                                   Contract_Exhibit__r.Exhibit_Status__c ='Live - Customer Signed')) and contract_exhibit__c!='') Or
                                   (contract_exhibit__c='')) LIMIT 100];
            
            
            for(Call2_vod__c m : BC_CallList) {            
                
                   if (m.Call_Owner_AGN__c != m.OwnerId) {
                        if(Schema.sObjectType.Call2_vod__c.fields.Call_Owner_AGN__c.isUpdateable()){ // swar cc
                            m.Call_Owner_AGN__c = m.OwnerId;
                        }    
                        if(Schema.sObjectType.Call2_vod__c.fields.Override_Lock_vod__c.isUpdateable()){// swar cc
                            m.Override_Lock_vod__c = true; 
                        } 
                                           
                        CallOwnerList.add(m);                
                    }
                } 
                if(Schema.sObjectType.Call2_vod__c.isUpdateable()){
                	update CallOwnerList;       
                }
            }
        }
        
                 
    }