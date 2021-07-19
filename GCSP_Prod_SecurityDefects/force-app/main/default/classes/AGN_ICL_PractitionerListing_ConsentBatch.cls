global class AGN_ICL_PractitionerListing_ConsentBatch implements Database.Batchable<sObject>,Database.Stateful {


    global Database.QueryLocator start(Database.BatchableContext bc) 
        {
            return Database.getQueryLocator([SELECT Id,Practitioner_AGN__c,First_Name_AGN__c,Last_Name_AGN__c,Clinic_AGN__c,
                                         Locator_Listing_AGN__c,Locator_Listing_AGN__r.Country_Code_AGN__c ,
                                         Locator_Listing_AGN__r.Country_Code_AGN__r.Country_Name_vod__c,
                                         Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c,
                                         Brand_AGN__c,Consent_AGN__c,CurrencyIsoCode,Email_AGN__c,Gender_AGN__c,
                                         Practitioner_Image_Available_AGN__c,Practitioner_Status_AGN__c,Qualification_AGN__c,
                                         Salutation_AGN__c,Status_AGN__c,Type_AGN__c,Type_Of_Physician_AGN__c ,Years_of_Experience_AGN__c 
                                         FROM Practitioner_Listing_AGN__c Where Consent_Check_AGN__c = false
                                         AND Practitioner_AGN__c != NULL]);   
        }


    global void execute(Database.BatchableContext bc, List<Practitioner_Listing_AGN__c> scope)
        {
            List<Practitioner_Listing_AGN__c> pl = new List<Practitioner_Listing_AGN__c>();      
            Map<id,Practitioner_Listing_AGN__c> accPracMap = new Map<id,Practitioner_Listing_AGN__c> ();
            Map<id,Multichannel_Consent_vod__c> accMCMapOptIn = new Map<id,Multichannel_Consent_vod__c> ();
            Map<id,Multichannel_Consent_vod__c> accMCMapOptOut = new Map<id,Multichannel_Consent_vod__c> ();
            
            List<Practitioner_Listing_AGN__c> pracConOpIn = new List<Practitioner_Listing_AGN__c> ();
            List<Practitioner_Listing_AGN__c> pracConOpOut = new List<Practitioner_Listing_AGN__c> ();
        
            if(scope!=null && !scope.isEmpty())
            {
                for (Practitioner_Listing_AGN__c pc: scope)
                {               
                accPracMap.put(pc.Practitioner_AGN__c,pc);
                }
                
               for(Multichannel_Consent_vod__c mc : [SELECT Id,Account_vod__c,Opt_Type_vod__c
                                                  FROM Multichannel_Consent_vod__c 
                                                  WHERE Account_vod__c IN:accPracMap.keySet() limit 1])
                 {
                    if(mc.Opt_Type_vod__c == 'Opt_In_vod')
                    {
                        accMCMapOptIn.put(mc.Account_vod__c,mc);
                    }
                    else if(mc.Opt_Type_vod__c == 'Opt_Out_vod')
                    {
                        accMCMapOptOut.put(mc.Account_vod__c,mc);
                    }
                 }           
                 
                for(Id accId: accPracMap.keySet())
                {                
                    if(accMCMapOptIn.containsKey(accId))
                    {                    
                        pracConOpIn.add(accPracMap.get(accId));
                    }
                    else if(accMCMapOptOut.containsKey(accId))
                    {
                        pracConOpOut.add(accPracMap.get(accId));

                    }
                 }
                 
                if(!pracConOpIn.isEmpty())
                {
                    for (Practitioner_Listing_AGN__c pd: pracConOpIn)
                    {
                        pd.Consent_AGN__c = True;
                        pd.Consent_Check_AGN__c= True; 
                    }
                    String obj = 'Practitioner_Listing_AGN__c';
                    SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(pracConOpIn,objType,'UPDATE');
                    update pracConOpIn;
                }
                
                if(!pracConOpOut.isEmpty())
                {
                    for (Practitioner_Listing_AGN__c pd: pracConOpOut)
                    {
                        pd.Consent_AGN__c = False;
                        pd.Consent_Check_AGN__c= True; 
                    }
                    String obj = 'Practitioner_Listing_AGN__c';
                    SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(pracConOpOut,objType,'UPDATE');
                    update pracConOpOut;
                }                 
                                                  
              }
            
        }



    global void finish(Database.BatchableContext bc)
        {
        
        }   


}