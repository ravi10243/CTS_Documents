/**************************************************************************************************************************
@ Class:          AGN_AMI_CPD_Course_Controller
@ Version:        1.0
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        Controller class for maintaining changes to vault code changes in metadata.
@ PMO:            CR-3277 : This class is used as controller for AGN_AMI_CPD_Course_Page
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 28.07.2020 / Ayush Basak / Created the class.
@ Change history: 03.11.2020 / Ayush Basak / Updated the class for 'CPD Tracking Enhancement'. In the previous version, 
                  list and maps of sObjects where used to display Curriculum, program and module heirarchy. This has been 
                  replaced with wrapper classes (AGN_AMI_CPD_Curr_Wrapper) to support the additional display of status 
                  flags at program and module level
***************************************************************************************************************************/
public class AGN_AMI_CPD_Course_Controller {
    Account accountRecord;
    Contact contactRecord; 
    User user;
    public String userCountryName {get; set;}
    public String userLanguage {get; set;}
    public AMI_Certification_AGN__c cert {get; set;}
    public Set<String> currList;
    public Set<String> currNameList {get; set;}
    public Boolean showAddButton {get; set;}
    String recTypeId;
    public List<AMI_Lrn_Rel_Dtl_AGN__c> visibleLRD;
    public Map<String, AMI_Lrn_Rel_Dtl_AGN__c> currMap {get; set;}
    public Boolean isChecked {get; set;}
    public List<AGN_AMI_CPD_Curr_Wrapper> cpdCurrList {get; set;}
    public Map<String, AGN_AMI_CPD_Curr_Wrapper> cpdCurrMap {get; set;}
    
