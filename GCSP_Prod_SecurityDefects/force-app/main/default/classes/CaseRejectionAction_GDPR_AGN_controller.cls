/*
*---------------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev Roushan
* @modifiedBy     Sandip Dey
* @maintainedBy   
* @version        1.0
* @created        
* @modified      19-Nov-2019
* @testClass     
* @Class Name 	 CaseRejectionAction_GDPR_AGN_controller
* -------------------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019    		
*  Apex Controller to the Aura Component CaseRejectionAction_GDPR_AGN which is used as a Quick Action to drive reject case 
functionality on Case. 
*-------------------------------------------------------------------------------------------------------------------------------+
*/

public class CaseRejectionAction_GDPR_AGN_controller 
{
    public class wrapTest 
    {
        @AuraEnabled
        public String comchanel {get; set;}
        @AuraEnabled
        public List<String> allOpts {get; set;}
        @AuraEnabled
        public String cstatus {get; set;}
        @AuraEnabled
        public Case CaseFields {get; set;}
    }
    @AuraEnabled
    public static wrapTest getselectOptions(sObject objObject, string fld, Id caseId) 
    {
        Case cs = new Case();
        cs=[SELECT Id,Rejection_Reason_AGN__c,Record_Type_Name_AGN__c,RecordType.DeveloperName,RejectCase_AGN__c,Rejection_Reason_Code_AGN__c,DS_Selected_Language_GDPR_AGN__c,Status from Case where Id= :caseId];
        wrapTest wt = new wrapTest();    
        String RecordTypeDevName  = cs.RecordType.DeveloperName;
        wt.CaseFields=[SELECT Id,Rejection_Reason_AGN__c,Record_Type_Name_AGN__c,DS_Email_Body_AGN__c,Rejection_Reason_Code_AGN__c,Case_Creation_Channel_GDPR_AGN__c,DS_Selected_Language_GDPR_AGN__c
                       from Case where Id= :caseId];
       
        if((cs.Status=='New' || cs.Status=='Under Review') && cs.RejectCase_AGN__c==false)
        {
               
            list<String> picklistValues = new list<String>();
            
            //get record type Id
            list<RecordType> recordTypes = [Select Id, Name From RecordType  Where SobjectType = 'Case' and DeveloperName = :RecordTypeDevName limit 1];
            Id recordTypeId = (!recordTypes.isEmpty()) ? recordTypes.get(0).Id : null;
            
            if(recordTypeId != null){
                
                String method = 'GET';
                String endpoint = String.format('/services/data/v43.0/ui-api/object-info/{0}/picklist-values/{1}/{2}', new String[]{ 'Case', recordTypeId, fld });
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:DSRM_Named_Credential'+endPoint);
                request.setMethod(method);
                
                HTTPResponse response = (new Http()).send(request);
                
                if(response.getStatusCode() == 200)
                {
                    
                    Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                    if(root.containsKey('values'))
                    { 
                        List<Object> picklistVals = (List<Object>)root.get('values');
                        for(Object picklistVal : picklistVals){
                            Map<String,Object> picklistValMap = (Map<String,Object>) picklistVal;
                            String pickVal ='';
                            pickVal = (String) picklistValMap.get('value');
                            picklistValues.add(pickVal);
                        }
                    }
                    
                }
                
            }
            picklistValues.sort();
            wt.allOpts = picklistValues;
            
            
            Case cs1 = new Case();
            cs1=[SELECT Id,Case_Creation_Channel_GDPR_AGN__c,Status from Case where Id= :caseId];
            wt.comchanel= cs1.Case_Creation_Channel_GDPR_AGN__c;
            wt.cstatus =cs1.Status;
            return wt;
            
            
        }
        else
        {
            if(cs.RejectCase_AGN__c==true)
            {
                wt.cstatus = 'Case Rejected';  
                return wt;
            }
            else
            {
                wt.cstatus = 'Invalid Status';   
                return wt;
            } 
        }
    }

    
    @AuraEnabled
    public static String getextemail(Id caseId ,String rejcode,String rjrc,String msg,Boolean chk,String cch,String SubjectLine) 
    {
        String response;
        Case cs = new Case();
        cs=[SELECT Id,Rejection_Reason_AGN__c,RejectCase_AGN__c,Rejection_Reason_Code_AGN__c,Status,Data_Subject_Email_GDPR_AGN__c,DS_Selected_Language_GDPR_AGN__c from Case where Id= :caseId];
        if(chk == false && cch=='Email')
        {
            cs.DPO_Verified_the_Mail_Content_AGN__c =true;
            cs.RejectCase_AGN__c=true;
            cs.Mail_Sent_AGN__c =true;
            cs.Rejection_Reason_AGN__c=rjrc;
            cs.Rejection_Reason_Code_AGN__c=rejcode;
            cs.DS_Email_Subject_GDPR_AGN__c=SubjectLine;

            //cs.DS_Email_Body_AGN__c = rejcode+' '+rjrc+' '+msg;
            cs.DS_Email_Body_AGN__c = msg;
            cs.Status='Closed';
            
            try
            {
                update cs;
            }
            catch(DmlException e)
            {   
                System.debug('An unexpected error has occurred Case : ' + e.getMessage());   
            }  
            
            
            
            External_Email_Communication_GDPR_AGN__c em = new External_Email_Communication_GDPR_AGN__c();
            em.Associated_Case_GDPR_AGN__c=caseId;
            em.Email_Sent_To__c=cs.Data_Subject_Email_GDPR_AGN__c;
            em.Email_Subject_GDPR_AGN__c = SubjectLine;
             
            em.Email_From_GDPR_AGN__c=System.Label.AGN_CCPA_ExternalEmail_From;
            // em.Email_Body_GDPR_AGN__c=rejcode+' '+rjrc+''+msg;
            em.Email_Body_GDPR_AGN__c=msg;
            
            try
            {
                insert em;
            }
            catch(DmlException e)
            {   
                System.debug('An unexpected error has occurred External Email Communication: ' + e.getMessage());   
            }     
            response ='Email Sent and Attachment Added';
        }
        
        
        else if((chk == true && cch=='Email') || (cch=='Postal' && chk ==false))
        {
            cs.DPO_Verified_the_Mail_Content_AGN__c =false;
            cs.RejectCase_AGN__c=true;
            cs.Mail_Sent_AGN__c =false;
            cs.Rejection_Reason_AGN__c=rjrc;
            cs.Rejection_Reason_Code_AGN__c=rejcode;
            cs.DS_Email_Subject_GDPR_AGN__c=SubjectLine;
 
            cs.DS_Email_Body_AGN__c = msg;
            cs.Status='Closed';
            
            try
            {
                update cs;
            }
            catch(DmlException e)
            {   
                System.debug('An unexpected error has occurred Case : ' + e.getMessage());   
            }  
            response ='Email Not Sent and Attachment Added';
            
        }
        return response;
    }
    
