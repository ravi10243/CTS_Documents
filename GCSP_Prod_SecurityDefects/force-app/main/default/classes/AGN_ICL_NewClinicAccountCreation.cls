/*
Modified by :ICL Project Team
Description: Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
Release :ICL Wave-3
*/
public class AGN_ICL_NewClinicAccountCreation 
{
    @InvocableMethod
    public static void AGN_ICL_NewClinicAccountCreation (List<ID> Ids) 
    {
        //Line of code has been change as a part of DCR Enablement 
        Locator_Listing_AGN__c loc = [SELECT Id,Name,Country_Code_AGN__c,Email_AGN__c,Street_AGN__c,	
                                      Clinic_Admin_AGN__c,Clinic_Admin_Email_AGN__c,City_AGN__c,Zip_Code_AGN__c,	
                                      OwnerId,Owner.Name,Approval_Status__c,AGN_Person_Account__c,	
                                      Existing_Business_Account_Searched__c,AGN_Business_Account__c,	
                                      AGN_Existing_Person_Account_Searched__c,AGN_Last_Name__c,	
                                      IsChildClinic_AGN__c,AGN_First_Name__c,Active_AGN__c,	
                                      Account_AGN__c,Clinic_Admin_Salutation_AGN__c,State_Providence_Region_AGN__c,Country_AGN__c,User_Language_AGN__c,	CASL_Consent_AGN__c  FROM Locator_Listing_AGN__c 
                                      WHERE Id in :Ids 
                                      LIMIT 1];
        loc.Active_AGN__c= False;	
               //Adding checkmarx comment	
             try{	
                	List<Locator_Listing_AGN__c> updateloclist = new List<Locator_Listing_AGN__c>();	
           			updateloclist.add(loc); 	
                    String objAcc = 'Locator_Listing_AGN__c';	
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();	
                    AGN_FLSCheck.check(updateloclist,accObjType,'UPDATE');	
                    update updateloclist;	
            }	
            catch(Exception ex)	
            {	
                System.debug('There is an exception for the locator listing update:'+ex);	
			}	
        //End	
        	
       // update loc;
        Country_vod__c Country_code = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Id=:loc.Country_Code_AGN__c limit 1];
        User u = [Select id,name,ContactId from User where Id=:loc.OwnerId];
        system.debug('user@@@'+u);	
        //Line of code has been added as a part of DCR Enablement 	
        List <Account> personaccList = new List<Account>();	
        String adminName='';	
        if(loc.Approval_Status__c =='Pending' && loc.Approval_Status__c == 'Approved' && loc.Existing_Business_Account_Searched__c==false && loc.AGN_Existing_Person_Account_Searched__c==false)	
        {	
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Select_Checkbox_Error));	
        }	
        if(loc.Approval_Status__c == 'Approved' && loc.Existing_Business_Account_Searched__c==true && loc.AGN_Business_Account__c!=null)	
        {	
            loc.Account_AGN__c = loc.AGN_Business_Account__c;	
                       	
        }	
        if(loc.Approval_Status__c == 'Approved' && loc.AGN_Existing_Person_Account_Searched__c==true && loc.AGN_Person_Account__c!=null)	
        {	
            loc.Clinic_Admin_AGN__c = loc.AGN_Person_Account__c;	
            	
        }	
       if(loc.AGN_Person_Account__c!=null && loc.AGN_Business_Account__c!=null)	
        {	
            List<Child_Account_vod__c> vodList = [select id from Child_Account_vod__c where Child_Account_vod__c = :loc.Clinic_Admin_AGN__c 	
                                                  and Parent_Account_vod__c = :loc.Account_AGN__c];	
            System.debug('vodlist print'+vodList);
            if(vodList == null || vodList.isEmpty())
            {	
                Child_Account_vod__c ChAcc = new Child_Account_vod__c();	
                ChAcc.Child_Account_vod__c = loc.Clinic_Admin_AGN__c;	
                ChAcc.Parent_Account_vod__c =loc.Account_AGN__c;	
                ChAcc.Copy_Address_vod__c = True;	
                ChAcc.External_ID_vod__c = loc.Account_AGN__c+'__'+loc.Id;	
                //insert ChAcc;	
                //Adding checkmarx comment	
             try{	
                	List<Child_Account_vod__c> Chdaccountinsert = new List<Child_Account_vod__c>();	
           			Chdaccountinsert.add(ChAcc); 	
                    String objAcc = 'Child_Account_vod__c';	
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();	
                    AGN_FLSCheck.check(Chdaccountinsert,accObjType,'INSERT');	
                    insert Chdaccountinsert;
                 
            }	
            catch(Exception ex)	
            {	
                System.debug('There is an exception for the childaccount insert:'+ex);	
			}

        //End
        }
           
                   AccountContactRelation acr = new AccountContactRelation();
            		acr.AccountId=loc.Account_AGN__c;
           			 List<AccountContactRelation> conacr = [Select ContactId from AccountContactRelation where AccountId=:loc.Clinic_Admin_AGN__c limit 1];
           			 if(!conacr.isEmpty())
                     {
                         for(AccountContactRelation loopacr:conacr)
                         {
                              acr.ContactId=loopacr.ContactId;
                              
                         }
                        insert acr;
                     }
            		
           			
           
            		 
        } 
        if(loc.AGN_Person_Account__c==null && loc.IsChildClinic_AGN__c==false)
            {
            adminName = loc.AGN_First_Name__c+' '+loc.AGN_Last_Name__c;
            Country_vod__c cc = [select Alpha_2_Code_vod__c,Cluster_Country_AGN__c from Country_vod__c where id=:LOC.Country_Code_AGN__c];
            System.debug('Country Code::'+cc.Alpha_2_Code_vod__c);
            Account aa = new Account();
            aa.Salutation=loc.Clinic_Admin_Salutation_AGN__c;
            aa.FirstName = loc.AGN_First_Name__c;
            aa.LastName = loc.AGN_Last_Name__c;
            aa.PersonEmail = loc.Clinic_Admin_Email_AGN__c;
            aa.Customer_Managed_AGN__c = true;
            aa.Registered_For_Clinic_Locator_AGN__c = true;
            aa.Status_AGN__c = 'Pending Validation';
            aa.Country_vod__c = loc.Country_Code_AGN__c;
           // aa.Country_Code__c = cc.Alpha_2_Code_vod__c;
               //Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
                if(cc.Cluster_Country_AGN__c==null)
                {
                   aa.Country_Code__c = Country_code.Alpha_2_Code_vod__c; 
                }
                else
                {
                  aa.Country_Code__c = Country_code.Cluster_Country_AGN__c;   
                }
            //End
            aa.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;
            
             //Adding checkmarx comment
            try{
                	List<Account> acctinsert = new List<Account>();
           			acctinsert.add(aa); 
                    String objAcc = 'Account';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(acctinsert,accObjType,'INSERT');
                    insert acctinsert;
                if(Country_code.Alpha_2_Code_vod__c == System.Label.AGN_ICL_Country_Code && loc.IsChildClinic_AGN__c == false ){
                    AGN_ICL_UtlityClass.CaslConsent(loc.CASL_Consent_AGN__c,aa.id,loc.User_Language_AGN__c,cc.Alpha_2_Code_vod__c);
                }
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Account Insert:'+ex);
			}
            //End
            
            //insert aa;
            
           // AGN_Account_SendToDP_DCR.createDCR(aa.id, 'Approved');
            String PersonDcrId = createDCR(aa.id, 'Approved');
            String PersonDCR = [SELECT name FROM Data_Change_Request_vod__c WHERE Account_vod__c=: aa.id LIMIT 1].name;
            if(loc.AGN_Business_Account__c!=null)
            {
                Child_Account_vod__c ChAcc = new Child_Account_vod__c();
                ChAcc.Child_Account_vod__c = aa.Id;
                ChAcc.Parent_Account_vod__c = loc.Account_AGN__c;
                ChAcc.Copy_Address_vod__c = True;
                ChAcc.External_ID_vod__c = loc.Account_AGN__c+'__'+loc.Id;
                  //Adding checkmarx comment
                 try{
                        List<Child_Account_vod__c> Chdaccountinsert = new List<Child_Account_vod__c>();
                        Chdaccountinsert.add(ChAcc); 
                        String objAcc = 'Child_Account_vod__c';
                        SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                        AGN_FLSCheck.check(Chdaccountinsert,accObjType,'INSERT');
                        insert Chdaccountinsert;
                }
                catch(Exception ex)
                {
                    System.debug('There is an exception for the childaccount insert:'+ex);
                }
            }  
        //End
            //insert ChAcc;
            
            loc.Clinic_Admin_AGN__c = aa.Id;
            loc.AGN_Person_Account__c=aa.Id;
            loc.DCR_Reference_Number_Person_Account_AGN__c	= PersonDCR ;
            // update loc;
            
        }
        if( loc.AGN_Business_Account__c == null && loc.Approval_Status__c == 'Approved' && loc.Existing_Business_Account_Searched__c==true && loc.AGN_Existing_Person_Account_Searched__c==true)       
        {
         //Line of code has been added as a part of DCR Enablement END
        Account a = new Account();
        a.Name = loc.Name;
        a.Status_AGN__c = 'Pending Validation';
        a.Customer_Managed_AGN__c = True;
        a.Country_vod__c = Country_code.id;
        a.Registered_For_Clinic_Locator_AGN__c = True;
        a.Email_Internal_AGN__c = loc.Email_AGN__c;
        //a.Country_Code__c = Country_code.Alpha_2_Code_vod__c;
       
        //Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
        if(Country_code.Cluster_Country_AGN__c==null)
        {
           a.Country_Code__c = Country_code.Alpha_2_Code_vod__c; 
        }
        else
        {
          a.Country_Code__c = Country_code.Cluster_Country_AGN__c;   
		}
        //End
        
        a.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;  
            try{
                List<Account> acctinsert = new List<Account>();
                acctinsert.add(a); 
                String objAcc = 'Account';
                SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                AGN_FLSCheck.check(acctinsert,accObjType,'INSERT');
                insert acctinsert;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Account Insert:'+ex);
            }
            
        //insert a;
        
        Address_vod__c ad = new Address_vod__c();
        ad.Account_vod__c = a.Id;
        ad.Name = loc.Street_AGN__c;
        ad.City_vod__c = loc.City_AGN__c;
		ad.Country_vod__c = loc.Country_AGN__c;
        ad.Country_Code__c = Country_code.Alpha_2_Code_vod__c;
        ad.Zip_vod__c = loc.Zip_Code_AGN__c;
        ad.Primary_vod__c = True;
        ad.State_vod__c = loc.State_Providence_Region_AGN__c;
        //Adding checkmarx comment
             try{
                	List<Address_vod__c> Addressinsert = new List<Address_vod__c>();
           			Addressinsert.add(ad); 
                    String objAdd = 'Address_vod__c';
                    SObjectType addObjType = ((SObject)(Type.forName('Schema.'+objAdd).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Addressinsert,addObjType,'INSERT');
                    insert Addressinsert;
            }
            catch(Exception ex)  
            {
                System.debug('There is an exception for the address insert:'+ex);
			}
        //End
        //insert ad;
        
        String DcrId = createDCR(a.id, 'Approved');
        string DCR = [SELECT name FROM Data_Change_Request_vod__c WHERE Account_vod__c=: a.id LIMIT 1].name;
        
        /*Contact con = new Contact();
con.FirstName= a.Name;
con.AccountId=a.Id;
con.Email=a.Email_Internal_AGN__c;
insert con;*/
        
        Child_Account_vod__c ChAcc = new Child_Account_vod__c();
        ChAcc.Child_Account_vod__c = loc.Clinic_Admin_AGN__c;
        ChAcc.Parent_Account_vod__c = a.Id;
        ChAcc.Copy_Address_vod__c = True;
        ChAcc.External_ID_vod__c = a.Id+'__'+loc.Id;
        
         //Adding checkmarx comment
             try{
                	List<Child_Account_vod__c> Chdaccountinsert = new List<Child_Account_vod__c>();
           			Chdaccountinsert.add(ChAcc); 
                    String objAcc = 'Child_Account_vod__c';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Chdaccountinsert,accObjType,'INSERT');
                    insert Chdaccountinsert;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the childaccount insert:'+ex);
			}
        //End
        // insert ChAcc;
        if(loc.IsChildClinic_AGN__c)	
            {
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId=a.Id;
        AccountContactRelation conacr = [Select ContactId from AccountContactRelation where AccountId=:loc.Clinic_Admin_AGN__c limit 1];
        acr.ContactId=conacr.ContactId;    
        
        //------CheckMarx Phase2--Added on 24/09/2020-------------------------------
        list<AccountContactRelation> accconrelList= new list<AccountContactRelation>();
        accconrelList.add(acr);
        String objAccconrel = 'AccountContactRelation';
        SObjectType accconrelObjType = ((SObject)(Type.forName('Schema.'+objAccconrel).newInstance())).getSObjectType();
        AGN_FLSCheck.check(accconrelList,accconrelObjType,'INSERT');
        //------CheckMarx Phase2--Ends here------------------------------------------------------
        insert acr;
            }
        loc.Account_AGN__c = a.Id;
        loc.AGN_Business_Account__c=a.Id;           
        loc.DCR_Reference_Number_AGN__c=DCR;
        }
            loc.Active_AGN__c=True;
          // update loc;
       //Adding checkmarx comment  
          try{
                	List<Locator_Listing_AGN__c> updateloclist = new List<Locator_Listing_AGN__c>();
           			updateloclist.add(loc); 
                    String objAcc = 'Locator_Listing_AGN__c';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(updateloclist,accObjType,'UPDATE');
                    update updateloclist;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the locator listing update:'+ex);
			}
        //End
         if(loc.IsChildClinic_AGN__c==true) //Line of code has been change as a part of DCR Enablement
         {
            AGN_ICL_SendEmailNotification.sendSingleMailLoc(loc,'AGN_ICL_Child_Clinic_Account_Created');
         }	
        
    }
    
    //Line of code has been added as a part of DCR Enablement 	
    // AGN_Account_SendToDP_DCR.createDCR(accId, DCR_note)  	
    public static String createDCR(String accId, String DCR_note){	
        try{	
            return AGN_Account_SendToDP_DCR.createDCR(accId, DCR_note);	
        }	
        catch (Exception e) {	
            // "Convert" the exception into an AuraHandledException	
            throw new AuraHandledException(e.getMessage()); 	
        }
    }
        
}