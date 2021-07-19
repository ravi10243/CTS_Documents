/*
*---------------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Krishnendu Sadhu
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        1.0
* @created        
* @modified      15-Nov-2019
* @testClass     
* @Class Name    AGN_GDPR_Email_Verification_Controller
* -------------------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019           
* Controller for the VF Page AGN_GDPR_Email_Verification ,Landing Page when a DS Clicks on the Link recieved in the eamil
to verify his email id ,it updates the case status from Email not verified to New and update the DS Email Verifiction record.
*-------------------------------------------------------------------------------------------------------------------------------+
*/
public class AGN_GDPR_Email_Verification_Controller
{
    public string selectedLang{get;set;}
    public List<DS_Email_Verification_GDPR_AGN__c> dsEmailVerifObjList { get; set;}
    public List<Case> caseObjList { get; set; } 
    public Boolean displayPopup {get;set;}
    public List<DS_Email_Verification_GDPR_AGN__c> dsEmailList {get; set;}
    public Boolean panel1 {get;set;} // Contains First time Email Verification Message and Button to redirect on Allergan Site
    public Boolean panel2 {get;set;} // Shows message Email Already Verified on 2nd and further click on the Email Verification URL
    public Boolean panel3 {get;set;} // Shows Email Link Expired Message after Link expiration 24 hours in CCPA and Contact Center
    public Boolean panel4 {get;set;} //Shows error message in case any unhandle error occurs
    public AGN_GDPR_Email_Verification_Controller(){} // Default Constructor
    
    public void doStatusUpdate()
    {
        displayPopup = true;
		dsEmailList = [SELECT DS_Email_GDPR_AGN__c,Case_AGN__c FROM DS_Email_Verification_GDPR_AGN__c where id =: apexpages.currentpage().getparameters().get('RecordInfo')];	// Fetches the DS Email Verification Id in the URL Parameter RecordInfo
        
        if(dsEmailList.size() > 0) // Check if the parameter has a value before querying details.
        {  
            dsEmailVerifObjList = [SELECT Case_ID_GDPR_AGN__c,DS_Email_GDPR_AGN__c,Id,
                                   IsVerified_GDPR_AGN__c,Language_GDPR_AGN__c,Name,
                                   Language_Code_GDPR_AGN__c,Case_AGN__c,Case_AGN__r.Record_Type_Name_AGN__c,IsExpired_AGN__c FROM DS_Email_Verification_GDPR_AGN__c where Case_AGN__c =: dsEmailList[0].Case_AGN__c];
            
            
            if(dsEmailVerifObjList.size()>0 && dsEmailVerifObjList[0].IsVerified_GDPR_AGN__c == false && dsEmailVerifObjList[0].IsExpired_AGN__c == false)
            {
                panel1 = true;
                panel2 = false;
                panel3 = false;
                panel4 = false;
                
                selectedLang = dsEmailVerifObjList[0].Language_Code_GDPR_AGN__c;
                
                List<String> caseNumberList = new List<String>();
                for(DS_Email_Verification_GDPR_AGN__c dsEmailRecord : dsEmailVerifObjList)
                {
                    caseNumberList.add(dsEmailRecord.Case_AGN__c);
                }
                
                caseObjList = [SELECT id ,SuppliedName,status,OwnerId,RecordTypeId,RecordType.Name  from Case where Id IN :caseNumberList];
                
                List<DS_Email_Verification_GDPR_AGN__c> dsEmailVefObjList = new List<DS_Email_Verification_GDPR_AGN__c>();
                
                for(DS_Email_Verification_GDPR_AGN__c dsEmlVerifRecord : dsEmailVerifObjList)
                {
                    DS_Email_Verification_GDPR_AGN__c dsEmailObject = new DS_Email_Verification_GDPR_AGN__c();
                    dsEmailObject.Id = dsEmlVerifRecord.Id;
                    dsEmailObject.IsVerified_GDPR_AGN__c=true;
                    dsEmailVefObjList.add(dsEmailObject);
                }
                
                if(dsEmailVefObjList.size()>0)
                {
                    try
                    {
                        update dsEmailVefObjList;
                    }
                    catch(Exception e)
                    {
                        System.debug('Error occured updating DS Email Verification '+e);
                    }  
                }
                
                
                List<Group> groupTypeGDPR= [SELECT Id FROM Group WHERE Name = 'GDPR' AND Type = 'Queue' Limit 1];
                List<Group> groupTypeCCPA= [SELECT Id FROM Group WHERE Name = 'CCPA' AND Type = 'Queue' Limit 1];
                
                List<Case> caseListToUpdate = new List<Case>();
                
                for (Case csObjRecord : caseObjList)
                {
                    Case caseToUpdate = New Case();
                    if(csObjRecord.RecordType.Name=='GDPR Case' || csObjRecord.RecordType.Name=='GDPR DPO')
                    {
                        caseToUpdate.Id=csObjRecord.Id;
                        caseToUpdate.OwnerId=groupTypeGDPR[0].ID;
                        caseListToUpdate.add(caseToUpdate);
                    }
                    else if(csObjRecord.RecordType.Name=='CCPA Case'||csObjRecord.RecordType.Name=='Contact Center')
                    {
                        caseToUpdate.Id=csObjRecord.Id;
                        caseToUpdate.OwnerId=groupTypeCCPA[0].ID;
                        caseListToUpdate.add(caseToUpdate);
                    }
                    else
                    {
                        System.debug('No action needed');
                    } 
                }
                
                
                if(caseListToUpdate.size()>0)
                {
                    try
                    {
                        update caseListToUpdate;
                    }
                    catch(Exception e)
                    {
                        System.debug('Error occured updating DS Email Verification '+e);
                    }  
                }
                
                
                List<Case> caseObjList1 = new List<Case>();
                for (Case caseObjRec : caseObjList)
                {
                    Case caseToUpdate1 = New Case();
                    caseToUpdate1.Id=caseObjRec.Id;
                    caseToUpdate1.Status='New';
                    caseObjList1.add(caseToUpdate1); 
                }
                
                if(caseObjList1.size()>0)
                {
                    try
                    {
                        update caseObjList1;
                    }
                    catch(Exception e)
                    {
                        System.debug('Error occured updating DS Email Verification '+e);
                    }  
                }
            }
            
            else  if(dsEmailVerifObjList.size()>0 && dsEmailVerifObjList[0].IsVerified_GDPR_AGN__c == true && dsEmailVerifObjList[0].IsExpired_AGN__c == false)
            {
                panel1 = false;
                panel2 = true;
                panel3 = false;
                panel4 = false;
            }
            else if(dsEmailVerifObjList.size()>0 && dsEmailVerifObjList[0].IsExpired_AGN__c == true && dsEmailVerifObjList[0].IsVerified_GDPR_AGN__c == false ) 
            {
                panel1 = false;
                panel2 = false;
                panel3 = true;
                panel4 = false;
            }
            
            else // Unhandle exception
            {
                panel1 = false;
                panel2 = false;
                panel3 = false;
                panel4 = true;  
            }
        }
        else // Unhandle exception
        {
            panel1 = false;
            panel2 = false;
            panel3 = false;
            panel4 = true;
            
        }
    }
    
