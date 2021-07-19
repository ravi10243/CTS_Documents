@isTest
public class AGN_CaseManagerWebServiceTest {
    
    public static testMethod void testAGNCaseManagerWebService() {
        
        Case caseObj = new Case(
            Status = 'New',
            Origin = 'Phone',
            Reason = 'Damage Product', 
            Description = 'Test Case'
        );
        
        insert caseObj;
        caseObj = [SELECT Id, caseNumber FROM Case where id = : caseObj.Id];
        
        Case_Attributes_for_CoolSculpting_AGN__c caseAttribute = new Case_Attributes_for_CoolSculpting_AGN__c(
            Case_CoolS_AGN__c = caseObj.Id,  
            Root_Cause_CoolS_AGN__c = 'rootcause',
            Inv_CoolS_AGN__c = 'inv',
            Warranty_CoolS_AGN__c = 'warranty',
            RMA_Number_CoolS_AGN__c = 'rmaNumber',                                                                        
            Complaint_Code_CoolS_AGN__c = 'complaintCode',
            Details_CoolS_AGN__c = 'details', 
            Investigator_CoolS_AGN__c = 'investigator',
            Item_Code_CoolS_AGN__c = 'itemCode',
            Serial_Number_CoolS_AGN__c = 'serialNumber',
            CoolQ_Status_CoolS_AGN__c = 'complaintStatus',                                          
            Date_Comp_Closed_CoolS_AGN__c = Date.Today(), 
            Problem_Type_CoolS_AGN__c = 'complaintClassification',
            Aware_Date_CoolS_AGN__c = System.today(),
            Event_Date_CoolS_AGN__c = System.today());
        
        insert caseAttribute;
        
        Test.startTest();
        
        String result = AGN_CaseManagerWebService.createCase(caseObj.caseNumber,'rootcause','inv','warranty', 'rmaNumber','complaintCode','details','investigator','itemCode','serialNumber','complaintStatus','','12/11/2018','complaintClassification');
        System.assertEquals('Case updated successfully', result);                
        Test.stopTest(); 
    }
    
    public static testMethod void testAGNCaseManagerWebServiceNoCase() {
        
        Case caseObj = new Case(
            Status = 'New',
            Origin = 'Phone',
            Reason = 'Damage Product', 
            Description = 'Test Case'
        );
        
        insert caseObj;
        
        Case_Attributes_for_CoolSculpting_AGN__c caseAttribute = new Case_Attributes_for_CoolSculpting_AGN__c(
            Case_CoolS_AGN__c = caseObj.Id,  
            Root_Cause_CoolS_AGN__c = 'rootcause',
            Inv_CoolS_AGN__c = 'inv',
            Warranty_CoolS_AGN__c = 'warranty',
            RMA_Number_CoolS_AGN__c = 'rmaNumber',                                                                        
            Complaint_Code_CoolS_AGN__c = 'complaintCode',
            Details_CoolS_AGN__c = 'details', 
            Investigator_CoolS_AGN__c = 'investigator',
            Item_Code_CoolS_AGN__c = 'itemCode',
            Serial_Number_CoolS_AGN__c = 'serialNumber',
            CoolQ_Status_CoolS_AGN__c = 'complaintStatus',                                          
            Date_Comp_Closed_CoolS_AGN__c = Date.Today(), 
            Problem_Type_CoolS_AGN__c = 'complaintClassification',
            Aware_Date_CoolS_AGN__c = System.today(),
            Event_Date_CoolS_AGN__c = System.today());
        
        insert caseAttribute;
        
        Test.startTest();
        
        String result = AGN_CaseManagerWebService.createCase('','rootcause','inv','warranty', 'rmaNumber','complaintCode','details','investigator','itemCode','serialNumber','complaintStatus','','12/11/2018','complaintClassification');
        System.assertEquals('No case found in salesforce', result);                
        Test.stopTest(); 
    }
    
    public static testMethod void testAGNCaseManagerWebServiceWithPRIDCase() {
        
        Case caseObj = new Case(
            Status = 'New',
            Origin = 'Phone',
            Reason = 'Damage Product', 
            Description = 'Test Case',
            PR_ID_Trackwise_AGN__c = '212458'
        );
        
        insert caseObj;
        caseObj = [SELECT Id, PR_ID_Trackwise_AGN__c FROM Case where id = : caseObj.Id];
        
        Case_Attributes_for_CoolSculpting_AGN__c caseAttribute = new Case_Attributes_for_CoolSculpting_AGN__c(
            Case_CoolS_AGN__c = caseObj.Id,  
            Root_Cause_CoolS_AGN__c = 'rootcause',
            Inv_CoolS_AGN__c = 'inv',
            Warranty_CoolS_AGN__c = 'warranty',
            RMA_Number_CoolS_AGN__c = 'rmaNumber',                                                                        
            Complaint_Code_CoolS_AGN__c = 'complaintCode',
            Details_CoolS_AGN__c = 'details', 
            Investigator_CoolS_AGN__c = 'investigator',
            Item_Code_CoolS_AGN__c = 'itemCode',
            Serial_Number_CoolS_AGN__c = 'serialNumber',
            CoolQ_Status_CoolS_AGN__c = 'complaintStatus',                                          
            Date_Comp_Closed_CoolS_AGN__c = Date.Today(), 
            Problem_Type_CoolS_AGN__c = 'complaintClassification',
            Aware_Date_CoolS_AGN__c = System.today(),
            Event_Date_CoolS_AGN__c = System.today());
        
        insert caseAttribute;
        
        Test.startTest();
        
        String result = AGN_CaseManagerWebService.createCase('','rootcause','inv','warranty', 'rmaNumber','complaintCode','details','investigator','itemCode','serialNumber','complaintStatus',caseObj.PR_ID_Trackwise_AGN__c,'12/11/2018','complaintClassification');
        System.assertEquals('Case updated successfully', result);                
        Test.stopTest(); 
    }  
   
