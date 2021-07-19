public class F3_LEXCaseFormController 
{
    @AuraEnabled
    public static F3_LEXCaseFormStepWrapper GetLEXFormStepWrapper(String formStepId)
    {
        F3_LEXCaseFormStepWrapper wrapper;
        
        List<LEXFormStep__c> listFormStep = [SELECT Id, LEXForm__c, MDFormStep__c, CurrentViewState__c, Status__c FROM  
                                             LEXFormStep__c WHERE Id = :formStepId];
        
        LEXFormStep__c currentFormStep;
        
        if(listFormStep!=null)
        {
            if(listFormStep.size() > 0)
            {
                currentFormStep = listFormStep[0];
                
                wrapper = new F3_LEXCaseFormStepWrapper();
                wrapper.LEXStepId = currentFormStep.Id;
                wrapper.CurrentViewState = currentFormStep.CurrentViewState__c;
                
                // STEP 1: Get the LEX Form Record Id
                List<LEXForm__c> listLEXForm = [SELECT Id, FormObjectRecordId__c, MD_Form__c, Status__c
                                                FROM LEXForm__c WHERE Id = :currentFormStep.LEXForm__c];
                if(listLEXForm != null)
                {
                    if(listLEXForm.size() > 0)
                    {
                        wrapper.CaseFormObjectRecordId = listLEXForm[0].FormObjectRecordId__c;
                        
                        // STEP 2: Get the MD Form Record - ObjectAPIName
                        List<MDForm__c> listMDForm = [SELECT Id, ObjectAPIName__c, ParentRelationshipAPIName__c FROM MDForm__c
                                                      WHERE Id = :listLEXForm[0].MD_Form__c];
                        if(listMDForm!=null)
                        {
                            if(listMDForm.size() > 0)
                            {
                                wrapper.CaseRelationshipFieldAPIName = listMDForm[0].ParentRelationshipAPIName__c;
                                wrapper.CaseFormObjectAPIName =  listMDForm[0].ObjectAPIName__c;
                            }
                        }
                    }
                }
                
                // STEP 3: Get Component Collections from MD Form Step Id
                Id mdPageFormStepId = currentFormStep.MDFormStep__c;
                
                List<F3_MDComponentWrapper> listComponents = F3_SitePageController.GetComponents(mdPageFormStepId, 'enGB');
                wrapper.ListComponent = listComponents;
            }
        }
        return wrapper;
    }
    
    @AuraEnabled
    public static List<LEXForm__c> GetLEXFormsForACase(string caseId)
    {
        List<LEXForm__c> listForm = [SELECT Id,Name,Case__c,MD_Form__c,Portal_Label__c,Status__c, Sort_Order__c 
                                     FROM LEXForm__c WHERE Case__c =: caseId
                                     ORDER BY Sort_Order__c];
        
        return listForm;
    }
    
    @AuraEnabled
    public static List<LEXFormStep__c> GetLEXFormStepsForAForm(Id lexFormId)
    {
        List<LEXFormStep__c> listStep = [SELECT Id,Name,LEXForm__c,Sort_Order__c,Status__c
                                         FROM LEXFormStep__c WHERE LEXForm__c =: lexFormId
                                         ORDER BY Sort_Order__c];
        
        return listStep;
    }
    
    @AuraEnabled
    public static LEXForm__c UpdateObjectRecordID(Id lexFormRecordId, Id formObjectRecordId, Id lexFormStepId, string currentStepViewState)
    {
        List<LEXForm__c> listForm = [SELECT Id, FormObjectRecordId__c FROM LEXForm__c
                                     WHERE Id = :lexFormRecordId];
        
        LEXForm__c lexForm;
        if(listForm!=null)
        {
            if(listForm.size() > 0)
            {
                lexForm = listForm[0];
                
                lexForm.FormObjectRecordId__c = formObjectRecordId;
                
                UPDATE lexForm;
            }
        }
        
        List<LEXFormStep__c> listStep = [SELECT Id, CurrentViewState__c
                                         FROM LEXFormStep__c WHERE ID =: lexFormStepId];
        
        if(listStep!=null)
        {
            if(listStep.size() > 0)
            {
                LEXFormStep__c formStep = listStep[0];
                formStep.CurrentViewState__c = currentStepViewState;
                
                UPDATE formStep;
            }
        }
        
        return lexForm;
    }
    
    @AuraEnabled
    public static F3_LEXCaseFormAndStepContext GetPreviouStepContext(Id currentStepId, Id caseId)
    {
        List<LEXFormStep__c> listCurrentStep = [SELECT Id,  StepContextChangerClassAPIName__c
                                                FROM LEXFormStep__c WHERE Id = :currentStepId];
        
        F3_LEXCaseFormAndStepContext currentContext;
        
        if(listCurrentStep!=null)
        {
            if(listCurrentStep.size() > 0)
            {
                String contextChangeClassName = listCurrentStep[0].StepContextChangerClassAPIName__c;
                if(!String.isBlank(contextChangeClassName))
                {
                    currentContext = F3_StepContextChangerHelper.GetStepContext(currentStepId, 'PREV', contextChangeClassName);    
                }
                else
                {
                    List<LEXForm__c> listForm = [SELECT Id, Sort_Order__c 
                                                 FROM LEXForm__c WHERE Case__c =: caseId
                                                 ORDER BY Sort_Order__c];
                    
                    Set<Id> setFormId = new Set<Id>();
                    
                    for(LEXForm__c lexForm :listForm)
                    {
                        setFormId.add(lexForm.Id);
                    }
                    
                    List<LEXFormStep__c> listStep = [SELECT Id, LEXForm__c, LEXFormSortOrder__c, Sort_Order__c
                                                     FROM LEXFormStep__c WHERE LEXForm__c IN :setFormId
                                                     ORDER BY LEXFormSortOrder__c, Sort_Order__c];
                    
                    currentContext = new F3_LEXCaseFormAndStepContext();
                    currentContext.IsFirstStep = false;
                    currentContext.IsLastStep = false;
                    
                    Integer counter = 0;
                    
                    for(LEXFormStep__c formStep : listStep)
                    {
                        if(formStep.Id == currentStepId)
                        {
                            Integer previousCounterNumber = counter - 1;
                            currentContext.LEXFormId = listStep[previousCounterNumber].LEXForm__c;
                            currentContext.LEXFormStepId = listStep[previousCounterNumber].Id;  
                            
                            if(previousCounterNumber == 0)
                            {
                                currentContext.IsFirstStep = true;     
                            }
                        }    
                        counter++;
                    }
                }
            }
        }

        return currentContext;
    }
    
    @AuraEnabled
    public static F3_LEXCaseFormAndStepContext GetNextStepContext(Id currentStepId, Id caseId)
    {
        List<LEXFormStep__c> listCurrentStep = [SELECT Id,  StepContextChangerClassAPIName__c
                                                FROM LEXFormStep__c WHERE Id = :currentStepId];
        
        F3_LEXCaseFormAndStepContext currentContext;
        
        if(listCurrentStep!=null)
        {
            if(listCurrentStep.size() > 0)
            {
                String contextChangeClassName = listCurrentStep[0].StepContextChangerClassAPIName__c;
                //TODO: COMMENT
                System.Debug('contextChangeClassName ==>' + contextChangeClassName);
                
                if(!String.isBlank(contextChangeClassName))
                {
                    currentContext = F3_StepContextChangerHelper.GetStepContext(currentStepId, 'NEXT', contextChangeClassName);    
                }
                else
                {
                    List<LEXForm__c> listForm = [SELECT Id, Sort_Order__c 
                                                 FROM LEXForm__c WHERE Case__c =: caseId
                                                 ORDER BY Sort_Order__c];
                    Set<Id> setFormId = new Set<Id>();
                    
                    for(LEXForm__c lexForm :listForm)
                    {
                        setFormId.add(lexForm.Id);
                    }
                    
                    List<LEXFormStep__c> listStep = [SELECT Id, LEXForm__c, LEXFormSortOrder__c, Sort_Order__c, StepContextChangerClassAPIName__c
                                                     FROM LEXFormStep__c WHERE LEXForm__c IN :setFormId
                                                     ORDER BY LEXFormSortOrder__c, Sort_Order__c];
                    
                    currentContext = new F3_LEXCaseFormAndStepContext();
                    currentContext.IsFirstStep = false;
                    currentContext.IsLastStep = false;
                    
                    Integer counter = 0;
                    
                    for(LEXFormStep__c formStep : listStep)
                    {
                        if(formStep.Id == currentStepId)
                        {
                            Integer nextCounterNumber = counter + 1;
                            
                            currentContext.LEXFormId = listStep[nextCounterNumber].LEXForm__c;
                            currentContext.LEXFormStepId = listStep[nextCounterNumber].Id;   
                            
                            if(nextCounterNumber == (listStep.size() - 1))
                            {
                                currentContext.IsLastStep = true;    
                            }
                        }    
                        counter++;
                    }
                }
            }
        }
        
        return currentContext;
    }
}