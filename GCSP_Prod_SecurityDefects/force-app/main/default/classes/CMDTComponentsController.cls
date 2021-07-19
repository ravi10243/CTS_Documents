/*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Controller class for Componets Custom Metadata Type 
* @Revisions      :    
*******************************************************************************/
public class CMDTComponentsController 
{
    @AuraEnabled 
    public static MDComponentInDesignerWrapper GetComponentsInDesignerWrapper(string mdFormId)
    {
        MDComponentInDesignerWrapper wrapper = new MDComponentInDesignerWrapper();
        
        List<MDForm__c> listForm = [SELECT Id, ObjectAPIName__c
                                    FROM MDForm__c
                                    WHERE Id = :mdFormId];
        
        if(!listForm.isEmpty())
        {
            String stringObjectAPIName = listForm[0].ObjectAPIName__c;
            
            if(String.isNotBlank(stringObjectAPIName))
            {
                wrapper.ListObjectField = CMDTComponentsController.GetFieldsForAnObject(stringObjectAPIName);
            }
        }
        
        wrapper.ListComponentType = CMDTComponentsController.GetActiveComponents();
        wrapper.ListFormSteps = CMDTComponentsController.GetMDFormSteps(mdFormId);
        return wrapper;
    }
    
    @AuraEnabled
    public static List<CMDTComponentWrapper> GetActiveComponents()
    {
        List<CMDTComponentWrapper> listComponents;
        
        List<MDComponentType__mdt> listCMDTRecords = [SELECT Id, MasterLabel, DeveloperName, IconName__c 
                                                      FROM MDComponentType__mdt
                                                      WHERE IsActive__c = :true];
        if(!listCMDTRecords.isEmpty())
        {
            listComponents = new List<CMDTComponentWrapper>();
            
            for(MDComponentType__mdt mdtRecord : listCMDTRecords)
            {
                CMDTComponentWrapper componentWrapper = new CMDTComponentWrapper();
                
                componentWrapper.RecordId = mdtRecord.Id;
                componentWrapper.DeveloperName = mdtRecord.DeveloperName;
                componentWrapper.Label = mdtRecord.MasterLabel;
                componentWrapper.IconName = mdtRecord.IconName__c;
                //componentWrapper.ComponentType = mdtRecord.ComponentType__c;
                
                listComponents.add(componentWrapper);
            }
        }
        
        return listComponents;
    }
    
    @AuraEnabled
    public static List<MDObjectFieldInfoWrapper> GetFieldsForAnObject(String objectAPIName)
    {
        List<MDObjectFieldInfoWrapper> listField = new List<MDObjectFieldInfoWrapper>();
        
        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
        
        for(String fieldName :fieldMap.keySet())
        {
            MDObjectFieldInfoWrapper fieldWrapper = new MDObjectFieldInfoWrapper();
            
            fieldWrapper.FieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            fieldWrapper.FieldAPIName = fieldMap.get(fieldName).getDescribe().getName();
            
            listField.add(fieldWrapper);
        }
        
        return listField;
    }
    
    @AuraEnabled
    public static List<MDFormStepWrapper> GetMDFormSteps(string mdFormId)
    {
        List<MDFormStepWrapper> listWrapper;
        
        List<MDFormStep__c> listMDFormStep = [SELECT Id, DeveloperName__c FROM MDFormStep__c
                                              WHERE MDForm__c = :mdFormId 
                                              ORDER BY StepOrder__c];
        
        if(!listMDFormStep.isEmpty())
        {
            listWrapper = new List<MDFormStepWrapper>();
            
            for(MDFormStep__c stepRecord : listMDFormStep)
            {
                MDFormStepWrapper wrapperRecord = new MDFormStepWrapper();
                
                wrapperRecord.StepId = stepRecord.Id;
                wrapperRecord.DeveloperName = stepRecord.DeveloperName__c;
                
                listWrapper.add(wrapperRecord);
            }
        }
        
        return listWrapper;
    }
}