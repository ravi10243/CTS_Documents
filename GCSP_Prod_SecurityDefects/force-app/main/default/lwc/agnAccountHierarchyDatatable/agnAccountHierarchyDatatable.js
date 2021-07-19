/************************************************************************************************************
@FileName:          agnAccountHierarchyDatatable.js 
@Version:           1.0
@Author:            Ayush Basak (ayush.basak@cognizant.com)
@Purpose:           This component is to display related records of the accounts on individual account nodes
-------------------------------------------------------------------------------------------------------------
@ Change history: 04.01.2021 / Ayush Basak / Created the file.
*************************************************************************************************************/

import { LightningElement, api} from 'lwc';

// Apex Method to fetch Data List
import getDataList from '@salesforce/apex/AGN_Account_Hierarchy_Helper.getDataList';

// Message to display if no case records returned
import NORECORDS from '@salesforce/label/c.AGN_Account_Hierarchy_No_Records';
// Creating Base URL
import ORGURL from '@salesforce/label/c.AGN_Account_Hierarchy_Base_URL';

export default class AgnAccountHierarchyDatatable extends LightningElement {

    // Public variable to accept the Id of the account for which information is to be displayed
    @api accountId;
    // Public variable to accept the sObject type for which the data is to be displayed
    @api sObjectType;
    // Reactive variable to accept list of cases from imperative apex call, and display data
    records;
    // Public variable to accept the column configuration
    @api columnInput;
    // List of columns to be displayed in datatable, is created from columnInput
    columns;
    // Public varibale to accept JSON flattening schema
    @api schemaInput;
    // JSON flattening schema, created locally from schemaInput
    flatteningSchema;
    // Private variable to hold the type of records being displayed currently
    sObjectTypeLocal;
    // Reactive variable to store if number of cases returned is greater than 0
    recordsReturned;
    // This variable set to false when component is inserted and to true when apex promise is completed
    // Controls spinner at component load  
    rendered;
    // Map of Labels
    label = {
        noRecords : NORECORDS
    };

    // Action to be executed on insertion of the component
    connectedCallback() {
        this.rendered = false;

    }

    // Action to be performed once all the public attributes are set by parent components.
    renderedCallback() {
        if(this.sObjectTypeLocal != this.sObjectType)
        {                
            this.sObjectTypeLocal = this.sObjectType;
            this.rendered = false;
            this.columns = null;
            this.data = null;
            // Imperative apex call to get list of related records from the given sObject, for given accountId
            getDataList({ accountId: this.accountId, sObjectType: this.sObjectType })
                .then(result => {
                    this.records =  result;
                    this.recordsReturned = this.records.length > 0;
                })
                .catch(error => {
                    this.wireError =  error.body.message;
                })
                // Once data is recieved, same is aligned to the column setup and using the flattening logic
                .finally( () => {
                    this.columns = JSON.parse(this.columnInput);
                    if(this.schemaInput != null) {
                        this.flatteningSchema = JSON.parse(this.schemaInput);
                    }
                    this.rendered = true;
                    this.dataSetup();
                });
            
        }
    }

    // This method aligns the data returned with list of columns to be displayed
    // creates record link and flattens the JSONOnce data is recieved
    dataSetup() {
        let flatteningPairs;
        if(this.flatteningSchema != null) {
            flatteningPairs = Object.entries(this.flatteningSchema);
        }
        // Flattening the records JSON for display and creating link
        if(this.records) {
            let tempRecords = []; 
            this.records.forEach(rec => {
                let tempRecord = {};
                tempRecord = rec;
                tempRecord.recordUrl = ORGURL+rec.Id;

                if(flatteningPairs != null) {
                    flatteningPairs.map(flatteningPair => {
                        let target = flatteningPair[0];
                        let sourceLevels = flatteningPair[1].split(".");
    
                        // Manual traversal through the relationship
                        // Condition till 5 added as only 5 relationships can be traversed in SOQL
                        try{
                            if(sourceLevels.length == 2) {
                                tempRecord[target] = rec[sourceLevels[0]][sourceLevels[1]];
                            }
                            else if(sourceLevels.length == 3) {
                                tempRecord[target] = rec[sourceLevels[0]][sourceLevels[1]][sourceLevels[2]];
                            }
                            else if(sourceLevels.length == 4) {
                                tempRecord[target] = rec[sourceLevels[0]][sourceLevels[1]][sourceLevels[2]][sourceLevels[3]];
                            }
                            else if(sourceLevels.length == 5) {
                                tempRecord[target] = rec[sourceLevels[0]][sourceLevels[1]][sourceLevels[2]][sourceLevels[3]][sourceLevels[4]];
                            }
                        }
                        catch(err) {
                            // Supressing traversal errors, in case traversal field is null
                        }
                        
                    });
                }
                tempRecords.push(tempRecord);
            });
            this.records = tempRecords;
        }
    }
}