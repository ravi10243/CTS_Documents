/************************************************************************************************************
@FileName:          agnAccountHierarchyNode.js 
@Version:           1.0
@Author:            Ayush Basak (ayush.basak@cognizant.com)
@Purpose:           This component is created to act as the individual nodes on the account hierarchy tree
-------------------------------------------------------------------------------------------------------------
@ Change history: 04.01.2021 / Ayush Basak / Created the file.
*************************************************************************************************************/
import { api, LightningElement, wire } from 'lwc';

// Apex Method to fetch data in the node structure
import getNodeDetail from '@salesforce/apex/AGN_Account_Hierarchy_Helper.getNodeDetail';

import ERRORMESSAGE from '@salesforce/label/c.AGN_Account_Hierarchy_Error';
const NODE_STYLE = "slds-p-right_none node";
const CURRENT = ' current';

export default class AgnAccountHierarchyNode extends LightningElement {

    // Public variable to accept the Id of the account for which information is to be displayed on the node
    @api accountId;
    // Public variable to accept the Id of the account for which hierarchy is displayed
    @api recordId;
    // Public variable to accept the list of Ids which are in the direct line from top HCO to the 
    // account for which hierarchy is displayed
    @api hierarchy;
    // Public variable to accept the list of sObject buttons and other dependant settings
    @api tableConfigs;
    // Reactive variable to accept node data from imperative apex call, and display
    record;
    // This variable set to false when component is inserted and to true when apex promise is completed
    // Controls spinner at component load  
    rendered;
    // This variable controls the load of children records
    isExpanded;
    // Reactive variable, created from tableConfigs for ease of access on template
    buttonConfig;
    // Reactive variable used to control the visibility of datatable on click on buttons on the node
    isDatatableVisible;
    // Store and pass the selected sObject api name to child datatable component
    selectedObject;
    // Store and pass column configuration to child datatable component
    selectedColumn;
    // Store and pass logic to parse hierarchy JSON into flat JSON to child datatable component
    selectedFlatteningSchema;
    // Styling control variable to separate current node from other nodes
    nodeStyle = NODE_STYLE;
    
    // Map of Labels
    label = {
        errorMessage : ERRORMESSAGE
    };

    // Action to be executed on insertion of the component
    connectedCallback() {
        this.rendered = false;
        this.isDatatableVisible = false;
    }

    // Action to be performed once all the public attributes are set by parent components.
    renderedCallback() {
        // Check to prevent recursive imperative call on render or without accountId being set from parent
        if(!this.rendered && this.accountId != null) {
            let hierarchyString = String(this.hierarchy) + ',' + this.recordId;
            // Making imperative apex call to node details and setting to record variable
            getNodeDetail({ recordId: this.accountId, hierarchy: hierarchyString })
                .then(result => {
                    this.record =  result;
                })
                .catch(error => {
                    console.log(error);
                    this.wireError =  error.body.message;
                })
                // Switching off loader spinner and allow display of data
                .finally(() => {
                    this.buttonSetup();
                    // Setting style class to current, to allow highlighting of the node
                    if(this.recordId.substr(0,15) == this.accountId.substr(0,15)) {
                        this.nodeStyle = this.nodeStyle + CURRENT;
                    }
                    // Checking if current node is in direct hierarchy line of pov account 
                    // and top account in the hierarchy, if yes, the same is kept open
                    this.isExpanded = this.hierarchy.includes(this.accountId);
                });
        }
    }

    // If accordion is opened, isExpanded is set to true, so child records are loaded
    handleSectionToggle(event) {
        this.isExpanded = true;
    }

    // This function supports button show button click
    // It checks for which sObject the button was clicked and sets the information 
    // from that config record to selected variables to be passed to child datatable
    showRequest(event) {
        const accordion = this.template.querySelector('.accordion');
        accordion.activeSectionName = this.record.account.Id;
        this.isDatatableVisible = false;
        this.isExpanded = true;
        this.selectedObject = event.target.dataset.object;
        let tempConfigs = [];
        this.buttonConfig.forEach(button => {
            if(button.sObject == this.selectedObject) {
                button.toggled = true;
                this.selectedColumn = button.column;
                this.selectedFlatteningSchema = button.schema;
            }
            else {
                button.toggled = false;
            }
            tempConfigs.push(button);
        });
        this.buttonConfig = tempConfigs;
        this.isDatatableVisible = true;
    }

    // This function supports button hide button click
    // It closes toggles the datatable visibility to off and update the buttons
    hideRequest(event) {
        this.selectedObject = event.target.dataset.object;
        let tempConfigs = [];
        this.buttonConfig.forEach(button => {
            if(button.sObject == this.selectedObject) {
                button.toggled = false;
            }
            tempConfigs.push(button);
        });
        this.buttonConfig = tempConfigs;
        this.isDatatableVisible = false;
    }

    // Reads through the tableConfigs and creates buttonConfigs, for ease of access on template
    buttonSetup() {
        let buttons = [];
        if(this.tableConfigs != null) {
            let configJSON = JSON.stringify(this.tableConfigs);
            let config = JSON.parse(configJSON);
            config.forEach(config => {
                let buttonConfig = new Object();
                buttonConfig.sObject = config.sObject_AGN__c;
                buttonConfig.toggled = false;
                buttonConfig.visible = true;
                buttonConfig.onLabel = config.Show_Label_AGN__c;
                buttonConfig.offLabel = config.Hide_Label_AGN__c;
                buttonConfig.column = config.Column_Configuration_AGN__c;
                buttonConfig.schema = config.JSON_Flattener_AGN__c;
                buttons.push(buttonConfig);                  
            });     
            this.rendered = true;       
        }
        else {
            setTimeout(this.buttonSetup,100);
        }
        this.buttonConfig = buttons;
    }
}