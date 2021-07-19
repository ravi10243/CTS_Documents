/*
*---------------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev Roushan
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        1.0
* @created        
* @modified      19-Feb-2020
* @testClass     
* @Class Name    ExtendCase_AGN_controller
* -------------------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019           
*  Apex Controller to the Aura Component ExtendCase which is used as a Quick Action to drive Extend case functionality on Case. 
*-------------------------------------------------------------------------------------------------------------------------------+
*/
public class ExtendCase_AGN_controller {
    //Wrapper class to send a Wrapped response for the doInit to check the Data and decision parameter.
    public class WrapClass
    {
        @AuraEnabled
        public String response{get;set;}
        @AuraEnabled
        public String provideReason{get;set;}
        @AuraEnabled
        public String DSLanguage{get;set;}
        
    }
    //Method used to fetch the Status of the Case and fetch the Language of the Data Subject.
    @AuraEnabled
    public static WrapClass getTextValues(Id caseId) 
    {
        WrapClass wrapclassInstance = new WrapClass();
        List<Case> caseList = New List<Case>();
        String caseLabel;
        
        if(caseId != null)
        { 
            //Query to fetch different parameters of the Associated Case.
            caseList = [Select Id,Rejection_Reason_AGN__c,Record_Type_Name_AGN__c,
                        RecordType.DeveloperName,RejectCase_AGN__c,DS_Selected_Language_GDPR_AGN__c,Extended_GDPR_AGN__c,
                        Status from Case where Id= :caseId];
        }

        //Checking if List is Blank or not
        if(caseList.size()>0)
        {    
            // Assigning wrapper classVariable value of DS Language
            wrapclassInstance.DSLanguage =caseList[0].DS_Selected_Language_GDPR_AGN__c;
            
            if(caseList[0].Status == 'Closed' || caseList[0].Status == 'Task Completed')
            {
                wrapclassInstance.response = 'statusError';
            }
            else if(caseList[0].Extended_GDPR_AGN__c == True)
            {
                wrapclassInstance.response = 'alreadyExtended';
            }
            else
            {
                wrapclassInstance.response = 'extend';
            }
            
            Map<string,AGN_GDPR_Language_Settings__c> languageCustomSetting = AGN_GDPR_Language_Settings__c.getAll();
            String LangCode = languageCustomSetting.get(caseList[0].DS_Selected_Language_GDPR_AGN__c).Language_Code_AGN__c;
            
            
            if(caseList[0].Record_Type_Name_AGN__c =='CCPA_Case' || caseList[0].Record_Type_Name_AGN__c =='Contact_Center_AGN')
            {
                caseLabel = 'CCPA_Case_Extend_Reason_AGN';
				                
                List<ExternalString> extrernalStringObj = new List<ExternalString>();
                extrernalStringObj = [SELECT Id,Language,Name,Value FROM ExternalString where Name = :caseLabel];
                
                List<ExternalStringLocalization> exteranStringLocalisationObj = new List<ExternalStringLocalization>();
                exteranStringLocalisationObj = [SELECT ExternalStringId,Id,Language,Value FROM ExternalStringLocalization WHERE ExternalStringId = :extrernalStringObj[0].Id and Language = :LangCode];
                
                if(caseList[0].DS_Selected_Language_GDPR_AGN__c == 'English')
                {
                    wrapclassInstance.provideReason = extrernalStringObj[0].Value;
                }
                else 
                {
                    if(exteranStringLocalisationObj.size()>0)
                    {
                        wrapclassInstance.provideReason = exteranStringLocalisationObj[0].Value; 
                    }
                }
            }
            else
            {
                wrapclassInstance.provideReason =null;
            }
            return wrapclassInstance;    
        }
        else
        {
            wrapclassInstance.response ='statusError';
            return wrapclassInstance;
        }
    }
    
