/*
Type Name: AGN_CustomerAccountUpdateController_v2
Reason: Controller class for Cusomer update page lightning components
21-03-2017 - SG - Initial Version
*/
public without sharing class AGN_OAMAccountUpdateController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo) {
        
        return AGN_OAMCustomerRegUtils.getLayoutCountrySetting(country, stepNo, null, null, null);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType) {
        
        return AGN_OAMCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, null);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType, List<Customer_Type_Configuration_AGN__c> custTypeConfig) {
        
        return AGN_OAMCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, custTypeConfig);
    }  
    
    @AuraEnabled
    public Allergan_Customer_Registration_AGN__c newRegistration {get;set;}
    @AuraEnabled
    public Allergan_Customer_Address_AGN__c newAddress {get;set;}
    @AuraEnabled
    public static Customer_Type_Configuration_AGN__c config {get;set;}
    @AuraEnabled
    public Form_Of_Payment_AGN__c paymentMethod {get;set;}
    @AuraEnabled
    public Payment_Term_AGN__c paymentTerm {get;set;}
    @AuraEnabled
    public list<Allergan_Customer_Payment_AGN__c> custPayment {get;set;}
    
    public static Account customerAccount;
    
    @AuraEnabled
    public static AGN_OAMAccountUpdateController doInit(Id addressId, string type){
        
        customerAccount = AGN_OAMAccountDetailController.getAccountDetails();
        
        config = getCustTypeConfigDetails();
        
        AGN_OAMAccountUpdateController obj = new AGN_OAMAccountUpdateController();
        obj.newRegistration = new Allergan_Customer_Registration_AGN__c();  
        obj.newRegistration.Account_AGN__c = customerAccount.Id;
        obj.newRegistration.Account_Status_AGN__c = customerAccount.Status_AGN__c ;
        obj.newRegistration.Account_Sub_Type_AGN__c= customerAccount.Type_AGN__c ;
        obj.newRegistration.AGN_Identifier_AGN__c = customerAccount.External_ID4_AGN__c ;
        obj.newRegistration.BirthDate_AGN__c = customerAccount.PersonBirthdate ;
        obj.newRegistration.Business_Unit_AGN__c = customerAccount.Additional_Specialties_AGN__c ;
        obj.newRegistration.Consent_to_Contact_AGN__c = customerAccount.Consent_to_Contact_AGN__c ? 'Yes':'No';
        obj.newRegistration.Consent_to_Email_AGN__c = customerAccount.Consent_to_Email_AGN__c ? 'Yes':'No';
        obj.newRegistration.Consent_to_Mail_AGN__c = customerAccount.Consent_to_Mail_AGN__c ? 'Yes':'No';
        obj.newRegistration.Consent_to_Phone_AGN__c = customerAccount.Consent_to_Phone_AGN__c ? 'Yes':'No';
        obj.newRegistration.Country_AGN__c = customerAccount.Country_vod__c ;
        obj.newRegistration.Customer_Group_AGN__c = customerAccount.SAP_Customer_Group_AGN__c ;
        obj.newRegistration.Distribution_ID_AGN__c = customerAccount.Distribution_ID_AGN__c ;
        obj.newRegistration.Email_AGN__c = customerAccount.PersonEmail ;
        obj.newRegistration.Fax_AGN__c = customerAccount.Fax_Internal_AGN__c ;
        obj.newRegistration.First_Name_AGN__c = customerAccount.FirstName ;
        obj.newRegistration.Gender_AGN__c = customerAccount.Gender_vod__c ;
        obj.newRegistration.Graduation_Year_AGN__c = customerAccount.Graduation_Year_AGN__c ;
        obj.newRegistration.Language_AGN__c = customerAccount.Language_vod__c ;
        obj.newRegistration.Last_Name_AGN__c = customerAccount.LastName ;
        obj.newRegistration.Mapping_1_AGN__c = customerAccount.Email_Internal_AGN__c ;
        obj.newRegistration.Middle_Name_AGN__c = customerAccount.Middle_vod__c ;
        obj.newRegistration.Mobile_AGN__c = customerAccount.PersonMobilePhone ;
        obj.newRegistration.Online_Registration_AGN__c = customerAccount.Customer_Managed_AGN__c ;
        obj.newRegistration.Phone_AGN__c = customerAccount.Phone ;
        obj.newRegistration.Physician_Registration_Reference_AGN__c = customerAccount.Physician_Registration_Reference_AGN__c ;
        obj.newRegistration.Salutation_AGN__c = customerAccount.Salutation ;
        obj.newRegistration.Specialty_Allergan_1_AGN__c = customerAccount.Specialty_Allergan_1_AGN__c ;
        obj.newRegistration.Sub_Specialty_Allergan_AGN__c = customerAccount.Sub_Specialty_Allergan_AGN__c ;
        
        obj.newRegistration.Country_Code_AGN__c = customerAccount.Country_Code__c ;
        obj.newRegistration.SAP_Country_Code_AGN__c = customerAccount.Country_vod__r.Alpha_2_Code_vod__c ;
        obj.newRegistration.OwnerId= customerAccount.OwnerID ;
        obj.newRegistration.Overseeing_accountID_AGN__c= customerAccount.Overseeing_account_ID_AGN__c ;
        
        obj.newRegistration.Online_Registration_AGN__c = true;
        
        obj.newRegistration.RecordTypeId= [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'Update' LIMIT 1][0].Id;
        obj.newAddress = getNewAddress(addressId, type);
        
        /*  Id accId = [select Account_vod__c from Address_vod__c where Id =: addressId limit 1].Account_vod__c;
obj.custPayment = [SELECT Form_Of_Payment_AGN__c, Payment_Term_AGN__c FROM Allergan_Customer_Payment_AGN__c WHERE Account_AGN__c =: accId LIMIT 1]; //customerAccount.Primary_Parent_vod__r.id LIMIT 1];
        system.debug('@@@@payment Value'+obj.custPayment);
        
        if(obj.custPayment != null && !obj.custPayment.isEmpty()){
            if(obj.custPayment[0].Form_Of_Payment_AGN__c != null){
obj.paymentMethod = [SELECT Id,Name, Form_Of_Payment_Label_AGN__c,SAP_Code_AGN__c,SAP_Country_Code_AGN__c,Country_Code_AGN__c FROM Form_Of_Payment_AGN__c WHERE ID=:obj.custPayment[0].Form_Of_Payment_AGN__c];  
            }else{
                obj.paymentMethod = new Form_Of_Payment_AGN__c();
            }
            if( obj.custPayment[0].Payment_Term_AGN__c != null){
obj.paymentTerm = [SELECT Id,Name, SAP_Payment_Term_Code_AGN__c,Payment_Term_Label_AGN__c,Form_Of_Payment__c,SAP_Country_Code_AGN__c,Country_Code_AGN__c FROM Payment_Term_AGN__c WHERE ID=:obj.custPayment[0].Payment_Term_AGN__c];
            }else{
                obj.paymentTerm = new Payment_Term_AGN__c();
            }
            
}  */
        
        
        if (type == 'SoldTo' || type == 'BillTo'){
            
            if (addressId != null){
                
                Id accountId = [select Account_vod__c from Address_vod__c where Id =: addressId limit 1].Account_vod__c;
                
                obj.custPayment = [SELECT Form_Of_Payment_AGN__c, Payment_Term_AGN__c FROM Allergan_Customer_Payment_AGN__c WHERE Account_AGN__c =: accountId LIMIT 1]; //customerAccount.Primary_Parent_vod__r.id LIMIT 1];
                system.debug('@@@@payment Value'+obj.custPayment);
                
                if(obj.custPayment != null && !obj.custPayment.isEmpty()){
                    if(obj.custPayment[0].Form_Of_Payment_AGN__c != null){
                        obj.paymentMethod = [SELECT Id,Name, Form_Of_Payment_Label_AGN__c,SAP_Code_AGN__c,SAP_Country_Code_AGN__c,Country_Code_AGN__c FROM Form_Of_Payment_AGN__c WHERE ID=:obj.custPayment[0].Form_Of_Payment_AGN__c];  
                        obj.newRegistration.Form_of_Payment_AGN__c = obj.paymentMethod.Id;
                        
                    }else{
                        obj.paymentMethod = new Form_Of_Payment_AGN__c();
                    }
                    if( obj.custPayment[0].Payment_Term_AGN__c != null){
                        obj.paymentTerm = [SELECT Id,Name, SAP_Payment_Term_Code_AGN__c,Payment_Term_Label_AGN__c,Form_Of_Payment__c,SAP_Country_Code_AGN__c,Country_Code_AGN__c FROM Payment_Term_AGN__c WHERE ID=:obj.custPayment[0].Payment_Term_AGN__c];
                        obj.newRegistration.Payment_Term_AGN__c = obj.paymentTerm.Id;   
                    }else{
                        obj.paymentTerm = new Payment_Term_AGN__c();
                    }
                    
                }               
                
                for (Allergan_Customer_Payment_AGN__c payment : [SELECT Account_AGN__c, Bank_Name_AGN__c, Bank_Account_Number_AGN__c, IBAN_AGN__c,IBAN_Text_AGN__c, 
                                                                 Sort_Code_AGN__c, SWIFT_BIC_AGN__c,
                                                                 Business_Name_Reference1_AGN__c,Business_Name_Reference2_AGN__c,
                                                                 Contact_Name_Reference1_AGN__c,Contact_Name_Reference2_AGN__c,
                                                                 Fax_Reference1_AGN__c,Fax_Reference2_AGN__c,
                                                                 Phone_Reference1_AGN__c,Phone_Reference2_AGN__c
                                                                 FROM Allergan_Customer_Payment_AGN__c WHERE Account_AGN__c =: accountId LIMIT 1]){              
                                                                     
                                                                     obj.newAddress.IBAN_AGN__c = payment.IBAN_Text_AGN__c;
                                                                     obj.newAddress.IBAN_Text_AGN__c = payment.IBAN_Text_AGN__c;
                                                                     obj.newAddress.SWIFT_BIC_AGN__c = payment.SWIFT_BIC_AGN__c;
                                                                     obj.newAddress.Bank_Name_AGN__c = payment.Bank_Name_AGN__c;
                                                                     obj.newAddress.Bank_Account_Number_AGN__c = payment.Bank_Account_Number_AGN__c;
                                                                     obj.newAddress.Sort_Code_AGN__c = payment.Sort_Code_AGN__c;
                                                                     obj.newAddress.Customer_Payment__c = payment.Id;
                                                                     obj.newAddress.Business_Name_Reference1_AGN__c = payment.Business_Name_Reference1_AGN__c;
                                                                     obj.newAddress.Business_Name_Reference2_AGN__c = payment.Business_Name_Reference2_AGN__c;
                                                                     obj.newAddress.Contact_Name_Reference1_AGN__c = payment.Contact_Name_Reference1_AGN__c;
                                                                     obj.newAddress.Contact_Name_Reference2_AGN__c = payment.Contact_Name_Reference2_AGN__c;
                                                                     obj.newAddress.Fax_Reference1_AGN__c = payment.Fax_Reference1_AGN__c;
                                                                     obj.newAddress.Fax_Reference2_AGN__c = payment.Fax_Reference2_AGN__c;
                                                                     obj.newAddress.Phone_Reference1_AGN__c = payment.Phone_Reference1_AGN__c;
                                                                     obj.newAddress.Phone_Reference2_AGN__c = payment.Phone_Reference2_AGN__c;
                                                                     
                                                                 }
            }
            else{       
                
                obj.newAddress.IBAN_AGN__c = '';
                obj.newAddress.IBAN_Text_AGN__c = '';
                obj.newAddress.SWIFT_BIC_AGN__c = '';
                obj.newAddress.Bank_Name_AGN__c = '';
                obj.newAddress.Bank_Account_Number_AGN__c = '';
                obj.newAddress.Sort_Code_AGN__c = '';
                obj.newAddress.Business_Name_Reference1_AGN__c = '';
                obj.newAddress.Business_Name_Reference2_AGN__c = '';
                obj.newAddress.Contact_Name_Reference1_AGN__c = '';
                obj.newAddress.Contact_Name_Reference2_AGN__c = '';
                obj.newAddress.Fax_Reference1_AGN__c = '';
                obj.newAddress.Fax_Reference2_AGN__c = '';
                obj.newAddress.Phone_Reference1_AGN__c = '';
                obj.newAddress.Phone_Reference2_AGN__c = '';                   
                
                //obj.newRegistration.Form_Of_Payment_AGN__c = [SELECT Id FROM Form_Of_Payment_AGN__c WHERE Country_Code_AGN__c=:customerAccount.Country_Code__c AND Active_AGN__c= true and Name = 'Direct Debit' LIMIT 1].Id;
            }
        }
        
        return obj;
    }
    
    @AuraEnabled
    public static Allergan_Customer_Address_AGN__c getNewAddress(Id addressId, string type){
        
        Allergan_Customer_Address_AGN__c newAddress = new Allergan_Customer_Address_AGN__c();
        newAddress.Country_AGN__c =  AGN_OAMAccountDetailController.getAccountDetails().Country_vod__r.AGN_Country_Name__c;
        
        system.debug('@@ Type => ' + type);
        if (type == 'SoldTo')
            newAddress.Sold_To_AGN__c = true;
        else if (type == 'ShipTo')
            newAddress.Ship_To_AGN__c = true;
        else if (type == 'BillTo')
            newAddress.Bill_To_AGN__c = true;
        
        if (addressId != null){
            
            Address_vod__c oldAddress = [SELECT Id,                                                 
                                         Name, 
                                         Address_line_2_vod__c,
                                         Address_Line_3_AGN__c, 
                                         State_vod__c, 
                                         City_vod__c, 
                                         Country_vod__c, 
                                         Phone_vod__c,
                                         Phone_2_vod__c, 
                                         Zip_vod__c, 
                                         Email_AGN__c, 
                                         Department_Name_AGN__c,                                         
                                         Buying_Group_Name_AGN__c,
                                         Member_Account_Number_AGN__c,
                                         Part_of_a_Buying_Group_AGN__c,
                                         Province_AGN__c,
                                         Account_vod__c, 
                                         Account_vod__r.Name, 
                                         Account_vod__r.External_ID2_AGN__c, 
                                         Account_vod__r.External_ID4_AGN__c,
                                         Account_vod__r.Status_AGN__c,
                                         Account_vod__r.Account_Type__c,
                                         Account_vod__r.Country_vod__c,
                                         Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c,
                                         Account_vod__r.Distribution_ID_AGN__c,
                                         Account_vod__r.Organization_Registration_Reference_AGN__c,
                                         Account_vod__r.Email_Internal_AGN__c,
                                         Account_vod__r.Type_AGN__c,
                                         Account_vod__r.Sub_Type_AGN__c,
                                         Account_vod__r.SAP_VAT_Number_AGN__c,
                                         Account_vod__r.SAP_Tax_Number_AGN__c,
                                         Account_vod__r.SAP_Doctors_Email_AGN__c,
                                         Account_vod__r.SAP_Doctors_First_Name__c,
                                         Account_vod__r.SAP_Doctors_Last_Name_AGN__c,
                                         Account_vod__r.License_Number_US_AGN__c,
                                         Account_vod__r.US_State_AGN__c,
                                         Account_vod__r.US_License_HCP_AGN__c,
                                         Account_vod__r.Primary_Physician_Email_AGN__c,
                                         Account_vod__r.Primary_Physician_Name_AGN__c,
                                         Account_vod__r.Primary_Physician_Phone_AGN__c,
                                         Account_vod__r.SAP_Pharmacy_License_Number_AGN__c,
                                         Account_vod__r.Registered_Home_AGN__c,
                                         Account_vod__r.Registering_on_behalf_of_owner_AGN__c,
                                         Account_vod__r.SAP_State_License_Number_AGN__c,
                                         Account_vod__r.SAP_NIF_CIF_number_AGN__c
                                         FROM Address_vod__c WHERE 
                                         Id = : addressId LIMIT 1];
            
            //Split house number  and Street Name
            //
            //houseNumber = !String.isBlank(oldAddress.Name)&& oldAddress.Name.Contains('--') ?oldAddress.Name.split('--')[0]:'';
            //streetName = !String.isBlank(oldAddress.Name)&& oldAddress.Name.Contains('--') ?oldAddress.Name.split('--')[1]:oldAddress.Name;
            newAddress.House_Number_AGN__c= !String.isBlank(oldAddress.Name)&& oldAddress.Name.Contains(',') ?oldAddress.Name.split(',')[1].Trim():'';
            newAddress.Street_Name_AGN__c = !String.isBlank(oldAddress.Name)&& oldAddress.Name.Contains(',') ?oldAddress.Name.split(',')[0].Trim():oldAddress.Name.Trim();
            newAddress.Address_Line_1_AGN__c = oldAddress.Name;
            newAddress.Address_Line_2_AGN__c = oldAddress.Address_line_2_vod__c;
            newAddress.Address_Line_3_AGN__c = oldAddress.Address_Line_3_AGN__c;
            newAddress.City_AGN__c = oldAddress.City_vod__c;
            newAddress.State_AGN__c = string.isBlank(oldAddress.State_vod__c)? '':(oldAddress.Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c+ '-' +oldAddress.State_vod__c) ;
            newAddress.Country_AGN__c = oldAddress.Country_vod__c;          
            newAddress.Zip_AGN__c = oldAddress.Zip_vod__c;
            newAddress.Phone_AGN__c = oldAddress.Phone_vod__c;
            newAddress.Phone_2_AGN__c = oldAddress.Phone_2_vod__c; 
            newAddress.Account_AGN__c = oldAddress.Account_vod__c;
            newAddress.Parent_Address_AGN__c = oldAddress.Id;
            newAddress.Province_AGN__c = oldAddress.Province_AGN__c;
            //newAddress.SAP_Tax_Number_AGN__c = oldAddress.NIF_CIF_number_AGN__c;
            //newAddress.Company_Name_AGN__c = oldAddress.Account_vod__r.Name;
            //newAddress.SAP_ID_AGN__c = oldAddress.Account_vod__r.External_ID2_AGN__c;
            newAddress.Email_AGN__c = oldAddress.Email_AGN__c;   
            newAddress.Account_Identifier_AGN__c = oldAddress.Account_vod__r.External_ID4_AGN__c;
            newAddress.Account_Status_AGN__c = oldAddress.Account_vod__r.Status_AGN__c;
            newAddress.Account_Type_AGN__c = oldAddress.Account_vod__r.Account_Type__c;
            newAddress.Company_Name_AGN__c = oldAddress.Account_vod__r.Name;
            newAddress.Country_Lookup_AGN__c = oldAddress.Account_vod__r.Country_vod__c;
            newAddress.Distribution_ID_AGN__c = oldAddress.Account_vod__r.Distribution_ID_AGN__c;
            newAddress.Mapping_1_AGN__c = oldAddress.Account_vod__r.Organization_Registration_Reference_AGN__c;
            newAddress.Mapping_2_AGN__c = oldAddress.Account_vod__r.Email_Internal_AGN__c;
            newAddress.SAP_ID_AGN__c = oldAddress.Account_vod__r.External_ID2_AGN__c;
            newAddress.Sub_Type_AGN__c = oldAddress.Account_vod__r.Type_AGN__c;
            newAddress.Type_AGN__c = oldAddress.Account_vod__r.Sub_Type_AGN__c;
            newAddress.VAT_Number_AGN__c = oldAddress.Account_vod__r.SAP_VAT_Number_AGN__c;
            newAddress.State_License_Number_AGN__c = oldAddress.Account_vod__r.SAP_State_License_Number_AGN__c;
            newAddress.Doctors_Email_AGN__c = oldAddress.Account_vod__r.SAP_Doctors_Email_AGN__c;
            newAddress.Doctors_First_Name_AGN__c = oldAddress.Account_vod__r.SAP_Doctors_First_Name__c;
            newAddress.Doctors_Last_Name_AGN__c = oldAddress.Account_vod__r.SAP_Doctors_Last_Name_AGN__c;
            newAddress.License_Number_US_AGN__c = oldAddress.Account_vod__r.License_Number_US_AGN__c;
            newAddress.US_State_AGN__c = oldAddress.Account_vod__r.US_State_AGN__c;
            newAddress.US_License_HCP_AGN__c = oldAddress.Account_vod__r.US_License_HCP_AGN__c;
            newAddress.Buying_Group_Name_AGN__c= oldAddress.Buying_Group_Name_AGN__c;
            newAddress.Member_Account_Number_AGN__c= oldAddress.Member_Account_Number_AGN__c;
            newAddress.Primary_Physician_Email_AGN__c = oldAddress.Account_vod__r.Primary_Physician_Email_AGN__c;
            newAddress.Primary_Physician_Name_AGN__c = oldAddress.Account_vod__r.Primary_Physician_Name_AGN__c;
            newAddress.Primary_Physician_Phone_AGN__c = oldAddress.Account_vod__r.Primary_Physician_Phone_AGN__c;
            newAddress.Pharmacy_License_Number_AGN__c = oldAddress.Account_vod__r.SAP_Pharmacy_License_Number_AGN__c;
            newAddress.Is_Registred_Home_Address_AGN__c = oldAddress.Account_vod__r.Registered_Home_AGN__c;
            newAddress.Registering_on_behalf_of_owner_AGN__c = oldAddress.Account_vod__r.Registering_on_behalf_of_owner_AGN__c;
            newAddress.Part_of_a_Buying_Group_AGN__c = oldAddress.Part_of_a_Buying_Group_AGN__c;
            
            newAddress.Department_Name_AGN__c = oldAddress.Department_Name_AGN__c;
            newAddress.NIF_CIF_number_AGN__c = oldAddress.Account_vod__r.SAP_NIF_CIF_number_AGN__c;
          //newAddress.NIF_CIF_number_AGN__c = oldAddress.Account_vod__r.SAP_Tax_Number_AGN__c;
            system.debug('SAP_NIF_CIF_number_AGN__c prince'+oldAddress.Account_vod__r.SAP_NIF_CIF_number_AGN__c);
            newAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'Amend' LIMIT 1][0].Id;
            
            for (Child_Account_vod__c ch : [SELECT Child_Account_vod__c, 
                                            Sold_To_AGN__c, Ship_To_AGN__c, 
                                            Bill_To_AGN__c 
                                            FROM Child_Account_vod__c WHERE Parent_Account_vod__c = : oldAddress.Account_vod__c AND Customer_Managed_AGN__c = True Limit 1]){
                                                newAddress.Sold_To_AGN__c = ch.Sold_To_AGN__c;
                                                newAddress.Ship_To_AGN__c = ch.Ship_To_AGN__c;                            
                                                newAddress.Bill_To_AGN__c = ch.Bill_To_AGN__c;                              
                                            }
        }
        else{
            
            newAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id;
            //newAddress.SAP_Referenced_Customer_ID_AGN__c = AGN_OAMAccountDetailController.getAccountDetails().Primary_Parent_vod__r.External_ID2_AGN__c;
            newAddress.House_Number_AGN__c= '';
            newAddress.Street_Name_AGN__c = '';
            newAddress.Address_Line_2_AGN__c = '';
            newAddress.Address_Line_3_AGN__c = '';
            newAddress.City_AGN__c = '';
            newAddress.State_AGN__c = '';
            newAddress.Country_AGN__c = customerAccount.Country_vod__r.AGN_Country_Name__c;     
            newAddress.Zip_AGN__c = '';
            newAddress.Phone_AGN__c = '';
            newAddress.Phone_2_AGN__c = ''; 
            newAddress.Company_Name_AGN__c = '';
            newAddress.Email_AGN__c = '';           
            newAddress.Department_Name_AGN__c = '';
            newAddress.Distribution_ID_AGN__c = customerAccount.Primary_Parent_vod__r.Distribution_ID_AGN__c;
            
            //  newAddress.Address_Line_1_AGN__c = '';
            //  newAddress.City_AGN__c = '';
            //  newAddress.State_AGN__c = '';               
            //   newAddress.Zip_AGN__c = '';
            //   newAddress.Phone_AGN__c = '';
            //   newAddress.Company_Name_AGN__c = '';
            //   newAddress.Email_AGN__c = ''; 
        }
        return newAddress;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getPickListValues(string objectName,String columnName,String columnId, String whereCondition){
        String wherecond = whereCondition != null ? String.valueOf(whereCondition) : '';
        String query = 'select '+String.escapeSingleQuotes(String.valueOf(columnName))+','+String.escapeSingleQuotes(String.valueOf(columnId))+' From '+String.escapeSingleQuotes(objectName) + wherecond;
        system.debug('@@@@query@@@'+ query);
        List<sObject> PicklistValues = Database.query(query);
        return PicklistValues;         
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Object> getPaymentDetails(string formofPayment,String paymentTerm, String countryCode){
        system.debug('@@@@getPaymentDetails>>>>'+formofPayment+'>>>>'+paymentTerm+'>>>>'+countryCode);
        List<Object> optionsObject = new List<Object>();
        Form_of_Payment_AGN__c fop;
        if(countryCode == 'CA'){
            if(formofPayment != null){
                fop = [SELECT ID,Name, Form_Of_Payment_Label_AGN__c FROM Form_of_Payment_AGN__c 
                       WHERE (Form_Of_Payment_Label_AGN__c =: formofPayment OR Name =: formofPayment) 
                       AND Country_code_AGN__c =: countryCode];
                
                optionsObject.add(fop);               
            
            } 
        }       
        if(paymentTerm != null){            
            Payment_Term_AGN__c pt;            
            if(countryCode == 'CA'){                
                pt = [SELECT ID, Name,Payment_Term_Label_AGN__c FROM Payment_Term_AGN__c 
                      WHERE (Name =: paymentTerm OR Payment_Term_Label_AGN__c =: paymentTerm)
                      AND Form_Of_Payment__c =: fop.Id];
                
            }else{
                
              pt = [SELECT ID, Name,Payment_Term_Label_AGN__c FROM Payment_Term_AGN__c 
                                      WHERE SAP_Payment_Term_Code_AGN__c =: paymentTerm 
                                      AND Form_Of_Payment__c =: formofPayment];
            
            }
            
            optionsObject.add(pt);  
        }   
        system.debug('@@@@getPaymentDetails>>>>'+optionsObject);
        return optionsObject;         
    }  
    
    @AuraEnabled
    public static Case saveCustomerUpdate(string newAddress, string newRegistration, string activity){
        system.debug('newAddress--->'+newAddress);
        system.debug('newRegistration--->'+newRegistration);
        system.debug('activity--->'+activity);
        
        Account customerAccount = AGN_OAMAccountDetailController.getAccountDetails();
        
       
        list<Allergan_Customer_Payment_AGN__c> payment = [SELECT Account_AGN__c,
                                                          Form_Of_Payment_AGN__c,Payment_Term_AGN__c,
                                                          Bank_Name_AGN__c, Bank_Account_Number_AGN__c, 
                                                          IBAN_AGN__c,IBAN_Text_AGN__c, Sort_Code_AGN__c, SWIFT_BIC_AGN__c,
                                                          Business_Name_Reference1_AGN__c,Business_Name_Reference2_AGN__c,
                                                          Contact_Name_Reference1_AGN__c,Contact_Name_Reference2_AGN__c,
                                                          Fax_Reference1_AGN__c,Fax_Reference2_AGN__c,
                                                          Phone_Reference1_AGN__c,Phone_Reference2_AGN__c
                                                          FROM Allergan_Customer_Payment_AGN__c
                                                          WHERE Account_AGN__c =: customerAccount.Primary_Parent_vod__r.id LIMIT 1];
        
        
        Allergan_Customer_Address_AGN__c customerAddress = (Allergan_Customer_Address_AGN__c)JSON.deserialize(newAddress, Allergan_Customer_Address_AGN__c.class);
        if (!String.isBlank(customerAddress.House_Number_AGN__c) && !String.isBlank(customerAddress.Street_Name_AGN__c)){
            customerAddress.Address_Line_1_AGN__c =  customerAddress.Street_Name_AGN__c + ' , ' + customerAddress.House_Number_AGN__c;
        }   
        Allergan_Customer_Registration_AGN__c  customerReg = (Allergan_Customer_Registration_AGN__c)JSON.deserialize(newRegistration, Allergan_Customer_Registration_AGN__c.class);
        String changeList = '';
        
        if(customerAddress.Parent_Address_AGN__c != null){
            Address_vod__c oldCustomerAddress = [SELECT Id, Account_vod__c, Account_vod__r.External_ID2_AGN__c, Account_vod__r.Name, Name, Address_line_2_vod__c, Address_line_3_AGN__c, State_vod__c, City_vod__c, 
                                                 Country_vod__c, Phone_vod__c, Zip_vod__c, Email_AGN__c, Department_Name_AGN__c FROM Address_vod__c 
                                                 WHERE Id =: customerAddress.Parent_Address_AGN__c LIMIT 1];
            changeList += AGN_CustomerRegistrationUtils.generateChangeList(customerAddress, oldCustomerAddress);
        }
         System.debug('CIF : '+ customerAddress.NIF_CIF_number_AGN__c);
        
        Case caseNewCr = new Case();
        caseNewCr.Service_AGN__c = 'Customer Registration';     
        caseNewCr.Priority = 'Medium';
        caseNewCr.Origin = 'Web';
        caseNewCr.Status = 'New';
        caseNewCr.AccountId = customerAccount.Primary_Parent_vod__c;
        caseNewCr.ContactId = customerAccount.PersonContactId;
        //caseNewCr.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'AGN_Support_Request_Customer_Update' LIMIT 1][0].Id;
        RecordType caseRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'AGN_Support_Request_Customer_Update' LIMIT 1][0];
        caseNewCr.RecordTypeId = caseRecordType.Id;
        caseNewCr.SuppliedName = customerAccount.FirstName + ' ' + customerAccount.LastName;
        caseNewCr.SuppliedEmail = customerAccount.PersonEmail;
        caseNewCr.SuppliedPhone = customerAccount.Phone;
        caseNewCr.Description_Rich_Text__c = changeList;
        
        if (activity == 'delete'){
            caseNewCr.Type = 'Deactivate';
            caseNewCr.Reason = 'Deactivate Customer Address';           
        }
        else if (activity == 'new'){
            caseNewCr.Type = 'New';
            caseNewCr.Reason = 'New Customer Address';
        }  
        else{
            caseNewCr.Type = 'Update';
            caseNewCr.Reason = 'Update Customer Address'; 
        }
        system.debug('case details---->'+caseNewCr);
        system.debug('======setEntitlement========='+ caseRecordType.Name+'=='+ caseNewCr.Type+ '=='+customerAccount.Country_Code__c);
        caseNewCr.EntitlementId = AGN_OAMCustomerRegUtils.setEntitlement(caseRecordType.Name, caseNewCr.Type, customerAccount.Country_Code__c);
        
        //----------Checkmarx Fix ---Added on 03-08-2020---------
        List<Case> crCaseList = new List<Case>();
        crCaseList.add(caseNewCr);
        String objCrCase = 'Case';
        SObjectType objCrCaseType = ((SObject)(Type.forName('Schema.'+objCrCase).newInstance())).getSObjectType();
        AGN_FLSCheck.check(crCaseList,objCrCaseType,'INSERT');
        insert caseNewCr;
        //------------------------------------------------
        
        
        system.debug('case--->'+caseNewCr.Id);
        
        customerReg.Case_AGN__c = caseNewCr.Id; 
        customerReg.Processed_By_SAP_AGN__c = 'In Progress';
        customerReg.Change_List_AGN__c = changeList;
        customerReg.Online_Registration_AGN__c= true;
        customerReg.Business_Account_SAP_ID__c =  customerAccount.Primary_Parent_vod__r.External_ID2_AGN__c;
        
        if (activity == 'edit' && customerAddress.Sold_To_AGN__c == True){            
            if(payment != null && !payment.isEmpty() && payment[0].Form_Of_Payment_AGN__c != null){
                customerReg.Form_of_Payment_AGN__c = payment[0].Form_Of_Payment_AGN__c;                 
            }
            if(payment != null && !payment.isEmpty() && payment[0].Payment_Term_AGN__c != null){
                customerReg.Payment_Term_AGN__c = payment[0].Payment_Term_AGN__c; 
            }          
        }       
        if(customerAccount.Country_Code__c != 'CA'){        
          if(activity == 'new' && customerAddress.Bill_To_AGN__c == True){ 
              //list<Allergan_Customer_Payment_AGN__c> payment = [SELECT Form_Of_Payment_AGN__c, Payment_Term_AGN__c FROM Allergan_Customer_Payment_AGN__c WHERE Account_AGN__c =: customerAccount.Primary_Parent_vod__r.id LIMIT 1];
              if(payment != null && !payment.isEmpty() && payment[0].Form_Of_Payment_AGN__c != null){
                  customerReg.Form_of_Payment_AGN__c = payment[0].Form_Of_Payment_AGN__c;
              }
              if(payment != null && !payment.isEmpty() && payment[0].Payment_Term_AGN__c != null){
                  customerReg.Payment_Term_AGN__c = payment[0].Payment_Term_AGN__c; 
              }          
          }  
       } 
        //----------Checkmarx Fix ---Added on 03-08-2020---------
        List<Allergan_Customer_Registration_AGN__c> crRegList = new List<Allergan_Customer_Registration_AGN__c>();
        crRegList.add(customerReg);
        String objCrReg = 'Allergan_Customer_Registration_AGN__c';
        SObjectType objCrRegType = ((SObject)(Type.forName('Schema.'+objCrReg).newInstance())).getSObjectType();
        AGN_FLSCheck.check(crRegList,objCrRegType,'INSERT');
        insert customerReg;
        //------------------------------------------------
        
        customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
        customerAddress.Parent_AGN__c = customerReg.Id;
        customerAddress.Account_Type_AGN__c = customerAccount.Primary_Parent_vod__r.RecordType.DeveloperName;
         //customerAddress.NIF_CIF_number_AGN__c =  customerAddress.NIF_CIF_number_AGN__c;     
        if (activity == 'edit' && customerAddress.Sold_To_AGN__c == True){
            customerAddress.Form_Of_Payment_AGN__c = customerReg.Form_of_Payment_AGN__c;
            customerAddress.Payment_Term_AGN__c = customerReg.Payment_Term_AGN__c;       
            
        }       
        
        if(customerAccount.Country_Code__c != 'IT' ){
            customerAddress.Country_AGN__c =  customerAccount.Country_vod__r.AGN_Country_Name__c; 
        }
        
        customerAddress.Country_Lookup_AGN__c = customerAccount.Country_vod__c;
        
        if(activity == 'new'){
            system.debug('Tax classification --->'+customerAccount.Primary_Parent_vod__r.SAP_Tax_Classification_AGN__c );
            if(customerAccount.Country_Code__c == 'IT'){
                if(customerAddress.Country_AGN__c == 'Italy' ){
                    customerAddress.Tax_Classification_AGN__c = '9';
                }else{
                    customerAddress.Tax_Classification_AGN__c = '0';
                }
            }else if(customerAccount.Primary_Parent_vod__r.SAP_Tax_Classification_AGN__c != null){
                customerAddress.Tax_Classification_AGN__c = customerAccount.Primary_Parent_vod__r.SAP_Tax_Classification_AGN__c;
                
            }
            
            customerAddress.IBAN_AGN__c = customerAddress.IBAN_Text_AGN__c;
            
        }
        // added by abdul
       
        if(activity == 'edit'){
           if(customerAccount.Primary_Parent_vod__r.SAP_Tax_Classification_AGN__c != null){
                customerAddress.Tax_Classification_AGN__c = customerAccount.Primary_Parent_vod__r.SAP_Tax_Classification_AGN__c;                
            }
            
        }
        // end 
        if (activity=='delete'){
            customerAddress.Request_for_Deactivation_AGN__c =  true;
        }
        
        //----------Checkmarx Fix ---Added on 03-08-2020---------
        List<Allergan_Customer_Address_AGN__c> crAddrList = new List<Allergan_Customer_Address_AGN__c>();
        crAddrList.add(customerAddress);
        String objCrAddr= 'Allergan_Customer_Address_AGN__c';
        SObjectType objCrAddrType = ((SObject)(Type.forName('Schema.'+objCrAddr).newInstance())).getSObjectType();
        AGN_FLSCheck.check(crAddrList,objCrAddrType,'INSERT');
        insert customerAddress;
        //------------------------------------------------
        
        
          if(activity == 'edit' && customerAddress.Sold_To_AGN__c == True){
            if(payment == null || payment.isEmpty()){
                Allergan_Customer_Payment_AGN__c acp = new Allergan_Customer_Payment_AGN__c();
                acp.Form_Of_Payment_AGN__c = customerReg.Form_of_Payment_AGN__c;
                acp.Payment_Term_AGN__c = customerReg.Payment_Term_AGN__c;
                acp.Account_AGN__c = customerAccount.Primary_Parent_vod__c;
                acp.IBAN_AGN__c = customerAddress.IBAN_Text_AGN__c;
                acp.IBAN_Text_AGN__c = customerAddress.IBAN_Text_AGN__c;
                acp.SWIFT_BIC_AGN__c = customerAddress.SWIFT_BIC_AGN__c;
                acp.Bank_Name_AGN__c = customerAddress.Bank_Name_AGN__c;
                acp.Bank_Account_Number_AGN__c = customerAddress.Bank_Account_Number_AGN__c;
                acp.Sort_Code_AGN__c = customerAddress.Sort_Code_AGN__c;
                acp.Business_Name_Reference1_AGN__c = customerAddress.Business_Name_Reference1_AGN__c;
                acp.Business_Name_Reference2_AGN__c = customerAddress.Business_Name_Reference2_AGN__c;
                acp.Contact_Name_Reference1_AGN__c = customerAddress.Contact_Name_Reference1_AGN__c;
                acp.Contact_Name_Reference2_AGN__c = customerAddress.Contact_Name_Reference2_AGN__c;
                acp.Fax_Reference1_AGN__c = customerAddress.Fax_Reference1_AGN__c;
                acp.Fax_Reference2_AGN__c = customerAddress.Fax_Reference2_AGN__c;
                acp.Phone_Reference1_AGN__c = customerAddress.Phone_Reference1_AGN__c;
                acp.Phone_Reference2_AGN__c = customerAddress.Phone_Reference2_AGN__c;
                
                
                //----------Checkmarx Fix ---Added on 03-08-2020---------
                List<Allergan_Customer_Payment_AGN__c> crAcpList = new List<Allergan_Customer_Payment_AGN__c>();
                crAcpList.add(acp);
                String objAcp= 'Allergan_Customer_Payment_AGN__c';
                SObjectType objAcpType = ((SObject)(Type.forName('Schema.'+objAcp).newInstance())).getSObjectType();
                AGN_FLSCheck.check(crAcpList,objAcpType,'INSERT');
                insert acp;
                //------------------------------------------------

                
            }
              /*else if(payment[0].Form_Of_Payment_AGN__c == null ||  payment[0].Payment_Term_AGN__c == null){
                payment[0].Form_Of_Payment_AGN__c = customerReg.Form_of_Payment_AGN__c;
                payment[0].Payment_Term_AGN__c = customerReg.Payment_Term_AGN__c;
                payment[0].IBAN_AGN__c = customerAddress.IBAN_Text_AGN__c;
                payment[0].IBAN_Text_AGN__c = customerAddress.IBAN_Text_AGN__c;
                payment[0].SWIFT_BIC_AGN__c = customerAddress.SWIFT_BIC_AGN__c;
                payment[0].Bank_Name_AGN__c = customerAddress.Bank_Name_AGN__c;
                payment[0].Bank_Account_Number_AGN__c = customerAddress.Bank_Account_Number_AGN__c;
                payment[0].Sort_Code_AGN__c = customerAddress.Sort_Code_AGN__c;
                payment[0].Business_Name_Reference1_AGN__c = customerAddress.Business_Name_Reference1_AGN__c;
                payment[0].Business_Name_Reference2_AGN__c = customerAddress.Business_Name_Reference2_AGN__c;
                payment[0].Contact_Name_Reference1_AGN__c = customerAddress.Contact_Name_Reference1_AGN__c;
                payment[0].Contact_Name_Reference2_AGN__c = customerAddress.Contact_Name_Reference2_AGN__c;
                payment[0].Fax_Reference1_AGN__c = customerAddress.Fax_Reference1_AGN__c;
                payment[0].Fax_Reference2_AGN__c = customerAddress.Fax_Reference2_AGN__c;
                payment[0].Phone_Reference1_AGN__c = customerAddress.Phone_Reference1_AGN__c;
                payment[0].Phone_Reference2_AGN__c = customerAddress.Phone_Reference2_AGN__c;
                
                update payment;
            }*/
            
        } 
        
        AGN_Case_Next.gotoNextStep(caseNewCr.Id);        
        
        return [select CaseNumber, Id from Case where Id =: caseNewCr.Id limit 1];        
        
    }
    
    @AuraEnabled
    public static string savetestFile(){
        
        Case c=new Case();
        c=[select CaseNumber, Id from Case limit 1];
        return c.CaseNumber;
        
    }
    
    
    @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType) {
        system.debug('== [FileUploadMethod].[saveTheFile] =='+parentId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        List<Attachment> attachmentList = new List<Attachment>();
        Allergan_Customer_Registration_AGN__c acr = new Allergan_Customer_Registration_AGN__c();
        acr = [SELECT Id, Case_AGN__c  FROM Allergan_Customer_Registration_AGN__c WHERE Case_AGN__c=:parentId LIMIT 1];
        
        
        Attachment attachmentFile = new Attachment(); 
        attachmentFile.ParentId = acr.Id;
        attachmentFile.Body = EncodingUtil.base64Decode(base64Data);
        attachmentFile.Name = fileName;
        attachmentFile.ContentType = contentType;
        
        system.debug('•attachmentFile•'+attachmentFile);
        //------CheckMarx--Added on 24/07/2020---------- 
        List<Attachment> tmpAttList = new List<Attachment>();        
        tmpAttList.add(attachmentFile);
        String objCrAtt = 'Attachment';
        SObjectType ACRAttObjType = ((SObject)(Type.forName('Schema.'+objCrAtt).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tmpAttList,ACRAttObjType,'INSERT');
        //-----------------------------------------------
        insert attachmentFile;        
        return attachmentFile.Id;
        
    }  
    
    @AuraEnabled 
    public static string getDocument(string type, string CustomerGroup){
        String communityBaseURL = AGN_OAMConstant.COMMUNITY_BASE_URL+AGN_OAMConstant.COMMUNITY_SUFFIX; 
        list<Document> docId;
        
        system.debug('Label.AGN_OAM_ShipTo_License_Doc>>>>>>'+Label.AGN_OAM_ShipTo_License_Doc);
        if(type =='Sold To' ){
            if(CustomerGroup=='PH'||CustomerGroup=='P2'||CustomerGroup=='P3'){
              docId =  [SELECT Id FROM Document WHERE Name =: Label.AGN_OAM_Account_Owner_SigDoc_Pharmacy];  
            }else{
              docId =  [SELECT Id FROM Document WHERE Name =: Label.AGN_OAM_Account_Owner_SigDoc];
            }
              
        }else if(type == 'Ship To'){
            docId =  [SELECT Id FROM Document WHERE Name =: Label.AGN_OAM_ShipTo_License_Doc]; 
        }  
        if(docId.size()>0){
            return communityBaseURL+'/servlet/servlet.FileDownload?file='+docId[0].Id;  
        }else{return null;}
        
    }
    /*   
@AuraEnabled
public static List<SelectOption> getRegionList(string countryCode){

List<SelectOption> regionList = new List<SelectOption>();
regionList.add(new SelectOption('', ''));
Schema.DescribeFieldResult fieldResult = Allergan_Customer_Address_AGN__c.State_AGN__c.getDescribe();     
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
for( Schema.PicklistEntry f : ple){
if(f.getValue().left(2).toUpperCase()==countryCode.toUpperCase())
regionList.add(new SelectOption(f.getValue(), f.getLabel()));
}     

//regionList.add(new SelectOption('', '')); 
//for (AGN_CR_CountryRegionMapping__mdt reg : AGN_CustomerRegistrationUtils.getRegions(AGN_OAMAccountDetailController.getAccountDetails().Country_vod__r.Alpha_2_Code_vod__c)){             
//regionList.add(new SelectOption(reg.RegionCode__c , reg.RegionName__c));
//}
//regionList.sort();
return regionList; 
}  */
    
    @AuraEnabled
    public static Customer_Type_Configuration_AGN__c getCustTypeConfigDetails(){
        
        Account acc = AGN_OAMAccountDetailController.getAccountDetails();
        
        Customer_Type_Configuration_AGN__c ctypeConfig = [SELECT ID, Category_AGN__c,
                                                          Category_Label_AGN__c,
                                                          Country_Code_AGN__c,
                                                          Customer_Country_AGN__r.Alpha_2_Code_vod__c,
                                                          Customer_Group_AGN__c,
                                                          Sub_Category__c 
                                                          FROM Customer_Type_Configuration_AGN__c
                                                          WHERE Customer_Group_AGN__c =: acc.SAP_Customer_Group_AGN__c 
                                                          //AND Country_Code_AGN__c =: acc.SAP_Country_Code_AGN__c LIMIT 1];
                                                          AND Country_Code_AGN__c =: acc.Country_Code__c
                                                          AND Customer_Country_AGN__c =: acc.Country_vod__c
                                                          AND Applicable_For_Online_Registration_AGN__c = true
                                                          LIMIT 1];    
        
        return ctypeConfig;        
        
    }  
    
    @AuraEnabled
    public static Map<String , List<AGN_CommunityDependentLayout__mdt>> getDependantLayout(String country) {
        
        return AGN_OAMCustomerRegUtils.getDependantFieldSettings(country); 
    }
    
    @AuraEnabled
    public static String[] getValidAddress(Allergan_Customer_Address_AGN__c customerAddress , String province){
        system.debug('Address Validation>>>>>>>>>>>>>>>>>>'+customerAddress+province);
        List<String> address = new List<String>();
        try{
            if(customerAddress != null && String.isNotBlank(province)){
                String addressInput = '';
                if(String.isNotBlank(customerAddress.Suite_AGN__c)){
                    addressInput = customerAddress.Suite_AGN__c +' '+customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.Zip_AGN__c;
                }else{
                    addressInput = customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.Zip_AGN__c;
                }
                system.debug('addressInput>>>>>>>>>>>>>>>>>>>'+addressInput);
                address = AGN_LoqateAddressLookupController.getValidAddresses(addressInput , '');
            }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
            
        }
        return address;
    }
    
    /*  @AuraEnabled
public static Allergan_Customer_Address_AGN__c fetchAddressDetail(string newAddress){

Allergan_Customer_Address_AGN__c customerAddress = (Allergan_Customer_Address_AGN__c)JSON.deserialize(newAddress, Allergan_Customer_Address_AGN__c.class); 
AGN_CustomerRegistrationUtils.AddressDetail cepDetail= AGN_CustomerRegistrationUtils.getAddressDetail(customerAddress.Zip_AGN__c);
customerAddress.Street_Name_AGN__c = cepDetail.street;
customerAddress.Address_Line_1_AGN__c = cepDetail.street;
customerAddress.Address_Line_2_AGN__c = cepDetail.complement;
customerAddress.Address_Line_3_AGN__c = cepDetail.bairro;         
customerAddress.City_AGN__c = cepDetail.city;
customerAddress.State_AGN__c = 'BR-'+cepDetail.state;

return customerAddress;

} */
    
    //Standard Apex, but it's not Aura-enabled
    
    public class SelectOption {
        
        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public String value { get;set; }
        @AuraEnabled
        public Boolean disabled { get;set; }
        @AuraEnabled
        public Boolean escapeItem { get;set; }
        
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
            this.disabled = false;
            this.escapeItem = false;
        }
        
        public SelectOption(String value, String label, Boolean isDisabled) {
            this.value = value;
            this.label = label;
            this.disabled = isDisabled;
            this.escapeItem = false;
        }       
    }
    
}