    public AGN_AMI_CPD_Course_Controller(){
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();  
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.maskedUserCountryName;
        user =  userDetails.user;
        accountRecord = userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;
        isChecked =false;
        recTypeId=[Select id from RecordType where SobjectType = 'AMI_Learning_Path_AGN__c' AND DeveloperName = 'AGN_Defined'][0].id;
        String certId = ApexPages.currentPage().GetParameters().Get('certId');
        cert = [SELECT Id, Name, Description_AGN_AMI__c, Certificate_Logo_AGN_AMI__c, Total_Curricula_AGN_AMI__c, 
                Disclaimer_AGN_AMI__c,
                Course_Description_AGN_AMI__c, Drop_Down_Label_AGN_AMI__c, Curriculum_Banner_AGN_AMI__c,         
                (SELECT Id, Curriculam_AGN_AMI__c, Learning_AGN_AMI__r.Curriculum_AGN__c,
                 Learning_AGN_AMI__r.Curriculum_AGN__r.Curriculum_Header_Sequence_AGN__c,
                 Learning_AGN_AMI__r.Curriculum_AGN__r.Description_AGN__c,
                 Program_AGN_AMI__c, Module_AGN_AMI__c, Learning_AGN_AMI__r.Curriculum_Sequence_AGN__c,
                 Learning_AGN_AMI__r.Module_AGN__c, Learning_AGN_AMI__c, 
                 Learning_AGN_AMI__r.Module_AGN__r.Module_Duration_AGN__c,
                 Learning_AGN_AMI__r.Module_AGN__r.Module_Content_Type_AGN__c,
                 Learning_AGN_AMI__r.Curriculum_AGN__r.AMI_Image_URL_AGN__c
                 FROM AMI_Certification_Paths__r 
                 ORDER BY Learning_AGN_AMI__r.Curriculum_AGN__r.Curriculum_Header_Sequence_AGN__c ASC NULLS LAST) 
                FROM AMI_Certification_AGN__c 
                WHERE Id = :certId];
        
        currList = new Set<String>();
        currNameList = new Set<String>();
        currMap = new Map<String, AMI_Lrn_Rel_Dtl_AGN__c>();
        Map<String, AMI_Lrn_Rel_Dtl_AGN__c> curriculumSequenceMap = new Map<String, AMI_Lrn_Rel_Dtl_AGN__c>();
        cpdCurrList = new List<AGN_AMI_CPD_Curr_Wrapper>();
        cpdCurrMap = new Map<String, AGN_AMI_CPD_Curr_Wrapper>();
        
        // Added as part of CPD Tracking Enhancement - start
        List<AMI_Learning_Path_AGN__c> lstALP = [SELECT Id,
                                                 Module__c,
                                                 HCP_AGN__c,
                                                 Module_Status_AGN__c, 
                                                 (SELECT Session_Status_AGN__c, Session_Code_AGN__c 
                                                  FROM AMI_Learning_Path_Sessions__r where Active_AGN__c=true)
                                                 FROM AMI_Learning_Path_AGN__c
                                                 WHERE HCP_AGN__c=: accountRecord.Id 
                                                 AND Module__c IN (SELECT Learning_AGN_AMI__c
                                                                   FROM AMI_CPD_Module_AGN__c 
                                                                   WHERE Certification_AGN_AMI__c =: cert.Id)];
        Map<String,AMI_Learning_Path_AGN__c> learningPathMap = new Map<String,AMI_Learning_Path_AGN__c>();
        for(AMI_Learning_Path_AGN__c lp : lstALP) {
            learningPathMap.put(lp.Module__c + '_' + lp.HCP_AGN__c, lp);
        }
        
        List<AMI_Sessions_AGN__c> sessionList = [SELECT Id, Parent_Module_AGN__c, Session_Code_AGN__c 
                                                 FROM AMI_Sessions_AGN__c 
                                                 WHERE Country_AGN__r.Name = :userCountryName 
                                                 AND IsActive_AGN__c = TRUE
                                                 ORDER BY Sequence_Number_AGN__c];
        system.debug('sessionList'+sessionList);
        Map<String, List<AMI_Sessions_AGN__c>> sessionCounts = new Map<String, List<AMI_Sessions_AGN__c>>();
        for(AMI_Sessions_AGN__c session : sessionList) {
            List<AMI_Sessions_AGN__c> sessions = new List<AMI_Sessions_AGN__c>();
            if(sessionCounts.keySet().contains(session.Parent_Module_AGN__c)) {
                sessions = sessionCounts.get(session.Parent_Module_AGN__c);
            }
            sessions.add(session);
              system.debug('session'+session);
            sessionCounts.put(session.Parent_Module_AGN__c, sessions);
            system.debug('sessionCounts'+sessionCounts);
        }
        // Added as part of CPD Tracking Enhancement - end
        for(AMI_CPD_Module_AGN__c cm : cert.AMI_Certification_Paths__r){
            if(!cpdCurrMap.keySet().contains(cm.Learning_AGN_AMI__r.Curriculum_AGN__c)) {
                
                AGN_AMI_CPD_Curr_Wrapper temp = new AGN_AMI_CPD_Curr_Wrapper();
                
                /* Commented as part of CPD Tracking Enhancement
                Map<String, List<AMI_Learning_AGN__c>> tempCurrTree = new Map<String, List<AMI_Learning_AGN__c>>();
                
                AMI_Learning_AGN__c module = new AMI_Learning_AGN__c();
                module.Module_AGN__c = cm.Module_AGN_AMI__c;
                module.Id = cm.Learning_AGN_AMI__r.Module_AGN__c;
                module.File_name_AGN__c = cm.Learning_AGN_AMI__c;
                module.Session_AGN__c = cm.Learning_AGN_AMI__r.Module_AGN__r.Module_Duration_AGN__c.toPlainString();
                module.Module_Content_Type_AGN__c = cm.Learning_AGN_AMI__r.Module_AGN__r.Module_Content_Type_AGN__c;
                if(learningPathMap.keySet().contains(module.Id + '_' + accountRecord.Id)) {
                    module.Tags_AGN__c = learningPathMap.get(module.Id + '_' + accountRecord.Id).Module_Status_AGN__c;
                }                
                else {
                    module.Tags_AGN__c = 'Not Started';
                }
                List<AMI_Learning_AGN__c> moduleList = new List<AMI_Learning_AGN__c>();
                moduleList.add(module);
                
                tempCurrTree.put(cm.Program_AGN_AMI__c, moduleList);
                */
                
                // Added as part of CPD Tracking Enhancement - start
                Map<String, AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper> programMap 
                    = new Map<String, AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper>();
                AGN_AMI_CPD_Module_Wrapper mw 
                    = new AGN_AMI_CPD_Module_Wrapper(cm, 
                                                     learningPathMap.get(cm.Learning_AGN_AMI__c 
                                                                         + '_' + accountRecord.Id), 
                                                     sessionCounts.get(cm.Learning_AGN_AMI__r.Module_AGN__c),
                                                     (Integer)cm.Learning_AGN_AMI__r.Curriculum_Sequence_AGN__c);
                List<AGN_AMI_CPD_Module_Wrapper> tempMWList 
                    = new List<AGN_AMI_CPD_Module_Wrapper>();
                tempMWList.add(mw);
                AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper programList 
                    = new AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper(cm.Program_AGN_AMI__c, tempMWList);
                programMap.put(cm.Program_AGN_AMI__c, programList);
                Map<Integer, String> programOrder = new Map<Integer, String>();
                programOrder.put((Integer)cm.Learning_AGN_AMI__r.Curriculum_Sequence_AGN__c, cm.Program_AGN_AMI__c);
                temp.programOrder = programOrder;
                // Added as part of CPD Tracking Enhancement - end
                
                temp.Id = cm.Learning_AGN_AMI__r.Curriculum_AGN__c;
                temp.currName = cm.Curriculam_AGN_AMI__c;
                temp.currDesc = cm.Learning_AGN_AMI__r.Curriculum_AGN__r.Description_AGN__c;
                temp.imageURL = cm.Learning_AGN_AMI__r.Curriculum_AGN__r.AMI_Image_URL_AGN__c;
                temp.sequence = (Integer)cm.Learning_AGN_AMI__r.Curriculum_AGN__r.Curriculum_Header_Sequence_AGN__c;
                // Updated as part of CPD Tracking Enhancement - start
                // temp.currTree is made obsolete and hence commented, and programTree attribute is added in its place
                // temp.currTree = tempCurrTree;     
                temp.programTree = programMap;
                // Updated as part of CPD Tracking Enhancement - end
                temp.moduleCount = 1;
                cpdCurrMap.put(temp.Id,temp);
                currList.add(temp.Id);
                system.debug('currList'+currList);
            }
            else {
                
                AGN_AMI_CPD_Curr_Wrapper temp = cpdCurrMap.get(cm.Learning_AGN_AMI__r.Curriculum_AGN__c);
                /* Commented as part of CPD Tracking Enhancement    
                Map<String, List<AMI_Learning_AGN__c>> tempCurrTree = temp.currTree;
                List<AMI_Learning_AGN__c> moduleList ;
                if(tempCurrTree.keySet().contains(cm.Program_AGN_AMI__c)) {
                    moduleList = tempCurrTree.get(cm.Program_AGN_AMI__c);
                }
                else { 
                    moduleList = new List<AMI_Learning_AGN__c>();
                }
                AMI_Learning_AGN__c module = new AMI_Learning_AGN__c();
                module.Module_AGN__c = cm.Module_AGN_AMI__c;
                module.Id = cm.Learning_AGN_AMI__r.Module_AGN__c;
                module.File_name_AGN__c = cm.Learning_AGN_AMI__c;
                module.Session_AGN__c = cm.Learning_AGN_AMI__r.Module_AGN__r.Module_Duration_AGN__c.toPlainString();
                module.Module_Content_Type_AGN__c = cm.Learning_AGN_AMI__r.Module_AGN__r.Module_Content_Type_AGN__c;
                if(learningPathMap.keySet().contains(module.Id + '_' + accountRecord.Id)) {
                    module.Tags_AGN__c = learningPathMap.get(module.Id + '_' + accountRecord.Id).Module_Status_AGN__c;
                }                
                else {
                    module.Tags_AGN__c = 'Not Started';
                }
                moduleList.add(module);
                tempCurrTree.put(cm.Program_AGN_AMI__c, moduleList);
                */ 
                
                // Added as part of CPD Tracking Enhancement - start
                List<AGN_AMI_CPD_Module_Wrapper> tempMWList;
                Map<String, AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper> tempProgramTree = temp.programTree;
                if(tempProgramTree.keySet().contains(cm.Program_AGN_AMI__c)) {
                    tempMWList = tempProgramTree.get(cm.Program_AGN_AMI__c).modules;
                }
                else { 
                    tempMWList = new List<AGN_AMI_CPD_Module_Wrapper>();
                }
                AGN_AMI_CPD_Module_Wrapper mw = 
                    new AGN_AMI_CPD_Module_Wrapper(cm, 
                                                   learningPathMap.get(cm.Learning_AGN_AMI__c
                                                                       + '_' + accountRecord.Id), 
                                                   sessionCounts.get(cm.Learning_AGN_AMI__r.Module_AGN__c), 
                                                   (Integer)cm.Learning_AGN_AMI__r.Curriculum_Sequence_AGN__c);
                tempMWList.add(mw);
                AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper programList 
                    = new AGN_AMI_CPD_Curr_Wrapper.ProgramWrapper(cm.Program_AGN_AMI__c, tempMWList);
                if(!tempProgramTree.keySet().contains(cm.Program_AGN_AMI__c)) {
                    temp.programOrder.put((Integer)cm.Learning_AGN_AMI__r.Curriculum_Sequence_AGN__c, cm.Program_AGN_AMI__c);
                }
                tempProgramTree.put(cm.Program_AGN_AMI__c, programList);
                
                // Added as part of CPD Tracking Enhancement - end
                
                // Updated as part of CPD Tracking Enhancement - start
                // temp.currTree is made obsolete and hence commented, and programTree attribute is added in its place
                // temp.currTree = tempCurrTree;
                temp.programTree = tempProgramTree;
                // Updated as part of CPD Tracking Enhancement - end
                
                temp.moduleCount = temp.moduleCount + 1;
                cpdCurrMap.put(temp.Id,temp);
                system.debug('cpdCurrMap'+cpdCurrMap);
            }
        }
        cpdCurrList = cpdCurrMap.values();
        cpdCurrList.sort();
        checkLearningPath();
        system.debug('cpdCurrMap'+cpdCurrList);
    } 
    
    
    
