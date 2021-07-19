/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 05-29-2021
 * @last modified by  : Avik Shaw
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-07-2021   Ravi Sirigiri   Initial Version
 * 1.1   05-29-2021   Avik Shaw       for PMO 2871 Brazil
**/
import { LightningElement, api ,track } from 'lwc';

export default class Agn_gcsp_accountUpdateWrapper extends LightningElement {

    @track countryCode;
    //@track country;
    @track language;
    @api source;
    @api sourceOAM;
    @api sourceCS;
    @api soldToSAPId;
	@api crRecord;

    @api existingSoldTo;
    @api existingShipTo;
    @api existingBillTo;

    isContacts = false;
    caseId;
    isShowDeactivateButton;
    isOnlineRegistration;

    connectedCallback() {
        this.showLoader = true;
        this.hidemaindiv = true;

        this.source = (this.sourceOAM) ? this.sourceOAM : (this.sourceCS) ? this.sourceCS : '';
        this.isOnlineRegistration = (this.sourceOAM) ? true : false;
        if (this.sourceCS && this.sourceCS == 'cs') {
            this.isShowDeactivateButton = true;
        }
        //console.log('this.soldToSAPId>>>>>>'+this.soldToSAPId);
        //console.log('this.source>>>>>>'+this.source);
       // this.getSapDetails(this.soldToSAPId, this.source);
    }   
    
    handleSave(event){ 
           
        const eventParemeters = event.detail;
        if(eventParemeters.caseId)
        {
            this.caseId =  eventParemeters.caseId; 
            this.soldToSAPId = eventParemeters.soldToSAPId;
            this.isContacts = true;
            this.existingSoldTo = eventParemeters.existingSoldTo;
            this.existingShipTo = eventParemeters.existingShipTo;
            this.existingBillTo = eventParemeters.existingBillTo;
        }        
        //console.log("eventParemeters>>>"+JSON.stringify(eventParemeters));
    }

}