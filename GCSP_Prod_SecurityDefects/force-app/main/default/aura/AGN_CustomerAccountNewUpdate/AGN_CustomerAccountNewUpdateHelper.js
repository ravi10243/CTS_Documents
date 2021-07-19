({
    getParameterByName : function (name) {
        var url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },

    
    MAX_DOC_FILE_SIZE: 750 000, /* 1 000 000 * 3/4 to account for base64 */

    saveFile : function(component,fileInput) {
    
        component.set("v.showSpinner", true);
        console.log("[FileUpload].[save]");
        var file = fileInput.files[0];

  
        if (file.size > this.MAX_DOC_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_DOC_FILE_SIZE + ' bytes.\n' +
              'Selected file size: ' + file.size);
            return;
        }

        var fr = new FileReader();

        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);

            console.log("[FileUpload].[Calling Upload]");
            self.upload(component, file, fileContents);
            console.log("[FileUpload].[Called Upload]");
        };


        fr.readAsDataURL(file);
    },

    upload : function(component, file, fileContents) {
        console.log("inside upload function. parent="+component.get("v.caseDetail.Id"));
        var actionFile;
        console.log("[FileUpload].["+ file.name+ "]");
        actionFile = component.get("c.saveFile");
        actionFile.setParams({
            "parentId": component.get("v.caseDetail.Id"),
            "fileName": file.name,
            "base64Data": encodeURIComponent(fileContents),
            "contentType": file.type
        });
        console.log("rrr-1");
        actionFile.setCallback(this, function(response) {

            var status = response.getState();
            if(status === "SUCCESS"){
                    
                console.log("rrr-2");
                console.log("rrr-3");
                component.set("v.showSpinner", false);
                /*var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/"
                });
                urlEvent.fire(); */               
            }
            else {
                alert("failed to upload file");
                component.set("v.showSpinner", false);
            }
        });
        console.log("rrr-5");
        $A.enqueueAction(actionFile);
        console.log("rrr-6");
    },

    callDummyMethod : function(component){
        component.set("v.showSpinner", false);
        console.log("[Dummy Method].[inside Method]");
        action = component.get("c.savetestFile");
        console.log("[Dummy Method].[Called Apex method]");
        action.setCallback(this, function(response) {     
            console.log("[Dummy Method].[inside callBack]");       
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                console.log("Dummy Case Number : "+response.getReturnValue());
                component.set("v.showSpinner", false);
            }
            else component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },


    validateAddressRequiredFields : function(component){
        jQuery.noConflict();
        var requiredMissing = false;
        var termsAndConditionMissing = false;
        //let sectionsToOpen= new Set();
        var message='';
		
        //Release 14.1 Niladri
        var wrongIbanFormat = false;
        var ibanGB = jQuery('.iban-identifire').attr("data-inputfiedlvalue");
        
        var wrongPostCodeFormat = false;
        var wrongEmailFormat = false;
        var wrongPhoneFormat = false;
        //alert('1.1');
        var emailAddress= jQuery('.email-identifire').attr("data-inputfiedlvalue");
        //alert(emailAddress);
        var phoneNumber = jQuery('.phone-identifire').attr("data-inputfiedlvalue");
       // alert(phoneNumber);
        var postCodeUK  = jQuery('.postCode-identifire').attr("data-inputfiedlvalue");
        //alert(postCodeUK);
        var CountryCode = 'GB';                

       // jQuery('.required_field').hide();
        //jQuery('.required_field').children('.blank_field_AddTerms ').hide();
        
        jQuery('.required-identifier').each(function(){ 

       // alert( 'inside require loop') ;
            
            console.log(jQuery(this).attr("data-inputfiedlvalue"));
            console.log(jQuery(this).find('input'));
            var currentComponent = jQuery(this).find('input');
            if( jQuery(this).attr("data-inputfiedlvalue")== 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('.required').show();
                $A.util.addClass(currentComponent, 'required');

                requiredMissing = true; 
            }
        });
        //alert('before post code');
        if(postCodeUK!= 'null'|| postCodeUK!=''){
            /*alert('inside postcode');

            if(countryCode== 'GB'){
                
                var postCodeRegex = /^(GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX]][0-9][A-HJKPSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY])))) [0-9][A-Z-[CIKMOV]]{2})?$/;
                //var postCodeRegex =/^((?:(?:gir)|(?:[a-pr-uwyz])(?:(?:[0-9](?:[a-hjkpstuw]|[0-9])?)|(?:[a-hk-y][0-9](?:[0-9]|[abehmnprv-y])?)))) ?([0-9][abd-hjlnp-uw-z]{2})/;
                alert ('after regex');
                if( !postCodeRegex.test(postCodeUK)){
                    alert('invalid postcode');
                    jQuery('.postCode-identifire').find('.required').show();;
                    wrongPostCodeFormat = true;                               
                }
                alert('valid postcode');
            }*/
        }
        //alert('after post code');

        /*if((jQuery.trim(jQuery(this).val())!='')&&(jQuery(this).hasClass('reg_phone'))){
           /* if( !validatePhone(jQuery(this).val())){
                addRequired(jQuery(this));
                wrongPhoneFormat = true;
                sectionsToOpen.add(jQuery(this).attr("alt"));
            }
            addRequired(jQuery(this));
            sectionsToOpen.add(jQuery(this).attr("alt"));
        }*/
            
        if(emailAddress!= 'null'|| emailAddress!=''){
            var emailRegex = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
                //emailRegex.test( emailAddress );

            if( !emailRegex.test(emailAddress)){
                jQuery('.email-identifire').find('.required').show();;
                wrongEmailFormat = true;                    
            }
        } 
        
        //Release 14.1 Niladri
        if((ibanGB!= 'null' || ibanGB!='') && component.get("v.type") != 'Ship To'){
			if(CountryCode == 'GB'){    
                var ibanRegex = /^GB\d{2}[A-Z]{4}\d{14}$/;
                console.log('ibancheck Value--'+ibanRegex.test( ibanGB ));
                if(!ibanRegex.test( ibanGB )){
                	jQuery('.iban-identifire').find('.required').show();                
                	wrongIbanFormat = true;
                }
    		}
        	//else return true;            
        }        
    
        if (requiredMissing == true){                
            message='Please fill the required field(s) correctly.' ;  
            //alert('required Missing') ;
            //return false;
        }
                   
        if(wrongPostCodeFormat){
            message= message+' Please check format for : Post code,';                 
            //label_content();
        }
        
        if(wrongEmailFormat){
            //alert('required email') ;
            if(message.slice(-1)!= ','){message= message+' Please Check format for : Email,';}
            else message= message+' Email,';
           // label_content();
        }
        
        //Release 14.1 Niladri
        if(wrongIbanFormat){
            //alert('IBAN Required') ;
            if(message.slice(-1)!= ','){message= message+' Please Check format for : IBAN,';}
            else message= message+' IBAN,';           
        }
        
        message=message.slice(0,-1);
        jQuery('.required_field').children('.blank_field ').text(message);
        jQuery('.required_field').show();
        jQuery('.required_field').children('.blank_field ').show();
            
        //alert('final block before');
        if(!requiredMissing && !wrongPostCodeFormat && !wrongEmailFormat && !wrongIbanFormat) {
           //alert('final block');
           component.set("v.fieldValidation" , true);
        }
    },

   /* validateEmail : function(component , email) {
        alert('in side email factory');
    jQuery.noConflict();
      var emailRegex = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
      return emailRegex.test( email );
    },*/
    /*validatePhone : function(component ,phone) {
        jQuery.noConflict();
        var phoneRegex =  /^\+?([0-9]{2})\)?[-. ]?([0-9]{4})[-. ]?([0-9]{4})$/;
        return phoneRegex.test( phone );
    },
*/
  /*  validatePostCodeUK : function(component , postCode , countryCode) {
        jQuery.noConflict();
        if(countryCode== 'GB'){
            var postCodeRegex =/^\b((?:(?:gir)|(?:[a-pr-uwyz])(?:(?:[0-9](?:[a-hjkpstuw]|[0-9])?)|(?:[a-hk-y][0-9](?:[0-9]|[abehmnprv-y])?)))) ?([0-9][abd-hjlnp-uw-z]{2})\b/ig;
            return postCodeRegex.test( postCode );
        }
        else return true;
    }*/
})