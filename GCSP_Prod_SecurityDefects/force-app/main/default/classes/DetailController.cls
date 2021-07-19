public class DetailController {
	 @AuraEnabled
    public static list<Sobject> getRecords(Id recordId, String fieldsToShow) {
        String objectName = recordId.getSobjectType().getDescribe().getName();
        String soql = 'Select ' + fieldsToShow + ' from ' + objectName;
        return Database.query(soql);
       // return rec;
    }
}