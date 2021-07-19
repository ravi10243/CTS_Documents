/************************************************************************************************************
@FileName:          agnAccountHierarchy.js 
@Version:           1.0
@Author:            Ayush Basak (ayush.basak@cognizant.com)
@Purpose:           This is the account hierarchy component, to be displayed on Account page layout.
                    This components gets the top most parent node for a given account and creates the 
                    account tree by the hierarchy node component 
-------------------------------------------------------------------------------------------------------------
@ Change history: 04.01.2021 / Ayush Basak / Created the file.
*************************************************************************************************************/
import { LightningElement, api } from 'lwc';
// Apex method to get the account hierarchy to the top most account frmo the current account
import getAccountTree from '@salesforce/apex/AGN_Account_Hierarchy_Helper.getAccountTree';
// Apex method to get the configuration of datatables to be displayed in hierarchy tree
import getTableConfigs from '@salesforce/apex/AGN_Account_Hierarchy_Helper.getTableConfigs';


export default class AgnAccountHierarchy extends LightningElement {
    // This variable accepts the current account id from parent and sets it to child nodes
    @api record;
    // This variable is set by apex callback method, with the list ids of all the accounts which are above 
    // the current account in heirarchy
    hierarchy;
    // This variable is set to the highest node on the hierarchy variable.
    topNodeId;
    // This variable set to false when component is inserted and to true when apex promise is completed
    // Controls spinner at component load  
    rendered;

    tableConfigs;

    connectedCallback() {
        this.rendered = false;
        // Getting the account hierarchy and top most node, and the table and button setup from metadata
        getAccountTree({ recordId: this.record })
            .then(result => {
                this.hierarchy =  result;
                if(String(this.hierarchy) == '') {
                    this.topNodeId = this.record;
                }
                else if(Array.isArray(this.hierarchy)) {
                    this.topNodeId = this.hierarchy[this.hierarchy.length - 1];
                }
                else {
                    this.topNodeId = this.record;
                }
                return getTableConfigs({});
            })
            .then(result => {
                this.tableConfigs = result;
                console.log(this.tableConfigs);
            })
            .catch(error => {
                this.wireError =  error.body.message;
            })
            .finally(() => {
                this.rendered = true;
            });
        
    }
}