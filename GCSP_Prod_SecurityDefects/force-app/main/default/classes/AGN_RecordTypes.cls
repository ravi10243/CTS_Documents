public with sharing class AGN_RecordTypes {
	private static Map<ID, RecordType> oppRecordTypeIdMap; 
	
	private static Map<Id, RecordType> queryRecordTypes(String sobjType){
		if(sobjType != null && sobjType != '' && sobjType == 'Opportunity'){
			oppRecordTypeIdMap = new Map<Id, RecordType>([Select Id, DeveloperName from RecordType where SobjectType = :sobjType]);
			return oppRecordTypeIdMap;
		}
		return new Map<Id, RecordType>();
	}
    
    public static  Map<Id, RecordType> getOppRecordTypes(String sobjType){
    	if(oppRecordTypeIdMap != null && oppRecordTypeIdMap.size() > 0){
    		return oppRecordTypeIdMap;
    	}
    	else{
    		return queryRecordTypes(sobjType);
    	}
    }
}