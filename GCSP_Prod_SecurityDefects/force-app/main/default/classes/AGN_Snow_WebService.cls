@RestResource(urlMapping='/actionEntity/*')
global with sharing class AGN_Snow_WebService {
    global static list<sobject> getEntity(string Name,string entType)
    {
        list<sobject> lstSobj=new list<sobject>();
        string dynaQuery,entId;
        if(entType=='User')
            dynaQuery='select Id,Username,Call_Backdate_Limit_AGN__c from '+ entType +' where Username=\''+string.escapeSingleQuotes(Name.trim())+'\' limit 1';
        else if (entType=='TOT')
            {
                dynaQuery='select Id,Name from Time_Off_Territory_vod__c where Name=\''+string.escapeSingleQuotes(Name.trim())+'\' limit 1';

            }
        else if (entType=='Call')
            dynaQuery='select Id,Name,Unlock_vod__c from Call2_vod__c where Name=\''+string.escapeSingleQuotes(Name.trim())+'\' limit 1';
        else
            dynaQuery='select Id from '+entType+' where Name=\''+string.escapeSingleQuotes(Name.trim())+'\' limit 1';
        if(String.isNotBlank(Name) && String.isNotBlank(entType)){
            lstSobj=Database.Query(dynaQuery);   
        }
        //entId=lstSobj.size()>0?(String) lstSobj[0].get('Id'):'';
        return lstSobj;
    }
    
    @HttpPost
    global static String entityAction()
    {
        try
        {
        string entityName,entityType,callBackdate;
        list<sobject> entity=new list<sobject>();
        list<sobject> bkpSobj=new list<sobject>();
        Error_Table_AGN__c BackupTable= new Error_Table_AGN__c();
        string bkpQuery, jsonBkp;
        RestRequest req  = RestContext.request;
        RestResponse res  = RestContext.response;
        fromJSON jsonBody;
        //entityName=r.requestURI.substring(r.requestURI.lastIndexOf('/')+1);
        jsonBody = (fromJSON) JSON.deserialize(req.requestBody.toString(),fromJSON.class);
        entityName=jsonBody.entityIdentifier;
        callBackdate=jsonBody.callBackDateLimit;
        system.debug('entityName.substring(0,3)--'+entityName);
        if(entityName.substring(0,1)=='C' && !entityName.contains('@') && entityName.startsWith('C0'))
            entityType='Call2_vod__c';
        else if (entityName.substring(0,3)=='TOT' && !entityName.contains('@') && entityName.startsWith('TOT-'))
            entityType='Time_Off_Territory_vod__c';
        else if (entityName.contains('@'))
            entityType='User';
        entity=getEntity(entityName,entityType);
        
        if(entity.size()<1)
        {
            //return not exists message
            return entityName+ ' does not exists';
        }
        else 
        {
            if (entityType=='Time_Off_Territory_vod__c')
              {
                bkpQuery ='select Id,Name from Time_Off_Territory_vod__c where Name=\''+string.escapeSingleQuotes(entityName.trim())+'\' limit 1';
                bkpSobj=Database.Query(bkpQuery);
                jsonBkp = JSON.serializePretty(bkpSobj);
                BackupTable.Name = 'SNOW Integration - TOT Delete';
                BackupTable.Error_Details_AGN__c = jsonBkp ;
                insert BackupTable;
                delete entity;
                return entityName+' has been Deleted';
                }
            else if (entityType=='User')
            {
                bkpQuery ='select Id,Username,Call_Backdate_Limit_AGN__c from user where Username=\''+string.escapeSingleQuotes(entityName.trim())+'\' limit 1';
                bkpSobj=Database.Query(bkpQuery);
                jsonBkp = JSON.serializePretty(bkpSobj);
                BackupTable.Name = 'SNOW Integration - User Call Backdate Update';
                BackupTable.Error_Details_AGN__c = jsonBkp ;
                insert BackupTable;
                entity[0].put('Call_Backdate_Limit_AGN__c',Decimal.valueof(callBackdate));
                update entity;
                return entityName+' has been Updated';
            }
            else if (entityType=='Call2_vod__c')
                {
                bkpQuery ='select Id,Name from Call2_vod__c where Name=\''+string.escapeSingleQuotes(entityName.trim())+'\' limit 1';
                bkpSobj=Database.Query(bkpQuery);
                jsonBkp = JSON.serializePretty(bkpSobj);
                BackupTable.Name = 'SNOW Integration - Call Unlock';
                BackupTable.Error_Details_AGN__c = jsonBkp ;
                insert BackupTable;
                
                entity[0].put('Unlock_vod__c',TRUE);
                update entity;
                return entityName+' has been Updated';
            }
        return entityName+' not found in the application';
        }
        }
        catch(DMLException dex)
        {
            return 'Error happened during the operation. Please open a service requst to process this request. ';
            //System.debug(ex.getmessage);
        }
        catch(Exception ex)
        {
            return 'Error happened during the operation. Please open a service requst to process this request.';
            //System.debug(ex.getmessage);
        }
    }
    public class fromJSON
    {
        public string entityIdentifier;
        public string callBackDateLimit;
    }
}