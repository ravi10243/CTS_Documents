// AGN_DCR2_Send_Back_for_Revision //

public without sharing class AGN_DCR2_Send_Back_for_Revision {
    
    // ======== Public Variables ======== //
    public DCR_Account_AGN__c Dcr {get; set;}
    public string DcrKeyPrefix {get; set;}
    
    
// ================================================================ //
    
    public AGN_DCR2_Send_Back_for_Revision(ApexPages.StandardController stdController) {
        system.debug('== [AGN_DCR2_Send_Back_for_Revision].[Constructor] ==');
        
        Dcr = (DCR_Account_AGN__c)stdController.getRecord();
        string dcrId = DCR.id;
        DcrKeyPrefix = dcrId.substring(0,3);
    }
    
    
// ================================================================ //
    
    public boolean getPromptForRevision() {
        system.debug('== [AGN_DCR2_Send_Back_for_Revision].[getPromptForRevision].Dcr =='+Dcr);
        
        Dcr = [SELECT Prompt_for_Revision_AGN__c,Request_Status_AGN__c,Approver_AGN__c FROM DCR_Account_AGN__c WHERE Id = :Dcr.id];
                system.debug('== [Query:Dcr] =='+Dcr);
        
        //if(Dcr.Request_Status_AGN__c == 'Rejected')
        if(Dcr.Request_Status_AGN__c == 'Rejected' && Dcr.Approver_AGN__c == UserInfo.getUserId())
            return(true);
        else
            return(false);
    }
    
    
// ================================================================ //
    
    public void UpdateStatusForRevision() {
        system.debug('== [AGN_DCR2_Send_Back_for_Revision].[UpdateStatusForRevision] ==');
        
        Dcr.Request_Status_AGN__c = 'Sent Back for Revision';
        system.debug('== [DML:update Dcr] =='+Dcr);
        update Dcr;
        system.debug('== [DML:update Dcr].success ==');
        Approval.UnlockResult ul = Approval.Unlock(Dcr.id);
    }
    
    
// ================================================================ //
    
    public void HideRevisionPrompt() {
        system.debug('== [AGN_DCR2_Send_Back_for_Revision].[HideRevisionPrompt] ==');
        
        Dcr.Prompt_for_Revision_AGN__c = False;
        system.debug('== [DML:update Dcr] =='+Dcr);
        update Dcr;
        system.debug('== [DML:update Dcr].success ==');
    }
    
    
// ================================================================ //
    
    public void EnableRevisionPrompt() {
        system.debug('== [AGN_DCR2_Send_Back_for_Revision].[EnableRevisionPrompt] ==');
        
        Dcr.Prompt_for_Revision_AGN__c = True;
        system.debug('== [DML:update Dcr] =='+Dcr);
        update Dcr;
        system.debug('== [DML:update Dcr].success ==');
    }
}

// AGN_DCR2_Send_Back_for_Revision //