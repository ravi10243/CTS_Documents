({
    doInit :function(component, event, helper) {
        
       // alert(JSON.stringify(component.get("v.record")));
    },
    
    handleBlur :function(component, event, helper) {
        
          
        var TaxNumber = component.get("v.record.Tax_Number_AGN__c");
        var VatNumber = component.get("v.record.VAT_Number_AGN__c");
        
        var fieldValueMissing = (TaxNumber === null || TaxNumber === '' || TaxNumber === undefined) && (VatNumber === null || VatNumber === '' || VatNumber === undefined);
        
        component.set("v.VatNumberMissing",(fieldValueMissing));
        component.set("v.TaxNumberMissing",(fieldValueMissing));
        
   
    },
  
    
})