/*******************************************************************************
* @author         :    Sarang Kulkarni
* @date           :    April 2019 
* @description    :    This class acts as controller for SitePage lightning component and associated components.
* @Revisions      :    
*******************************************************************************/
public class F3_SitePageController {
	
    @AuraEnabled 
    public static F3_MDSitePageWrapper GetLocalisedPage(String urlKey, String langCode, string mdpageformstepId)
    {
        F3_MDSitePageWrapper sitePageWrapper;
        
        // Get MDForm__c
        List<MDForm__c> listPageForm = [SELECT Id, 
                                             Status__c,
                                        	 PropertiesJSON__c,
                                             ObjectAPIName__c,
                                             ObjectRecordTypeAPIName__c,
                                        	 BrandingJSON__c,
                                        	 FormDescription__c,
                                        	 FormTitle__c,
                                        	 HelpText__c,
                                        	 SaveButtonLabel__c,
                                        	 SaveAndNextButtonLabe__c,
                                        	 SaveAndPreviousButtonLabe__c,
                                             (SELECT Id,
                                             	FormAttributesJSON__c,
                                             	FormDescription__c,
                                             	FormTitle__c,
                                             	Language__c,
                                                HelpText__c,
                                             	SaveAndNextButtonLabel__c,
                                             	SaveAndPreviousButtonLabel__c,
                                             	SaveButtonLabel__c
                                             	FROM MD_Localised_Forms__r
                                             	WHERE Language__c = :langCode) 
                                             FROM MDForm__c
                                             WHERE URLKey__c =:urlKey];
        system.debug('listPageForm: ' + listPageForm.size());
       //get all languages available to display as language selector on the comuunity page.
        list<F3_PageLanguageSelectorController.languageTypes> languagesList = new list<F3_PageLanguageSelectorController.languageTypes>();
        Schema.DescribeFieldResult F = MDLocalisedFormStep__c.Language__c.getDescribe();
		Schema.sObjectField T = F.getSObjectField();
		List<Schema.PicklistEntry> allLanguages = T.getDescribe().getPicklistValues();
        system.debug('allLanguages: ' + allLanguages); 
        for(PicklistEntry pe : allLanguages){
            F3_PageLanguageSelectorController.languageTypes lang = new F3_PageLanguageSelectorController.languageTypes();
            lang.langName = pe.getLabel();
            lang.langCode = pe.getValue();
            languagesList.add(lang);
        }
        
        if(!listPageForm.isEmpty())
        {
        	sitePageWrapper = new F3_MDSitePageWrapper();
            sitePageWrapper.DefaultPageForm = listPageForm[0];
            sitePageWrapper.urlKey = urlKey;
            sitePageWrapper.languageCode = langCode;
            sitePageWrapper.PageFormBrandingJSON = ((List<MDCSSFormAreaWrapper>) System.JSON.deserialize(listPageForm[0].BrandingJSON__c, List<MDCSSFormAreaWrapper>.class));
            sitePageWrapper.PageFormPropertiesJSON = ((List<MDFormPropertyWrapper>) System.JSON.deserialize(listPageForm[0].PropertiesJSON__c, List<MDFormPropertyWrapper>.class));
            sitePageWrapper.FormPortalDescription = listPageForm[0].FormDescription__c;
            sitePageWrapper.FormPortalLabel = listPageForm[0].FormTitle__c;
            sitePageWrapper.HelpText = listPageForm[0].HelpText__c;
            sitePageWrapper.SaveButtonLabel = listPageForm[0].SaveButtonLabel__c;
            sitePageWrapper.SaveNextButtonLabel = listPageForm[0].SaveAndNextButtonLabe__c;
            sitePageWrapper.SavePreviousButtonLabel = listPageForm[0].SaveAndPreviousButtonLabe__c;
            List<MDLocalisedForm__c> listLocalisedPageForm = new List<MDLocalisedForm__c>();
            sitePageWrapper.languagesList = languagesList;  
            listLocalisedPageForm.addAll(listPageForm[0].MD_Localised_Forms__r);
            system.debug('---sitePageWrapper.languagesList---'+sitePageWrapper.languagesList);
            if(!listLocalisedPageForm.isEmpty()){
                sitePageWrapper.FormPortalLabel = listLocalisedPageForm[0].FormTitle__c;
                sitePageWrapper.FormPortalDescription = listLocalisedPageForm[0].FormDescription__c;
                sitePageWrapper.SaveButtonLabel = listLocalisedPageForm[0].SaveButtonLabel__c;
                sitePageWrapper.HelpText = listPageForm[0].HelpText__c;
                sitePageWrapper.SaveNextButtonLabel = listLocalisedPageForm[0].SaveAndNextButtonLabel__c;
                sitePageWrapper.SavePreviousButtonLabel = listLocalisedPageForm[0].SaveAndPreviousButtonLabel__c;
            }
            
            // Get all the pageform steps
                sitePageWrapper.ListPageFormSteps = F3_SitePageController.GetMDPageFormSteps(listPageForm[0].Id, langCode);
            	// Get default/supplied pageform step
                if(mdpageformstepId==null)
                {
                    ID firstFormStepId = sitePageWrapper.ListPageFormSteps[0].PageFormStepId;
                    
                    sitePageWrapper.CurrentStepId = firstFormStepId;
                    sitePageWrapper.PageFormStepWrapper = F3_SitePageController.GetMDPageFormStep(firstFormStepId, langCode);
                }
                else
                {
                    sitePageWrapper.PageFormStepWrapper = F3_SitePageController.GetMDPageFormStep(mdpageformstepId, langCode);
                    sitePageWrapper.CurrentStepId = mdpageformstepId;
                }
                
                if(sitePageWrapper.PageFormStepWrapper!=null)
                {
                   	sitePageWrapper.PageFormStepWrapper.SaveButtonLabel = sitePageWrapper.SaveButtonLabel;
                    sitePageWrapper.PageFormStepWrapper.SaveNextButtonLabel = sitePageWrapper.SaveNextButtonLabel;
                    sitePageWrapper.PageFormStepWrapper.SavePreviousButtonLabel = sitePageWrapper.SavePreviousButtonLabel;
                }
            	system.debug('Page Wrapper : ' + sitePageWrapper);
        }
        return sitePageWrapper;
    }
    
