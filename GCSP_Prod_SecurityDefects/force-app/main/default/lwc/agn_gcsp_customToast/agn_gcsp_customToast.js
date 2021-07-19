import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Agn_gcsp_customToast extends LightningElement {
    @api title = 'Sample Title';
    @api message = 'Sample Message';
    @api variant = 'error';
    @api autoCloseTime = 3000;
    @api autoClose = false;
    @api autoCloseErrorWarning = false;

    showNotification() {

        if (ShowToastEvent) {
            const evt = new ShowToastEvent({
                title: this.title,
                message: this.message,
                variant: this.variant               
            });
            this.dispatchEvent(evt);
        }
    }

    @api
    showCustomNotice() {

        const toastModel = this.template.querySelector(`[data-id="toastModel"]`);
        toastModel.className = 'slds-show';
        //this.variant = this.variant.toLowerCase();
        //console.log('toastModel1>>>');        
        if (this.autoClose)
            if ((this.autoCloseErrorWarning && this.variant !== 'success') || this.variant === 'success' || this.variant === 'error') {
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                this.delayTimeout = setTimeout(() => {
                    const toastModel1 = this.template.querySelector(`[data-id="toastModel"]`);
                    toastModel1.className = 'slds-hide';
                    //console.log('toastModel2>>>' );  
                }, this.autoCloseTime);

            }
    }
    @api
    closeModel() {
        const toastModel = this.template.querySelector('[data-id="toastModel"]');
        toastModel.className = 'slds-hide';
    }

    get mainDivClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.variant;
    }

    get messageDivClass() {
        return 'slds-icon_container slds-icon-utility-' + this.variant + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
    get iconName() {
        return 'utility:' + this.variant;
    }
}