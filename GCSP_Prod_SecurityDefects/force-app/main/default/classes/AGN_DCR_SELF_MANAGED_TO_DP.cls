public class AGN_DCR_SELF_MANAGED_TO_DP {
    
    public String dcrId { get; set; }
    Public Boolean sendToDPButtonFlag { get; set;}
    public String exceptionMesage {get;set;}
    List<Data_Change_Request_vod__c> dcrToUpdate = new List<Data_Change_Request_vod__c>();// New list added for DCR Update
    Set<ID> accID = new Set<ID>();
    List<Account> dcrAcc = new List<Account>();
    
    public AGN_DCR_SELF_MANAGED_TO_DP(ApexPages.StandardController controller){        
        dcrId = ApexPages.CurrentPage().getparameters().get('id');        
        System.debug('Inside Constructor');
        Data_Change_Request_vod__c dcrObj = [select ID, Data_Provider_Managed_AGN__c,Company_Managed_AGN__c, 
                                             Country_Code_AGN__c, Account_vod__c,DCR_Approver_AGN__c,Secondary_Approver_AGN__c,
                                             DCR_Status_AGN__c,Reps_Selected_Self_Manged_AGN__c,DCR_Rerouted_AGN__c
                                             from Data_Change_Request_vod__c where ID = :ApexPages.CurrentPage().getparameters().get('id')]; // NM CC
        
        System.debug('DCR Status'+dcrObj.DCR_Status_AGN__c);
        //if((dcrObj.Reps_Selected_Self_Manged_AGN__c==True && dcrObj.Company_Managed_AGN__c==True && dcrObj.DCR_Rerouted_AGN__c==False) && 
      //     (dcrObj.DCR_Status_AGN__c!='Approved' || dcrObj.DCR_Status_AGN__c!='Rejected' || dcrObj.DCR_Status_AGN__c!='Rejected by DP')){
               
         if(dcrObj.Reps_Selected_Self_Manged_AGN__c==True && dcrObj.Company_Managed_AGN__c==True && dcrObj.DCR_Rerouted_AGN__c==False && dcrObj.DCR_Status_AGN__c=='Pending for Approval'){
            sendToDPButtonFlag=True;
        }else{
            sendToDPButtonFlag=False;
        }
            
    }
    
    public Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;

        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId])
            retVal  =  workItem.Id;

        return retVal;
    }
        
    public void rejectRecord()
    {
        try{
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();        
        req.setComments(Label.AGN_DCR_Send_to_DP_Approval_Cmnt);
        req.setAction('Reject');
        Id workItemId = getWorkItemId(dcrId); 
        if(workItemId == null)
        {
            System.debug('Inside if');
           
        }
        else
        {
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(req);
        }
        String base = Url.getSalesforceBaseUrl().toExternalForm();
        System.debug('My Domain Url'+base+'/'+ dcrId);
      //New code added for DCR Update
      for(Data_Change_Request_vod__c dcr : [select ID, Data_Provider_Managed_AGN__c, DCR_Approver_AGN__c, Company_Managed_AGN__c,MDM_Managed_AGN__c, 
                                                      Country_AGN__c, DCR_Settings_Applied_AGN__c, Error_vod__c, Provisional_Contact_Required_AGN__c, 
                                                      Country_Code_AGN__c, RecordTypeId, Type_vod__c, Account_vod__c,Address_vod__c, Child_Account_vod__c,
                                                      DCR_Status_AGN__c, Secondary_Approver_AGN__c,Reps_Selected_Self_Manged_AGN__c,DCR_Rerouted_AGN__c
                                                      from Data_Change_Request_vod__c
                                            where ID = :ApexPages.CurrentPage().getparameters().get('id')]){ //NM CC
             if(dcr.DCR_Rerouted_AGN__c==False && dcr.Reps_Selected_Self_Manged_AGN__c==TRUE){
                 
                 //AG CC
                 
                if(Schema.sObjectType.Data_Change_Request_vod__c.fields.Company_Managed_AGN__c.isUpdateable()) 
                {
                    dcr.Company_Managed_AGN__c=False;
                }
                 if(Schema.sObjectType.Data_Change_Request_vod__c.fields.Data_Provider_Managed_AGN__c.isUpdateable()) 
                 {
                     dcr.Data_Provider_Managed_AGN__c=True;
                 }
                 //dcr.Reps_Selected_Self_Manged_AGN__c=False;
                 
                 if(Schema.sObjectType.Data_Change_Request_vod__c.fields.DCR_Status_AGN__c.isUpdateable())
                 {
                     dcr.DCR_Status_AGN__c='Saved';
                 }
             }                          
            dcrToUpdate.add(dcr);
            accID.add(dcr.Account_vod__c);
            System.debug('Account ID'+accID);                                    
            System.debug('Updated DCR before update'+dcrToUpdate);
             
          }
        
        for(Account acc:[select ID,Self_Managed_Account_AGN__c from Account where ID in :accID]){
          if(Schema.sObjectType.Account.fields.Self_Managed_Account_AGN__c.isUpdateable()) 
          {
          acc.Self_Managed_Account_AGN__c=False;
          }
            dcrAcc.add(acc);
            System.debug('Inside for loop Account ID'+dcrAcc);
        }
         if(dcrToUpdate.size()>0){
                update dcrToUpdate;
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'DCR is marked to be sent to Data Provider. Thank you!'));
                System.debug('Updated DCR before update'+dcrToUpdate);
                
            }
        sendToDPButtonFlag=False;
        if(dcrAcc.size()>0){
                update dcrAcc;
                
            }
            exceptionMesage='success';
           // return exceptionMesage;
        }catch(System.Exception e){
            system.debug('@@ Exception encountered while click to Sent to DP in DCR. Exception: ' + e);                     
            exceptionMesage=e.getMessage();
           
        }

        //End of DCR code Update
    }

}