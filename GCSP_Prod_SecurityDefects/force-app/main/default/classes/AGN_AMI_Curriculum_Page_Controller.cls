public without sharing  class AGN_AMI_Curriculum_Page_Controller {
    
    User user;
    List<AMI_Lrn_Rel_Dtl_AGN__c> lstALRD;
    List<AMI_Lrn_Rel_Dtl_AGN__c> tempALRD;
    List<AMI_Lrn_Rel_Dtl_AGN__c> tempUnResALRD;
    List<AMI_Learning_Path_AGN__c> lstALPCheck;
    List<AMI_HCP_Profile_AGN__c> hCPProfile;
    String curriculumId;
    Account accountRecord;
    Contact contactRecord; 
    Set<Id> SetUserspecificmodules; 
    set<string> setMod;
    public Map<string,List<AMI_Lrn_Rel_Dtl_AGN__c>> curriculumMap{get;set;}
    public Set<AMI_Lrn_Rel_Dtl_AGN__c> LstModToAdd{get;set;}
    public string currName{get;set;}
    public string currImage{get;set;}
    public List<AMI_Objective_AGN__c> lstcurrobj{get;set;}
    public AMI_Learning_AGN__c currdesc{get;set;}
    public string moduleCount{get;set;}
    public boolean lpAdded{get;set;}
    public String lRDId {get; set;}
    public String userCountryName {get; set;}
    public String userLanguage {get; set;}
    public List<String> programList {get; set;}
    string recTypeId;
    public List<User> lstAmiAdmin;
    public Boolean is_MENA;
    public String user_country_MENA;
    
    public AGN_AMI_CPD_Curr_Wrapper currWrap {get; set;}
    public boolean sessionProgressVisibility{get; set;}
    
    
    public AGN_AMI_Curriculum_Page_Controller()
    {
        system.debug('Inside AGN_AMI_Curriculum_Page_Controller');
        recTypeId=[Select id from RecordType where SobjectType = 'AMI_Learning_Path_AGN__c' AND DeveloperName = 'AGN_Defined'][0].id;
        lpAdded=true;
        setMod=new set<string>();
        programList = new List<string>();
          
        curriculumId=ApexPages.currentPage().GetParameters().Get('currId');
        curriculumMap=new Map<string,List<AMI_Lrn_Rel_Dtl_AGN__c>>();
        LstModToAdd = new Set<AMI_Lrn_Rel_Dtl_AGN__c>();
        if(curriculumId!=null)
        {
           
            currWrap = new AGN_AMI_CPD_Curr_Wrapper();
            currdesc = [select Curriculum_AGN__c,Description_AGN__c,Image_AGN__c,AMI_Image_URL_AGN__c from AMI_Learning_AGN__c where Id =:curriculumId limit 1];
            currName= currdesc.Curriculum_AGN__c;
            currImage=currdesc.AMI_Image_URL_AGN__c;
                                                          /*  user = [Select contact.AccountId,Country_code__c,LanguageLocaleKey from user where id =: Userinfo.getUserid() limit 1];
                                                             UserId       = user.contact.AccountId;
                                                             //userCountry  = user.Country_code__c;
                                                            userCountryName = [Select Country_vod__r.name from account where id =: userId limit 1].Country_vod__r.name;
                                                            userLanguage = user.LanguageLocaleKey;
                                                                                 System.debug('User Country-->'+userCountryName );
                                                            */                     
           AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            //userDetails  = AGN_AMI_Utility_class.getUserDeails();   
            userLanguage = userDetails.userLanguage;
            system.debug('userLanguage-->'+userLanguage);
            /*AMI MENA changes- Start */
            //userCountryName =  userDetails.userCountryName;
            userCountryName =  userDetails.maskedUserCountryName;
            system.debug('userCountryName-->'+userCountryName);
            /*AMI MENA changes- End */
            user =  userDetails.user;
            accountRecord = userDetails.accountRecord;
            contactRecord = userDetails.contactRecord;
             system.debug('&&&&'+userDetails.userLanguage);
              system.debug('####'+userDetails.userCountryName);
            Id SetUserSpec; 
            String SetUsertype;
            Set<Id> SetUserResc = new set <Id>();
            
            sessionProgressVisibility=AMI_Web_Visibility_Settings_AGN__c.getValues(userCountryName).AGN_AMI_Session_Progress_Visibility__c;
            lstALPCheck = [Select Id,
                         Module__c,
                         (SELECT Session_Status_AGN__c, Session_Code_AGN__c 
                            FROM AMI_Learning_Path_Sessions__r where Active_AGN__c=true),  //added active=true check-3814
                         Module__r.Module_AGN__c,
                         Module__r.Curriculum_AGN__c,
                         Module__r.Program_AGN__c,
                         Country_AGN__c,
                         Curriculum_name_AGN__c,
                         HCP_AGN__c,
                         Module_Name_AGN__c,
                         Program_Name_AGN__c
                         from AMI_Learning_Path_AGN__c
                         where HCP_AGN__c=: accountRecord.Id 
                         and Module__r.Curriculum_AGN__c=:currdesc.ID
                         and Country_AGN__r.Name = :userCountryName ];
        system.debug('ADD TO LEARNING PATH--->'+lstALPCheck);
            /*AMI MENA changes- Start */
            userCountryName =  userDetails.userCountryName;
            /*AMI MENA changes- End */
            
            Map<String,AMI_Learning_Path_AGN__c> learningPathMap = new Map<String,AMI_Learning_Path_AGN__c>();
            for(AMI_Learning_Path_AGN__c lp : lstALPCheck) {
                learningPathMap.put(lp.Module__c + '_' + lp.HCP_AGN__c, lp);
            }
            
            List<AMI_Sessions_AGN__c> sessionList = [SELECT Id, Parent_Module_AGN__c, Session_Code_AGN__c 
                                                 FROM AMI_Sessions_AGN__c 
                                                 WHERE Country_AGN__r.Name = :userCountryName 
                                                 AND IsActive_AGN__c = TRUE
                                                 ORDER BY Sequence_Number_AGN__c];
            
            
            Map<String, List<AMI_Sessions_AGN__c>> sessionCounts = new Map<String, List<AMI_Sessions_AGN__c>>();
            for(AMI_Sessions_AGN__c session : sessionList) {
                List<AMI_Sessions_AGN__c> sessions = new List<AMI_Sessions_AGN__c>();
                if(sessionCounts.keySet().contains(session.Parent_Module_AGN__c)) {
                    sessions = sessionCounts.get(session.Parent_Module_AGN__c);
                }
                sessions.add(session);
                sessionCounts.put(session.Parent_Module_AGN__c, sessions);
            }
            
            
            lstcurrobj = [select Objective_description_AGN__c
                          from AMI_Objective_AGN__c 
                          where Parent_Module_AGN__c =:curriculumId
                          and Country_AGN__r.Name = :userCountryName ];
            
           
            lstALRD=[Select Id,
                     Name,
                     Curriculum_AGN__r.Name,
                     Curriculum_Fma_AGN__c,
                     Curriculum_AGN__r.Description_AGN__c,
                     Curriculum_AGN__r.AMI_Image_URL_AGN__c,
                     Curriculum_AGN__r.Curriculum_Header_Sequence_AGN__c,
                     Module_AGN__r.Name,
                     Module_AGN__r.Module_Content_Type_AGN__c,
                     Module_AGN__r.Module_Duration_AGN__c,
                     Module_AGN__r.Duration_FMA_AGN__c,
                     Module_AGN__r.Restricted_AGN__c,
                     Module_AGN__r.Module_AGN__c,
                     Country_AGN__r.Country_Name_vod__c,
                     CurrencyIsoCode,
                     Module_Fma_AGN__c,
                     Program_AGN__r.Name,
                     Program_Fma_AGN__c,
                     External_ID_AGN__c,
                     Country_AGN__c,
                     Curriculum_Sequence_AGN__c
                     from AMI_Lrn_Rel_Dtl_AGN__c 
                     where Curriculum_AGN__c=:curriculumId
                     and Country_AGN__r.Name = :userCountryName 
                     and Language_AGN__c =: userLanguage
                     and Active_AGN__c = true
                     ORDER BY Curriculum_Sequence_AGN__c NULLS LAST];
            
           system.debug('ADD TO LEARNING PATH--->'+lstALPCheck);
           System.debug('Lstalrd-->'+curriculumId);  
           System.debug('Lstalrd---->'+lstALRD);      
            
            /* Substituted by accountRecord from AGN_AMI_Utility_class
            List<Account> LstUserDetails=[Select Id,
                                          Name,
                                          AMI_Specialty_AGN__c,
                                          Type_AGN__c
                                          from Account where Id = :UserID];
            
            for(Account spec:LstUserDetails)
            {
                if(spec.Id == UserID )
                SetUserSpec.add(spec.AMI_Specialty_AGN__c);
                SetUsertype.add(spec.Type_AGN__c);
            }
            */
            SetUserSpec = accountRecord.AMI_Specialty_AGN__c;
            SetUsertype = accountRecord.Type_AGN__c;
            hCPProfile = [Select Id,
                          Account_AGN__c,
                          Injector_Status_AGN__c 
                          from AMI_HCP_Profile_AGN__c 
                          where Account_AGN__c =: accountRecord.Id limit 1];
            
            system.debug('sn--'+ hCPProfile);                          
            
            string injecstatus = hCPProfile.size()>0?hCPProfile[0].Injector_Status_AGN__c:null;                                                         
            
            system.debug('ag--'+ injecstatus );
            
         //   List<AMI_Module_Restriction_AGN__c> LstUserresModule = [Select AMI_Learning_agn__c
         //                                                           from AMI_Module_Restriction_AGN__c 
         //                                                           where AMI_Specialty_AGN__c in :SetUserSpec
         //                                                           and Injector_Status_AGN__c=: injecstatus
         //                                                           and AMI_Learning_agn__r.Country_AGN__r.Name =: userCountryName ];
             /*AMI MENA changes- Start */
            userCountryName =  userDetails.userCountryName;
            /*AMI MENA changes- End */
            List<AMI_Module_Visibility_AGN__c> LstUserresModule = [Select AMI_Learning_agn__c
                                                                    from AMI_Module_Visibility_AGN__c 
                                                                    where AMI_Specialty_AGN__c =: SetUserSpec
                                                                    and Injector_Status_AGN__c=: injecstatus
                                                                    and AMI_Learning_agn__r.Country_AGN__r.Name =: userCountryName ];
            
            List<AMI_HCP_modules_AGN__c> LstUserspecModule =[Select AMI_Module_AGN__c
                                                               from AMI_HCP_modules_AGN__c  
                                                               where AMI_Account_AGN__c =: accountRecord.Id ];   
            
            
            
            SetUserspecificmodules = new Set<Id>();
            SetUserResc = New Set<ID>();
            
            for(AMI_HCP_modules_AGN__c b:LstUserspecModule )
            {
                SetUserspecificmodules.add(b.AMI_Module_AGN__c);
            }   
            
          //  for(AMI_Module_Restriction_AGN__c a:LstUserresModule )
          //  {
          //      SetUserResc.add(a.AMI_Learning_agn__c);
          //  }
            for(AMI_Module_Visibility_AGN__c a:LstUserresModule )
            {
                SetUserResc.add(a.AMI_Learning_agn__c);
            }
            
            
            system.debug('SetUserResc--'+SetUserResc);
            system.debug('SetUserspecificmodules--'+SetUserspecificmodules);
            system.debug('lstALRD--'+lstALRD);
            
            currWrap.programTree = new Map<String, AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper>();
            Map<String, AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper> programMap = new Map<String, AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper>();
            Map<Integer, String> programOrder = new Map<Integer, String>();
           for(AMI_Lrn_Rel_Dtl_AGN__c alrd:lstALRD) 
            {
                List<AGN_AMI_CPD_Module_Wrapper> tempMWList;
                if(currWrap.programTree != null && currWrap.programTree.keySet().contains(alrd.Program_FMA_AGN__c)) {
                    tempMWList = currWrap.programTree.get(alrd.Program_FMA_AGN__c).modules;
                    
                }
                else {
                    tempMWList = new List<AGN_AMI_CPD_Module_Wrapper>();
                }
                
                system.debug('currWrap.programTree.keySet()'+currWrap.programTree.keySet()+'  lllllll  '+alrd.Program_FMA_AGN__c);
                if(!(currWrap.programTree.keySet().contains(alrd.Program_FMA_AGN__c))) {
                    if(!alrd.Module_AGN__r.Restricted_AGN__c){
                        programOrder.put((Integer)alrd.Curriculum_Sequence_AGN__c, alrd.Program_FMA_AGN__c);
                        system.debug('comming in 1st if');
                    }
                    else {
                        system.debug('comming in else');
                        
                        if(SetUserspecificmodules.contains(alrd.Id) || SetUserResc.contains(alrd.Module_AGN__c))
                        {
                            system.debug('comming in if condition in else');
                            programOrder.put((Integer)alrd.Curriculum_Sequence_AGN__c, alrd.Program_FMA_AGN__c); 
                        }
                        
                    }

                    
                }
                system.debug('programOrder' +programOrder);
                system.debug('alrdForProg.Module_AGN__r.Restricted_AGN__c--'+alrd.Module_AGN__r.Restricted_AGN__c);

                system.debug('alrdForProg.Module_AGN__r.Restricted_AGN__c--'+alrd.Module_AGN__r.Module_AGN__c);
                system.debug('alrdForProg.Module_AGN__r.Restricted_AGN__c--'+alrd.Module_AGN__r.Restricted_AGN__c);
                system.debug('alrdForProg.Module_AGN__r.Restricted_AGN__c--'+alrd.Module_AGN__r.Module_AGN__c);
                
                tempALRD=new List<AMI_Lrn_Rel_Dtl_AGN__c>();
                tempUnResALRD=new List<AMI_Lrn_Rel_Dtl_AGN__c>();
                if(alrd.Module_AGN__r.Restricted_AGN__c)
                {
                    if(SetUserspecificmodules.contains(alrd.Id) || SetUserResc.contains(alrd.Module_AGN__c))
                    {
                        system.debug('Entered for ' + alrd.Id);
                        LstModToAdd.add(alrd);
                        setMod.add(string.valueof(alrd.Curriculum_AGN__c)+string.valueof(alrd.Program_AGN__c)+string.valueof(alrd.Module_AGN__c));
                                
                       /* for(AMI_Lrn_Rel_Dtl_AGN__c alrdForProg:lstALRD)
                        {
                            system.debug('program--'+alrdForProg.Module_Fma_AGN__c);
                            system.debug('SetUserspecificmodules--'+SetUserspecificmodules);
                            system.debug('SetUserResc--'+SetUserResc);
                            if(alrdForProg.Program_AGN__c==alrd.Program_AGN__c && (SetUserspecificmodules.contains(alrdForProg.Id) || SetUserResc.contains(alrdForProg.Module_AGN__c)))
                            {
                                system.debug('alrd.Id--'+alrdForProg.Module_Fma_AGN__c);
                                
                                tempALRD.add(alrdForProg);
                                system.debug('tempALRD--'+tempALRD);
                                LstModToAdd.add(alrdForProg);
                                setMod.add(string.valueof(alrdForProg.Curriculum_AGN__c)+string.valueof(alrdForProg.Program_AGN__c)+string.valueof(alrdForProg.Module_AGN__c));
                                if(curriculumMap.keySet().size()<1)
                                {
                                    curriculumMap.put(alrd.Program_Fma_AGN__c, tempALRD); 
                                    programList.add(alrdForProg.Program_Fma_AGN__c);
                                }
                                else
                                {
                                    if(curriculumMap.keyset().contains(alrd.Program_Fma_AGN__c) )
                                    {
                                        if(!curriculumMap.get(alrd.Program_Fma_AGN__c).contains(alrd))
                                            curriculumMap.get(alrd.Program_Fma_AGN__c).add(alrd);
                                    }
                                    else
                                    {
                                        curriculumMap.put(alrd.Program_Fma_AGN__c, tempALRD);
                                        programList.add(alrdForProg.Program_Fma_AGN__c);
                                    }                                    
                                } 
                            }                       
                        }*/
                        AGN_AMI_CPD_Module_Wrapper mw =new AGN_AMI_CPD_Module_Wrapper(alrd,
                                                                                      learningPathMap.get(alrd.id + '_' + accountRecord.Id),
                                                                                      sessionCounts.get(alrd.Module_AGN__c),
                                                                                      (Integer)alrd.Curriculum_Sequence_AGN__c);
                        tempMWList.add(mw);
                        AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper programList 
                            = new AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper(alrd.Program_FMA_AGN__c, tempMWList);
                        programMap.put(alrd.Program_FMA_AGN__c, programList);
                       
                     //   programOrder.put((Integer)alrd.Curriculum_Sequence_AGN__c, alrd.Program_FMA_AGN__c); 
                        currWrap.programOrder = programOrder;
                        currWrap.Id = alrd.Curriculum_AGN__c;
                        currWrap.currName = alrd.Curriculum_Fma_AGN__c;
                        currWrap.currDesc = alrd.Curriculum_AGN__r.Description_AGN__c;
                        currWrap.imageURL = alrd.Curriculum_AGN__r.AMI_Image_URL_AGN__c;
                        currWrap.sequence = (Integer)alrd.Curriculum_AGN__r.Curriculum_Header_Sequence_AGN__c;
                        currWrap.programTree =programMap;
                        currWrap.moduleCount = setMod.size();
                    }
                }
               
         else 
                {
                    LstModToAdd.add(alrd);
                    setMod.add(string.valueof(alrd.Curriculum_AGN__c)+string.valueof(alrd.Program_AGN__c)+string.valueof(alrd.Module_AGN__c));
                    
                   //  Map<String, AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper> programMap = new Map<String, AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper>();
                    AGN_AMI_CPD_Module_Wrapper mw =new AGN_AMI_CPD_Module_Wrapper(alrd,
                                                                                  learningPathMap.get(alrd.id + '_' + accountRecord.Id),
                                                                                  sessionCounts.get(alrd.Module_AGN__c),
                                                                                  (Integer)alrd.Curriculum_Sequence_AGN__c);
                    tempMWList.add(mw);
                    AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper programList 
                    = new AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper(alrd.Program_FMA_AGN__c, tempMWList);
                     programMap.put(alrd.Program_FMA_AGN__c, programList);
                    
                  //  programOrder.put((Integer)alrd.Curriculum_Sequence_AGN__c, alrd.Program_FMA_AGN__c);  
                    currWrap.programOrder = programOrder;
                    currWrap.Id = alrd.Curriculum_AGN__c;
                    currWrap.currName = alrd.Curriculum_Fma_AGN__c;
                    currWrap.currDesc = alrd.Curriculum_AGN__r.Description_AGN__c;
                    currWrap.imageURL = alrd.Curriculum_AGN__r.AMI_Image_URL_AGN__c;
                    currWrap.sequence = (Integer)alrd.Curriculum_AGN__r.Curriculum_Header_Sequence_AGN__c;
                    currWrap.programTree =programMap;
                    currWrap.moduleCount = setMod.size();
                    
                  /* for(AMI_Lrn_Rel_Dtl_AGN__c alrdForProg:lstALRD)
                    {
                        if(!alrdForProg.Module_AGN__r.Restricted_AGN__c )
                        {
                            if(alrdForProg.Program_AGN__c==alrd.Program_AGN__c)
                            {
                                system.debug('alrd.Id--'+alrdForProg.Module_Fma_AGN__c);
                                tempUnResALRD.add(alrdForProg);
                                LstModToAdd.add(alrdForProg);
                                setMod.add(string.valueof(alrdForProg.Curriculum_AGN__c)+string.valueof(alrdForProg.Program_AGN__c)+string.valueof(alrdForProg.Module_AGN__c));
                                if(curriculumMap.keySet().size()<1)
                                {
                                    curriculumMap.put(alrd.Program_Fma_AGN__c, tempUnResALRD);
                                    programList.add(alrdForProg.Program_Fma_AGN__c);
                                }
                                else
                                {
                                    if(curriculumMap.keyset().contains(alrdForProg.Program_Fma_AGN__c) )
                                    {
                                        if(!curriculumMap.get(alrdForProg.Program_Fma_AGN__c).contains(alrdForProg))
                                            curriculumMap.get(alrdForProg.Program_Fma_AGN__c).add(alrdForProg);
                                    }
                                    else
                                    {
                                        curriculumMap.put(alrd.Program_Fma_AGN__c, tempUnResALRD);
                                        programList.add(alrdForProg.Program_Fma_AGN__c);
                                    }
                                }
                            }
                        }
                    }*/
                    
                    System.debug('currWrap>>>>'+currWrap);
                }
             //  currWrap.programTree.put(alrd.Program_FMA_AGN__c, tempMWList);  
             
            
            }
             System.debug('currWrap111111'+currWrap);
            //System.debug('cpdCurrList>>>>'+cpdCurrList);
            
            moduleCount=String.valueof(setMod.size()); 
            system.debug(setMod.size()+'_'+lstALPCheck.size());
            if(setMod.size()<=lstALPCheck.size())
            {
                for(AMI_Learning_Path_AGN__c al:lstALPCheck)
                {
                    System.debug(string.valueof(al.Module__r.Curriculum_AGN__c)+string.valueof(al.Module__r.Program_AGN__c)+string.valueof(al.Module__r.Module_AGN__c));
                    if(!(setMod.contains(string.valueof(al.Module__r.Curriculum_AGN__c)+string.valueof(al.Module__r.Program_AGN__c)+string.valueof(al.Module__r.Module_AGN__c))))
                    {
                        
                        lpAdded=true;
                        break;
                    }
                    else{
                        
                        lpAdded=false;
                    }
                    
                }
            }
            else
                lpAdded=true;
        }
    }

    public void AddCurrToLearningPath()
    {
        
        
        /*AMI MENA changes- Start */
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userCountryName=userDetails.maskedUserCountryName;
        /*AMI MENA changes- End */
        string lpRecOwner=AMI_User_Settings_AGN__c.getValues(userCountryName).LP_Record_Owner_AGN__c;
        lstAmiAdmin=[select Id from user where UserName=:lpRecOwner Limit 1];
        List<AMI_Learning_Path_AGN__c> lstALP=new List<AMI_Learning_Path_AGN__c>();
        List<AMI_Path_Session_AGN__c> lstAPS=new List<AMI_Path_Session_AGN__c>();
        List<AMI_Learning_Path_AGN__c> usrLP=[select Id,Module__c from AMI_Learning_Path_AGN__c where HCP_AGN__c =: accountRecord.Id];
        set<string> setModules=new set<string>();
        System.debug('usrLP--->' + usrLP);
        for(AMI_Learning_Path_AGN__c al:usrLP )
        {
            setModules.add(al.Module__c);
        }
        System.debug('SetModules--->'+setModules);
        set<Id> setmodadd = new set<Id>(); 
        System.debug ('The Size of usrLP--->' + usrLP.size() );
        System.debug ('The LstModToAdd is----->' +LstModToAdd);
        /*AMI MENA changes- Start */
        Id usrCountry=[Select id from Country_vod__c where Name=:userCountryName].id;
        /*AMI MENA changes- End */
        
        set<id> modIdSet = new set<id>();
        
        for(AMI_Lrn_Rel_Dtl_AGN__c getMod:LstModToAdd)
        {
            Id modId = Id.Valueof(getMod.Id);
            modIdSet.add(modId);
        }
         Map<id,AMI_Lrn_Rel_Dtl_AGN__c > lrnRelDtlMap = new Map<id,AMI_Lrn_Rel_Dtl_AGN__c >([select id,Module_AGN__r.Module_AGN__c,Program_AGN__r.Program_AGN__c,Curriculum_AGN__r.Curriculum_AGN__c from AMI_Lrn_Rel_Dtl_AGN__c where id in: modIdSet]);
       
        
        for(AMI_Lrn_Rel_Dtl_AGN__c getMod:LstModToAdd)
        {
             Id modId = Id.Valueof(getMod.Id);   
            if(usrLP.size()>0)
            {

                if(!setModules.contains(getMod.Id))
                {
                    system.debug('I am here');
                    system.debug('getMod.Id--'+getMod.Id);
                    setmodadd.add(getMod.Module_AGN__c);
                    lstALP.add(new AMI_Learning_Path_AGN__c( HCP_AGN__c= accountRecord.Id,
                                                            Contact_AGN__c = contactRecord.Id,
                                                            Module__c=Id.Valueof(getMod.Id),
                                                            Unique_Learning_Path__c = String.valueOf(accountRecord.Id) + lrnRelDtlMap.get(modId).Module_AGN__r.Module_AGN__c + lrnRelDtlMap.get(modId).Program_AGN__r.Program_AGN__c+ lrnRelDtlMap.get(modId).Curriculum_AGN__r.Curriculum_AGN__c,
                                                            /*AMI MENA changes- Start */
                                                            //Country_AGN__c=getMod.Country_AGN__c,
                                                            Country_AGN__c=usrCountry,
                                                            /*AMI MENA changes- End */
                                                            CurrencyIsoCode=getMod.CurrencyIsoCode,
                                                            OwnerId=lstAmiAdmin.Size()>0?lstAmiAdmin[0].Id:Userinfo.getUserid(),
                                                            /*AMI MENA changes- Start */
                                                            //Country_Code_AGN__c=getMod.Country_AGN__r.Country_Name_vod__c,
                                                            Country_Code_AGN__c=userCountryName,
                                                            /*AMI MENA changes- End */
                                                            RecordTypeId = recTypeId));
                }
                
            }
            else
            {
                setmodadd.add(getMod.Module_AGN__c);
                lstALP.add(new AMI_Learning_Path_AGN__c( HCP_AGN__c= accountRecord.Id,
                                                        Contact_AGN__c = contactRecord.Id,
                                                        Module__c=Id.Valueof(getMod.Id), 
                                                        Unique_Learning_Path__c = String.valueOf(accountRecord.Id) + lrnRelDtlMap.get(modId).Module_AGN__r.Module_AGN__c + lrnRelDtlMap.get(modId).Program_AGN__r.Program_AGN__c+ lrnRelDtlMap.get(modId).Curriculum_AGN__r.Curriculum_AGN__c,
                                                        /*AMI MENA changes- Start */
                                                        //Country_AGN__c=getMod.Country_AGN__c,
                                                        Country_AGN__c=usrCountry,
                                                        /*AMI MENA changes- End */
                                                        CurrencyIsoCode=getMod.CurrencyIsoCode,
                                                        OwnerId=lstAmiAdmin.Size()>0?lstAmiAdmin[0].Id:Userinfo.getUserid(),
                                                        /*AMI MENA changes- Start */
                                                        //Country_Code_AGN__c=getMod.Country_AGN__r.Country_Name_vod__c,
                                                        Country_Code_AGN__c=userCountryName,
                                                        /*AMI MENA changes- End */
                                                        RecordTypeId = recTypeId));
            }
        }
        
        List<AMI_Sessions_AGN__c> lstsessions=[select Parent_Module_AGN__c,
                                               AMI_Content_agn__c,
                                               Session_code_AGN__c,
                                               Country_AGN__c,
                                               Duration_AGN__c,
                                               File_name_AGN__c,
                                               Name_AGN__c,
                                               Parent_Module_Tags_AGN__c,
                                               Tags_AGN__c,
                                               Training_URL_AGN__c,
                                               ZINC_number_agn__c
                                               from AMI_Sessions_AGN__c 
                                               where  Parent_Module_AGN__c in :setmodadd
                                               and IsActive_AGN__c = true];
        
        system.debug('lstsessions--'+lstsessions);
        system.debug('lstALP--'+lstALP);
        system.debug('LstModToAdd--'+LstModToAdd);
        if(lstALP != null)
        {
            try
            {
               // insert lstALP;
               Database.upsert(lstALP,AMI_Learning_Path_AGN__c.Unique_Learning_Path__c,false);
            }
            Catch(DMLException ex)
            {
                AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Curriculum_Page_Controller','AddCurrToLearningPath');
            }               
        }
        for(AMI_Lrn_Rel_Dtl_AGN__c getMod:LstModToAdd)
        { 
            for(AMI_Learning_Path_AGN__c getmodadd:lstALP)
            {
                if(getMod.Id == getmodadd.Module__c)
                {
                    for(AMI_Sessions_AGN__c getsess:lstsessions)
                    {
                        system.debug('getmod.Module_Fma_AGN__c--'+getmod.Module_Fma_AGN__c);
                        system.debug('getsess.Parent_Module_AGN__c--'+getsess.Parent_Module_AGN__c);
                        if(getmod.Module_AGN__r.Id == getsess.Parent_Module_AGN__c)
                        {
                            lstAPS.add(new AMI_Path_Session_AGN__c(AMI_Learning_Path_agn__c=getmodadd.Id,
                                                                   Duration_AGN__c=getsess.Duration_AGN__c,
                                                                   File_name_AGN__c=getsess.File_name_AGN__c,
                                                                   Name_AGN__c=getsess.Name_AGN__c,
                                                                   ZINC_number_AGN__c=getsess.ZINC_number_AGN__c,
                                                                   Training_URL_AGN__c=getsess.Training_URL_AGN__c,
                                                                   Session_Code_AGN__c = getsess.Session_Code_AGN__c,
                                                                   Active_AGN__c = true));
                        }
                    }
                }
            }
        }
        system.debug('lstAPS--'+lstAPS);
        
        if(lstAPS != null)
        {
            try
            {
                insert lstAPS;
            }
            Catch(DMLException ex)
            {
                AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Curriculum_Page_Controller','AddCurrToLearningPath');
            }
        }
        /*AMI MENA changes- Start */
        userCountryName=userDetails.userCountryName;
        /*AMI MENA changes- End */
        Pagereference pr=new PageReference('/Apex/AGN_AMI_Curriculam_Page');
         pr.setRedirect(true);
        pr.getParameters().put('currId',curriculumId);
  
        System.debug('The PR is--->' +pr);
        lpAdded = False;
        
        
    } 
    
public PageReference moveModDet()
    {
        
        Pagereference pr=new PageReference('/Apex/AGN_AMI_Module_Details_Page');
        pr.setRedirect(true);
        
        pr.getParameters().put('lRDId',lRDId);
        System.debug('ID value test value is-->' +lRDId);
        return pr;
    }
    
     public PageReference moveToLP()
    {
        Pagereference pr=new PageReference('/Apex/AGN_AMI_Learning_Path_Page');
        pr.setRedirect(true);
        
        return pr;
    }
}