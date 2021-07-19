({
    scriptsLoaded : function(component, event, helper) {
        
        console.log('javaScript files loaded successfully') 
        
        jQuery.noConflict();
        
    },
    doneRendering : function(component,event, helper){
        
        //console.log("doneRendering");
        //jQuery.noConflict();
        
        jQuery('.input-identifier').each(function(){
            if( jQuery(this).attr("data-inputfiedlvalue") == 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        });
    },
    onChange : function(component, event, helper) {
        
        const cmps = component.find("fieldId_Doc");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){            
            cmps.forEach( function (cmp){                
                //storing all screen data in to relevant object
                if(cmp.get("v.sobjectName") === 'Allergan_Customer_Registration_AGN__c' && cmp.get("v.fieldName")==='Tax_Exempted_AGN__c'){
                    var derivedField = 'v.objAGNCustReg.' + cmp.get("v.fieldName"); 
                    component.set(derivedField,cmp.get("v.fieldValue"));                   
                }
            });
            //end forEach
        }
        else{
            //single record
            //storing all screen data in to relevant object
            if(cmps.get("v.sobjectName") === 'Allergan_Customer_Registration_AGN__c'&& cmp.get("v.fieldName")==='Tax_Exempted_AGN__c'){
                var derivedField = 'v.objAGNCustReg.' + cmps.get("v.fieldName"); 
                component.set(derivedField,cmps.get("v.fieldValue"));
            }
        }
        var taxExemptedVal = component.get("v.objAGNCustReg.Tax_Exempted_AGN__c");
        component.set("v.taxExempted",taxExemptedVal);
        //var taxExemptedVal = component.get("v.taxExempted");
        console.log('@@@@@[taxExemptedVal]@@@'+taxExemptedVal);
        
        /* for attachment */
        var customerRegId = component.get("v.selectedCustRegID");
        var taxExemptedVal = taxExemptedVal;
        var objCompB = component.find('TaxExeId');
        objCompB.TaxExpMethod(customerRegId, taxExemptedVal);
        
    },
    
    handleBlur : function(component,event, helper){ 
        
        helper.validateFieldValue(component, event);
    },
    
    doInit : function(component,event, helper){      
        
        //console.log('country -->'+component.get('v.countryCode'));
        
        component.set("v.sectionHeaderMapDoc", {});
        
        helper.fetchDocumentSettings(component, event);
        helper.displaySpecialty(component, event);
        
        helper.fetchCustomerDetails(component, event);
        helper.fetchSpecialityDetails(component, event);
        //helper.fetchCustomerAddressDetails(component, event);
        
        //jQuery('.Doc_Basic_det .infr_det').slideDown(500);
        //jQuery('.no_det.active').css("border", "2px solid #a3d233");
        
    },
    
    showForm : function(component, event, helper) {
        var params = event.getParam('arguments');        
        
        if(!$A.util.isEmpty(params.custRegID)){
            component.set("v.selectedCustRegID", params.custRegID);            
            // console.log('selectedCustRegID-->'+component.get("v.selectedCustRegID"));           
            
            component.set("v.sectionHeaderMapDoc", {});
            
            helper.fetchDocumentSettings(component, event);
            helper.displaySpecialty(component, event);
            // helper.fetchCustomerDetails(component, event);
            // helper.fetchCustomerAddressDetails(component, event);
            
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
        
        /*jQuery('.upload_doc .infr_det').slideUp(500);
        jQuery('.upload_doc.active').css("border", "2px solid #a3d233");
        jQuery( ".upload_doc .edit_btn" ).show();
        jQuery( ".payment .edit_btn" ).show();*/
    },
    
    ondocumentUploadMandate : function(component, event, helper){
        var eventParam = event.getParam("isMandateDoc"); 
        component.set("v.isMandate",eventParam);
        console.log('@@@@@con isMandateVal-->'+eventParam); 
    },
    onTaxExemptingDocmantUploadMandate : function(component, event){
        var eventParam = event.getParam("isMandateDoc");
         component.set("v.isMandateTaxExempting",eventParam);                  
    },
    
    
    handleChange : function(component,event, helper){
        console.log('dfdfdfdddddd' );
        //IE fileUpload issue fix Start #SCTASK1100635 Start
        //var radiovalue = component.get("v.value");
        var radiovalue = event.getSource().get("v.label");		       
        component.set("v.value", radiovalue);
        component.set("v.value11", radiovalue);        
        console.log('dfdfdfdddddd>>>'+radiovalue );
        if( radiovalue === 'Owner' ){
            component.set("v.objAGNCustReg.Owner_AGN__c", true);
        }
        if( radiovalue === 'Contractor' ){          
            component.set("v.objAGNCustReg.Contractor_AGN__c", true);
        }
        if( radiovalue === 'Employee' ){
            component.set("v.objAGNCustReg.Employee_AGN__c", true);
        }
        if( radiovalue === 'Professional Service Provider' ){
            component.set("v.objAGNCustReg.Professional_Service_Provider_AGN__c", true);
        }
        //IE fileUpload issue fix Start #SCTASK1100635 End
    },
    
    validateAndUpsert : function(component,event, helper){ 
        helper.validateAndUpsert(component, event); 
    }, 
    
})