    public void checkLearningPath(){
        
        Id SetUserSpec; 
        String SetUsertype;
        Set<Id> SetUserspecificmodules = new Set<Id>();
        Set<Id> SetUserResc = new set <Id>();
        visibleLRD = new List<AMI_Lrn_Rel_Dtl_AGN__c>();
        Boolean lpAdded;
        
        List<AMI_Learning_Path_AGN__c> lstALPCheck = [Select Id,
                                                      Module__c,
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
                                                      and Module__c in (SELECT Learning_AGN_AMI__c
                                                                        FROM AMI_CPD_Module_AGN__c 
                                                                        WHERE Certification_AGN_AMI__c =: cert.Id)];
        
        system.debug('lstALPCheck'+lstALPCheck);
        
        List<AMI_Lrn_Rel_Dtl_AGN__c> lstALRD=[Select Id,
                                              Name,
                                              Curriculum_AGN__r.Name,
                                              Curriculum_Fma_AGN__c,
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
                                              Country_AGN__c 
                                              from AMI_Lrn_Rel_Dtl_AGN__c 
                                              where Id in (SELECT Learning_AGN_AMI__c 
                                                           FROM AMI_CPD_Module_AGN__c 
                                                           WHERE Certification_AGN_AMI__c =: cert.Id)
                                              and Country_AGN__r.Name = :userCountryName 
                                              and Language_AGN__c =: userLanguage
                                              and Active_AGN__c = true
                                              ORDER BY Curriculum_Sequence_AGN__c NULLS LAST];
        
        
        SetUserSpec = accountRecord.AMI_Specialty_AGN__c;
        SetUsertype = accountRecord.Type_AGN__c;
        List<AMI_HCP_Profile_AGN__c> hCPProfile = [Select Id,
                                                   Account_AGN__c,
                                                   Injector_Status_AGN__c 
                                                   from AMI_HCP_Profile_AGN__c 
                                                   where Account_AGN__c =: accountRecord.Id limit 1];
        
        List<AMI_Module_Visibility_AGN__c> LstUserresModule = [Select AMI_Learning_agn__c
                                                               from AMI_Module_Visibility_AGN__c 
                                                               where AMI_Specialty_AGN__c =: SetUserSpec
                                                               and AMI_Learning_agn__r.Country_AGN__r.Name =: userCountryName ];
        
        List<AMI_HCP_modules_AGN__c> LstUserspecModule =[Select AMI_Module_AGN__c
                                                         from AMI_HCP_modules_AGN__c  
                                                         where AMI_Account_AGN__c =: accountRecord.Id ];   
        
        
        
        
        for(AMI_HCP_modules_AGN__c b:LstUserspecModule )
        {
            SetUserspecificmodules.add(b.AMI_Module_AGN__c);
        } 
        
        for(AMI_Module_Visibility_AGN__c a:LstUserresModule )
        {
            SetUserResc.add(a.AMI_Learning_agn__c);
        }
        
        for(AMI_Lrn_Rel_Dtl_AGN__c alrd:lstALRD) 
        {
            if(alrd.Module_AGN__r.Restricted_AGN__c)
            {
                if(SetUserspecificmodules.contains(alrd.Id) || SetUserResc.contains(alrd.Module_AGN__c))
                {
                    visibleLRD.add(alrd);
                }
            }
            else 
            {
                visibleLRD.add(alrd);
            }
            
        }
        List<AMI_CPD_Granted_AGN__c> cpdList=[SELECT Id,Account_name_AGN_AMI__c, Achieved_Certification_AGN_AMI__c, HCP_AGN_AMI__c FROM AMI_CPD_Granted_AGN__c 
                                              WHERE HCP_AGN_AMI__c =: accountRecord.Id AND Achieved_Certification_AGN_AMI__c =: cert.Id]; 
        
        system.debug(visibleLRD.size());
        showAddButton = ((!(visibleLRD.size()<=lstALPCheck.size())) || cpdList.isEmpty());
    }
    
