/*
* This is a handler class for Opportunity trigger.
*/
public with sharing class AGN_OpportunityTriggerHandler extends AGN_TriggerHandler {
        
  //  public override void beforeInsert() {
    //    AM_Opportunity_AGN amo = new AM_Opportunity_AGN();
      //  amo.onInsert(Trigger.new);
  //  }
  
  AGN_OpportunityRollUpOnMeeting AOROM = new AGN_OpportunityRollUpOnMeeting();
    
    public override void beforeInsert() {
        
        AGN_updateGSTQSTHandler updateGST= new AGN_updateGSTQSTHandler();
        updateGST.runTrigger(Trigger.new,null);
        
    }
    
    public override void beforeUpdate() {
        AGN_OppContactRolesHelper ocr = new AGN_OppContactRolesHelper();
        ocr.setContactAndHCPLookup(Trigger.new);

        AGN_updateGSTQSTHandler updateGST= new AGN_updateGSTQSTHandler();
        updateGST.runTrigger(Trigger.new,Trigger.oldMap);
    }
    
  public override void afterInsert() {
    //  AGN_OppLineItemsHelper li = new AGN_OppLineItemsHelper();
      //li.afterInsert(Trigger.new);  
      
      AOROM.OppRollMeetings(Trigger.new);
      
   }
    
    public override void afterUpdate() {   
            AOROM.OppRollMeetings(Trigger.new); 
            //AOROM.OppRollMeetings(Trigger.old);     
       
    }
    
    public override void afterDelete() {
        AOROM.OppRollMeetings(Trigger.old);
    }
    
    public override void afterUndelete() {
        AOROM.OppRollMeetings(Trigger.New);
    }
}