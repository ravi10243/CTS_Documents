public class AGN_ICL_LocatorListingRejectController {
public String recid {get;set;}
    public AGN_ICL_LocatorListingRejectController(){
        recid = System.currentPageReference().getParameters().get('recordId');
      
        
        
        
    }
    
    public PageReference dmlOperation(){
         
          List<PermissionSetAssignment>  psassign=[SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.name =:System.label.AGN_ICL_PSName and AssigneeId=:UserInfo.getUserId() ];
           if(!psassign.isEmpty())
             {

        Locator_Listing_AGN__c ll =[select id,Registered_For_Clinic_Locator_AGN__c,Active_AGN__C,Approval_Status__c,Existing_Business_Account_Searched__c,AGN_Existing_Person_Account_Searched__c,Rejected_Message_AGN__c,Clinic_Admin_Email_AGN__c,AGN_First_Name__c,AGN_Last_Name__c,User_Language_AGN__c,ICL_Registration_Case__c,ICL_Registration_Case__r.Status from Locator_Listing_AGN__c where id =:recid];
       
		Case cs =[select Id,Status from Case where Id=:ll.ICL_Registration_Case__c];
        
        /* ll.Rejection_Comment_AGN__c = 'Rejected';
        ll.Approval_Status__c = 'Rejected';
        
        update ll; */
        
        if(ll.Rejected_Message_AGN__c != null && ll.Approval_Status__c == System.label.AGN_ICL_Pending && (ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Working)) 
        {           
			ll.Approval_Status__c = System.Label.AGN_ICL_Rejected;
            ll.Active_AGN__c = False;
            ll.Registered_For_Clinic_Locator_AGN__c = True;
         //Adding checkmarx comment  
         try{
        	List<Locator_Listing_AGN__c> Locupdate = new List<Locator_Listing_AGN__c>();
           			Locupdate.add(ll); 
                    String objloc = 'Locator_Listing_AGN__c';
                    SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objloc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Locupdate,locObjType,'UPDATE');
                    update Locupdate; 
                 }
         catch(Exception ex)
            {
                System.debug('There is an exception for Updating locator listing:'+ex);
			}
			
			//END
			// update ll;
			cs.Status = System.Label.AGN_ICL_Rejected;
             //Adding checkmarx comment  
          try{
        	List<Case> Caseupdate = new List<Case>();
           			Caseupdate.add(cs); 
                    String objCase = 'Case';
                    SObjectType caseObjType = ((SObject)(Type.forName('Schema.'+objCase).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Caseupdate,caseObjType,'UPDATE');
                    update Caseupdate; 
                 }
        catch(Exception ex)
            {
                System.debug('There is an exception for the Case Update:'+ex);
			}
			//END
			//update cs;			
			
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_Rejected_successfully));  
			
        }
                 else if(ll.Rejected_Message_AGN__c != null && ll.Approval_Status__c == System.label.AGN_ICL_Pending && ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Reopen){
                     ll.Approval_Status__c = System.Label.AGN_ICL_Finally_Rejected;
                     ll.Active_AGN__c = False;
                     ll.Registered_For_Clinic_Locator_AGN__c = True;
                     //Adding checkmarx comment  
                     try{
                         List<Locator_Listing_AGN__c> Locupdate = new List<Locator_Listing_AGN__c>();
                         Locupdate.add(ll); 
                         String objloc = 'Locator_Listing_AGN__c';
                         SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objloc).newInstance())).getSObjectType();
                         AGN_FLSCheck.check(Locupdate,locObjType,'UPDATE');
                         update Locupdate; 
                     }
                     catch(Exception ex)
                     {
                         System.debug('There is an exception for Updating locator listing:'+ex);
                     }
                     
                     //END
                     // update ll;
                     cs.Status = System.Label.AGN_ICL_Closed;
                         
                     //Adding checkmarx comment  
                     try{
                         List<Case> Caseupdate = new List<Case>();
                         Caseupdate.add(cs); 
                         String objCase = 'Case';
                         SObjectType caseObjType = ((SObject)(Type.forName('Schema.'+objCase).newInstance())).getSObjectType();
                         AGN_FLSCheck.check(Caseupdate,caseObjType,'UPDATE');
                         update Caseupdate; 
                     }
                     catch(Exception ex)
                     {
                         System.debug('There is an exception for the Case Update:'+ex);
                     }
                     //END
                     //update cs;			
                     
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_Rejected_successfully));  
                     
                 }
                 
		else if((ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Reopen ) && ll.Approval_Status__c == System.label.AGN_ICL_Pending){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Accept_Case));
		}
         else if((ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_New ) && ll.Approval_Status__c == System.label.AGN_ICL_Pending){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Accept_Case));
		}        
		else if(ll.Rejected_Message_AGN__c == null && ll.Approval_Status__c != System.label.AGN_ICL_Approved)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Rejected_Msg_cannot_blank));
        }
        
		else if(ll.Approval_Status__c == System.label.AGN_ICL_Rejected){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Record_Rejected));
		}
		else if(ll.Approval_Status__c == System.label.AGN_ICL_Approved){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Approved_cannot_reject));
		}
		
      }
		else
           {
            	 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_NonICLAdminValidation));
            }
        
        
        return null;
    }
	
	public PageReference back() {
       
        PageReference nextPage = new PageReference('/' + recid);
        nextPage.setRedirect(true);
        return nextPage;
	}
	
    public Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
        }
        return retVal;
    }
}