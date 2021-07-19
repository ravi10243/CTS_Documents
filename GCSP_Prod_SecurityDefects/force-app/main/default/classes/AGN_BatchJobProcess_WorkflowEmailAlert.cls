/**
* The Job will getting triggered once Queue job finished its activity 
* responsible for masking all production email exists in workflowemail as part of PII data protection.
*
* @author  Santanu Roy
* @version 1.0
* @since   2020-07-27 
*/


global class AGN_BatchJobProcess_WorkflowEmailAlert implements Database.Batchable<sObject>,Database.AllowsCallouts{
     String currentSessionId = UserInfo.getSessionID();
     String domainUrl = URL.getSalesforceBaseUrl().toExternalForm();
     String unmanagedState = 'unmanaged';
     String paramValue = '.invalid';
     String tempInput ='\'%' + paramValue  + '%\'';
     Boolean isNextBatchExecute = true;
     public AGN_BatchJobProcess_WorkflowEmailAlert(Boolean value){
       this.isNextBatchExecute = value;
     }
    
    
   //retrive all the emails from the workflowalert table using service call. 
   global Database.QueryLocator start(Database.BatchableContext BC) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + currentSessionId);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept','application/json');
       //Select Id,SenderType,ManageableState,templateId,ccEmails  from WorkflowAlert where ManageableState='unmanaged' and (ccEmails <> null and (Not ccEmails like '%invalid'))
        //request.setEndpoint(domainUrl + '/services/data/v48.0/tooling/query/?q=Select+Id,SenderType,ManageableState,templateId+from+WorkflowAlert+where+ManageableState=\'' + unmanagedState + '\'+and+ccEmails <> null');
        String criteria = 'q=Select+id,+SenderType,+DeveloperName,+CcEmails,+Description,+TemplateId+FROM+WorkflowAlert+where+ManageableState=\'' + unmanagedState + '\'+and+CcEmails+!=+null';
        request.setEndpoint(domainUrl + '/services/data/v48.0/tooling/query/?' + criteria);
       //request.setEndpoint(domainUrl + '/services/data/v48.0/tooling/query/?q=Select+Id,SenderType,ManageableState,templateId+from+WorkflowAlert+where+ManageableState=\'' + unmanagedState + '\'+and+(Not+ccEmails+like'+tempInput+')');
        request.setTimeOut(7000);
        request.setMethod('GET');
        Http h = new Http();
        HttpResponse response = h.send(request);
        List<String> workflowEmailAlertIds = new List <String>(); 
        String[] wFlowIds;
        String getResponse = response.getBody();
        JSONParser parser = JSON.createParser(getResponse);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                String fieldName = parser.getText();
                parser.nextToken();
                String fieldValue = parser.getText();
                if (fieldName == 'Id') {
                    workflowEmailAlertIds.add(fieldValue);
                }
            }
        } 
       wFlowIds = new String[workflowEmailAlertIds.size()];
       Integer k=0;
       List<AGN_WorkFlowData__c> wFlowDatas = new List<AGN_WorkFlowData__c>();
       try{
           
           List<AGN_WorkFlowData__c> toDel = new List<AGN_WorkFlowData__c>();
           toDel = [select id from AGN_WorkFlowData__c];
           if (AGN_WorkFlowData__c.sObjectType.getDescribe().isDeletable()){  // sw cc
                delete toDel;
            }
       }
       Catch(DMLException e){
           
       }
       
       
       for(String id : workflowEmailAlertIds){
           //wFlowIds[k] = id;
           AGN_WorkFlowData__c wFlowData = new AGN_WorkFlowData__c();
           if(Schema.sObjectType.AGN_WorkFlowData__c.fields.WorkflowId__c.isCreateable()){  //sw cc
            wFlowData.WorkflowId__c = id;
           }
           wFlowDatas.add(wFlowData);
          // k++;
       }
       try{
           if (AGN_WorkFlowData__c.sObjectType.getDescribe().isCreateable()){  //sw cc
            insert wFlowDatas;
           }
       }
       Catch(DmlException e){
           
       }
       
       
       System.debug('Workflow ids '+wFlowIds);
       String query = 'select Id, ccEmails from WorkflowAlert Where Id IN ';
       query +=':wFlowIds';
       System.debug('Query params '+query);
       String query1 = 'select Id, ccEmails from WorkflowAlert where ccEmails <> null and ManageableState = :unmanaged';
       System.debug('Pre Query locator');
       String query2 = 'Select WorkflowId__c from AGN_WorkFlowData__c';
       //System.debug('Workflows '+wFlows);
       return Database.getQueryLocator(query2);
      
    }
     
    global void execute(Database.BatchableContext BC,  List<AGN_WorkFlowData__c> wFlowEmailAlertList) {
        Integer count = 0;
        System.debug('Workflow alerts '+ wFlowEmailAlertList);
        for (AGN_WorkFlowData__c workflow: wFlowEmailAlertList) {
           // WorkflowAlert wAlert = (WorkflowAlert) workflow;
            count++;
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + currentSessionId);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept','application/json');
            req.setEndPoint(domainUrl + '/services/data/v48.0/tooling/sobjects/WorkflowAlert/' + workflow.WorkflowId__c);
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res = http.send(req);
            String response2nd = res.getBody();
            System.debug('Get Response data -- ' + response2nd);
            try {
                AGN_WorkFlowAlertUpdateParser workFlowAlertParser = AGN_WorkFlowAlertUpdateParser.parse(response2nd);        
                JSONGenerator jsonGenerator = JSON.createGenerator(true);       
                jsonGenerator.writeStartObject();
                jsonGenerator.writeFieldName('Metadata');
        
                if (null != workFlowAlertParser.Metadata) { 
                    jsonGenerator.writeStartObject();
                    if (workFlowAlertParser.Metadata.ccEmails.size() > 0) {                        
                        for (Integer i = 0; i < workFlowAlertParser.Metadata.ccEmails.size(); i++) {
                            //code to mask email ids in the queue
                            if(AGN_PostCopyValidateUtil.isEligible(workFlowAlertParser.Metadata.ccEmails[i])){  
                               workFlowAlertParser.Metadata.ccEmails[i] += '.invalid';                                
                            }
                            //code to unmask email ids in the queue
                            /*if (workFlowAlertParser.Metadata.ccEmails[i] != null && (workFlowAlertParser.Metadata.ccEmails[i].endsWithIgnoreCase('.invalid'))) {
                                String ccEmails =  workFlowAlertParser.Metadata.ccEmails[i];   
                                String value = ccEmails.substring(0,ccEmails.indexOf('.invalid'));
                                workFlowAlertParser.Metadata.ccEmails[i] = value;                            
                            }*/
                            
                        }
                        List < String > ccEmailList = workFlowAlertParser.Metadata.ccEmails;
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeObjectField('ccEmails', ccEmailList);
                    } else {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeNullField('ccEmails');
                    }           
                    if (null != workFlowAlertParser.Metadata.description) {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeStringField('description', workFlowAlertParser.Metadata.description);
                    } else {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeNullField('description');
                    }
                    if (workFlowAlertParser.Metadata.protected_Z == false) {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeBooleanField('protected', false);
                    } else {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeBooleanField('protected', true);
                    }           
                    if (null != workFlowAlertParser.Metadata.recipients) {              
                        jsonGenerator.writeFieldName('recipients');                
                        if (workFlowAlertParser.Metadata.recipients.size() > 0) {
                            jsonGenerator.writeStartArray();
                            for (AGN_WorkFlowAlertUpdateParser.Recipients allRecipients: workFlowAlertParser.Metadata.recipients) {                     
                                jsonGenerator.writeStartObject();
                                if (null != String.valueOf(allRecipients.field)) {
                                    jsonGenerator.writeObjectField('field', allRecipients.field);
                                } else {
                                    //jsonGenerator.writeStartObject();
                                    jsonGenerator.writeNullField('field');
                                }
                                if (null != allRecipients.recipient) {
                                    //jsonGenerator.writeStartObject();
                                    jsonGenerator.writeStringField('recipient', allRecipients.recipient);
                                } else {
                                    //jsonGenerator.writeStartObject();
                                    jsonGenerator.writeNullField('recipient');
                                }
                                if (null != allRecipients.type_Z) {
                                    jsonGenerator.writeStringField('type', allRecipients.type_Z);
                                } else {
                                    //jsonGenerator.writeStartObject();
                                    jsonGenerator.writeNullField('type');
                                }
                                jsonGenerator.writeEndObject();
                            }
                            jsonGenerator.writeEndArray();
                        } else {
                                jsonGenerator.writeStartArray();
                                jsonGenerator.writeEndArray();                      
                            }
                    } else {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeNullField('recipients');
                    }            
                    if (null != workFlowAlertParser.Metadata.senderAddress) {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeStringField('senderAddress', workFlowAlertParser.Metadata.senderAddress);
                    } else {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeNullField('senderAddress');
                    }            
                    if (null != workFlowAlertParser.Metadata.senderType) {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeStringField('senderType', workFlowAlertParser.Metadata.senderType);
                    } else {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeNullField('senderType');
                    }            
                    if (null != workFlowAlertParser.Metadata.template) {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeStringField('template', workFlowAlertParser.Metadata.template);
                    } else {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeNullField('template');
                    }            
                    if (null == workFlowAlertParser.Metadata.urls) {
                        jsonGenerator.writeNullField('urls');
                    } else {
                        //jsonGenerator.writeStartObject();
                        jsonGenerator.writeObjectField('urls', workFlowAlertParser.Metadata.urls);
                    }
                    jsonGenerator.writeEndObject();         
                }
                if (null != workFlowAlertParser.FullName) {
                    //jsonGenerator.writeStartObject();
                    jsonGenerator.writeStringField('FullName', workFlowAlertParser.FullName);
                } else {
                    //jsonGenerator.writeStartObject();
                    jsonGenerator.writeNullField('FullName');           
                }
                jsonGenerator.writeEndObject();
                
                String jsonData = jsonGenerator.getAsString();
                System.debug('- @@@@ jsonData @@@@ - ' + jsonData);
        
                
                HttpRequest updateReq = new HttpRequest();
                updateReq.setHeader('Authorization', 'Bearer ' + currentSessionId);
                updateReq.setHeader('Content-Type', 'application/json');
                updateReq.setHeader('Accept','application/json');
                updateReq.setEndPoint(domainUrl + '/services/data/v48.0/tooling/sobjects/WorkflowAlert/' + workflow.WorkflowId__c);
                //updateReq.setEndPoint(domainUrl + '/services/data/v48.0/tooling/sobjects/WorkflowAlert/describe/' + workflow.WorkflowId__c);
                String reqBody = jsonData;
                updateReq.setBody(reqBody);
                updateReq.setMethod('PATCH');
                Http h1 = new Http();
                HttpResponse updateRes = h1.send(updateReq);
                System.debug(updateRes.getStatusCode());
                System.debug(updateRes.getBody());
        
            } 
            catch (System.CalloutException ex) {
                System.debug('****exception for email alertid-' + ex.getMessage());
            }
       }   
    }  
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
        System.debug('Queue job finished ');
        // start next batch process
        AGN_Post_Copy_Util.insertJobRecord(BC.getJobId()); 
        if(this.isNextBatchExecute){
            AGN_BatchJobProcess_CustomLabel custLabelJob = new AGN_BatchJobProcess_CustomLabel(true);
            Database.executeBatch(custLabelJob,50);
            
        }
        else{
            AGN_Post_Copy_Util.sendJobStatusReportEmail();
        }
        
    }
}