/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 03-01-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   02-04-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement, api, track } from 'lwc';

export default class Agn_gcsp_addressFlatView extends LightningElement {

    @api addressFields;
    @api addressData;

    @track addressFlatViewData;

    connectedCallback(){

        let addFields = this.addressFields;
        let addData = this.addressData;
       // //console.log('addFields::::', addFields);
       // //console.log('addData::::', addData);
        let addFlatView = '';
        
        for (var i in addFields) {
            var fieldValue = addData[addFields[i].Field_Name_AGN__c];
            //As per the requirements, No need to display true/false values
            if (fieldValue && fieldValue != true && fieldValue != false) {
                addFlatView += fieldValue + ', ';
            }
        }
      
        this.addressFlatViewData = addFlatView.replace(/,\s*$/, "");

        //console.log('addFlatView:::::  ', this.addressFlatViewData);

    }

}