    //method called when DS clicks on the Extend Case Button on Controller
    @AuraEnabled
    public static boolean getextendCase(Id caseId,String text) 
    {
        String caseLabel;
        String caseLabel1;
        String caseLabelSubj;
        
        String extendReason = text.trim();
        extendReason = extendReason.replaceAll('(\\s+)', ' ');
        System.debug('Extension Reason after triming and space charachter removal '+extendReason);
        if(extendReason == null || String.isBlank(extendReason))
        {
            return false;
        }
        else
        {
            List<Case> caseObjList = New List<Case>(); 
            if(caseId != null)
            {
                caseObjList = [Select Id,Rejection_Reason_AGN__c,Record_Type_Name_AGN__c,
                           RecordType.DeveloperName,RejectCase_AGN__c,DS_Selected_Language_GDPR_AGN__c,Extended_GDPR_AGN__c,Data_Subject_Email_GDPR_AGN__c,
                           Status,First_Name_GDPR_AGN__c,Last_Name_GDPR_AGN__c,CCPA_Case_Extended_Date_AGN__c,CreatedDate,Date_recieved_AGN_GDPR__c from Case where Id= :caseId];                
            }
 
            Map<string,AGN_GDPR_Language_Settings__c> languageCustomSetting = AGN_GDPR_Language_Settings__c.getAll();
            String LangCode = languageCustomSetting.get(caseObjList[0].DS_Selected_Language_GDPR_AGN__c).Language_Code_AGN__c;
            
            if(caseObjList[0].Record_Type_Name_AGN__c =='CCPA_Case' || caseObjList[0].Record_Type_Name_AGN__c =='Contact_Center_AGN')
            {   
                AGN_GDPR_LoginExtension__c loginExtensionCustomSetting = AGN_GDPR_LoginExtension__c.getAll().values();
                Decimal days = loginExtensionCustomSetting.AGN_CCPA_Case_Extend_Number__c;
                
                Integer intConvertedValue = days.intValue();
                System.debug('Days to extend CCPA '+intConvertedValue);
                
                DateTime dT = caseObjList[0].CreatedDate; 
                DateTime extendedDate = dT.addDays(intConvertedValue); 
                System.debug('Extended New Date '+extendedDate);
                
                Integer dd = extendedDate.day();
                Integer mo = extendedDate.month();
                Integer yr = extendedDate.year();
                
                DateTime DT1 = DateTime.newInstance(yr, mo, dd);
                
                String dateOutput = DT1.format('MM/dd/yyyy');
                
                Case caseObject = new Case();
                caseObject.Id = caseId;
                caseObject.Provide_Reason_for_Case_Ext_GDPR_AGN__c = text+' '+dateOutput;
                caseObject.Extended_GDPR_AGN__c = true;
                caseObject.Send_Email_Check_for_Case_extension_AGN__c = false;
                caseObject.Expected_Case_Close_Date_Time_AGN__c = extendedDate;
                try
                {
                    Update caseObject;  
                }
                catch(DmlException e)
                {   
                    System.debug('An unexpected error has occurred : ' + e.getMessage());   
                }   
                
                
                External_Email_Communication_GDPR_AGN__c externalEmailObj = new External_Email_Communication_GDPR_AGN__c();
                externalEmailObj.Associated_Case_GDPR_AGN__c= caseId;
                externalEmailObj.Email_Sent_To__c=caseObjList[0].Data_Subject_Email_GDPR_AGN__c;
                externalEmailObj.Email_From_GDPR_AGN__c='System Owner';
                externalEmailObj.Email_Subject_GDPR_AGN__c = System.Label.CCPA_Case_Subject_Reason_AGN;
                externalEmailObj.Email_Body_GDPR_AGN__c=caseObject.Provide_Reason_for_Case_Ext_GDPR_AGN__c;
                
                try
                {
                    insert externalEmailObj;
                }
                catch(DmlException e)
                {   
                    System.debug('An unexpected error has occurred External Email Communication: ' + e.getMessage());   
                }        
                
            }
            else if(caseObjList[0].Record_Type_Name_AGN__c =='GDPR_Case' || caseObjList[0].Record_Type_Name_AGN__c =='GDPR_DPO')
            {
                caseLabel = 'GDPR_Case_Extend_Reason_AGN';
                caseLabel1 = 'GDPR_Case_Extend_Reason1_AGN';
                caseLabelSubj ='GDPR_Case_Extend_Subject_AGN';
                
                // Body Custom Label Fetch
                List<ExternalString> externalStringObjList = new List<ExternalString>();
                externalStringObjList = [SELECT Id,Language,Name,Value FROM ExternalString where Name = :caseLabel];
                
                List<ExternalStringLocalization> externalStringLocalisationList = new List<ExternalStringLocalization>();
                externalStringLocalisationList = [SELECT ExternalStringId,Id,Language,Value FROM ExternalStringLocalization WHERE ExternalStringId = :externalStringObjList[0].Id and Language = :LangCode];
                
                // Body2 Custom Label Fetch
                List<ExternalString> externalStringObjList1 = new List<ExternalString>();
                externalStringObjList1 = [SELECT Id,Language,Name,Value FROM ExternalString where Name = :caseLabel1];
                
                List<ExternalStringLocalization> externalStringLocalisationList1 = new List<ExternalStringLocalization>();
                externalStringLocalisationList1 = [SELECT ExternalStringId,Id,Language,Value FROM ExternalStringLocalization WHERE ExternalStringId = :externalStringObjList1[0].Id and Language = :LangCode];
                
                // Subject Custom Label Fetch
                List<ExternalString> externalStringObjList2 = new List<ExternalString>();
                externalStringObjList2 = [SELECT Id,Language,Name,Value FROM ExternalString where Name = :caseLabelSubj];
                
                List<ExternalStringLocalization> externalStringLocalisationList2 = new List<ExternalStringLocalization>();
                externalStringLocalisationList2 = [SELECT ExternalStringId,Id,Language,Value FROM ExternalStringLocalization WHERE ExternalStringId = :externalStringObjList2[0].Id and Language = :LangCode];
                
                
                AGN_GDPR_LoginExtension__c loginExtensionCustomSetting = AGN_GDPR_LoginExtension__c.getAll().values();
                Decimal days = loginExtensionCustomSetting.AGN_GDPR_Case_Extend_Number__c;
                
                Integer intConvertedValue = days.intValue();
                System.debug('Days to extend GDPR '+intConvertedValue);

                if(caseObjList[0].DS_Selected_Language_GDPR_AGN__c == 'English')
                {  
                    
                    Case caseObj = new Case();
                    caseObj.Id = caseId;
                    caseObj.Provide_Reason_for_Case_Ext_GDPR_AGN__c = text;
                    caseObj.Extended_GDPR_AGN__c = true;
                    caseObj.Send_Email_Check_for_Case_extension_AGN__c = false;
                    
                    DateTime dT;
                    if(caseObjList[0].Date_recieved_AGN_GDPR__c == null)
                    {
                        dT= caseObjList[0].CreatedDate;
                    }
                    else
                    {
                        dT = caseObjList[0].Date_recieved_AGN_GDPR__c;  
                    }
  
                    DateTime extendedDate = dT.addDays(intConvertedValue); 
                    System.debug('Extended New Date '+extendedDate);
                    caseObj.Expected_Case_Close_Date_Time_AGN__c = extendedDate;
                    
                    try
                    {
                        Update caseObj;  
                    }
                    catch(DmlException e)
                    {   
                        System.debug('An unexpected error has occurred : ' + e.getMessage());   
                    }   
                    
                    External_Email_Communication_GDPR_AGN__c externalEmailObj = new External_Email_Communication_GDPR_AGN__c();
                    externalEmailObj.Associated_Case_GDPR_AGN__c= caseId;
                    externalEmailObj.Email_Sent_To__c=caseObjList[0].Data_Subject_Email_GDPR_AGN__c;
                    externalEmailObj.Email_From_GDPR_AGN__c='System Owner';
                    externalEmailObj.Email_Body_GDPR_AGN__c=externalStringObjList[0].Value+' '+text+' '+externalStringObjList1[0].Value;
                    externalEmailObj.Email_Subject_GDPR_AGN__c = externalStringObjList2[0].Value;
                    
                    try
                    {
                        insert externalEmailObj;
                    }
                    catch(DmlException e)
                    {   
                        System.debug('An unexpected error has occurred External Email Communication: ' + e.getMessage());   
                    }         
                }
                else
                {
                    if(externalStringLocalisationList.size()>0 && externalStringLocalisationList1.size()>0 && externalStringLocalisationList2.size()>0)
                    { 
                        Case caseObj = new Case();
                        caseObj.Id = caseId;
                        caseObj.Provide_Reason_for_Case_Ext_GDPR_AGN__c = text;
                        caseObj.Extended_GDPR_AGN__c = true;
                        caseObj.Send_Email_Check_for_Case_extension_AGN__c = false;
                        
                        DateTime dT;
                        if(caseObjList[0].Date_recieved_AGN_GDPR__c == null)
                        {
                            dT= caseObjList[0].CreatedDate;
                        }
                        else
                        {
                            dT = caseObjList[0].Date_recieved_AGN_GDPR__c;  
                        }
                       
                        DateTime extendedDate = dT.addDays(intConvertedValue); 
                        System.debug('Extended New Date '+extendedDate);
                        caseObj.Expected_Case_Close_Date_Time_AGN__c = extendedDate;
                        
                        try
                        {
                            Update caseObj;  
                        }
                        catch(DmlException e)
                        {   
                            System.debug('An unexpected error has occurred : ' + e.getMessage());   
                        }   
                        
                        External_Email_Communication_GDPR_AGN__c externalEmailObj = new External_Email_Communication_GDPR_AGN__c();
                        externalEmailObj.Associated_Case_GDPR_AGN__c= caseId;
                        externalEmailObj.Email_Sent_To__c=caseObjList[0].Data_Subject_Email_GDPR_AGN__c;
                        externalEmailObj.Email_From_GDPR_AGN__c='System Owner';
                        externalEmailObj.Email_Body_GDPR_AGN__c=externalStringLocalisationList[0].Value+' '+text+' '+externalStringLocalisationList1[0].Value;
                        externalEmailObj.Email_Subject_GDPR_AGN__c = externalStringLocalisationList2[0].Value;
                        
                        try
                        {
                            insert externalEmailObj;
                            checkCase(caseObjList[0].Id);
                        }
                        catch(DmlException e)
                        {   
                            System.debug('An unexpected error has occurred External Email Communication: ' + e.getMessage());   
                        }         
                    }
                    else
                    {
                        System.debug('Check Custom Label must have corresponding values');   
                    }
                }
            } 
            return true;
        }
    }   
    @future
    public static void checkCase(ID caseId)
    {
        if(caseId != null)
        {
            Case caseObj = new Case();
            caseObj.Id = caseId;
            caseObj.Send_Email_Check_for_Case_extension_AGN__c = true;
            try
            {
                Update caseObj;                
            }
            catch(DmlException e)
            {   
                System.debug('An unexpected error has occurred External Email Communication: ' + e.getMessage());   
            }           
        } 
    }
}