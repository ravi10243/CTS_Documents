/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant
* @Name           ContractExhibitStatusCalc
* @version        1.0
* @created        2015-12-18 (Sananda)
* @modified       2021-06-16 (SG)
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes 
  R003:Cognizant:Sananda(18-12-2015): Batch class written to change the status of the Contract Exhibits to "Hours Calculated"based on
  the Hours logged in call against the Exhibit.
  
  R3.1_2021 PMO NO - 3824 new picklist values added and modified one picklist value.
*/

global class ContractExhibitStatusCalc  implements Database.Batchable<SObject>{
//Database.executeBatch(new ContractExhibitStatusCalc(), 200);

    public final static String SERVICE_BILLABLE_1 = 'B.C.S. Customer Facing';
    public final static String SERVICE_BILLABLE_2 = 'B.C.S. Offsite';
    public final static String CONTRACT_DRAFT = System.Label.Contract_Exhibit_draft;
    public final static String EXHIBIT_WAITING_SIGN = System.Label.Contract_Exhibit_pending;
    public final static String EXHIBIT_LIVE = System.Label.Contract_Exhibit_live;
    public final static String EXHIBIT_COMPLETE = System.Label.Contract_Exhibit_hours;
    public final static String CALL_REPORT_SERVICE_TRANSITION = System.Label.Contract_Exhibit_transition;
    public final static String EXHIBIT_INVOICED = System.Label.Contract_Exhibit_Invoiced;
    public final static String EXHIBIT_CANCELLED = System.Label.Contract_Exhibit_Cancelled;
    
    //New Variable for Canada BC
    public final static String EXHIBIT_LIVE_NEW = System.Label.Contract_Exhibit_live_new;
    public final static String CALLREPORT_STATUS_COMPLETED = System.Label.Contract_Exhibit_completed;
    public final static String EXHIBIT_CLOSED=System.Label.Contract_Exhibit_Closed;
        
   /* private String  errors {get; set;}
    
    public static RecordType getBCRT() {
        return [Select id, DeveloperName From RecordType where DeveloperName = :'Business_Consultant'];
    }
        
        
    global final Set<ID> testIDs;
    global ContractExhibitStatusCalc(Set<ID> testIDs){
        this.testIDs = testIDs;
    }
    global ContractExhibitStatusCalc(){
    }
    */  
    global Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator(
                [select Exhibit_Status__c, Exhibit_Hours__c from Contract_Exhibit__c where Transition_Exhibit__c = false]
            );
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        
        List<Contract_Exhibit__c> updateStatus = new List<Contract_Exhibit__c>();
        List<Contract_Exhibit__c> updateServiceHrs = new List<Contract_Exhibit__c>();  //R008
        List<Contract_Exhibit__c> updateBusinessHrs = new List<Contract_Exhibit__c>(); //R008
        Map<ID,Contract_Exhibit__c> exhibitids = new Map<ID, Contract_Exhibit__c>();
        //CONTRACT EXHIBIT ID , object
        for(SObject s : scope){
            exhibitids.put(s.id, (Contract_Exhibit__c)s);
        }
        
        //R008:Cognizant : Calculate Service delivery hours and Business consulting hours
        //Service Delivery Hours
        //PMO 3216: New picklist value "BC Onboarding- Customer Facing Call" has been added in the query
        AggregateResult[] groupedServiceHrs = [SELECT Contract_Exhibit__c, SUM(Duration_vod__c) total1 
                                          FROM Call2_vod__c  
                                          WHERE Contract_Exhibit__c IN :exhibitids.keySet() 
                                          AND Status_vod__c = 'Submitted_vod'
                                          AND Is_Parent_Call_vod__c=1
                                          AND (Service_Delivered_AGN__c='Business Consulting – Customer Facing' OR
                                          Service_Delivered_AGN__c='Business Consulting – Offsite' OR
                                          Service_Delivered_AGN__c='Credentialing and Gateway – Customer Facing' OR
                                          Service_Delivered_AGN__c='Product Support – Customer Facing' OR
                                          Service_Delivered_AGN__c='Quick win programme'  OR
                                          Service_Delivered_AGN__c='Business Academy' OR
                                          Service_Delivered_AGN__c='Credentialing and Gateway – Offsite' OR
                                          Service_Delivered_AGN__c='Product Support – Offsite' OR
                                          //R3.1_2021 PMO NO - 3824 new picklist values added and modified one picklist value.
                                          Service_Delivered_AGN__c='Credentialing New Client – Customer Facing' OR 
                                          Service_Delivered_AGN__c='Credentialing New Client - Preparation' OR
                                          Service_Delivered_AGN__c='Re-engage with existing client - Customer Facing' OR
                                          Service_Delivered_AGN__c='Re-engage with existing client - Preparation' OR
                                          Service_Delivered_AGN__c='GAP Analysis – Patient Retention - Customer Facing' OR
                                          Service_Delivered_AGN__c='GAP Analysis – Patient Retention - Preparation' OR
                                          Service_Delivered_AGN__c='GAP Analysis – Patient Experience - Customer Facing' OR
                                          Service_Delivered_AGN__c='GAP Analysis – Patient Experience - Preparation' OR
                                          Service_Delivered_AGN__c='GAP Analysis – Patient Acquisition - Onsite' OR
                                          Service_Delivered_AGN__c='GAP Analysis – Patient Acquisition - Preparation' OR
                                          Service_Delivered_AGN__c='GAP Analysis – Ad-hoc Customer Facing' OR
                                          Service_Delivered_AGN__c='GAP Analysis – Ad-hoc Preparation' OR
                                          Service_Delivered_AGN__c='Proposal & Contract Management' OR
                                          Service_Delivered_AGN__c='BC Onboarding – Client Visit'    
                                          )
                                          GROUP BY Contract_Exhibit__c];
                                          
        for (AggregateResult ar1 : groupedServiceHrs) {
            ID exhibitid1 = (ID)ar1.get('Contract_Exhibit__c');
            Contract_Exhibit__c ce1 = exhibitids.get(exhibitid1);
            Decimal hrs1 = (Decimal)ar1.get('total1')/60;
            updateServiceHrs.add (new Contract_Exhibit__c(id=exhibitid1, Service_Delivery_Hours_AGN__c = hrs1));
          }
         
        //Business Consulting Hours                                 
        AggregateResult[] groupedBusinessHrs = [SELECT Contract_Exhibit__c, SUM(Duration_vod__c) total2 
                                          FROM Call2_vod__c  
                                          WHERE Contract_Exhibit__c IN :exhibitids.keySet() 
                                          AND Status_vod__c = 'Submitted_vod'
                                          AND Is_Parent_Call_vod__c=1
                                          AND (Service_Delivered_AGN__c='Business Consulting – Customer Facing' OR
                                          Service_Delivered_AGN__c='Business Consulting – Offsite')
                                          GROUP BY Contract_Exhibit__c];
        for (AggregateResult ar2 : groupedBusinessHrs) {
            ID exhibitid2 = (ID)ar2.get('Contract_Exhibit__c');
            Contract_Exhibit__c ce2 = exhibitids.get(exhibitid2);
            Decimal hrs2 = (Decimal)ar2.get('total2')/60;
            updateBusinessHrs.add (new Contract_Exhibit__c(id=exhibitid2, Business_Consulting_Hours_AGN__c = hrs2));
          }
        
        
        //R007.1:Cognizant:(21-05-2016)(Sananda):Change made in criteria based on Req 801.
        AggregateResult[] groupedResults = [SELECT Contract_Exhibit__c, SUM(Duration_vod__c) total FROM Call2_vod__c  
                                            WHERE Contract_Exhibit__c IN :exhibitids.keySet() 
                                            AND Status_vod__c = 'Submitted_vod'
                                            AND Is_Parent_Call_vod__c=1
                                            //AND Not_included_in_Hours__c=false
                                            //AND Service_Delivered__c IN (:SERVICE_BILLABLE_1,:SERVICE_BILLABLE_2)
                                            AND (Service_Delivered_AGN__c='Business Consulting – Customer Facing' OR
                                            Service_Delivered_AGN__c='Business Consulting – Offsite' ) 
                                            GROUP BY Contract_Exhibit__c];
            system.debug('Group result---->'+groupedResults);
        for (AggregateResult ar : groupedResults) {
            ID exhibitid = (ID)ar.get('Contract_Exhibit__c');
            Contract_Exhibit__c ce = exhibitids.get(exhibitid);
            Decimal hrs = (Decimal)ar.get('total')/60;
            system.debug('Decimal Hours---->'+exhibitid);
            system.debug('Decimal Hours---->'+hrs );
            if (hrs >= ce.Exhibit_Hours__c && ce.Exhibit_Status__c == 'Live - Customer Signed') {
                updateStatus.add (new Contract_Exhibit__c(id=exhibitid, Exhibit_Status__c = EXHIBIT_COMPLETE , Hours_logged_in_Call__c = hrs));
            }
            // # R:016 : Update Code for Canada
            //# 20R1: Req No: 2805 Code commented as Canada move to Core Flow.
            /*if (hrs >= ce.Exhibit_Hours__c && ce.Exhibit_Status__c == EXHIBIT_LIVE_NEW) {
                updateStatus.add (new Contract_Exhibit__c(id=exhibitid, Exhibit_Status__c = CALLREPORT_STATUS_COMPLETED , Hours_logged_in_Call__c = hrs));
            }*/
            
            // End of R:016
        }
        //Database.update (updateStatus, false) not used to allow updates even if some records fails
        update updateStatus;
        update updateServiceHrs;
        update updateBusinessHrs;
     }
    
    global void finish(Database.BatchableContext BC){
        
    }

}