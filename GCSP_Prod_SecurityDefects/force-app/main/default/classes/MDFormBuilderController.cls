/*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019
* @description    :    Act as a Controller for working with MD Form object. Used in wizard and also in Builder
* @Revisions      :    
*******************************************************************************/
public class MDFormBuilderController 
{
    /*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Get the MDForm Properties in the form of a class searialized from the JSON
* @param          :    Id formId 
* @return         :    returns searialized 
*******************************************************************************/
    @AuraEnabled
    public static List<MDFormPropertyWrapper> GetMDFormProperties(Id mdFormId)
    {
        List<MDFormPropertyWrapper> listFormPropertyWrapper;
        
        List<MDForm__c> listForm = [SELECT Id, PropertiesJSON__c
                                    FROM MDForm__c
                                    WHERE Id = :mdFormId];
        
        if(!listForm.isEmpty())
        {
            String propertiesJSON = listForm[0].PropertiesJSON__c;
            
            if(String.isNotBlank(propertiesJSON))
            {
                listFormPropertyWrapper = (List<MDFormPropertyWrapper>) System.JSON.deserialize(propertiesJSON, List<MDFormPropertyWrapper>.class);
            }
        }
        
        return listFormPropertyWrapper;
    }
    
    /*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Save Form Properties from the list of properties
* @param          :    Id formId, list of proerties 
* @return         :      
*******************************************************************************/
    @AuraEnabled
    public static void SaveMDFormProperties(List<MDFormPropertyWrapper> listProperties, Id mdFormId)
    {
        List<MDForm__c> listForm = [SELECT Id, PropertiesJSON__c
                                    FROM MDForm__c
                                    WHERE Id = :mdFormId];
        
        if(!listForm.isEmpty())
        {
            String propertiesJSON = JSON.serialize(listProperties);
            
            MDForm__c mdForm = listForm[0];
            mdForm.PropertiesJSON__c = propertiesJSON;
            UPDATE mdForm;
        }
    }
    
    /*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Return records from MD Localised Form for a form Id 
* @param          :    Id formId
* @return         :      
*******************************************************************************/
    @AuraEnabled
    public static List<MDLocalisedForm__c> GetLocalisedMDFormRecords(Id mdFormId) 
    {
        List<MDLocalisedForm__c> listLocalisedForm;
        
        listLocalisedForm = [SELECT Id, FormTitle__c, FormDescription__c, Language__c, SaveButtonLabel__c,
                             SaveAndNextButtonLabel__c, SaveAndPreviousButtonLabel__c
                             FROM MDLocalisedForm__c
                             WHERE MDForm__c = :mdFormId];
        
        return listLocalisedForm;
    }
    
    /*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Return Branding Information for a Form 
* @param          :    Id formId
* @return         :      
*******************************************************************************/
    @AuraEnabled
    public static List<MDCSSFormAreaWrapper> GetMDFormBranding(Id mdFormId)
    {
        List<MDCSSFormAreaWrapper> listFormAreaWrapper;
        
        List<MDForm__c> listForm = [SELECT Id, BrandingJSON__c
                                    FROM MDForm__c
                                    WHERE Id = :mdFormId];
        
        if(!listForm.isEmpty())
        {
            String brandingJSON = listForm[0].BrandingJSON__c;
            
            if(String.isNotBlank(brandingJSON))
            {
                listFormAreaWrapper = (List<MDCSSFormAreaWrapper>) System.JSON.deserialize(brandingJSON, List<MDCSSFormAreaWrapper>.class);
            }
        }
        
        return listFormAreaWrapper;
    }
    
    @AuraEnabled
    public static MDCSSFormAreaWrapper GetMDComponentBranding(Id mdComponentId)
    {
        MDCSSFormAreaWrapper formAreaWrapper;
        
        List<MDComponent__c> listComponent = [SELECT Id, BrandingJSON__c
                                              FROM MDComponent__c
                                              WHERE Id =:mdComponentId];
        if(!listComponent.isEmpty())
        {
            String brandingJSON = listComponent[0].BrandingJSON__c;
            
            if(String.isNotBlank(brandingJSON))
            {
                formAreaWrapper = (MDCSSFormAreaWrapper) System.JSON.deserialize(brandingJSON, MDCSSFormAreaWrapper.class);
            }
        }
        
        return formAreaWrapper;
    }
    /*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Save Form Properties from the list of properties
* @param          :    Id formId, list of proerties 
* @return         :    
*******************************************************************************/
    @AuraEnabled
    public static void SaveMDFormBranding(List<MDCSSFormAreaWrapper> listFormArea, Id mdFormId)
    {
        List<MDForm__c> listForm = [SELECT Id, BrandingJSON__c
                                    FROM MDForm__c
                                    WHERE Id = :mdFormId];
        if(!listForm.isEmpty())
        {
            String brandingJSON = JSON.serialize(listFormArea);
            
            MDForm__c mdForm = listForm[0];
            mdForm.BrandingJSON__c = brandingJSON;
            
            UPDATE mdForm;
        }
    }
    
