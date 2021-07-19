/**
 * @description: Deleted the selected address record.
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 01-20-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-20-2021   Ravi Sirigiri   Initial Version
**/
import {
    LightningElement,
    api
} from 'lwc';

export default class Agn_gcsp_addressDelete extends LightningElement {
    @api index;
    @api shippingMapCounter;
    @api instancetype;
    @api recordId;

    handleClick() {
        //console.log('dispatching event>>>>>>>');
        var headerData = {
            index: this.index,
            instancetype: this.instancetype,
            recordId: this.recordId
        };
        const shiptoAddressDeleteEvent = new CustomEvent('shiptoaddressdelete', {
            detail: headerData
        });

        // Dispatches the event.
        this.dispatchEvent(shiptoAddressDeleteEvent);

    }

}