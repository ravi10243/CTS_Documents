/* 
@Class name : AGN_Object_lookup
@Createdate : 30.09.2019
@Author : GDPR Case management Project Team
@Description: Apex class created to return records for an object and pass it back to the lightning component. 
*/

public class AGN_Object_lookup {

 @AuraEnabled
 
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10  
         
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 10';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}