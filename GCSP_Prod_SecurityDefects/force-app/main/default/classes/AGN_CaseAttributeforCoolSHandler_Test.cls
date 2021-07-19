@isTest
public class AGN_CaseAttributeforCoolSHandler_Test {
    
    @isTest
    public static void testCoolSAtrributeUpdate(){
        
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        
        Case cs = new case(PR_ID_Trackwise_AGN__c = 'INT-000012');
        Insert cs;
        Case_Attributes_for_CoolSculpting_AGN__c caseAtt = new Case_Attributes_for_CoolSculpting_AGN__c(); 
        caseAtt.Case_CoolS_AGN__c = cs.id;
        caseAtt.Aware_Date_CoolS_AGN__c = Date.today();
        caseAtt.Event_Date_CoolS_AGN__c = Date.today();
        //caseAtt.Sub_Type_CoolS_AGN__c = 'CoolScuplting';
        caseAtt.Reported_Serial_Number_CoolS_AGN__c = '10291';
        caseAtt.SAP_CoolS_AGN__c = '1234567890';
        Insert caseAtt;
        
        Test.startTest();
        System.runAs(AdminUser){
            
            Map<Id,Case_Attributes_for_CoolSculpting_AGN__c> oldMap = new Map<Id,Case_Attributes_for_CoolSculpting_AGN__c>();
            oldMap.put(caseAtt.id,caseAtt);
            
            Case_Attributes_for_CoolSculpting_AGN__c caseAttUpdate = [Select Id,Case_CoolS_AGN__c,Aware_Date_CoolS_AGN__c,Event_Date_CoolS_AGN__c,Sub_Type_CoolS_AGN__c,Reported_Serial_Number_CoolS_AGN__c,SAP_CoolS_AGN__c 
                                                                      from Case_Attributes_for_CoolSculpting_AGN__c where Id =:caseAtt.id];
            caseAttUpdate.Aware_Date_CoolS_AGN__c = Date.today() - 1;
            caseAttUpdate.Event_Date_CoolS_AGN__c = Date.today() - 1;
            //caseAttUpdate.Sub_Type_CoolS_AGN__c = 'N/A';
            caseAttUpdate.Reported_Serial_Number_CoolS_AGN__c = '283712';
            caseAttUpdate.SAP_CoolS_AGN__c = '1234567891';
            
            //Update caseAttUpdate;
            List<Case_Attributes_for_CoolSculpting_AGN__c> caList = new List<Case_Attributes_for_CoolSculpting_AGN__c>();
            caList.add(caseAttUpdate);
            Update caList;
            
            
            AGN_CaseAttributeforCoolSculptingHandler excute = new AGN_CaseAttributeforCoolSculptingHandler();
            excute.executeCaseAttributeforCoolSculptingHandler(caList,oldMap);
            
            Case cas = [Select Aware_Date_CoolS_AGN__c,Event_Date_CoolS_AGN__c,Reported_Serial_Number_CoolS_AGN__c,SAP_Call_ID_CoolS_AGN__c From Case where Id =:cs.id];
            System.assertEquals(cas.Aware_Date_CoolS_AGN__c,Date.today() - 1);
            System.assertEquals(cas.Event_Date_CoolS_AGN__c,Date.today() - 1);
            System.assertEquals(cas.Reported_Serial_Number_CoolS_AGN__c,'283712');
            System.assertEquals(cas.SAP_Call_ID_CoolS_AGN__c,'1234567891');
            
        }
        Test.stopTest();
    }
    
}