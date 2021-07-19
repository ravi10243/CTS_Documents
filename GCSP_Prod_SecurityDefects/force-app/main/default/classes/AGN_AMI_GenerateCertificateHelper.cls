/**************************************************************************************************************************
@ Class:          AGN_AMI_GenerateCertificateHelper
@ Version:        1.0
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        Controller class for maintaining changes to vault code changes in metadata.
@ PMO:            CR-3277 : This class is created to be invoked from process builder to update certificate record if 
                  Module is completed
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 28.07.2020 / Ayush Basak / Created the class.
***************************************************************************************************************************/
public class AGN_AMI_GenerateCertificateHelper {
    @invocableMethod
    public static void create_achievement(list<id> ch){
        List<Id> lrdIds = new List<Id>();
        List<Id> hcpIds = new List<Id>();
        
        
        List<AMI_Learning_Path_AGN__c> learningPaths = [Select Id, HCP_AGN__c, Module__c, Module__r.Curriculum_AGN__c 
                                                        from AMI_Learning_Path_AGN__c 
                                                        where id in : ch and Module_Status_AGN__c = 'Completed'];
        AMI_Learning_Path_AGN__c lp = learningPaths[0];
        List<AMI_CPD_Granted_AGN__c> certList = [Select Id, Curricula_Completed_AGN_AMI__c, Achieved_Certification_AGN_AMI__r.Total_Curricula_AGN_AMI__c, 
                                                        AMI_Certification_Status_AGN__c, DateOfCompletion_AGN_AMI__c 
                                                 from AMI_CPD_Granted_AGN__c 
                                                 where HCP_AGN_AMI__c = :lp.HCP_AGN__c 
                                                 and Achieved_Certification_AGN_AMI__c in
                                                 (Select Certification_AGN_AMI__c 
                                                  from AMI_CPD_Module_AGN__c 
                                                  where Learning_AGN_AMI__c = : lp.Module__c)];
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
            
            for(AMI_CPD_Granted_AGN__c cert : certList){
                if(cert.AMI_Certification_Status_AGN__c == 'Completed') {
                    continue;
                }
                cert.AMI_Certification_Status_AGN__c = 'In Progress';
                If(learningDetailList.size() == pathList.size()){ 
                    if(cert.Curricula_Completed_AGN_AMI__c==null) {
                        cert.Curricula_Completed_AGN_AMI__c = (String)lp.Module__r.Curriculum_AGN__c;
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
            update updateCertList;
    }
}