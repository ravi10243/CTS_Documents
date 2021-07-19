/*****************************************************************************************************
* @Author: Cognizant Team 
* @Class Name: AGN_CaseToOneTrackHandler
* @Description: Handler class to update Memo field

*******************************************************************************************************/
public class AGN_CaseToOneTrackHandler {
    
    
    public void executeCaseToOneTrackHandler(List<Case> newCaseList, Map<Id,Case> oldCaseMap){
        
       try{ 
        List<Schema.FieldSetMember> caseFields = Schema.SObjectType.Case.fieldSets.getMap().get('AGN_CoolS_OneTrack').getFields();
        
        for(Case newCase : newCaseList){
            if(String.isNotBlank(newCase.PR_ID_Trackwise_AGN__c)){
                Case oldCase = oldCaseMap.get(newCase.Id);
                Map<String, Object> fieldMap = stringToMap(newCase.Memo_CoolS_AGN__c);
                for(Schema.FieldSetMember field : caseFields) {
                    if(oldCase.get(field.getSobjectField().getDescribe().getName()) != newCase.get(field.getSobjectField().getDescribe().getName())){
                        String value;
                        if(field.getSobjectField().getDescribe().getType() == Schema.DisplayType.DATE){
                            Date d =  (Date)newCase.get(field.getSobjectField().getDescribe().getName());
                            value = d.format();
                        }else{ 
                            value = (String)newCase.get(field.getSobjectField().getDescribe().getName());
                            
                        }
                        
                        fieldMap.put(field.getLabel(),value);
                        newCase.OTI_Batch_Status_CoolS_AGN__c = 'Scheduled';
                    }  
                }
                
                
                newCase.Memo_CoolS_AGN__c = mapToString(fieldMap);
                System.debug('####Memo####' +newCase.Memo_CoolS_AGN__c);
            }
         }
           
       }catch (Exception ex){
         System.debug('####Exception Message####'+ex.getMessage());
       }
    }
    
    public Map<String,String> stringToMap(String text) {
        
        Map<String,String> fieldMap = new Map<STring,String>();
        
       try{
        if(String.isNotBlank(text)){
            List<String> lineItems = text.split('<br>');
            for(String item : lineItems) {
                System.debug('####item####'+item);
                List<String> fieldValue = item.split(':');
                if(fieldValue.size() > 1){
                 String fieldName = fieldValue[0];
                    fieldValue.remove(0);
                    String value = string.join(fieldValue,':');
                  fieldMap.put(fieldName,value);   
                }
            }
         }
       }catch (Exception ex){
         System.debug('####Exception Message####'+ex.getMessage());
       }
        return fieldMap;
 
    }
    
    public String mapToString(Map<String,Object> fieldMap) {
        
       
        String textField = '';
        String Description;
        String descriptionKey = 'Description';
       try{ 
        for(String key : fieldMap.keySet()){
            if(key == descriptionKey){
                Description = (String)fieldMap.get(key);
                Continue; 
            }   
            textField = textField + key + ':' + fieldMap.get(key) + '<br>';
        }
        
        if(Description!=null){
            textField = textField + descriptionKey + ':' + Description + '<br>';
        }
       }catch (Exception ex){
         System.debug('####Exception Message####'+ex.getMessage());
        }
        return textField;
    }
    
    
    
   public void addressFieldsToCase(List<Case> newCaseList, Map<Id,Case> oldCaseMap){
      try{
        Set<Id> accountIds = new Set<Id>();
       for(Case newCase : newCaseList){
          if(String.isNotBlank(newCase.PR_ID_Trackwise_AGN__c)){
             Case oldCase = oldCaseMap.get(newCase.Id);
             if(oldCase.AccountId != newCase.AccountId){
               accountIds.add(newCase.AccountId);
               System.debug('####Account Id######'+accountIds);
              }
            }
          }
          
          List<Address_vod__c> addressList = new List<Address_vod__c>();
          if(!accountIds.isEmpty()){
              addressList = [Select Id,State_vod__c,Zip_vod__c,Address_line_2_vod__C,City_vod__c,Country_vod__c,Primary_vod__c,Account_vod__c From Address_vod__c where Account_vod__c in : accountIds and Primary_vod__c = True order by LastModifiedDate desc Limit 1];
          }
          
          Map<Id,Address_vod__c> addressMap = new Map<Id,Address_vod__c>();
          for(Address_vod__c address : addressList){ 
              addressMap.put(address.Account_vod__c,address);
          }
        
    
        for(Case newCase : newCaseList){
          if(String.isNotBlank(newCase.PR_ID_Trackwise_AGN__c)){
              Case oldCase = oldCaseMap.get(newCase.Id);
             if(oldCase.AccountId != newCase.AccountId){
              if(addressMap.containsKey(newCase.AccountId)){
               Address_vod__c add =  addressMap.get(newCase.AccountId);
               
                  newCase.State_CoolS_AGN__c = add.State_vod__c;     
                 
                  newCase.Postal_Code_CoolS_AGN__c = add.Zip_vod__c;     
                
                  newCase.Street_CoolS_AGN__c = add.Address_line_2_vod__C;     
                
                  newCase.City_CoolS_AGN__c = add.City_vod__c;     
                                  
                  newCase.Country_CoolS_AGN__c = add.Country_vod__c;     
             
                 }else{
                     
                   newCase.State_CoolS_AGN__c = 'null';     
                 
                   newCase.Postal_Code_CoolS_AGN__c = 'null';     
                
                   newCase.Street_CoolS_AGN__c = 'null';     
                
                   newCase.City_CoolS_AGN__c = 'null';     
                                  
                   newCase.Country_CoolS_AGN__c = 'null';
                 }
              }
            }
          }
        }catch (Exception ex){
         System.debug('####Exception Message####'+ex.getMessage());
       }
       
    }
    
    
}