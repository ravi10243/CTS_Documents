/* eslint-disable no-console */

//Import Custom Labels
import AGN_OAM_SAVE from "@salesforce/label/c.AGN_OAM_Save";
import AGN_OAM_NEW_PASSWORD from "@salesforce/label/c.AGN_OAM_New_Password";
import AGN_OAM_RECOVERY_ANSWER from "@salesforce/label/c.AGN_OAM_Recovery_Answer";
import AGN_OAM_CONFIRM_PASSWORD from "@salesforce/label/c.AGN_OAM_Confirm_Password";
import AGN_OAM_RECOVERY_QUESTION from "@salesforce/label/c.AGN_OAM_Recovery_Question";
import AGN_OAM_BODY_CHANGEPASSWORD from "@salesforce/label/c.AGN_OAM_Body_ChangePassword";
import AGN_OAM_OKTA_PASSWORD_POLICY from "@salesforce/label/c.AGN_OAM_Okta_Password_Policy";
import AGN_OAM_Recovery_Link_Expired from "@salesforce/label/c.AGN_OAM_Recovery_Link_Expired";
import AGN_GCSP_Redirecting from "@salesforce/label/c.AGN_GCSP_Redirecting";
import AGN_OAM_NEW_PASSWORD_AND_CONFIRMATION_NOT_SAME from "@salesforce/label/c.AGN_OAM_New_Password_and_Confirmation_not_same";
import AGN_OAM_BODY_CHANGE_RECOVERY_QUESTION_PASSWORD_AGN from "@salesforce/label/c.AGN_OAM_Body_Change_Recovery_Question_Password_AGN";

//import apex methods
import validateAccountActivationToken from "@salesforce/apex/AGN_GCSP_OktaAuthController.validateAccountActivationToken";
import getLabelString from "@salesforce/apex/AGN_GCSP_OktaAuthController.getLabelString";
import updateOktaPwdRecovery from "@salesforce/apex/AGN_GCSP_OktaAuthController.updateOktaPwdRecovery";

import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    LightningElement,
    api,
    track
} from "lwc";
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';
import LANG from '@salesforce/i18n/lang';
import LOCALE from '@salesforce/i18n/locale'; 

export default class AGN_GCSP_account_activation extends LightningElement {
    @track securityQtsLabelVal;
    @api oktaUserNameString;
    @track oktaNewPasswordString;
    @track oktaNewConfirmPasswordString;
    @track oktaSecurityQuestionString;
    @track oktaSecurityAnsString;
    @track userLanguage;
    @api showSpinner = false;
    @track renderContent = false;
    @track renderPW = false;
    @track activationToken;
    @track passwordResetKey;
    @track customerContactId;
    @track securityQuestionSelectOption = [];
    @track settingPWD = false;

    // Expose the labels to use in the template.
    label = {
        AGN_OAM_NEW_PASSWORD_AND_CONFIRMATION_NOT_SAME,
        AGN_OAM_SAVE,
        AGN_OAM_BODY_CHANGEPASSWORD,
        AGN_OAM_RECOVERY_QUESTION,
        AGN_OAM_NEW_PASSWORD,
        AGN_OAM_RECOVERY_ANSWER,
        AGN_OAM_CONFIRM_PASSWORD,
        AGN_OAM_OKTA_PASSWORD_POLICY,
        AGN_OAM_BODY_CHANGE_RECOVERY_QUESTION_PASSWORD_AGN
    };

    renderedCallback() {
        loadStyle(this, ASSETS + '/assets/agn_gcsp_registration.css');
        loadStyle(this, ASSETS1 + '/css/style.css');   
        loadStyle(this, ASSETS1 + '/css/footer.css');
    }

    connectedCallback() {
        this.renderPW = true;
        this.validateRequest(); 
    }

    handleFormInputChange(event) {
        switch (event.target.name) {
            case "txtNewPassword":
                this.oktaNewPasswordString = event.target.value;
                break;
            case "txtNewConfirmPassword":
                this.oktaNewConfirmPasswordString = event.target.value;
                break;
            case "cmbRecoveryQuestions":
                this.oktaSecurityQuestionString = event.target.value;
                break;
            case "cmbRecoveryAnswer":
                this.oktaSecurityAnsString = event.target.value;
                break;
            default:
        }
    }