    @AuraEnabled 
    public static F3_MDSitePageWrapper GetLocalisedPage(Id formId, String langCode, Id mdpageformstepId)
    {
        F3_MDSitePageWrapper sitePageWrapper;
        
        // Get MDForm__c
        List<MDForm__c> listPageForm = [SELECT Id, RecordTypeId,
                                             Status__c,
                                        	 PropertiesJSON__c,
                                             ObjectAPIName__c,
                                             ObjectRecordTypeAPIName__c,
                                        	 BrandingJSON__c,
                                        	 FormDescription__c,
                                        	 FormTitle__c,
                                        	 SaveButtonLabel__c,
                                        	 SaveAndNextButtonLabe__c,
                                        	 SaveAndPreviousButtonLabe__c,
                                             (SELECT Id,
                                             	FormAttributesJSON__c,
                                             	FormDescription__c,
                                             	FormTitle__c,
                                             	Language__c,
                                             	SaveAndNextButtonLabel__c,
                                             	SaveAndPreviousButtonLabel__c,
                                             	SaveButtonLabel__c
                                             	FROM MD_Localised_Forms__r
                                             	WHERE Language__c = :langCode) 
                                             FROM MDForm__c
                                             WHERE Id =:formId];
        system.debug('listPageForm: ' + listPageForm.size());
        //get all languages available to display as language selector on the comuunity page.
        list<F3_PageLanguageSelectorController.languageTypes> languagesList = new list<F3_PageLanguageSelectorController.languageTypes>();
        Schema.DescribeFieldResult F = MDLocalisedFormStep__c.Language__c.getDescribe();
		Schema.sObjectField T = F.getSObjectField();
		List<Schema.PicklistEntry> allLanguages = T.getDescribe().getPicklistValues();
        system.debug('allLanguages: ' + allLanguages); 
        for(PicklistEntry pe : allLanguages){
            F3_PageLanguageSelectorController.languageTypes lang = new F3_PageLanguageSelectorController.languageTypes();
            lang.langName = pe.getLabel();
            lang.langCode = pe.getValue();
            languagesList.add(lang);
        }
        
        if(!listPageForm.isEmpty())
        {
        	sitePageWrapper = new F3_MDSitePageWrapper();
            sitePageWrapper.DefaultPageForm = listPageForm[0];
            sitePageWrapper.languageCode = langCode;
            sitePageWrapper.recordTypeName = listPageForm[0].RecordTypeId;
            sitePageWrapper.PageFormBrandingJSON = ((List<MDCSSFormAreaWrapper>) System.JSON.deserialize(listPageForm[0].BrandingJSON__c, List<MDCSSFormAreaWrapper>.class));
            sitePageWrapper.PageFormPropertiesJSON = ((List<MDFormPropertyWrapper>) System.JSON.deserialize(listPageForm[0].PropertiesJSON__c, List<MDFormPropertyWrapper>.class));
            sitePageWrapper.FormPortalDescription = listPageForm[0].FormDescription__c;
            sitePageWrapper.languagesList = languagesList;
            sitePageWrapper.FormPortalLabel = listPageForm[0].FormTitle__c;
            sitePageWrapper.FormPortalLabel = listPageForm[0].FormDescription__c;
            sitePageWrapper.SaveButtonLabel = listPageForm[0].SaveButtonLabel__c;
            sitePageWrapper.SaveNextButtonLabel = listPageForm[0].SaveAndNextButtonLabe__c;
            sitePageWrapper.SavePreviousButtonLabel = listPageForm[0].SaveAndPreviousButtonLabe__c;
            List<MDLocalisedForm__c> listLocalisedPageForm = new List<MDLocalisedForm__c>();
            listLocalisedPageForm.addAll(listPageForm[0].MD_Localised_Forms__r);
            if(!listLocalisedPageForm.isEmpty()){
                //sitePageWrapper.FormPortalLabel = listLocalisedPageForm[0].LEX_LocalisedPortalLabel__c;
                sitePageWrapper.FormPortalLabel = listLocalisedPageForm[0].FormDescription__c;
                sitePageWrapper.FormPortalDescription = listLocalisedPageForm[0].FormTitle__c;
                sitePageWrapper.SaveButtonLabel = listLocalisedPageForm[0].SaveButtonLabel__c;
                sitePageWrapper.SaveNextButtonLabel = listLocalisedPageForm[0].SaveAndNextButtonLabel__c;
                sitePageWrapper.SavePreviousButtonLabel = listLocalisedPageForm[0].SaveAndPreviousButtonLabel__c;
            }
            // Get all the pageform steps
                sitePageWrapper.ListPageFormSteps = F3_SitePageController.GetMDPageFormSteps(listPageForm[0].Id, langCode);
            	// Get default/supplied pageform step
                if(mdpageformstepId==null)
                {
                    ID firstFormStepId = sitePageWrapper.ListPageFormSteps[0].PageFormStepId;
                    
                    sitePageWrapper.CurrentStepId = firstFormStepId;
                    sitePageWrapper.PageFormStepWrapper = F3_SitePageController.GetMDPageFormStep(firstFormStepId, langCode);
                }
                else
                {
                    sitePageWrapper.PageFormStepWrapper = F3_SitePageController.GetMDPageFormStep((String)mdpageformstepId, langCode);
                    sitePageWrapper.CurrentStepId = (String)mdpageformstepId;
                }
                
                if(sitePageWrapper.PageFormStepWrapper!=null)
                {
                   	sitePageWrapper.PageFormStepWrapper.SaveButtonLabel = sitePageWrapper.SaveButtonLabel;
                    sitePageWrapper.PageFormStepWrapper.SaveNextButtonLabel = sitePageWrapper.SaveNextButtonLabel;
                    sitePageWrapper.PageFormStepWrapper.SavePreviousButtonLabel = sitePageWrapper.SavePreviousButtonLabel;
                }
            	system.debug('Page Wrapper : ' + sitePageWrapper);
        }
        return sitePageWrapper;
    }
    
