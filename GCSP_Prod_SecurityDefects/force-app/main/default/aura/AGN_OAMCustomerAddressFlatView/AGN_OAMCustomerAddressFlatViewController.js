({
    doInit: function(component, event, helper){ 
        
        //console.log('abdl address '+JSON.stringify(component.get('v.addressFields')));
        var arr = component.get('v.addressFields');
        var data = component.get('v.addressData');
        //console.log(JSON.stringify(data));
        
        var str = '';
        for(var i in arr){
            var fieldValue = data[arr[i].Field_Name_AGN__c];
            //As per the requirements, No need to display true/false values
            if(fieldValue && fieldValue != true && fieldValue != false){
                str += fieldValue + ', '; 
            }
        }
        component.set('v.outPut', str.replace(/,\s*$/, "")); //removed last comma(,)
        
    }
})