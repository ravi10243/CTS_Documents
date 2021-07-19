/* New batch class created to mitigate the changes done by Salesforce for Spring 21 release.
This batch class class an approval process when the locator listing has been submitted by the clinic admin for both child and parent clinics.
Created by: ICL Project Team
*/

global with sharing class AGN_ICL_LocatorlistingCaseapprovalbatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
    return Database.getQueryLocator([select id,IsUpdatedByAdmin_AGN__c,AGN_ICL_Validated_with_Approval_1__c,AGN_ICL_Validated_with_Approval_2__c,First_Level_Clinic_Approver_AGN__c,Country_AGN__c,Approval_Status__c,Country_Code_AGN__c,ICL_Registration_Case__c from Locator_Listing_AGN__c 
                                     where Active_AGN__c=False and Data_Loaded_AGN__c=False and Approval_Status__c NOT IN ('Approved','Pending')]) ;
    }
    global void execute(Database.BatchableContext BC, List<Locator_Listing_AGN__c> loclist)
    {
     List<Locator_Listing_AGN__c> updlistloc= new List<Locator_Listing_AGN__c>();
        Locator_Listing_AGN__c updloc=new Locator_Listing_AGN__c();
        String objloc = 'Locator_Listing_AGN__c';
         SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objloc).newInstance())).getSObjectType();
        for(Locator_Listing_AGN__c loc : loclist)
        {
            if(loc.Approval_Status__c=='Rejected'||loc.Approval_Status__c=='Finally Rejected')
            {
              List<Locator_Listing_Rejected_AGN__c> llr=[SELECT About_the_Practice_AGN__c,Account_ID_AGN__c,Active_AGN__c,AGN_ICL_Validated_with_Approval_1__c,AGN_ICL_Validated_with_Approval_2__c,Approval_Status__c,Ask_Question_Email_AGN__c,BD_Participant_AGN__c,Book_Consultation_AGN__c,Brand_AGN__c,City_AGN__c,Clinical_Investigator_AGN__c,Clinic_Admin_Email_AGN__c,Clinic_Consent_AGN__c,Clinic_Experience_AGN__c,Clinic_Experience_Site_AGN__c,Clinic_Image_AGN__c,Clinic_Type_AGN__c,Consent_AGN__c,Country_AGN__c,Country_Shadow_AGN__c,CreatedById,CreatedDate,CurrencyIsoCode,Data_Loaded_AGN__c,DCR_Reference_Number_AGN__c,DT_Update_AGN__c,Email_AGN__c,Enquiriy_Email_AGN__c,First_Level_Clinic_Approver_AGN__c,Friday_Close_Hours_AGN__c,Friday_Open_Hours_AGN__c,GeoLocation_AGN__c,GeoLocation_AGN__Latitude__s,GeoLocation_AGN__Longitude__s,Google_Url_AGN__c,Google_URL_France_AGN__c,Id,IsChildClinic_AGN__c,IsDeleted,IsLocked,IsUpdatedByAdmin_AGN__c,LastActivityDate,LastModifiedById,LastModifiedDate,Locator_Listing_AGN__c,MAB_Distinction_AGN__c,MayEdit,Monday_Close_Hours_AGN__c,Monday_Open_Hours_AGN__c,Name,Number_of_Locator_Listings_AGN__c,Offer_Evenings_AGN__c,Open_Evenings_Email_AGN__c,Password_Activation_link_AGN__c,Patient_Financing_Provider_ID_AGN__c,Patient_Financing_Status_AGN__c,Patient_Financing_URL_AGN__c,Patient_Plan_ID_AGN__c,Phone_Number_AGN__c,Physician_Image_AGN__c,Physician_Name_AGN__c,Picture_Available_AGN__c,Registered_For_Clinic_Locator_AGN__c,Registered_from_OAM_AGN__c,Rejected_Message_AGN__c,Request_Call_Email_AGN__c,Salutation_AGN__c,Saturday_Close_Hours_AGN__c,Saturday_Open_Hours_AGN__c,Second_Level_Clinic_Approver_AGN__c,State_Providence_Region_AGN__c,Street_AGN__c,Sunday_Close_Hours_AGN__c,Sunday_Open_Hours_AGN__c,SystemModstamp,Testimonial_Available_AGN__c,Test_URL__c,Thursday_Close_Hours_AGN__c,Thursday_Open_Hours_AGN__c,Tuesday_Close_Hours_AGN__c,Tuesday_Open_Hours_AGN__c,User_Language_AGN__c,VIP_AGN__c,Website_AGN__c,Wednesday_Close_Hours_AGN__c,Wednesday_Open_Hours_AGN__c,Zip_Code_AGN__c,Case_Reopen_AGN__c FROM Locator_Listing_Rejected_AGN__c where Locator_Listing_AGN__c=:loc.Id and Submitted_for_Approval_AGN__c=false order by createddate desc limit 1]; 
              
              if(!llr.IsEmpty()) 
                {
                    for(Locator_Listing_Rejected_AGN__c loclr:llr)
                    {
                        updloc.ICL_Registration_Case__c=loc.ICL_Registration_Case__c;
                        updloc.Id=loclr.Locator_Listing_AGN__c;
                        updloc.IsUpdatedByAdmin_AGN__c=loclr.IsUpdatedByAdmin_AGN__c;
                        updloc.Name = loclr.Name;
                        updloc.Email_AGN__c = loclr.Email_AGN__c;
                        updloc.Street_AGN__c = loclr.Street_AGN__c;
                        updloc.Testimonial_Available_AGN__c = loclr.Testimonial_Available_AGN__c;
                        updloc.Offer_Evenings_AGN__c = loclr.Offer_Evenings_AGN__c;
                        updloc.Request_Call_Email_AGN__c = loclr.Request_Call_Email_AGN__c;
                        updloc.Open_Evenings_Email_AGN__c = loclr.Open_Evenings_Email_AGN__c;
                        updloc.Ask_Question_Email_AGN__c = loclr.Ask_Question_Email_AGN__c;
                        updloc.Enquiriy_Email_AGN__c = loclr.Enquiriy_Email_AGN__c;
                        updloc.Google_Url_AGN__c = loclr.Google_Url_AGN__c;
                        updloc.Website_AGN__c = loclr.Website_AGN__c;
                        updloc.Book_Consultation_AGN__c  = loclr.Book_Consultation_AGN__c;
                        updloc.Clinic_Experience_AGN__c = loclr.Clinic_Experience_AGN__c;
                        updloc.City_AGN__c = loclr.City_AGN__c;
                        updloc.State_Providence_Region_AGN__c = loclr.State_Providence_Region_AGN__c;
                        updloc.Zip_Code_AGN__c = loclr.Zip_Code_AGN__c;
                        updloc.Country_AGN__c = loclr.Country_AGN__c;
                        updloc.Brand_AGN__c = loclr.Brand_AGN__c;
                        updloc.Clinic_Experience_Site_AGN__c = loclr.Clinic_Experience_Site_AGN__c;
                        updloc.Phone_Number_AGN__c = loclr.Phone_Number_AGN__c;
                  
                        
                        Country_vod__c ct=[Select id,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c from country_vod__c where id=:loc.Country_Code_AGN__c ];
                        updloc.First_Level_Clinic_Approver_AGN__c = ct.First_Level_Clinic_Approver_AGN__c;
                        if(ct.Second_Level_Clinic_Approver_AGN__c != null)
                       {
                          updloc.Second_Level_Clinic_Approver_AGN__c = ct.Second_Level_Clinic_Approver_AGN__c;
                       }
               
              
                
                    updloc.Monday_Open_Hours_AGN__c = loclr.Monday_Open_Hours_AGN__c;
                    updloc.Monday_Close_Hours_AGN__c = loclr.Monday_Close_Hours_AGN__c;
                    updloc.Tuesday_Open_Hours_AGN__c = loclr.Tuesday_Open_Hours_AGN__c;
                    updloc.Tuesday_Close_Hours_AGN__c = loclr.Tuesday_Close_Hours_AGN__c;
                    updloc.Wednesday_Open_Hours_AGN__c = loclr.Wednesday_Open_Hours_AGN__c;
                    updloc.Wednesday_Close_Hours_AGN__c = loclr.Wednesday_Close_Hours_AGN__c;
                    updloc.Thursday_Open_Hours_AGN__c = loclr.Thursday_Open_Hours_AGN__c;
                    updloc.Thursday_Close_Hours_AGN__c = loclr.Thursday_Close_Hours_AGN__c;
                    updloc.Friday_Open_Hours_AGN__c = loclr.Friday_Open_Hours_AGN__c;
                    updloc.Friday_Close_Hours_AGN__c = loclr.Friday_Close_Hours_AGN__c;
                    updloc.Saturday_Open_Hours_AGN__c = loclr.Saturday_Open_Hours_AGN__c;
                    updloc.Saturday_Close_Hours_AGN__c = loclr.Saturday_Close_Hours_AGN__c;
                    updloc.Sunday_Open_Hours_AGN__c = loclr.Sunday_Open_Hours_AGN__c;
                    updloc.Sunday_Close_Hours_AGN__c = loclr.Sunday_Close_Hours_AGN__c;
                    updloc.Final_Rejection_AGN__c=true; 
                    updloc.Case_Reopen_AGN__c=true;
                    
                    updlistloc.add(updloc);
                    
                    
                  
            
                    }
                     
              } 
            }
        
        }
        if(!updlistloc.isEmpty()){
                   try  {
                        AGN_FLSCheck.check(updlistloc,locObjType,'UPDATE');
                       Database.SaveResult[] srList = Database.update(updlistloc, false);
                       for (Database.SaveResult sr : srList) 
                       {
                           if (sr.isSuccess()) 
                           {
                             System.debug('casereopen' +updlistloc); 
                             AGN_ICL_UtlityClass.CaseReopen(updlistloc);   
                           }
               
                       }   
                    }
             catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        }    
      
    }
    global void finish(Database.BatchableContext BC) {
    }
}





  /*  global void execute(Database.BatchableContext BC, List<Locator_Listing_AGN__c> loclist)
    {
        List<Locator_Listing_AGN__c> updlistloc= new List<Locator_Listing_AGN__c>();
        Locator_Listing_AGN__c updloc=new Locator_Listing_AGN__c();
        String objloc = 'Locator_Listing_AGN__c';
        SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objloc).newInstance())).getSObjectType();
        List<Id> caseIds = new List<Id>();
        List<Case> getCaseList = new List<Case>();
        List<Case> updateCaseList = new List<Case>();
        for(Locator_Listing_AGN__c loc : loclist)
        {
            
            if(loc.Case_Reopen_AGN__c && (loc.Approval_Status__c=='Rejected'||loc.Approval_Status__c=='Finally Rejected'))
            {
                caseIds.add(loc.ICL_Registration_Case__c);
                
                getCaseList= [select id,status from case where id in :caseIds];
                for(Case caseRec :getCaseList){
                    caseRec.status = 'Reopen';
                    updateCaseList.add(caseRec);
                } 
            }
        }
        update updateCaseList;
    }
    global void finish(Database.BatchableContext BC) {
    }
}*/