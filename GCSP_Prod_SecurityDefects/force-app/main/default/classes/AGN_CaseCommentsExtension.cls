/*
Type Name: AGN_CaseCommentsExtension
Reason: Edit/Add comments from standard page layout.
03-09-2016 - SG - Initial Version
*/
public with sharing class AGN_CaseCommentsExtension {
    
    public Case editCase {get;set;}
    public list<AGN_CaseCommentWrapper> newCommentLineItems {get;set;}
    public list<CaseComment> caseComments {get;set;}
    list<CaseComment> newComments {get;set;}    
    public Id delCommentId {get;set;}
    public Case caseDetails;
    public String commentsCountryCode;
    public AGN_CaseCommentsExtension(ApexPages.StandardController controller){
        
        editCase = (Case)controller.getRecord();
        newCommentLineItems = new list<AGN_CaseCommentWrapper>();
        newComments = new list<CaseComment>();
        caseComments = [select commentBody, CreatedBy.Name, CreatedDate from CaseComment where parentId =: editCase.Id order by CreatedDate desc];       
        /*19r3,start*/
        caseDetails = [select Country_Code_AGN__c from Case where id =:editCase.Id];
        User userInfo = [select Id, Profile.Id from User where Id =: UserInfo.getUserId()];
        AGN_Settings__c agnSettings = AGN_Settings__c.getInstance(userInfo.Profile.Id);
        commentsCountryCode = agnSettings.Comments_Mandatory_AGN__c;
        /*end */
        
    }
    
    public PageReference SaveRecord(){
        
        try
        {   
            AGN_Settings__c AGN_Setting = AGN_Settings__c.getInstance();
            String recordtypestring = AGN_Setting.Comments_mandatory_record_types_AGN__c;
            
            
            List<String> mandatrecordtype = new List<String>();
            if(recordtypestring != null)
            {
                mandatrecordtype = recordtypestring.split(';');   
            }
            /*mandatrecordtype.add('AGN_Order_Request_Distribution');
                mandatrecordtype.add('AGN_Order_Request_Invoicing');
                mandatrecordtype.add('AGN_Order_Request_Sales_Order');
                mandatrecordtype.add('AGN_Order_Request_Sample');
                mandatrecordtype.add('AGN_Order_Request_Taxation');
                mandatrecordtype.add('AGN_Support_Request_Customer_Registration');
                mandatrecordtype.add('AGN_Support_Request_Customer_Update');
                mandatrecordtype.add('AGN_Complaint_Request_Patient');
                mandatrecordtype.add('AGN_Complaint_Request_Professional');
                mandatrecordtype.add('AGN_Support_Request_Miscellaneous');
                mandatrecordtype.add('AGN_Support_Request_Account_Receivable');
                mandatrecordtype.add('AGN_Support_Request_Return_AGN');
                mandatrecordtype.add('AGN_Support_Request_Information');*/
            
            RecordType caserec = [Select id,name,DeveloperName from RecordType where id =: editCase.RecordTypeId];
            for(AGN_CaseCommentWrapper c: newCommentLineItems){
                
                System.debug('Case comment: '+c.comment.CommentBody);
                if(mandatrecordtype.contains(caserec.DeveloperName))
                {
                    //19r3, added commentBody and country specific checking for null comment body
                    if(c.comment.CommentBody == '' && commentsCountryCode.contains(caseDetails.Country_Code_AGN__c)){
                        System.debug('inside comment null');
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Comment'));
                    } 
                    else{
                        
                        System.debug('inside comment not null');
                        c.comment.ParentId = editCase.Id;
                        c.comment.CommentBody = c.Type + ' => ' + c.comment.CommentBody;
                        newComments.add(c.comment);            
                        //------CheckMarx--Added on 24/07/2020----------   
                        /*SObjectAccessDecision decisionOnCmts1 = Security.stripInaccessible(AccessType.CREATABLE,newComments);
                        if(decisionOnCmts1.getRemovedFields().get('CaseComment')!=null){
                            throw new AGN_CommonException('Error: Insufficient Create Access On CaseComment [Class Name: AGN_CaseCommentsExtension and Method Name: SaveRecord]');
                        }
                        else{
                            insert newComments;
                        }*/
                        String objCrCmntt = 'CaseComment';
                        SObjectType ACsCmtObjType = ((SObject)(Type.forName('Schema.'+objCrCmntt).newInstance())).getSObjectType();
                        AGN_FLSCheck.check(newComments,ACsCmtObjType,'INSERT');
                        insert newComments;
                        //--------------------
                    }
                }
                else{
                    
                    System.debug('inside comment not null');
                    c.comment.ParentId = editCase.Id;
                    c.comment.CommentBody = c.Type + ' => ' + c.comment.CommentBody;
                    newComments.add(c.comment);            
                    //------CheckMarx--Added on 24/07/2020----------   
                    /*SObjectAccessDecision decisionOnCmts2 = Security.stripInaccessible(AccessType.CREATABLE,newComments);
                    if(decisionOnCmts2.getRemovedFields().get('CaseComment')!=null){
                        throw new AGN_CommonException('Error: Insufficient Create Access On CaseComment [Class Name: AGN_CaseCommentsExtension and Method Name: SaveRecord]');
                    }
                    else{
                        insert newComments;
                    }*/
                    String objCrCmnt2 = 'CaseComment';
                    SObjectType ACsCmt1ObjType = ((SObject)(Type.forName('Schema.'+objCrCmnt2).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(newComments,ACsCmt1ObjType,'INSERT');
                    insert newComments;
                    //-------------------------------------------------
                    
                }
                
            }
        }
        catch (DmlException e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(msg);          
        }
        
        return null;
    }
    /*19r3,hasError referred in vf page to check whether save button has page messages. Start */
    public Boolean hasError {
        get {
            return ApexPages.hasMessages();
        }
    }
    /*19r3,end */
    public PageReference DeleteRecord(){
        
        try
        {   
            for (CaseComment c : caseComments){
                if (c.Id == delCommentId){
                    //------CheckMarx--Updated on 24/07/2020----------                    
                    if(CaseComment.sObjectType.getDescribe().isDeletable()){
                        delete c;
                        break;  
                    }
                    else{
                        throw new AGN_CommonException('Error: Insufficient Delete permission on  CaseComment [Class Name: AGN_CaseCommentsExtension and Method Name: DeleteRecord]');
                    }
                    //------------------------------------------------
                }
            }
        }
        catch (DmlException e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(msg);          
        }
        
        return null;
    }        
    
}