    // function to save the values provided in reject case pop up onclicking save button
    
    @AuraEnabled
    public static String SaveRejectCaseInput(Id caseId1 ,String rejcode1,String rjrc1,String msg1,Boolean chk1,String cch1,String SubjectLine) 
    {
        String response;
        Case cs1 = new Case();
        cs1=[SELECT Id,Rejection_Reason_AGN__c,RejectCase_AGN__c,Rejection_Reason_Code_AGN__c,Status,Data_Subject_Email_GDPR_AGN__c,DS_Selected_Language_GDPR_AGN__c,DS_Email_Subject_GDPR_AGN__c from Case where Id= :caseId1];
        
        //cs1.DS_Email_Subject_GDPR_AGN__c=System.Label.AGN_CCPA_Case_Reject_EmailSubj;
        cs1.DS_Email_Body_AGN__c = msg1;
        cs1.Case_Creation_Channel_GDPR_AGN__c=cch1;
        cs1.Rejection_Reason_AGN__c=rjrc1;
        cs1.Rejection_Reason_Code_AGN__c=rejcode1;
        cs1.DS_Email_Subject_GDPR_AGN__c=SubjectLine;
        response = 'Input saved to case';
        
        try
        {
            update cs1;
        }
        catch(DmlException e)
        {   
            System.debug('An unexpected error has occurred Case : ' + e.getMessage());   
        }  
        
        return response;
    }
    //Calls Generate PDF VF Page AGN_GDPR_RejectCasePdfGenerator and Attaches the rejected details with the case as a pdf.
    @AuraEnabled
    public static void pdfgenerate(Id caseId) 
    {  
        System.debug('Generating PDF');
        Case cs = new Case();
        cs=[SELECT Id,CaseNumber,Status from Case where Id= :caseId];
        
        PageReference pdfPage = new PageReference('/apex/AGN_GDPR_RejectCasePdfGenerator');
        pdfPage.getParameters().put('caseId',caseId);
        Blob pdfContent = pdfPage.getContent();
        try
        {
            Attachment attach1= new Attachment();
            attach1.ParentId = caseId;
            attach1.Name = 'Reject Case PDF - '+cs.CaseNumber;
            attach1.Body = pdfContent;
            attach1.contentType = 'application/pdf';
            insert attach1;
        }
        catch(DmlException e)
        {   
            System.debug('An unexpected error has occurred Case : ' + e.getMessage());   
        }   
    }  
    
}