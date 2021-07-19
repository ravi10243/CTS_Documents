/*
Type Name: AGN_CustomerAccountDetailController
Reason: Controller class for Cusomer update page lightning components
21-03-2017 - SG - Initial Version
*/
public without sharing class AGN_CustomerAccountUpdateController {
    
    @AuraEnabled
    public Allergan_Customer_Registration_AGN__c newRegistration {get;set;}
    @AuraEnabled
    public Allergan_Customer_Address_AGN__c newAddress {get;set;}
    public static Account customerAccount;
    
    @AuraEnabled
    public static AGN_CustomerAccountUpdateController doInit(Id addressId, string type){
        
        customerAccount = AGN_CustomerAccountDetailController.getAccountDetails();
        
        AGN_CustomerAccountUpdateController obj = new AGN_CustomerAccountUpdateController();
        obj.newRegistration = new Allergan_Customer_Registration_AGN__c();  
        obj.newRegistration.Account_AGN__c = customerAccount.Id;
        obj.newRegistration.Account_Status_AGN__c = customerAccount.Status_AGN__c ;
        obj.newRegistration.Account_Sub_Type_AGN__c = customerAccount.Type_AGN__c ;
        obj.newRegistration.AGN_Identifier_AGN__c = customerAccount.External_ID4_AGN__c ;
        obj.newRegistration.BirthDate_AGN__c = customerAccount.PersonBirthdate ;
        obj.newRegistration.Business_Unit_AGN__c = customerAccount.Additional_Specialties_AGN__c ;
        obj.newRegistration.Consent_to_Contact_AGN__c = customerAccount.Consent_to_Contact_AGN__c ? 'Yes':'No';
        obj.newRegistration.Consent_to_Email_AGN__c = customerAccount.Consent_to_Email_AGN__c ? 'Yes':'No';
        obj.newRegistration.Consent_to_Mail_AGN__c = customerAccount.Consent_to_Mail_AGN__c ? 'Yes':'No';
        obj.newRegistration.Consent_to_Phone_AGN__c = customerAccount.Consent_to_Phone_AGN__c ? 'Yes':'No';
        obj.newRegistration.Country_AGN__c = customerAccount.Primary_Parent_vod__r.Country_vod__c;//customerAccount.Country_vod__c ;
        obj.newRegistration.Country_Code_AGN__c = customerAccount.Primary_Parent_vod__r.Country_Code__c;//customerAccount.Country_Code__c ;
        obj.newRegistration.SAP_Country_Code_AGN__c = customerAccount.Primary_Parent_vod__r.SAP_Country_Code_AGN__c;//customerAccount.SAP_Country_Code_AGN__c ;
        obj.newRegistration.Customer_Group_AGN__c = customerAccount.Primary_Parent_vod__r.SAP_Customer_Group_AGN__c;//customerAccount.SAP_Customer_Group_AGN__c ;
         obj.newRegistration.Customer_Sub_Category_AGN__c = customerAccount.Primary_Parent_vod__r.Customer_Category_AGN__c;
        obj.newRegistration.Customer_Sub_Category_AGN__c = customerAccount.Primary_Parent_vod__r.Customer_Sub_Category_AGN__c;
        obj.newRegistration.Distribution_ID_AGN__c = customerAccount.Primary_Parent_vod__r.Distribution_ID_AGN__c;//customerAccount.Distribution_ID_AGN__c ;
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
        
        
        
        obj.newRegistration.Contact_Person_Type_AGN__c = customerAccount.SAP_Contact_Person_Type_AGN__c;  // EMEA OAM
        
        obj.newRegistration.OwnerId= customerAccount.OwnerID ;
        
        obj.newRegistration.Online_Registration_AGN__c = true;
        obj.newRegistration.RecordTypeId= [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'Update' LIMIT 1][0].Id;
        obj.newAddress = getNewAddress(addressId, type, customerAccount.Id);
        
        if (type == 'SoldTo' || type == 'BillTo'){
        
            if (addressId != null){
                
                Id accountId = [select Account_vod__c from Address_vod__c where Id =: addressId limit 1].Account_vod__c;
                
                for (Allergan_Customer_Payment_AGN__c payment : [SELECT Account_AGN__c, 
                                                                        Bank_Name_AGN__c, 
                                                                        Bank_Account_Number_AGN__c, 
                                                                        IBAN_Text_AGN__c, 
                                                                        Sort_Code_AGN__c, 
                                                                        SWIFT_BIC_AGN__c,
                                                                        Form_Of_Payment_AGN__c,
                                                                        Payment_Term_AGN__c
                                                                   FROM Allergan_Customer_Payment_AGN__c 
                                                                  WHERE Account_AGN__c =: accountId LIMIT 1]){              
                    obj.newAddress.IBAN_Text_AGN__c= payment.IBAN_Text_AGN__c;
                    obj.newAddress.SWIFT_BIC_AGN__c = payment.SWIFT_BIC_AGN__c;
                    obj.newAddress.Bank_Name_AGN__c = payment.Bank_Name_AGN__c;
                    obj.newAddress.Bank_Account_Number_AGN__c = payment.Bank_Account_Number_AGN__c;
                    obj.newAddress.Form_Of_Payment_AGN__c = payment.Form_Of_Payment_AGN__c;     
                    obj.newAddress.Payment_Term_AGN__c = payment.Payment_Term_AGN__c;                                                    
                    if(!string.isBlank(payment.Sort_Code_AGN__c))
                        obj.newAddress.Sort_Code_AGN__c = payment.Sort_Code_AGN__c.remove('-');
                    obj.newAddress.Customer_Payment__c = payment.Id;
                }
            }
            else{
                
                obj.newAddress.IBAN_Text_AGN__c= '';
                obj.newAddress.SWIFT_BIC_AGN__c = '';
                obj.newAddress.Bank_Name_AGN__c = '';
                obj.newAddress.Bank_Account_Number_AGN__c = '';
                obj.newAddress.Sort_Code_AGN__c = '';
                obj.newRegistration.Form_Of_Payment_AGN__c = [SELECT Id FROM Form_Of_Payment_AGN__c WHERE Country_Code_AGN__c=:customerAccount.Country_Code__c AND Active_AGN__c= true and Name = 'Direct Debit' LIMIT 1].Id;
            }
        }
        
        obj.newRegistration.Form_Of_Payment_AGN__c = obj.newAddress.Form_Of_Payment_AGN__c;
        obj.newRegistration.Payment_Term_AGN__c = obj.newAddress.Payment_Term_AGN__c;
        obj.newRegistration.VAT_AGN__c = obj.newAddress.VAT_Number_AGN__c;
        system.debug('obj>>>>>>>>>>>>>>>>>>>'+obj);
        return obj;
    }
    
    @AuraEnabled
    public static Allergan_Customer_Address_AGN__c getNewAddress(Id addressId, string type, String PAId){
        
        Allergan_Customer_Address_AGN__c newAddress = new Allergan_Customer_Address_AGN__c();
        //newAddress.Country_AGN__c =  AGN_CustomerAccountDetailController.getAccountDetails().Country_vod__r.AGN_Country_Name__c;
        newAddress.Country_AGN__c =  AGN_CustomerAccountDetailController.getAccountDetails().Primary_Parent_vod__r.Country_vod__r.AGN_Country_Name__c;
                
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
                                         
                                                Account_vod__r.Calling_Name_AGN__c,
                                                Account_vod__r.Fax,
                                                Account_vod__r.SAP_Additional_Shipping_Instructions_AGN__c,
                                                Account_vod__r.SAP_Customer_group_1_AGN__c,
                                                Account_vod__r.SAP_Customer_Group_AGN__c,
                                                Account_vod__r.SAP_Default_Address_AGN__c,
                                                Account_vod__r.SAP_Name_2_AGN__c,
                                                Account_vod__r.SAP_Name_3_AGN__c,
                                                Account_vod__r.SAP_Name_4_AGN__c, 
                                                Account_vod__r.SAP_SalesText_AGN__c,
                                                Account_vod__r.SAP_Search_Term_1_AGN__c,
                                                Account_vod__r.SAP_Search_Term_2_AGN__c,
                                                Account_vod__r.SAP_Shipping_Instructions_AGN__c,
                                                Account_vod__r.SAP_Sold_To_AGN__c,
                                                Account_vod__r.SAP_Ship_To_AGN__c,
                                                Account_vod__r.SAP_Bill_To_AGN__c,
                                                Account_vod__r.SAP_Tax_Classification_AGN__c,
                                                Account_vod__r.SAP_VAT_Number_AGN__c        

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
       
            newAddress.Department_Name_AGN__c = oldAddress.Department_Name_AGN__c;            
            
            newAddress.Department_Name_AGN__c = oldAddress.Account_vod__r.Calling_Name_AGN__c;
            newAddress.Fax_AGN__c = oldAddress.Account_vod__r.Fax;
            newAddress.Additional_Shipping_Instructions_AGN__c = oldAddress.Account_vod__r.SAP_Additional_Shipping_Instructions_AGN__c;
            newAddress.Customer_group_1_AGN__c = oldAddress.Account_vod__r.SAP_Customer_group_1_AGN__c;
            newAddress.Customer_Group_AGN__c = oldAddress.Account_vod__r.SAP_Customer_Group_AGN__c;
            newAddress.Default_AGN__c = oldAddress.Account_vod__r.SAP_Default_Address_AGN__c;
            newAddress.SAP_Name_2_AGN__c = oldAddress.Account_vod__r.SAP_Name_2_AGN__c;
            newAddress.SAP_Name_3_AGN__c = oldAddress.Account_vod__r.SAP_Name_3_AGN__c;
            newAddress.SAP_Name_4_AGN__c = oldAddress.Account_vod__r.SAP_Name_4_AGN__c;
            newAddress.SAP_SalesText_AGN__C = oldAddress.Account_vod__r.SAP_SalesText_AGN__c;
            newAddress.SAP_Search_Term_1_AGN__c = oldAddress.Account_vod__r.SAP_Search_Term_1_AGN__c;
            newAddress.SAP_Search_Term_2_AGN__c = oldAddress.Account_vod__r.SAP_Search_Term_2_AGN__c;
            newAddress.Shipping_Instructions_AGN__c = oldAddress.Account_vod__r.SAP_Shipping_Instructions_AGN__c;
            newAddress.Sold_To_AGN__c = oldAddress.Account_vod__r.SAP_Sold_To_AGN__c;
            /*Added below two lines to fix shipto checkbox issue*/
            newAddress.Ship_To_AGN__c = oldAddress.Account_vod__r.SAP_Ship_To_AGN__c;
            newAddress.Bill_To_AGN__c = oldAddress.Account_vod__r.SAP_Bill_To_AGN__c;
            /* Code Fix Ends */
            newAddress.Tax_Classification_AGN__c = oldAddress.Account_vod__r.SAP_Tax_Classification_AGN__c;
            newAddress.VAT_Number_AGN__c = oldAddress.Account_vod__r.SAP_VAT_Number_AGN__c ;       

            newAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'Amend' LIMIT 1][0].Id;
            
            for (Child_Account_vod__c ch : [SELECT Child_Account_vod__c, 
                                                Sold_To_AGN__c, Ship_To_AGN__c, 
                                                Bill_To_AGN__c 
                                            FROM Child_Account_vod__c 
                                            WHERE Child_Account_vod__c =:PAId 
                                            AND Parent_Account_vod__c = :oldAddress.Account_vod__c 
                                            Limit 1]){ //Parent_Account_vod__c = :oldAddress.Account_vod__c AND Customer_Managed_AGN__c = True
                newAddress.Sold_To_AGN__c = ch.Sold_To_AGN__c;
                newAddress.Ship_To_AGN__c = ch.Ship_To_AGN__c;                            
                newAddress.Bill_To_AGN__c = ch.Bill_To_AGN__c;                              
            }
        }
        else{
            
            newAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id;
            //newAddress.SAP_Referenced_Customer_ID_AGN__c = AGN_CustomerAccountDetailController.getAccountDetails().Primary_Parent_vod__r.External_ID2_AGN__c;
            newAddress.House_Number_AGN__c= '';
            newAddress.Street_Name_AGN__c = '';
            newAddress.Address_Line_2_AGN__c = '';
            newAddress.Address_Line_3_AGN__c = '';
            newAddress.City_AGN__c = '';
            newAddress.State_AGN__c = '';
            newAddress.Country_AGN__c = customerAccount.Primary_Parent_vod__r.Country_vod__r.AGN_Country_Name__c;//customerAccount.Country_vod__r.AGN_Country_Name__c;     
            newAddress.Zip_AGN__c = '';
            newAddress.Phone_AGN__c = '';
            newAddress.Phone_2_AGN__c = ''; 
            newAddress.Company_Name_AGN__c = '';
            newAddress.Email_AGN__c = '';           
            newAddress.Department_Name_AGN__c = '';
            newAddress.Distribution_ID_AGN__c = customerAccount.Primary_Parent_vod__r.Distribution_ID_AGN__c;
        /*  newAddress.Address_Line_1_AGN__c = '';
            newAddress.City_AGN__c = '';
            newAddress.State_AGN__c = '';               
            newAddress.Zip_AGN__c = '';
            newAddress.Phone_AGN__c = '';
            newAddress.Company_Name_AGN__c = '';
            newAddress.Email_AGN__c = ''; */
        }
        return newAddress;
        
    }
    
    
    @AuraEnabled
    public static Case saveCustomerUpdate(string newAddress, string newRegistration, string activity){
       
        
        Contact con = AGN_CustomerAccountDetailController.getContactDetails();        
        Account customerAccount = AGN_CustomerAccountDetailController.getAccountDetails();
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
        
        //Fix for PMO 3091 and INC #INC0465845 Santanu Start
        caseNewCr.Business_Unit_AGN__c = customerAccount.Type_AGN__c == 'Dentista (Pessoa Física)' ? customerAccount.Additional_Specialties_AGN__c : '';
        //End
        
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
        system.debug('======setEntitlement========='+ caseRecordType.Name+'=='+ caseNewCr.Type+ '=='+customerAccount.Country_Code__c);
        //caseNewCr.EntitlementId = AGN_CustomerRegistrationUtils.setEntitlement(caseRecordType.Name, caseNewCr.Type, customerAccount.Country_Code__c);
        caseNewCr.EntitlementId = AGN_CustomerRegistrationUtils.setEntitlement(caseRecordType.Name, caseNewCr.Type, customerAccount.Primary_Parent_vod__r.Country_Code__c);
        //------CheckMarx--Added on 23/07/2020----------      
        List<Case> tempCsList = new List<Case>();
        tempCsList.add(caseNewCr);
        String objCs = 'Case';
        SObjectType CSbjType = ((SObject)(Type.forName('Schema.'+objCs).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCsList,CSbjType,'INSERT');  
        insert caseNewCr;

        //--------------------
        
        
        customerReg.Case_AGN__c = caseNewCr.Id; 
        customerReg.Processed_By_SAP_AGN__c = 'In Progress';
        customerReg.Change_List_AGN__c = changeList;
        customerReg.Online_Registration_AGN__c= true;
        //------CheckMarx--Added on 23/07/2020----------      
        List<Allergan_Customer_Registration_AGN__c> tempCrRegList = new List<Allergan_Customer_Registration_AGN__c>();
        tempCrRegList.add(customerReg);        
        String objCReg = 'Allergan_Customer_Registration_AGN__c';
        SObjectType CRegbjType = ((SObject)(Type.forName('Schema.'+objCReg).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCrRegList,CRegbjType,'INSERT');  
        insert customerReg; 
        //--------------------
        
        
        
        customerAddress.Parent_AGN__c = customerReg.Id;
        customerAddress.Account_Type_AGN__c = customerAccount.Primary_Parent_vod__r.RecordType.DeveloperName;
        customerAddress.Sub_Type_AGN__c = customerAccount.Primary_Parent_vod__r.Type_AGN__c;
        customerAddress.Country_AGN__c =  customerAccount.Primary_Parent_vod__r.Country_vod__r.AGN_Country_Name__c;//customerAccount.Country_vod__r.AGN_Country_Name__c;
        customerAddress.Country_Lookup_AGN__c = customerAccount.Primary_Parent_vod__r.Country_vod__c;//customerAccount.Country_vod__c;
        
        if (activity=='delete'){
            customerAddress.Request_for_Deactivation_AGN__c =  true;
        }
        
        //------CheckMarx--Added on 23/07/2020----------      
        List<Allergan_Customer_Address_AGN__c> tempCrAddList = new List<Allergan_Customer_Address_AGN__c>();
        tempCrAddList.add(customerAddress);        
        String objCRAddr = 'Allergan_Customer_Address_AGN__c';
        SObjectType CRAddrbjType = ((SObject)(Type.forName('Schema.'+objCRAddr).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCrAddList,CRAddrbjType,'INSERT');  
        insert customerAddress;
        //--------------------
        
        
        // add allergan customer registration and Contact relation
        Allergan_Customer_Contact_AGN__c crContact = new Allergan_Customer_Contact_AGN__c();
        crContact.Parent_AGN__c = customerReg.Id; 
        crContact.Contact_AGN__c = con.Id;
        crContact.First_Name_AGN__c = con.FirstName;
        crContact.Last_Name_AGN__c  = con.LastName;
        crContact.Email_AGN__c =  con.Email;
        crContact.Salutation_AGN__c = con.Salutation;
        crContact.Phone_AGN__c = con.Phone;
        crContact.Middle_Name_AGN__c = con.Middle_Name_AGN__c;
        crContact.Primary_Contact_AGN__c = con.Is_Primary_Contact_AGN__c;
        crContact.Enable_Portal_User_AGN__c = true;
        crContact.Enable_HCP_AGN__c = string.isBlank(customerAccount.PersonContactId)? false:true;
        crContact.Allergan_Direct_Access_Requested_AGN__c = con.Has_Allergan_Direct_Access_AGN__c;
        //------CheckMarx--Added on 23/07/2020----------      
        List<Allergan_Customer_Contact_AGN__c> tempCrCntList = new List<Allergan_Customer_Contact_AGN__c>();
        tempCrCntList.add(crContact);       
        String objCRCnt= 'Allergan_Customer_Contact_AGN__c';
        SObjectType CRCntbjType = ((SObject)(Type.forName('Schema.'+objCRCnt).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCrCntList,CRCntbjType,'INSERT');  
        insert crContact;
        //--------------------
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
        //------CheckMarx--Added on 23/07/2020----------
        List<Attachment> tmpattList = new List<Attachment>();        
        tmpattList.add(attachmentFile);       
        String objCrAtt = 'Attachment';
        SObjectType ACRAttObjType = ((SObject)(Type.forName('Schema.'+objCrAtt).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tmpAttList,ACRAttObjType,'INSERT');
        insert attachmentFile;
        return attachmentFile.Id;
        //--------------------       
    }
    

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
        
        /*regionList.add(new SelectOption('', '')); 
        for (AGN_CR_CountryRegionMapping__mdt reg : AGN_CustomerRegistrationUtils.getRegions(AGN_CustomerAccountDetailController.getAccountDetails().Country_vod__r.Alpha_2_Code_vod__c)){             
            regionList.add(new SelectOption(reg.RegionCode__c , reg.RegionName__c));
        }*/
        //regionList.sort();
        return regionList; 
    }
    
    @AuraEnabled
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
         
    }

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