    public void addCurrToLearningPath(){
        /*AMI MENA changes- Start */
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userCountryName=userDetails.maskedUserCountryName;
        /*AMI MENA changes- End */
        string lpRecOwner=AMI_User_Settings_AGN__c.getValues(userCountryName).LP_Record_Owner_AGN__c;
        List<User> lstAmiAdmin=[select Id from user where UserName=:lpRecOwner Limit 1];
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
        /*AMI MENA changes- Start */
        Id usrCountry=[Select id from Country_vod__c where Name=:userCountryName].id;
        /*AMI MENA changes- End */
        for(AMI_Lrn_Rel_Dtl_AGN__c getMod : visibleLRD)
        {
            
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
        if(lstALP != null)
        {
            try
            {
                insert lstALP;
            }
            Catch(DMLException ex)
            {
                AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Curriculum_Page_Controller','AddCurrToLearningPath');
            }               
        }
        for(AMI_Lrn_Rel_Dtl_AGN__c getMod : visibleLRD)
        { 
            for(AMI_Learning_Path_AGN__c getmodadd:lstALP)
            {
                if(getMod.Id == getmodadd.Module__c)
                {
                    for(AMI_Sessions_AGN__c getsess:lstsessions)
                    {
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
        showAddButton = false;
    }
    
    
    
    public void createCPDGrant(){
        
        addCurrToLearningPath();
        String completedCurricula = completedCurricula();
        AMI_CPD_Granted_AGN__c newCPD = new AMI_CPD_Granted_AGN__c(Account_name_AGN_AMI__c = contactRecord.FirstName 
                                                                   + ' ' + contactRecord.LastName, 
                                                                   Achieved_Certification_AGN_AMI__c = cert.Id, 
                                                                   HCP_AGN_AMI__c = accountRecord.Id, 
                                                                   AMI_Certification_Status_AGN__c = 'Not Started');
        system.debug('newCPD'+newCPD);
        if(completedCurricula != null) {
            newCPD.Curricula_Completed_AGN_AMI__c = completedCurricula;
            List<String> tempList = completedCurricula.split(';');
            if(tempList.size() == cert.Total_Curricula_AGN_AMI__c) {
                newCPD.AMI_Certification_Status_AGN__c = 'Completed';
                newCPD.DateOfCompletion_AGN_AMI__c = DateTime.now();
            }
            else {
                newCPD.AMI_Certification_Status_AGN__c = 'In Progress';
            }
        }
        else{
            List<AMI_Lrn_Rel_Dtl_AGN__c> CPDCurriculamList=[Select Curriculum_AGN__c  from AMI_Lrn_Rel_Dtl_AGN__c 
                                                         where Id in (Select Learning_AGN_AMI__c 
                                                                      FROM AMI_CPD_Module_AGN__c WHERE
                                                                      Certification_AGN_AMI__c=:newCPD.Achieved_Certification_AGN_AMI__c) and Active_AGN__c=true];
            system.debug('CPDCurriculamList'+CPDCurriculamList);
            List<ID> Curriculamcheck=new List<ID>();
            for(AMI_Lrn_Rel_Dtl_AGN__c mdl: CPDCurriculamList){
                if(!Curriculamcheck.contains(mdl.Curriculum_AGN__c)){
                    Curriculamcheck.add(mdl.Curriculum_AGN__c);
                }
            }
            system.debug('Curriculamcheck'+Curriculamcheck);
            integer countCompletedModulelist;
            
            list<integer> listcount = new list<integer>();
            for(Id CID:Curriculamcheck){
                countCompletedModulelist =[select count() from AMI_Learning_Path_AGN__c where Module__r.Curriculum_AGN__c =:CID 
                                       and HCP_AGN__c =:newCPD.HCP_AGN_AMI__c and Module_Status_AGN__c ='Completed' ];
            listcount.add(countCompletedModulelist);
            }
            system.debug('countCompletedModulelist'+countCompletedModulelist);
            if(listcount[0]!=null && listcount[0]!=0){
                newCPD.AMI_Certification_Status_AGN__c = 'In Progress';
            }else{
                newCPD.AMI_Certification_Status_AGN__c = 'Not Started';
            }
            
        }
        //AMI-CR-3666-CPD reporting -Start
        List<AMI_CPD_Granted_AGN__c> cpdList=[SELECT Id,Account_name_AGN_AMI__c, Achieved_Certification_AGN_AMI__c, HCP_AGN_AMI__c FROM AMI_CPD_Granted_AGN__c 
                                              WHERE HCP_AGN_AMI__c =: accountRecord.Id AND Achieved_Certification_AGN_AMI__c =: cert.Id]; 
        system.debug('cpdList'+cpdList);
        if (!Schema.sObjectType.AMI_CPD_Granted_AGN__c.isCreateable()){
            if(cpdList.isEmpty()){
                try{
                    insert newCPD;
                    system.debug('newCPD'+newCPD);
                    List<AMI_Lrn_Rel_Dtl_AGN__c> CurriculamList=[Select Curriculum_AGN__c  from AMI_Lrn_Rel_Dtl_AGN__c 
                                                           where Id in (Select Learning_AGN_AMI__c 
                                                                        FROM AMI_CPD_Module_AGN__c WHERE
                                                                        Certification_AGN_AMI__c=:newCPD.Achieved_Certification_AGN_AMI__c) and Active_AGN__c=true];
                    List<ID> FinalCurriculamList=new List<ID>();
                    for(AMI_Lrn_Rel_Dtl_AGN__c mdl: CurriculamList){
                        if(!FinalCurriculamList.contains(mdl.Curriculum_AGN__c)){
                            FinalCurriculamList.add(mdl.Curriculum_AGN__c);
                        }
                    }
                   
                    integer countTotalModule=0;
                    integer countCompletedModule=0;

                    List<CPD_Curricula_AGN_AMI__c> insertList = new List<CPD_Curricula_AGN_AMI__c>();
                    for(Id CID:FinalCurriculamList){
                        
                        countTotalModule=[Select count() from AMI_Lrn_Rel_Dtl_AGN__c where Curriculum_AGN__c=: CID and Active_AGN__c=true];
                        
                        countCompletedModule =[select count() from AMI_Learning_Path_AGN__c where Module__r.Curriculum_AGN__c =:CID 
                                                                          and HCP_AGN__c =:newCPD.HCP_AGN_AMI__c and Module_Status_AGN__c ='Completed' ];

                        insertList.add(new CPD_Curricula_AGN_AMI__c(AMI_CPD_Granted_AGN_AMI__c=newCPD.ID,
                                                                   Curriculam_Id__c=CID,
                                                                   HCP_name_AGN_AMI__c=newCPD.Account_name_AGN_AMI__c,
                                                                   AGN_AMI_HCP_Account__c=newCPD.HCP_AGN_AMI__c,
                                                                   AGN_AMI_Total_Module_Count__c=countTotalModule,
                                                                   AGN_AMI_Completed_Module__c=countCompletedModule,
                                                                   AGN_AMI_CPD_Curriculum_Completion_Date__c= (countTotalModule==countCompletedModule ? datetime.now() : null)));
                    }
                    insert insertList;
                    //AMI-CR-3666-CPD reporting -End
                }
                catch(Exception ex){
                    system.debug('Exception : '+ex.getMessage());
                    AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_CPD_Course_Controller','createCPDGrant');
                }    
            }
        }  
    }
    
    public String completedCurricula() { 
        String currNameList;
        List<AMI_Learning_Path_AGN__c> lstALPCheck = [SELECT Id,
                                                      Module__c,
                                                      Module__r.Module_AGN__c,
                                                      Module__r.Curriculum_AGN__c, 
                                                      Module_Status_AGN__c
                                                      FROM AMI_Learning_Path_AGN__c
                                                      WHERE HCP_AGN__c=: accountRecord.Id 
                                                      AND Module__r.Curriculum_AGN__c in :currList 
                                                      AND Module_Status_AGN__c = 'Completed'];
        
        Map<String, Set<String>> completedModules = new Map<String, Set<String>>();
        for(AMI_Learning_Path_AGN__c lp : lstALPCheck) { 
            Set<String> moduleList;
            if(completedModules.keySet().contains(lp.Module__r.Curriculum_AGN__c)) {
                moduleList = completedModules.get(lp.Module__r.Curriculum_AGN__c);
                
            }
            else { 
                moduleList = new Set<String>();
            }
            moduleList.add(lp.Module__r.Module_AGN__c);
            completedModules.put(lp.Module__r.Curriculum_AGN__c, moduleList);
        }
        List<AMI_Lrn_Rel_Dtl_AGN__c> lstALRD=[SELECT Id, Curriculum_AGN__c, Module_AGN__c 
                                              FROM AMI_Lrn_Rel_Dtl_AGN__c 
                                              WHERE Id IN (SELECT Learning_AGN_AMI__c 
                                                           FROM AMI_CPD_Module_AGN__c 
                                                           WHERE Certification_AGN_AMI__c =: cert.Id)
                                              AND Country_AGN__r.Name = :userCountryName 
                                              AND Language_AGN__c =: userLanguage
                                              AND Active_AGN__c = true
                                              ORDER BY Curriculum_Sequence_AGN__c NULLS LAST];
        Map<String, Set<String>> requiredModules = new Map<String, Set<String>>();
        for(AMI_Lrn_Rel_Dtl_AGN__c lrd : lstALRD) { 
            Set<String> moduleList;
            if(requiredModules.keySet().contains(lrd.Curriculum_AGN__c)) {
                moduleList = requiredModules.get(lrd.Curriculum_AGN__c);
                
            }
            else { 
                moduleList = new Set<String>();
            }
            moduleList.add(lrd.Module_AGN__c);
            requiredModules.put(lrd.Curriculum_AGN__c, moduleList);
        }
        
        
        for(String currId : requiredModules.keySet()) {
            if(completedModules.keySet().contains(currId)) {
                if(completedModules.get(currId).containsAll(requiredModules.get(currId))) {
                    currNameList = (currNameList != null) ? (currNameList + ';' + currId) : currId;
                }
            }
        }
        return currNameList;
    }
}