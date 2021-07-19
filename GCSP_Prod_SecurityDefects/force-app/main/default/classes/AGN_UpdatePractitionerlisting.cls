public class AGN_UpdatePractitionerlisting {
     @InvocableMethod
        public static  void updaterecord(List<Account> PracId)
    {
        for(Integer i=0;i<PracId.size();i++)
        {
            
            List<Practitioner_Listing_AGN__c> pl=[select Id,Consent_Check_AGN__c from Practitioner_Listing_AGN__c where Practitioner_AGN__c=:PracId[i].Id];
        system.debug('Account'+PracId[i].Id);
            List<Practitioner_Listing_AGN__c> prl=new List<Practitioner_Listing_AGN__c>();
            if(pl.size()>0)
        {
           for(Practitioner_Listing_AGN__c pla :pl)
           {
               pla.Consent_Check_AGN__c=false;
               prl.add(pla);
           }
            update prl;
        }
            
      }
    }

}