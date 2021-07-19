/* Modified by :ICL Project Team
   Decription : 1.Added New method CallApprovalProcess ()  for Spring 21 release by salesforce to call an apporval process from batch class.
                2.Added new method isCluster() as a  part of ICL wave 3 development for cluster country logic.
                3.Added getVaultFromLoc() and getVaultLoggedUser()  as a part of Vault Code Changes for LATAM.
                4.Added line 24 as a  part of ICL wave 3 development for cluster country logic. 
				5.Added isCaslConsentEnabled method as a part of CASL Consent for Canada
				6.Added getMultipicklistBrand method as a part Duallist Box Logic Brand
				7.Added isTwoLayerLayout method as a part of Two Column Layout for Canada
				8.Added CaslConsent and calculateExpirationDate to create multichannel consent for CASL Consent(Canada) as apart of ICL Project
   Release :ICL Wave-3
*/
public without Sharing class AGN_ICL_UtlityClass {   
    
    public static List<PicklistWrapper> getPicklistValues(String SObjectAPIName,String FieldAPIName,String countryCode)
    {
        List<PicklistWrapper> piclistval = new List<PicklistWrapper>();
        List<PicklistWrapper> restrictval = new List<PicklistWrapper>();
        Set<String> valueSet = new Set<String>();
        Set<String> restrictedSet = new Set<String>();
        if(SObjectAPIName=='Account' && FieldAPIName =='Salutation'){            
            SObjectAPIName = 'Locator_Listing_AGN__c';
            FieldAPIName = 'Salutation_AGN__c';
        }
       
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(SObjectAPIName).getDescribe().fields.getMap().get(FieldAPIName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){           
            piclistval.add(new PicklistWrapper(f));
        }        
        try{
            AGN_ICL_Allowable_Picklist_Value__mdt restrictSettingObj = new AGN_ICL_Allowable_Picklist_Value__mdt();
            //Added as a  part of ICL wave 3 development for cluster country logic.
            countryCode = AGN_ICL_UtlityClass.isCluster(countryCode);
            restrictSettingObj = [SELECT Value_AGN__c,Country_Code_AGN__c,Field_Name_AGN__c
                                  FROM AGN_ICL_Allowable_Picklist_Value__mdt 
                                  WHERE Country_Code_AGN__c =:countryCode 
                                  AND Field_Name_AGN__c =:FieldAPIName AND Object_API_Name_AGN__c =:SObjectAPIName LIMIT 1];            
            
            if(String.isNotBlank(restrictSettingObj.Value_AGN__c)){
                List<String> pickList_List = restrictSettingObj.Value_AGN__c.split(',');                                       
                for(String pickList : pickList_List){                      
                    restrictedSet.add(pickList.trim());                       
                } 
            }    
            for(String str1:restrictedSet){                
                for( Schema.PicklistEntry f : ple){
                    if(f.getLabel()==str1){
                        restrictval.add(new PicklistWrapper(f));
                        break; 
                    }
                }
            }
            if(restrictval.size()>0){
                return restrictval;
            }
        }
        catch(exception ex){
            
        }
        
        return piclistval;
    }
    public class PicklistWrapper {
        @AuraEnabled public String label           {get;private set;}
        @AuraEnabled public String value           {get;private set;}
        @AuraEnabled public Boolean isDefaultValue {get;private set;}
        
        public PicklistWrapper() {
            this.label          = '';
            this.value          = '';
            this.isDefaultValue = false;
        }
        
        public PicklistWrapper(Schema.PicklistEntry picklistEntry) {
            this.label          = picklistEntry.getLabel();
            this.value          = picklistEntry.getValue();
            this.isDefaultValue = picklistEntry.isDefaultValue();
        }
        public PicklistWrapper(String label, String value, Boolean isDefaultValue) {
            this.label          = label;
            this.value          = value;
            this.isDefaultValue = isDefaultValue;
        }
    }
    
    
    public static List<String> getBrandPicklistValues(String countryCode)
    {      
        List<String> brandPicklistval = new List<String>();
        List<String> brandList = new List<String>();
        Set<String> brandSet = new Set<String>();
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Locator_Listing_AGN__c').getDescribe().fields.getMap().get('Brand_AGN__c').getDescribe();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for( Schema.PicklistEntry f : ple){
            brandSet.add(f.getLabel());
        }
        try{
            countrySetting = [SELECT Brand_Values_AGN__c 
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:countryCode 
                              LIMIT 1];
           
            if(countrySetting.Brand_Values_AGN__c!=null|| countrySetting.Brand_Values_AGN__c!='')
            {
                brandList.addAll(countrySetting.Brand_Values_AGN__c.split(','));
            }       
            if(brandList.size()>0){
                for(String str:brandList){
                    if(brandSet.contains(str.trim())){
                        brandPicklistval.add(str.trim());
                    }
                }
                if(brandPicklistval.size()>0)
                {
                    return brandPicklistval;
                }
                
            } 
        }catch(exception ex){
            
        }
        brandPicklistval.addAll(brandSet);
        return brandPicklistval;
    }
    
    
    public static Boolean getDisclaimerSettings(String countryCode)
    {   
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        try{
            countrySetting = [SELECT Enable_HCP__c,Show_CT_Disclaimer_AGN__c 
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:countryCode 
                              LIMIT 1];
        }
        catch(exception ex){
            
        }        
        return countrySetting.Show_CT_Disclaimer_AGN__c;
    }
    
    
    public static Boolean getHCPEnableStatus(String countryCode)
    {   
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        try{
            countrySetting = [SELECT Enable_HCP__c,Show_CT_Disclaimer_AGN__c 
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:countryCode 
                              LIMIT 1];
        }
        catch(exception ex){
            
        }        
        return countrySetting.Enable_HCP__c;
    }
    
    
    public static Boolean isClinicConsentEnabled(String countryCode)
    {   
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        try{
            countrySetting = [SELECT Enable_HCP__c,Show_CT_Disclaimer_AGN__c,Enable_Clinic_Consent_AGN__c 
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:countryCode 
                              LIMIT 1];
        }
        catch(exception ex){
            
        }        
        return countrySetting.Enable_Clinic_Consent_AGN__c;
    }
    //Added below method as a part of CASL Consent for Canada
    public static Boolean isCaslConsentEnabled(String countryCode)
    {   
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        try{
            countrySetting = [SELECT CASL_Consent_AGN__c 
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:countryCode 
                              LIMIT 1];
        }
        catch(exception ex){
            
        }        
        return countrySetting.CASL_Consent_AGN__c;
    }
    // End
    
     // Duallist Box Logic added for Brand 
       public static String getMultipicklistBrand(){
       AGN_ICL_Portal_Settings__c mc = AGN_ICL_Portal_Settings__c.getOrgDefaults();
       return mc.Multipicklist_Brand_Count_AGN__c;}
     // Duallist Box Logic added for Brand 
   
           
    //Added as a part of Two Column Layout for Canada
     public static Boolean isTwoLayerLayout(String countryCode)
    {   
        
        List<AGN_ICL_Country_Settings__c > countryval=[select Name,Country_AGN__c,Enable_Two_Column_Layout_AGN__c from AGN_ICL_Country_Settings__c where Country_AGN__c = :countryCode ];
        if(!countryval.isEmpty() && countryval.size() > 0){
            return countryval[0].Enable_Two_Column_Layout_AGN__c;
        }
        return null;
        
    }
    //End
    public static String getPrivacyLinkURLFromLoc(string LocId){
        
        String privacyLink = Label.AGN_ICL_Defualt_Privacy_Link;
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        
        try{
            Locator_Listing_AGN__c locObj = [SELECT id, Country_Code_AGN__r.Alpha_2_Code_vod__c 
                                             FROM Locator_Listing_AGN__c 
                                             WHERE id =:LocId
                                             LIMIT 1];
            countrySetting = [SELECT Country_AGN__c,PrivacyLink_AGN__c 
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:locObj.Country_Code_AGN__r.Alpha_2_Code_vod__c 
                              LIMIT 1];
            
            if(String.isNotBlank(countrySetting.PrivacyLink_AGN__c)){
                privacyLink = countrySetting.PrivacyLink_AGN__c;
                return privacyLink;
            }            
        }
        catch(exception ex){
            
          
        }        
        return privacyLink;
    }
    
    public static String getPrivacyLinkLoggedUser(){
        
        String privacyLink = Label.AGN_ICL_Defualt_Privacy_Link;
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        
        try{
            User u = [SELECT id,name,Country_Code__c  
                      FROM User 
                      WHERE id =:UserInfo.getUserId()];
            countrySetting = [SELECT Country_AGN__c,PrivacyLink_AGN__c 
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:u.Country_Code__c 
                              LIMIT 1];
            
            if(String.isNotBlank(countrySetting.PrivacyLink_AGN__c)){
                privacyLink = countrySetting.PrivacyLink_AGN__c;
                return privacyLink;
            }            
        }
        catch(exception ex){
            
           
        }        
        return privacyLink;
    }
    // Added as a part of Vault Code Changes for LATAM
        public static String getVaultFromLoc(string LocId){
        String VaultCode = '';
        AGN_ICL_VaultCode__mdt countrySetting = new AGN_ICL_VaultCode__mdt();
        
        try{
            Locator_Listing_AGN__c locObj = [SELECT id, Country_Code_AGN__r.Alpha_2_Code_vod__c 
                                             FROM Locator_Listing_AGN__c 
                                             WHERE id =:LocId
                                             LIMIT 1];
            countrySetting = [SELECT Country_Code__c,Vault_value__c 
                              FROM AGN_ICL_VaultCode__mdt 
                              WHERE Country_Code__c =:locObj.Country_Code_AGN__r.Alpha_2_Code_vod__c 
                              LIMIT 1];
            
            if(String.isNotBlank(countrySetting.Vault_value__c)){
                VaultCode = countrySetting.Vault_value__c;
                return VaultCode;
            }            
        }
        catch(exception ex){
            
          
        }        
        return VaultCode;
    }
   
     public static String getVaultLoggedUser(){
        
        String VaultCode = '';
        AGN_ICL_VaultCode__mdt countrySetting = new AGN_ICL_VaultCode__mdt();
        
        try{
            User u = [SELECT id,name,Country_Code__c  
                      FROM User 
                      WHERE id =:UserInfo.getUserId()];
            countrySetting = [SELECT Country_Code__c,Vault_value__c
                              FROM AGN_ICL_VaultCode__mdt 
                              WHERE Country_Code__c =:u.Country_Code__c 
                              LIMIT 1];
            
            if(String.isNotBlank(countrySetting.Vault_value__c)){
                VaultCode = countrySetting.Vault_value__c;
                return VaultCode;
            }            
        }
        catch(exception ex){
            
           
        }        
        return VaultCode;
    }
    //END
    public static String getCountry(String country)
    {
        AGN_ICL_Country_Settings__c  countryval=[SELECT Name,Country_AGN__c 
                                                 FROM AGN_ICL_Country_Settings__c 
                                                 WHERE Country_AGN__c = :country 
                                                 LIMIT 1 ];
        return countryval.Name;
    }
    
    public static String fetchUsercountry()
    {
        User u = [Select Country_Code__c from User where Id=: UserInfo.getUserId() LIMIT 1]; 
        return u.Country_Code__c;
    }
    
    //Thailand CR
    public static Boolean isClinicImageEnabled(String countryCode)
    {   
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        try{
            countrySetting = [SELECT Enable_HCP__c,Show_CT_Disclaimer_AGN__c,Enable_Clinic_Timing__c ,Enable_Clinic_Image__c    
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:countryCode 
                              LIMIT 1];
        }
        catch(exception ex){
           
        }        
        return countrySetting.Enable_Clinic_Image__c;
    }
    
    public static Boolean isClinicTimingEnabled(String countryCode)
    {   
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        try{
            countrySetting = [SELECT Enable_HCP__c,Show_CT_Disclaimer_AGN__c,Enable_Clinic_Timing__c 
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:countryCode 
                              LIMIT 1];
        }
        catch(exception ex){
           
        }        
        return countrySetting.Enable_Clinic_Timing__c;
    }   
    //Thailand CR
    //Cluster Changes    
    public static String isCluster(String countryCode) {    
        String user_country_CLUSTER = countryCode;  
        Boolean is_CLUSTER = false; 
        List<AGN_ICL_CLUSTER_Mapping__mdt> clusterSettings = new List<AGN_ICL_CLUSTER_Mapping__mdt>([Select AGN_ICL_Child_Country_Code__c,AGN_ICL_Parent_Country_Code__c from AGN_ICL_CLUSTER_Mapping__mdt Where MasterLabel =:countryCode ]) ; 
        if(clusterSettings.size() > 0){ 
            for(AGN_ICL_CLUSTER_Mapping__mdt m:clusterSettings){    
                if(user_country_CLUSTER != null || user_country_CLUSTER != ''){ 
                    user_country_CLUSTER=m.AGN_ICL_Parent_Country_Code__c;  
                    is_CLUSTER = true;  
                }   
            }   
        }   
        return user_country_CLUSTER;    
    } 
   //Added below methods to create multichannel consent for CASL Consent(Canada) as apart of ICL Project
    public static void CaslConsent(Boolean caslConsent,Id accId, String Language,String CountryCode){
        String optType;
       
        Consent_Type_vod__c ct = [SELECT Id,Consent_Expires_In_vod__c,Consent_Custom_Duration_vod__c from Consent_Type_vod__c where Consent_Header_vod__r.Country_vod__r.Name =:CountryCode and Consent_Header_vod__r.Language_vod__c =:Language and RecordType.name='CASL Consent'];
        Id recordTypeId = Schema.SObjectType.Multichannel_Consent_vod__c.getRecordTypeInfosByDeveloperName().get('CASL_Consent_AGN').getRecordTypeId();
        List<Multichannel_Consent_vod__c> mclist=new List<Multichannel_Consent_vod__c>();
        Multichannel_Consent_vod__c mConsent = new Multichannel_Consent_vod__c();
        mConsent.RecordtypeId = recordTypeId;
        mConsent.Account_vod__c =  accId;
        if(caslConsent){
        optType = 'Opt_In_vod';
        }else{
        optType = 'Opt_Out_vod';
   
        }
    	mConsent.Opt_Type_vod__c =  optType;
        mConsent.Opt_Expiration_Date_vod__c = ((ct != null && optType == 'Opt_In_vod') ? calculateExpirationDate(ct.Consent_Expires_In_vod__c, ct.Consent_Custom_Duration_vod__c) : null);
        mConsent.Capture_Datetime_vod__c = System.now();
        mConsent.Consent_Type_vod__c = ((ct != null) ? ct.Id : null);
        mConsent.Last_Device_vod__c = 'Online_vod';
        mclist.add(mConsent);
        if(!mclist.isempty())
           {
               String objloc = 'Multichannel_Consent_vod__c';
               SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objloc).newInstance())).getSObjectType();
               AGN_FLSCheck.check(mclist,locObjType,'INSERT');
               insert mclist;
           }   
           }
    public static Date calculateExpirationDate(String consentDateValue, Decimal duration)
    {
        Date expiryDate = System.today();
        
        if(consentDateValue == 'Custom_Duration_vod' && duration != null && duration != 0)
        {
            expiryDate = expiryDate.addMonths(Integer.valueOf(duration));
        }
        else if(consentDateValue == 'One_Year_vod')
        {
            expiryDate = expiryDate.addYears(1);
        }
        else if(consentDateValue == 'End_Of_Calendar_Year_vod')
        {
            expiryDate = Date.newInstance(expiryDate.year(), 12, 31);
        }
        else if(consentDateValue == 'End_Of_Next_Calendar_Year_vod')
        {
            expiryDate = Date.newInstance(expiryDate.year()+1 , 12, 31);
        }
        else
            expiryDate = null;
             
        return expiryDate;      
    }
    //END
    
  //New method added for Spring 21 release by salesforce to call an apporval process from batch class.
    
    public static void CallApprovalProcess(List<Locator_Listing_AGN__c> loclist)
    {
        String iclowner = System.Label.AGN_ICL_Owner;
        User us=[select Id from User where name = :iclowner];
        Set<Locator_Listing_AGN__c> setloclist=new Set<Locator_Listing_AGN__c>();
        setloclist.addall(loclist);
       //Locator_Listing_Rejected_AGN__c llr=new Locator_Listing_Rejected_AGN__c();
        List<Locator_Listing_Rejected_AGN__c> newlistllr=new List<Locator_Listing_Rejected_AGN__c>();
         String objloc = 'Locator_Listing_Rejected_AGN__c';
         SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objloc).newInstance())).getSObjectType();
       
         for(Locator_Listing_AGN__c loc : setloclist)
        {
                
                 Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
                 req.setObjectId(loc.id);
                 req.setProcessDefinitionNameOrId('AGN_ICL_First_Level_Approval');
                 req.setSubmitterId(us.Id);
                 Approval.ProcessResult result = Approval.process(req); 
                List<Locator_Listing_Rejected_AGN__c> listllr=[Select Id,Submitted_for_Approval_AGN__c from Locator_Listing_Rejected_AGN__c where Locator_Listing_AGN__c=:loc.id];
                for(Locator_Listing_Rejected_AGN__c llr:listllr )
                {
                    llr.Id=llr.id;
                    llr.Submitted_for_Approval_AGN__c=true;
                    newlistllr.add(llr);
                   
                    AGN_FLSCheck.check(newlistllr,locObjType,'UPDATE');
                              
                }
                
                
        }
        if(!newlistllr.isEmpty())
        {
            update newlistllr;
        }
        
    }
    
     public static void CaseReopen(List<Locator_Listing_AGN__c> loclist)
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
            
            if(loc.Case_Reopen_AGN__c )
            {
                caseIds.add(loc.ICL_Registration_Case__c);
                

                loc.Approval_Status__c = 'Pending';
                updlistloc.add(loc);
            }
        }
               getCaseList= [select id,status from case where id in :caseIds];
                for(Case caseRec :getCaseList){
                    caseRec.status = 'Reopen';
                    updateCaseList.add(caseRec);
                } 
                try {
                    if(!updlistloc.isEmpty() && !updateCaseList.isEmpty())
                    {
                        update updateCaseList;
                        update updlistloc;
                    }
                    
                }
             catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
             }
        
    }
    
}