    /*******************************************************************************
	* @author         :    Sarang Kulkarni
	* @date           :    April 2019 
	* @description    :    Method to return all pageformsteps for a given form
	* @param          :    pkey
	* @return         :    returns the list of pageformsteps for a given form    
	*******************************************************************************/
    @AuraEnabled
    public static List<F3_MDFormStepWrapper> GetMDPageFormSteps(Id mdPageFormId, String langCode)
    {
    	List<F3_MDFormStepWrapper> listFormStepWrapper;
        
        List<MDFormStep__c> listFormSteps = [SELECT Id,
                                             		Name,
                                             		LocalisedShortName__c,
                                             		LocalisedLongName__c,
                                             		Description__c,
                                             		Type__c,
                                             		OnLoadViewState__c,
                                             		(SELECT Id,
                                                    		Name,
                                                     		LocalisedShortName__c,
                                                     		Language__c,
                                                     		LocalisedLongName__c,
                                                     		Description__c
                                                    		FROM MD_Localised_FormSteps__r
                                                    		WHERE Language__c = :langCode)
                                                  FROM MDFormStep__c
                                                  WHERE MDForm__c = :mdPageFormId AND IsActive__c = true
                                                  ORDER BY StepOrder__c];
        
        if(!listFormSteps.isEmpty())
        {
            listFormStepWrapper = new List<F3_MDFormStepWrapper>();
        }
        Set<Id> setStepId = new Set<Id>();
            
        for(MDFormStep__c step : listFormSteps)
        {
            setStepId.add(step.Id);
        }
        
        for(MDFormStep__c pageFormStep : listFormSteps)
        {
        	F3_MDFormStepWrapper stepWrapper = new F3_MDFormStepWrapper(pageFormStep);
            stepWrapper.ShortName = pageFormStep.LocalisedShortName__c;
            stepWrapper.PortalLabel = pageFormStep.LocalisedLongName__c;
            stepWrapper.StepType = pageFormStep.Type__c;
            stepWrapper.Description = pageFormStep.Description__c;
            if(!pageFormStep.MD_Localised_FormSteps__r.isEmpty()){
                stepWrapper.ShortName = pageFormStep.MD_Localised_FormSteps__r[0].LocalisedShortName__c;
                stepWrapper.PortalLabel = pageFormStep.MD_Localised_FormSteps__r[0].LocalisedLongName__c;
                stepWrapper.Description = pageFormStep.MD_Localised_FormSteps__r[0].Description__c;
            }
            listFormStepWrapper.add(stepWrapper);
        }
        return listFormStepWrapper;
    }
    
