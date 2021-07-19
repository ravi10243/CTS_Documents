public without sharing class AGN_AMI_Search_Controller {
    User user;
    // DQ - HCP Harmonization Start
    Account accountRecord;
    // DQ - HCP Harmonization End
    public string selvalue{get;set;}
    public List<AMI_Lrn_Rel_Dtl_AGN__c> lstALRDResult{get;set;}
    Set<Id> setCurrId = new set<ID>();
    Set<Id> setProgId = new set<ID>();
    Set<Id> setModId = new set<ID>();
    Set<Id> setFacultyId = new set<ID>();
    public integer modcount{get;set;}
    public String lRDId {get; set;}
    public String userLanguage{get;set;}
    List<AMI_HCP_Profile_AGN__c> hCPProfile;
    String userCountryName;
    public string sortType {get; set;}
    string curriculumrecType;
    string modulerecType;
    string programrecType;
    public AGN_AMI_Search_Controller()
    {   
        curriculumrecType=[Select id from RecordType where SobjectType = 'AMI_Learning_AGN__c' AND DeveloperName = 'Curriculum'][0].id;
        modulerecType=[Select id from RecordType where SobjectType = 'AMI_Learning_AGN__c' AND DeveloperName = 'Module'][0].id;
        programrecType=[Select id from RecordType where SobjectType = 'AMI_Learning_AGN__c' AND DeveloperName = 'Program'][0].id;
        string srchval;                
        selvalue = ApexPages.currentPage().getParameters().get('Search');
        srchval = '*'+ selvalue + '*';
        
        List<List <sObject>> searchList = [FIND :srchval IN ALL FIELDS RETURNING  
                                           AMI_Learning_AGN__c (Id,recordtypeid),
                                           AMI_Objective_AGN__c(Parent_Module_AGN__c,Parent_Module_AGN__r.recordtypeid)];
        
        system.debug(searchList);
        
        if(((List <AMI_Learning_AGN__c>)searchList[0]).size() > 0 || (List <AMI_Learning_AGN__c>)searchList[0] != null)
        {
            for(AMI_Learning_AGN__c a:(List <AMI_Learning_AGN__c>)searchList[0])
            {

                if(a.recordtypeid == curriculumrecType)          
                {
                    setCurrId.add(a.Id);
                }

                else if(a.recordtypeid == programrecType)
                {
                    setProgId.add(a.Id);
                }

                else if(a.recordtypeid == modulerecType)
                {
                    setModId.add(a.Id);
                }
            }
        }
        
        if(((List <AMI_Objective_AGN__c>)searchList[1]).size() > 0 || (List <AMI_Objective_AGN__c>)searchList[1] != null)
        {
            for(AMI_Objective_AGN__c b:(List <AMI_Objective_AGN__c>)searchList[1])
            {
      
                if(b.Parent_Module_AGN__r.recordtypeid == curriculumrecType)
                {
                    setCurrId.add(b.Parent_Module_AGN__c);
                }
     
                else if(b.Parent_Module_AGN__r.recordtypeid == modulerecType)
                {
                    setModId.add(b.Parent_Module_AGN__c);
                }
            }
        }        
        GetModuleDeatils();        
    }     
    
    public void GetModuleDeatils()
    {
        
        Id SetUserSpec; 
        Id UsrCountry; 
        Set<Id> SetUserResc = new set <Id>(); 
        String SetUsertype; 
        Set<Id> SetUserspecificmodules = new set <Id>();
        set<Id> setALRDResult = new set<Id>();
        set<Id> setfacId = new set<Id>();
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        // DQ - HCP Harmonization Start
        accountRecord = userDetails.accountRecord;
        // DQ - HCP Harmonization End
        /* Removed 
        List<Account> LstUserDetails = [Select Id,
                                        Name,
                                        AMI_Specialty_AGN__c,
                                        Type_AGN__c,
                                        Country_vod__c
                                        from Account 
                                        where Id =:UserId limit 1];
        
        System.debug(LstUserDetails);
        for(Account spec:LstUserDetails)
        {
            SetUserSpec = spec.AMI_Specialty_AGN__c;
            SetUsertype = spec.Type_AGN__c;
            UsrCountry = spec.Country_vod__c;
        }
        */
        hCPProfile = [Select Id,
                      Account_AGN__c,
                      Injector_Status_AGN__c 
                      from AMI_HCP_Profile_AGN__c 
                      where Account_AGN__c = :accountRecord.Id limit 1];
        string injecstatus = hCPProfile.size()>0?hCPProfile[0].Injector_Status_AGN__c:null; 
      //  List<AMI_Module_Restriction_AGN__c> LstUserresModule = [Select AMI_Learning_agn__c
      //                                                          from AMI_Module_Restriction_AGN__c 
      //                                                          where AMI_Specialty_AGN__c = :SetUserSpec
      //                                                          and Injector_Status_AGN__c=: injecstatus];    
        
        
      //  for(AMI_Module_Restriction_AGN__c a:LstUserresModule )
      //  {
      //      SetUserResc.add(a.AMI_Learning_agn__c);
      //  }
      // Added to fix restriction issue
        SetUserSpec = accountRecord.AMI_Specialty_AGN__c;
        SetUsertype = accountRecord.Type_AGN__c;
        // Added to fix restriction issue  
        List<AMI_Module_Visibility_AGN__c> LstUserresModule = [Select AMI_Learning_agn__c
                                                                from AMI_Module_Visibility_AGN__c 
                                                                where AMI_Specialty_AGN__c = :SetUserSpec
                                                                and Injector_Status_AGN__c=: injecstatus];    
      
        for(AMI_Module_Visibility_AGN__c a:LstUserresModule )
        {
            SetUserResc.add(a.AMI_Learning_agn__c);
        } 
        
        List<AMI_HCP_modules_AGN__c  > LstUserspecModule =[Select AMI_Module_AGN__c
                                                           from AMI_HCP_modules_AGN__c  
                                                           where AMI_Account_AGN__c = :accountRecord.Id ];   
        
        
        for(AMI_HCP_modules_AGN__c b:LstUserspecModule )
        {
            SetUserspecificmodules.add(b.AMI_Module_AGN__c);
        }                                  
        
        List<AMI_Lrn_Rel_Dtl_AGN__c> lstALRD = [Select Curriculum_AGN__c,
                                                Curriculum_Fma_AGN__c,
                                                Module_AGN__c,
                                                Module_Fma_AGN__c,
                                                Program_AGN__c,
                                                Program_Fma_AGN__c,
                                                Module_AGN__r.Anatomy_Area_AGN__c,
                                                Module_AGN__r.Module_Content_Type_AGN__c,
                                                Module_AGN__r.Module_format_AGN__c,
                                                Module_AGN__r.Tags_AGN__c,
                                                Module_AGN__r.Description_AGN__c,
                                                Module_AGN__r.Module_Duration_AGN__c,
                                                Module_AGN__r.Duration_FMA_AGN__c,
                                                Module_AGN__r.AMI_Image_URL_AGN__c,
                                                Module_AGN__r.AMI_Recommended_AGN__c,
                                                Module_AGN__r.LastModifiedDate,
                                                LastModifiedDate, 
                                                Country_AGN__c,
                                                Module_AGN__r.Restricted_AGN__c
                                                from AMI_Lrn_Rel_Dtl_AGN__c
                                                where Country_AGN__r.Name =: userCountryName and Active_AGN__c = true];   
        
        lstALRDResult = new List<AMI_Lrn_Rel_Dtl_AGN__c>();                                            
        
        for(AMI_Lrn_Rel_Dtl_AGN__c alrd:lstALRD) 
        {
            if(alrd.Module_AGN__r.Restricted_AGN__c)
            {
                if(SetUserspecificmodules.contains(alrd.Id) || SetUserResc.contains(alrd.Module_AGN__c))
                {
                    if(setCurrId.contains(alrd.Curriculum_AGN__c)||setProgId.contains(alrd.Program_AGN__c)||setModId.contains(alrd.Module_AGN__c))
                    {
                        lstALRDResult.add(alrd);
                        setALRDResult.add(alrd.Module_AGN__c); 
                    }                    
                }
            }
            else
            {
                if(setCurrId.contains(alrd.Curriculum_AGN__c)||setProgId.contains(alrd.Program_AGN__c)||setModId.contains(alrd.Module_AGN__c))
                {
                    lstALRDResult.add(alrd);
                    setALRDResult.add(alrd.Module_AGN__c); 
                }                
            }           
            modcount = lstALRDResult.size();            
        }                  
    }    
    
    public pagereference GoToModuleDetails()
    {
        Pagereference pr=new PageReference(System.Label.AGN_AMI_Module_Details_Page);
        pr.setRedirect(true);
        pr.getParameters().put('lRDId',ApexPages.currentPage().getParameters().get('moduleId'));                 
        return pr;
    }
    public void sort()
    {
        system.debug('sortType--'+sortType);                     
        /* Sort Logic */
        List<AGN_AMI_LRD_Sort> ALS = new List<AGN_AMI_LRD_Sort>();
        for(AMI_Lrn_Rel_Dtl_AGN__c ALRD : lstALRDResult)
            ALS.add(new AGN_AMI_LRD_Sort(ALRD,sortType));        
        ALS.sort();        
        for(integer a=0;a<lstALRDResult.size();a++)
        {
            lstALRDResult[a]=ALS[a].ALRD;
        }        
    }    
}