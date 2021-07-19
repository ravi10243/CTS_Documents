/*****************************************************************************************************
* @Author: Cognizant Team 
* @Class Name: AGN_CaseAttributeforCoolSculptingHandler
* @Description: Handler class for Case_Attributes_for_CoolSculpting_AGN__c Trigger 
                
*******************************************************************************************************/

public class AGN_CaseAttributeforCoolSculptingHandler {
    
    public void executeCaseAttributeforCoolSculptingHandler(List<Case_Attributes_for_CoolSculpting_AGN__c> newCaseAList, Map<Id,Case_Attributes_for_CoolSculpting_AGN__c> oldCaseAMap){
            
        List<Case> caseList = new List<Case>();
        Set<Id> caseIds = new Set<Id>();
       
       try{ 
        for(Case_Attributes_for_CoolSculpting_AGN__c newCaseA : newCaseAList){
            caseIds.add(newCaseA.Case_CoolS_AGN__c);
        }
        
        if(!CaseIds.isEmpty()){
            caseList = [Select Id,Aware_Date_CoolS_AGN__c,Event_Date_CoolS_AGN__c,Sub_Type_CoolS_AGN__c,Reported_Serial_Number_CoolS_AGN__c,SAP_Call_ID_CoolS_AGN__c,PR_ID_Trackwise_AGN__c From Case where id in : caseIds];
        }
        
        Map<Id,Case> caseMap = new Map<Id,Case>();
        for(Case cs : caseList){
            caseMap.put(cs.id,cs);
        }
        
        List<Case> updateCaseList = new List<Case>();
        for(Case_Attributes_for_CoolSculpting_AGN__c newCaseA : newCaseAList){
           Boolean flag = false;
           if(caseMap.containsKey(newCaseA.Case_CoolS_AGN__c)){
            Case parentcase = caseMap.get(newCaseA.Case_CoolS_AGN__c);
            Case_Attributes_for_CoolSculpting_AGN__c oldCaseA = oldCaseAMap.get(newCaseA.Id);
                
          if(String.isNotBlank(parentcase.PR_ID_Trackwise_AGN__c)){
            
            if(oldCaseA.Aware_Date_CoolS_AGN__c != newCaseA.Aware_Date_CoolS_AGN__c){
               if(Schema.sObjectType.Case.fields.Aware_Date_CoolS_AGN__c.isUpdateable()){
                 parentcase.Aware_Date_CoolS_AGN__c = newCaseA.Aware_Date_CoolS_AGN__c;
                 flag = true;
               }
            }
  
            if(oldCaseA.Event_Date_CoolS_AGN__c != newCaseA.Event_Date_CoolS_AGN__c){
             if(Schema.sObjectType.Case.fields.Event_Date_CoolS_AGN__c.isUpdateable()){
               parentcase.Event_Date_CoolS_AGN__c = newCaseA.Event_Date_CoolS_AGN__c;
               flag = true;
             }
            }
                
             /*if(oldCaseA.Sub_Type_CoolS_AGN__c != newCaseA.Sub_Type_CoolS_AGN__c){
               parentcase.Sub_Type_CoolS_AGN__c = newCaseA.Sub_Type_CoolS_AGN__c;
            }*/
            
            if(oldCaseA.Reported_Serial_Number_CoolS_AGN__c != newCaseA.Reported_Serial_Number_CoolS_AGN__c){
             if(Schema.sObjectType.Case.fields.Reported_Serial_Number_CoolS_AGN__c.isUpdateable()){
               parentcase.Reported_Serial_Number_CoolS_AGN__c = newCaseA.Reported_Serial_Number_CoolS_AGN__c;
               flag = true;
             }
            }
                
             if(oldCaseA.SAP_CoolS_AGN__c != newCaseA.SAP_CoolS_AGN__c){
              if(Schema.sObjectType.Case.fields.SAP_Call_ID_CoolS_AGN__c.isUpdateable()){
               parentcase.SAP_Call_ID_CoolS_AGN__c = newCaseA.SAP_CoolS_AGN__c;
               flag = true;
              }
            }
              
             if(flag){   
               updateCaseList.add(parentcase);
             }
          }
        }
      }
        
        if(!updateCaseList.isEmpty()){
            Update updateCaseList;
        }  
    }catch (Exception ex){
      System.debug('####Exception Message####'+ex.getMessage());
    }
        
   }
}