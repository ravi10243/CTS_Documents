public class AGN_ICL_LocatorListingController {
public String recid {get;set;}
    public AGN_ICL_LocatorListingController(){
        recid = System.currentPageReference().getParameters().get('recordId');
    
    }
    public PageReference dmlOperation(){
        
          try {
              
           List<PermissionSetAssignment>  psassign=[SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.name =:System.label.AGN_ICL_PSName and AssigneeId=:UserInfo.getUserId() ];
           if(!psassign.isEmpty())
             {
         
        Locator_Listing_AGN__c ll =[select id,First_Level_Clinic_Approver_AGN__c,Approval_Status__c,Existing_Business_Account_Searched__c,AGN_Existing_Person_Account_Searched__c,Active_AGN__c,AGN_Business_Account__c,AGN_Person_Account__c,ICL_Registration_Case__c,ICL_Registration_Case__r.Status,IsChildClinic_AGN__c,Clinic_Admin_AGN__c from Locator_Listing_AGN__c where id =:recid];
       
		Case cs =[select Id,Status from Case where Id=:ll.ICL_Registration_Case__c];
        if (ll.AGN_Person_Account__c != NULL && ll.AGN_Business_Account__c != NULL)
              {
              	List<Locator_Listing_AGN__c> existloc = [SELECT Id FROM Locator_Listing_AGN__c WHERE Clinic_Admin_AGN__c = :ll.AGN_Person_Account__c and Account_AGN__c = :ll.AGN_Business_Account__c ];
            
                    if (existloc.isempty())
                  {  
                             if(ll.Existing_Business_Account_Searched__c == True && ll.AGN_Existing_Person_Account_Searched__c == True && ll.Approval_Status__c != System.label.AGN_ICL_Approved && (ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Working || ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Reopen) &&(ll.Approval_Status__c!= System.label.AGN_ICL_Rejected ||ll.Approval_Status__c!= System.label.AGN_ICL_Approved))  
                                 {
                    ll.Active_AGN__c =True;
                    ll.Approval_Status__c = System.Label.AGN_ICL_Approved;
                    ll.First_Level_Clinic_Approver_AGN__c=UserInfo.getUserId();
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
                    
                    cs.Status ='Closed';
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
                       // update cs;
                    
                    Locator_Listing_AGN__c loc =[select id,Existing_Business_Account_Searched__c,AGN_Existing_Person_Account_Searched__c,AGN_Business_Account__r.Name,AGN_Person_Account__r.Name from Locator_Listing_AGN__c where id =:recid];
                  
                    
                    if(ll.AGN_Business_Account__c == null && ll.AGN_Person_Account__c != null)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_New_Business_Account+'"'+loc.AGN_Business_Account__r.Name+'"'+ System.Label.AGN_ICL_Created_Successfully +' <br/> '+ System.Label.AGN_ICL_LocatorListing_with_PersonAccount +'"'+loc.AGN_Person_Account__r.Name+'"'));
                    }
                    else if (ll.AGN_Person_Account__c == null && ll.AGN_Business_Account__c != null)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_New_Person_Account+'"'+loc.AGN_Person_Account__r.Name+'"'+ System.Label.AGN_ICL_Created_Successfully+'<br/>'+System.Label.AGN_ICL_LocatorListing_with_BusinessAccount +'"'+loc.AGN_Business_Account__r.Name+'"'));
                    }
                    else if (ll.AGN_Person_Account__c == null && ll.AGN_Business_Account__c == null)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_New_Person_Account+'"'+loc.AGN_Person_Account__r.Name+'"'+ System.Label.AGN_ICL_Created_Successfully+'<br/>'+System.Label.AGN_ICL_New_Business_Account+'"'+loc.AGN_Business_Account__r.Name+'"'+ System.Label.AGN_ICL_Created_Successfully));
                    }
                    else 
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_LocatorListing_with_PersonAccount+'"'+loc.AGN_Person_Account__r.Name+'"'+ '<br/>'+ System.Label.AGN_ICL_LocatorListing_with_BusinessAccount +'"'+loc.AGN_Business_Account__r.Name+'"'));
                    }
                   
                 
               }
                        
                                   else if((ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Closed || ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_New) && ll.Existing_Business_Account_Searched__c != True && ll.AGN_Existing_Person_Account_Searched__c != True && ll.Approval_Status__c != System.label.AGN_ICL_Rejected && ll.Approval_Status__c != System.label.AGN_ICL_Approved){
                                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Accept_Case));
                                       
                                   }
                                   else if((ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Closed || ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_New) && ll.Existing_Business_Account_Searched__c == True && ll.AGN_Existing_Person_Account_Searched__c == True && ll.Approval_Status__c != System.label.AGN_ICL_Rejected && ll.Approval_Status__c != System.label.AGN_ICL_Approved){
                                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Accept_Case));
                                       
                                   }
                                   else if(ll.Existing_Business_Account_Searched__c == True && ll.AGN_Existing_Person_Account_Searched__c == True && ll.Approval_Status__c == System.label.AGN_ICL_Approved){
                                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Request_approved));	
                                       
                                   }
                                   else if(ll.Approval_Status__c== System.label.AGN_ICL_Rejected){
                                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Request_rejected));	
                                   }
                                   
                                     
                                   else if(ll.ICL_Registration_Case__r.Status== System.label.AGN_ICL_Working && ll.Existing_Business_Account_Searched__c != True && ll.AGN_Existing_Person_Account_Searched__c != True) 
                                    {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Check_ClinicRecord_AdminRecord));
                                    }
                					
                                    else if(ll.ICL_Registration_Case__r.Status== System.label.AGN_ICL_Working && ll.Existing_Business_Account_Searched__c != True && ll.AGN_Existing_Person_Account_Searched__c == True) 
                                    {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Check_ClinicRecord_to_Approve));
                                    }
                                    else if(ll.ICL_Registration_Case__r.Status== System.label.AGN_ICL_Working && ll.Existing_Business_Account_Searched__c == True && ll.AGN_Existing_Person_Account_Searched__c != True ) 
                                    {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Check_AdminRecord_to_Approve));
                                    }
                                    
                                    
                  }
              else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Error_Clinic_Account_mapping));
                  }
              }   
          else
          {
               if(ll.Existing_Business_Account_Searched__c == True && ll.AGN_Existing_Person_Account_Searched__c == True && ll.Approval_Status__c != System.label.AGN_ICL_Approved && (ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Working || ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Reopen) &&(ll.Approval_Status__c!= System.label.AGN_ICL_Rejected||ll.Approval_Status__c!=System.label.AGN_ICL_Approved))  
                                 {
                    ll.Active_AGN__c =True;
                    ll.Approval_Status__c = System.Label.AGN_ICL_Approved;
                    ll.First_Level_Clinic_Approver_AGN__c=UserInfo.getUserId();
                                     
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
                    
                    cs.Status =System.Label.AGN_ICL_Closed;
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
                                     
                    // update cs;
                    
                    Locator_Listing_AGN__c loc =[select id,Existing_Business_Account_Searched__c,AGN_Existing_Person_Account_Searched__c,AGN_Business_Account__r.Name,AGN_Person_Account__r.Name from Locator_Listing_AGN__c where id =:recid];
                   
                    
                    if(ll.AGN_Business_Account__c == null && ll.AGN_Person_Account__c != null)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_New_Business_Account+'"'+loc.AGN_Business_Account__r.Name+'"'+ System.Label.AGN_ICL_Created_Successfully +' <br/> '+ System.Label.AGN_ICL_LocatorListing_with_PersonAccount +'"'+loc.AGN_Person_Account__r.Name+'"'));
                    }
                    else if (ll.AGN_Person_Account__c == null && ll.AGN_Business_Account__c != null)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_New_Person_Account+'"'+loc.AGN_Person_Account__r.Name+'"'+ System.Label.AGN_ICL_Created_Successfully+'<br/>'+System.Label.AGN_ICL_LocatorListing_with_BusinessAccount +'"'+loc.AGN_Business_Account__r.Name+'"'));
                    }
                    else if (ll.AGN_Person_Account__c == null && ll.AGN_Business_Account__c == null)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_New_Person_Account+'"'+loc.AGN_Person_Account__r.Name+'"'+ System.Label.AGN_ICL_Created_Successfully+'<br/>'+System.Label.AGN_ICL_New_Business_Account+'"'+loc.AGN_Business_Account__r.Name+'"'+ System.Label.AGN_ICL_Created_Successfully));
                    }
                    else 
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_LocatorListing_with_PersonAccount+'"'+loc.AGN_Person_Account__r.Name+'"'+ '<br/>'+ System.Label.AGN_ICL_LocatorListing_with_BusinessAccount +'"'+loc.AGN_Business_Account__r.Name+'"'));
                    }
                   
                 
               }
                                   else if((ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Closed || ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_New) && ll.Existing_Business_Account_Searched__c != True && ll.AGN_Existing_Person_Account_Searched__c != True && ll.Approval_Status__c != System.label.AGN_ICL_Rejected && ll.Approval_Status__c != System.label.AGN_ICL_Approved){
                                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Accept_Case));
                                       
                                   }
                                   else if((ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_Closed || ll.ICL_Registration_Case__r.Status == System.label.AGN_ICL_New) && ll.Existing_Business_Account_Searched__c == True && ll.AGN_Existing_Person_Account_Searched__c == True && ll.Approval_Status__c != System.label.AGN_ICL_Rejected && ll.Approval_Status__c != System.label.AGN_ICL_Approved){
                                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Accept_Case));
                                       
                                   }
                                   else if(ll.Existing_Business_Account_Searched__c == True && ll.AGN_Existing_Person_Account_Searched__c == True && ll.Approval_Status__c == System.label.AGN_ICL_Approved){
                                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Request_approved));	
                                       
                                   }
                                   else if(ll.Approval_Status__c== System.label.AGN_ICL_Rejected){
                                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Request_rejected));	
                                   }
                                    
                                    
                                    if((ll.ICL_Registration_Case__r.Status== System.label.AGN_ICL_Working||ll.ICL_Registration_Case__r.Status== System.label.AGN_ICL_Reopen) && ll.Existing_Business_Account_Searched__c != True && ll.AGN_Existing_Person_Account_Searched__c != True) 
                                    {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Check_ClinicRecord_AdminRecord));
                                    }
                                    else if((ll.ICL_Registration_Case__r.Status== System.label.AGN_ICL_Working||ll.ICL_Registration_Case__r.Status== System.label.AGN_ICL_Reopen) && ll.Existing_Business_Account_Searched__c != True && ll.AGN_Existing_Person_Account_Searched__c == True) 
                                    {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Check_ClinicRecord_to_Approve));
                                    }
                                    else if((ll.ICL_Registration_Case__r.Status== System.label.AGN_ICL_Working||ll.ICL_Registration_Case__r.Status== System.label.AGN_ICL_Reopen) && ll.Existing_Business_Account_Searched__c == True && ll.AGN_Existing_Person_Account_Searched__c != True ) 
                                    {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Check_AdminRecord_to_Approve));
                                    }
             				 
                                    
          }
        }     
         
          
          else
           {
            	 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_NonICLAdminValidation));
            }
          }
        catch (DmlException dx) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Error));
            throw new DmlException(dx.getMessage());
             
        }
        return null;
     }
	 
	 public PageReference back() {
      
        PageReference nextPage = new PageReference('/' + recid);
        nextPage.setRedirect(true);
        return nextPage;
	}
    
}