    /*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Save Form Properties from the list of properties
* @param          :    Id formId, list of proerties 
* @return         :    
*******************************************************************************/
    @AuraEnabled
    public static void SaveMDComponentBranding(MDCSSFormAreaWrapper formArea, Id mdComponentId)
    {
        List<MDComponent__c> listComponent = [SELECT Id, BrandingJSON__c
                                              FROM MDComponent__c
                                              WHERE Id =:mdComponentId];
        
        if(!listComponent.isEmpty())
        {
            String brandingJSON = JSON.serialize(formArea);
            
            MDComponent__c mdComponent = listComponent[0];
            mdComponent.BrandingJSON__c = brandingJSON;
            //throw new AuraHandledException('Forced brading: ' + brandingJSON);
            UPDATE mdComponent;
        }
    }
    
    /*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Get the list of all objects in the Org
* @param          :     
* @return         :    
*******************************************************************************/
    @AuraEnabled
    public static List<String> GetListOfSObject()
    {
        List<String> listObjectAPIName = new List<String>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
        
        for(Schema.SObjectType f : gd)
        {
            listObjectAPIName.add(f.getDescribe().getName());
        }
        
        return listObjectAPIName;
    }
    
    /*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Get the MDForm Properties in the form of a class searialized from the JSON
* @param          :    Id formId 
* @return         :    returns searialized 
*******************************************************************************/
    @AuraEnabled
    public static MDFormWrapper GetMDFormWrapper(Id mdFormId)
    {
        MDFormWrapper mdFormWrapper;
        
        List<MDForm__c> listMDForm = [SELECT Id, Name, URLKey__c FROM MDForm__c WHERE ID = :mdFormId];
        
        if(!listMDForm.isEmpty())
        {
            mdFormWrapper = new mdFormWrapper();
            
            mdFormWrapper.FormId = listMDForm[0].Id;
            mdFormWrapper.DeveloperName =  listMDForm[0].Name;
            mdFormWrapper.URLKey =  listMDForm[0].URLKey__c;
            
            // Now get the formsteps
            mdFormWrapper.ListSteps = MDFormBuilderController.GetMDFormSteps(mdFormId, true);
        }
        
        return mdFormWrapper;
    }
    
