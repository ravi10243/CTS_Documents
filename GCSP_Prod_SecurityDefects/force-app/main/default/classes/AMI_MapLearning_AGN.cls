global with sharing class AMI_MapLearning_AGN {
    webservice static integer Learning(String localId){
        List<AMI_Lrn_Rel_Dtl_AGN__c> objALRD=new List<AMI_Lrn_Rel_Dtl_AGN__c>();
        //Get all Learning relationships
        List<AMI_Learning_Relationship_AGN__c>  objALR=[select id,
                                                    Name,
                                                    AMI_Parent_Learning_AGN__c,
                                                    Country_AGN__c,
                                                    Country_AGN__r.Name,
                                                    AMI_Child_Learning_AGN__c,
                                                    Curriculum_Fma_AGN__c,
                                                    Child_Program_Fma_AGN__c,
                                                    Child_Module_Fma_AGN__c,
                                                    Country_AGN__r.Country_Name_vod__c,
                                                    Language_AGN__c,
                                                    Sequence_AGN__c,
                                                    Recordtype.Name
                                                    from AMI_Learning_Relationship_AGN__c
                                                    order by Sequence_AGN__c];
        
        List<AMI_Learning_Relationship_AGN__c> objCP=new List<AMI_Learning_Relationship_AGN__c>();
        List<AMI_Learning_Relationship_AGN__c> objPM=new List<AMI_Learning_Relationship_AGN__c>();
        
        for(AMI_Learning_Relationship_AGN__c alr: objALR)
        {
            system.debug('cp'+alr.RecordType.Name);
            //filter based on record type
            //and put in separate lists
            if(alr.RecordType.Name=='Curriculum Program')
                /*objCP.add(new AMI_Learning_Relationship__c(AMI_Parent_Learning_AGN__c=alr.AMI_Parent_Learning_AGN__c,
                                                           Country_AGN__c=alr.Country_AGN__c,
                                                           AMI_Child_Learning_AGN__c=alr.AMI_Child_Learning_AGN__c,
                                                           RecordTypeId=alr.RecordTypeId
                                                         ));*/
                objCP.add(alr);
                if(alr.RecordType.Name=='Program Module') 
                /*objPM.add(new AMI_Learning_Relationship__c(AMI_Parent_Learning_AGN__c=alr.AMI_Parent_Learning_AGN__c,
                                                           Country_AGN__c=alr.Country_AGN__c,
                                                           AMI_Child_Learning_AGN__c=alr.AMI_Child_Learning_AGN__c,
                                                           RecordTypeId=alr.RecordTypeId
                                                          ));*/
                   objPM.add(alr);
                }
       
        //inside CurriculumProgram list
        decimal CurriculumSequence;
        for(AMI_Learning_Relationship_AGN__c cp: objCP)
        {           
            AMI_Lrn_Rel_Dtl_AGN__c objCPMS=new AMI_Lrn_Rel_Dtl_AGN__c();
            //inside ProgramModule list
            for(AMI_Learning_Relationship_AGN__c pm:objPM)
            {
                //check whether the child program in cp is 
                //equal to parent program in pm
                if(cp.AMI_Child_Learning_AGN__c==pm.AMI_Parent_Learning_AGN__c)
                {   
                    if(pm.Sequence_AGN__c != null && cp.Sequence_AGN__c != null)
                        CurriculumSequence = cp.Sequence_AGN__c * 10 +  pm.Sequence_AGN__c;
                    //populate final AMI_Lrn_Rel_Dtl_AGN__c record
                    objCPMS.Curriculum_AGN__c=cp.AMI_Parent_Learning_AGN__c;
                    objCPMS.Program_AGN__c=cp.AMI_Child_Learning_AGN__c; 
                    objCPMS.Module_AGN__c=pm.AMI_Child_Learning_AGN__c;
                    objCPMS.Country_AGN__c=cp.Country_AGN__c;
                    objCPMS.Language_AGN__c=cp.Language_AGN__c;
                    objCPMS.Country_Code_AGN__c=cp.Country_AGN__r.Country_Name_vod__c;
                    system.debug('---'+cp.Country_AGN__c);
                    system.debug('---'+cp.Country_AGN__r.Name);
                    //External ID required for upsert
                    
                    objCPMS.External_ID_AGN__c= cp.AMI_Parent_Learning_AGN__c+'_'+
                        cp.AMI_Child_Learning_AGN__c+'_'+
                        pm.AMI_Child_Learning_AGN__c
                        +'_'+ cp.Country_AGN__r.Name
                        +'_'+cp.Language_AGN__c;
                    //check whether the same record is already  
                    //present in the list
                    boolean present=false; 
                    for(AMI_Lrn_Rel_Dtl_AGN__c cpmsOb:objALRD)
                    { 
                        
                        if(cpmsOb.Curriculum_AGN__c==objCPMS.Curriculum_AGN__c &&
                           cpmsOb.Program_AGN__c==objCPMS.Program_AGN__c &&
                           cpmsOb.Module_AGN__c==objCPMS.Module_AGN__c) 
                            present=true;
                        
                    }
                    if(!present && 
                       !(objCPMS.Curriculum_AGN__c==null || objCPMS.Program_AGN__c==null || objCPMS.Module_AGN__c==null))
                    {
                       objCPMS.Curriculum_Sequence_AGN__c = CurriculumSequence;
                       //adding to the final list to be upserted
                       objALRD.add(objCPMS);
                    }
                    objCPMS=new AMI_Lrn_Rel_Dtl_AGN__c();
                }
            } 
        }
        //upsert on the basis of external ID
        try
        {
            upsert objALRD AMI_Lrn_Rel_Dtl_AGN__c.Fields.External_ID_AGN__c;
        }
        Catch(DMLException ex)
        {} 
        system.debug('----'+objALRD);
        return objALRD.size();
        
    }
}