    validateAccountActivationToken() {
        this.showSpinner = true;
        validateAccountActivationToken({
                activationToken: this.activationToken
            })
            .then(data => {
                //console.log(data);
                let result = JSON.parse(data);
                if (result.responseType) {
                    if (result.responseType === 'SUCCESS') {
                        this.passwordResetKey = result.passwordResetKey;
                        this.customerContactId = result.customerContactId;
                        this.userLanguage = result.userLanguage;
                        this.oktaUserNameString = result.userEmail;
                        this.renderContent = true;
                        this.showSpinner = false;

                        let selectedLanguage;
                        let defaultLanguage = "EN_US"; //default
                        let securityQuestionCustomLabelDefinedCountries = ["DE", "ES", "FR", "IT", "EN_AU", "EN_GB", "EN_NZ", "EN_US", "EN_CA", "FR_CA", "PT_BR"];

                        selectedLanguage = selectedLanguage = this.userLanguage; 
                        //this.getUrlParamValue("language");
                       
                        if (selectedLanguage && selectedLanguage.trim() !== "" && securityQuestionCustomLabelDefinedCountries.includes(selectedLanguage.toUpperCase())) {
                            this.fetchSecurityQuestionCustomLabel(selectedLanguage.toUpperCase());
                        } else {
                            this.fetchSecurityQuestionCustomLabel(defaultLanguage);
                        }

                    } else {
                        this.dispatchToastEvent(result.response, "error");
                    }
                } else {
                    console.error(JSON.stringify(data));
                }
                this.showSpinner = false;
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.showSpinner = false;
            });
    }

    validateRequest() {
        let token = this.getUrlParamValue("token");
        /* let showQA = this.getUrlParamValue("r"); // if found => only show Q&A (skip showing password option) else show both Q&A and password
        if (showQA && showQA.trim() !== "") {
            this.renderPW = false; //render only Q&A options
        }
        else {
            this.renderPW = true; //render Q&A and password options
        } */

        if (token && token.trim() !== "") {
            this.activationToken = token;
            //this.renderContent = true;
            this.validateAccountActivationToken();
        } else {
            this.renderContent = false;
            this.dispatchToastEvent(AGN_OAM_Recovery_Link_Expired, "error");
        }
    }

    fetchSecurityQuestionCustomLabel(lang) {
        //console.log('labelName ->' + lang);
        this.securityQuestionSelectOption = [];
        getLabelString({
                lang: lang
            })
            .then(data => {
                //console.log(data);
                this.securityQtsLabelVal = data;

                if (this.securityQtsLabelVal.trim() !== "") {
                    let securityQuestions = [];
                    this.securityQtsLabelVal.split("_").forEach(function (item) {
                        const option = {
                            label: item,
                            value: item
                        };
                        securityQuestions.push(option);
                    });
                    //console.log(securityQuestions);
                    //this.securityQuestionSelectOption = [...this.securityQuestionSelectOption, securityQuestions];
                    this.securityQuestionSelectOption = securityQuestions;
                }
            })
            .catch(error => {
                console.error(JSON.stringify(error));
            });
    }

    isAllFieldsValid() {
        const allInputValid = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        const allComboValid = [
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allInputValid && allComboValid;
    }

    handlePwdRecovery() {
        /* //console.log('passwordResetKey:' + this.passwordResetKey);
        //console.log('oktaSecurityQuestionString:' + this.oktaSecurityQuestionString);
        //console.log('oktaSecurityAnsString:' + this.oktaSecurityAnsString);
        //console.log('oktaNewPasswordString:' + this.oktaNewPasswordString); */
        const allValid = this.isAllFieldsValid();
        if (allValid) {
            if (this.oktaNewConfirmPasswordString !== this.oktaNewPasswordString) {
                this.dispatchToastEvent(AGN_OAM_NEW_PASSWORD_AND_CONFIRMATION_NOT_SAME, "error");
                return;
            }
            this.showSpinner = true;
            updateOktaPwdRecovery({
                    renderPW: this.renderPW,
                    customerContactId: this.customerContactId,
                    passwordResetKey: this.passwordResetKey,
                    selectedRecoveryQuestion: this.oktaSecurityQuestionString,
                    recoveryAnswer: this.oktaSecurityAnsString,
                    newPassword: this.oktaNewPasswordString,
                    userEmail: this.oktaUserNameString,
                    userLanguage: this.userLanguage
                })
                .then(result => {
                    if (result) {
                        //console.error(JSON.stringify(result));
                        let data = JSON.parse(result);
                        if (data.responseType && data.responseType === 'SUCCESS') {
                            this.showSpinner = false;
                            this.renderContent = false;
                            this.settingPWD = true;
                            this.dispatchToastEvent(AGN_GCSP_Redirecting, "success");
                            window.location.href = data.response;
                        } else {
                            this.showSpinner = false;
                            this.dispatchToastEvent(data.response, "error");
                        }
                    } else {
                        this.showSpinner = false;
                        this.dispatchToastEvent("Unknown Error", "error");
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.error(JSON.stringify(error));
                });
        }
    }

    get options() {
        var securityQuestions = [];
        this.securityQtsLabelVal.split("_").forEach(function (item) {
            const option = {
                label: item,
                value: item
            };
            securityQuestions.push(option);
        });
        return securityQuestions;
    }

    getUrlParamValue(key) {
        return new URL(window.location.href).searchParams.get(key);
    }

    dispatchToastEvent(messageString, messageType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "",
                message: messageString,
                variant: messageType,
                mode: "dismissable"
            })
        );
    }
}