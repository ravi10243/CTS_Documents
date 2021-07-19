public without sharing class AGN_OAMMultiSelectController {

    @AuraEnabled
    public static PicklistOption[] getOptions(String ObjectName ,string fieldName) {
        List<PicklistOption> options = new List<PicklistOption>();
        sObject objObject = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        PicklistOption option;
        for (Schema.PicklistEntry a: values) {
              option = new PicklistOption(a.getValue() , a.getLabel());
              options.add(option);
        }
        system.debug('allOpts ---->' + options);
        return options;
    }
    
    @AuraEnabled(cacheable=true)
    public static PicklistOption[] getPicklistOptions(String ObjectName ,string fieldName) {
        List<PicklistOption> options = new List<PicklistOption>();
        sObject objObject = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        PicklistOption option;
        for (Schema.PicklistEntry a: values) {
              option = new PicklistOption(a.getValue() , a.getLabel());
              options.add(option);
        }
        system.debug('allOpts ---->' + options);
        return options;
    }
    
    @AuraEnabled
    public static PicklistOption[] getOptions(String ObjectName ,string fieldName,String customerCountryCode,String customerType,String customerSubType) {
        
        
        System.debug('customCountryCode PI : '+customerCountryCode+ ' customerType PI : '+customerType+ ' customerSubType PI : '+customerSubType);
        
        List<PicklistOption> options = new List<PicklistOption>();
        sObject objObject = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        PicklistOption option;
        
       // if(customCountryCode.equalsIgnoreCase('ES')){
            
            
            if(customerType.equalsIgnoreCase('Pharmacies') && customerSubType.equalsIgnoreCase('Pharmacy')){
                // PH VP // BK, OZ, BTX, GE, OL
                
                // RD,PM,EF,IXEN,CS  remove
                for (Schema.PicklistEntry a: values) {
                    
                    option = new PicklistOption(a.getValue() , a.getLabel());
                    options.add(option);
                    
                    for (Integer i = (options.size()-1) ; i>= 0 ; i--){
                        PicklistOption s = options[i];
                        
                        if(s.value.contains('RD')|| s.value.contains('PM') || s.value.contains('EF') || s.value.contains('IXEN') || s.value.contains('CS')){
                            options.remove(i);
                        }
                        
                    } 
                    
                    
                }
                
                System.debug('options abd: '+options);
                
            }/*else if(customerType.equalsIgnoreCase('Pharmacies') && customerSubType.equalsIgnoreCase('Pharmacy authorized to buy Vistabel')){
                // CL  //BK, OZ, VB, GE, OL
                for (Schema.PicklistEntry a: values) {
                    
                    option = new PicklistOption(a.getValue() , a.getLabel());
                    options.add(option);
                    
                    for (Integer i = (options.size()-1) ; i>= 0 ; i--){
                        PicklistOption s = options[i];
                        
                        if(s.value.contains('RD')|| s.value.contains('PM') || s.value.contains('EF') || s.value.contains('IXEN') || s.value.contains('CS') || s.value.contains('BTX')){
                            options.remove(i);
                        }
                        
                    } 
                    
                    
                }       
                System.debug('options abd: '+options);  
            }*/else if(customerType.equalsIgnoreCase('Clinic') || customerType.equalsIgnoreCase('Healthcare Practitioners')){
                // CL  //RD, PM, EF, IXEN, CS
                // RD,PM,EF,IXEN,CS,BK,OZ,BTX,VB,GE,OL
                for (Schema.PicklistEntry a: values) {
                    
                    option = new PicklistOption(a.getValue() , a.getLabel());
                    options.add(option);
                    
                    for (Integer i = (options.size()-1) ; i>= 0 ; i--){
                        PicklistOption s = options[i];
                        
                        if(s.value.contains('BK')|| s.value.contains('OZ') || s.value.contains('BTX') || s.value.contains('VB') || s.value.contains('GE') || s.value.contains('OL')){
                            options.remove(i);
                        }
                        
                    } 
                    
                    
                }       
                System.debug('options abd: '+options);  
            }else{
                // all HR 
                for (Schema.PicklistEntry a: values) {
                    option = new PicklistOption(a.getValue() , a.getLabel());
                    options.add(option);
                }
                system.debug('allOpts ---->' + options);
            }
            
            
      //  }
        
        return options;
    }
    
    public class PicklistOption{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        public PicklistOption(String value , String label){
           this.value = value;
           this.label = label;            
        }
    }
}