/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 02-25-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   02-02-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const DELAY = 3000;

export default class Agn_GCSP_completedRegistration extends LightningElement {
    @api isStep1;
    @api isStep2;
    @api isStep3;
    @api isStep4;

    @api RegistrationStepNo;
    @api caseId;
    @api sourceCS;
    @api accountId;

  
    connectedCallback(){
        //console.log('caseId::::', this.caseId);
        //console.log('RegistrationStepNo::::', this.RegistrationStepNo);
        //console.log('sourceCS::::', this.sourceCS);        
        //this.showToast('Success' , this.sourceCS , 'Success');
      this.assignisStepValue(this.RegistrationStepNo);        
    }

    assignisStepValue(stepNo){
        this.isStep1 = false;
        this.isStep2 = false;
        this.isStep3 = false;
        this.isStep4 = false;
        this.isContacts = false;
        switch (stepNo) {
            case '1':
                this.isStep1 = true;
                break;
            case '2':
                this.isStep2 = true;
                break;
            case '3':
                this.isStep3 = true;
                break;
            case '4':
                this.isStep4 = true;
                break;
            case '0':
                this.isContacts = true;
                break;
            default:
                this.isStep1 = true;
                break;
        }
    }

    handleChangeEvent(event) {
        //console.log('customeEvent', event);
        let stepNo = event.detail.stepNo;
        this.caseId = event.detail.caseId;
        this.assignisStepValue(stepNo);
    }

    showToast(title , message , variant) {
        const event = new ShowToastEvent({
            title: title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(event);
    } 

    clearErrorMessage() {
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
          this.error = undefined;
        }, DELAY);
      }

}