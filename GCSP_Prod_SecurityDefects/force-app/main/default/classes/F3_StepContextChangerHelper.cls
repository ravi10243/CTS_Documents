public class F3_StepContextChangerHelper 
{
	public static F3_LEXCaseFormAndStepContext GetStepContext(String formStepId, String moveType, String contextChangerApexClassName)
    {
     	if(!String.isBlank(contextChangerApexClassName))
        {
            F3_StepContextChangeInterface contextChangerInstance = (F3_StepContextChangeInterface)Type.forName(contextChangerApexClassName).newInstance();
            
            //TODO: COMMENT
            System.debug('Inside F3_StepContextChangerHelper');
            System.Debug(contextChangerInstance);
            
            return contextChangerInstance.GetStepContext(formStepId, moveType);    
        }
        
        return null;
    }
}