    @AuraEnabled
    public static F3_MDFormStepWrapper GetMDPageFormStep(ID mdPageFormStepId, String langCode)
    {
    	F3_MDFormStepWrapper pageFormStepWrapper;
        
        List<MDFormStep__c> listFormSteps = [SELECT Id,
                                                  IsActive__c,
                                                  MDForm__c,
                                                  LocalisedShortName__c,
                                                  Name,
                                                  LocalisedLongName__c,
                                                  StepOrder__c,
                                                  ValidatorClass__c,
                                                  Description__c,
                                             	  Type__c,
                                             	OnLoadViewState__c,
                                             	  (SELECT Id,
                                                  			Name,
                                                     		LocalisedShortName__c,
                                                     		Language__c,
                                                     		LocalisedLongName__c,
                                                   			Description__c
                                                    		FROM MD_Localised_FormSteps__r
                                                   			WHERE Language__c = :langCode
                                                  )
                                                  FROM MDFormStep__c
                                                  WHERE Id = :mdPageFormStepId];
        
        if(!listFormSteps.isEmpty())
        {
            pageFormStepWrapper = new F3_MDFormStepWrapper(listFormSteps[0]);
            
            pageFormStepWrapper.ListElements = GetComponents(mdPageFormStepId, langCode);
        }
        
        return pageFormStepWrapper;
        
    }
    
