/**
 * This class is the driver class for the after insert Opportunities trigger.
 * This class receives a list of opportunities and filters them if they do not
 * have a pricebook2id. Then the class will pull out the pricebook2ids and
 * the currency codes off the opportunity. Then query for all pricebookentrys
 * based on the pricebookids, the currencycodes and if the products associated
 * are have the default_system_product set to true. Then opportunity line items
 * are created for each pricebookentry found.
 */
public with sharing class AGN_OppLineItemsHelper {
    
    public Map<String, String> oppRecordTypeIdMap;  
    
    public AGN_OppLineItemsHelper(){
        oppRecordTypeIdMap = new Map<String, String>();
        Map<Id, RecordType> oppRecordTypes = new Map<Id, RecordType>();
        
        oppRecordTypes = AGN_RecordTypes.getOppRecordTypes('Opportunity');
          if(oppRecordTypes != null && oppRecordTypes.size() > 0){
              for(RecordType rt : oppRecordTypes.values()){
                  oppRecordTypeIdMap.put(rt.Developername, rt.Id);
              }
          }
    }
     /**
     * This method is called from the after insert part of the trigger
     *
     * @param opportunities The list of opportunities coming from the trigger
     */
    public void afterInsert(Opportunity[] opportunities){
        Opportunity[] filtered = new Opportunity[0];
        for(Opportunity opportunity : opportunities){
            if(opportunity.Pricebook2Id != null &&
               (opportunity.RecordTypeId != null && (oppRecordTypeIdMap != null && oppRecordTypeIdMap.size() > 0) &&
                (opportunity.RecordTypeId == oppRecordTypeIdMap.get('AM_with_MSA_AGN') ||
                 opportunity.RecordTypeId == oppRecordTypeIdMap.get('AM_without_MSA_AGN')))){
                filtered.add(opportunity);
            }
        }
        if(!filtered.isEmpty()){
            insertLineItems(filtered);
        }
    }

    /**
     * This method gathers all the data to query for pricebookentrys and
     * to create opportunityLineitems.
     *
     * @param opportunities     the filtered opportunities received from the trigger
     */
   @TestVisible private void insertLineItems(Opportunity[] opportunities){
        Set<id> pricebookIds = AGN_OpportunityUtility.extractIds(opportunities, 'Pricebook2Id');
        Set<String> currencyCodes = AGN_OpportunityUtility.extractStrings(opportunities, 'CurrencyISOCode');
        Map<Id, PricebookEntry[]> pbeMap = getPbeMap(pricebookIds, currencyCodes);
        OpportunityLineItem[] newLineItems = new OpportunityLineItem[0];
        for(Opportunity opportunity : opportunities){
            PricebookEntry[] results = pbeMap.get(opportunity.Pricebook2Id);
            if(results != null){
                newLineItems.addAll(createLineItems(results, opportunity));
            }
        }
        //AG CC
        if (Schema.sObjectType.OpportunityLineItem.isCreateable()){
            insert newLineItems;
            }
    }

    /**
     * This method creates the line items for insertion and association to the
     * the incoming opportunity.
     *
     * @param pbes      the list of pricebookentry queried from data from the opportunities
     * @param opp       The opportunity associated to the data
     * @return  a list of newly created opportunitylineitems
     */
    
     @TestVisible private OpportunityLineItem[] createLineItems(PricebookEntry[] pbes, Opportunity opp){
        OpportunityLineItem[] lineItems = new OpportunityLineItem[0];
        for(PricebookEntry pbe : pbes){
            if(pbe.CurrencyIsoCode == opp.CurrencyIsoCode){
                OpportunityLineItem oli = new OpportunityLineItem();
                //AG CC
                if (Schema.sObjectType.OpportunityLineItem.fields.OpportunityId.isCreateable()){
                    oli.OpportunityId = opp.id;
                    }
                oli.Quantity = pbe.Product2.Default_Quantity_AGN__c != null ? pbe.Product2.Default_Quantity_AGN__c : 1;
                oli.UnitPrice = pbe.Product2.Default_Price_to_Zero_AGN__c ? 0 : pbe.UnitPrice;
                oli.PricebookEntryId = pbe.id;
                lineItems.add(oli);
            }
        }
        return lineItems;
    }

    /**
     * This method creates a map with an index of pricebook2ids to a list of
     * pricebookentry. This method calls the query method to get the list
     * of pricebookentries to create the map.
     *
     * @param ids       the set of pricebook2id from the opportunities
     * @param currencycodes  the set of currencycodes from the opportunities
     * @return a map of pricebookEntrys to pricebook2id
     */
    private Map<Id, PricebookEntry[]> getPbeMap(Set<Id> ids, Set<String> currencyCodes){
        Map<Id, PricebookEntry[]> entryMap = new Map<Id, PricebookEntry[]>();
        for(PricebookEntry pbe : query(ids, currencyCodes)){
            PricebookEntry[] results = entryMap.get(pbe.Pricebook2Id);
            if(results == null){
                results = new PricebookEntry[0];
            }
            results.add(pbe);
            entryMap.put(pbe.Pricebook2Id, results);
        }
        return entryMap;
    }

    /**
     * This method returns a list of pricebookEntrys limited by currencycodes,
     * pricebook2id and Default_System_Product
     */
    @TestVisible private PricebookEntry[] query(Set<Id> ids, Set<String> currencyCodes){
        return [SELECT Id, UnitPrice, Pricebook2Id, CurrencyISOCode, Product2.Default_Quantity_AGN__c
                , Product2.Default_Price_to_Zero_AGN__c
                FROM PricebookEntry
                WHERE Pricebook2Id IN :ids
                AND CurrencyISOCode IN :currencyCodes
                AND Product2.Default_System_Product_AGN__c = true
                AND IsActive = true];
    }    
}