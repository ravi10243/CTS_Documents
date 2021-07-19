public class AGN_Meeting_MassUpdate_CostController {
    
    public Meeting_Cost_AGN__c cost{get; set;}
    public String currentRecordId {get;set;}
    public PageReference prevPage;
    public pagereference p;
    
    List<Meeting_Cost_AGN__c> meetingCostList = new List<Meeting_Cost_AGN__c>();
    
    
    public AGN_Meeting_MassUpdate_CostController(ApexPages.StandardSetController controller1) {
        
        cost = new Meeting_Cost_AGN__c();
        currentRecordId = apexpages.currentpage().getparameters().get('id');
        System.debug('Current Record ID:'+currentRecordId);
        
    }
    
    public PageReference update1()
    {
        Integer recordCount =0;
        
        try
        {
            meetingCostList = [Select Id,Actual_Cost_AGN__c,Planned_Cost_AGN__c,Cost_Category__c from Meeting_Cost_AGN__c where Medical_Event_AGN__c =:currentRecordId AND Cost_Category__c =:cost.Cost_Category__c];
            
            if(meetingCostList.size()!=0)
            {
                if(cost.Cost_Category__c!= Null && (cost.Actual_Cost_AGN__c!= Null || cost.Planned_Cost_AGN__c != Null))
                {
                    if(cost.Actual_Cost_AGN__c != Null && cost.Planned_Cost_AGN__c == Null)
                    {
                        
                        for(Meeting_Cost_AGN__c costTemp : meetingCostList)
                        {
                            
                            costTemp.Actual_Cost_AGN__c = cost.Actual_Cost_AGN__c;
                            
                        }
                    }
                    else if(cost.Planned_Cost_AGN__c != Null && cost.Actual_Cost_AGN__c == Null)
                    {
                        for(Meeting_Cost_AGN__c costTemp : meetingCostList)
                        {
                            
                            costTemp.Planned_Cost_AGN__c =cost.Planned_Cost_AGN__c;
                            
                        }
                        
                    }
                    else
                    {
                        for(Meeting_Cost_AGN__c costTemp : meetingCostList)
                        {
                            
                            costTemp.Actual_Cost_AGN__c = cost.Actual_Cost_AGN__c;
                            costTemp.Planned_Cost_AGN__c =cost.Planned_Cost_AGN__c;
                            
                        }
                    }
                    
                    List<Database.SaveResult> results = Database.update(meetingCostList, false);
                    
                    for (Database.SaveResult result : results) {
                        if(result.isSuccess() == true)
                        {
                            recordCount++ ;
                        }
                    }
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,recordCount+' '+System.Label.AGN_Record_count_sub_sentence+' '+meetingCostList.size()+' '+System.Label.AGN_Update_Successful));                
                }
                else
                {
                    System.debug('I am inside else');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.AGN_Proper_Choice_Alert));
                    return null;
                }
                
            }
            
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.AGN_No_Cost_Catagory_Alert));
                
            }
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.AGN_Exception_Alert+ e));
            return null;
        }
        
        System.debug('Cost List: '+meetingCostList);
        System.debug('Actual Cost: '+cost.Actual_Cost_AGN__c);
        System.debug('Planned Cost: '+cost.Planned_Cost_AGN__c);
        
        return null; 
        
    }
    
 /*   public PageReference goBack(){
                System.debug('I am inside');

       /* PageReference pg = new PageReference(System.Label.AGN_Prev_Page_URL+currentRecordId);
        System.debug('Prev Page URL: '+System.Label.AGN_Prev_Page_URL+currentRecordId);
        pg.setRedirect(true);
        return pg; 
        return null;
    }  */
    
}