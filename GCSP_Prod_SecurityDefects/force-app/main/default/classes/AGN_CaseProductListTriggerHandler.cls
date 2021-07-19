/*
Type Name: AGN_CaseProductListTriggerHandler
Reason: Utility class for Case product line items Trigger methods.
11-09-2016 - SG - Set approver value for default pricelist validation for orders.
*/

public with sharing class AGN_CaseProductListTriggerHandler {

   
    public static void searchManagers(List<Case_Product_List_AGN__c> newTrigger){
        
        set<ID> caseIDList = new set<ID>();
        map<ID,String> caseApprovaerMap = new map<ID,String>();
        
        
        list<Case_Product_List_AGN__c> allProductList = new list<Case_Product_List_AGN__c>();
        list<Case> caseUpdateList = new list<Case>();
        
        
        //new products
        for(Case_Product_List_AGN__c cpl : newTrigger) {
            
            caseIDList.add(cpl.Case_AGN__c);
            allProductList.add(cpl);                                  
        }
   
       
      
        //get all existing products for edit record
        for (Case_Product_List_AGN__c cpl :  [select Case_AGN__r.recordtype.name,Case_AGN__c ,id,SAP_Approver_AGN__c from Case_Product_List_AGN__c where Case_AGN__c IN:caseIDList]){
            allProductList.add(cpl);
        }
          
         string[] rectypename= System.Label.CaseApproverCopy.split(',');
        for (Case_Product_List_AGN__c cpl : allProductList){
        
          
            for(string s: rectypename) {
            
              system.debug('*********************'+s);
              
             if(cpl.Case_AGN__r.recordtype.name!=null && s.equals(cpl.Case_AGN__r.recordtype.name))
                 {
            
             if(cpl.SAP_Approver_AGN__c!=null && cpl.SAP_Approver_AGN__c.containsIgnoreCase('National')){                    
                    caseApprovaerMap.put(cpl.Case_AGN__c, 'NM');                
                }                
             else if(cpl.SAP_Approver_AGN__c!=null && cpl.SAP_Approver_AGN__c.containsIgnoreCase('District')){
                  if (!caseApprovaerMap.containsKey(cpl.Case_AGN__c))
                     caseApprovaerMap.put(cpl.Case_AGN__c, 'DM');
              else if (caseApprovaerMap.get(cpl.Case_AGN__c) == 'NONE')
                    caseApprovaerMap.put(cpl.Case_AGN__c, 'DM');
            }               
            else if (cpl.SAP_Approver_AGN__c==null || cpl.SAP_Approver_AGN__c=='' ){
                if (!caseApprovaerMap.containsKey(cpl.Case_AGN__c))
                    caseApprovaerMap.put(cpl.Case_AGN__c, 'NONE');               
            }
        }
        else
        continue;
         }
        }
        
        for (Id caseId : caseApprovaerMap.keySet()){
            Case caseRecord = new Case (Id = caseId);
            caseRecord.Approver_AGN__c = caseApprovaerMap.get(caseId);
            caseUpdateList.add(caseRecord);
        }
        
        if(caseUpdateList.size()>0 && caseUpdateList!=null)
        update caseUpdateList;
              

    }
}