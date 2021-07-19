public class AGN_ICL_PractitionerController {
    public String recid {get;set;}
    public AGN_ICL_PractitionerController(){
        recid = System.currentPageReference().getParameters().get('recordId');
        System.debug('recid::'+recid);
        
        
    }
    
     public PageReference dmlOperation(){
         
        Practitioner_Listing_AGN__c pl =[SELECT Id,First_Consent_AGN__c,Practitioner_AGN__c,First_Name_AGN__c,Last_Name_AGN__c,Clinic_AGN__c,Locator_Listing_AGN__c,Locator_Listing_AGN__r.Country_Code_AGN__c ,Locator_Listing_AGN__r.Country_Code_AGN__r.Country_Name_vod__c,Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c,Brand_AGN__c,Consent_AGN__c,CurrencyIsoCode,Email_AGN__c,Gender_AGN__c,Practitioner_Image_Available_AGN__c,Practitioner_Status_AGN__c,Qualification_AGN__c,Salutation_AGN__c,Status_AGN__c,Type_AGN__c,Type_Of_Physician_AGN__c ,Years_of_Experience_AGN__c,ICL_Existing_Person_Account_Searched__c,ICL_Person_Account__c,AGN_ICL_DCR_Reference_Number__c,ICL_Practitioner_Case__c,ICL_Practitioner_Case__r.Status,Locator_Listing_AGN__r.Account_AGN__c,Locator_Listing_AGN__r.Country_Code_AGN__r.Cluster_Country_AGN__c FROM Practitioner_Listing_AGN__c where id =:recid];
        System.debug('pl::'+pl);
		System.debug('Case Id::'+pl.ICL_Practitioner_Case__c);
		System.debug('Case Status::'+pl.ICL_Practitioner_Case__r.Status);
		Case cs =[select Id,Status from Case where Id=:pl.ICL_Practitioner_Case__c];
		
        /* 
         acc.RecordTypeId=rcId;
            acc.FirstName= pc.First_Name_AGN__c;
            acc.LastName= pc.Last_Name_AGN__c;
            acc.Primary_Parent_vod__c = pc.Clinic_AGN__c;
            acc.Practitioner_Listing_Id__c = pc.Id;
            acc.PersonEmail = pc.Email_AGN__c;
            acc.Registered_For_Clinic_Locator_AGN__c = True;
            acc.Status_AGN__c = 'Pending Validation';
            acc.Country_vod__c =pc.Locator_Listing_AGN__r.Country_Code_AGN__c;
            acc.Country_Code__c=pc.Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c;
            */
        Account aa = new Account();
           if(pl.Status_AGN__c != 'Active')
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Request_Deleted));
                  cs.Status='Closed';
                 //Adding checkmarx comment
            try{
                	List<Case> caseupdate = new List<Case>();
           			caseupdate.add(cs); 
                    String objAcc = 'Case';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(caseupdate,accObjType,'INSERT');
                    update caseupdate;
                
           
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Case update:'+ex);
			}
             //End
            }
         else
         {
             if(pl.Practitioner_AGN__c != null)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Request_approved));
            }
             else
             {
        if(pl.ICL_Person_Account__c==null && pl.ICL_Existing_Person_Account_Searched__c==true && pl.ICL_Practitioner_Case__r.Status=='Working'){    
            
            
            aa.FirstName = pl.First_Name_AGN__c;
            aa.LastName = pl.Last_Name_AGN__c;
            aa.Primary_Parent_vod__c = pl.Clinic_AGN__c;
            aa.Practitioner_Listing_Id__c = pl.Id;
            aa.PersonEmail = pl.Email_AGN__c;
            aa.Registered_For_Clinic_Locator_AGN__c = True;
            aa.Status_AGN__c = 'Pending Validation';
            aa.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;
            aa.Country_vod__c =pl.Locator_Listing_AGN__r.Country_Code_AGN__c;
           // aa.Country_Code__c=pl.Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c;
           //Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
                if(pl.Locator_Listing_AGN__r.Country_Code_AGN__r.Cluster_Country_AGN__c==null)
                {
                   aa.Country_Code__c = pl.Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c; 
                }
                else
                {
                  aa.Country_Code__c = pl.Locator_Listing_AGN__r.Country_Code_AGN__r.Cluster_Country_AGN__c;   
                }
            //End
            
            //Adding checkmarx comment
            try{
                	List<Account> acctinsert = new List<Account>();
           			acctinsert.add(aa); 
                    String objAcc = 'Account';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(acctinsert,accObjType,'INSERT');
                    insert acctinsert;
                
           
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Account Insert:'+ex);
			}
             //End
        
            Child_Account_vod__c ChAcc = new Child_Account_vod__c();
            ChAcc.Child_Account_vod__c = aa.Id;
            ChAcc.Parent_Account_vod__c = pl.Locator_Listing_AGN__r.Account_AGN__c;
            ChAcc.Copy_Address_vod__c = True;
            ChAcc.External_ID_vod__c = pl.Locator_Listing_AGN__r.Account_AGN__c+'__'+pl.Id;
                //Adding checkmarx comment
                      try{
                	List<Child_Account_vod__c> Chdaccinsert = new List<Child_Account_vod__c>();
           			Chdaccinsert.add(ChAcc); 
                    String objAcc = 'Child_Account_vod__c';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Chdaccinsert,accObjType,'INSERT');
                    insert Chdaccinsert;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the childaccount insert:'+ex);
			}
             //End
            System.debug('Account id::'+aa.Id);
			String accountId = aa.Id;
			//create dcr
			String DcrId = AGN_ICL_ClinicRegistrationController.createDCR(accountId,'Approve'); 
            String DCR = [SELECT name FROM Data_Change_Request_vod__c WHERE Account_vod__c=: accountId LIMIT 1].name;
			System.debug('DCR::'+DCR); 
            //pl.ICL_Existing_Person_Account_Searched__c = true;
            pl.ICL_Person_Account__c = aa.Id;
            pl.AGN_ICL_DCR_Reference_Number__c = DCR;
			pl.Practitioner_AGN__c = aa.Id;
			pl.First_Consent_AGN__c = false;
             //Adding checkmarx comment
             try{
                	List<Practitioner_Listing_AGN__c> pracupdate = new List<Practitioner_Listing_AGN__c>();
           			pracupdate.add(pl); 
                    String objAcc = 'Practitioner_Listing_AGN__c';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(pracupdate,accObjType,'UPDATE');
                    update pracupdate;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Practitioner update:'+ex);
			}
            //End
            //update pl;
			
			cs.Status ='Closed';
            //Adding checkmarx comment
             try{
                	List<Case> Caseupdate = new List<Case>();
           			Caseupdate.add(cs); 
                    String objAcc = 'Case';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Caseupdate,accObjType,'UPDATE');
                    update Caseupdate;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Case update:'+ex);
			}
            //End
			//update cs;
			
			Practitioner_Listing_AGN__c prac =[select id,ICL_Person_Account__r.Name from Practitioner_Listing_AGN__c where id =:recid];
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_NewAccount_Created +'"'+prac.ICL_Person_Account__r.Name+'"'));
			
        }
		else if(pl.ICL_Person_Account__c!=null && pl.ICL_Existing_Person_Account_Searched__c==true && pl.ICL_Practitioner_Case__r.Status=='Working'){
			Practitioner_Listing_AGN__c prac1 =[select id,First_Consent_AGN__c,Practitioner_AGN__c,ICL_Person_Account__r.Id,ICL_Person_Account__r.Name from Practitioner_Listing_AGN__c where id =:recid];
			prac1.Practitioner_AGN__c = prac1.ICL_Person_Account__r.Id;
			prac1.First_Consent_AGN__c = false;
            //Adding checkmarx comment
             try{
                	List<Practitioner_Listing_AGN__c> Pracupdate = new List<Practitioner_Listing_AGN__c>();
           			Pracupdate.add(prac1); 
                    String objAcc = 'Practitioner_Listing_AGN__c';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Pracupdate,accObjType,'UPDATE');
                    update Pracupdate;
                 
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Practitioner update:'+ex);
			}
            //End
            List<Child_Account_vod__c> vodList = [select id from Child_Account_vod__c where Child_Account_vod__c = :prac1.ICL_Person_Account__r.Id 	
                                                  and Parent_Account_vod__c = :pl.Locator_Listing_AGN__r.Account_AGN__c];	
            System.debug('vodlist print'+vodList);
            if(vodList == null || vodList.isEmpty()){
            Child_Account_vod__c ChAcc = new Child_Account_vod__c();
                 ChAcc.Child_Account_vod__c = prac1.ICL_Person_Account__r.Id;
                 ChAcc.Parent_Account_vod__c = pl.Locator_Listing_AGN__r.Account_AGN__c;
                 ChAcc.Copy_Address_vod__c = True;
                 ChAcc.External_ID_vod__c = pl.Locator_Listing_AGN__r.Account_AGN__c+'__'+pl.Id;
             //Adding checkmarx comment
             try{
                	List<Child_Account_vod__c> Chdaccinsert = new List<Child_Account_vod__c>();
           			Chdaccinsert.add(ChAcc); 
                    String objAcc = 'Child_Account_vod__c';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Chdaccinsert,accObjType,'INSERT');
                    insert Chdaccinsert;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the childaccount insert:'+ex);
			}
            } 
            //End
			//update prac1;
            cs.Status ='Closed';
			//update cs;
			
			//Adding checkmarx comment
			 try{
                	List<Case> Caseupdate = new List<Case>();
           			Caseupdate.add(cs); 
                    String objAcc = 'Case';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Caseupdate,accObjType,'UPDATE');
                    update Caseupdate;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Case update:'+ex);
			}
            //End
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.AGN_ICL_PractitionerListing_With_PersonAccount +'"'+prac1.ICL_Person_Account__r.Name+'"'));
			
		}
		else if(pl.ICL_Existing_Person_Account_Searched__c==false && pl.ICL_Practitioner_Case__r.Status=='Working'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Check_PractitionerRecord));
		}
       
		else if(pl.ICL_Practitioner_Case__r.Status!='Working' && pl.Practitioner_AGN__c == null ){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Accept_Case));
		}
             }
         }
      /*  if(aa.Id !=null || pl.ICL_Person_Account__c!=null){
            //pl.ICL_Existing_Person_Account_Searched__c = true;
            //update pl;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Account Created'));  
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Something went wrong!'));
        } */
        
        return null;
     }
	 
	 public PageReference back() {
        System.debug('Entered');
        PageReference nextPage = new PageReference('/' + recid);
        nextPage.setRedirect(true);
        return nextPage;
	}
}