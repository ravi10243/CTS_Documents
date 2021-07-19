({
    doInit: function (component, event, helper) {
        var captchalink = $A.get("$Label.c.AGN_DSRM_Captcha_Link1") + '/apex/AGN_CCPAGoogleCaptchaPage';
        component.set("v.Captcha1", captchalink);
        /*GOOGLE RECAPTCHA*/
        window.addEventListener("message", function (event) {
            // Custom Label AGN_DSRM_CommunityURL

            if (event.origin !== $A.get("$Label.c.AGN_DSRM_Captcha_Link")) {
                return;
            }
            if (event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'NOK') {
                component.set("v.captchaCheck", false);
            } else if (event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'OK') {
                component.set("v.captchaCheck", true);
            }
        }, false);

        helper.setDefaultStyle(component);
        helper.getMessage(component, "error_fields_required", "enGB", (title, message) => console.log('Callback message: ' + message));

        var currentFormStep = component.get("v.currentFormStep");

        if (currentFormStep) {
            var saveButtonLabel = currentFormStep.SaveButtonLabel;
            var saveNextButtonLabel = currentFormStep.SaveNextButtonLabel;
            var savePreviousButtonLabel = currentFormStep.SavePreviousButtonLabel;

            if (saveButtonLabel) {
                component.set("v.saveButtonLabel", saveButtonLabel);
            }
            if (saveNextButtonLabel) {
                component.set("v.saveNextButtonLabel", saveNextButtonLabel);
            }
            if (savePreviousButtonLabel) {
                component.set("v.savePreviousButtonLabel", savePreviousButtonLabel);
            }

            var listPageElements = currentFormStep.ListElements;
            console.log('CurrentViewState--' + currentFormStep.CurrentViewState);

            if (listPageElements) {
                component.set("v.listPageElements", listPageElements);
            }
            if (currentFormStep.CurrentViewState) {
                component.set("v.currentViewState", currentFormStep.CurrentViewState);
                helper.handleOnLoadViewState(component, event, helper);
            }
        }
        //get primary object record type and set to record edit form
        helper.getRecordTypeId(component, event, helper);
    },
    onClickSaveNext: function (component, event, helper) {
        component.set("v.clickedButtonType", 'SAVENEXT');

        helper.checkRequiredValidations(component, event, helper);
        var requiredValidationFailed = component.get("v.requiredValidationFailed");

        if (!requiredValidationFailed) {
            helper.onCumulativeSave(component, event, helper);
        } else {
            const errorMessage = component.get("v.requiredValidationFailedErrorMessage");
            if (errorMessage) {
                //helper.showOnErrorToast(component.get("v.requiredValidationFailedErrorTitle"), errorMessage);
            } else {
                const language = component.get("v.listPageElements")[0].CurrentLanguageCode;
                helper.getMessage(component, "error_fields_required", language, (title, message) => {
                    component.set("v.requiredValidationFailedErrorTitle", title);
                    component.set("v.requiredValidationFailedErrorMessage", message);
                    //  helper.showOnErrorToast(title, message);
                });
            }

        }
    },
    onClickSavePrevious: function (component, event, helper) {
        component.set("v.clickedButtonType", 'SAVEPREV');

        helper.checkRequiredValidations(component, event, helper);
        var requiredValidationFailed = component.get("v.requiredValidationFailed");

        if (!requiredValidationFailed) {
            helper.onCumulativeSave(component, event, helper);
        } else {
            const errorMessage = component.get("v.requiredValidationFailedErrorMessage");
            if (errorMessage) {
                //helper.showOnErrorToast(component.get("v.requiredValidationFailedErrorTitle"), errorMessage);
            } else {
                const language = component.get("v.listPageElements")[0].CurrentLanguageCode;
                helper.getMessage(component, "error_fields_required", language, (title, message) => {
                    component.set("v.requiredValidationFailedErrorTitle", title);
                    component.set("v.requiredValidationFailedErrorMessage", message);
                    //  helper.showOnErrorToast(title, message);
                });
            }
            //var requiredValidationFailedErrorMessage = component.get("v.requiredValidationFailedErrorMessage");
            //helper.showOnErrorToast(component, event, helper, requiredValidationFailedErrorMessage);
        }
    },
    onClickSave: function (component, event, helper) {
        var cptcha = component.get("v.captchaCheck");
        console.log('CAPTCHA ' + cptcha);
        if (cptcha == true) {
            component.set("v.clickedButtonType", 'SAVE');

            helper.checkRequiredValidations(component, event, helper);
            var requiredValidationFailed = component.get("v.requiredValidationFailed");
            console.log('requiredValidationFailed ' + requiredValidationFailed);
            if (!requiredValidationFailed) {
                helper.onCumulativeSave(component, event, helper);
            } else {
                const errorMessage = component.get("v.requiredValidationFailedErrorMessage");
                if (errorMessage) {
                    // helper.showOnErrorToast(component.get("v.requiredValidationFailedErrorTitle"), errorMessage);
                } else {
                    const language = component.get("v.listPageElements")[0].CurrentLanguageCode;
                    helper.getMessage(component, "error_fields_required", language, (title, message) => {
                        component.set("v.requiredValidationFailedErrorTitle", title);
                        component.set("v.requiredValidationFailedErrorMessage", message);

                        //  helper.showOnErrorToast(title, message);
                    });
                }
                //var requiredValidationFailedErrorMessage = component.get("v.requiredValidationFailedErrorMessage");
                //helper.showOnErrorToast(component, event, helper, requiredValidationFailedErrorMessage);
            }

        } else {
            // //alert('CAPTCHA NEEDED');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error Message',
                message: 'Captcha REQUIRED!!!!!!',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
    onSubmitForm: function (component, event, helper) {
        //alert('Inside onSubmitForm - This should never get called');
        event.preventDefault();
    },
    onSubmitSuccess: function (component, event, helper) {
        //Start - Experian related change
        var urlKey = component.get("v.currentSitePage.urlKey");
        if (urlKey !== 'ccpa') {
            component.set("v.successPopup", true);
        }
        //End - Experian related change
        var payload = event.getParams().response;
        var submittedRecordId = payload.id;

        component.set("v.recordId", submittedRecordId);

        var gotObjectRecordIdInContext = $A.get("e.c:F3_GotObjectRecordIdInContext");
        gotObjectRecordIdInContext.setParams({
            "recordIdInContext": submittedRecordId
        });
        gotObjectRecordIdInContext.fire();
        console.log('Submitted Record ID', submittedRecordId);

        var action = component.get("c.getCaseDetails");
        action.setParams({
            "caseId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var res = JSON.stringify(response.getReturnValue());
            var parseres = JSON.parse(res);

            console.log('Response ', parseres.First_Name_GDPR_AGN__c);
            component.set("v.firstName", parseres.First_Name_GDPR_AGN__c);
            component.set("v.lastName", parseres.Last_Name_GDPR_AGN__c);
        });
        $A.enqueueAction(action);


        console.log('FirstName ', component.get("v.firstName"));
        helper.saveChildComponents(component, event, helper);
        helper.navigateStep(component, event, helper);
		component.set("v.showSpinner", false); //Experian related change
        //Start - Experian related change
        //this is only applicable for CCPA portal
        if (urlKey === 'ccpa') {
            //Navigation Event needs to be fired.
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/submit-answer?caseid=" + submittedRecordId
            });
            urlEvent.fire();
        }
        //End - Experian related change
    },
    PopupOK: function () {
        $A.get('e.force:refreshView').fire();
    },
    onSubmitError: function (component, event, helper) {
        /*
        var eventName = event.getName();
        console.log('eventName:::'+eventName);
    	var eventDetails = event.getParam("error");
        console.log('error----'+JSON.stringify(eventDetails));
    	////alert('Error Event received' + eventDetails);
        
        ////alert('TBD - onSubmitError');
        
       // component.set("v.hasOtherErrors", true);
       // helper.showOnErrorToast("Unknown Error", hasOtherErrorsMessage); */
    },
    onEditFormLoad: function (component, event, helper) {
        helper.onEditFormLoad(component, event, helper);
    },
    accessibilityAction: function (component, event, helper) {
        try {
            switch (event.getParams().action) {
                case "decreaseFontSize":
                    helper.applyStyleAction(component, helper.decreaseFontSize);
                    break;
                case "increaseFontSize":
                    helper.applyStyleAction(component, helper.increaseFontSize);
                    break;
                case "increaseLetterSpacing":
                    helper.applyStyleAction(component, helper.increaseLetterSpacing);
                    break;
                case "highContrastWhite":
                    helper.applyStyleAction(component, helper.highContrastWhite);
                    break;
                case "highContrastYellow":
                    helper.applyStyleAction(component, helper.highContrastYellow);
                    break;
                case "reset":
                    helper.setDefaultStyle(component);
                    break;
                default:
                    return;
            }
        } catch (err) {
            console.error(err);
        }
    },
    componentViewStateHandler: function (component, event, helper) {

        var selectedValueJSON = event.getParam("param");
        console.log('On change visibility change--' + selectedValueJSON);
        var listFieldVisibility = selectedValueJSON.VisisbilityArray;

        for (var i = 0; i < listFieldVisibility.length; i++) {
            var formField = listFieldVisibility[i];
            var listFormStepElements = component.find("formstepComponent");

            for (var j = 0; j < listFormStepElements.length; j++) {
                if (listFormStepElements[j].get("v.elementWrapper").DeveloperName == formField.DeveloperName) {
                    listFormStepElements[j].set("v.elementWrapper.class", formField.visibility);
                    helper.modifyViewState(component, event, helper, formField.DeveloperName, formField.visibility);
                    break;
                }
            }
        }
    }
})