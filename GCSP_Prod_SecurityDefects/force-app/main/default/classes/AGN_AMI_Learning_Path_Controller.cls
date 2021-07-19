public without sharing class AGN_AMI_Learning_Path_Controller
{
    public List<AMI_Learning_Path_AGN__c> userLearningPath {get; set;}
    public List<AMI_Learning_Path_AGN__c> userLearningPathCompleted {get; set;}
    public List<AMI_Learning_Path_AGN__c> userLearningPathProgress {get; set;}
    public List<AMI_Learning_Path_AGN__c> userLearningPathNotStarted {get; set;}
    
    // PMO#3277 - added to store certificates to be displayed
    public List<AMI_CPD_Granted_AGN__c> certificates {get; set;}
    public AMI_CPD_Granted_AGN__c selectedCertificate {get; set;}
    public String certId {get; set;}
    
    
    public Integer lpCount{get;set;}
    
    Public Integer completedCount {get; set;}
    Public Integer notStartedCount {get; set;}
    Public Integer inProgressCount {get; set;}
    Account accountRecord;
    String userCountryName;
    public string moduleId {get; set;}
    public String userLanguage {get;set;}
    
    public Id removeId {get; set;}
    public Id removeIdNotStarted {get; set;}
    
    User user;
    
    public AGN_AMI_Learning_Path_Controller()
    {
        system.debug('Inside AGN_AMI_Learning_Path_Controller');
        userLearningPath = new List<AMI_Learning_Path_AGN__c> ();  
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();   
        userLanguage = userDetails.userLanguage;
        /*AMI MENA changes- Start */
        //userCountryName =  userDetails.userCountryName;
        userCountryName =  userDetails.maskedUserCountryName;
        /*AMI MENA changes- End */
        accountRecord =  userDetails.accountRecord;
        user =  userDetails.user;
        getLearningPath(); 
        getCertifications();
    }
    
    public void getLearningPath()
    {
        system.debug('Inside getLearningPath');
        system.debug('userCountryName-->'+userCountryName);
        system.debug('accountRecord-->'+accountRecord);
        userLearningPath = [Select Id, 
                            Module__c, HCP_AGN__c,
                            Module__r.Curriculum_AGN__c,
                            Module__r.Curriculum_Fma_AGN__c,
                            Module__r.Module_AGN__c,
                            Module__r.Module_Fma_AGN__c,
                            Module__r.Program_AGN__c,
                            Module__r.Program_Fma_AGN__c,
                            Module__r.Module_AGN__r.Duration_FMA_AGN__c,
                            Module__r.Module_AGN__r.Module_Duration_AGN__c,
                            Module__r.Module_AGN__r.AMI_Image_URL_AGN__c,
                            CreatedDate,
                            Module_Status_AGN__c,
                            Last_Attended_AGN__c,
                            Module__r.Module_AGN__r.anatomy_area_AGN__c,
                            Module__r.Module_AGN__r.Module_Content_Type_AGN__c
                            from AMI_Learning_Path_AGN__c 
                            where HCP_AGN__c =: accountRecord.Id
                            and Country_AGN__r.Name =:userCountryName
                            and Module__r.Active_AGN__c = true
                            order by Last_Attended_AGN__c];
        userLearningPathCompleted = new List<AMI_Learning_Path_AGN__c>();
        userLearningPathNotStarted = new List<AMI_Learning_Path_AGN__c>();
        userLearningPathProgress = new List<AMI_Learning_Path_AGN__c>();
        
        if (userLearningPath != null && !userLearningPath.isEmpty() ){
            for(AMI_Learning_Path_AGN__c ALP : userLearningPath)
            {
                if(ALP.Module_Status_AGN__c.ToUpperCase() == 'Completed'.ToUpperCase())
                {
                    userLearningPathCompleted.add(ALP);
                }
                else if(ALP.Module_Status_AGN__c.ToUpperCase() == 'Not Started'.ToUpperCase())
                {
                    userLearningPathNotStarted .add(ALP);
                }
                else
                {
                    userLearningPathProgress.add(ALP);
                }
                
            }
        }
        
                
        completedCount = userLearningPathCompleted.size();
        notStartedCount =userLearningPathNotStarted .size();
        inProgressCount=userLearningPathProgress.size();
        
        lpCount=completedCount +notStartedCount +inProgressCount;
        
        system.debug('CompletedCount Line 97'+completedCount);
        system.debug('InProgressCount Line 98'+inProgressCount);
        system.debug('NotStartedCount Line 99'+notStartedCount);
   }    
    
   
    public void remove()
    {       
        list<AMI_Learning_Path_AGN__c> ALP = [Select id from AMI_Learning_Path_AGN__c where id = :removeId];
        if ( ALP.size()>0 )
        {
            try
            {
                delete ALP;
            }
            
            catch(Exception e)
            {
                AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_Learning_Path_Controller','remove');
            }
            
            Integer del; 
            for(AMI_Learning_Path_AGN__c ALPs : userLearningPathProgress) 
            {
                if(ALPs.ID==removeId)
                    del=userLearningPathProgress.indexOf(ALPs);
            }
            userLearningPathProgress.remove(del);
            inProgressCount--;
            lpCount--; 
        }
    }
    
    
    public void removeNotStarted()
    { 
        system.debug('Inside removeNotStarted:'+removeIdNotStarted);
        list<AMI_Learning_Path_AGN__c> ALP = [Select id from AMI_Learning_Path_AGN__c where id = :removeIdNotStarted];
        
                       
        if ( ALP.size()>0 )
        {
            try
            {
                delete ALP;
            }
            catch(Exception e)
            {
                AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_Learning_Path_Controller','removeNotStarted');
            }
            
            Integer del; 
            for(AMI_Learning_Path_AGN__c ALPs : userLearningPathNotStarted) 
            {
                if(ALPs.ID==removeIdNotStarted)
                    del=userLearningPathNotStarted.indexOf(ALPs);
            }
            userLearningPathNotStarted.remove(del);
            notStartedCount--;
            lpCount--;
        }
    }
    
    // PMO#3277 - added to fetch certifications obtained by the HCP
    public void getCertifications(){
        certificates = [SELECT id, HCP_AGN_AMI__c, Curricula_Completed_AGN_AMI__c, 
                        Achieved_Certification_AGN_AMI__r.Certificate_Logo_AGN_AMI__c, 
                        Achieved_Certification_AGN_AMI__r.Name, AMI_Certification_Status_AGN__c,
                        Achieved_Certification_AGN_AMI__r.Description_AGN_AMI__c, HCP_AGN_AMI__r.Name,
                        Achieved_Certification_AGN_AMI__r.Disclaimer_AGN_AMI__c,
                        Achieved_Certification_AGN_AMI__r.Total_Curricula_AGN_AMI__c
                        FROM AMI_CPD_Granted_AGN__c 
                        WHERE Achieved_Certification_AGN_AMI__r.Active_AGN_AMI__c = true 
                        AND HCP_AGN_AMI__c = :accountRecord.Id
                        ORDER BY createdDate DESC];
    }
    
    // PMO#3277 - added to fetch certifications obtained by the HCP
    public void setCertificatePopup(){
        Id certId = ApexPages.currentPage().getParameters().get('certId');
        selectedCertificate = [SELECT id, HCP_AGN_AMI__c, Achieved_Certification_AGN_AMI__r.Name, 
                               Achieved_Certification_AGN_AMI__r.Description_AGN_AMI__c, HCP_AGN_AMI__r.Name,
                               Achieved_Certification_AGN_AMI__r.Disclaimer_AGN_AMI__c
                               FROM AMI_CPD_Granted_AGN__c 
                               WHERE Id = :certId 
                               LIMIT 1];
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