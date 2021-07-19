/*
Type Name: AGN_CaseEditExtension
28-07-2016 - SG - Initial Version
Reason: Extension for new case visualforce page.
*/
public with sharing class AGN_CaseEditExtension {
    
    public Case newCase {get;set;}
    public Case_Attributes_for_CoolSculpting_AGN__c newCaseAttribute {get;set;}
    public list<Case_Product_List_AGN__c> productLineItems {get;set;}
    public list<AGN_CaseCommentWrapper> caseComments {get;set;}       
    public Case dummyPersonAccount {get;set;} //lookup for person account/contact
    public Case dummySecondaryPoC {get; set;} //lookup for Secondary Point of Contact used in CoolSculpting
    public string recordType {get;set;}
    public boolean shipToSameCheck {get;set;}
    //Added by HCO harmonization team to copy SAP Sold To to SAP Ship To in case creation page//
    public boolean shipToSameCheck_SAP {get;set;}
    //Added by HCO harmonization team to copy SAP Sold To to SAP Ship To in case creation page//
    public string internalComments {get;set;}
    
    private string accID{get;set;}
    private string parentId {get;set;}
    private string caseType {get;set;}
    private string caseReason {get;set;}
    private String caseStaticCategory{get;set;}
    private string caseCategory {get;set;}
    private string entitlementId {get;set;}
    private string productRequired {get;set;}
    private string forCoolSculpting{get;set;} //To check if the information is specific to CoolSculpting
    private boolean isCoolS; //To check if the case is of Cool Sculpting type
    private string recordIdCaseAttribute; //The record id for cool sculpting case attribute
    private string opportunityId {get; set;}
    public string description{get;set;}
    private List<RecordType> caseAttrRecTypeList;
    
    public Map<Id, String> recordTypeIdNameMap{get;set;} //Map to extract record type name for the passed record type id
    public string recordTypeName{get;set;}
    
    list<SObject> newRelatedLists = new list<SObject>();
    
    public AGN_CaseEditExtension(ApexPages.StandardController controller){
        
        newCase = (Case)controller.getRecord();
        
        newCaseAttribute= new Case_Attributes_for_CoolSculpting_AGN__c();
        dummyPersonAccount = new Case();
        
        accID = System.currentPageReference().getParameters().get('def_account_id');
        parentId = System.currentPageReference().getParameters().get('def_parent_id');
        caseType = System.currentPageReference().getParameters().get('caseService');
        caseReason = System.currentPageReference().getParameters().get('caseReason');
        caseStaticCategory = System.currentPageReference().getParameters().get('caseStaticCategory');
        caseCategory = System.currentPageReference().getParameters().get('caseCategory');
        recordType = System.currentPageReference().getParameters().get('recordType');
        entitlementId = System.currentPageReference().getParameters().get('entitlementId');
        productRequired = System.currentPageReference().getParameters().get('caseProduct');
        
        /* New lines of code added as a part of CoolSculpting implementation */
        forCoolSculpting=System.currentPageReference().getParameters().get('forCoolSculpting');
        opportunityId=System.currentPageReference().getParameters().get('oppId');
        isCoolS = forCoolSculpting != '' && forCoolSculpting != 'null' ? true : false;
        System.debug('forCoolSculpting'+forCoolSculpting);
        if(forCoolSculpting=='true'){
            isCoolS=true;
        }
        dummySecondaryPoC = new Case();
        /* End of lines of code added as a part of CoolSculpting implementation */
        
        String parentCaseRecordTypeName;       
        
        //prepopulate from parent case
        if (parentId != null) {
            Case parentCase = [select Id, RecordTypeId, AccountId, ContactId, Contact.AccountId, Business_Unit_AGN__c, Sales_Rep_Requester_AGN__c, SAP_Order_Code_AGN__c, Ship_To_Account_AGN__c from Case where Id =: parentId limit 1];
            newCase.AccountId = parentCase.AccountId;
            dummyPersonAccount.AccountId = parentCase.Contact.AccountId;
            newCase.Business_Unit_AGN__c = parentCase.Business_Unit_AGN__c;
            newCase.Sales_Rep_Requester_AGN__c = parentCase.Sales_Rep_Requester_AGN__c;
            newCase.Ship_To_Account_AGN__c = parentCase.Ship_To_Account_AGN__c;
            
            /* ********** R14: Following lines were included to meet the requirement 1749. Prevent copy of SAP Order Code when parent case is of type Sales Order ********** */
            parentCaseRecordTypeName = [select DeveloperName from RecordType where Id = :parentCase.RecordTypeId].DeveloperName; 
            if(parentCaseRecordTypeName != 'AGN_Order_Request_Sales_Order'){
                newCase.SAP_Order_Code_AGN__c = parentCase.SAP_Order_Code_AGN__c;                
            }
            /* ********** End of R14 changes ********** */            
            
            newCase.ParentId = parentCase.Id;
        }
        
        if(accId != null) {                
            Account acc = [select id, ispersonAccount, PersonContactId, Owner_AGN__c  from Account where id =:accID limit 1];                    
            if (acc.ispersonAccount){
                newCase.ContactId = acc.PersonContactId;                                
                dummyPersonAccount.AccountId = acc.Id;                          
            }
            else                    
                newCase.AccountId= acc.Id;
            
            newCase.Sales_Rep_Requester_AGN__c = acc.Owner_AGN__c;                                              
        }
        
        newCase.Service_AGN__c = caseType;
        newCase.Type = caseStaticCategory != 'null' ? caseStaticCategory : caseCategory;
        newCase.Reason = caseReason;
        newCase.RecordTypeId = recordType;
        newCase.EntitlementId = entitlementId;
        /* New lines of code added as a part of CoolSculpting implementation */
        newCaseAttribute.Sub_Type_CoolS_AGN__c = caseReason;
        /* End of lines of code added as a part of CoolSculpting implementation */
        
        productLineItems = new list<Case_Product_List_AGN__c>();
        caseComments = new list<AGN_CaseCommentWrapper>();
        
        //Put values in recordTypeIdNameMap
        recordTypeName= [select Name from RecordType where SObjectType = 'Case' and id = :recordType Limit 1].Name;
        
        /* New lines of code added as a part of CoolSculpting implementation */
        caseAttrRecTypeList = [select Id, Name from RecordType where SObjectType = 'Case_Attributes_for_CoolSculpting_AGN__c' and name = :recordTypeName Limit 1];
        if(caseAttrRecTypeList != null && caseAttrRecTypeList.size() > 0){
            recordIdCaseAttribute = caseAttrRecTypeList[0].Id;
        }        
        /* End of lines of code added as a part of CoolSculpting implementation */
        
        System.debug('===recordTypeName==='+recordTypeName);
    }
    
    public void copyShipToAccount() {
        
        //system.debug('inside account copy');
        if (shipToSameCheck){
           
            newCase.Ship_To_Account_AGN__c = newCase.AccountId;
        }
        else
        {
            
            newCase.Ship_To_Account_AGN__c = null; 
        }
    }
    
    
    //Added by HCO Harmonization team to copy the same SAP Sold To into SAP Ship To in case creation page for Brazil//
    public void copySAPShipTo() {
        try{
            //system.debug('inside sap copy copy');
            if (shipToSameCheck_SAP){
                Customer_Detail_AGN__c saprec = [select Id,Parent_Account_AGN__c,SAP_Sold_To_AGN__c,SAP_Ship_To_AGN__c from Customer_Detail_AGN__c where Id =:newCase.BR_Case_Creation_SAP_Sold_To_AGN__c  LIMIT 1];
                if(saprec.SAP_Ship_To_AGN__c){ 
                    newCase.BR_Case_Creation_SAP_Ship_To_AGN__c = newCase.BR_Case_Creation_SAP_Sold_To_AGN__c;
                }
                else{
                    //system.debug('in error');
                    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,System.Label.AGN_Case_Invalid_Ship_To));
                    newCase.BR_Case_Creation_SAP_Ship_To_AGN__c = newCase.BR_Case_Creation_SAP_Sold_To_AGN__c;
                }
            }
            else{
                newCase.BR_Case_Creation_SAP_Ship_To_AGN__c = null;
            }
        }
        
        catch (Exception ex)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            system.debug('@@Error => ' + ex.getMessage());
            
        }
        
    }
    //Added by HCO Harmonization team to copy the same SAP Sold To into SAP Ship To in case creation page for Brazil//
    
    
    public PageReference saveRecord(){        
        
        Savepoint sp = Database.setSavepoint();
        
        try
        {
            if (productRequired == 'true' && productLineItems.size() == 0){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CaseProductRequired);
                ApexPages.addMessage(msg);
                return null;
            }
            
            //set the PersonContactId to case contact
            if (dummyPersonAccount.AccountId <> null){
                Account personAccount = [select Id, PersonContactId from Account where Id =: dummyPersonAccount.AccountId limit 1 ];
                newCase.ContactId = personAccount.PersonContactId;
            }
            
            /* New lines of code added as a part of CoolSculpting implementation */
            if(isCoolS){
                newCase.Description=description;
                newCase.Opportunity_AGN__c = opportunityId;
                //set the PersonContactId to case Secondary Point of Contact
                if (dummySecondaryPoC.AccountId <> null){
                    Account secondaryPersonAccount = [select Id, PersonContactId from Account where Id =: dummySecondaryPoC.AccountId limit 1 ];
                    newCase.Point_of_Contact_if_other_CoolS_AGN__c = secondaryPersonAccount.PersonContactId;
                }
            }
            /* End of lines of code added as a part of CoolSculpting implementation */
            
            
            //Added by HCO team to populate the SAP related case fields//
            newCase.Sold_To_SAP_Account_AGN__c=newCase.BR_Case_Creation_SAP_Sold_To_AGN__c;
            if(newCase.BR_Case_Creation_SAP_Ship_To_AGN__c !=null){
                newCase.Ship_To_SAP_Account_AGN__c=newCase.BR_Case_Creation_SAP_Ship_To_AGN__c;
            }
            newCase.Sold_To_Account_AGN__c=newCase.Sold_To_SAP_Account_AGN__c;
            //system.debug('cool--->'+isCoolS);
            String caseRecordTypeName = [select DeveloperName from RecordType where Id = :recordType].DeveloperName;
            if(!caseRecordTypeName.toUpperCase().contains('COOLSCULPTING')){
                //system.debug('in this');
                if(newCase.BR_Case_Creation_SAP_Sold_To_AGN__c !=null)
                	newCase.AccountId= [select Id,Parent_Account_AGN__c from Customer_Detail_AGN__c where Id =:newCase.BR_Case_Creation_SAP_Sold_To_AGN__c LIMIT 1].Parent_Account_AGN__c;
                
                if(newCase.BR_Case_Creation_SAP_Ship_To_AGN__c !=null){
                    //system.debug('in if');
                    newCase.Ship_To_Account_AGN__c = [select Id,Parent_Account_AGN__c from Customer_Detail_AGN__c where Id =:newCase.BR_Case_Creation_SAP_Ship_To_AGN__c LIMIT 1].Parent_Account_AGN__c;
                    //system.debug('acc--------->'+newCase.Ship_To_Account_AGN__c);
                }
            }
            
            //Added by HCO team to populate the SAP related case fields//
            
            
            //Code added to insert case
            List<Case> newCaseList= new List<Case>();
            System.debug('---forCoolSculpting---'+isCoolS);
            newCaseList.add(newCase);
            System.debug('newCaseList : '+newCaseList);
            Database.SaveResult[] srList = Database.insert(newCaseList, false);
            System.debug('isCoolS'+isCoolS);
            
            /* New lines of code added as a part of CoolSculpting implementation */
            //Code for inserting case attribute only in case of cool sculpting
            if(isCoolS){
                if(caseAttrRecTypeList != null && caseAttrRecTypeList.size() > 0){
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully inserted case. Case ID: ' + sr.getId());
                            newCaseAttribute.Case_CoolS_AGN__c= sr.getId();
                            newCaseAttribute.RecordTypeId = recordIdCaseAttribute;
                            Insert newCaseAttribute;
                        }
                        else {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Case fields that affected this error: ' + err.getFields());
                            }
                        }
                    }                    
                }
            }
            /* End of lines of code added as a part of CoolSculpting implementation */
            
            //update related lists
            for (Case_Product_List_AGN__c p : productLineItems){
                p.Case_AGN__c = newCase.Id;
                newRelatedLists.add(p);
            }
            
            for(AGN_CaseCommentWrapper c: caseComments){
                c.comment.ParentId = newCase.Id;
                c.comment.CommentBody = c.Type + ' => ' + c.comment.CommentBody;
                newRelatedLists.add(c.comment);
            }
            
            if(internalComments != ''){        
                CaseComment newComment = new CaseComment();
                newComment.CommentBody = internalComments;
                newComment.ParentId = newCase.Id;
                newRelatedLists.add(newComment);
            }
            System.debug('newRelatedLists : '+newRelatedLists);
            //insert related lists
            insert newRelatedLists;
            /*newCase.Approval_Step_Number_AGN__c = 11;
newCase.Status = 'Pending Approval';
update newCase;
System.debug('status @@ '+newCase.Status);
Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
req.setObjectId(newCase.Id);
Approval.ProcessResult result = Approval.process(req); */
            
            PageReference retUrl = new PageReference('/' + newCase.Id);
            retUrl.setRedirect(true);
            return retUrl;
        }
        catch (DmlException e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0));
            ApexPages.addMessage(msg);
            system.debug('@@Error => ' + e.getMessage());
            Database.rollback(sp);          
            return null;
        }
        
    }
}