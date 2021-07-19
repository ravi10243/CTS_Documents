({
    scriptsLoaded : function(component, event, helper) {
        
        console.log('javaScript files loaded successfully') 
        
        jQuery.noConflict();
        
    },   

    doneRendering : function(component,event, helper){
       
        jQuery('.input-identifier').each(function(){
            if( jQuery(this).attr("data-inputfiedlvalue") == 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        });
    }, 
    
    doInit : function(component,event, helper){      
       
       
        component.set("v.sectionHeaderMapDoc", {});
        
        helper.fetchDocumentSettings(component, event);
       
        helper.fetchCustomerDetails(component, event);     
       
        var subType = component.get("v.customerSubType");
        var type = component.get("v.customerType");
        component.set("v.customerSubType", subType.toUpperCase());
        component.set("v.customerType", type.toUpperCase());                  
    },
    
    showForm : function(component, event, helper) {
        var params = event.getParam('arguments');        
        
        if(!$A.util.isEmpty(params.custRegID)){
            component.set("v.selectedCustRegID", params.custRegID);           
          
            component.set("v.sectionHeaderMapDoc", {});            
            helper.fetchDocumentSettings(component, event);
           // helper.displaySpecialty(component, event);
          
            jQuery('.Doc_Basic_det .infr_det').slideDown(500);
            jQuery('.no_det.active').css("border", "2px solid #a3d233");
        }
        else{
            console.log('CustId -->'+JSON.stringify(params.custRegID));
            jQuery('.basic_details .infr_det').slideUp(500);
            jQuery(".basic_details .no_det" ).css("border", "2px solid #bfbfbf");
        }
    },
    resetBlock : function(component,event, helper){    
        
        var notifyRegStepChange = component.getEvent("notifyRegStepChange");
        notifyRegStepChange.setParams({"Operation": 'CANCEL',
                                      "StepNo": '3'}
                                     );
        notifyRegStepChange.fire();
    
    },
 	onChangeTcAccepted : function(component, event, helper){
       var tcAccepted = component.get("v.isTCAccepted");
        if(tcAccepted){
            component.set("v.isdisabled",false);
        }else{
            component.set("v.isdisabled",true);
        }        
    },   
    ondocumentUploadMandate : function(component, event, helper){
        var eventParam = event.getParam("isMandateDoc"); 
        component.set("v.isMandate",eventParam);          
    },   
    validateAndUpsert : function(component,event, helper){ 
        helper.validateAndUpsert(component, event);         
    },    
})