    @AuraEnabled
    public static List<MDFormStepWrapper> GetMDFormSteps(Id mdFormId, boolean fetchComponents)
    {
        List<MDFormStepWrapper> listStepWrapper;
        
        List<MDFormStep__c> listMDFormStep = [SELECT Id, DeveloperName__c, StepOrder__c, IsActive__c  FROM MDFormStep__c
                                              WHERE MDForm__c = :mdFormId 
                                              ORDER BY StepOrder__c];
        
        if(!listMDFormStep.isEmpty())
        {
            // Prepare list to return
            listStepWrapper = new List<MDFormStepWrapper>();
            
            for(MDFormStep__c mdFormStep : listMDFormStep)
            {
                MDFormStepWrapper stepWrapper = new MDFormStepWrapper();
                
                stepWrapper.StepId = mdFormStep.Id;
                stepWrapper.DeveloperName = mdFormStep.DeveloperName__c;
                stepWrapper.SortOrder = mdFormStep.StepOrder__c;
                stepWrapper.IsActive = mdFormStep.IsActive__c;
                
                if(fetchComponents)
                {
                    stepWrapper.ListComponent = MDFormBuilderController.GetMDStepComponents(mdFormStep.Id);
                }
                
                listStepWrapper.add(stepWrapper);
            }
        }
        
        return listStepWrapper;
    }
    
    
    @AuraEnabled
    public static List<MDComponentWrapper> GetMDStepComponents(Id mdFormStepId)
    {
        List<MDComponentWrapper> listComponentWrapper;
        
        List<MDComponent__c> listMDComponent = [SELECT Id, DeveloperName__c, IsActive__c, ElementType__c, SortOrder__c,
                                                ComponentTypeIcon__c, ComponentType__c, ComponentTypeLabel__c	
                                                FROM MDComponent__c
                                                WHERE MDFormStep__c = :mdFormStepId
                                                ORDER BY SortOrder__c];
        if(!listMDComponent.isEmpty())
        {
            listComponentWrapper = new List<MDComponentWrapper>();
            
            for(MDComponent__c mdComponent : listMDComponent)
            {
                MDComponentWrapper componentWrapper = new MDComponentWrapper();
                
                componentWrapper.ComponentId = mdComponent.Id;
                componentWrapper.DeveloperName = mdComponent.DeveloperName__c;
                componentWrapper.ComponentType = mdComponent.ComponentType__c;
                componentWrapper.ComponentTypeIcon = mdComponent.ComponentTypeIcon__c;
                componentWrapper.ComponentTypeLabel = mdComponent.ComponentTypeLabel__c;
                componentWrapper.SortOrder = mdComponent.SortOrder__c;
                componentWrapper.IsActive = mdComponent.IsActive__c;
                
                listComponentWrapper.add(componentWrapper);
            }
        }
        
        return listComponentWrapper;
    }
    /*******************************************************************************
* @author         :    Rajesh Mewada
* @date           :    April 2019 
* @description    :    Return records from MD Localised Form step for a form step Id 
* @param          :    Id Form Step Id
* @return         :      
*******************************************************************************/
    @AuraEnabled
    public static List<MDLocalisedFormStep__c> GetLocalisedMDFormStepRecords(Id mdFormStepId) 
    {
        List<MDLocalisedFormStep__c> listLocalisedFormStep;
        
        listLocalisedFormStep = [SELECT Id, LocalisedShortName__c, LocalisedLongName__c, Language__c,MDFormStep__c
                                 FROM MDLocalisedFormStep__c
                                 WHERE MDFormStep__c = :mdFormStepId];
        
        return listLocalisedFormStep;
    }
    /*******************************************************************************
* @author         :    Rajesh Mewada
* @date           :    April 2019 
* @description    :    Return records Localised component for a form component Id 
* @param          :    Id Component Id
* @return         :      
*******************************************************************************/
    @AuraEnabled
    public static List<MDLocalisedComponent__c> GetLocalisedMDStepComponentRecords(Id mdStepComponentId) 
    {
        List<MDLocalisedComponent__c> listLocalisedStepComponent;
        
        listLocalisedStepComponent = [SELECT Id, ContainerTextHtml__c, Language__c, MDComponent__c, ContainerRichText__c, PortalLabel__c, PortalQuickHelpText__c
                                      FROM MDLocalisedComponent__c
                                      WHERE MDComponent__c = : mdStepComponentId];
        
        return listLocalisedStepComponent;
    }
    
    @AuraEnabled
    public static F3_MDSitePageWrapper GetSitePageWrapper(string mdFormId, string selectedStepId)
    {
        F3_MDSitePageWrapper sitePageWrapper;
        List<MDForm__c> listPageForm = [SELECT Id, 
                                        Status__c,
                                        PropertiesJSON__c,
                                        ObjectAPIName__c,
                                        ObjectRecordTypeAPIName__c,
                                        BrandingJSON__c,
                                        FormDescription__c,
                                        FormTitle__c,
                                        SaveButtonLabel__c,
                                        SaveAndNextButtonLabe__c,
                                        SaveAndPreviousButtonLabe__c
                                        FROM MDForm__c
                                        WHERE Id =:mdFormId];
        
        if(!listPageForm.isEmpty())
        {
            sitePageWrapper = new F3_MDSitePageWrapper();
            
            sitePageWrapper.DefaultPageForm = listPageForm[0];
            sitePageWrapper.PageFormBrandingJSON = ((List<MDCSSFormAreaWrapper>) System.JSON.deserialize(listPageForm[0].BrandingJSON__c, List<MDCSSFormAreaWrapper>.class));
            sitePageWrapper.PageFormPropertiesJSON = ((List<MDFormPropertyWrapper>) System.JSON.deserialize(listPageForm[0].PropertiesJSON__c, List<MDFormPropertyWrapper>.class));
            sitePageWrapper.FormPortalDescription = listPageForm[0].FormDescription__c;
            sitePageWrapper.FormPortalLabel = listPageForm[0].FormTitle__c;
            sitePageWrapper.SaveButtonLabel = listPageForm[0].SaveButtonLabel__c;
            sitePageWrapper.SaveNextButtonLabel = listPageForm[0].SaveAndNextButtonLabe__c;
            sitePageWrapper.SavePreviousButtonLabel = listPageForm[0].SaveAndPreviousButtonLabe__c;
            
            sitePageWrapper.ListPageFormSteps = MDFormBuilderController.GetMDPageFormSteps(mdFormId);
            
            if(selectedStepId==null)
            {
                ID firstFormStepId = MDFormBuilderController.GetFirstStepId(mdFormId);
                sitePageWrapper.CurrentStepId = firstFormStepId;
                sitePageWrapper.PageFormStepWrapper = MDFormBuilderController.GetMDPageFormStep(firstFormStepId);
            }
            else
            {
                sitePageWrapper.CurrentStepId = selectedStepId;
                sitePageWrapper.PageFormStepWrapper = MDFormBuilderController.GetMDPageFormStep(selectedStepId);
            }
            
            if(sitePageWrapper.PageFormStepWrapper!=null)
            {
                sitePageWrapper.PageFormStepWrapper.SaveButtonLabel = sitePageWrapper.SaveButtonLabel;
                sitePageWrapper.PageFormStepWrapper.SaveNextButtonLabel = sitePageWrapper.SaveNextButtonLabel;
                sitePageWrapper.PageFormStepWrapper.SavePreviousButtonLabel = sitePageWrapper.SavePreviousButtonLabel;
            }
        }
        
        return sitePageWrapper;
    }
    
