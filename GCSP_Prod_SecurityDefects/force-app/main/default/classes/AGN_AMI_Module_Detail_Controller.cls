public without sharing class AGN_AMI_Module_Detail_Controller 
{
    User user;
    Account accountRecord;
    Contact contactRecord;
    public String userLanguage {get;set;}
    public String userCountryName {get;set;}
    public AMI_Learning_AGN__c moduleDetail{get;set;}
    public String moduleStatus {get; set;}
    public AMI_Contact_AGN__c contact{get;set;}
    Public List<AMI_Learning_Faculty_AGN__c> lstLFA{get;set;}
    public List<AMI_Sessions_AGN__c> lstSession{get;set;}
    public Id sessionId{get;set;}
    public Integer count{get;set;}
    public string duration{get;set;}
    public string facultydetailsID{get;set;}
    public string description{get;set;}
    public List<AMI_Objective_AGN__c> lstcurrobj{get;set;}
    public string name{get;set;}
    public Integer counter{get;set;}
    public string trainingURL{get;set;}
    //public decimal moduleDuration{get;set;} 
    public Map<string,List<AMI_Lrn_Rel_Dtl_AGN__c>> curriculumMap{get;set;}
    public Set<AMI_Lrn_Rel_Dtl_AGN__c> LstModToAdd{get;set;}
    public string currName{get;set;}
    public AMI_Learning_AGN__c currdesc{get;set;}
    public string moduleCount{get;set;}
    public boolean lpAdded{get;set;}
    public string firstModule{get;set;}
    public string priorModule{get;set;}
    public string priorId{get;set;}
    public String lRDId {get; set;}    
    public string noPrior{get;set;}
    public AMI_Lrn_Rel_Dtl_AGN__c objALRD{get;set;}
    public List<wrapSession> lstWrapSession{get;set;}
    public boolean blResume{get;set;}
    public Id UsersessionId{get;set;}
    List<AMI_Lrn_Rel_Dtl_AGN__c> tempUnResALRD;
    List<AMI_Lrn_Rel_Dtl_AGN__c> lstALRD;
    String curriculumId;   
    Set<Id> SetUserspecificmodules; 
    set<string> setMod;
    List<AMI_Lrn_Rel_Dtl_AGN__c> tempALRD;
    Map<string,string> mpAPS;
    wrapSession objWrap;
    Id SetUserSpec; 
    Set<Id> SetUserResc; 
    String SetUsertype; 
    //List<AMI_Module_Restriction_AGN__c> LstUserresModule;
    List<AMI_Module_Visibility_AGN__c> LstUserresModule;
    Public AMI_Learning_Faculty_AGN__c lstFaculty{get;set;}
    List<Account> LstUserDetails;
    List<AMI_HCP_modules_AGN__c  > LstUserspecModule;
    List<AMI_Path_Session_AGN__c>  lstAPS;
    List<AMI_Sessions_AGN__c> lstSess;
    string urlVal;
    public string lastsessionstatusid{get;set;}
    public string lastsessionstatus{get;set;}
    public string lastSessionStatusUrl {get; set;}
    //public string finalUrl{get;set;}
    public string sessionStatus {get; set;}
    public Id sessionStatusId {get; set;}
    public string trainingType {get; set;}
    //public String confirmationInput {get; set;}
    //public AMI_Learning_Faculty_AGN__c facultyDetailsdisplay {get;set;}
    List<AMI_HCP_Profile_AGN__c> hCPProfile;
    public List<String> programList {get; set;}
    public String modulePreRequisite {get;set;}
    public List<User> lstAmiAdmin;
    public AMI_Web_Visibility_Settings_AGN__c AWV {get; set;}
    public String userCountry{get;set;}
    
    public String CurriculaNames { get; set; }//3277
    public AMI_CPD_Granted_AGN__c certificate {get; set;}//3277
    public integer totalCurriculum {get; set;}//3277
    public integer completedCurriculum {get; set;}//3277
    public string achievementId{get;set;}//3277
    
    public boolean IsCompleted{get;set;}//3602
    public AGN_AMI_CPD_Curr_Wrapper currWrap {get; set;}
    public boolean sessionProgressVisibility{get; set;}
    public boolean flagForSec{get; set;}
     public decimal TimeInSeconds{get; set;}
    
    
    
    public AGN_AMI_Module_Detail_Controller()
    {  
        flagForSec = false;
        IsCompleted =false;
        lstAmiAdmin=new List<User>();
        lstLFA=new List<AMI_Learning_Faculty_AGN__c>(); 
        programList = new List<string>();
        mpAPS=new Map<string,string>();
        SetUserResc = new set <Id>(); 
        SetUserspecificmodules = new Set<Id>();
        hCPProfile=new List<AMI_HCP_Profile_AGN__c>();       
        urlVal = Apexpages.currentPage().getUrl();
        lstWrapSession=new List<wrapSession>();
        lstSession=new List<AMI_Sessions_AGN__c>();
        blResume=false;
        setMod=new set<string>();
        LstModToAdd = new Set<AMI_Lrn_Rel_Dtl_AGN__c>();
        curriculumMap=new Map<string,List<AMI_Lrn_Rel_Dtl_AGN__c>>(); 
        /* Added for hide modules contact section Logic 7/7/2020 - Start */
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userCountry =  userDetails.userCountryName;
        if(userDetails.user.Is_AMI_Demo_User_AGN__c == true){
            AWV = AMI_Web_Visibility_Settings_AGN__c.getValues('demo');
        }else{
            AWV = AMI_Web_Visibility_Settings_AGN__c.getValues(userCountry);
        }
        /* Added for hide modules contact section Logic 7/7/2020 - End */  
        
        lRDId= ApexPages.currentPage().getParameters().get('lRDId');        
        getModuleDetail();
        checkCertification();
        sessionId=ApexPages.currentPage().getParameters().get('sessionId');
        
        sessionProgressVisibility=AMI_Web_Visibility_Settings_AGN__c.getValues(userCountryName).AGN_AMI_Session_Progress_Visibility__c;
        
        System.debug('The lstsession at start is---->' +lstSession);
        if(lstSession!=null)
        {
            if(lstSession.size()>0){
                for(AMI_Sessions_AGN__c obj:lstSession){
                    if(obj.Id==sessionId){
                        trainingURL=obj.Training_URL_AGN__c;
                        trainingType=obj.Content_Type_AGN__c;
                        sessionStatus = [Select Progress_Key_AGN__c from AMI_Path_Session_AGN__c 
                                         where Name_AGN__c =: obj.Name_AGN__c 
                                         and AMI_Learning_Path_AGN__r.HCP_AGN__c =: accountRecord.Id
                                         and AMI_Learning_Path_AGN__r.Module__c =: LRDId
                                         Limit 1].Progress_Key_AGN__c;
                        sessionStatusId = sessionId;
                        name=obj.Name_AGN__c;
                    }
                }
            }            
        }
        //Objective
        
        lstcurrobj = [select Objective_description_AGN__c from AMI_Objective_AGN__c where Parent_Module_AGN__c =:objALRD.Module_AGN__r.Id];    
        //End Objective
        
        // prior learning
        
        if(objALRD.Curriculum_AGN__r.Id!=null)
        {
            currWrap = new AGN_AMI_CPD_Curr_Wrapper();
            //currdesc =objALRD.Curriculum_AGN__c;
            lstALRD=new List<AMI_Lrn_Rel_Dtl_AGN__c >(); 
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
                     where Curriculum_AGN__c=:objALRD.Curriculum_AGN__r.Id 
                     and Country_AGN__r.Name = :userCountryName 
                     and Language_AGN__c =: userLanguage
                     and Active_AGN__c = true 
                     order by Curriculum_Sequence_AGN__c asc];
            //Added active check in AMI_Learning_Path_Sessions__c query
            List<AMI_Learning_Path_AGN__c>  lstALPCheck = [Select Id,
                                                           Module__c,
                                                           (SELECT Session_Status_AGN__c, Session_Code_AGN__c 
                                                            FROM AMI_Learning_Path_Sessions__r where Active_AGN__c=true),  
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
                                                           and Module__r.Curriculum_AGN__c=:objALRD.Curriculum_AGN__r.Id
                                                           and Country_AGN__r.Name = :userCountryName ];
            
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
            
            /* Substituted by accountRecord from AGN_AMI_Utility_class
LstUserDetails=[Select Id,
Name,
AMI_Specialty_AGN__c,
Type_AGN__c
from Account 
where RecordType.Name='Professional_vod'
and id =: accountRecord.Id];

for(Account spec:LstUserDetails)
{
if(spec.Id == accountRecord.Id )
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
                          where Account_AGN__c = :accountRecord.Id limit 1];
            
            system.debug('sn--'+ hCPProfile);                          
            
            string injecstatus = hCPProfile.size()>0?hCPProfile[0].Injector_Status_AGN__c:null;                                                         
            
            system.debug('ag--'+ injecstatus );
            
            // LstUserresModule = [Select AMI_Learning_agn__c
            //                     from AMI_Module_Restriction_AGN__c 
            //                     where AMI_Specialty_AGN__c in :SetUserSpec
            //                     and Injector_Status_AGN__c=: injecstatus
            //                    ];
            LstUserresModule = [Select AMI_Learning_agn__c
                                from AMI_Module_Visibility_AGN__c 
                                where AMI_Specialty_AGN__c =: SetUserSpec
                                and Injector_Status_AGN__c=: injecstatus
                               ];
            
            LstUserspecModule =[Select AMI_Module_AGN__c
                                from AMI_HCP_modules_AGN__c  
                                where AMI_Account_AGN__c =: accountRecord.Id ];   
            
            
            
            
            for(AMI_HCP_modules_AGN__c b:LstUserspecModule )
            {
                SetUserspecificmodules.add(b.AMI_Module_AGN__c);
            }   
            
            //   for(AMI_Module_Restriction_AGN__c a:LstUserresModule )
            //   {
            //       SetUserResc.add(a.AMI_Learning_agn__c);
            //   }
            
            for(AMI_Module_Visibility_AGN__c a:LstUserresModule )
            {
                SetUserResc.add(a.AMI_Learning_agn__c);
            }  
            
            
            system.debug('SetUserResc--'+SetUserResc);
            system.debug('SetUserspecificmodules--'+SetUserspecificmodules);
            system.debug('lstALRD--'+lstALRD);
            boolean blPrior=false;
            
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
                
                
                
                tempALRD=new List<AMI_Lrn_Rel_Dtl_AGN__c>();
                tempUnResALRD=new List<AMI_Lrn_Rel_Dtl_AGN__c>();
                if(alrd.Module_AGN__r.Restricted_AGN__c)
                {
                    
                    if(SetUserspecificmodules.contains(alrd.Id) || SetUserResc.contains(alrd.Module_AGN__c))
                    {
                        LstModToAdd.add(alrd);
                        setMod.add(string.valueof(alrd.Curriculum_AGN__c)+string.valueof(alrd.Program_AGN__c)+string.valueof(alrd.Module_AGN__c));
                        
                        system.debug('Entered for ' + alrd.Id);
                        /*for(AMI_Lrn_Rel_Dtl_AGN__c alrdForProg:lstALRD)
{
system.debug('program--'+alrdForProg.Module_Fma_AGN__c);
system.debug('SetUserspecificmodules--'+SetUserspecificmodules);
system.debug('SetUserResc--'+SetUserResc);
if(alrdForProg.Program_AGN__c==alrd.Program_AGN__c && (SetUserspecificmodules.contains(alrdForProg.Id) || SetUserResc.contains(alrdForProg.Module_AGN__c)))
{
system.debug('alrd.Id--'+alrdForProg.Module_Fma_AGN__c);
if(firstModule==null || firstModule=='')
firstModule=alrdForProg.Module_Fma_AGN__c;

if(alrdForProg.Module_Fma_AGN__c!=moduleDetail.Module_AGN__c && blPrior==false){
priorModule=alrdForProg.Module_Fma_AGN__c;
priorId=alrdForProg.Id;
}
else
blPrior=true;     


tempALRD.add(alrdForProg);
LstModToAdd.add(alrdForProg);
setMod.add(string.valueof(alrdForProg.Curriculum_AGN__c)+string.valueof(alrdForProg.Program_AGN__c)+string.valueof(alrdForProg.Module_AGN__c));
//curriculumMap.put(alrd.Program_Fma_AGN__c, tempALRD);  
if(curriculumMap.keySet().size()<1)
{
curriculumMap.put(alrd.Program_Fma_AGN__c, tempALRD); 
programList.add(alrd.Program_Fma_AGN__c);
}
else
{
if(curriculumMap.keyset().contains(alrd.Program_Fma_AGN__c) )
{
if(!curriculumMap.get(alrd.Program_Fma_AGN__c).contains(alrd))
{
curriculumMap.get(alrd.Program_Fma_AGN__c).add(alrd);                                            
}
}
else
{
curriculumMap.put(alrd.Program_Fma_AGN__c, tempALRD);
programList.add(alrd.Program_Fma_AGN__c);
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
                        
                        if(firstModule==null || firstModule=='')
                            firstModule=alrd.Module_Fma_AGN__c;
                        
                        if(alrd.Module_Fma_AGN__c!=moduleDetail.Module_AGN__c && blPrior==false){
                            priorModule=alrd.Module_Fma_AGN__c;
                            priorId=alrd.Id;
                        }
                        else
                            blPrior=true;     
                        
                        // programOrder.put((Integer)alrd.Curriculum_Sequence_AGN__c, alrd.Program_FMA_AGN__c);
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
                    
                    if(firstModule==null || firstModule=='')
                        firstModule=alrd.Module_Fma_AGN__c;
                    
                    if(alrd.Module_Fma_AGN__c!=moduleDetail.Module_AGN__c && blPrior==false){
                        priorModule=alrd.Module_Fma_AGN__c;
                        priorId=alrd.Id;
                    }
                    else
                        blPrior=true;     
                    
                    
                    // programOrder.put((Integer)alrd.Curriculum_Sequence_AGN__c, alrd.Program_FMA_AGN__c);
                    currWrap.programOrder = programOrder;
                    currWrap.Id = alrd.Curriculum_AGN__c;
                    currWrap.currName = alrd.Curriculum_Fma_AGN__c;
                    currWrap.currDesc = alrd.Curriculum_AGN__r.Description_AGN__c;
                    currWrap.imageURL = alrd.Curriculum_AGN__r.AMI_Image_URL_AGN__c;
                    currWrap.sequence = (Integer)alrd.Curriculum_AGN__r.Curriculum_Header_Sequence_AGN__c;
                    currWrap.programTree =programMap;
                    currWrap.moduleCount = setMod.size();
                    
                    
                    /*for(AMI_Lrn_Rel_Dtl_AGN__c alrdForProg:lstALRD)
{
if(!alrdForProg.Module_AGN__r.Restricted_AGN__c && alrdForProg.Program_AGN__c==alrd.Program_AGN__c)
{
if(firstModule==null || firstModule=='')
firstModule=alrdForProg.Module_Fma_AGN__c;

if(alrdForProg.Module_Fma_AGN__c!=moduleDetail.Module_AGN__c && blPrior==false){
priorModule=alrdForProg.Module_Fma_AGN__c;
priorId=alrdForProg.Id;
}
else
blPrior=true; 
system.debug('alrd.Id--'+alrdForProg.Module_Fma_AGN__c);
tempUnResALRD.add(alrdForProg);
LstModToAdd.add(alrdForProg);
setMod.add(string.valueof(alrdForProg.Curriculum_AGN__c)+string.valueof(alrdForProg.Program_AGN__c)+string.valueof(alrdForProg.Module_AGN__c));
//curriculumMap.put(alrd.Program_Fma_AGN__c, tempUnResALRD); 

if(curriculumMap.keySet().size()<1)
{
curriculumMap.put(alrd.Program_Fma_AGN__c, tempUnResALRD); 
programList.add(alrd.Program_Fma_AGN__c);
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
programList.add(alrd.Program_Fma_AGN__c);
}
}
}
}*/
                }
                
            }
            /*if(priorModule==null || priorModule=='')
noPrior=Label.AMI_Module_Detail_noPrior;
else
noPrior=Label.AMI_Module_Detail_Prior;*/
            
            moduleCount=String.valueof(setMod.size());
            
            system.debug('lRDId--'+lRDId);
            
            lpAdded=true;
            List<AMI_Learning_Path_AGN__c> usrLP=[select Id,Module__c,Module_Status_AGN__c,Last_Attended_AGN__c,Previous_Videos_Attented_AGN__c
                                                  from AMI_Learning_Path_AGN__c where HCP_AGN__c =: accountRecord.Id and Module__c=:lRDId];
            
            
            if(usrLP.size()>0)
            {     
                lpAdded=false;
                moduleStatus = usrLP[0].Module_Status_AGN__c;
                modulePreRequisite = String.valueOf(usrLP[0].Previous_Videos_Attented_AGN__c);
            }
            
            
            
            system.debug('lpAdded:' + lpAdded);
        }
        
        //end 
        //learning faculty
        system.debug('moduleid:' + objALRD.Module_AGN__r.Id);
        
        lstLFA=[select AMI_Faculty_AGN__r.id,AMI_Faculty_AGN__r.Name,AMI_Faculty_AGN__r.AMI_Specialty_AGN__r.Name_AGN__c,AMI_Faculty_AGN__r.Hospital_AGN__c,
                AMI_Faculty_AGN__r.Image_URL_AGN__c,
                AMI_Faculty_AGN__r.Country_AGN__c, AMI_Faculty_AGN__r.Name_AGN__c, 
                AMI_Faculty_AGN__r.Title_AGN__c, AMI_Faculty_AGN__r.email_AGN__c
                from AMI_Learning_Faculty_AGN__c where AMI_Learning_AGN__c=:objALRD.Module_AGN__r.Id];
        system.debug('lstLFA:' + lstLFA);
        If(lstLFA.size() > 0)
        {
            lstFaculty = New AMI_Learning_Faculty_AGN__c();
            lstFaculty = lstLFA[0];
        }
        //end
        
        //contact
        List<AMI_Contact_AGN__c> lstContact=new List<AMI_Contact_AGN__c>();
        lstContact=[select Name,Country_AGN__r.Name,Email_AGN__c, First_Name_AGN__c, Last_Name_AGN__c, 
                    Phone_AGN__c,Photo_URL_AGN__c from AMI_Contact_AGN__c 
                    where Country_AGN__r.name=: userCountryName and Active_AGN__c=true and Is_Support_AGN__c=false 
                    and AGN_AMI_Business_Unit__c=: AGN_AMI_SC_Static_Labels.medicalAesthetics
                    limit 1]; 
        if(lstContact!=null){
            if(lstContact.size()>0)
                contact=lstContact[0];
        }         
        //end  
        
    }
    
    public void getModuleDetail()
    {
        lstWrapSession=new List<wrapSession>();
        lstALRD=new List<AMI_Lrn_Rel_Dtl_AGN__c >();      
        lstALRD=[Select Curriculum_AGN__r.Curriculum_AGN__c,Curriculum_AGN__r.Id,
                 CurrencyIsoCode,Program_AGN__r.Program_AGN__c,
                 Country_AGN__r.Country_Name_vod__c,
                 Country_AGN__c,Module_AGN__r.Id,Curriculum_Fma_AGN__c,Program_Fma_AGN__c 
                 from AMI_Lrn_Rel_Dtl_AGN__c 
                 where id=:lRDId limit 1];
        system.debug('lstALRD is---->' + lstALRD);
        /*AMI MENA changes- Start */
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetailsMENA =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        String userCountry_MENA_tmp=userDetailsMENA.userCountryName;
        /*AMI MENA changes- End */
        if(lstALRD!=null)
        {
            if(lstALRD.size()>0)
                /*AMI MENA changes- Start */
                lstALRD[0].Country_Code_AGN__c=userCountry_MENA_tmp;
            lstALRD[0].Country_AGN__c=[Select id from Country_vod__c where Name=:userCountry_MENA_tmp].id;
            lstALRD[0].Country_AGN__r.Country_Name_vod__c=userCountry_MENA_tmp;
            /*AMI MENA changes- End */
            objALRD=lstALRD[0];
        }
        /* 
user = [Select contact.AccountId,Country_code__c,LanguageLocaleKey from user where id =: Userinfo.getUserid() limit 1];
UserID = user.contact.AccountId;
userLanguage = user.LanguageLocaleKey;
*/
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        
        //userDetails  = AGN_AMI_Utility_class.getUserDeails();   
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        accountRecord = userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;
        
        //UserID = [Select contact.AccountId from user where id =: Userinfo.getUserid()].contact.AccountId;
        //UserID = [Select contact.AccountId from user where id ='0055E000002F4xo'].contact.AccountId; 
        system.debug('objALRD is---->' + objALRD);
        List<AMI_Learning_AGN__c> lstMod=new List<AMI_Learning_AGN__c>();
        lstMod=[select Module_AGN__c,Image_AGN__c,Duration_FMA_AGN__c,Description_AGN__c,Module_Content_Type_AGN__c,Module_Duration_AGN__c,
                SubTitles_AGN__c,Total_Duration_AGN__c,AMI_Image_URL_AGN__c, Anatomy_Area_AGN__c,Module_format_AGN__c,
                Pre_requisite_Module_type_AGN__c,Pre_requisite_Module_Confirmation_AGN__c
                from AMI_Learning_AGN__c where Id=:objALRD.Module_AGN__r.Id Limit 1];
        if(lstMod!=null)
        {
            if(lstMod.size()>0)
               
                moduleDetail=lstMod[0];
            if(lstMod[0].Module_Duration_AGN__c < 1){
                 TimeInSeconds = lstMod[0].Module_Duration_AGN__c*60;
                flagForSec = true;
                
            }
            //moduleStatus=lstMod
        }
        lstSession=[select Id,Name_AGN__c,Session_Code_AGN__c, Content_Type_AGN__c,Duration_AGN__c,File_name_AGN__c,Parent_Module_AGN__r.Module_Content_Type_AGN__c,
                    Status_AGN__c, Training_URL_AGN__c,ZINC_number_AGN__c, Sequence_Number_AGN__c
                    from AMI_Sessions_AGN__c 
                    where Parent_Module_AGN__c=:objALRD.Module_AGN__r.Id and IsActive_AGN__c = true
                    order by Sequence_Number_AGN__c asc];
        
        lstAPS=new List<AMI_Path_Session_AGN__c>();
        lstAPS=[select Session_Status_AGN__c,Session_Code_AGN__c,AMI_Learning_Path_AGN__r.Previous_Videos_Attented_AGN__c,Percentage_For_Completed_Session_AGN__c,
                Training_URL_AGN__c,Name_AGN__c,Progress_Key_AGN__c,Percent_Completed_AGN__c,AMI_Learning_Path_AGN__r.Last_Attended_AGN__c,LastModifiedDate,
                AMI_Learning_Path_AGN__r.Module_Status_AGN__c 
                from AMI_Path_Session_AGN__c 
                where AMI_Learning_Path_AGN__r.Module__c=:lRDId 
                and AMI_Learning_Path_AGN__r.HCP_AGN__c=: accountRecord.Id
                and Active_AGN__c = true
                order by LastModifiedDate];
        system.debug('lstAPS:' + lstAPS);
        
        count=0;
        if(lstSession!=null)
        {
            if(lstSession.size()>0){
                for(AMI_Sessions_AGN__c  obj:lstSession){
                    objWrap=new wrapSession();
                    if(lstAPS.size()>0){
                        modulePreRequisite = String.valueOf(lstAPS[0].AMI_Learning_Path_AGN__r.Previous_Videos_Attented_AGN__c);
                        lpAdded=false;
                        for(AMI_Path_Session_AGN__c  objAPS:lstAPS)
                        {
                            System.debug('Name AGN__c----->' + objAPS.Name_AGN__c);
                            if(objAPS.Session_Code_AGN__c ==obj.Session_Code_AGN__c){
                                //sessionStatusId = obj.Id;
                                //sessionStatus = objAPS.Progress_Key_AGN__c;.
                                System.debug('last Attented---->' +objAPS.AMI_Learning_Path_AGN__r.Last_Attended_AGN__c + 'last modified date---->'  +objAPS.LastModifiedDate);
                                System.debug('IF Condition--->' + String.valueof(objAPS.AMI_Learning_Path_AGN__r.Last_Attended_AGN__c) == String.valueOfgmt(objAPS.LastModifiedDate));
                                if(objAPS.Session_Status_AGN__c == 'In Progress' 
                                   && String.valueof(objAPS.AMI_Learning_Path_AGN__r.Last_Attended_AGN__c) == String.valueOf(objAPS.LastModifiedDate))
                                {
                                    
                                    System.debug('Second IF---->'); 
                                    //trainingURL = obj.Training_URL_AGN__c;
                                    lastsessionstatusid = obj.Id;
                                    lastsessionstatus = objAPS.Progress_Key_AGN__c;
                                    lastSessionStatusUrl = obj.Training_URL_AGN__c; 
                                    trainingType = obj.Content_Type_AGN__c;
                                    
                                    
                                    System.debug('lastsessionstatusid----inprogress>' +lastsessionstatusid + 'lastsessionstatus---->'  +lastsessionstatus);
                                    
                                }
                                
                                if(lastsessionstatusid == null && objAPS.Session_Status_AGN__c  == 'Not Started')
                                {
                                    lastsessionstatusid = obj.Id;
                                    lastsessionstatus = null;
                                    lastSessionStatusUrl = obj.Training_URL_AGN__c; 
                                    System.debug('First IF---->');
                                    //trainingURL = obj.Training_URL_AGN__c;
                                    trainingType = obj.Content_Type_AGN__c;
                                }
                                
                                System.debug('SesstionStatus'+sessionStatus+'___________'+sessionStatusId);
                                objWrap.status=objAPS.Session_Status_AGN__c;
                                objWrap.key=objAPS.Progress_Key_AGN__c;
                                objWrap.percentage = objAPS.Percent_Completed_AGN__c;
                                objWrap.percentageForCompleted = objAPS.Percentage_For_Completed_Session_AGN__c;
                                System.debug('SesstionStatus'+objWrap.percentage+'___________'+objAPS.Percent_Completed_AGN__c);
                                mpAPS.put(objAPS.Name_AGN__c,objAPS.Session_Status_AGN__c);
                                break;
                            }
                            else 
                                objWrap.status='Not Started';
                            
                        }
                        /*lastsessionstatusid = lstAPS[0].id;
lastsessionstatus = lstAPS[0].Progress_Key_AGN__c;
trainingURL = lstAPS[0].Training_URL_AGN__c;*/
                        
                    }
                    else
                    {
                        objWrap.percentage = 0;
                        objWrap.percentageForCompleted =0;
                        objWrap.status='Not Started'; 
                    }
                    objWrap.sess=obj;
                    if(objWrap.sess.Duration_AGN__c<1){
                        objWrap.sessionDuration=objWrap.sess.Duration_AGN__c*60;
                        objWrap.flagforSecSession = true;
                    }
                    else{
                       objWrap.sessionDuration= objWrap.sess.Duration_AGN__c;
                    }
                    lstWrapSession.add(objWrap);
                    count++;
                }
                
                system.debug('lstWrapSession:' +lstWrapSession);
                system.debug('mpAPS:' +mpAPS);
                
                for(AMI_Sessions_AGN__c  obj:lstSession){  
                    if(mpAPS!=null){
                        if(mpAPS.get(obj.Name_AGN__c)=='In Progress'){
                            /*system.debug('mpAPS.get(obj.Name_AGN__c):' + mpAPS.get(obj.Name_AGN__c));
name=obj.Name_AGN__c;
sessionId=obj.Id;
sessionStatus = [Select Progress_Key_AGN__c from AMI_Path_Session_AGN__c 
where Name_AGN__c =: obj.Name_AGN__c 
and AMI_Learning_Path_AGN__r.HCP_AGN__c =: UserID
Limit 1].Progress_Key_AGN__c;
System.debug(obj.Name_AGN__c+sessionStatus+UserID);
sessionStatusId = obj.Id; 
// trainingURL=obj.Training_URL_AGN__c;
sessionContentType=obj.Content_Type_AGN__c;
blResume=true;*/
                            
                            moduleStatus = 'In Progress';
                            IsCompleted =false;//3602
                            break;   
                        }
                        else if(mpAPS.get(obj.Name_AGN__c)=='Completed')
                        {
                            
                            
                            if(mpAPS.values().contains('Not Started')||mpAPS.values().contains('In Progress'))
                            {
                                moduleStatus = 'In Progress';
                                IsCompleted =false;//3602
                                break;
                            }
                            else{
                                moduleStatus = 'Completed';
                                IsCompleted =true;//3602
                                break;
                            }
                        }
                        else
                            moduleStatus = 'Not Started';
                        IsCompleted =false;//3602
                    }                   
                }            
            }            
        }
        System.debug('lastsessionstatusid---->' +lastsessionstatusid + 'lastsessionstatus---->'  +lastsessionstatus);
    } 
    public PageReference AddCurrToLearningPath()
    {
        system.debug('AddCurrToLearningPath');
        system.debug('objALRD-->'+objALRD);
        /*AMI MENA changes- Start */
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userCountryName=userDetails.maskedUserCountryName;
        /*AMI MENA changes- End */
        string lpRecOwner=AMI_User_Settings_AGN__c.getValues(userCountryName).LP_Record_Owner_AGN__c;
        system.debug('AddCurrToLearningPathAddCurrToLearningPath'+lpRecOwner);
        lstAmiAdmin=[select Id from user where UserName=:lpRecOwner Limit 1];
        system.debug('lstAmiAdmin:' + lstAmiAdmin);
        AMI_Learning_Path_AGN__c  objALP=new AMI_Learning_Path_AGN__c();
        List<AMI_Path_Session_AGN__c> lstAPSess=new List<AMI_Path_Session_AGN__c>();
        List<AMI_Learning_Path_AGN__c>  oldObjALP = [Select id from AMI_Learning_Path_AGN__c 
                                                     where Module__c =: lrdId 
                                                     and HCP_AGN__c =: accountRecord.Id];
        system.debug('oldObjALP:' + oldObjALP);
        if(oldObjALP.size()>0)
            return null;
        /*AMI MENA changes- Start */
        Id usrCountry=[Select id from Country_vod__c where Name=:userCountryName].id;
        /*AMI MENA changes- End */
        if(lpAdded==true){              
            objALP.HCP_AGN__c= accountRecord.Id;
            objALP.Contact_AGN__c = contactRecord.Id;
            objALP.Module__c=Id.Valueof(ApexPages.currentPage().getParameters().get('lRDId'));
            
            Map<id,AMI_Lrn_Rel_Dtl_AGN__c > lrnRelDtlMap = new Map<id,AMI_Lrn_Rel_Dtl_AGN__c >([select id,Module_AGN__r.Module_AGN__c,Program_AGN__r.Program_AGN__c,Curriculum_AGN__r.Curriculum_AGN__c from AMI_Lrn_Rel_Dtl_AGN__c where id =: objALP.Module__c]);
            objALP.Unique_Learning_Path__c = String.valueOf(objALP.HCP_AGN__c) + lrnRelDtlMap.get(objALP.Module__c).Module_AGN__r.Module_AGN__c + lrnRelDtlMap.get(objALP.Module__c).Program_AGN__r.Program_AGN__c+ lrnRelDtlMap.get(objALP.Module__c).Curriculum_AGN__r.Curriculum_AGN__c;
            
            
            
            /*AMI MENA changes- Start */
            //objALP.Country_AGN__c=objALRD.Country_AGN__c;
            //objALP.Country_code_AGN__c=objALRD.Country_AGN__r.Country_Name_vod__c;
            objALP.Country_AGN__c=usrCountry;
            objALP.Country_code_AGN__c=userCountryName;
            /*AMI MENA changes- End */
            system.debug('objALRD.Country_AGN__r.Country_Name_vod__c-->'+objALRD.Country_AGN__r.Country_Name_vod__c);
            objALP.OwnerId=lstAmiAdmin.size()>0?lstAmiAdmin[0].Id:Userinfo.getUserid();
            objALP.CurrencyIsoCode=objALRD.CurrencyIsoCode;
            objALP.RecordTypeId= [Select id from RecordType where SobjectType = 'AMI_Learning_Path_AGN__c' AND DeveloperName = 'AGN_Defined'][0].id;
            
            System.debug('The Record Type Id is--->' +objALP.RecordTypeId);
            try
            {
                    //insert objALP;
                	Database.upsert(objALP,AMI_Learning_Path_AGN__c.Unique_Learning_Path__c,false);
                    system.debug('AddCurrToLearningPathobjALP'+objALP);
            }
            Catch(DMLException ex)
            {
            	AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Module_Detail_Controller','AddCurrToLearningPath2');
            } 
            if(objALP.Id != null)
            {
            	system.debug('lstSession>>>'+lstSession);
                for(AMI_Sessions_AGN__c objSess:lstSession){
                	lstAPSess.add(new AMI_Path_Session_AGN__c(AMI_Learning_Path_agn__c=objALP.Id,
                                                          Duration_AGN__c=objSess.Duration_AGN__c,
                                                          File_name_AGN__c=objSess.File_name_AGN__c,
                                                          Name_AGN__c=objSess.Name_AGN__c,
                                                          ZINC_number_AGN__c=objSess.ZINC_number_AGN__c,
                                                          Training_URL_AGN__c=objSess.Training_URL_AGN__c,
                                                          Session_Code_AGN__c=objSess.Session_Code_AGN__c,
                                                          Active_AGN__c = true));
                }
                system.debug('lstAPSess'+lstAPSess);
            
                if(lstAPSess!=null)  
                {
                    try
                    {
                        insert lstAPSess;
                    }
                    Catch(DMLException ex)
                    {
                        AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Module_Detail_Controller','AddCurrToLearningPath1');
                    }
                }
            }
        }
        System.debug(objALP.Id);
        /*Pagereference pr=new PageReference('/Apex/AGN_AMI_Module_Details_Page');
pr.setRedirect(true);
pr.getParameters().put('lRDId',lRDId);*/
        getModuleDetail();
        
        System.debug(lpAdded);
        //ModuleStatus='Not Started';
        return null;  
    }  
    public PageReference sessionInfoUpdate() {
        system.debug('sessionStatus??????' +sessionStatus);
        
        String contentInfo = sessionStatus;
        Id APSId = sessionStatusId;
        System.debug('APSId=='+APSId);
        AMI_Path_Session_AGN__c APS = new AMI_Path_Session_AGN__c ();
        AMI_Sessions_AGN__c session = [Select Name_AGN__c,Content_Type_AGN__c,Training_URL_AGN__c,Duration_AGN__c,Feedback_Slide_Number__c from AMI_Sessions_AGN__c where id =: APSId Limit 1];
        String sessionName = session.Name_AGN__c;
        String sessionType = session.Content_Type_AGN__c;
        Id contactID = [Select contactId from user where id =: Userinfo.getUserid()].contactId;  
        APS = [Select Id,AMI_Learning_Path_AGN__c,Current_Value_AGN__c from AMI_Path_Session_AGN__c where Name_AGN__c =: sessionName 
               and AMI_Learning_Path_AGN__r.Module__c =: lRDId
               and AMI_Learning_Path_AGN__r.HCP_AGN__c =: accountRecord.Id];
        AMI_Learning_Path_AGN__c AP = new AMI_Learning_Path_AGN__c();
        AP.Id = APS.AMI_Learning_Path_AGN__c;
        AP.Previous_Videos_Attented_AGN__c = Boolean.valueOf(ApexPages.currentPage().getParameters().get('confirmation'));
        
        
        
        //APS.id = APSId;
        if(sessionType == 'Video')
        {
            if(contentInfo != '' && contentInfo != null)
            {
                Map<String, Object> statusMap = new Map<String, Object>();
                try
                {
                    statusMap = (Map<String, Object>)JSON.deserializeUntyped(contentInfo);
                }
                catch(Exception e)
                {                    
                    system.debug(e);
                }
                if(statusMap.get('event')=='status' || statusMap.get('event')=='pause')
                {
                    if(!(APS.Current_Value_AGN__c>Decimal.valueOf(String.valueOf(((Map<String, Object>)statusMap.get('status')).get('currentTime')))))
                    {
                        APS.Current_Value_Completed_AGN__c = Decimal.valueOf(String.valueOf(((Map<String, Object>)statusMap.get('status')).get('currentTime')));
                        APS.Current_Value_AGN__c = Decimal.valueOf(String.valueOf(((Map<String, Object>)statusMap.get('status')).get('currentTime')));
                        APS.Total_Value_AGN__c=session.Duration_AGN__c * 60;
                        APS.Progress_Key_AGN__c = String.valueOf(((Map<String, Object>)statusMap.get('status')).get('currentTime'));                        
                    } 
                    APS.Current_Value_Completed_AGN__c = Decimal.valueOf(String.valueOf(((Map<String, Object>)statusMap.get('status')).get('currentTime')));  
                    APS.Progress_Key_AGN__c = String.valueOf(((Map<String, Object>)statusMap.get('status')).get('currentTime'));          
                }
                if(statusMap.get('event')=='playerComplete'|| statusMap.get('event')=='chapterComplete')
                {
                    APS.Current_Value_Completed_AGN__c = session.Duration_AGN__c * 60;
                    APS.Current_Value_AGN__c = session.Duration_AGN__c * 60;
                    APS.Total_Value_AGN__c=session.Duration_AGN__c * 60;
                    //APS.Progress_Key_AGN__c = String.valueOf(session.Duration_AGN__c * 60);
                    APS.Progress_Key_AGN__c =  String.valueOf(((Map<String, Object>)statusMap.get('status')).get('currentTime')); 
                }
                
            }
            
        }
        else
        {
            if(contentInfo != '' && contentInfo != null)
            {
                List<String> contentInfoList = contentInfo.split(';');
                System.debug(contentInfoList);
                Map<String,String> contentInfoMap = new Map<String,String>();
                integer i=0;
                for(i=0;i<contentInfoList.size();i++)
                {
                    List<String> infoSet = contentInfoList.get(i).split('=');
                    if(infoSet.size()>1)
                        contentInfoMap.put(infoSet.get(0),infoSet.get(1));
                }
                if(!contentInfoMap.isEmpty() && !(APS.Current_Value_AGN__c>Integer.valueOf(contentInfoMap.get('CurrentPage'))))
                {
                    APS.Current_Value_Completed_AGN__c = Integer.valueOf(contentInfoMap.get('CurrentPage'));
                    APS.Content_Type_AGN__c = contentInfoMap.get('ContentType');
                    APS.Current_Value_AGN__c = Integer.valueOf(contentInfoMap.get('CurrentPage'));
                    if(session.Feedback_Slide_Number__c != NULL && session.Feedback_Slide_Number__c != 0)
                        APS.Total_Value_AGN__c=session.Feedback_Slide_Number__c;
                    else
                    	APS.Total_Value_AGN__c = Integer.valueOf(contentInfoMap.get('TotalPages')); 
                    APS.Rating_AGN__c = (contentInfoMap.containsKey('Feedback'))?((contentInfoMap.get('Feedback') != 'null') ? Integer.valueOf(contentInfoMap.get('Feedback')) : 0):0;
                    if(APS.Current_Value_AGN__c != APS.Total_Value_AGN__c){  
                        APS.Progress_Key_AGN__c = contentInfo;   
                    }  
                    
                    else{  
                        system.debug('its reaching here'+contentInfo);  
                        
                        APS.Progress_Key_AGN__c = '';  
                        lastsessionstatusid =null;  
                    }  
                    
                }  
                
                
                if(!contentInfoMap.isEmpty()){  
                    
                    
                    If(Integer.valueOf(contentInfoMap.get('CurrentPage'))!=Integer.valueOf(contentInfoMap.get('TotalPages'))){  
                        APS.Progress_Key_AGN__c = contentInfo;   
                        APS.Current_Value_Completed_AGN__c = Integer.valueOf(contentInfoMap.get('CurrentPage'));  
                        lastsessionstatusid =null;                          
                    }  
                    else{  
                        APS.Progress_Key_AGN__c = '';   
                    }
                    
                }
            }
        }
        try
        {
            update AP;
            update APS;
            // checkCertification();
            grantedrecordUpdate(AP);
            modulecompletionCalculation(AP);
            
        }
        catch(Exception e)
        {
            AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_Module_Detail_Controller','AddCurrToLearningPath3');  
        }
        
        getModuleDetail();
        return null;
    }
    public class wrapSession 
    {
        public AMI_Sessions_AGN__c  sess {get; set;}
        public Decimal sessionDuration {get; set;}
        public String status {get; set;}
        public String key {get; set;}
        public Decimal percentage {get; set;}
        public Decimal percentageForCompleted {get; set;}
        public boolean flagforSecSession{get; set;}
        
    }
    public PageReference moveModDet()
    {
        Pagereference pr=new PageReference('/Apex/AGN_AMI_Module_Details_Page');
        pr.setRedirect(true);
        pr.getParameters().put('lRDId',lRDId);        
        return pr;
    }
    public void facultyDetails()
    {
        Integer index;
        System.debug('Faculty Details ID ----->'+facultyDetailsID);
        System.debug('lstLFA===='+lstLFA);
        for(AMI_Learning_Faculty_AGN__c alf:lstLFA)
        {
            if(alf.id == facultyDetailsID)
            {
                Index = lstLFA.indexOf(alf);             
                System.debug('Index===='+Index);
                break;
            }
        }
        //lstFaculty = [Select Name_AGN__c from AMI_Faculty_AGN__c where ID = :facultyDetailsID Limit 1];      
        lstFaculty = lstLFA[index];   
        System.debug('lstFaculty==========='+lstFaculty);
    }
    
    // Created for PMO#3277 - to check whether a certification result is created as result of session completion
    public void checkCertification(){
        system.debug('checkCertification');
        DateTime filterTime = DateTime.now();
        filterTime = filterTime.addMinutes(-1);
        List<AMI_CPD_Granted_AGN__c> certificates = [SELECT id, HCP_AGN_AMI__c, Curricula_Completed_AGN_AMI__c, 
                                                     Achieved_Certification_AGN_AMI__r.Name, HCP_AGN_AMI__r.Name, 
                                                     Achieved_Certification_AGN_AMI__r.Disclaimer_AGN_AMI__c, 
                                                     Achieved_Certification_AGN_AMI__r.Total_Curricula_AGN_AMI__c,
                                                     Achieved_Certification_AGN_AMI__r.Certificate_Logo_AGN_AMI__c 
                                                     FROM AMI_CPD_Granted_AGN__c
                                                     WHERE Achieved_Certification_AGN_AMI__r.Active_AGN_AMI__c = true 
                                                     AND HCP_AGN_AMI__c = :accountRecord.Id
                                                     AND Achieved_Certification_AGN_AMI__c IN (SELECT Certification_AGN_AMI__c 
                                                                                               FROM AMI_CPD_Module_AGN__c 
                                                                                               WHERE Learning_AGN_AMI__c = :lRDId) 
                                                     AND AGN_AMI_Congratulation_Timestamp__c >= :filterTime
                                                     ORDER BY createdDate DESC];
        system.debug('certificates'+certificates);
        if(!certificates.isEmpty()){
            certificate = certificates[0];
            List<String> curriculaIds = (certificate.Curricula_Completed_AGN_AMI__c==null) ? null : certificate.Curricula_Completed_AGN_AMI__c.split(';');
            
            completedCurriculum = (certificate.Curricula_Completed_AGN_AMI__c==null) ? 0 : curriculaIds.size();
            totalCurriculum = (Integer)certificate.Achieved_Certification_AGN_AMI__r.Total_Curricula_AGN_AMI__c;
            
            //fetch the curricula manes from completed curricula ids
            CurriculaNames = '';
            
            if(curriculaIds != null) {
                for(AMI_Learning_AGN__c lrng : [SELECT Curriculum_AGN__c FROM AMI_Learning_AGN__c WHERE Id IN : curriculaIds]) {
                    CurriculaNames += lrng.Curriculum_AGN__c + ', ';
                }
                
                CurriculaNames = '(' + CurriculaNames.subString(0, CurriculaNames.length()-2) + ')';
            }
        }
    }
    //AMI-CR-3666-CPD reporting -Start 
    public void modulecompletionCalculation(AMI_Learning_Path_AGN__c AP){
        system.debug('AP>>>>>>'+AP);
        
        AMI_Learning_Path_AGN__c objLPRecord =[select Id,Module__c,HCP_AGN__c,Module__r.Curriculum_AGN__c from AMI_Learning_Path_AGN__c where id =:AP.ID];
        
        id currId =objLPRecord.Module__r.Curriculum_AGN__c;
        system.debug('calling modulecompletionCalculation');
        
        integer completedModuleCount = 0;
        List<AMI_Lrn_Rel_Dtl_AGN__c> listALRD = [Select id,Curriculum_AGN__c,Module_AGN__c from AMI_Lrn_Rel_Dtl_AGN__c
                                                 where Curriculum_AGN__c =:currId and Active_AGN__c = true];
        system.debug('calling listALRD>>>>>'+listALRD);
        integer totalModuleCount;
        
        totalModuleCount = listALRD.size();
        
        set<id> arldIDs = new  set<id>();
        for(AMI_Lrn_Rel_Dtl_AGN__c temp :listALRD){
            arldIDs.add(temp.id); 
            
        }
        system.debug('calling arldIDs>>>>>'+arldIDs);
        
        List<AMI_Learning_Path_AGN__c> listLp =[select ID
                                                from AMI_Learning_Path_AGN__c where Module__c IN : arldIDs and HCP_AGN__c =: objLPRecord.HCP_AGN__c];
        
        system.debug('calling listLp>>>>>'+listLp);
        if(listLp.size()>0){
            for(AMI_Learning_Path_AGN__c temp : listLp){
                boolean flag = true;
                List<AMI_Path_Session_AGN__c>  lstSessionPath =[select id,Current_Value_AGN__c,Total_Value_AGN__c from AMI_Path_Session_AGN__c 
                                                                where AMI_Learning_Path_AGN__c =: temp.id and Active_AGN__c=true ];
                for(AMI_Path_Session_AGN__c temp1: lstSessionPath){
                    if(!(temp1.Current_Value_AGN__c==temp1.Total_Value_AGN__c) || (temp1.Current_Value_AGN__c==null && temp1.Total_Value_AGN__c==null )){
                        flag=false;
                        break;
                    } 
                    
                }
                if(flag==true){
                    completedModuleCount =completedModuleCount+1;
                }
            }
        }
        system.debug('calling completedModuleCount>>>>>'+completedModuleCount);
        
        list<CPD_Curricula_AGN_AMI__c> objCPDCurricula = [select id,AGN_AMI_CPD_Curriculum_Completion_Date__c from CPD_Curricula_AGN_AMI__c 
                                                          where Curriculam_Id__c =:objLPRecord.Module__r.Curriculum_AGN__c 
                                                          and AGN_AMI_HCP_Account__c =:objLPRecord.HCP_AGN__c ];
        
        system.debug('calling objCPDCurricula>>>>>'+objCPDCurricula);
        
        try{
            if(objCPDCurricula.size()>0){
                objCPDCurricula[0].AGN_AMI_Completed_Module__c =completedModuleCount;
                if(completedModuleCount ==totalModuleCount && objCPDCurricula[0].AGN_AMI_CPD_Curriculum_Completion_Date__c==null )
                {
                    objCPDCurricula[0].AGN_AMI_CPD_Curriculum_Completion_Date__c=datetime.now();
                }
                //objCPDCurricula[0].AGN_AMI_CPD_Curriculum_Completion_Date__c=datetime.now();
                objCPDCurricula[0].AGN_AMI_Total_Module_Count__c =totalModuleCount;
                update objCPDCurricula;    
            }
        }
        catch(Exception e)
        {
            AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_Module_Detail_Controller','modulecompletionCalculation');  
        }
        
        //AMI-CR-3666-CPD reporting -End
        
    }
    public void grantedrecordUpdate(AMI_Learning_Path_AGN__c AP){
        
        List<Id> lrdIds = new List<Id>();
        List<Id> hcpIds = new List<Id>();
        
        
        List<AMI_Learning_Path_AGN__c> learningPaths = [Select Id, HCP_AGN__c, Module__c, Module__r.Curriculum_AGN__c 
                                                        from AMI_Learning_Path_AGN__c 
                                                        where id =: AP.ID and Module_Status_AGN__c = 'Completed'];
        system.debug('learningPaths'+learningPaths);
        if(!learningPaths.isEmpty()){
        AMI_Learning_Path_AGN__c lp = learningPaths[0];
        system.debug('lp'+lp);
        
        List<AMI_CPD_Granted_AGN__c> certList = [Select Id, Curricula_Completed_AGN_AMI__c, Achieved_Certification_AGN_AMI__r.Total_Curricula_AGN_AMI__c, 
                                                 AMI_Certification_Status_AGN__c, DateOfCompletion_AGN_AMI__c 
                                                 from AMI_CPD_Granted_AGN__c 
                                                 where HCP_AGN_AMI__c = :lp.HCP_AGN__c 
                                                 and Achieved_Certification_AGN_AMI__c in
                                                 (Select Certification_AGN_AMI__c 
                                                  from AMI_CPD_Module_AGN__c 
                                                  where Learning_AGN_AMI__c = : lp.Module__c)];
        system.debug('certList'+certList);
        List<AMI_CPD_Granted_AGN__c> updateCertList = new List<AMI_CPD_Granted_AGN__c>();
        if(! certList.isEmpty())
        {
            List<AMI_Lrn_Rel_Dtl_AGN__c> learningDetailList = [Select id from AMI_Lrn_Rel_Dtl_AGN__c 
                                                               where Id in (SELECT Learning_AGN_AMI__c 
                                                                            FROM AMI_CPD_Module_AGN__c) 
                                                               AND Curriculum_AGN__c =: lp.Module__r.Curriculum_AGN__c and Active_AGN__c = true];
            List<AMI_Learning_Path_AGN__c> pathList = [Select id from AMI_Learning_Path_AGN__c 
                                                       where Module__c in (SELECT Learning_AGN_AMI__c
                                                                           FROM AMI_CPD_Module_AGN__c) 
                                                       AND Module__r.Curriculum_AGN__c =: lp.Module__r.Curriculum_AGN__c
                                                       and HCP_AGN__c = :lp.HCP_AGN__c and Module_Status_AGN__c = 'Completed'];
            system.debug('learningDetailList'+learningDetailList.size());
            system.debug('pathList'+pathList.size());
            for(AMI_CPD_Granted_AGN__c cert : certList){
                if(cert.AMI_Certification_Status_AGN__c == 'Completed') {
                    continue;
                }
                cert.AMI_Certification_Status_AGN__c = 'In Progress';
                If(learningDetailList.size() == pathList.size()){ 
                    if(cert.Curricula_Completed_AGN_AMI__c==null) {
                        cert.Curricula_Completed_AGN_AMI__c = (String)lp.Module__r.Curriculum_AGN__c;
                        system.debug('cert.Curricula_Completed_AGN_AMI__c'+cert.Curricula_Completed_AGN_AMI__c);
                    }
                    else if(!cert.Curricula_Completed_AGN_AMI__c.contains((String)lp.Module__r.Curriculum_AGN__c)) {
                        cert.Curricula_Completed_AGN_AMI__c = (String)cert.Curricula_Completed_AGN_AMI__c 
                            + ';' + (String)lp.Module__r.Curriculum_AGN__c;
                    }
                    
                    system.debug(cert.Curricula_Completed_AGN_AMI__c.split(';') + '_' + cert.Curricula_Completed_AGN_AMI__c.split(';').size() + '_' + (Integer)cert.Achieved_Certification_AGN_AMI__r.Total_Curricula_AGN_AMI__c);
                    if(cert.Curricula_Completed_AGN_AMI__c!=null 
                       && (cert.Curricula_Completed_AGN_AMI__c.split(';').size() 
                           == (Integer)cert.Achieved_Certification_AGN_AMI__r.Total_Curricula_AGN_AMI__c)) {
                               cert.AMI_Certification_Status_AGN__c = 'Completed';
                               cert.DateOfCompletion_AGN_AMI__c = DateTime.now();
                           }
                }
                updateCertList.add(cert);
            }
        }
        
        if(! updateCertList.isEmpty())
            try{
                update updateCertList;
            }catch(Exception e)
            {
                AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_Module_Detail_Controller','grantedrecordUpdate');  
            }
        }
        
    }
    /* public PageReference redirect(){
//  achievementId = ApexPages.currentPage().getParameters().get('lRDId');
//System.debug('achievementid: ' +achievementId);
PageReference pageRef = new PageReference(System.Label.AGN_AMI_CG_Detail_Page);
pageRef.setRedirect(true);
pageRef.getParameters().put('lRDId',lRDId);
//  AGN_AMI_Community_page_Controller.updateViewCounts(accRecord.Id, projectId);
return pageRef;}*/    
    
    
    
    
}