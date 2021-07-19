/**
* The Job will getting triggered once Custom Label job finished its activity 
* which overrides the config data with org specific data. In this case data 
* maintained under different custom settings will be restored specific for sandbox org.
*
* @author  Amit Das
* @version 1.0
* @since   2020-08-05 
*/

public class AGN_CustomSettingBatchProcess {
    List<String> listSoqlQueries = new List<String>();
    List<String> filteredQueryList = new List<String>();
    String query ;
    public void processCustomSettingBatchJobs(){
        Map < String, Schema.SObjectType > gd = Schema.getGlobalDescribe();        
        for ( String objectName : gd.keySet() ) {            
            Schema.SObjectType result = gd.get( objectName );            
            if ( result.getDescribe().isCustomSetting() ) {                
                query = 'SELECT ';
                List <String> listFields = new List <String>();
                Map <String, Schema.SObjectField> objectFields = result.getDescribe().fields.getMap();
                for (String s : objectFields.keySet()) {                    
                    if (String.valueOf( objectFields.get(s).getDescribe().getType()) == 'Email' || String.valueOf(objectFields.get(s).getDescribe().getType()) == 'String'){ 
                        query += s + ',';
                        listFields.add(s);                            
                    }
                }
                if (listFields.size() > 0 ) {
                    query = query.removeEnd( ',' );
                    query += ' FROM ' + objectName;
                }
                listSoqlQueries.add(query);
                if(isQueryEligibleForProcess(query)){
                    filteredQueryList.add(query);
                }
                /*List<sObject> records = Database.query(query);
                if(records != null && records.size() > 0){
                    listSoqlQueries.add(query);
                }*/
                
            }
            
        }
        System.debug('Total queries '+ listSoqlQueries.size());
        System.debug('Filtered queries '+ filteredQueryList.size());
        for(String filterQuery : filteredQueryList){
            System.debug('Filetered query '+ filterQuery);
            List<String> columns = filterQuery.substring(filterQuery.indexOf('Select')+7, filterQuery.indexOf('FROM')-1).split(',');
            String table = filterQuery.substring(filterQuery.indexOf('FROM')+5).split(' ')[0];
            System.debug('Column names '+ columns);
            System.debug('Table name '+table);
        }
        Integer counter =1;
        for(String str : filteredQueryList){
            boolean isLastQuery = (counter == filteredQueryList.size()) ? true:false;
            System.debug('IsLast' + isLastQuery+' -- ' + str );
            //database.executeBatch(new SampleCustomSettingTest(str , isLastQuery), 50);
            database.executeBatch(new AGN_BatchJobProcess_CustomSettings(str , isLastQuery), 50);
            counter +=1;
        }
        //System.debug('Query size '+listSoqlQueries.size());
    }
    
    private boolean isQueryEligibleForProcess(String sql){
        List<sObject> records = Database.query(sql);
        if(records != null && records.size() > 0){
            List<String> columns = sql.substring(sql.indexOf('Select')+7, sql.indexOf('FROM')-1).split(',');
            String table = sql.substring(sql.indexOf('from')+5).split(' ')[0];
            for (sObject obj : records ) {
                for (String columnName : columns ) {
                    String strField = columnName.trim();
                    //query build if custom setting email fields needs for masking
                    if (obj.get(strField) != null && AGN_PostCopyValidateUtil.validateEmail(String.valueOf(obj.get(strField)))){ 
                        return true;
                    }
                    //query build if custom setting email fields needs for unmasking
                    /*if (obj.get(strField) != null &&  String.valueOf(obj.get(strField)).endsWith('.invalid')){ 
                        return true;
                    }*/
                }
            }
        }
        return false;
    }
    
    
}