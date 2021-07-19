({
    fetchAssessmentAccountCustomerRecord : function(component, event, helper) {
        console.log('start1');

        if(component.get('v.accountAssessmentId') === null) return;

        var action = component.get('c.getAssessmentAccountCustomerRecords');
        action.setParams({
            'userId': component.get('v.userId'),
            'accountAssessmentId': component.get('v.accountAssessmentId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set('v.wrapperList', response.getReturnValue());
                if(response.getReturnValue() === null) return;

                // Take the first record to get data about the GPS Assessment - all records are related to the same GPS Asssessment
                var firstRecord = response.getReturnValue().accountCustomerAssessments[0];
                if(firstRecord) {
                    var isActive         = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Status_AGN__c == 'Active';
                    var deletionsEnabled = isActive && firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Allow_Account_Removal_AGN__c == true;
                    
                    //PMO 3408: GPS Assessment: Start: Account-Customer question addition
                    var gpsAssessment = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r;
                    var stakeholderCapture = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Display_KOL_Capture_AGN__c == true;
                    var consentForDigitalCapture = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Consent_for_Digital_AGN__c == true;
                    var digitalOnlyCapture = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Digital_Only_AGN__c == true;
                    var isBusinessSizeQstnMandatory = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Business_Size_Question_Mandatory_AGN__c == true;
                    var isAGNUsageQstnMandatory = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.AGN_Share_Absolute_QSTN_Mandatory_AGN__c  == true;
                    var isCustomQuestion1Available = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_1_AGN__c != null;
                    var isCustomQuestion2Available = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_2_AGN__c != null;
                    var isCustomQuestion3Available = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_3_AGN__c != null;
                    var isCustomQuestion4Available = firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_4_AGN__c != null;
                    
                    component.set('v.gpsAssessment', gpsAssessment);
                    component.set('v.disableForm', isActive == false);
                    component.set('v.allowAccountCustomerDeletions', deletionsEnabled);
                    component.set('v.stakeholderCapture', stakeholderCapture);
                    component.set('v.consentForDigitalCapture', consentForDigitalCapture);
                    component.set('v.digitalOnlyCapture', digitalOnlyCapture);
                    component.set('v.businessSizeQstnMandatory', isBusinessSizeQstnMandatory);
                    component.set('v.agnUsageQstnMandatory', isAGNUsageQstnMandatory);
                    component.set('v.customQuestion1Availability', isCustomQuestion1Available);
                    component.set('v.customQuestion2Availability', isCustomQuestion2Available);
                    component.set('v.customQuestion3Availability', isCustomQuestion3Available);
                    component.set('v.customQuestion4Availability', isCustomQuestion4Available);
                    
                    var customQuestionColspan = 0;
                    if(firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_1_Type_AGN__c) {
                        component.set('v.custPicklistOptionsCustomQuestion1', this.generatePicklistOptions(firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_1_List_Of_Values_AGN__c));
                    	customQuestionColspan++;
                    }
                    if(firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_2_Type_AGN__c) {
                        component.set('v.custPicklistOptionsCustomQuestion2', this.generatePicklistOptions(firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_2_List_Of_Values_AGN__c));
                    	customQuestionColspan++;
                    }
                    if(firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_3_Type_AGN__c) {
                        component.set('v.custPicklistOptionsCustomQuestion3', this.generatePicklistOptions(firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_3_List_Of_Values_AGN__c));
                    	customQuestionColspan++;
                    }
                    if(firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_4_Type_AGN__c) {
                        component.set('v.custPicklistOptionsCustomQuestion4', this.generatePicklistOptions(firstRecord.Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_4_List_Of_Values_AGN__c));
                    	customQuestionColspan++;
                    }
                    component.set('v.customQuestionColspan', customQuestionColspan);
                    //PMO 3408: GPS Assessment: End: Account-Customer question addition
                }
                //PMO 3408: GPS Assessment: Start: Reset UI 
                else{
                    this.resetUI(component)
                }
                //PMO 3408: GPS Assessment: End: Reset UI 
            } else {
                console.log('ERROR');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    save : function(component, event, helper) {
        console.log('save1:');
        var wrapper = component.get('v.wrapperList');
        var action = component.get('c.upsertAccountCustomerAssessment');
        action.setParams({
            'wrapperJSON': JSON.stringify(wrapper)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                this.fetchAssessmentAccountCustomerRecord(component, event);

                var appEvent = $A.get('e.c:AGN_GPSShowAccountAssessmentsEvt');
                appEvent.setParams({
                    'assessmentId' : component.get('v.assessmentId')
                });
                appEvent.fire();

                var successMessage = $A.get('$Label.c.Save_successful');
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : [successMessage]});
                toastNotificationEvent.fire();
                console.log(response.getReturnValue());
            } else {
                console.log('ERROR');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    addCustomers : function(component, event, helper) {
        console.log('addcustomer:');
        var action = component.get('c.getCustomerRecords');
        action.setParams({
            'accountAssessmentId': component.get('v.accountAssessmentId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set('v.accountList', response.getReturnValue());
                console.log(component.get('v.accountList'));
            } else {
                console.log('ERROR');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    createAccountCustomers : function(component, event, customerIds) {
        console.log('assacctid:' + component.get('v.accountAssessmentId'));
        console.log('cust:' + customerIds);
        var action = component.get('c.createAccountCustomerRecord');
        action.setParams({
            'accountAssessmentId': component.get('v.accountAssessmentId'),
            'customerIds': customerIds,
            'userId': component.get('v.userId')
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                var successMessage = $A.get('$Label.c.Save_successful');
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : [successMessage]});
                toastNotificationEvent.fire();
                console.log(response.getReturnValue());
            } else {
                console.log('ERROR');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    deleteAccountCustomerAssessment : function(component, event) {
        var confirmed = confirm('Are you sure that you want to remove this account?');
        if(!confirmed) return;
		console.log("id:" + event.getSource().get('v.value'));
        var accountAssessmentId = event.getSource().get('v.value');
        var action = component.get('c.deleteAccountCustomerGPSAssessment');
        action.setParams({
            accountCustomerAssessmentId : accountAssessmentId
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : ['Record successfully deleted']});
                toastNotificationEvent.fire();
                this.fetchAssessmentAccountCustomerRecord(component);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                var errorDetails = [];
                for(var i=0; i < response.getError().length; i++) {
                    var errorWrapper = response.getError()[i];
                    console.log(errorWrapper);
                    for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                        errorDetails.push(errorWrapper.pageErrors[i].message);
                    }
                }

            }
        });
        $A.enqueueAction(action);
    },
    
    //PMO 3408: GPS Assessment: Start: Account-Customer question addition
    generatePicklistOptions : function(listOfValues) {
        if(listOfValues == null) return;
        
        var picklistOptions = new Array();
        
        var emptypicklistOption = {};
        emptypicklistOption.label = '';
        emptypicklistOption.value = '';
        picklistOptions.push(emptypicklistOption);
        
        if(listOfValues != null){
        var splitListOfValues = listOfValues.split(/\r?\n/);
            for(var i=0; i < splitListOfValues.length; i++) {
                var val = splitListOfValues[i];
                
                var picklistOption = {};
                picklistOption.label = val;
                picklistOption.value = val;
                picklistOptions.push(picklistOption);
            }
        }
        return picklistOptions;
    },
    //PMO 3408: GPS Assessment: End: Account-Customer question addition
    
	//PMO 3408: GPS Assessment: Start: Reset UI 
    resetUI : function(component) {
        component.set('v.gpsAssessment', null);
        component.set('v.stakeholderCapture', false);
        component.set('v.consentForDigitalCapture', false);
        component.set('v.digitalOnlyCapture', false);
        component.set('v.businessSizeQstnMandatory', false);
        component.set('v.agnUsageQstnMandatory', false);
        component.set('v.customQuestion1Availability', false);
        component.set('v.customQuestion2Availability', false);
        component.set('v.customQuestion3Availability', false);
        component.set('v.customQuestion4Availability', false);
        component.set('v.customQuestionColspan', 0);
    },
	//PMO 3408: GPS Assessment: End: Reset UI
})