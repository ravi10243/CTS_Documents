public without sharing class AGN_AMI_Training_Modules_Page_Controller {

    public ID UserID {get;set;}
    // DQ - HCP Harmonization Start
    Account accountRecord;
    // DQ - HCP Harmonization End
    String userCountryName;
    
    public List<AMI_Learning_AGN__c> lstAL;
    public List<AMI_Lrn_Rel_Dtl_AGN__c> lstALRDMod{get;set;}
    public List<AMI_Lrn_Rel_Dtl_AGN__c> lstALRD;
    
    Id SetUserSpec; 
    Id UsrCountryCode;
    
    Set<Id> SetUserResc = new set <Id>(); 
    String SetUsertype; 
    Set<Id> SetUserspecificmodules;
    
    public Set<String> lstCurrName {get; set;}
    public List<String> lstAnatomy{get;set;}
    public Map<string,string> mapFormat{get;set;}
    public List<String> lstFormat{get;set;}
    public integer moduleCount{get;set;}
    
    public string cur{get;set;}
    public string ana{get;set;}
    public string format{get;set;}
    public String userLanguage {get;set;}
   
    public string sortType {get; set;}   //For recommened or recently added
    
       
    public String lRDId {get; set;}
    public string moduleId {get; set;}
    
    public string strCurricula{get;set;}
    public string strAnatomy{get;set;}
    public string strFormat{get;set;}
    
    List<AMI_HCP_Profile_AGN__c> hCPProfile;
    
    User user;
    
    
    public AGN_AMI_Training_Modules_Page_Controller()
    {
        
       system.debug('Inside AGN_AMI_Training_Modules_Page_Controller');
   
        lstALRDMod=new List<AMI_Lrn_Rel_Dtl_AGN__c>();
        
       
        SetUserResc = new set <Id>(); 
        SetUserspecificmodules = new Set<Id>();
        
       String loggedInUserID=Userinfo.getUserid();
   
       String ipUserID;                                                    
       ipUserID =loggedInUserID;
      /* 
       user =  [Select contact.AccountId,Country_code__c,LanguageLocaleKey from user where id =: Userinfo.getUserid() limit 1];
  
       UserID = user.contact.AccountId;
       userCountryName = [Select Country_vod__r.name from account where id =: UserID limit 1].Country_vod__r.name;
       userLanguage = user.LanguageLocaleKey; */
       
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            
            //userDetails  = AGN_AMI_Utility_class.getUserDeails();   
            userLanguage = userDetails.userLanguage;
            userCountryName =  userDetails.userCountryName;
            user =  userDetails.user;
            // DQ - HCP Harmonization Start
            accountRecord = userDetails.accountRecord;
            UserId = user.contact.AccountId;
           // DQ - HCP Harmonization End
       List<Account> lstAccountWithUserDetails = [Select Id,
                                        Name,
                                        AMI_Specialty_AGN__c,
                                        Type_AGN__c,
                                        Country_vod__c
                                        from Account 
                                        where Id =:UserId limit 1];
        
                                        
        
        for(Account spec:LstAccountWithUserDetails)
           {  
                                            
            SetUserSpec = spec.AMI_Specialty_AGN__c;
            UsrCountryCode = spec.Country_vod__c;
               
                                                        system.debug('SetUserSpec>'+SetUserSpec);
                                                        system.debug('UsrCountry>'+UsrCountryCode);
           }
        
        hCPProfile = [Select Id,
                          Account_AGN__c,
                          Injector_Status_AGN__c 
                          from AMI_HCP_Profile_AGN__c 
                          where Account_AGN__c = :UserID limit 1];
        
        string injecstatus = hCPProfile.size()>0?hCPProfile[0].Injector_Status_AGN__c:null; 
   
      //  List<AMI_Module_Restriction_AGN__c> LstUserRestrictedModule = [Select AMI_Learning_agn__c
      //                                                          from AMI_Module_Restriction_AGN__c 
      //                                                          where AMI_Specialty_AGN__c = :SetUserSpec
      //                                                          and Injector_Status_AGN__c=: injecstatus
      //                                                          and AMI_Learning_agn__r.Country_AGN__r.Name =: userCountryName];
        List<AMI_Module_Visibility_AGN__c> LstUserRestrictedModule = [Select AMI_Learning_agn__c
                                                                      from AMI_Module_Visibility_AGN__c 
                                                                      where AMI_Specialty_AGN__c = :SetUserSpec
                                                                      and Injector_Status_AGN__c=: injecstatus
                                                                      and AMI_Learning_agn__r.Country_AGN__r.Name =: userCountryName];
               
        
        
                                                                
        
        
     //   for(AMI_Module_Restriction_AGN__c a:LstUserRestrictedModule )
     //   {
     //       SetUserResc.add(a.AMI_Learning_agn__c);
     //   }
        
        for(AMI_Module_Visibility_AGN__c a:LstUserRestrictedModule )
        {
            SetUserResc.add(a.AMI_Learning_agn__c);
        } 
                                                                           
        
        List<AMI_HCP_modules_AGN__c  > LstUserSpecificModule =[Select AMI_Module_AGN__c
                                                           from AMI_HCP_modules_AGN__c  
                                                           where AMI_Account_AGN__c = :UserID ];  
                
                                                                             
        
        for(AMI_HCP_modules_AGN__c b:LstUserSpecificModule )
        {
            SetUserspecificmodules.add(b.AMI_Module_AGN__c);
        }  
        
                                                                               
        
        //list of all active AMI_Lrn_Rel_Dtl_AGN__c for the logged in User Country
        
        lstALRD = [Select  Active_AGN__c,
                   Curriculum_AGN__c,
                   Curriculum_Fma_AGN__c,
                   Module_AGN__c,
                   Module_Fma_AGN__c,
                   Program_AGN__c,
                   Program_Fma_AGN__c,
                   Module_AGN__r.Anatomy_Area_AGN__c,
                   Module_AGN__r.Module_Content_Type_AGN__c,
                   Module_AGN__r.Tags_AGN__c,
                   Module_AGN__r.Description_AGN__c,
                   Module_AGN__r.Module_Duration_AGN__c,
                   Module_AGN__r.Duration_FMA_AGN__c,
                   Module_AGN__r.AMI_Image_URL_AGN__c,
                   Module_AGN__r.AMI_Recommended_AGN__c,
                   Module_AGN__r.LastModifiedDate, 
                   Country_AGN__c,
                   Country_AGN__r.Name,
                   Module_AGN__r.Restricted_AGN__c ,
                   Module_AGN__r.Module_format_AGN__c,
                   Module_AGN__r.Name,
                   Module_AGN__r.Module_AGN__c,
                   LastModifiedDate
                   from AMI_Lrn_Rel_Dtl_AGN__c
                   where Country_AGN__r.Name =: userCountryName and Active_AGN__c=true
                   ORDER BY Curriculum_Sequence_AGN__c NULLS LAST]; 
                
                                                                            
        
        //Include RecordType.DeveloperName='Curriculum'  to filter the curriculam
       
        lstAL=[Select Id,
               Curriculum_AGN__c,
               Country_AGN__c,
               Module_format_AGN__c,
               RecordTypeId,
               RecordType.DeveloperName,
               franchise_agn__c
               from AMI_Learning_AGN__c
               where Country_AGN__r.Name =: userCountryName and RecordType.DeveloperName='Curriculum' and IsActive_AGN__c=true order by Curriculum_Header_Sequence_AGN__c asc];
               //where Country_AGN__r.Name =: userCountryName and RecordType.DeveloperName='Curriculum' and IsActive_AGN__c=true order by lastmodifieddate desc];
       
        system.debug('line 164: lstAL is'+lstAL);//////////////////////////////////////////////////////////
        
        lstCurrName = new Set<String>();
        
        for(AMI_Learning_AGN__c getcurr:lstAL )
        {
            if((getcurr.Curriculum_AGN__c!='') && !String.isBlank( getcurr.Curriculum_AGN__c))
            {
                //Below is for showing the list in UpperCase
                String upperCurricula=getcurr.Curriculum_AGN__c.toUpperCase();
                lstCurrName.add(upperCurricula);
              
            }
            else { 
                system.debug('Curricula  is null');
            }
        }
        lstAnatomy=GetPickListValues('AMI_Learning_AGN__c','Anatomy_Area_AGN__c');
        lstFormat=GetPickListValues('AMI_Learning_AGN__c','Module_Content_Type_AGN__c');
        mapFormat=GetPickListMap('AMI_Learning_AGN__c','Module_Content_Type_AGN__c');
        system.debug('lstFormat-->'+lstFormat);
                                        
             
    }
    public Map<string,string> GetPickListMap(string obj,string field)
    {
        Map<string,string> lststr=new Map<string,string>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(obj);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = AMI_Learning_AGN__c.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { 
            lststr.put(a.getLabel().ToUpperCase(),a.getValue().ToUpperCase());//add the value  to our final list
            //lststr.add(a.getLabel().ToUpperCase());//add the value  to our final list
        }
        return lststr;
    }
    
    public List<string> GetPickListValues(string obj,string field)
    {
        List<string> lststr=new List<string>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(obj);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = AMI_Learning_AGN__c.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { 
            lststr.add(a.getLabel().ToUpperCase());//add the value  to our final list
            //lststr.add(a.getLabel().ToUpperCase());//add the value  to our final list
        }
        return lststr;
    }
    
    public void sort()
    {
        system.debug('sortType--'+sortType);                     
        /* Sort Logic */
        List<AGN_AMI_LRD_Sort> ALS = new List<AGN_AMI_LRD_Sort>();
        for(AMI_Lrn_Rel_Dtl_AGN__c ALRD : lstALRDMod)
            ALS.add(new AGN_AMI_LRD_Sort(ALRD,sortType));
        
        ALS.sort();
        
        for(integer a=0;a<lstALRDMod.size();a++)
        {
            lstALRDMod[a]=ALS[a].ALRD;
        }
        
    }
    public pagereference GoToModuleDetails()
    {
        Pagereference prModDet=new PageReference('/Apex/AGN_AMI_Module_Details_Page');
        
        prModDet.setRedirect(true);
        prModDet.getParameters().put('lRDId',lRDId);         
        
        return prModDet;
        
    }
    
     
     public void searchModuleDetails()
     {
         
         system.debug('In searchModuleDetails: Selected Curricula is :'+strCurricula+' Selected Anatomy is:'+strAnatomy+' Selected Format is:'+strFormat);
         
         if(strAnatomy.containsWhitespace()){
               strAnatomy = strAnatomy.deleteWhitespace();
           }
         
         lstALRDMod=new List<AMI_Lrn_Rel_Dtl_AGN__c>();
         
                                             
          
        integer i=0; 
       
       for(AMI_Lrn_Rel_Dtl_AGN__c alrd:lstALRD) 
       {  
           boolean flag = false;
           system.debug('i !!! '+i);
           string curriculainList=(alrd.Curriculum_Fma_AGN__c==null)?'':alrd.Curriculum_Fma_AGN__c; 
           string anatomyAreainList= (alrd.Module_AGN__r.Anatomy_Area_AGN__c==null)?'':alrd.Module_AGN__r.Anatomy_Area_AGN__c; 
           if(anatomyAreainList.containsWhitespace()){
               anatomyAreainList = anatomyAreainList.deleteWhitespace();
           }
           string ModuleContentTypeinList= (alrd.Module_AGN__r.Module_Content_Type_AGN__c==null)?'':alrd.Module_AGN__r.Module_Content_Type_AGN__c; 
           
           
           system.debug('SearchModule:Iteration# >'+i+'>>>'+alrd.Id+'<  Restricted=:>'+alrd.Module_AGN__r.Restricted_AGN__c+'<  Curriculam=:'+alrd.Curriculum_Fma_AGN__c+'< anatomyAreainList=:'+anatomyAreainList+'<  Format=:'+ModuleContentTypeinList);
           
           if(alrd.Module_AGN__r.Restricted_AGN__c)
           {       
               if(SetUserspecificmodules.contains(alrd.Id) || SetUserResc.contains(alrd.Module_AGN__c))
               {                                 
                   
                   
                   if (!String.isBlank(strCurricula)){
                       if(curriculainList.equalsIgnoreCase(strCurricula) )
                       {      
                           
                           lstALRDMod.add(alrd);
                           system.debug('curriculainList ---'+i);
                       }  
                       
                       else  {
                           
                           flag =true;
                       }
                   }         
                   
                   
                   
                   if (!String.isBlank(strAnatomy)){
                       system.debug('Selected anatomy value in searchModule: >'+strAnatomy);
                       
                       if(anatomyAreainList.containsIgnoreCase(strAnatomy))
                       { 
                           if(!lstALRDMod.contains(alrd) && !flag)
                               lstALRDMod.add(alrd);
                           
                       } 
                       
                       else 
                       { 
                           if(lstALRDMod.contains(alrd) )
                               lstALRDMod.remove(lstALRDMod.indexOf(alrd));
                           flag =true;
                       } 
                   }    
                   
                   
                   
                   if( !String.isBlank(strFormat) )
                   {   
                       system.debug('Selected format value in searchModule: >'+strFormat);
                       if (ModuleContentTypeinList.equalsIgnoreCase(strFormat) )
                       {   
                           
                           if(!lstALRDMod.contains(alrd) && !flag)
                               lstALRDMod.add(alrd);
                           system.debug('ModuleContentTypeinList ---'+i);
                       }
                       
                       else 
                       {   
                           
                           if(lstALRDMod.contains(alrd))
                               lstALRDMod.remove(lstALRDMod.indexOf(alrd));
                           system.debug('ModuleContentTypeinList ---'+i);
                           flag =true;
                       }   
                       
                   }
                   
               }  //////////////////
           }
           else
           {           system.debug('This Module is NOT Restricted'+alrd.Module_AGN__r.Module_AGN__c);
            
            
            system.debug('$strCurricula$'+strCurricula+'$strAnatomy$'+strAnatomy+'$strFormat$'+strFormat);                
            
            
            if (!String.isBlank(strCurricula)){
                if(curriculainList.equalsIgnoreCase(strCurricula) )
                {      
                    
                    lstALRDMod.add(alrd);
                    system.debug('curriculainList ---'+i);
                }  
                
                else  {
                    
                    flag =true;
                }
            }         
            if (!String.isBlank(strAnatomy)){
                system.debug('Selected anatomy value in searchModule: >'+strAnatomy);
                
                if(anatomyAreainList.containsIgnoreCase(strAnatomy))
                { 
                    if(!lstALRDMod.contains(alrd) && !flag)
                        lstALRDMod.add(alrd);
                    
                } 
                
                else 
                { 
                    if(lstALRDMod.contains(alrd) )
                        lstALRDMod.remove(lstALRDMod.indexOf(alrd));
                    flag =true;
                } 
            }    
            
            
            
            if( !String.isBlank(strFormat) )
            {   
                system.debug('Selected format value in searchModule: >'+strFormat);
                if (ModuleContentTypeinList.equalsIgnoreCase(strFormat) )
                {   
                    
                    if(!lstALRDMod.contains(alrd) && !flag)
                        lstALRDMod.add(alrd);
                    system.debug('ModuleContentTypeinList ---'+i);
                }
                
                else 
                {   
                    
                    if(lstALRDMod.contains(alrd))
                        lstALRDMod.remove(lstALRDMod.indexOf(alrd));
                    system.debug('ModuleContentTypeinList ---'+i);
                    flag =true;
                }   
                
            }
            
            
           }/////////////****
           i++;
       }
         //end for      
         
         
         
        moduleCount=lstALRDMod.size();
        system.debug('The number of module matched is:'+moduleCount);
        String SortLogic = 'LastModified';
        sort();
           
     }
    
    public PageReference redirectToModulePage()
    {
        moduleId=ApexPages.currentPage().getParameters().get('moduleId');
        PageReference pr = new PageReference(System.Label.AGN_AMI_Module_Details_Page);
        pr.setRedirect(true);
        pr.getParameters().put('lRDId',moduleId);
        return pr;
    }
    
    
}