    @AuraEnabled
    public static List<F3_MDFormStepWrapper> GetMDPageFormSteps(Id mdPageFormId)
    {
        List<F3_MDFormStepWrapper> listFormStepWrapper;
        
        List<MDFormStep__c> listFormSteps = [SELECT Id,
                                             Name,
                                             LocalisedShortName__c,
                                             Type__c,
                                             LocalisedLongName__c,
                                             Description__c,
                                             OnLoadViewState__c
                                             FROM MDFormStep__c
                                             WHERE MDForm__c = :mdPageFormId AND IsActive__c = true
                                             ORDER BY StepOrder__c];
        
        if(!listFormSteps.isEmpty())
        {
            listFormStepWrapper = new List<F3_MDFormStepWrapper>();
            for(MDFormStep__c pageFormStep : listFormSteps)
            {
                F3_MDFormStepWrapper stepWrapper = new F3_MDFormStepWrapper(pageFormStep);
                stepWrapper.ShortName = pageFormStep.LocalisedShortName__c;
                stepWrapper.PortalLabel = pageFormStep.LocalisedLongName__c;
                stepWrapper.Description = pageFormStep.Description__c;
                listFormStepWrapper.add(stepWrapper);
            }
        }
        
        return listFormStepWrapper;
    }
    
    @AuraEnabled
    public static Id GetFirstStepId(Id mdPageFormId)
    {
        Id firstStepId;
        
        List<MDFormStep__c> listFormSteps = [SELECT Id,
                                             Name,OnLoadViewState__c
                                             FROM MDFormStep__c
                                             WHERE MDForm__c = :mdPageFormId AND IsActive__c = true
                                             ORDER BY StepOrder__c];
        
        if(!listFormSteps.isEmpty())
        {
            firstStepId = listFormSteps[0].Id;
        }
        
        return firstStepId;
    }
    
    @AuraEnabled
    public static F3_MDFormStepWrapper GetMDPageFormStep(ID mdPageFormStepId)
    {
        F3_MDFormStepWrapper pageFormStepWrapper;
        
        List<MDFormStep__c> listFormSteps = [SELECT Id,
                                             IsActive__c,
                                             MDForm__c,
                                             LocalisedShortName__c,
                                             Name,
                                             LocalisedLongName__c,
                                             Type__c,
                                             Description__c,
                                             StepOrder__c,
                                             ValidatorClass__c,
                                             OnLoadViewState__c
                                             FROM MDFormStep__c
                                             WHERE Id = :mdPageFormStepId];
        if(!listFormSteps.isEmpty())
        {
            pageFormStepWrapper = new F3_MDFormStepWrapper(listFormSteps[0]);
            
            pageFormStepWrapper.ListElements = MDFormBuilderController.GetComponents(mdPageFormStepId);
        }
        
        return pageFormStepWrapper;
    }
    
