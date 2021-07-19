/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 04-27-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-13-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import forgotPassword from "@salesforce/apex/AGN_GCSP_OktaAuthController.forgotPassword";
import getOktaSecurityQuestion from "@salesforce/apex/AGN_GCSP_OktaAuthController.getOktaSecurityQuestion";
import forgotRecoveryQA from "@salesforce/apex/AGN_GCSP_OktaAuthController.forgotRecoveryQA";

import AGN_OAM_RESET_PASSWORD from "@salesforce/label/c.AGN_OAM_Reset_Password";
import AGN_OAM_BODY_FORGOTPASSWORD from "@salesforce/label/c.AGN_OAM_Body_ForgotPassword";
import AGN_OAM_BODY_ENTERUSERNAME from "@salesforce/label/c.AGN_OAM_Body_EnterUsername";
import AGN_OAM_RECOVERY_QUESTION from "@salesforce/label/c.AGN_OAM_Recovery_Question";
import AGN_OAM_NEW_PASSWORD from "@salesforce/label/c.AGN_OAM_New_Password";
import AGN_OAM_RECOVERY_ANSWER from "@salesforce/label/c.AGN_OAM_Recovery_Answer";
import AGN_OAM_CONFIRM_PASSWORD from "@salesforce/label/c.AGN_OAM_Confirm_Password";
import AGN_OAM_NEW_PASSWORD_AND_CONFIRMATION_NOT_SAME from "@salesforce/label/c.AGN_OAM_New_Password_and_Confirmation_not_same";
import AGN_OAM_OKTA_PASSWORD_POLICY from "@salesforce/label/c.AGN_OAM_Okta_Password_Policy";
import AGN_OAM_FORGOT_RECOVERY_QUESTIONS_ANSWER from "@salesforce/label/c.AGN_OAM_Forgot_recovery_questions_answer";
import AGN_OAM_CLICK_HERE_TO_RESET from "@salesforce/label/c.AGN_OAM_Click_here_to_reset";
import AGN_OAM_SUCCESSFULLY_RESET_AND_CHECK_INBOX from "@salesforce/label/c.AGN_OAM_Successfully_reset_and_check_inbox";
import AGN_GCSP_Redirecting from "@salesforce/label/c.AGN_GCSP_Redirecting";

import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';

export default class AGN_GCSP_changePassword extends LightningElement {
    //@track labelVal;
    @api oktaUserNameString;
    @track oktaNewPasswordString;
    @track oktaNewConfirmPasswordString;
    @track oktaSecurityQuestionString;
    @track oktaSecurityAnsString;
    @track validUsername;
    @track securityQuestionSelectOption = [];
    @api showSpinner = false;

    // Expose the labels to use in the template.
    label = {
        AGN_OAM_NEW_PASSWORD_AND_CONFIRMATION_NOT_SAME,
        AGN_OAM_RESET_PASSWORD,
        AGN_OAM_BODY_FORGOTPASSWORD,
        AGN_OAM_BODY_ENTERUSERNAME,
        AGN_OAM_RECOVERY_QUESTION,
        AGN_OAM_NEW_PASSWORD,
        AGN_OAM_RECOVERY_ANSWER,
        AGN_OAM_CONFIRM_PASSWORD,
        AGN_OAM_OKTA_PASSWORD_POLICY,
        AGN_OAM_FORGOT_RECOVERY_QUESTIONS_ANSWER,
        AGN_OAM_CLICK_HERE_TO_RESET,
        AGN_OAM_SUCCESSFULLY_RESET_AND_CHECK_INBOX
    };
    renderedCallback() {
        loadStyle(this, ASSETS + '/assets/agn_gcsp_registration.css');
        loadStyle(this, ASSETS1 + '/css/style.css');   
        loadStyle(this, ASSETS1 + '/css/footer.css');
     }
    connectedCallback() {
        this.validUsername = false;
        this.oktaUserNameString = this.getUrlParamValue("un");
        if (this.oktaUserNameString && this.oktaUserNameString.trim() !== "") {
            this.getOktaSecurityQuestion();
        }
    }

    /* get options() {
        var securityQuestions = [];
        this.labelVal.split("_").forEach(function (item) {
            const option = {
                label: item,
                value: item
            };
            securityQuestions.push(option);
        });
        return securityQuestions;
    } */

    securityQOption() {
        this.securityQuestionSelectOption = [];
        const startSelect = this.template.querySelector('.question-select');
        if (this.oktaSecurityQuestionString && this.oktaSecurityQuestionString.trim() !== "") {
            const option = {
                label: this.oktaSecurityQuestionString,
                value: this.oktaSecurityQuestionString
            };
            this.securityQuestionSelectOption = [...this.securityQuestionSelectOption, option];
        }
        if (startSelect) {
            startSelect.value = this.oktaSecurityQuestionString;
        }
    }

    getUrlParamValue(key) {
        return new URL(window.location.href).searchParams.get(key);
    }

