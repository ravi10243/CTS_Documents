/*
Name            : AGN_CaseCollaborationUpdate
Created Date    : 14-OCT-2019
Developer Name  : CCPA/GDPR Case management project team
Purpose         : This invocable method is being called from a process builder (AGN_Case_Collaborator_add)  which is updating parent of a case 
                if case number provided in child case's DS case refrence field is having same email like the child case. 
                This is applicable for CCPA case only and case channel has to be Email. 
*/

public class AGN_CaseCollaborationUpdate {   
    @InvocableMethod
    Public static void UpdateCollaborator (list <id> caseid)
    {
                
        //system.debug ('recordtype: ' + vRecordtypeId);
        
        Case newcaseInfo = [select id, DS_Case_reference_agn__c,Data_Subject_Email_GDPR_AGN__c from case 
                        where id = :caseid[0]];
        
        list <case> newcaselist= new list<case>();
        
        if (newcaseInfo.DS_Case_reference_agn__c != null)
        {          
            newcaselist= [select id, casenumber from case where casenumber= :newcaseInfo.DS_Case_reference_agn__c and
                       Data_Subject_Email_GDPR_AGN__c =:newcaseInfo.Data_Subject_Email_GDPR_AGN__c ];

        }
        
        //system.debug ('recordtype: ' + newcase1[0]);
        
        try
        {
            if(newcaselist.size() > 0)
            {
                if (newcaselist[0].id !=null)
                {
                    newcaseInfo.ParentId= newcaseList[0].id;
                    update newcaseInfo;
                }
            }
        }
        catch(Exception ex)
        {
            system.debug ('Exception : ' + ex);
        }
        
    }
}