    @AuraEnabled
    public static List<F3_MDComponentWrapper> GetComponents(Id mdPageFormStepId)
    {
        List<F3_MDComponentWrapper> listComponentWrapper;
        
        List<MDComponent__c> listComponents = [SELECT Id,
                                               Name,
                                               BrandingJSON__c,
                                               DataFieldAPIName__c,
                                               DependencyMetadata__c,
                                               ElementType__c,
                                               IsActive__c,
                                               MDFormStep__c,
                                               ContainerTextHtml__c,
                                               PortalLabel__c,
                                               PortalQuickHelpText__c,
                                               Required__c,
                                               SortOrder__c,
                                               ComponentTypeIcon__c,
                                               ComponentType__c,
                                               ComponentTypeLabel__c
                                               FROM 
                                               MDComponent__c
                                               WHERE IsActive__c = true
                                               AND MDFormStep__c = :mdPageFormStepId
                                               ORDER BY SortOrder__c];
        if(!listComponents.isEmpty())
        {
            listComponentWrapper = new List<F3_MDComponentWrapper>();
            
            Set<Id> setComponentID = new Set<Id>();
            
            for(MDComponent__c component:listComponents)
            {
                setComponentID.add(component.Id);
            }            
            
            for(MDComponent__c component:listComponents)
            {
                F3_MDComponentWrapper componentWrapper = new F3_MDComponentWrapper();
                
                componentWrapper.PageElementId = component.Id;
                componentWrapper.PageElement = component;
                componentWrapper.ContainerHtmlText = component.ContainerTextHtml__c;
                componentWrapper.PortalLabel = component.PortalLabel__c;
                componentWrapper.QuickHelpText = component.PortalQuickHelpText__c;
                if(component.BrandingJSON__c != NULL)
                    componentWrapper.PageFormComponentBrandingJSON = ((MDCSSFormAreaWrapper) System.JSON.deserialize(component.BrandingJSON__c, MDCSSFormAreaWrapper.class));
                
                listComponentWrapper.add(componentWrapper);
            }
        }
        
        return listComponentWrapper;
    }
    
    @AuraEnabled
    public static MDChildObjectSingleConfig GetChildObjectOneConfig(Id mdComponentId)
    {
         MDChildObjectSingleConfig configObject;
        
        List<MDComponent__c> listComponent = [SELECT Id, ConfigJSON__c
                                               FROM MDComponent__c
                                               WHERE Id = :mdComponentId];
        
        if(!listComponent.isEmpty())
        {
            String configJSON = listComponent[0].ConfigJSON__c;
            if(String.isNotBlank(configJSON))
            {
                configObject = (MDChildObjectSingleConfig)System.JSON.deserialize(configJSON, MDChildObjectSingleConfig.class);    
            }
            else
            {
                configObject = new MDChildObjectSingleConfig();
                
                List<MDChilObjectFieldConfig> listField = new List<MDChilObjectFieldConfig>();
                configObject.ListFieldConfig = listField;
            }
        }
        
        return configObject;
    }
    
    @AuraEnabled
    public static String GetComponentConfigJSON(Id mdComponentId)
    {
        String configJSON;
        
        List<MDComponent__c> listComponent = [SELECT Id, ConfigJSON__c
                                               FROM MDComponent__c
                                               WHERE Id = :mdComponentId];
        if(!listComponent.isEmpty())
        {
            configJSON = listComponent[0].ConfigJSON__c;
        }
        
        return configJSON;
    }
    
    @AuraEnabled
    public static List<MDLocalisedComponent__c> GetLocalisedComponentConfigJSON(Id mdComponentId)
    {
        List<MDLocalisedComponent__c> listComponent = [SELECT Id, ConfigJSON__c
                                              FROM MDLocalisedComponent__c
                                              WHERE id = :mdComponentId];
        return listComponent;
    }
    
    @AuraEnabled
    public static void SaveLocalisedComponentConfigJSON(Id mdComponentId, String configJSON)
    {
        List<MDLocalisedComponent__c> savedLocalisedListComponent = [SELECT Id, ConfigJSON__c
                                              FROM MDLocalisedComponent__c
                                              WHERE id = :mdComponentId];
        if (savedLocalisedListComponent.size() != 0) {
            savedLocalisedListComponent[0].ConfigJSON__c = configJSON;
            update savedLocalisedListComponent;
        }
    }
    
    @AuraEnabled
    public static void SaveChildObjectOneConfig(String configJSON, Id mdComponentId)
    {
        List<MDComponent__c> listComponent = [SELECT Id, ConfigJSON__c
                                               FROM MDComponent__c
                                               WHERE Id = :mdComponentId];
        
        if(!listComponent.isEmpty())
        {
            ///String configJSON = JSON.serialize(configObject);
            listComponent[0].ConfigJSON__c = configJSON;
            UPDATE listComponent[0];
        }
    }
        