    handleFormInputChange(event) {

        switch (event.target.name) {
            case "txtUsername":
                this.oktaUserNameString = event.target.value;
                break;
            case "txtNewPassword":
                this.oktaPasswordString = event.target.value;
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

    getOktaSecurityQuestion() {
        if (this.oktaUserNameString.trim() !== "") {
            this.showSpinner = true;
            getOktaSecurityQuestion({
                    oktaUserName: this.oktaUserNameString
                })
                .then(result => {
                    if (result) {
                        let data = JSON.parse(result);
                        //console.log('data::::: ',data);
                        if (data.responseType && (data.responseType === 'USER_NOT_FOUND_SFDC' ||
                                data.responseType === 'OKTA_ERROR_UNDEFINED_RECOVERY_Q' ||
                                data.responseType === 'OKTA_ERROR_UNKNOWN')) {

                            this.validUsername = false;
                            this.oktaSecurityQuestionString = undefined;
                            this.securityQOption();
                             this.dispatchToastEvent(data.response, "error");
                        } else if (data.responseType && data.responseType === 'SUCCESS') {
                            this.validUsername = true;
                            this.oktaSecurityQuestionString = data.recoveryQuestion;
                            this.securityQOption();
                        }
                        this.showSpinner = false;
                    } else {
                        this.validUsername = false;
                        this.oktaSecurityQuestionString = undefined;
                        this.securityQOption();
                        this.dispatchToastEvent("Unknown Error", "error");
                        this.showSpinner = false;
                    }
                })
                .catch(error => {
                    console.error(error);
                    this.showSpinner = false;
                });
        }
    }

    handleBlur(event) {
        this.showSpinner = false;
        switch (event.target.name) {
            case "txtUsername":
                this.oktaUserNameString = event.target.value;
                this.getOktaSecurityQuestion();
                break;
            default:
        }
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

    handleChangePassword() {
        this.showSpinner = false;
        const allValid = this.isAllFieldsValid();
        if (allValid) {
            //let newPassword = this.template.querySelector(".inputNewPassword");
            //let confPassword = this.template.querySelector(".inputNewConfirmPassword");
            if (this.oktaNewConfirmPasswordString !== this.oktaPasswordString) {
                this.dispatchToastEvent(AGN_OAM_NEW_PASSWORD_AND_CONFIRMATION_NOT_SAME, "error");
                /* newPassword.setCustomValidity(AGN_OAM_NEW_PASSWORD_AND_CONFIRMATION_NOT_SAME);
                newPassword.reportValidity();

                confPassword.setCustomValidity(AGN_OAM_NEW_PASSWORD_AND_CONFIRMATION_NOT_SAME);
                confPassword.reportValidity(); */
                return;
            }

            //console.log("uname->" + this.oktaUserNameString);
            this.showSpinner = true;
            forgotPassword({
                    oktaUserName: this.oktaUserNameString,
                    oktaNewPassword: this.oktaPasswordString,
                    oktaSecurityAns: this.oktaSecurityAnsString
                })
                .then(result => {
                    if (result) {
                        let data = JSON.parse(result);
                        if (data.responseType && (data.responseType === 'USER_NOT_FOUND_SFDC' ||
                                data.responseType === 'OKTA_ERROR_UNKNOWN' ||
                                data.responseType === 'OKTA_ERROR_UNDEFINED_RECOVERY_Q')) {

                            this.validUsername = false;
                            this.oktaSecurityQuestionString = undefined;
                            this.securityQOption();
                            this.showSpinner = false;
                            this.dispatchToastEvent(data.response, "error");
                        } else if (data.responseType && data.responseType === 'OKTA_ERROR') {
                            this.validUsername = false;
                            this.oktaSecurityQuestionString = data.recoveryQuestion;
                            this.securityQOption();
                            this.showSpinner = false;
                            this.dispatchToastEvent(data.response, "error");
                        } else if (data.responseType && data.responseType === 'SUCCESS') {
                            this.validUsername = true;
                            this.showSpinner = false;
                            //this.oktaSecurityQuestionString = data.recoveryQuestion;
                            this.dispatchToastEvent(AGN_GCSP_Redirecting, "success");
                            window.location.href = data.response;
                        }
                    } else {
                        this.validUsername = false;
                        this.showSpinner = false;
                        this.dispatchToastEvent("Unknown Error", "error");
                    }
                })
                .catch(error => {
                    console.error(error);
                    this.showSpinner = false;
                });
        }
    }
    handleForgotSecQuestion() {
        let inputUsername = this.template.querySelector(".inputUsername");
        inputUsername.reportValidity();
        if (!inputUsername.checkValidity()) {
            this.dispatchToastEvent(AGN_OAM_BODY_ENTERUSERNAME, "error");
        } else {
            if (this.oktaUserNameString.trim() !== "") {
                this.showSpinner = true;
                getOktaSecurityQuestion({
                        oktaUserName: this.oktaUserNameString
                    })
                    .then(result => {
                        if (result) {
                            let data = JSON.parse(result);
                            if (data.responseType && (data.responseType === 'USER_NOT_FOUND_SFDC')) {

                                this.validUsername = false;
                                this.oktaSecurityQuestionString = undefined;
                                this.securityQOption();
                                this.dispatchToastEvent(data.response, "error");
                            } else if (data.responseType && (data.responseType === 'SUCCESS' || data.responseType === 'OKTA_ERROR_UNDEFINED_RECOVERY_Q')) {
                                forgotRecoveryQA({
                                        userEmail: this.oktaUserNameString
                                    })
                                    .then(resp => {
                                        console.error(resp);
                                        if (resp) {
                                            this.showSpinner = false;
                                            this.dispatchToastEvent(AGN_OAM_SUCCESSFULLY_RESET_AND_CHECK_INBOX, "success");
                                        }
                                    })
                                    .catch(error => {
                                        console.error(error);
                                        this.showSpinner = false;
                                    });
                            }
                            this.showSpinner = false;
                        }
                    })
                    .catch(error => {
                        console.error(error);
                        this.showSpinner = false;
                    });
            }
        }
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