    public PageReference redirectToPage()
    {
        PageReference pageRef;
        dsEmailVerifObjList = [SELECT Case_ID_GDPR_AGN__c,DS_Email_GDPR_AGN__c,Id,IsVerified_GDPR_AGN__c,Language_GDPR_AGN__c,Name,Language_Code_GDPR_AGN__c,Case_AGN__c FROM DS_Email_Verification_GDPR_AGN__c where id =: apexpages.currentpage().getparameters().get('RecordInfo') ];
        
        if(dsEmailVerifObjList.size() > 0)
        { 
            caseObjList = [SELECT id ,SuppliedName,status,OwnerId,RecordTypeId,RecordType.Name  from Case where Id=: dsEmailVerifObjList[0].Case_AGN__c];
            
            if(caseObjList.size()> 0)
            {
                if(caseObjList[0].RecordType.Name=='GDPR Case' || caseObjList[0].RecordType.Name=='GDPR DPO')
                {
                    AGN_GDPR_LoginExtension__c loginExtensionCustomSetting = AGN_GDPR_LoginExtension__c.getAll().values();                   
                    displayPopup = false;
                    pageRef = new PageReference(loginExtensionCustomSetting.GDPR_Page_Refernce__c);
                    pageRef.setRedirect(true);  
                }
                else if(caseObjList[0].RecordType.Name=='CCPA Case'||caseObjList[0].RecordType.Name=='Contact Center')
                {
                    AGN_GDPR_LoginExtension__c loginExtensionCustomSetting = AGN_GDPR_LoginExtension__c.getAll().values();  
                    displayPopup = false;
                    pageRef = new PageReference(loginExtensionCustomSetting.CCPA_Page_Refernce__c);
                    pageRef.setRedirect(true);
                }
            }  
            else // Unhandled Exception with No redirection
            {
                displayPopup = true;
                panel1 = false;
                panel2 = false;
                panel3 = false;
                panel4 = true;
                pageRef.setRedirect(false);
            } 
        }
        return pageRef; 
    }
}