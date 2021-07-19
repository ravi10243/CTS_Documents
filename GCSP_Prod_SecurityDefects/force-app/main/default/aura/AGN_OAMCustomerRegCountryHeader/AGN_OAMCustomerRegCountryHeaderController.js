({
    doInit : function(component, event, helper) {               
        helper.fetchCountry(component, event);
    },
    doneRendering : function(component,event, helper){
        
        jQuery.noConflict();
        
        jQuery('.input-identifier').each(function(){
            if( jQuery(this).attr("data-inputfiedlvalue") == 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        });
        console.log('doneRendering');
        //jQuery('.Basic_det .infr_det').slideDown();
        //jQuery('.no_det.active').css("border", "2px solid #a3d233");
    },
    onSelectChangeCountry : function(component, event, helper) {
        component.set("v.picklistCustomerTypeOptions", []);
        component.set("v.picklistSubTypeOptions", []);
        
        component.set("v.selectedCountry", '');
        component.set("v.selectedCustomerType", '');
        component.set("v.selectedSubType", '');
        helper.fetchCustomerType(component,event);
    },
    onSelectChangeCustomerType : function(component, event, helper) {
        
        component.set("v.picklistSubTypeOptions", []);
        component.set("v.selectedCustomerType", '');
        component.set("v.selectedSubType", '');
       
        helper.fetchCustomerSubType(component,event, helper);
    },
    onSelectChangeSubType : function(component,event, helper) {
        var selected = component.find("inputSelectSubType").get("v.value");
        component.set("v.selectedSubType", selected);
		helper.fireEvent(component, event);
    }
})