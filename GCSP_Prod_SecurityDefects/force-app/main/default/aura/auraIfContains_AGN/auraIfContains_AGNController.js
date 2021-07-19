({
    doInit: function(component, event, helper) {
        
        var array1 = component.get('v.items').split(',');
        var array2 = component.get('v.element').split(',');
        
        var found = array1.some(r=> array2.includes(r));
        
        component.set('v.condition', found);
        
        //console.log(array1);
        //console.log(array2);
        //console.log(found);
    }
})