@isTest
public class F3_LEXCaseTest {
    public static  LEXForm__c lexForm1;
    public static Case caseRecord;
    
    
    @isTest 
    public static void setUpTestData() {
        // code_block
        caseRecord=new Case();
        caseRecord.Status='Open';
        caseRecord.Origin='Email';
        caseRecord.MetadataDeveloperName__c='abcdef';
        insert caseRecord;
        
        lexForm1=new LEXForm__c();
        lexForm1.Case__c=caseRecord.Id;
        lexForm1.Sort_Order__c=5;
        insert lexForm1;
    }
    @isTest 
    public static void F3_LEXCaseTest(){
        setUpTestData();
        Test.startTest();
        F3_LEXCase.doGetLEXForms(caseRecord.Id);
        F3_LEXCase.doGetLEXFormSteps(lexForm1.Id);
        
        
        
        Test.stopTest();
        
        
    }
}