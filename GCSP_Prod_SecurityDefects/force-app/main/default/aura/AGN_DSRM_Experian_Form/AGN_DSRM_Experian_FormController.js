({
    doInit: function (component, event, helper) {
        component.set("v.showSpinner", true);
        const caseId = helper.getParameterByName("caseid");
        console.log("caseId ->" + caseId);
        component.set("v.recordId", caseId);
        component.find("caseInfo").reloadRecord();
    },
    navigateToHome: function () {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    },
    handleRecordChanged: function (component, event, helper) {
        var eventParams = event.getParams();
        console.log("---> " + eventParams.changeType);
        switch (eventParams.changeType) {
            case "ERROR":
                component.set("v.showOTP", false);
                component.set("v.showQuestion", false);
                component.set("v.showSpinner", false);
                break;
            case "LOADED":
                let caseStatus = component.get("v.caseRecord").Status;
                console.log(" caseStatus ---> " + caseStatus);
                //check if Case is not closed
                if (caseStatus !== 'Closed') {
                    var actionDsEmailObj = component.get("c.getDSEmailObject");
                    actionDsEmailObj.setParams({
                        caseRecordId: component.get("v.recordId")
                    });

                    actionDsEmailObj.setCallback(this, function (response) {
                        var state = response.getState();
                        console.log(state);
                        if (state === "SUCCESS") {
                            var resp = response.getReturnValue();
                            //console.log('resp.Experian_Overall_Decision_AGN__c ' + resp.Experian_Overall_Decision_AGN__c);
                            if (!resp.Experian_Overall_Decision_AGN__c || resp.Experian_Overall_Decision_AGN__c === '') {
                                //get initial response from Experian
                                component.set("v.showOTP", false);
                                component.set("v.showQuestion", false);
                                var questions = [];
                                var qaData;
                                var action = component.get("c.getInitialResponse");
                                action.setParams({
                                    caseRecordId: component.get("v.recordId"),
                                    caseNumber: component.get("v.caseRecord.CaseNumber"),
                                    countryCode: 'USA'
                                });
                                action.setCallback(this, function (response) {
                                    var state = response.getState();
                                    console.log("state: " + state);
                                    if (state === "SUCCESS") {
                                        var resp = response.getReturnValue();
                                        console.log("experianFinalDecision -> " + resp.responseHeader.overallResponse.decision);
                                        console.log('Other Data -> '+ resp.clientResponsePayload.decisionElements[0].otherData);
                                        if (resp.clientResponsePayload.decisionElements[0].otherData) {
                                            var experianSessionId = resp.clientResponsePayload.decisionElements[0].otherData.json
                                                .fraudSolutions.response.products.preciseIDServer.sessionID;

                                            component.set("v.experianSessionId", experianSessionId);

                                            //kba => Questions & Answers are generated
                                            var kba =
                                                resp.clientResponsePayload.decisionElements[0].otherData.json
                                                .fraudSolutions.response.products.preciseIDServer.kba;

                                            //- OR -
                                            //otp => One time passcode generated and sent to DS's mobile
                                            var otp =
                                                resp.clientResponsePayload.decisionElements[0].otherData.json
                                                .fraudSolutions.response.products.preciseIDServer.multiFactorAuth;

                                            if (kba) {
                                                kba.questionSet.forEach(q => {
                                                    //console.log(q.questionText);
                                                    qaData = new Object();
                                                    qaData.questionId = q.questionType;
                                                    qaData.question = q.questionText;
                                                    qaData.required = true;
                                                    qaData.questionDisplayType = "PICKLIST";
                                                    qaData.answerChoices = q.questionSelect.questionChoice;
                                                    questions.push(qaData);
                                                });
                                                component.set("v.questionAnswerMap", questions); //setting up Questions & Answers data
                                                component.set("v.showQuestion", true); //displaying Question & Answer screen
                                                component.set("v.showOTP", false);
                                            } else if (otp) {
                                                component.set("v.showQuestion", false);
                                                component.set("v.showOTP", true); //displaying OTP screen
                                            } else {
                                                //Neither Questions & Answers are generated nor One time passcode generated
                                                //displaying a message with a dialog box
                                                component.set("v.showQuestion", false);
                                                component.set("v.showOTP", false);

                                                console.log("experianFinalDecision -> " + resp.responseHeader.overallResponse.decision);
                                                if (resp && resp.responseHeader && resp.responseHeader.overallResponse && resp.responseHeader.overallResponse.decision) {
                                                    var decision = 'ACCEPT';
                                                    if (resp.responseHeader.overallResponse.decision !== 'ACCEPT') {
                                                        decision = 'NODECISION';
                                                    }
                                                    component.set("v.experianFinalDecision", decision); //controlling dialog box message to be displayed
                                                    //component.set("v.experianFinalDecision", resp.responseHeader.overallResponse.decision);
                                                }
                                                component.set("v.displayDialog", true); //finally displaying dialog box with message
                                            }
                                            component.set("v.showSpinner", false);
                                        } else {
                                            component.set("v.showQuestion", false);
                                            component.set("v.showOTP", false);
											component.set("v.showSpinner", false);
                                            console.log("experianFinalDecision -> " + resp.responseHeader.overallResponse.decision);
                                            if (resp && resp.responseHeader && resp.responseHeader.overallResponse && resp.responseHeader.overallResponse.decision) {
                                                var decision = 'ACCEPT';
                                                if (resp.responseHeader.overallResponse.decision !== 'ACCEPT') {
                                                    decision = 'NODECISION';
                                                }
                                                component.set("v.experianFinalDecision", decision); //controlling dialog box message to be displayed
                                            }
                                            component.set("v.displayDialog", true); //finally displaying dialog box with message
                                        }
                                    } else {
                                        helper.logActionErrors(component, response);
                                        component.set("v.showSpinner", false);
                                    }
                                });
                                $A.enqueueAction(action);
                                //End of initial response from Experian
                            } else {
                                component.set("v.showOTP", false);
                                component.set("v.showQuestion", false);
                                var inProgressMsg = $A.get("$Label.c.AGN_CCPA_Request_InProgress");
                                helper.showTosteMessage(component, '', 'success', inProgressMsg, 'sticky');
                                component.set("v.showSpinner", false);
                            }
                        } else {
                            helper.logActionErrors(component, response);
                            component.set("v.showSpinner", false);
                        }
                    });
                    $A.enqueueAction(actionDsEmailObj);
                } else {
                    component.set("v.showOTP", false);
                    component.set("v.showQuestion", false);
                    var caseClosedMsg = $A.get("$Label.c.AGN_CCPA_Request_Closed");
                    helper.showTosteMessage(component, '', 'error', caseClosedMsg, 'sticky');
                    component.set("v.showSpinner", false);
                }
                break;
            case "REMOVED":
                // stuff
                break;
            case "CHANGED":
                // more stuff
                break;
        }
    },
    otpSubmit: function (component, event, helper) {
        console.log('OTP');
        let inputCmp = component.find("inputFieldOTP");
        if (!inputCmp.get('v.validity').valid) {
            inputCmp.showHelpMessageIfInvalid();
        } else {
            console.log('Exp - SessionId ' + component.get("v.experianSessionId"));
            var otpValue = inputCmp.get("v.value");
            console.log('otpValue -> ' + otpValue);
            component.set("v.showSpinner", true);
            var action = component.get("c.validateOTP");
            action.setParams({
                caseRecordId: component.get("v.recordId"),
                caseNumber: component.get("v.caseRecord.CaseNumber"),
                valueOTP: otpValue,
                experianSessionId: component.get("v.experianSessionId")
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue();
                    component.set("v.showOTP", false);
                    component.set("v.showSpinner", false);

                    console.log("experianFinalDecision -> " + resp.responseHeader.overallResponse.decision); //ACCEPT / REFER
                    if (resp && resp.responseHeader && resp.responseHeader.overallResponse && resp.responseHeader.overallResponse.decision) {
                        component.set("v.experianFinalDecision", resp.responseHeader.overallResponse.decision); //controlling dialog box message to be displayed
                    }
                    component.set("v.displayDialog", true); //finally displaying dialog box with message
                } else {
                    helper.logActionErrors(component, response);
                    component.set("v.showSpinner", false);
                }
            });

            $A.enqueueAction(action);
        }
    },
    questionAnswerSubmit: function (component, event, helper) {
        var requiredMissing = false;
        const cmps = component.find("fieldId");
        if (!cmps) return;
        cmps.forEach(function (cmp) {
            let selectedVal = cmp.get("v.fieldValue");
            console.log(cmp.get("v.questionId") + " -- " + selectedVal);
            if (cmp.get("v.required") && (!selectedVal || selectedVal.length == 0)) {
                requiredMissing = true;
                cmp.checkReportValidity();
                console.log("Required field is missing for " + cmp.get("v.questionId"));
            }
        });
        if (requiredMissing) {
            console.log("requireFieldMissing");
        } else {
            let answersMap = new Map();
            let answer = [];
            cmps.forEach(function (cmp) {
                let selected = cmp.get("v.fieldValue");
                selected = Number.parseInt(selected) + 1; //+1 -> Experian logic
                answer.push(selected);
                console.log(cmp.get("v.questionId") + " selected value -> ", selected);
                answersMap.set(
                    cmp.get("v.questionId"),
                    selected === undefined ? "" : selected
                );
            });
            console.log("answersMap>>>>>>>>>>>>>>", answersMap);
            component.set("v.showSpinner", true);
            var answerIds = JSON.stringify(answer);
            var action = component.get("c.submitQuestions");
            action.setParams({
                caseRecordId: component.get("v.recordId"),
                caseNumber: component.get("v.caseRecord.CaseNumber"),
                answerIds: answerIds,
                experianSessionId: component.get("v.experianSessionId")
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue();
                    component.set("v.showQuestion", false);
                    component.set("v.showSpinner", false);

                    console.log("experianFinalDecision -> " + resp.responseHeader.overallResponse.decision); //ACCEPT / REFER
                    if (resp && resp.responseHeader && resp.responseHeader.overallResponse && resp.responseHeader.overallResponse.decision) {
                        component.set("v.experianFinalDecision", resp.responseHeader.overallResponse.decision); //controlling dialog box message to be displayed
                    }
                    component.set("v.displayDialog", true); //finally displaying dialog box with message
                } else {
                    helper.logActionErrors(component, response);
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(action);
        }
    }
});