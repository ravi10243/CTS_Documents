global class AGN_Meeting_SubmitForApproval 
{
    webservice static boolean submitForApproval(Id me) 
    {
        //Id passed from Button JS
        //system.debug(me);
        
        ///Create Request object and set object Id
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        //req.setComments('Submitting request for approval.');
        req.setObjectId(me);
        
        //Checking value in Req object
        //System.debug(req);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req);
        
        //Checking value in result object
        system.debug(result);
        
        //Return value accordingly to display whether the submission was successful
		if(result.isSuccess())	
            return true;
        else 
            return false;
    }
}