    public static testMethod void testAGNCaseManagerWebServiceException() {
        Case caseObj = new Case(
            Status = 'New',
            Origin = 'Phone',
            Reason = 'Damage Product', 
            Description = 'Test Case',
            PR_ID_Trackwise_AGN__c = '212457'
        );
        
        insert caseObj;
        caseObj = [SELECT Id, caseNumber, PR_ID_Trackwise_AGN__c FROM Case where id = : caseObj.Id];
        
        Case_Attributes_for_CoolSculpting_AGN__c caseAttribute = new Case_Attributes_for_CoolSculpting_AGN__c(
             Case_CoolS_AGN__c = caseObj.Id,  
            Root_Cause_CoolS_AGN__c = 'rootcause',
            Inv_CoolS_AGN__c = 'inv',
            Warranty_CoolS_AGN__c = 'warranty',
            RMA_Number_CoolS_AGN__c = 'rmaNumber',                                                                        
            Complaint_Code_CoolS_AGN__c = 'complaintCode',
            Details_CoolS_AGN__c = 'details', 
            Investigator_CoolS_AGN__c = 'investigator',
            Item_Code_CoolS_AGN__c = 'itemCode',
            Serial_Number_CoolS_AGN__c = 'serialNumber',
            CoolQ_Status_CoolS_AGN__c = 'complaintStatus',                                          
            Date_Comp_Closed_CoolS_AGN__c = Date.Today(), 
            Problem_Type_CoolS_AGN__c = 'complaintClassification',
            Aware_Date_CoolS_AGN__c = System.today(),
            Event_Date_CoolS_AGN__c = System.today());
        
        insert caseAttribute;
        
        Test.startTest();
        
        String result = AGN_CaseManagerWebService.createCase(caseObj.caseNumber,'TestRootCause','TestInv','2', '123456789','TestDemo','testing','TestRest','testCase','testCaseAttri','noRun','5212','dd/mm','awwqq');
        System.assertEquals(true, result.length() > 0);
        Test.stopTest();  
    }
    
    public static testMethod void testAGNCaseManagerWebServiceCatchException() {
        Case caseObj = new Case(
            Status = 'New',
            Origin = 'Phone',
            Reason = 'Damage Product', 
            Description = 'Test Case',
            PR_ID_Trackwise_AGN__c = '212457'
        );
        
        insert caseObj;
        caseObj = [SELECT Id, caseNumber, PR_ID_Trackwise_AGN__c FROM Case where id = : caseObj.Id];
        
        Case_Attributes_for_CoolSculpting_AGN__c caseAttribute = new Case_Attributes_for_CoolSculpting_AGN__c(
             Case_CoolS_AGN__c = caseObj.Id,  
            Root_Cause_CoolS_AGN__c = 'rootcause',
            Inv_CoolS_AGN__c = 'inv',
            Warranty_CoolS_AGN__c = 'warranty',
            RMA_Number_CoolS_AGN__c = 'rmaNumber',                                                                        
            Complaint_Code_CoolS_AGN__c = 'complaintCode',
            Details_CoolS_AGN__c = 'details', 
            Investigator_CoolS_AGN__c = 'investigator',
            Item_Code_CoolS_AGN__c = 'itemCode',
            Serial_Number_CoolS_AGN__c = 'serialNumber',
            CoolQ_Status_CoolS_AGN__c = 'complaintStatus',                                          
            Date_Comp_Closed_CoolS_AGN__c = Date.Today(), 
            Problem_Type_CoolS_AGN__c = 'complaintClassification',
            Aware_Date_CoolS_AGN__c = System.today(),
            Event_Date_CoolS_AGN__c = System.today());
        
        insert caseAttribute;
        
        Test.startTest();
        
        String result = AGN_CaseManagerWebService.createCase(caseObj.caseNumber,'TestRootCause','TestInv','2', '123456789','TestDemo','testing','TestRest','testCase','testCaseAttri','noRun',caseObj.PR_ID_Trackwise_AGN__c,'ttt','awwqq');
        System.assertEquals(true, result.length() > 0);
        Test.stopTest();  
    }
}