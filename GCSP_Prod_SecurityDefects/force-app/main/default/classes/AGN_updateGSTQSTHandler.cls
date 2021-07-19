public with sharing class AGN_updateGSTQSTHandler {
    
    List<Id> shipIds = new List<Id>();
    Map<id,String> shipAddress = new Map<id,String>();
    List<String> states = new List<String>();
    List<Province_AGN__c> taxValues;
    Map<String,Province_AGN__c> province= new  Map<String,Province_AGN__c>();
    List<Id> shipIdsOld = new List<Id>();
    Map<id,String> addressOld = new Map<id,String>();
    List<Opportunity> newRecords;
    Map<Id,Opportunity> oldMap;
    
    /*public updateGSTQSTHandler(List<Opportunity> newRecords, Map<Id,Opportunity> oldMap)
    {
       this.newRecords =newRecords;
       this.oldMap =oldMap;
       runTrigger();
    } */
     
    public void runTrigger(List<Opportunity> newRecords, Map<Id,Sobject> oldMap1)
    {
        Map<Id,Opportunity> oldMap = (Map<Id,Opportunity>) oldMap1;
        System.debug('oldMap: '+oldMap);
        System.debug('newRecords: '+newRecords);
    for(Opportunity opp: newRecords)
    {
         if(Trigger.isUpdate)
        {
         Opportunity oppOld = oldMap.get(opp.Id);
         shipIdsOld.add(oppOld.Shipping_Address_AGN__c);   
        }
        
       if(Trigger.isInsert || Trigger.isUpdate)
       shipIds.add(opp.Shipping_Address_AGN__c);
    }
  
    for(Address_vod__c add: [Select id,toLabel(State_vod__c) from Address_vod__c where Id IN :shipIds])
    {
        shipAddress.put(add.id,add.State_vod__c);
    }
    System.debug('new Add: '+shipAddress);
    for(Province_AGN__c pro: [select Province_Code_AGN__c,QST_PST_PRC_AGN__c,GST_HST_PRC_AGN__c from Province_AGN__c where Province_Code_AGN__c IN :shipAddress.values()])
    {
        province.put(pro.Province_Code_AGN__c,pro);
    }
    System.debug('Province_Code_AGN__c: '+province);
    if(Trigger.isUpdate)
    {

     for(Address_vod__c add: [Select id,toLabel(State_vod__c) from Address_vod__c where Id IN :shipIdsOld])
    {
      addressOld.put(add.id,add.State_vod__c);
    }
    System.debug('Old Add: '+addressOld);
    }
  
    for(Opportunity opp: newRecords)
    {
        
        if(Trigger.isUpdate)
        {
            System.debug('Update Trigger');
            Opportunity oppOld = oldMap.get(opp.Id);
            
            if(addressOld.containsKey(oppOld.Shipping_Address_AGN__c))
            {
                String stateCodeOld;
                String stateNew;
                if(oppOld.Shipping_Address_AGN__c != opp.Shipping_Address_AGN__c)
                {
                  System.debug('Ship address has changed');
                  stateCodeOld = addressOld.get(oppOld.Shipping_Address_AGN__c);
                  stateNew = shipAddress.get(opp.Shipping_Address_AGN__c); 
                }
                else
                {
                  System.debug('Ship address is same');
                  stateCodeOld = opp.shipProvince_AGN__c;
                  stateNew = shipAddress.get(opp.Shipping_Address_AGN__c); 
                  System.debug('Old State code: '+stateCodeOld);
                }
                if(stateCodeOld != stateNew)
                {
                    System.debug('Old and new state code is different');
                    opp.shipProvince_AGN__c = stateNew;
                if(province.containsKey(stateNew))
                {
                  Province_AGN__c pro1 = province.get(stateNew);
                  opp.GST_HST_PRC_AGN__c = pro1.GST_HST_PRC_AGN__c;
                  opp.QST_PST_PRC_AGN__c = pro1.QST_PST_PRC_AGN__c;      
                }
                else
                {
                opp.GST_HST_PRC_AGN__c = 0;
                opp.QST_PST_PRC_AGN__c = 0;
                }
                }
             }
        }
       
        if(Trigger.isInsert)
        {
        System.debug('Insert Trigger');
        if(shipAddress.containsKey(opp.Shipping_Address_AGN__c))
        {
            String stateCode = shipAddress.get(opp.Shipping_Address_AGN__c);
            opp.shipProvince_AGN__c = stateCode;
            if(province.containsKey(stateCode))
            {
                Province_AGN__c pro1 = province.get(stateCode);
                opp.GST_HST_PRC_AGN__c = pro1.GST_HST_PRC_AGN__c;
                opp.QST_PST_PRC_AGN__c = pro1.QST_PST_PRC_AGN__c; 
            }
            else               
            {
                opp.GST_HST_PRC_AGN__c = 0;
                opp.QST_PST_PRC_AGN__c = 0;
                
            }
        }
        }
        
    } 
      
    }
}