    @AuraEnabled
    public static list<MDLocalisedPicklistVal> GetLocalisedPicklistValues(Id localisedPageElementId)
    {
        List<MDLocalisedPicklistVal> listToBeLocalised;
        
        List<MDLocalisedComponent__c> listLocalisedPageElement = [SELECT MDComponent__c, ConfigJSON__c 
                                                                     FROM MDLocalisedComponent__c
                                                                     WHERE Id = :localisedPageElementId];
        
        if(!listLocalisedPageElement.isEmpty())
        {
            String configJSON = listLocalisedPageElement[0].ConfigJSON__c;
            
            //System.debug(configJSON);
            if(String.isNotBlank(configJSON))
            {
                listToBeLocalised = (List<MDLocalisedPicklistVal>)System.JSON.deserialize(configJSON, List<MDLocalisedPicklistVal>.class);    
            }
            else
            {
                // Find out the element, formObjectAPIName
                Id parentElementId =  listLocalisedPageElement[0].MDComponent__c;
                
                List<MDComponent__c> listFormElements = [SELECT Id,
                                                            DataFieldAPIName__c, MDFormStep__c
                                                            FROM MDComponent__c
                                                            WHERE Id  = :parentElementId];
                
                // Get PageFormStep
                if(!listFormElements.isEmpty())
                {
                    String dataFieldApiName = listFormElements[0].DataFieldAPIName__c;
                    
                    List<MDFormStep__c> listFormSteps = [SELECT Id, 
                                                              MDForm__c
                                                              FROM MDFormStep__c
                                                              WHERE Id = :listFormElements[0].MDFormStep__c];
                    
                    if(!listFormSteps.isEmpty())
                    {
                        // Get PageForm
                        Id pageFormId = listFormSteps[0].MDForm__c;
                        
                        List<MDForm__c> pageformList = [SELECT Id,
                                                             ObjectAPIName__c
                                                             FROM MDForm__c
                                                             WHERE Id =:pageFormId];
                        
                        if(!pageformList.isEmpty())
                        {
                            String objectApiName = pageformList[0].ObjectAPIName__c;
                                                        
                            listToBeLocalised = MDFormBuilderController.GetPicklistOptions(objectApiName, dataFieldApiName);
                        }
                    }
                }
            }
        }
        
        return listToBeLocalised;
    }
    
    @AuraEnabled
    public static void SaveLocalisedPicklistValues(Id localisedPageElementId, List<MDLocalisedPicklistVal> listMDLocalisedPicklistVal)
    {
        List<MDLocalisedComponent__c> listLocalisedPageElement = [SELECT MDComponent__c, ConfigJSON__c 
                                                                     FROM MDLocalisedComponent__c
                                                                     WHERE Id = :localisedPageElementId];
        
        if(!listLocalisedPageElement.isEmpty())
        {
            String configJSON = JSON.serialize(listMDLocalisedPicklistVal);
            
            listLocalisedPageElement[0].ConfigJSON__c = configJSON;
            UPDATE listLocalisedPageElement[0];
        }
    }
    
    @AuraEnabled
    public static List<MDLocalisedPicklistVal> GetPicklistOptions(String objectName, string fieldName)
    {
        try 
        {
            List<MDLocalisedPicklistVal> listToBeLocalised;
            
            // get the object type of the SObject.
            Schema.sObjectType objType = Schema.getGlobalDescribe().get(objectName);
            
            // get a map of fields for the SObject
            Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
            
            // get the list of picklist values for this field.
            List<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();
            
            if(!values.isEmpty())   
            {
                system.debug('values not empty' + values.size());
                
                listToBeLocalised = new List<MDLocalisedPicklistVal>();
                
                // add these values to the selectoption list.
                for (Schema.PicklistEntry a: values) 
                {
                    //allOptions.add(a.getValue());
                    MDLocalisedPicklistVal picklistOpt = new MDLocalisedPicklistVal();
                    
                    picklistOpt.TranslatedLabel = a.getLabel();
                    picklistOpt.OptionLabel = a.getLabel();
                    picklistOpt.Include = false;
                    picklistOpt.OptionValue = a.getValue();
                    
                    listToBeLocalised.add(picklistOpt);
                }    
            }                       
            
            return listToBeLocalised;
        }
        catch(Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
}