    @AuraEnabled
    public static List<F3_MDComponentWrapper> GetComponents(Id mdPageFormStepId, String langCode)
    {
        List<F3_MDComponentWrapper> listComponentWrapper;
        
        List<MDComponent__c> listComponents = [SELECT Id,
                                               Name,
                                               BrandingJSON__c,
                                               DataFieldAPIName__c,
                                               Component_Display_Type__c,
                                               DependencyMetadata__c,
                                               DeveloperName__c,
                                               OnChangeViewState__c,
                                               ElementType__c,
                                               IsActive__c,
                                               MDFormStep__c,
                                               ContainerTextHtml__c,
                                               PortalLabel__c,
                                               PortalQuickHelpText__c,
                                               Required__c,
                                               ContainerRichText__c,
                                               SortOrder__c,
                                               ComponentTypeIcon__c,
                                               ComponentType__c,
                                               ComponentTypeLabel__c,
                                               IsHidden__c,
                                               ReadOnly__c,
                                               DefaultValue__c,
                                               (SELECT Id,
                                                		ConfigJSON__c,
                                                		ContainerTextHtml__c,
                                                		Language__c,
                                                		Name,
                                                		PortalLabel__c,
                                                		PortalQuickHelpText__c                       		
                                                		FROM MD_Localised_Components__r
                                               			WHERE Language__c = :langCode)
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
                componentWrapper.CurrentLanguageCode = langCode;
                componentWrapper.PageElementId = component.Id;
                componentWrapper.PageElement = component;
                componentWrapper.DeveloperName = component.DeveloperName__c;
                componentWrapper.OnChangeViewState = component.OnChangeViewState__c;
                componentWrapper.ContainerHtmlText = component.ContainerTextHtml__c;
                componentWrapper.ContainerRichText = component.ContainerRichText__c;
                componentWrapper.PortalLabel = component.PortalLabel__c;
                componentWrapper.QuickHelpText = component.PortalQuickHelpText__c;
                componentWrapper.IsHidden = component.IsHidden__c;
                componentWrapper.ReadOnly = component.ReadOnly__c;
                componentWrapper.DefaultValue = component.DefaultValue__c; //(component.DefaultValue__c == null) ? '' : 
                
                if(component.BrandingJSON__c != NULL)
                	componentWrapper.PageFormComponentBrandingJSON = ((MDCSSFormAreaWrapper) System.JSON.deserialize(component.BrandingJSON__c, MDCSSFormAreaWrapper.class));
                if(!component.MD_Localised_Components__r.isEmpty())
                {  
                    
                    componentWrapper.ContainerHtmlText = component.MD_Localised_Components__r[0].ContainerTextHtml__c;
                    componentWrapper.PortalLabel = component.MD_Localised_Components__r[0].PortalLabel__c;
                    componentWrapper.QuickHelpText = component.MD_Localised_Components__r[0].PortalQuickHelpText__c;
                }
                
                listComponentWrapper.add(componentWrapper);
            }
        }
        
        return listComponentWrapper;
    }
    
    @AuraEnabled 
    public static string GetPreviousStepId(string mdPageFormStepId)
    {
        string previousStep = '';
        
        // Get the current step
        List<MDFormStep__c> listCurrentStep = [SELECT Id,StepOrder__c, MDForm__c
                                                  FROM MDFormStep__c
                                                  WHERE Id = :mdPageFormStepId];
        
        if(!listCurrentStep.isEmpty())
        {
            MDFormStep__c currentStep = listCurrentStep[0];
            
            List<MDFormStep__c> listPrevious = [SELECT Id,StepOrder__c, MDForm__c
                                                  FROM MDFormStep__c
                                                  WHERE MDForm__c = :currentStep.MDForm__c
                                              			AND StepOrder__c < :currentStep.StepOrder__c
                                                     	AND IsActive__c = true
                                              	  ORDER BY StepOrder__c DESC NULLS LAST];
            
            if(!listPrevious.isEmpty())
            {
                previousStep = listPrevious[0].Id;
            }
            else
            {
                previousStep = 'START';
            }
        }
        
        return previousStep;
    }
    
    @AuraEnabled 
    public static string GetNextStepId(string mdPageFormStepId)
    {
        string nextStep = '';
        
        // Get the current step
        List<MDFormStep__c> listCurrentStep = [SELECT Id,StepOrder__c, MDForm__c
                                                  FROM MDFormStep__c
                                                  WHERE Id = :mdPageFormStepId];
        
        if(!listCurrentStep.isEmpty())
        {
            MDFormStep__c currentStep = listCurrentStep[0];
            
            List<MDFormStep__c> listNext = [SELECT Id,StepOrder__c, MDForm__c
                                                  FROM MDFormStep__c
                                                  WHERE MDForm__c = :currentStep.MDForm__c
                                              			AND StepOrder__c > :currentStep.StepOrder__c
                                                 		AND IsActive__c = true
                                              	  ORDER BY StepOrder__c asc];
            
            if(!listNext.isEmpty())
            {
                nextStep = listNext[0].Id;
            }
            else
            {
                nextStep = 'END';
            }
        }
        
        return nextStep;
    }
    
    @auraenabled
    public static LEXApplication__c getApplicationById(Id appId){
        return [SELECT Id,Name, ApplicationNumber__c,Status__c, CreatedDate FROM LEXApplication__c where Id = : appId];
    }
}