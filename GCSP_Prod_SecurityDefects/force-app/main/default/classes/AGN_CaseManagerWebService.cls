@RestResource(urlMapping='/Cases/*')
global class AGN_CaseManagerWebService{    
    @HttpPost
    global static string createCase(String caseNumber, String rootCause, String inv, String warranty, String rmaNumber,  
                                    String complaintCode, String details, String investigator, String itemCode, String serialNumber, 
                                    String complaintStatus, String intakeId, String complaintClosedDate, String complaintClassification) {
                                        
        String caseAttributeId = '';  
        String caseId = '';
        if(String.isNotBlank(intakeId)){
            caseAttributeId = getCaseAttribute(caseAttributeId, intakeId, null);
            caseId = getCaseId(caseId, intakeId, null);
        }
        if(String.isBlank(caseAttributeId)){
            if(String.isNotBlank(caseNumber)){
                caseAttributeId = getCaseAttribute(caseAttributeId, null, caseNumber);
                caseId = getCaseId(caseId, null, caseNumber);
            }
        }
        if(String.isBlank(caseAttributeId)){
            return Label.Trackwise_prId_CaseNumber_Not_Available_AGN;
        }
        
        try{ 
            Case_Attributes_for_CoolSculpting_AGN__c trackwiseCaseAttribute = new Case_Attributes_for_CoolSculpting_AGN__c(
                Root_Cause_CoolS_AGN__c = rootCause,
                Inv_CoolS_AGN__c = inv,
                Warranty_CoolS_AGN__c = warranty,
                RMA_Number_CoolS_AGN__c = rmaNumber,                                                                        
                Complaint_Code_CoolS_AGN__c = complaintCode,
                Details_CoolS_AGN__c = details, 
                Investigator_CoolS_AGN__c = investigator,
                Item_Code_CoolS_AGN__c = itemCode,
                Serial_Number_CoolS_AGN__c = serialNumber,
                Complaint_Status_Trackwise_AGN__c = complaintStatus,                                          
                Id = caseAttributeId,                                                                              
                Date_Comp_Closed_CoolS_AGN__c = formatDate(complaintClosedDate), 
                Problem_Type_CoolS_AGN__c = complaintClassification);
            
           
            // Update case Attribute                            
            Database.SaveResult result = Database.update(trackwiseCaseAttribute);               
            if(result.isSuccess()){
                if(String.isNotBlank(intakeId)){
                    // Update case
                    Case trackwiseCase = new Case(Id = caseId,
                                                  PR_ID_Trackwise_AGN__c = intakeId);
                    Database.SaveResult caseUpdateResult = Database.update(trackwiseCase); 
                    if(!caseUpdateResult.isSuccess()){
                        return String.valueOf(caseUpdateResult.getErrors()[0]);
                    }
                }
                return Label.Trackwise_Case_Update_Success_AGN;
            }else if(!result.isSuccess()){
                return String.valueOf(result.getErrors()[0]);
            }
            
        }catch (Exception ex){
            insertErrorDetails(caseId, ex.getMessage());
            return ex.getMessage();
        }
        return null;
    }   
    
    // For Insert Exception/Error Message
    public static Allergan_Error_Logger_AGN__c insertErrorDetails(String caseId, String message){
        Allergan_Error_Logger_AGN__c e = new Allergan_Error_Logger_AGN__c(Case_AGN__c = caseId, Error_Message_AGN__c = message, Source_AGN__c = 'Trackwise');
        insert e;
        return e;
    }

    // Get Attribute Case Attribute Id using Case intakeId or Case number         
    public static string getCaseAttribute(String caseAttributeId, String intakeId, String caseNumber){
        for(Case_Attributes_for_CoolSculpting_AGN__c cafca: [SELECT Id FROM Case_Attributes_for_CoolSculpting_AGN__c WHERE  ((Case_CoolS_AGN__r.PR_ID_Trackwise_AGN__c != null AND (Case_CoolS_AGN__r.PR_ID_Trackwise_AGN__c = :intakeId)) OR (Case_CoolS_AGN__r.CaseNumber != null AND (Case_CoolS_AGN__r.CaseNumber = :caseNumber)) )]){
            caseAttributeId = cafca.id;
        }
        return caseAttributeId;
    }
    // Get case Id using intakeId or Case Number
    public static string getCaseId(String caseId, String intakeId, String caseNumber){
        for(Case c: [SELECT Id FROM Case WHERE  ((PR_ID_Trackwise_AGN__c != null AND (PR_ID_Trackwise_AGN__c = :intakeId)) OR (CaseNumber != null AND (CaseNumber = :caseNumber)) )]){
            caseId = c.id;
        }
        return caseId;
    }
    
    // Format date 
    public static Date formatDate(String complaintClosed){
        if(String.isNotBlank(complaintClosed) ){  
            if(complaintClosed.contains('/')){          
                String[] splitedDate =  complaintClosed.split('/');
                if(splitedDate.size() == 3){
                    // YYYY, MM, DD
                    return Date.newInstance(integer.valueOf(splitedDate[2]), integer.valueOf(splitedDate[0]), integer.valueOf(splitedDate[1]));
                }else if(splitedDate.size() != 3){
                    return Date.parse(complaintClosed);
                }
            }else{
                return Date.parse(complaintClosed);
            }
        }        
        return null;
    }
}