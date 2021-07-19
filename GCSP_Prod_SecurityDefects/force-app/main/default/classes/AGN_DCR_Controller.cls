// AGN_DCR_Controller
    public without sharing class AGN_DCR_Controller {
        //Custom Labels
        String HCO = 'HCO';
        String HCP = 'HCP';
        String Processing = 'Processing';
        String Accepted = 'Accepted';
        String Rejected = 'Rejected';
        String Submitted = 'Submitted'; 
        String Active = 'Active';
        String Inactive = 'Inactive';
        String Pending_Validation = 'Pending_Validation';
        String Add = 'Add';
        String Change = 'Change';
        String Remove = 'Delete';
        String HCO_Ins_Self = System.Label.Record_Type_1;
        String HCP_Ins_Self = System.Label.Record_Type_2;
        String HCO_Upd_Self = System.Label.Record_Type_3;
        String HCP_Upd_Self = System.Label.Record_Type_4;
        String HCO_Ins_DP = System.Label.Record_Type_5;
        String HCP_Ins_DP = System.Label.Record_Type_6;
        String dcr_task_subject = System.Label.DCR_Task;
       
        public DCR_AGN__c cr {get; set;}
        public ID dcrId;
        public string dcrRecordType{get; set;}
        public User loggedInUser {get; set;}
        public boolean isMslUser {get; set;}
        public String createdByName {get; set;}
        public DCR_Configuration_Settings_AGN__c configSettings;
        Map <String,DCR_Configuration_Settings_AGN__c> configSettingsMap =  new Map <String,DCR_Configuration_Settings_AGN__c>();
        Map <String,DCR_Configuration_Settings_AGN__c> configSettingsMap2 =  new Map <String,DCR_Configuration_Settings_AGN__c>();

        
        //List of variables to store parameter values
        public string accountTypeParam;
        public string actionTypeParam {get; set;}
        public string approvalTypeParam {get;set;}
        public Boolean immediateTerritoryAlignmentParam;
        public Boolean provisionalContactParam;
        public Boolean showProdMetrParam {get;set;}
        public string recType;
        public string retUrlParam;    
        //R006
        public Boolean territoryAlignmentAfterApprovalParam;
        
        public Boolean isPersonAccount { get { return cr.Request_Entity_AGN__c == HCP; } }
        public Boolean isBusinessAccount { get { return cr.Request_Entity_AGN__c == HCO; } }
        public Boolean isPersonAccountAdd { get { return cr.Request_Type_AGN__c == Add && cr.Request_Entity_AGN__c == HCP; } }
        public Boolean isPersonAccountChange { get { return cr.Request_Type_AGN__c == Change && cr.Request_Entity_AGN__c == HCP; } }
        public Boolean isBusinessAccountAdd { get { return cr.Request_Type_AGN__c == Add && cr.Request_Entity_AGN__c == HCO; } }
        public Boolean isBusinessAccountChange { get { return cr.Request_Type_AGN__c == Change && cr.Request_Entity_AGN__c == HCO; } }
        public Boolean isHospitalDepartment { get { return cr.Account_Type_AGN__c == 'HospitalDepartment_vod'; } }
        public Boolean enableSubmit {get;set;}    
        public Boolean viewReadOnly {get;set;}
        public Boolean viewReadWrite {get;set;}
        public Boolean viewReadWritePM {get;set;}
        public Boolean viewReadOnlyPM {get;set;}
        public Boolean showApproveReject {get;set;}
        public Integer showDelAffiliation { get{ return affiliatedAccounts.size(); } set; }
        public String primaryAffiliatedAccount { get;set; }
        // R008 : Composite DCR
        public List<DCRProductMetricsWrapper> cdcrProdMetrWrappers {get; set;}
        public String selectedValue {get; set;}
        public Boolean ChangePrimaryAffiliationCheck {get;set;}
        public Boolean Account_Phone {get;set;}
        public Boolean Address_Line_3 {get;set;}
        public Boolean Birthdate {get;set;}
        public List<DCR_AGN__c> pDCRList {get;set;}
        public Boolean Brick {get;set;}
        public Boolean City {get;set;}
        public Boolean Education_Speciality {get;set;}
        public Boolean FirstName {get;set;}
        public Boolean Gender {get;set;}
        public List<DCR_AGN__c> cDCRList {get;set;}
        public Boolean Graduation_Year {get;set;}
        public Boolean Last_Name {get;set;}
        public Boolean Physician_Registration_Reference {get;set;}
        public Boolean Postal_Code {get;set;}
        public Boolean State {get;set;}
        public Boolean Salutation {get;set;}
        public Boolean beds {get;set;}
        public Boolean departments {get;set;}
        public Boolean accountGroup {get;set;}
        public Boolean allerganAccountGroup {get;set;}
        public Boolean additionalSpecialties {get;set;}
        public Boolean addressWhanin {get;set;}
        public Boolean accountSubType {get;set;}
        public Boolean addressLine2 {get;set;}
        public Boolean addressType {get;set;}
        public Boolean agnSpecialtyCheck {get;set;}
        public Boolean agnSubSpecialty {get;set;}
        public Boolean apptRequired {get;set;}
        public Boolean avocisDate {get;set;}
        public Boolean avocisPlaced {get;set;}
        public Boolean billing {get;set;}
        public Boolean business {get;set;}
        public Boolean callingName {get;set;}
        public Boolean consentToContact {get;set;}
        public Boolean consentToEmail {get;set;}
        public Boolean consentToMail {get;set;}
        public Boolean consentToPhone {get;set;}
        public Boolean country {get;set;}
        public Boolean customerConsent {get;set;}
        public Boolean defaultOrderType {get;set;}
        public Boolean description {get;set;}
        public Boolean distributionID {get;set;}
        public Boolean doNotPhoneCall {get;set;}
        public Boolean doNotSendFax {get;set;}
        public Boolean doNotSendMail {get;set;}
        public Boolean doNotVisit {get;set;}
        public Boolean emailInternal {get;set;}
        public Boolean externalID {get;set;}
        public Boolean externalID1 {get;set;}
        public Boolean externalID2 {get;set;}
        public Boolean externalID3 {get;set;}
        public Boolean externalID4 {get;set;}
        public Boolean fax {get;set;}
        public Boolean faxInternal {get;set;}
        public Boolean graduationSchool {get;set;}
        public Boolean home {get;set;}
        public Boolean institutionSite {get;set;}
        public Boolean isRank {get;set;}
        public Boolean isType {get;set;}
        public Boolean jobTitle {get;set;}
        public Boolean kol {get;set;}
        public Boolean language {get;set;}
        public Boolean mailing {get;set;}
        public Boolean middleName {get;set;}
        public Boolean mobile {get;set;}
        public Boolean noOrders {get;set;}
        public Boolean nsHeadacheTargetCentre {get;set;}
        public Boolean orderType {get;set;}
        public Boolean organizationRegistrationReference {get;set;}
        public Boolean otherName {get;set;}
        public Boolean owner {get;set;}
        public Boolean partnerEmail {get;set;}
        public Boolean partnerEmpCode {get;set;}
        public Boolean partnerRepName {get;set;}
        public Boolean partnerTeamName {get;set;}
        public Boolean patients {get;set;}
        public Boolean phone {get;set;}
        public Boolean phoneInternal {get;set;}
        public Boolean phone2 {get;set;}
        public Boolean positionAtPrimaryInstitution {get;set;}
        public Boolean primaryParentBusinessAccount {get;set;}
        public Boolean privacy {get;set;}
        public Boolean privacyLawStatus {get;set;}
        public Boolean receptionistEmail {get;set;}
        public Boolean receptionistName {get;set;}
        public Boolean salesCreditLimit {get;set;}
        public Boolean shipping {get;set;}
        public Boolean specialty1Check {get;set;}
        public Boolean specialty2Check {get;set;}
        public Boolean targetWhanin {get;set;}
        public Boolean target {get;set;}
        public Boolean website {get;set;}
        public Boolean workplace {get;set;}
        public Boolean email {get;set;}
        public Boolean influentialProfile {get;set;}
        //R008.1
        public Account parAccVal {get;set;}
        public Address_vod__c addrVal {get;set;}
        //end
        public DCR_AGN__c pDCR {get;set;}
        public List<DCR_AGN__c> rCDCR {get;set;}
        public String mdcrId {get;set;}
        public String mdcrName {get;set;}
        public List<Account> accntList {get;set;}
        public list<DCR_AGN__c> addNewCHCO{get; set;}
        public list<DCR_AGN__c> addExistingCHCO{get; set;}
        public List<DCR_AGN__c> addNewCHCP { get; set; }
        public List<DCR_AGN__c> addExistingCHCP { get; set; } 
        public list<Child_Account_vod__c> childac {get; set;}
        public list<Account> parentac {get; set;}
        public Address_vod__c addr {get;set;}
        public String fullAddr {get;set;}
        public List<Selectoption> dcrOptionsList {get; set;}
        public String AGNSpecialty {get;set;}
        public String Specialty1 {get;set;}
        public String AGNIdentifier {get;set;}
        public String physicianRegRef {get;set;}
        public String sapID {get;set;}
        public String distributorID {get;set;}
        public Boolean rbtnExistingHCP {get; set;}
        public Boolean rbtnAddHCP {get; set;}
        public Boolean rbtnExistingHCO {get; set;}
        public Boolean rbtnAddHCO {get; set;}
        public ID chcpId {get; set;}
        public ID chcoId {get; set;}
        public boolean saveCheck {get; set;}
        public boolean sectionCheck {get; set;}
        public Account acc{get;set;}
        public Account accSubmit{get;set;}
        public id nPa;
         public string checkCountry;
        public Integer NewhcpRowToRemove { get; set; }
        public Integer ExCHCPRowToRemove { get; set; }
        public Integer ExCHCORowToRemove { get; set; }
        public Integer NewCHCORowToRemove { get; set; }
        public String newAffiliatedAccountId {get; set;}
        public String parDCRurl {get; set;}
        public Boolean cprodmetrshow {get; set;}
        public Integer chkAccMatchHCP;
        public Integer chkAccMatchHCO;
        Public List <SelectOption> picklistValuesToShow{get; set;}

       //end
       Map <string,string> dcrRTMap = new Map <string,string>(); // to get rt id
       Map <string,string> dcrRTMapByName = new Map <string,string>(); // to get rt name
        //R008
        public AffiliationWrapper otherAff {get;set;}
        public List<AffiliationWrapper> WrapperList{get;set;}
        
        //R008.1 - Apurba -09/09/2016
        public w_AffiliationWrapper w_otherAff {get;set;}
        public List<w_AffiliationWrapper> w_WrapperList{get;set;}
        
        public boolean isClusterUser {get; set;}
     
        Public List<SelectOption> AccountSubtypePicklistValuesToShow {get; set;}
        public Boolean showCustomPicklistValues { 
            get { 
                List <DCR_Picklist_Values_AGN__c> custPickVal_AccountSubtype_List = DCR_Picklist_Values_AGN__c.getAll().values();
                for(DCR_Picklist_Values_AGN__c csPickVal : custPickVal_AccountSubtype_List) {
                    if(csPickVal.Country_Code_AGN__c == loggedInUser.Country_Code__c)
                    return true;
                }
                return false;
            } 
            set; }
        
        public List<SelectOption> getRoles(){
            List<SelectOption> pickValuesDCR = new List<SelectOption>();

            Schema.DescribeFieldResult fieldGetDescribe = DCR_AGN__c.Role_AGN__c.getDescribe();
            List<Schema.PicklistEntry> pickValuesSource = fieldGetDescribe.getPicklistValues();

            pickValuesDCR.add(new SelectOption('', '--None--'));
            for(Schema.PicklistEntry pickSrc : pickValuesSource)
            {
                pickValuesDCR.add(new SelectOption(pickSrc.getValue(),pickSrc.getLabel()));
            }       
            return pickValuesDCR;
        }
        
        public List<SelectOption> getWorkStatus(){
            List<SelectOption> pickValuesDCR = new List<SelectOption>();

            Schema.DescribeFieldResult fieldGetDescribe = DCR_AGN__c.Work_Status_AGN__c.getDescribe();
            List<Schema.PicklistEntry> pickValuesSource = fieldGetDescribe.getPicklistValues();

            pickValuesDCR.add(new SelectOption('', '--None--'));
            for(Schema.PicklistEntry pickSrc : pickValuesSource)
            {
                 pickValuesDCR.add(new SelectOption(pickSrc.getValue(),pickSrc.getLabel()));
            }       
            return pickValuesDCR;
        }
        
        public String affiliatedAccountId {get; set;}
        //Affiliation
        public List<SelectOption> affiliatedAccounts {
            get {
                List<SelectOption> affiliatedAccounts = new List<SelectOption>();
               
                if(cr.Contact_AGN__c != null) {
                    String qry = 'SELECT Primary_Parent_vod__c FROM Account WHERE Id = \'' + cr.Contact_AGN__c + '\'';
                    Account pacc = database.query(qry);
                   
                    List<Account> pacclist = [SELECT Id, Name FROM Account WHERE Id = :pacc.Primary_Parent_vod__c];
                    for (Account x : pacclist)
                        affiliatedAccounts.add(new SelectOption(x.Id, x.Name));
                    List<Account> acclist = [SELECT Id, Name FROM Account WHERE Id IN
                                             (SELECT Parent_Account_vod__c FROM Child_Account_vod__c WHERE Child_Account_vod__c = :cr.Contact_AGN__c
                                              AND Primary_vod__c = :System.Label.Common_No_vod)
                                             ORDER BY Name];
                    for (Account x : acclist)
                        affiliatedAccounts.add(new SelectOption(x.Id, x.Name));
                    affiliatedAccounts.add(new SelectOption('other', 'Other'));
                }
                return affiliatedAccounts;
            }
        }    
        public String associatedAddressId {get; set;}
        public List<SelectOption> associatedAddress {
            get {
                List<SelectOption> associatedAddress = new List<SelectOption>();
               
                List<Address_vod__c> addressList = new List<Address_vod__c>();
                
                if(cr.Account_AGN__c != null){
                    addressList = [SELECT Id, Name, City_vod__c, Country_vod__c, Zip_vod__c FROM Address_vod__c 
                                   WHERE Account_vod__c = :cr.Account_AGN__c 
                                   ORDER BY Name];
                }else{
                    if(affiliatedAccountId != null){
                        addressList = [SELECT Id, Name, City_vod__c, Country_vod__c, Zip_vod__c FROM Address_vod__c 
                                       WHERE Account_vod__c = :affiliatedAccountId
                                       ORDER BY Name];
                    }else{
                        addressList = null;
                    }
                }   
                
                string fullAddress = '';
               
                if(addressList != null){
                    for (Address_vod__c addr : addressList){
                        fullAddress = addr.Name + ', ' + addr.City_vod__c + ', '+ addr.Country_vod__c + ', ' + addr.Zip_vod__c;
                        associatedAddress.add(new SelectOption(addr.Id, fullAddress));               
                    }  
                    
                    if (isBusinessAccount)
                        associatedAddress.add(new SelectOption('other', 'Other'));
                   
                }            
                return associatedAddress;
            }
        }
         
        public List<DCRProductMetricsWrapper> dcrProdMetrWrappers {get; set;}
        public List<DCR_Product_Metrics_AGN__c> selectedDCRProductMetricsList = new List<DCR_Product_Metrics_AGN__c>();
        public List<Product_Metrics_vod__c> curProductMetrics = new List<Product_Metrics_vod__c>();
        public List<DCR_Product_Metrics_AGN__c> curDCRProductMetrics = new List<DCR_Product_Metrics_AGN__c>();
        public DCR_Product_Metrics_AGN__c pmRemove = new DCR_Product_Metrics_AGN__c();
        public List<String> productsForRemoveList = new List<String>();
        public List<DCR_Product_Metrics_AGN__c> productMetricsRemoveList = new List<DCR_Product_Metrics_AGN__c>();
        public static List<Product_Group_vod__c> productGroupList = new List<Product_Group_vod__c>([SELECT Product_vod__c,Product_Catalog_vod__c,Product_Catalog_vod__r.Name FROM Product_Group_vod__c]);
        


        //function start poc ajay--
        //query for Account Details
        
        public void addExistingHCP(){
          if(rbtnExistingHCP == true && addExistingCHCP.size()==0){
                DCR_AGN__c newObject = new DCR_AGN__c();
                addExistingCHCP.add(newObject);
                system.debug('inside add button logic size of addExistingCHCP'+addExistingCHCP.size());
             }
        }
        public void addNewHCP(){
        cprodmetrshow=true;
            if(rbtnAddHCP == true && addNewCHCP.size()==0){
                DCR_AGN__c newObject = new DCR_AGN__c();
                //newObject.RecordTypeId = dcrRTMap.get('HCP_Insert_Company_Managed');
                if (dcrRecordType.contains('Company'))
                 newObject.RecordTypeId = dcrRTMap.get('HCP_Insert_Company_Managed');
                else
                   newObject.RecordTypeId= dcrRTMap.get('HCP_Insert_Data_Provider_Managed');
                 addNewCHCP.add(newObject);
            }
        }
        public void addExistingHCO(){
            if(rbtnExistingHCO == true && addExistingCHCO.size()==0){
               DCR_AGN__c newObject = new DCR_AGN__c();
                addExistingCHCO.add(newObject);
            }
        }
         public void addNewHCO(){
             if(rbtnAddHCO == true && addNewCHCO.size()==0){
                DCR_AGN__c newObject = new DCR_AGN__c(); 
                //newObject.RecordTypeId = dcrRTMap.get('HCO_Insert_Company_Managed');
                if (dcrRecordType.contains('Company'))
                   newObject.RecordTypeId = dcrRTMap.get('HCO_Insert_Company_Managed');
                else
                    newObject.RecordTypeId = dcrRTMap.get('HCO_Insert_Data_Provider_Managed');
                addNewCHCO.add(newObject);
            }
        }
        public void mExistingHCP(){
            if(rbtnExistingHCP == true)
                    addExistingCHCP.remove(ExCHCPRowToRemove);
           }
         public void mAddHCP(){
         cprodmetrshow=false;
             if(rbtnAddHCP == true)
                addNewCHCP.remove(NewhcpRowToRemove);
         }
        
         public void mExistingHCO(){
             if(rbtnExistingHCO == true)
                 addExistingCHCO.remove(ExCHCORowToRemove);
         }
        
         public void mAddHCO(){
             if(rbtnAddHCO == true)  
                addNewCHCO.remove(NewCHCORowToRemove);
         }
        
        public void updateData() 
    {
        if(selectedValue == 'ExHCP') 
        {
            rbtnExistingHCP = true;
            rbtnAddHCP=false;
            rbtnExistingHCO=false;
            rbtnAddHCO=false;
            if(addNewCHCP.size() == 0)
                rbtnAddHCP = false;
            if(addNewCHCP.size() > 0)   
                addNewCHCP.remove(0);
            if(addNewCHCO.size() == 0)
                rbtnAddHCO = false;
            if(addNewCHCO.size() > 0)   
                addNewCHCO.remove(0);
            if(addExistingCHCO.size() == 0)
                rbtnExistingHCO = false;
            if(addExistingCHCO.size() > 0)  
                addExistingCHCO.remove(0);
            
        } else if(selectedValue == 'NewHCP') 
        {
            rbtnAddHCP = true;
            rbtnExistingHCP=false;
            rbtnExistingHCO=false;
            rbtnAddHCO=false;
            if(addExistingCHCP.size() == 0) 
                rbtnExistingHCP = false;
            if(addExistingCHCP.size() > 0)  
                addExistingCHCP.remove(0);
            if(addNewCHCO.size() == 0)
                rbtnAddHCO = false;
            if(addNewCHCO.size() > 0)   
                addNewCHCO.remove(0);
            if(addExistingCHCO.size() == 0)
                rbtnExistingHCO = false;
            if(addExistingCHCO.size() > 0)  
                addExistingCHCO.remove(0);
            
        }
        else if(selectedValue == 'ExHCO') 
        {
            rbtnExistingHCO = true;
            rbtnAddHCP=false;
            rbtnExistingHCP=false;
            rbtnAddHCO=false;
            if(addNewCHCO.size() == 0)
                rbtnAddHCO = false;
            if(addNewCHCO.size() > 0)   
                addNewCHCO.remove(0);
            if(addExistingCHCP.size() == 0) 
                rbtnExistingHCP = false;
            if(addExistingCHCP.size() > 0)  
                addExistingCHCP.remove(0);
            if(addNewCHCP.size() == 0)
                rbtnAddHCP = false;
            if(addNewCHCP.size() > 0)   
                addNewCHCP.remove(0);
           
        }
        else if(selectedValue == 'NewHCO') 
        {
            rbtnAddHCO = true;
            rbtnAddHCP=false;
            rbtnExistingHCP=false;
            rbtnExistingHCO=false;
            if(addExistingCHCP.size() == 0) 
                rbtnExistingHCP = false;
            if(addExistingCHCP.size() > 0)  
                addExistingCHCP.remove(0);
            if(addNewCHCP.size() == 0)
                rbtnAddHCP = false;
            if(addNewCHCP.size() > 0)   
                addNewCHCP.remove(0);
            if(addExistingCHCO.size() == 0)
                rbtnExistingHCO = false;
            if(addExistingCHCO.size() > 0)  
                addExistingCHCO.remove(0);
        }
    }
       
        
        
        public void fetchhcp(){
            //system.debug('value of chcpid' + chcpId);
            List<Account> hcpf= ([SELECT FirstName, LastName,Type_AGN__c,Status_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c from Account where id=:chcpId limit 1]);
            list<DCR_AGN__c> hcp1= new list<DCR_AGN__c>(addExistingCHCP);
            
            for(integer k=0; k<hcp1.size();k++){
                if(hcp1[k].Contact_AGN__c==chcpId){
                    hcp1[k].FirstName_AGN__c=hcpf[0].FirstName;
                    hcp1[k].Last_Name_AGN__c=hcpf[0].LastName;
                     hcp1[k].Account_Status_AGN__c=hcpf[0].Status_AGN__c;
                    hcp1[k].Type_AGN__c=hcpf[0].Type_AGN__c;
                    hcp1[k].Specialty_1_AGN__c=hcpf[0].Specialty_1_AGN__c;
                    hcp1[k].Specialty_2_AGN__c=hcpf[0].Specialty_2_AGN__c;
                }
            }
            addExistingCHCP = hcp1;
            system.debug('value of addExistingCHCP is  '+addExistingCHCP);
        }
        
        public void fetchhco(){
            //system.debug('value of chcpid' + chcpId);
            List<Account> hcof= ([SELECT Name,Status_AGN__c,Type_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c from Account where id=:chcoId limit 1]);
            list<DCR_AGN__c> hco1= new list<DCR_AGN__c>(addExistingCHCO);
            for(integer k=0; k<hco1.size();k++){   
                if(hco1[k].Account_AGN__c==chcoId){
                    hco1[k].Account_Name_AGN__c=hcof[0].Name;
                    hco1[k].Account_Status_AGN__c=hcof[0].Status_AGN__c;               
                    hco1[k].Type_AGN__c=hcof[0].Type_AGN__c;
                    hco1[k].Specialty_1_AGN__c=hcof[0].Specialty_1_AGN__c;
                    hco1[k].Specialty_2_AGN__c=hcof[0].Specialty_2_AGN__c;
                }
            }
            addExistingCHCO = hco1;
            system.debug('value of addExistingCHCO line no 1208'+addExistingCHCO);
        }
        
        //end of dcr poc--ajay
        
        public Map <String,wrapTarget> fieldMap = new Map <String,wrapTarget>
        { 
                'Salutation_AGN__c' => New wrapTarget('Salutation_AGN__c','Account','Salutation'),
                'FirstName_AGN__c' => New wrapTarget('FirstName_AGN__c','Account','FirstName'),
                'Last_Name_AGN__c' => New wrapTarget('Last_Name_AGN__c','Account','LastName'),
                'Middle_Name_AGN__c' => New wrapTarget('Middle_Name_AGN__c','Account','Middle_vod__c'),
                'Type_AGN__c' => New wrapTarget('Type_AGN__c','Account','Type_AGN__c'),
                'Privacy_AGN__c' => New wrapTarget('Privacy_AGN__c','Account','Privacy_AGN__c'),
                'Privacy_law_status_AGN__c' => New wrapTarget('Privacy_law_status_AGN__c','Account','Privacy_law_status_AGN__c'),
                'Gender_AGN__c' => New wrapTarget('Gender_AGN__c','Account','Gender_vod__c'),
                'Specialty_1_AGN__c' => New wrapTarget('Specialty_1_AGN__c','Account','Specialty_1_AGN__c'),
                'Education_Speciality_AGN__c' => New wrapTarget('Education_Speciality_AGN__c','Account','Education_Speciality_AGN__c'),
                'Specialty_2_AGN__c' => New wrapTarget('Specialty_2_AGN__c','Account','Specialty_2_AGN__c'),
                'Specialty_Allergan_1_AGN__c' => New wrapTarget('Specialty_Allergan_1_AGN__c','Account','Specialty_Allergan_1_AGN__c'),
                'Sub_Specialty_Allergan_AGN__c' => New wrapTarget('Sub_Specialty_Allergan_AGN__c','Account','Sub_Specialty_Allergan_AGN__c'),
                'Additional_Specialties_AGN__c' => New wrapTarget('Additional_Specialties_AGN__c','Account','Additional_Specialties_AGN__c'),
                'Account_Country_AGN__c' => New wrapTarget('Account_Country_AGN__c','Account_HCO','Country_vod__c'),
                'Email_AGN__c' => New wrapTarget('Email_AGN__c','Account','PersonEmail'),
                'Consent_to_Email_AGN__c' => New wrapTarget('Consent_to_Email_AGN__c','Account','Consent_to_Email_AGN__c'),
                'Fax_AGN__c' => New wrapTarget('Fax_AGN__c','Account','Fax'),
                'Consent_to_Mail_AGN__c' => New wrapTarget('Consent_to_Mail_AGN__c','Account','Consent_to_Mail_AGN__c'),
                'Mobile_AGN__c' => New wrapTarget('Mobile_AGN__c','Account','PersonMobilePhone'),
                'Consent_to_Phone_AGN__c' => New wrapTarget('Consent_to_Phone_AGN__c','Account','Consent_to_Phone_AGN__c'),
                'Workplace_AGN__c' => New wrapTarget('Workplace_AGN__c','Account','Workplace_AGN__c'),
                'KOL_AGN__c' => New wrapTarget('KOL_AGN__c','Account','KOL_vod__c'),
                'Do_not_Phone_Call_AGN__c' => New wrapTarget('Do_not_Phone_Call_AGN__c','Account','Do_not_Phone_Call_AGN__c'),
                'Do_not_send_Fax_AGN__c' => New wrapTarget('Do_not_send_Fax_AGN__c','Account','Do_not_send_Fax_AGN__c'),
                'Do_not_send_Mail_AGN__c' => New wrapTarget('Do_not_send_Mail_AGN__c','Account','Do_not_send_Mail__c'),
                'JobTitle_AGN__c' => New wrapTarget('JobTitle_AGN__c','Account','Other_title_information_AGN__c'),
                'Target_AGN__c' => New wrapTarget('Target_AGN__c','Account','Target__c'),
                'Language_AGN__c' => New wrapTarget('Language_AGN__c','Account','Language_vod__c'),
                'Consent_to_Contact_AGN__c' => New wrapTarget('Consent_to_Contact_AGN__c','Account','Consent_to_Contact_AGN__c'),
                'PersonBirthdate_AGN__c' => New wrapTarget('PersonBirthdate_AGN__c','Account','PersonBirthdate'),
                'Graduation_School_AGN__c' => New wrapTarget('Graduation_School_AGN__c','Account','Graduation_School_AGN__c'),
                'Graduation_Year_AGN__c' => New wrapTarget('Graduation_Year_AGN__c','Account','Graduation_Year_AGN__c'),
                'Phone_Internal_AGN__c' => New wrapTarget('Phone_Internal_AGN__c','Account','Phone_Internal_AGN__c'),
                'Email_Internal_AGN__c' => New wrapTarget('Email_Internal_AGN__c','Account','Email_Internal_AGN__c'),
                'Fax_Internal_AGN__c' => New wrapTarget('Fax_Internal_AGN__c','Account','Fax_Internal_AGN__c'),
                'Calling_Name_AGN__c' => New wrapTarget('Calling_Name_AGN__c','Account','Calling_Name_AGN__c'),
                'Other_Name_AGN__c' => New wrapTarget('Other_Name_AGN__c','Account','Other_Name_AGN__c'),
                'Description_AGN__c' => New wrapTarget('Description_AGN__c','Account','Description'),
                'NS_Headache_Target_Centre_AGN__c' => New wrapTarget('NS_Headache_Target_Centre_AGN__c','Account','NS_Headache_Target_Centre_AGN__c'),
                'No_Orders_AGN__c' => New wrapTarget('No_Orders_AGN__c','Account_HCP','No_Orders_vod__c'),
                'Order_Type_AGN__c' => New wrapTarget('Order_Type_AGN__c','Account','Order_Type_vod__c'),
                'Default_Order_Type_AGN__c' => New wrapTarget('Default_Order_Type_AGN__c','Account','Default_Order_Type_vod__c'),
                'Distribution_ID_AGN__c' => New wrapTarget('Distribution_ID_AGN__c','Account','Distribution_ID_AGN__c'),
                'DCR_External_ID2_AGN__c' => New wrapTarget('DCR_External_ID2_AGN__c','Account','External_ID2_AGN__c'),
                'DCR_External_ID4_AGN__c' => New wrapTarget('DCR_External_ID4_AGN__c','Account','External_ID4_AGN__c'),
                'Physician_Registration_Reference_AGN__c' => New wrapTarget('Physician_Registration_Reference_AGN__c','Account','Physician_Registration_Reference_AGN__c'),
                'Website_AGN__c' => New wrapTarget('Website_AGN__c','Account','Website'),
                'Account_Name_AGN__c' => New wrapTarget('Account_Name_AGN__c','Account_HCO','Name'),
                'Account_Phone_AGN__c' => New wrapTarget('Account_Phone_AGN__c','Account','Phone'),
                'Beds_AGN__c' => New wrapTarget('Beds_AGN__c','Account','Beds__c'),
                'Departments_AGN__c' => New wrapTarget('Departments_AGN__c','Account','Departments__c'),
                'Patients_AGN__c' => New wrapTarget('Patients_AGN__c','Account','Patients_AGN__c'),
                'Account_Group_AGN__c' => New wrapTarget('Account_Group_AGN__c','Account','Account_Group_vod__c'),
                'Institution_Site_AGN__c' => New wrapTarget('Institution_Site_AGN__c','Account','Institution_Site_AGN__c'),
                'Organization_Registration_Reference_AGN__c' => New wrapTarget('Organization_Registration_Reference_AGN__c','Account','Organization_Registration_Reference_AGN__c'),
                'Allergan_Account_Group_AGN__c' => New wrapTarget('Allergan_Account_Group_AGN__c','Account','Account_Group_AGN__c'),
                'Primary_Business_Accnt_AGN__c' => New wrapTarget('Primary_Business_Accnt_AGN__c','Account_HCO','Primary_Parent_vod__c'),
                'Account_Status_AGN__c' => New wrapTarget('Account_Status_AGN__c','Account','Status_AGN__c'),
                'Do_not_Visit_AGN__c' => New wrapTarget('Do_not_Visit_AGN__c','Account','Do_not_Visit_AGN__c'),
               
                'Address_Line_1_AGN__c' => New wrapTarget('Address_Line_1_AGN__c','Address_vod__c','Name'),
                'Address_Line_2_AGN__c' => New wrapTarget('Address_Line_2_AGN__c','Address_vod__c','Address_line_2_vod__c'),
                'City_AGN__c' => New wrapTarget('City_AGN__c','Address_vod__c','City_vod__c'),
                'Address_Type_AGN__c' => New wrapTarget('Address_Type_AGN__c','Address_vod__c','address_type_vod__c'),
                'Zip_AGN__c' => New wrapTarget('Zip_AGN__c','Address_vod__c','Zip_vod__c'),
                'Brick_AGN__c' => New wrapTarget('Brick_AGN__c','Address_vod__c','Brick_vod__c'),
                'Receptionist_Email_AGN__c' => New wrapTarget('Receptionist_Email_AGN__c','Address_vod__c','Receptionist_Email_AGN__c'),
                'Receptionist_Name_AGN__c' => New wrapTarget('Receptionist_Name_AGN__c','Address_vod__c','Receptionist_Name_AGN__c'),
                'Appt_Required_AGN__c' => New wrapTarget('Appt_Required_AGN__c','Address_vod__c','Appt_Required_vod__c'),
                'Mailing_AGN__c' => New wrapTarget('Mailing_AGN__c','Address_vod__c','Mailing_vod__c'),
                'Shipping_AGN__c' => New wrapTarget('Shipping_AGN__c','Address_vod__c','Shipping_vod__c'),
                'Billing_AGN__c' => New wrapTarget('Billing_AGN__c','Address_vod__c','Billing_vod__c'),
                'Home_AGN__c' => New wrapTarget('Home_AGN__c','Address_vod__c','Home_vod__c'),
                'Business_AGN__c' => New wrapTarget('Business_AGN__c','Address_vod__c','Business_vod__c'),
                'Phone_AGN__c' => New wrapTarget('Phone_AGN__c','Address_vod__c','Phone_vod__c'),
                'Address_Fax_AGN__c' => New wrapTarget('Address_Fax_AGN__c','Address_vod__c','Fax_vod__c'),
                'Phone_2_AGN__c' => New wrapTarget('Phone_2_AGN__c','Address_vod__c','Phone_2_vod__c'),
                'Country_AGN__c' => New wrapTarget('Country_AGN__c','Address_vod__c','Country_vod__c'),
                'Country_Code_AGN__c' => New wrapTarget('Country_Code_AGN__c','Address_vod__c','Country_Code__c'),
                'Address_Line_3_AGN__c' => New wrapTarget('Address_Line_3_AGN__c','Address_vod__c','Address_Line_3_AGN__c'),
                'State_AGN__c' => New wrapTarget('State_AGN__c','Address_vod__c','State_vod__c'),
               
                'Role_AGN__c' => New wrapTarget('Role_AGN__c','Child_Account_vod__c','OK_Role__c'),
                'Work_Status_AGN__c' => New wrapTarget('Work_Status_AGN__c','Child_Account_vod__c','Work_Status_AGN__c')
                };
        public List<Account> oACC {get; set;}                     // {oACC: ACCOUNT}
        public List<Address_vod__c> oADR {get; set;}              // {oADR: ADDRESS}
        public List<Child_Account_vod__c> oMEMB {get; set;}       // {oCHL: MEMBERSHIP}
        public Address_vod__c oADR_PR {get; set;}                 // {oADR: PRIMARY ADDRESS}
        public String ChangeString {get; set;}
       
        public AGN_DCR_Controller (ApexPages.StandardController stdController) {
              
            for (RecordType rt : [select id,Name from RecordType where sobjectType = 'DCR_AGN__c'])
            {
                dcrRTMap.put(rt.Name,rt.Id);
                dcrRTMapByName.put(rt.Id,rt.Name);
            }
            
            //section wise render flag
            rbtnExistingHCP = false;
            rbtnAddHCP = false;
            rbtnExistingHCO = false;
            rbtnAddHCO = false;
            cprodmetrshow= false;
            dcrOptionsList = new List<SelectOption>{
                new Selectoption ('ExHCP', System.Label.DCRChild_Option_Existing_Person_Account),
                new Selectoption ('NewHCP', System.Label.DCRChild_Option_AddNew_Person_Account),
                new Selectoption ('ExHCO', System.Label.DCRChild_Option_Existing_Business_Account),
                new Selectoption ('NewHCO', System.Label.DCRChild_Option_AddNew_Business_Account)}; 
                    
            addExistingCHCP = new List<DCR_AGN__c>();
            addNewCHCP = new List<DCR_AGN__c>();
            addNewCHCO = new List<DCR_AGN__c>();
            addExistingCHCO = new List<DCR_AGN__c>();
            
            system.debug('===== [AGN_DCR_Controller] =====');
            //R007
            stdController.addFields(new String[]{
                'Request_Status_AGN__c',
                 'CreatedById'
            }); 
            retUrlParam = ApexPages.currentPage().getParameters().get('returnUrl');
            //R008 - 1026
            loggedInUser = [select Id, Name, ProfileId, ManagerId, DCR_Self_Approved__c, Country_Code__c, MA_Medical_Affairs_AGN__c,
                            DCR_Approver_AGN__c, Cluster_user_AGN__c, Division
                            FROM User WHERE Id = :UserInfo.getUserId() Limit 1];
            isMslUser = (loggedInUser.MA_Medical_Affairs_AGN__c == 'Yes');
            //R008 - 1026
            isClusterUser = loggedInUser.Cluster_user_AGN__c;
            string loggedInUserProfileName = [select Name from Profile where Id = :loggedInUser.ProfileId].Name;
            //R008 BU Add
            string userBU = loggedInUser.Division == null ? 'ZZ': loggedInUser.Division;
            
            for(DCR_Configuration_Settings_AGN__c dcs: [select Id,Manager_Approved_AGN__c,Local_Admin_Approved_AGN__c,
                                    Local_Approver_AGN__c,Business_Unit_AGN__c,External_Id_AGN__c
                                    FROM DCR_Configuration_Settings_AGN__c
                                    WHERE Country_Code_AGN__c = :loggedInUser.Country_Code__c 
                                    AND Profile_AGN__c = :loggedInUserProfileName]) 
            {
                configSettingsMap.put(dcs.External_Id_AGN__c,dcs);
            }
            
            
            /*
            configSettings = [select Manager_Approved_AGN__c,Local_Admin_Approved_AGN__c,Local_Approver_AGN__c,Business_Unit_AGN__c
                              from DCR_Configuration_Settings_AGN__c
                              where Country_Code_AGN__c = :loggedInUser.Country_Code__c AND Profile_AGN__c = :loggedInUserProfileName
                              AND Business_Unit_AGN__c =:userBU];
                              */
           
            //DCR fields mandatory abhisek
            DCR_Mandatory_Fields_AGN__c cs = DCR_Mandatory_Fields_AGN__c.getOrgDefaults();        
            if(cs.Account_Phone_AGN__c.contains(loggedInUser.Country_Code__c))
                Account_Phone = True;
            if(cs.Address_Line_3_AGN__c.contains(loggedInUser.Country_Code__c))
                Address_line_3 = True;
            if(cs.Birthdate_AGN__c.contains(loggedInUser.Country_Code__c))
                Birthdate = True;
            if(cs.Brick_AGN__c.contains(loggedInUser.Country_Code__c))
                Brick = True;
            if(cs.City_AGN__c.contains(loggedInUser.Country_Code__c))
                City = True;
            if(cs.Education_Speciality_AGN__c.contains(loggedInUser.Country_Code__c))
                Education_Speciality = True;
            if(cs.FirstName_AGN__c.contains(loggedInUser.Country_Code__c))
                FirstName = True;
            if(cs.Gender_AGN__c.contains(loggedInUser.Country_Code__c))
                Gender = True;
            if(cs.Graduation_Year_AGN__c.contains(loggedInUser.Country_Code__c))
                Graduation_Year = True;
            if(cs.Last_Name_AGN__c.contains(loggedInUser.Country_Code__c))
                Last_Name = True;
            if(cs.Physician_Registration_Reference_AGN__c.contains(loggedInUser.Country_Code__c))
                Physician_Registration_Reference = True;
            if(cs.Salutation_AGN__c.contains(loggedInUser.Country_Code__c))
                Salutation = True;
            if(cs.State_AGN__c.contains(loggedInUser.Country_Code__c))
                State = True;
            if(cs.Postal_Code_AGN__c.contains(loggedInUser.Country_Code__c))
                Postal_Code = False;
            else
                Postal_Code = True;
           if(cs.Beds_AGN__c.contains(loggedInUser.Country_Code__c))
                beds = True;
            if(cs.Departments_AGN__c.contains(loggedInUser.Country_Code__c))
                departments = True;
            if(cs.Account_Group_AGN__c.contains(loggedInUser.Country_Code__c))
                accountGroup = True;
            if(cs.Allergan_Account_Group_AGN__c.contains(loggedInUser.Country_Code__c))
                allerganAccountGroup = True;
            if(cs.Type_AGN__c.contains(loggedInUser.Country_Code__c))
                accountSubType= True;
            if(cs.Additional_Specialties_AGN__c.contains(loggedInUser.Country_Code__c))
                additionalSpecialties = True;
            if(cs.Address_Whanin_AGN__c.contains(loggedInUser.Country_Code__c))
                addressWhanin = True;
            if(cs.Address_Line_2_AGN__c.contains(loggedInUser.Country_Code__c))
                addressLine2 = True;
            if(cs.Address_Type_AGN__c.contains(loggedInUser.Country_Code__c))
                addressType = True;
            if(cs.Specialty_Allergan_1_AGN__c.contains(loggedInUser.Country_Code__c))
                agnSpecialtyCheck = True;
            if(cs.Sub_Specialty_Allergan_AGN__c.contains(loggedInUser.Country_Code__c))
                agnSubSpecialty = True;
            if(cs.Appt_Required_AGN__c.contains(loggedInUser.Country_Code__c))
                apptRequired = True;
            if(cs.Avocis_date_AGN__c.contains(loggedInUser.Country_Code__c))
                avocisDate = True;
            if(cs.Avocis_placed_AGN__c.contains(loggedInUser.Country_Code__c))
                avocisPlaced = True;
            if(cs.Billing_AGN__c.contains(loggedInUser.Country_Code__c))
                billing = True;
            if(cs.Business_AGN__c.contains(loggedInUser.Country_Code__c))
                business = True;
            if(cs.Calling_Name_AGN__c.contains(loggedInUser.Country_Code__c))
                callingName = True;
            if(cs.Consent_to_Contact_AGN__c.contains(loggedInUser.Country_Code__c))
                consentToContact = True;
            if(cs.Consent_to_Email_AGN__c.contains(loggedInUser.Country_Code__c))
                consentToEmail = True;
            if(cs.Consent_to_Mail_AGN__c.contains(loggedInUser.Country_Code__c))
                consentToMail = True;
            if(cs.Consent_to_Phone_AGN__c.contains(loggedInUser.Country_Code__c))
                consentToPhone = True;
            if(cs.Country_AGN__c.contains(loggedInUser.Country_Code__c))
                country = True;
            if(cs.Customer_Consent_AGN__c.contains(loggedInUser.Country_Code__c))
                customerConsent = True;
            if(cs.Default_Order_Type_AGN__c.contains(loggedInUser.Country_Code__c))
                defaultOrderType = True;
            if(cs.Description_AGN__c.contains(loggedInUser.Country_Code__c))
                description = True;
            if(cs.Distribution_ID_AGN__c.contains(loggedInUser.Country_Code__c))
                distributionID = True;
            if(cs.Do_not_Phone_Call_AGN__c.contains(loggedInUser.Country_Code__c))
                doNotPhoneCall = True;
            if(cs.Do_not_send_Fax_AGN__c.contains(loggedInUser.Country_Code__c))
                doNotSendFax = True;
            if(cs.Do_not_Send_Mail_AGN__c.contains(loggedInUser.Country_Code__c))
                doNotSendMail = True;
            if(cs.Do_not_Visit_AGN__c.contains(loggedInUser.Country_Code__c))
                doNotVisit = True;
            if(cs.Email_Internal_AGN__c.contains(loggedInUser.Country_Code__c))
                emailInternal = True;
            if(cs.DCR_External_ID_AGN__c.contains(loggedInUser.Country_Code__c))
                externalID = True;
            if(cs.DCR_External_ID1_AGN__c.contains(loggedInUser.Country_Code__c))
                externalID1 = True;
            if(cs.DCR_External_ID2_AGN__c.contains(loggedInUser.Country_Code__c))
                externalID2 = True;
            if(cs.DCR_External_ID4_AGN__c.contains(loggedInUser.Country_Code__c))
                externalID4 = True;
            if(cs.Fax_AGN__c.contains(loggedInUser.Country_Code__c))
                fax = True;
            if(cs.Fax_Internal_AGN__c.contains(loggedInUser.Country_Code__c))
                faxInternal = True;
            if(cs.Graduation_School_AGN__c.contains(loggedInUser.Country_Code__c))
                graduationSchool = True;
            if(cs.Home_AGN__c.contains(loggedInUser.Country_Code__c))
                home = True;
            if(cs.Institution_Site_AGN__c.contains(loggedInUser.Country_Code__c))
                institutionSite = True;
            if(cs.IS_Rank_AGN__c.contains(loggedInUser.Country_Code__c))
                isRank = True;
            if(cs.IS_Type_AGN__c.contains(loggedInUser.Country_Code__c))
                isType = True;
            if(cs.JobTitle_AGN__c.contains(loggedInUser.Country_Code__c))
                jobTitle = True;
            if(cs.KOL_AGN__c.contains(loggedInUser.Country_Code__c))
                kol = True;
            if(cs.Language_AGN__c.contains(loggedInUser.Country_Code__c))
                language = True;
            if(cs.Mailing_AGN__c.contains(loggedInUser.Country_Code__c))
                mailing = True;
            if(cs.Middle_Name_AGN__c.contains(loggedInUser.Country_Code__c))
                middleName = True;
            if(cs.Mobile_AGN__c.contains(loggedInUser.Country_Code__c))
                mobile = True;
            if(cs.No_Orders_AGN__c.contains(loggedInUser.Country_Code__c))
                noOrders = True;
            if(cs.NS_Headache_Target_Centre_AGN__c.contains(loggedInUser.Country_Code__c))
                nsHeadacheTargetCentre = True;
            if(cs.Order_Type_AGN__c.contains(loggedInUser.Country_Code__c))
                orderType = True;
            if(cs.Organization_Registration_Reference_AGN__c.contains(loggedInUser.Country_Code__c))
                organizationRegistrationReference = True;
            if(cs.Other_Name_AGN__c.contains(loggedInUser.Country_Code__c))
                otherName = True;
            if(cs.Owner_AGN__c.contains(loggedInUser.Country_Code__c))
                owner = True;
            if(cs.Partner_Email_AGN__c.contains(loggedInUser.Country_Code__c))
                partnerEmail = True;
            if(cs.Partner_Emp_Code_AGN__c.contains(loggedInUser.Country_Code__c))
                partnerEmpCode = True;
            if(cs.Partner_Rep_Name_AGN__c.contains(loggedInUser.Country_Code__c))
                partnerRepName = True;
            if(cs.Partner_Team_Name_AGN__c.contains(loggedInUser.Country_Code__c))
                partnerTeamName = True;
            if(cs.Patients_AGN__c.contains(loggedInUser.Country_Code__c))
                patients = True;
            if(cs.Phone_AGN__c.contains(loggedInUser.Country_Code__c))
                phone = True;
            if(cs.Phone_Internal_AGN__c.contains(loggedInUser.Country_Code__c))
                phoneInternal = True;
            if(cs.Phone_2_AGN__c.contains(loggedInUser.Country_Code__c))
                phone2 = True;
            if(cs.Position_at_Primary_Institution_AGN__c.contains(loggedInUser.Country_Code__c))
                positionAtPrimaryInstitution = True;
            if(cs.Primary_Parent_Business_Account_AGN__c.contains(loggedInUser.Country_Code__c))
                primaryParentBusinessAccount = True;
            if(cs.Privacy_AGN__c.contains(loggedInUser.Country_Code__c))
                privacy = True;
            if(cs.Privacy_law_status_AGN__c.contains(loggedInUser.Country_Code__c))
                privacyLawStatus = True;
            if(cs.Receptionist_Email_AGN__c.contains(loggedInUser.Country_Code__c))
                receptionistEmail = True;
            if(cs.Receptionist_Name_AGN__c.contains(loggedInUser.Country_Code__c))
                receptionistName = True;
            if(cs.Sales_Credit_Limit_AGN__c.contains(loggedInUser.Country_Code__c))
                salesCreditLimit = True;
            if(cs.Shipping_AGN__c.contains(loggedInUser.Country_Code__c))
                shipping = True;
            if(cs.Specialty_1_AGN__c.contains(loggedInUser.Country_Code__c))
                specialty1Check = True;
            if(cs.Specialty_2_AGN__c.contains(loggedInUser.Country_Code__c))
                specialty2Check = True;
            if(cs.Target_Whanin_AGN__c.contains(loggedInUser.Country_Code__c))
                targetWhanin = True;
            if(cs.Target_AGN__c.contains(loggedInUser.Country_Code__c))
                target = True;
            if(cs.Website_AGN__c.contains(loggedInUser.Country_Code__c))
                website = True;
            if(cs.Workplace_AGN__c.contains(loggedInUser.Country_Code__c))
                workplace = True;
            if(cs.Email_AGN__c.contains(loggedInUser.Country_Code__c))
                email = True;
            if(cs.Influential_Profile_AGN__c.contains(loggedInUser.Country_Code__c))
                influentialProfile = True;
            //end
            
            //Country Code Append to AGN Identifier
            Country_Code_Append_to_AGN_Identifier__c cc = Country_Code_Append_to_AGN_Identifier__c.getOrgDefaults();
              checkCountry = cc.AGN_Identifier_AGN__c;
            //end
            
            cr = (DCR_AGN__c)stdController.getRecord();
            system.debug('===== [AGN_DCR_Controller] CR ==>>' + cr);
            dcrId = cr.Id;
           
            
            // Product Metrics Section Data
            dcrProdMetrWrappers = new List<DCRProductMetricsWrapper>();
            cdcrProdMetrWrappers = new List<DCRProductMetricsWrapper>();
            //R007 - Apurba
            List<Product_vod__c> userProduct;
            if (cr.Request_Status_AGN__c == Processing || dcrId == null ) {
                userProduct = [SELECT Id,Name FROM Product_vod__c WHERE Id IN (SELECT Product_vod__c FROM My_Setup_Products_vod__c
                                                                               WHERE Product_vod__r.Product_Type_vod__c IN ('Detail') AND OwnerId = :loggedInUser.Id)];
            }
           
            else {
                userProduct = [SELECT Id,Name FROM Product_vod__c WHERE Id IN (SELECT Product_vod__c FROM My_Setup_Products_vod__c
                                                                               WHERE Product_vod__r.Product_Type_vod__c IN ('Detail') AND OwnerId = :cr.createdById)];
            }
            
            for (Product_vod__c userProd: userProduct) {
                dcrProdMetrWrappers.add(new DCRProductMetricsWrapper(userProd));
            }
           
            for (Product_vod__c userProd: userProduct) {
                cdcrProdMetrWrappers.add(new DCRProductMetricsWrapper(userProd));
            }
            
            // Load Custom Picklist Items in Account Subtype
            List <DCR_Picklist_Values_AGN__c> custPickVal_AccountSubtype_List = DCR_Picklist_Values_AGN__c.getAll().values();
            AccountSubtypePicklistValuesToShow = setCustomPicklistItems(custPickVal_AccountSubtype_List,loggedInUser.Country_Code__c);
            
            if(dcrId == null || (retUrlParam != null && retUrlParam.contains('DCRTypeAndActionSelectionAGN'))){
                system.debug('===== [AGN_DCR_Controller][dcrId = null....] =====');
                accountTypeParam = ApexPages.currentPage().getParameters().get('accntType');
                actionTypeParam = ApexPages.currentPage().getParameters().get('actionType');
                approvalTypeParam = ApexPages.currentPage().getParameters().get('approvalType');
                immediateTerritoryAlignmentParam = (ApexPages.currentPage().getParameters().get('ita') == 'TRUE') ? True : False;
                provisionalContactParam = (ApexPages.currentPage().getParameters().get('provisionalContact') == 'TRUE') ? True : False;                   
                showProdMetrParam = (ApexPages.currentPage().getParameters().get('showProdMetr') == 'TRUE') ? True : False;
                recType = ApexPages.currentPage().getParameters().get('rtId');
                territoryAlignmentAfterApprovalParam = (ApexPages.currentPage().getParameters().get('taaf') == 'TRUE') ? True : False;
                dcrRecordType = [select Name from RecordType where Id = :Id.valueOf(recType)].Name;
     
                if(([select name from RecordType where id =:recType].Name).contains('Company'))
                    cr.Consent_to_Contact_AGN__c = true;
                
                if (rectype != null) {         
                    cr.RecordTypeId = Id.valueOf(recType);
                    dcrRecordType = [select Name from RecordType where Id = :cr.RecordTypeId].Name;
                    cr.Request_Status_AGN__c = Processing;
                    cr.Request_Entity_AGN__c = accountTypeParam;
                    cr.Request_Type_AGN__c = actionTypeParam;
                    cr.Country_Code_AGN__c = loggedInUser.Country_Code__c;
                    cr.Provisional_Contact_AGN__c = provisionalContactParam;
                    cr.Has_Product_Metrics__c = showProdMetrParam;
                    cr.TAAF_AGN__c = territoryAlignmentAfterApprovalParam;

                    //============
                    //R008.1 : DCR Approver
                    //=============
                    if ((dcrRecordType == 'HCO_Insert_Company_Managed' || dcrRecordType == 'HCO_Update_Company_Managed' ||
                         dcrRecordType == 'HCP_Insert_Company_Managed' || dcrRecordType == 'HCP_Update_Company_Managed'))
                    {
                        cr.Auto_Approved_AGN__c = loggedInUser.DCR_Self_Approved__c;
                        String loggedInUserKeyWithBU = loggedInUser.Country_Code__c + '_' +userBU + '_' + loggedInUserProfileName;
                        String loggedInUserKeyWithOutBU  = loggedInUser.Country_Code__c + '_' +'ZZ' + '_' + loggedInUserProfileName;
                        //Loop over config settings.
                        for (String dcrsetting : configSettingsMap.keySet())
                        {
                            if(configSettingsMap.containsKey(loggedInUserKeyWithBU)) // BU match found 
                            {
                                system.debug('4========BU match=========');
                                if (cr.Auto_Approved_AGN__c == False && configSettingsMap.get(loggedInUserKeyWithBU).Local_Admin_Approved_AGN__c == True){
                                    cr.DCR_Approver_AGN__c = configSettingsMap.get(loggedInUserKeyWithBU).Local_Approver_AGN__c;
                                }
                                if (cr.Auto_Approved_AGN__c == False && configSettingsMap.get(loggedInUserKeyWithBU).Manager_Approved_AGN__c == True)
                                {
                                    cr.DCR_Approver_AGN__c = loggedInUser.ManagerId;
                                }
                                if (cr.Auto_Approved_AGN__c == True &&  (dcrId == null || cr.CreatedById == UserInfo.getUserId()))
                                {
                                    cr.DCR_Approver_AGN__c = UserInfo.getUserId();
                                }
                            }
                            // BU specific Approver setting NOT found in Config Setting . Hence pick up the one with ZZ
                            else if (configSettingsMap.containsKey(loggedInUserKeyWithOutBU))
                            {
                                system.debug('5========BU dont match=========');
                                if (cr.Auto_Approved_AGN__c == False && configSettingsMap.get(loggedInUserKeyWithOutBU).Local_Admin_Approved_AGN__c == True){
                                    cr.DCR_Approver_AGN__c = configSettingsMap.get(loggedInUserKeyWithOutBU).Local_Approver_AGN__c;
                                }
                                if (cr.Auto_Approved_AGN__c == False && configSettingsMap.get(loggedInUserKeyWithOutBU).Manager_Approved_AGN__c == True)
                                {
                                    cr.DCR_Approver_AGN__c = loggedInUser.ManagerId;
                                }
                                if (cr.Auto_Approved_AGN__c == True &&  (dcrId == null || cr.CreatedById == UserInfo.getUserId()))
                                {
                                    cr.DCR_Approver_AGN__c = UserInfo.getUserId();
                                }
                            }
                            else
                            {
                                system.debug('===============No DCR Admin settings found==================');
                            }
                        }
                    }
                    else
                    {
                        cr.Auto_Approved_AGN__c = false;
                    }
                }
                
             //Set Account-subtype default value
            if(isPersonAccount && (dcrRecordType == 'HCP_Insert_Data_Provider_Managed' || dcrRecordType == 'HCP_Insert_Company_Managed'))
            {
                cr.Account_Type_AGN__c = 'Professional_vod';
                 typeControl();
            }
            else if(isBusinessAccount && (dcrRecordType == 'HCO_Insert_Company_Managed' || dcrRecordType == 'HCO_Insert_Data_Provider_Managed'))
            {
                cr.Account_Type_AGN__c = 'Hospital_vod';
                 typeControl();
            }   

                //Manager_Approved_AGN__c
                viewReadOnly = false;
                viewReadWrite = true;
                createdByName = '';
                showDelAffiliation = 0;
                
            }
            if(dcrId != null){            
                system.debug('===== [AGN_DCR_Controller][dcrId != null] =====');
                      //R008 Requirement# 918 : Added field 
                cr = [SELECT Account_AGN__c,Account_Name_AGN__c,Account_Phone_AGN__c,Account_Type_AGN__c,Address_AGN__c,Address_Fax_AGN__c,
                      Address_Line_1_AGN__c,Address_Line_2_AGN__c,Address_Status__c,Address_Type_AGN__c,Affiliated_Account_Sub_Type__c,
                      Affiliated_Account_Type_AGN__c,Approved_By_AGN__c,Approver_Comment_AGN__c,Appt_Required_AGN__c,Auto_Approved_AGN__c,
                      Beds_AGN__c,Billing_AGN__c,Brick_AGN__c,Business_AGN__c,City_AGN__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,
                      Consent_to_Phone_AGN__c,Contact_AGN__c,Country_AGN__c,Country_Code_AGN__c,CreatedById,CreatedDate,
                      Delete_Affiliation_AGN__c,Departments_AGN__c,Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,Do_not_send_Mail_AGN__c,
                      Education_Speciality_AGN__c,Email_AGN__c,Fax_AGN__c,FirstName_AGN__c,Gender_AGN__c,Has_Product_Metrics__c,Home_AGN__c,Id,
                      IsDeleted,IsLocked,ITA_AGN__c,JobTitle_AGN__c,KOL_AGN__c,Last_Name_AGN__c,Mailing_AGN__c,MayEdit,Middle_Name_AGN__c,
                      Migrated_to_DP_AGN__c,Mobile_AGN__c,Name,OwnerId,Person_Title_AGN__c,Phone_2_AGN__c,Phone_AGN__c,Primary_Affiliation_AGN__c,
                      Primary_Address_AGN__c,
                      Primary_Business_Accnt_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Provisional_Contact_AGN__c,P_Account_Address_Id__c,
                      P_Business_Account_Id_AGN__c,P_Child_Account_Id_AGN__c,P_Person_Account_Id_AGN__c,Receptionist_Email_AGN__c,
                      Receptionist_Name_AGN__c,RecordTypeId,Requestor_Comment_AGN__c,Request_Entity_AGN__c,Request_Status_AGN__c,
                      Request_Type_AGN__c,Role_AGN__c,Salutation_AGN__c,Shipping_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,
                      Specialty_Allergan_1_AGN__c,Sub_Specialty_Allergan_AGN__c,Additional_Specialties_AGN__c,Type_AGN__c,Website_AGN__c,
                      Workplace_AGN__c,Zip_AGN__c,DCR_Approver_AGN__c ,Account_Status_AGN__c,Do_not_Visit_AGN__c,Target_AGN__c,Language_AGN__c,
                      Consent_to_Contact_AGN__c,PersonBirthdate_AGN__c,Graduation_School_AGN__c,Graduation_Year_AGN__c,Phone_Internal_AGN__c,
                      Email_Internal_AGN__c,Fax_Internal_AGN__c,Calling_Name_AGN__c,Other_Name_AGN__c,Description_AGN__c,Patients_AGN__c,
                      Account_Group_AGN__c,Institution_Site_AGN__c,Work_Status_AGN__c,Address_Line_3_AGN__c,State_AGN__c,
                      NS_Headache_Target_Centre_AGN__c,No_Orders_AGN__c,Order_Type_AGN__c,Default_Order_Type_AGN__c,Account_Country_AGN__c,
                      DCR_External_ID_AGN__c,Distribution_ID_AGN__c,DCR_External_ID2_AGN__c,DCR_External_ID4_AGN__c,Physician_Registration_Reference_AGN__c,
                      Organization_Registration_Reference_AGN__c,Allergan_Account_Group_AGN__c,Influential_profile_AGN__c,Address_Whanin_AGN__c,Avocis_date_AGN__c,
                      Avocis_placed_AGN__c,Customer_Consent_AGN__c,IS_Rank_AGN__c,IS_Type_AGN__c,Owner_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,
                      Partner_Rep_Name_AGN__c,Parent_DCR_ID_AGN__c,Is_Child_DCR_AGN__c,Partner_Team_Name_AGN__c,Position_at_Primary_Institution_AGN__c,Sales_Credit_Limit_AGN__c,
                      Target_Whanin_AGN__c,Error_Log_AGN__c,DCR_Type_AGN__c,DCR_Changes_AGN__c
                      FROM DCR_AGN__c 
                      WHERE Id = :dcrId];
                
                if(cr.Is_Child_DCR_AGN__c==true)
                {
                    pDCRList = [select Auto_Approved_AGN__c,Id,Name from DCR_AGN__c where id=:cr.Parent_DCR_ID_AGN__c];
                    system.debug('value of pDCRList '+pDCRList);
                    cr.Auto_Approved_AGN__c= pDCRList[0].Auto_Approved_AGN__c;
                    mdcrId=pDCRList[0].Id;
                    mdcrName=pDCRList[0].Name;
                    cDCRList = [select Id,Name from DCR_AGN__c where Parent_DCR_ID_AGN__c=:mdcrId and id!=:dcrId];
                }
                //fetching Child DCR Abhisek
                if(cr.Is_Child_DCR_AGN__c==false)
                {
                    cDCRList = [select Id,Name from DCR_AGN__c where Parent_DCR_ID_AGN__c=:dcrId];
                    if(cDCRList.size() == 0)
                       pDCRList = [select Id,Name from DCR_AGN__c where Parent_DCR_ID_AGN__c=:dcrId];
                    
                }
                  if(isPersonAccountChange && cr.Parent_DCR_ID_AGN__c != null)
                {
                    pDCRList = [select Auto_Approved_AGN__c,Id,Name from DCR_AGN__c where id=:cr.Parent_DCR_ID_AGN__c];
                    system.debug('value of pDCRList '+pDCRList);
                    //cr.Auto_Approved_AGN__c= pDCRList[0].Auto_Approved_AGN__c;
                    mdcrId=pDCRList[0].Id;
                    //mdcrName=pDCRList[0].Name;
                    cDCRList = [select Id,Name from DCR_AGN__c where Parent_DCR_ID_AGN__c=:mdcrId and id!=:dcrId];
                }
                if(isPersonAccountChange &&  cr.Parent_DCR_ID_AGN__c == null)
                {
                    cDCRList = [select Id,Name from DCR_AGN__c where Parent_DCR_ID_AGN__c=:dcrId];
                    if(cDCRList.size() == 0 && pDCRList.size() ==0)
                       pDCRList = [select Id,Name from DCR_AGN__c where Parent_DCR_ID_AGN__c=:dcrId];
                }
                //R008.1
                if (cr.Account_AGN__c != null && cr.Is_Child_DCR_AGN__c==false) {
                    //addrVal = [SELECT Id, Name, City_vod__c, State_vod__c, Country_vod__c, Zip_vod__c FROM Address_vod__c WHERE id =: cr.Address_AGN__c];
                    addrVal = [SELECT Id, Name, City_vod__c, State_vod__c, Country_vod__c, Zip_vod__c FROM Address_vod__c WHERE Primary_vod__c=true AND Account_vod__c =: cr.Account_AGN__c];
                    parAccVal = [SELECT Id, Beds__c, Departments__c, Specialty_1_AGN__c, Specialty_Allergan_1_AGN__c FROM Account WHERE id =: cr.Account_AGN__c];
                }
                
                 
                /* query for stamping parent account name
                String pid='';
                List<DCR_AGN__c> pDCRid = new List<DCR_AGN__c>();
                pDCRid = [select Parent_DCR_ID_AGN__c from DCR_AGN__c where id=:dcrId limit 1];
                system.debug('value of pDCRid '+pDCRid);
                
                if(pDCRid[0].Parent_DCR_ID_AGN__c != null)
                {
                    pid=pDCRid[0].Parent_DCR_ID_AGN__c;
                    system.debug('value of pid '+pid);
                    pDCR =[select Account_Name_AGN__c from DCR_AGN__c where id =: pid];
                    system.debug('value of pDCR '+pDCR);
                } */
                 
                 //R008 Requirement# 918 : Added field 
                accountTypeParam = cr.Request_Entity_AGN__c;
                actionTypeParam = cr.Request_Type_AGN__c;
                approvalTypeParam = null;
                immediateTerritoryAlignmentParam = cr.ITA_AGN__c;
                provisionalContactParam = cr.Provisional_Contact_AGN__c;
                recType = string.valueOf(cr.RecordTypeId);
                showProdMetrParam = cr.Has_Product_Metrics__c;
                //R007
                if(cr.Request_Status_AGN__c == Processing || (cr.CreatedById == loggedInUser.Id && cr.Request_Status_AGN__c == 'Send Back for Revision')){
                    viewReadOnly = false;
                    viewReadWrite = true;
                }else{
                    viewReadOnly = true;
                    viewReadWrite = false;
                }
                
                if (cr.Request_Status_AGN__c == 'Send Back for Revision'){
                   enableSubmit = true; 
                }

                //END R007
                if(isPersonAccountChange){
                    affiliatedAccountId = cr.Account_AGN__c;
                    showDelAffiliation = cr.Delete_Affiliation_AGN__c == true? 1 : 0;
                }
                
                if(!isBusinessAccountAdd){
                    associatedAddressId = cr.Address_AGN__c;
                 }
                
                dcrRecordType = [select Name from RecordType where Id = :cr.RecordTypeId].Name;
                
                if(cr.Request_Status_AGN__c == Submitted){
                    if (dcrRecordType == 'HCO_Insert_Company_Managed' || dcrRecordType == 'HCO_Update_Company_Managed' ||
                        dcrRecordType == 'HCP_Insert_Company_Managed' || dcrRecordType == 'HCP_Update_Company_Managed')
                    {
                        if(cr.DCR_Approver_AGN__c == UserInfo.getUserId())
                            showApproveReject = true;
                        else
                        {
                            if(loggedInUser.DCR_Approver_AGN__c == true && cr.Auto_Approved_AGN__c == true)
                                showApproveReject = true;
                            else
                                showApproveReject = false;
                        }
                    }
                    else
                    {
                        showApproveReject = false;
                    }
                }
                if(cr.Request_Status_AGN__c != Submitted){
                    showApproveReject = false;
                }
                if(cr.Request_Status_AGN__c == Accepted  || cr.Request_Status_AGN__c == Rejected){
                    showApproveReject = false;
                    enableSubmit = false;
                }
                
                createdByName = [select Name from User where Id = :cr.CreatedById].Name;
                
                // Fetch Product Metrics data from DCR Product Metrics
                curDCRProductMetrics = [SELECT Id,DCR_AGN__c,Product_AGN__c,Product_Metrics_Reference__c,Detail_Group_AGN__c,Detail_Group_AGN__r.Name,Adoption_AGN__c,Adoption_IMS_AGN__c,Potential_AGN__c,
                                        Potential_IMS_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c,Target_AGN__c,Sector_AGN__c,Fase_AGN__c,Ratings_AGN__c,Advocacy_Profile_AGN__c,Investigator_Readiness_AGN__c,
                                        Customer_Segment_AGN__c,Sales_Target_AGN__c,Investigator_AGN__c,Profiling_AGN__c,Retina_Profile_AGN__c,Product_Status_AGN__c,Growth_Potential_AGN__c,
                                        Awareness_AGN__c,Adoption_Level_AGN__c,Engagements_AGN__c,Account_Support_AGN__c,Fixed_Consignment_AGN__c,Key_Account_AGN__c,Ophthalmology_Profile_AGN__c,
                                        Segment1_AGN__c,Continuum_Placement_AGN__c
                                        FROM DCR_Product_Metrics_AGN__c WHERE DCR_AGN__c = :dcrId];
                for(integer i = 0 ; i < dcrProdMetrWrappers.size() ; i++) {
                    for(DCR_Product_Metrics_AGN__c pm: curDCRProductMetrics) {
                        if(pm.Product_AGN__c == dcrProdMetrWrappers[i].dcrProductMetrics.Product_AGN__c) {
                            dcrProdMetrWrappers[i].dcrProductMetrics = pm;
                            dcrProdMetrWrappers[i].selected = true;
                            break;
                        }
                    }
                }
            } 
            
            if((cr.CreatedById == null) || (cr.CreatedById == loggedInUser.Id && (cr.Request_Status_AGN__c == 'Processing' || cr.Request_Status_AGN__c == 'Send Back for Revision')) || (cr.DCR_Approver_AGN__c == loggedInUser.Id && cr.Request_Status_AGN__c == 'Submitted')) {
                viewReadWritePM = true;
                viewReadOnlyPM = false;
            } else {
                viewReadWritePM = false;
                viewReadOnlyPM = true;
            }
            system.debug('===== [AGN_DCR_Controller] viewReadWritePM ==>>' + viewReadWritePM);
            enableSubmit = cr.Request_Status_AGN__c == Processing ? true : false;        
            
            parDCRurl = System.URL.getSalesforceBaseURL().toExternalForm() + '/' + mdcrId;

         

            /*** Track Changes made in Current DCR ***/
            if(cr.Request_Status_AGN__c == Submitted && cr.Request_Type_AGN__c == 'Change')
                cr.DCR_Changes_AGN__c = detectChanges();
        
            String debugString =
                'dcrId: '+dcrId+
                '   retUrlParam: '+retUrlParam+
                '   accountTypeParam: '+ accountTypeParam+ 
                '   actionTypeParam:'+actionTypeParam+
                '   approvalTypeParam: '+approvalTypeParam+
                '   immediateTerritoryAlignmentParam: '+immediateTerritoryAlignmentParam+
                '   provisionalContactParam'+provisionalContactParam+
                '   rtid :'+recType;
            system.debug('===== [AGN_DCR_Controller] debugString ==>>' + debugString);
            system.debug('===== [AGN_DCR_Controller] PM_RENDER ==>>' + (showProdMetrParam && (approvalTypeParam != 'DataProvider') && (cr.DCR_Type_AGN__c=='Base HCP Affiliation')));
            system.debug('===== [AGN_DCR_Controller] DCR_TYPE ==>>' + cr.DCR_Type_AGN__c);

        }
       
        public string toString(Object o) {
            if(o==null)                             return '';
            else if(o instanceof String)            return (String)o;
            else if(o instanceof Boolean)           return o == true ? 'true' : 'false';
            else if(o instanceof Decimal)           return String.valueOf(o);
            else                                    return String.valueOf(o);        //Other Types: Id,Blob,Date,Datetime,Time,Integer,Long,Double
        }

        //Apurba - R008
        public List<AffiliationWrapper> getAffiliationAccountList()
        {      
            //R008 - Affiliation
            List<Child_Account_vod__c> cAcList;
            Set<ID> pAcId = new  Set<ID>();
            WrapperList= new List<AffiliationWrapper>();
            if(cr.Contact_AGN__c != null) {
                if (cAcList == null){               
                    cAcList = new List<Child_Account_vod__c>();                                                                     
                    for (Child_Account_vod__c cAc :
                         [SELECT Name,OK_Role__c,Parent_Account_vod__c,Work_Status_AGN__c,Parent_Account_vod__r.Beds__c,
                          Parent_Account_vod__r.Name, Child_Account_vod__c,Copy_Address_vod__c,Network_Primary_vod__c,
                          Parent_Account_vod__r.Departments__c,Parent_Account_vod__r.Specialty_1_AGN__r.Name,
                          Parent_Account_vod__r.Specialty_Allergan_1_AGN__r.Name,Child_Account_vod__r.Primary_Parent_vod__c
                          FROM Child_Account_vod__c
                          WHERE Child_Account_vod__c =: cr.Contact_AGN__c])    
                    {
                        cAcList.add(cAc);
                        pAcId.add(cAc.Parent_Account_vod__c);
                    }
                    Map<Id,Address_vod__c> addrMap = new Map<Id,Address_vod__c>();
                    for (Address_vod__c ad:
                         [SELECT Account_vod__c, Name,Address_line_2_vod__c,Address_Line_3_AGN__c,
                          State_vod__c,City_vod__c,Zip_vod__c, Brick_vod__c,Country_vod__c
                          FROM Address_vod__c 
                          WHERE Account_vod__c IN : pAcId
                          AND Primary_vod__c = true])  // filter with child's parent acc
                    {
                        addrMap.put(ad.Account_vod__c,ad);
                    }    
                    for(Child_Account_vod__c ca: cAcList){
                        WrapperList.add(New AffiliationWrapper(ca,addrMap.get(ca.Parent_Account_vod__c)));
                    }
                }
            }
            return WrapperList;
        }

        //R008.1 - Apurba modification on 09/09/2016

        public List<w_AffiliationWrapper> getw_AffiliationAccountList()
        {      
            List<Child_Account_vod__c> cAcList;
            Set<ID> pAcId = new  Set<ID>();
            //Child_Account_vod__c
            String childAccount;
            String parentAccount;
            String parentAccountName;
            String workStatus;
            String okRole;
            String childPrimaryParent;
            //Account
            Decimal beds;
            Decimal department;
            String speciality1;
            String agnSpecialty;
            //Address
            String address;

            w_WrapperList= new List<w_AffiliationWrapper>();
            if(cr.Contact_AGN__c != null) {
                if (cAcList == null){               
                    Address_vod__c addr;
                    cAcList = new List<Child_Account_vod__c>(); 
                    system.debug('0=========before for ========='+cr.Contact_AGN__c);                                                                      
                    Map<Id,Address_vod__c> addrMap = new Map<Id,Address_vod__c>();

                    for (Child_Account_vod__c ca :
                        [SELECT Name,OK_Role__c,Parent_Account_vod__c,Work_Status_AGN__c,Parent_Account_vod__r.Beds__c,
                          Parent_Account_vod__r.Name, Child_Account_vod__c,Copy_Address_vod__c,Network_Primary_vod__c,
                          Parent_Account_vod__r.Departments__c,Parent_Account_vod__r.Specialty_1_AGN__r.Name,
                          Parent_Account_vod__r.Specialty_Allergan_1_AGN__r.Name,Child_Account_vod__r.Primary_Parent_vod__c
                          FROM Child_Account_vod__c
                          WHERE Child_Account_vod__c =: cr.Contact_AGN__c])  
                    {
                        pAcId.add(ca.Parent_Account_vod__c);
                    }
                    for (Address_vod__c ad : [SELECT Account_vod__c, Name,Address_line_2_vod__c,Address_Line_3_AGN__c,
                                          State_vod__c,City_vod__c,Zip_vod__c, Brick_vod__c,Country_vod__c
                                          FROM Address_vod__c 
                                          WHERE Account_vod__c IN : pAcId
                                          AND Primary_vod__c = true])
                    {
                        addrMap.put(ad.Account_vod__c,ad);
                    }

                    for (Child_Account_vod__c cAc :
                         [SELECT Name,OK_Role__c,Parent_Account_vod__c,Work_Status_AGN__c,Parent_Account_vod__r.Beds__c,
                          Parent_Account_vod__r.Name, Child_Account_vod__c,Copy_Address_vod__c,Network_Primary_vod__c,
                          Parent_Account_vod__r.Departments__c,Parent_Account_vod__r.Specialty_1_AGN__r.Name,
                          Parent_Account_vod__r.Specialty_Allergan_1_AGN__r.Name,Child_Account_vod__r.Primary_Parent_vod__c
                          FROM Child_Account_vod__c
                          WHERE Child_Account_vod__c =: cr.Contact_AGN__c])  
                          
                    {
                         system.debug('1=========Inside for getw_AffiliationAccountList========='+cAc);  
                         cAcList.add(cAc);
                         childAccount = cAc.Child_Account_vod__c;
                         parentAccount =cAc.Parent_Account_vod__c;
                         parentAccountName = cAc.Parent_Account_vod__r.Name;
                         workStatus = cAc.Work_Status_AGN__c;
                         okRole = cAc.OK_Role__c;
                         childPrimaryParent = cAc.Child_Account_vod__r.Primary_Parent_vod__c;
                         beds =cAc.Parent_Account_vod__r.Beds__c;
                         department =cAc.Parent_Account_vod__r.Departments__c;
                         speciality1 = cAc.Parent_Account_vod__r.Specialty_1_AGN__r.Name;
                         agnSpecialty = cAc.Parent_Account_vod__r.Specialty_Allergan_1_AGN__r.Name;

                        
                   

                    
                    /*addr = [SELECT Account_vod__c, Name,Address_line_2_vod__c,Address_Line_3_AGN__c,
                                          State_vod__c,City_vod__c,Zip_vod__c, Brick_vod__c,Country_vod__c
                                          FROM Address_vod__c 
                                          WHERE Account_vod__c IN : pAcId
                                          AND Primary_vod__c = true];  // filter with child's parent acc
                    
                    address = addr.Name+ ' '+ (addr.Address_line_2_vod__c == null? '' : addr.Address_line_2_vod__c) + ' ' +
                                                (addr.Address_Line_3_AGN__c == null? '' : addr.Address_Line_3_AGN__c) + ' ' +
                                                (addr.City_vod__c == null ? '' : addr.City_vod__c) + ' ' +
                                                (addr.Zip_vod__c == null ? '' : addr.Zip_vod__c) + ' ' +
                                                (addr.Brick_vod__c == null ? '' : addr.Brick_vod__c) + ' ' +
                                                (addr.State_vod__c == null ? '' : addr.State_vod__c) + ' ' +
                                                (addr.Country_vod__c == null ? '' : addr.Country_vod__c);

                    */

                         address = addrMap.get(parentAccount).Name+ ' '+ 
                                    (addrMap.get(parentAccount).Address_line_2_vod__c == null? '' : addrMap.get(parentAccount).Address_line_2_vod__c) + ' ' +
                                    (addrMap.get(parentAccount).Address_Line_3_AGN__c == null? '' : addrMap.get(parentAccount).Address_Line_3_AGN__c) + ' ' +
                                    (addrMap.get(parentAccount).City_vod__c == null ? '' : addrMap.get(parentAccount).City_vod__c) + ' ' +
                                    (addrMap.get(parentAccount).Zip_vod__c == null ? '' : addrMap.get(parentAccount).Zip_vod__c) + ' ' +
                                    (addrMap.get(parentAccount).Brick_vod__c == null ? '' : addrMap.get(parentAccount).Brick_vod__c) + ' ' +
                                    (addrMap.get(parentAccount).State_vod__c == null ? '' : addrMap.get(parentAccount).State_vod__c) + ' ' +
                                    (addrMap.get(parentAccount).Country_vod__c == null ? '' : addrMap.get(parentAccount).Country_vod__c);

                        w_WrapperList.add(New w_AffiliationWrapper(childAccount,parentAccount,parentAccountName,workStatus,okRole,childPrimaryParent,beds,department,speciality1,agnSpecialty,address));
                    }
                }
                system.debug('4=========inside w_WrapperList ========='+w_WrapperList + '========w_WrapperList.size() ========='+w_WrapperList.size());  
            }
            return w_WrapperList;
        }

        public void selectOtherAccountFromLookup()
        {      
            //R008 - Affiliation
           
            if(isPersonAccountChange){
                Account acc;
                w_otherAff = new w_AffiliationWrapper();
                if(cr.Contact_AGN__c != null && cr.Account_AGN__c != null) {         
                    if (acc == null){                                                                              
                        acc = [SELECT
                               Id, Name, IsPersonAccount,Beds__c,Departments__c,Fax,Specialty_1_AGN__r.Name,
                               Specialty_2_AGN__r.Name,Specialty_Allergan_1_AGN__r.Name
                               FROM Account WHERE Id = :cr.Account_AGN__c];
                        Address_vod__c addr = [SELECT Account_vod__c, Name,Address_line_2_vod__c,Address_Line_3_AGN__c,
                                               State_vod__c,City_vod__c,Zip_vod__c, Brick_vod__c,Country_vod__c
                                               FROM Address_vod__c 
                                               WHERE Account_vod__c =: cr.Account_AGN__c
                                               AND Primary_vod__c = true];
     
                        w_otherAff.v_childAccount = cr.Contact_AGN__c;
                        w_otherAff.v_parentAccount = acc.Id;
                        w_otherAff.v_beds = acc.Beds__c;
                        w_otherAff.v_department = acc.Departments__c;
                        w_otherAff.v_speciality1 = acc.Specialty_1_AGN__r.Name;
                        w_otherAff.v_agnSpecialty = acc.Specialty_Allergan_1_AGN__r.Name;
                        w_otherAff.v_address = addr.Name+ ' '+
                                                (addr.Address_line_2_vod__c == null? '' : addr.Address_line_2_vod__c) + ' ' +
                                                (addr.Address_Line_3_AGN__c == null? '' : addr.Address_Line_3_AGN__c) + ' ' +
                                                (addr.City_vod__c == null ? '' : addr.City_vod__c) + ' ' +
                                                (addr.Zip_vod__c == null ? '' : addr.Zip_vod__c) + ' ' +
                                                (addr.Brick_vod__c == null ? '' : addr.Brick_vod__c) + ' ' +
                                                (addr.State_vod__c == null ? '' : addr.State_vod__c) + ' ' +
                                                (addr.Country_vod__c == null ? '' : addr.Country_vod__c);
                        w_otherAff.v_selected = true;
                        w_otherAff.v_primaryAffiliation = 'No';
                        w_otherAff.v_deleteAffiliation = false;
                    }
                }
           }
           
            if(isPersonAccountAdd){
                //Account acc;
                if(cr.Account_AGN__c != null) {
                    //if (acc == null){
                        parAccVal = [SELECT
                               Id, Name, IsPersonAccount,Beds__c,Departments__c,Fax,Specialty_1_AGN__c,Specialty_Allergan_1_AGN__c,Country_vod__c
                               FROM Account WHERE Id = :cr.Account_AGN__c];
                        addrVal = [SELECT Account_vod__c, Name,Address_line_2_vod__c,Address_Line_3_AGN__c,
                                               State_vod__c,City_vod__c,Zip_vod__c, Brick_vod__c,Country_vod__c
                                               FROM Address_vod__c 
                                               WHERE Account_vod__c =: cr.Account_AGN__c
                                               AND Primary_vod__c = true];
                                               
                        //Aditi :: R008.1
                        if(isMslUser || isClusterUser) {
                            String accMSLCode = [Select Alpha_2_Code_vod__c from Country_vod__c where Id =: parAccVal.Country_vod__c].Alpha_2_Code_vod__c;
                            cr.Country_Code_AGN__c = accMSLCode;
                        }
                }
            }
        }

        // END:: R008.1 : Apurba modification on 09/09/2016
        public void w_selectOtherAccountFromLookup()
        {      
            //R008 - Affiliation
           
            if(isPersonAccountChange){
                Account acc;
                w_otherAff = new w_AffiliationWrapper();
                if(cr.Contact_AGN__c != null && cr.Account_AGN__c != null) {         
                    acc = [SELECT
                           Id, Name, IsPersonAccount,Beds__c,Departments__c,Fax,Specialty_1_AGN__r.Name,
                           Specialty_2_AGN__r.Name,Specialty_Allergan_1_AGN__r.Name
                           FROM Account WHERE Id = :cr.Account_AGN__c];
                           system.debug('1=========Inside w_selectOtherAccountFromLookup Account_AGN__c==='+ cr.Account_AGN__c + '=======Account===='+acc);
                    Address_vod__c addr = [SELECT Account_vod__c, Name,Address_line_2_vod__c,Address_Line_3_AGN__c,
                                           State_vod__c,City_vod__c,Zip_vod__c, Brick_vod__c,Country_vod__c
                                           FROM Address_vod__c 
                                           WHERE Account_vod__c =: cr.Account_AGN__c
                                           AND Primary_vod__c = true];
                   /* Child_Account_vod__c cacc = new  Child_Account_vod__c
                        (Child_Account_vod__c = cr.Contact_AGN__c,
                         Parent_Account_vod__c = acc.id,
                         Copy_Address_vod__c = true
                        );*/
 
                    system.debug('1==Beds__c=='+(acc.Beds__c == null)+'   BED:'+acc.Beds__c);
                    w_otherAff.v_parentAccount = cr.Account_AGN__c;
                    w_otherAff.v_beds = acc.Beds__c;
                    w_otherAff.v_department = acc.Departments__c;
                    w_otherAff.v_speciality1 = acc.Specialty_1_AGN__r.Name;
                    w_otherAff.v_agnSpecialty = acc.Specialty_Allergan_1_AGN__r.Name;
                    w_otherAff.v_address = addr.Name+ ' '+
                                            (addr.Address_line_2_vod__c == null? '' : addr.Address_line_2_vod__c) + ' ' +
                                            (addr.Address_Line_3_AGN__c == null? '' : addr.Address_Line_3_AGN__c) + ' ' +
                                            (addr.City_vod__c == null ? '' : addr.City_vod__c) + ' ' +
                                            (addr.Zip_vod__c == null ? '' : addr.Zip_vod__c) + ' ' +
                                            (addr.Brick_vod__c == null ? '' : addr.Brick_vod__c) + ' ' +
                                            (addr.State_vod__c == null ? '' : addr.State_vod__c) + ' ' +
                                            (addr.Country_vod__c == null ? '' : addr.Country_vod__c);
                    w_otherAff.v_selected = true;
                    w_otherAff.v_primaryAffiliation = 'No';
                    w_otherAff.v_deleteAffiliation = false;
                    system.debug('2=========Inside w_selectOtherAccountFromLookup w_otherAff==='+w_otherAff);
                }
           }
           
            if(isPersonAccountAdd){
                //Account acc;
                if(cr.Account_AGN__c != null) {
                    //if (acc == null){
                        parAccVal = [SELECT
                               Id, Name, IsPersonAccount,Beds__c,Departments__c,Fax,Specialty_1_AGN__c,Specialty_Allergan_1_AGN__c
                               FROM Account WHERE Id = :cr.Account_AGN__c];
                        addrVal = [SELECT Account_vod__c, Name,Address_line_2_vod__c,Address_Line_3_AGN__c,
                                               State_vod__c,City_vod__c,Zip_vod__c, Brick_vod__c,Country_vod__c
                                               FROM Address_vod__c 
                                               WHERE Account_vod__c =: cr.Account_AGN__c
                                               AND Primary_vod__c = true];

                        // cr.Beds_AGN__c = acc.Beds__c;
                        // cr.Departments_AGN__c = acc.Departments__c;
                        // cr.Specialty_1_AGN__c = acc.Specialty_1_AGN__c;
                        // cr.Specialty_Allergan_1_AGN__c = acc.Specialty_Allergan_1_AGN__c;
     
                        //cr.Address_Line_1_AGN__c = addr.Name ;
                        // addr.Address_line_2_vod__c == null? '' : addr.Address_line_2_vod__c + ' ' +
                        // addr.Address_Line_3_AGN__c == null? '' : addr.Address_Line_3_AGN__c + ' ' +
                        // addr.City_vod__c == null ? '' : addr.City_vod__c + ' ' +
                        // addr.Zip_vod__c == null ? '' : addr.Zip_vod__c + ' ' +
                        // addr.Brick_vod__c == null ? '' : addr.Brick_vod__c + ' ' +
                        // addr.State_vod__c == null ? '' : addr.State_vod__c  + ' ' +
                        // addr.Country_vod__c == null ? '' : addr.Country_vod__c;
     
                    //}
                }
            }
        }
        //End - Affiliation Wrapper   
        
        /**
    * Called whenever a new HCP is selected
    */
        public void selectPersonAccount() {
            
            system.debug('===== Inside [selectPersonAccount] =====');
            //R008 Requirement# 918 : Added field 
            List<Account> personAccount = 
                [SELECT Salutation,FirstName,LastName,Gender_vod__c,Primary_Parent_vod__c,Account_Type__c,Consent_to_Contact_AGN__c,
                 Education_Speciality_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Email_Internal_AGN__c,PersonEmail,Fax,Fax_Internal_AGN__c,
                 PersonMobilePhone,Mobile_Internal_AGN__c,Workplace_AGN__c,Specialty_Allergan_1_AGN__c,Sub_Specialty_Allergan_AGN__c,
                 Additional_Specialties_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,Website,Type_AGN__c,
                 Consent_to_Phone_AGN__c,Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,Middle_vod__c,Do_not_send_Mail__c,KOL_vod__c,RecordTypeId,
                 Other_title_information_AGN__c,Status_AGN__c,Do_not_Visit_AGN__c,Language_vod__c,Target__c,PersonBirthdate,Graduation_School_AGN__c,
                 Graduation_Year_AGN__c,Phone_Internal_AGN__c,Calling_Name_AGN__c,Other_Name_AGN__c,Description,NS_Headache_Target_Centre_AGN__c,
                 No_Orders_vod__c,Order_Type_vod__c,Default_Order_Type_vod__c,Country_Code__c,Country_vod__c,
                 Distribution_ID_AGN__c,External_ID2_AGN__c,External_ID4_AGN__c,Physician_Registration_Reference_AGN__c,Influential_profile_AGN__c,
                 Address_AGN__c,Avocis_date_AGN__c,Avocis_placed_AGN__c,Customer_Consent_AGN__c,IS_Rank_AGN__c,IS_Type_AGN__c,Owner_AGN__c,
                 Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,Position_at_Primary_Institution_AGN__c,
                 Sales_Credit_Limit_AGN__c,Target_AGN__c,
                 Phone
                 FROM Account WHERE Id = :cr.Contact_AGN__c];
                 //R008 Requirement# 918 : Added field 
            if (personAccount.size() != 1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Person_Account_Not_Found));
            }
            else {         
                cr.Salutation_AGN__c = personAccount[0].Salutation;
                cr.Account_Type_AGN__c = [select Name from RecordType where Id = :personAccount[0].RecordTypeId].Name;
                cr.FirstName_AGN__c = personAccount[0].FirstName;
                cr.Type_AGN__c = personAccount[0].Type_AGN__c;
                cr.Last_Name_AGN__c = personAccount[0].LastName;
                cr.Privacy_AGN__c = personAccount[0].Privacy_AGN__c;
                cr.Middle_Name_AGN__c = personAccount[0].Middle_vod__c;
                cr.Privacy_law_status_AGN__c = personAccount[0].Privacy_law_status_AGN__c;
                cr.Gender_AGN__c = personAccount[0].Gender_vod__c;
                cr.Specialty_1_AGN__c = personAccount[0].Specialty_1_AGN__c;
                cr.Education_Speciality_AGN__c = personAccount[0].Education_Speciality_AGN__c;
                cr.Specialty_2_AGN__c = personAccount[0].Specialty_2_AGN__c;
                cr.Specialty_Allergan_1_AGN__c = personAccount[0].Specialty_Allergan_1_AGN__c;
                cr.Sub_Specialty_Allergan_AGN__c = personAccount[0].Sub_Specialty_Allergan_AGN__c;
                cr.Additional_Specialties_AGN__c = personAccount[0].Additional_Specialties_AGN__c;
                cr.Email_AGN__c = personAccount[0].PersonEmail;
                cr.Consent_to_Email_AGN__c = personAccount[0].Consent_to_Email_AGN__c;
                cr.Fax_AGN__c = personAccount[0].Fax;
                cr.Consent_to_Mail_AGN__c = personAccount[0].Consent_to_Mail_AGN__c;
                cr.Website_AGN__c = personAccount[0].Website;
                cr.Mobile_AGN__c = personAccount[0].PersonMobilePhone;
                cr.Consent_to_Phone_AGN__c = personAccount[0].Consent_to_Phone_AGN__c;
                cr.Workplace_AGN__c = personAccount[0].Workplace_AGN__c;
                cr.KOL_AGN__c = personAccount[0].KOL_vod__c;
                cr.Do_not_Phone_Call_AGN__c = personAccount[0].Do_not_Phone_Call_AGN__c;
                cr.Do_not_send_Fax_AGN__c = personAccount[0].Do_not_send_Fax_AGN__c;
                cr.JobTitle_AGN__c = personAccount[0].Other_title_information_AGN__c;
                cr.Do_not_send_Mail_AGN__c = personAccount[0].Do_not_send_Mail__c; 
                cr.Delete_Affiliation_AGN__c = false;
                //R003
                cr.Account_Status_AGN__c = personAccount[0].Status_AGN__c;
                cr.Target_AGN__c = personAccount[0].Target__c;
                cr.Language_AGN__c = personAccount[0].Language_vod__c;
                cr.Do_not_Visit_AGN__c = personAccount[0].Do_not_Visit_AGN__c;
                cr.Consent_to_Contact_AGN__c = personAccount[0].Consent_to_Contact_AGN__c;
                //R005
                cr.PersonBirthdate_AGN__c = personAccount[0].PersonBirthdate;
                cr.Graduation_School_AGN__c = personAccount[0].Graduation_School_AGN__c;
                cr.Graduation_Year_AGN__c = personAccount[0].Graduation_Year_AGN__c;
                cr.Phone_Internal_AGN__c = personAccount[0].Phone_Internal_AGN__c;
                cr.Email_Internal_AGN__c = personAccount[0].Email_Internal_AGN__c;
                cr.Fax_Internal_AGN__c = personAccount[0].Fax_Internal_AGN__c;
                cr.Calling_Name_AGN__c = personAccount[0].Calling_Name_AGN__c;
                cr.Other_Name_AGN__c = personAccount[0].Other_Name_AGN__c;
                cr.Description_AGN__c = personAccount[0].Description;
                cr.NS_Headache_Target_Centre_AGN__c = personAccount[0].NS_Headache_Target_Centre_AGN__c;
                 //R008      
                cr.Account_Phone_AGN__c = personAccount[0].Phone;
                //R006
                cr.No_Orders_AGN__c = personAccount[0].No_Orders_vod__c;
                cr.Order_Type_AGN__c = personAccount[0].Order_Type_vod__c;
                cr.Default_Order_Type_AGN__c = personAccount[0].Default_Order_Type_vod__c;
                //R007 :: Aditi :: R008.1 - fixed
                //cr.Country_Code_AGN__c = personAccount[0].Country_Code__c;
                cr.Country_Code_AGN__c = [Select Alpha_2_Code_vod__c from Country_vod__c where Id =: personAccount[0].Country_vod__c].Alpha_2_Code_vod__c;
                cr.Account_Country_AGN__c = personAccount[0].Country_vod__c;
                cr.Distribution_ID_AGN__c = personAccount[0].Distribution_ID_AGN__c;
                cr.DCR_External_ID2_AGN__c = personAccount[0].External_ID2_AGN__c;
                cr.DCR_External_ID4_AGN__c = personAccount[0].External_ID4_AGN__c;
                cr.Physician_Registration_Reference_AGN__c = personAccount[0].Physician_Registration_Reference_AGN__c;
                //R008
                cr.Influential_profile_AGN__c = personAccount[0].Influential_profile_AGN__c;
                // Select the Primary Business account for the selected Person account
                affiliatedAccountId = personAccount[0].Primary_Parent_vod__c;
                //R008 Requirement# 918 : Added field 
                cr.Avocis_date_AGN__c = personAccount[0].Avocis_date_AGN__c;
                cr.Avocis_placed_AGN__c = personAccount[0].Avocis_placed_AGN__c ; 
                cr.Customer_Consent_AGN__c = personAccount[0].Customer_Consent_AGN__c; 
                cr.Owner_AGN__c = personAccount[0].Owner_AGN__c; 
                cr.Position_at_Primary_Institution_AGN__c = personAccount[0].Position_at_Primary_Institution_AGN__c; 
                //R008 Requirement# 918 : Added field 
                // Load the primary business account
                if (affiliatedAccountId != null) {
                    fetchAccount(affiliatedAccountId);
                    fetchAffiliation(cr.Contact_AGN__c,affiliatedAccountId);
                }else{
                    //Clear Business Account and Address fields if selected Person Account does not have a Primary Business Account
                    affiliatedAccountId = 'other';
                    cr.Account_AGN__c = null;
                    cr.Account_Name_AGN__c = null;
                    cr.Primary_Business_Accnt_AGN__c = null;
                    cr.Affiliated_Account_Sub_Type__c = null;
                    cr.Affiliated_Account_Type_AGN__c = null;
                    cr.Account_Phone_AGN__c = null;
                    cr.Beds_AGN__c = null;
                    cr.Departments_AGN__c = null;                
                    cr.Role_AGN__c = null;
                    cr.Primary_Affiliation_AGN__c = null;                
                    associatedAddressId = null;
                    cr.Address_AGN__c = null;
                    cr.Address_Line_1_AGN__c = null;
                    cr.Address_Type_AGN__c = null;
                    cr.Address_Line_2_AGN__c = null;
                    cr.Billing_AGN__c = null;
                    cr.Brick_AGN__c = null;
                    cr.Business_AGN__c = null;
                    cr.City_AGN__c = null;
                    cr.Home_AGN__c = null;
                    cr.Country_AGN__c = null;
                    cr.Mailing_AGN__c = null;
                    cr.Zip_AGN__c = null;
                    cr.Shipping_AGN__c = null;                
                    cr.Fax_AGN__c = null;
                    cr.Appt_Required_AGN__c = null;
                    cr.Phone_AGN__c = null;
                    cr.Receptionist_Name_AGN__c = null;
                    cr.Phone_2_AGN__c = null;
                    cr.Receptionist_Email_AGN__c = null;
                    //R005
                    cr.Patients_AGN__c = null;
                    cr.Account_Group_AGN__c = null;
                    cr.Institution_Site_AGN__c = null;
                    cr.Address_Line_3_AGN__c = null;
                    cr.State_AGN__c = null;
                    cr.Work_Status_AGN__c = null;
                    //R007.1
                    cr.Organization_Registration_Reference_AGN__c = null;
                    cr.Allergan_Account_Group_AGN__c = null;
                    //R008 Requirement# 918 : Added field 
                    cr.Avocis_date_AGN__c = null;
                    cr.Avocis_placed_AGN__c = null;
                    cr.Customer_Consent_AGN__c = null;
                    cr.Owner_AGN__c = null;
                    cr.Position_at_Primary_Institution_AGN__c = null;
                    //R008 Requirement# 918 : Added field 
                }
                setsubCustomPicklistItems( picklistValuesToShow ,cr);
            }
        }
        
        /*
    * Called when an acocunt is selected using the lookup
    */
        
        public void selectBusinessAccountFromLookup() {
            
            system.debug('===== Inside [selectBusinessAccountFromLookup] =====');
            // Make sure affiliatedAccountId to other if not already
            affiliatedAccountId = 'other';
            
            // Reload details
            fetchAccount(cr.Account_AGN__c);
            if (cr.Contact_AGN__c != null)
                fetchAffiliation(cr.Contact_AGN__c,cr.Account_AGN__c);
        }
        
        /*
    * Called when an Business Account is selected using the affiliation list
    */
        public void selectBusinessAccountFromList() {
            
            system.debug('===== Inside [selectBusinessAccountFromList] =====');
            cr.Delete_Affiliation_AGN__c = false;
            
            if (affiliatedAccountId == 'other') {
                // Clear account details
                cr.Account_AGN__c = null;
                cr.Account_Name_AGN__c = null;
                cr.Primary_Business_Accnt_AGN__c = null;
                cr.Affiliated_Account_Sub_Type__c = null;
                cr.Affiliated_Account_Type_AGN__c = null;
                cr.Account_Phone_AGN__c = null;
                cr.Beds_AGN__c = null;
                cr.Departments_AGN__c = null;
                cr.Role_AGN__c = null;
                cr.Primary_Affiliation_AGN__c = null;
                
                //Clear Address details
                associatedAddressId = null;
                cr.Address_AGN__c = null;
                cr.Address_Line_1_AGN__c = null;
                cr.Address_Type_AGN__c = null;
                cr.Address_Line_2_AGN__c = null;
                cr.Billing_AGN__c = null;
                cr.Brick_AGN__c = null;
                cr.Business_AGN__c = null;
                cr.City_AGN__c = null;
                cr.Home_AGN__c = null;
                cr.Country_AGN__c = null;
                cr.Mailing_AGN__c = null;
                cr.Zip_AGN__c = null;
                cr.Shipping_AGN__c = null;                
                cr.Fax_AGN__c = null;
                cr.Appt_Required_AGN__c = null;
                cr.Phone_AGN__c = null;
                cr.Receptionist_Name_AGN__c = null;
                cr.Phone_2_AGN__c = null;
                cr.Receptionist_Email_AGN__c = null;
                
                //R005
                cr.Patients_AGN__c = null;
                cr.Account_Group_AGN__c = null;
                cr.Institution_Site_AGN__c = null;
                cr.Work_Status_AGN__c = null;
                cr.Address_Line_3_AGN__c = null;
                cr.State_AGN__c = null;
                //R007.1
                cr.Organization_Registration_Reference_AGN__c = null;
                cr.Allergan_Account_Group_AGN__c = null;
                //R008 Requirement# 918 : Added field 
                cr.Address_Whanin_AGN__c = null;
                cr.Avocis_date_AGN__c = null;
                cr.Avocis_placed_AGN__c = null;
                cr.IS_Rank_AGN__c = null;
                cr.IS_Type_AGN__c = null;
                cr.Owner_AGN__c = null;
                cr.Partner_Email_AGN__c = null;
                cr.Partner_Emp_Code_AGN__c = null;
                cr.Partner_Rep_Name_AGN__c = null;
                cr.Partner_Team_Name_AGN__c = null;
                cr.Sales_Credit_Limit_AGN__c = null;
                cr.Target_Whanin_AGN__c = null;
                    
                if (cr.Account_AGN__c != null)
                    fetchAccount(cr.Account_AGN__c);
                
            }
            else {
                // Clear the account lookup if set
                cr.Account_AGN__c = null;
                
                // Reload details
                fetchAccount(affiliatedAccountId);
                
                if (cr.Contact_AGN__c != null)
                    fetchAffiliation(cr.Contact_AGN__c,affiliatedAccountId);
            }
        }
        
        
        /* Load details of Business Account onto the DCR Page
    */
        private void fetchAccount(Id id) {
            
            system.debug('===== Inside [fetchAccount] =====');
            //R008 Requirement# 918 : Added field 
            List<Account> accntList = [SELECT Name,Phone,RecordTypeId,Type_AGN__c,Primary_Parent_vod__c,Beds__c,Departments__c,Fax,Specialty_1_AGN__c,Specialty_2_AGN__c,
                                       Specialty_Allergan_1_AGN__c,Sub_Specialty_Allergan_AGN__c,Additional_Specialties_AGN__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,
                                       Website,Consent_to_Phone_AGN__c,Do_not_Phone_Call_AGN__c,Consent_to_Contact_AGN__c,Workplace_AGN__c,Privacy_AGN__c,Do_not_send_Fax_AGN__c,
                                       Privacy_law_status_AGN__c,Status_AGN__c,Do_not_Visit_AGN__c,Language_vod__c,Target__c,Do_not_send_Mail__c,PersonBirthdate,
                                       Graduation_School_AGN__c,Graduation_Year_AGN__c,Other_title_information_AGN__c,Patients_AGN__c,Account_Group_vod__c,Institution_Site_AGN__c,
                                       Phone_Internal_AGN__c,Email_Internal_AGN__c,Fax_Internal_AGN__c,Calling_Name_AGN__c,Other_Name_AGN__c,Description,NS_Headache_Target_Centre_AGN__c,
                                       Country_vod__c,Distribution_ID_AGN__c,External_ID2_AGN__c,External_ID4_AGN__c,Physician_Registration_Reference_AGN__c,Country_Code__c,
                                       Organization_Registration_Reference_AGN__c,Account_Group_AGN__c,Address_AGN__c,Avocis_date_AGN__c,Avocis_placed_AGN__c,
                                       Customer_Consent_AGN__c,IS_Rank_AGN__c,IS_Type_AGN__c,Owner_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,
                                       Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,Position_at_Primary_Institution_AGN__c,Sales_Credit_Limit_AGN__c,Target_AGN__c,
                                       (SELECT Id FROM Address_vod__r WHERE Primary_vod__c = true)
                                       FROM Account WHERE Id = :id];
           //R008 Requirement# 918 : Added field 
            
            if (accntList.size() != 1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Business_Account_Not_Found));
            }
            else
            {      
                //R007 :: Aditi :: R008.1 - fixed
                //cr.Country_Code_AGN__c = accntList[0].Country_Code__c;
                cr.Country_Code_AGN__c = [Select Alpha_2_Code_vod__c from Country_vod__c where Id =: accntList[0].Country_vod__c].Alpha_2_Code_vod__c;
                System.Debug('== [fetchAccount] - Set CountryCode ==' + accntList[0].Country_Code__c);
                
                if(isPersonAccount){
                    cr.Affiliated_Account_Type_AGN__c = [select Name from RecordType where Id = :accntList[0].RecordTypeId].Name;
                    cr.Affiliated_Account_Sub_Type__c = accntList[0].Type_AGN__c;  
                }
                
                if(isBusinessAccount){
                    cr.Account_Type_AGN__c = [select Name from RecordType where Id = :accntList[0].RecordTypeId].Name;
                    cr.Type_AGN__c = accntList[0].Type_AGN__c; 
                    cr.Fax_AGN__c = accntList[0].Fax ;
                    cr.Specialty_1_AGN__c = accntList[0].Specialty_1_AGN__c ;
                    cr.Specialty_2_AGN__c = accntList[0].Specialty_2_AGN__c ;
                    cr.Specialty_Allergan_1_AGN__c = accntList[0].Specialty_Allergan_1_AGN__c ;
                    cr.Sub_Specialty_Allergan_AGN__c = accntList[0].Sub_Specialty_Allergan_AGN__c ;
                    cr.Additional_Specialties_AGN__c = accntList[0].Additional_Specialties_AGN__c ;
                    cr.Consent_to_Email_AGN__c = accntList[0].Consent_to_Email_AGN__c ;
                    cr.Consent_to_Mail_AGN__c = accntList[0].Consent_to_Mail_AGN__c ;
                    cr.Website_AGN__c = accntList[0].Website ;
                    cr.Consent_to_Phone_AGN__c = accntList[0].Consent_to_Phone_AGN__c ;
                    cr.Do_not_Phone_Call_AGN__c = accntList[0].Do_not_Phone_Call_AGN__c ;
                    cr.Privacy_AGN__c = accntList[0].Privacy_AGN__c ;
                    cr.Do_not_send_Fax_AGN__c = accntList[0].Do_not_send_Fax_AGN__c ;
                    cr.Privacy_law_status_AGN__c = accntList[0].Privacy_law_status_AGN__c ;
                    cr.Do_not_send_Mail_AGN__c = accntList[0].Do_not_send_Mail__c ;
                    
                    cr.Account_Name_AGN__c = accntList[0].Name;
                    cr.Primary_Business_Accnt_AGN__c = accntList[0].Primary_Parent_vod__c;
                    cr.Account_Phone_AGN__c = accntList[0].Phone;
                    cr.Beds_AGN__c = accntList[0].Beds__c;
                    cr.Departments_AGN__c = accntList[0].Departments__c;
                    //R003
                    cr.Account_Status_AGN__c = accntList[0].Status_AGN__c;
                    cr.Target_AGN__c = accntList[0].Target__c;
                    cr.Language_AGN__c = accntList[0].Language_vod__c;
                    cr.Do_not_Visit_AGN__c = accntList[0].Do_not_Visit_AGN__c; 
                    cr.Consent_to_Contact_AGN__c = accntList[0].Consent_to_Contact_AGN__c;
                    //R005
                    cr.Patients_AGN__c = accntList[0].Patients_AGN__c;
                    cr.Account_Group_AGN__c = accntList[0].Account_Group_vod__c;
                    cr.Institution_Site_AGN__c = accntList[0].Institution_Site_AGN__c;
                    cr.NS_Headache_Target_Centre_AGN__c = accntList[0].NS_Headache_Target_Centre_AGN__c;
                    //R005 fixed
                    cr.Phone_Internal_AGN__c = accntList[0].Phone_Internal_AGN__c;
                    cr.Email_Internal_AGN__c = accntList[0].Email_Internal_AGN__c;
                    cr.Fax_Internal_AGN__c = accntList[0].Fax_Internal_AGN__c;
                    cr.Calling_Name_AGN__c = accntList[0].Calling_Name_AGN__c;
                    cr.Other_Name_AGN__c = accntList[0].Other_Name_AGN__c;
                    cr.Description_AGN__c = accntList[0].Description;
                    cr.Workplace_AGN__c = accntList[0].Workplace_AGN__c;
                    cr.Account_Phone_AGN__c = accntList[0].Phone;
                    //R007 - fixed in R008.1
                    //cr.Country_Code_AGN__c = accntList[0].Country_Code__c;
                    cr.Account_Country_AGN__c = accntList[0].Country_vod__c;
                    cr.Distribution_ID_AGN__c = accntList[0].Distribution_ID_AGN__c;
                    cr.DCR_External_ID2_AGN__c = accntList[0].External_ID2_AGN__c;
                    cr.DCR_External_ID4_AGN__c = accntList[0].External_ID4_AGN__c;
                    cr.Physician_Registration_Reference_AGN__c = accntList[0].Physician_Registration_Reference_AGN__c;
                    //R007.1
                    cr.Organization_Registration_Reference_AGN__c = accntList[0].Organization_Registration_Reference_AGN__c;
                    cr.Allergan_Account_Group_AGN__c = accntList[0].Account_Group_AGN__c;
                    //R008 Requirement# 918 : Added field 
                    cr.Address_Whanin_AGN__c = accntList[0].Address_AGN__c;
                    cr.Avocis_date_AGN__c = accntList[0].Avocis_date_AGN__c;
                    cr.Avocis_placed_AGN__c = accntList[0].Avocis_placed_AGN__c ; 
                    cr.IS_Rank_AGN__c = accntList[0].IS_Rank_AGN__c; 
                    cr.IS_Type_AGN__c = accntList[0].IS_Type_AGN__c; 
                    cr.Owner_AGN__c = accntList[0].Owner_AGN__c; 
                    cr.Partner_Email_AGN__c = accntList[0].Partner_Email_AGN__c; 
                    cr.Partner_Emp_Code_AGN__c = accntList[0].Partner_Emp_Code_AGN__c; 
                    cr.Partner_Rep_Name_AGN__c = accntList[0].Partner_Rep_Name_AGN__c; 
                    cr.Partner_Team_Name_AGN__c = accntList[0].Partner_Team_Name_AGN__c; 
                    cr.Sales_Credit_Limit_AGN__c = accntList[0].Sales_Credit_Limit_AGN__c; 
                    cr.Target_Whanin_AGN__c = accntList[0].Target_AGN__c ;
                    //R008 Requirement# 918 : Added field 
                    setsubCustomPicklistItems( picklistValuesToShow ,cr);
                }

                //system.debug('== accntList[0].Address_vod__r[0] =>'+accntList[0].Address_vod__r[0]);
                if (accntList[0].Address_vod__r.size() > 0) {
                    cr.Address_AGN__c = accntList[0].Address_vod__r[0].Id;
                    associatedAddressId = cr.Address_AGN__c;
                    fetchAddress(associatedAddressId); 
                }
                
                // Fetch data for Existing Product Metrics
                if(isPersonAccount)
                    curProductMetrics = [SELECT Id,Account_vod__c,Products_vod__c,Adoption_AGN__c,Adoption_IMS_AGN__c,Allergan_Potential_AGN__c,Potential_IMS_AGN__c,
                        Segment_AGN__c,Segment_IMS_AGN__c,Target_AGN__c,Sector_AGN__c,Fase_AGN__c,Ratings_AGN__c,Advocacy_Profile_AGN__c,Investigator_Readiness__c,
                        Customer_Segment_AGN__c,Sales_Target_AGN__c,Investigator_smb__c,Profiling_AGN__c,Retina_Profile_AGN__c,Product_Status_AGN__c,Growth_Potential_AGN__c,
                        Awareness__c,Adoption_Level__c,Engagements__c,Account_Support_AGN__c,Fixed_Consignment_AGN__c,Key_Account_AGN__c,Ophthalmology_Profile_AGN__c,
                        Segment__c,Continuum_Placement_AGN__c
                        FROM Product_Metrics_vod__c WHERE Account_vod__c = :cr.Contact_AGN__c];
                else
                    curProductMetrics = [SELECT Id,Account_vod__c,Products_vod__c,Adoption_AGN__c,Adoption_IMS_AGN__c,Allergan_Potential_AGN__c,Potential_IMS_AGN__c,
                        Segment_AGN__c,Segment_IMS_AGN__c,Target_AGN__c,Sector_AGN__c,Fase_AGN__c,Ratings_AGN__c,Advocacy_Profile_AGN__c,Investigator_Readiness__c,
                        Customer_Segment_AGN__c,Sales_Target_AGN__c,Investigator_smb__c,Profiling_AGN__c,Retina_Profile_AGN__c,Product_Status_AGN__c,Growth_Potential_AGN__c,
                        Awareness__c,Adoption_Level__c,Engagements__c,Account_Support_AGN__c,Fixed_Consignment_AGN__c,Key_Account_AGN__c,Ophthalmology_Profile_AGN__c,
                        Segment__c,Continuum_Placement_AGN__c
                        FROM Product_Metrics_vod__c WHERE Account_vod__c = :cr.Account_AGN__c];
                for(integer i = 0 ; i < dcrProdMetrWrappers.size() ; i++) 
                {
                    for(Product_Metrics_vod__c pm: curProductMetrics) {
                        if(pm.Products_vod__c == dcrProdMetrWrappers[i].dcrProductMetrics.Product_AGN__c) {
                            dcrProdMetrWrappers[i].dcrProductMetrics.Product_Metrics_Reference__c = pm.Id;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Adoption_AGN__c = pm.Adoption_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Adoption_IMS_AGN__c = pm.Adoption_IMS_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Potential_AGN__c = pm.Allergan_Potential_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Potential_IMS_AGN__c = pm.Potential_IMS_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Segment_AGN__c = pm.Segment_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Segment_IMS_AGN__c = pm.Segment_IMS_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Target_AGN__c = pm.Target_AGN__c;
                            //R005
                            dcrProdMetrWrappers[i].dcrProductMetrics.Sector_AGN__c = pm.Sector_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Fase_AGN__c = pm.Fase_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Ratings_AGN__c = pm.Ratings_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Advocacy_Profile_AGN__c = pm.Advocacy_Profile_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Investigator_Readiness_AGN__c = pm.Investigator_Readiness__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Customer_Segment_AGN__c = pm.Customer_Segment_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Sales_Target_AGN__c = pm.Sales_Target_AGN__c;
                            //R007
                            dcrProdMetrWrappers[i].dcrProductMetrics.Investigator_AGN__c = pm.Investigator_smb__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Profiling_AGN__c = pm.Profiling_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Retina_Profile_AGN__c = pm.Retina_Profile_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Product_Status_AGN__c = pm.Product_Status_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Growth_Potential_AGN__c = pm.Growth_Potential_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Awareness_AGN__c = pm.Awareness__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Adoption_Level_AGN__c = pm.Adoption_Level__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Engagements_AGN__c = pm.Engagements__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Account_Support_AGN__c = pm.Account_Support_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Fixed_Consignment_AGN__c = pm.Fixed_Consignment_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Key_Account_AGN__c = pm.Key_Account_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Ophthalmology_Profile_AGN__c = pm.Ophthalmology_Profile_AGN__c;
                            dcrProdMetrWrappers[i].dcrProductMetrics.Segment1_AGN__c = pm.Segment__c;
                            //R007.1
                            dcrProdMetrWrappers[i].dcrProductMetrics.Continuum_Placement_AGN__c = pm.Continuum_Placement_AGN__c;
                            dcrProdMetrWrappers[i].selected = true;
                            break;
                        }
                    }
                }
              
                   for(integer i = 0 ; i < cdcrProdMetrWrappers.size() ; i++) 
            {
                    for(Product_Metrics_vod__c pm: curProductMetrics) {
                        if(pm.Products_vod__c == cdcrProdMetrWrappers[i].dcrProductMetrics.Product_AGN__c) {
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Product_Metrics_Reference__c = pm.Id;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Adoption_AGN__c = pm.Adoption_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Adoption_IMS_AGN__c = pm.Adoption_IMS_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Potential_AGN__c = pm.Allergan_Potential_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Potential_IMS_AGN__c = pm.Potential_IMS_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Segment_AGN__c = pm.Segment_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Segment_IMS_AGN__c = pm.Segment_IMS_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Target_AGN__c = pm.Target_AGN__c;
                            //R005
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Sector_AGN__c = pm.Sector_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Fase_AGN__c = pm.Fase_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Ratings_AGN__c = pm.Ratings_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Advocacy_Profile_AGN__c = pm.Advocacy_Profile_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Investigator_Readiness_AGN__c = pm.Investigator_Readiness__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Customer_Segment_AGN__c = pm.Customer_Segment_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Sales_Target_AGN__c = pm.Sales_Target_AGN__c;
                            //R007
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Investigator_AGN__c = pm.Investigator_smb__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Profiling_AGN__c = pm.Profiling_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Retina_Profile_AGN__c = pm.Retina_Profile_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Product_Status_AGN__c = pm.Product_Status_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Growth_Potential_AGN__c = pm.Growth_Potential_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Awareness_AGN__c = pm.Awareness__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Adoption_Level_AGN__c = pm.Adoption_Level__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Engagements_AGN__c = pm.Engagements__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Account_Support_AGN__c = pm.Account_Support_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Fixed_Consignment_AGN__c = pm.Fixed_Consignment_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Key_Account_AGN__c = pm.Key_Account_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Ophthalmology_Profile_AGN__c = pm.Ophthalmology_Profile_AGN__c;
                            cdcrProdMetrWrappers[i].dcrProductMetrics.Segment1_AGN__c = pm.Segment__c;
                            
                            cdcrProdMetrWrappers[i].selected = true;
                            break;
                        }
                    }
            }
                
                
            }
        }
        
        /*
    * Load membership details onto the DCR Page
    */
        private void fetchAffiliation(Id person, Id account) {
            
            system.debug('===== Inside [fetchAffiliation] =====');
            
            if(cr.Request_Status_AGN__c == 'Processing'){
                if (dcrId != null){
                    //Fetch Affiliation details from DCR object if DCR is Saved previously 
                    List<DCR_AGN__c> dcrlist = [SELECT Id,Name,Role_AGN__c,Primary_Affiliation_AGN__c,
                                                Work_Status_AGN__c,Account_AGN__c,Contact_AGN__c
                                                FROM DCR_AGN__c
                                                WHERE Id =:dcrId
                                                AND (Account_AGN__c =:account AND Contact_AGN__c =:person)
                                               ];
                    system.debug('1 ======================'+dcrlist);
                    if (dcrlist.size() > 0) {
                        if (dcrlist[0].Role_AGN__c!= '' && dcrlist[0].Role_AGN__c!= null) {
                            cr.Role_AGN__c = dcrlist[0].Role_AGN__c;
                        }
                        else {                
                            cr.Role_AGN__c = '';
                        }
                        //R005
                        if (dcrlist[0].Work_Status_AGN__c!= '' && dcrlist[0].Work_Status_AGN__c!= null) {
                            cr.Work_Status_AGN__c = dcrlist[0].Work_Status_AGN__c;
                        }
                        else {                
                            cr.Work_Status_AGN__c = '';
                        }
                        cr.Primary_Affiliation_AGN__c = dcrlist[0].Primary_Affiliation_AGN__c;
                    }
                    else{
                        system.debug('2 ======================');
                        List<Child_Account_vod__c> affiliationList = [SELECT Name,OK_Role__c,Primary_vod__c,Work_Status_AGN__c,Parent_Account_vod__r.Name 
                                                                      FROM Child_Account_vod__c
                                                                      WHERE Child_Account_vod__c = :person
                                                                      AND Parent_Account_vod__c = :account];
                        
                        if(affiliationList.size()>0) {
                            primaryAffiliatedAccount = affiliationList[0].Parent_Account_vod__r.Name;
                            system.debug('== primaryAffiliatedAccount 1 ==>' + primaryAffiliatedAccount);
                            if (affiliationList.size() > 0) {
                                if (affiliationList[0].OK_Role__c!= '' && affiliationList[0].OK_Role__c!= null) {
                                    cr.Role_AGN__c = affiliationList[0].OK_Role__c;
                                }
                                else {                
                                    cr.Role_AGN__c = '';
                                }
                                //R005
                                if (affiliationList[0].Work_Status_AGN__c!= '' && affiliationList[0].Work_Status_AGN__c!= null) {
                                    cr.Work_Status_AGN__c = affiliationList[0].Work_Status_AGN__c;
                                }
                                else {                
                                    cr.Work_Status_AGN__c = '';
                                }
                                
                                cr.Primary_Affiliation_AGN__c = affiliationList[0].Primary_vod__c;
                            }
                        }
                    }//end else
                }// end dcr not null
                //Fetch Affiliation details from Child Account while creating a fresh new DCR
                else{
                    List<Child_Account_vod__c> affiliationList = [SELECT Name,OK_Role__c,Primary_vod__c,Work_Status_AGN__c,Parent_Account_vod__r.Name 
                                                                  FROM Child_Account_vod__c
                                                                  WHERE Child_Account_vod__c = :person
                                                                  AND Parent_Account_vod__c = :account];
                   
                    if (affiliationList.size() > 0) {
                             
                        primaryAffiliatedAccount = affiliationList[0].Parent_Account_vod__r.Name;
                        system.debug('== primaryAffiliatedAccount 2 ==>' + primaryAffiliatedAccount);
                        if (affiliationList[0].OK_Role__c!= '' && affiliationList[0].OK_Role__c!= null) {
                            cr.Role_AGN__c = affiliationList[0].OK_Role__c;
                        }
                        else {                
                            cr.Role_AGN__c = '';
                        }
                        //R005
                        if (affiliationList[0].Work_Status_AGN__c!= '' && affiliationList[0].Work_Status_AGN__c!= null) {
                            cr.Work_Status_AGN__c = affiliationList[0].Work_Status_AGN__c;
                        }
                        else {                
                            cr.Work_Status_AGN__c = '';
                        }              
                        cr.Primary_Affiliation_AGN__c = affiliationList[0].Primary_vod__c;
                    }
                }
                
            }//end processing
            else{
                List<Child_Account_vod__c> affiliationList = [SELECT Name,OK_Role__c,Primary_vod__c,Work_Status_AGN__c 
                                                              FROM Child_Account_vod__c
                                                              WHERE Child_Account_vod__c = :person
                                                              AND Parent_Account_vod__c = :account];
                
                if (affiliationList.size() > 0) {
                    if (affiliationList[0].OK_Role__c!= '' && affiliationList[0].OK_Role__c!= null) {
                        cr.Role_AGN__c = affiliationList[0].OK_Role__c;
                    }
                    else {                
                        cr.Role_AGN__c = '';
                    }
                    //R005
                    if (affiliationList[0].Work_Status_AGN__c!= '' && affiliationList[0].Work_Status_AGN__c!= null) {
                        cr.Work_Status_AGN__c = affiliationList[0].Work_Status_AGN__c;
                    }
                    else {                
                        cr.Work_Status_AGN__c = '';
                    }
                    
                    cr.Primary_Affiliation_AGN__c = affiliationList[0].Primary_vod__c;
                }
            }
        }
        /* ************************** Address ********************************** */
        
        public void pickAddressFromList() {
            
            system.debug('===== Inside [pickAddressFromList] =====');
            if(cr.Account_AGN__c != null || affiliatedAccountId != null){
                if (associatedAddressId == 'other') {
                    
                    cr.Address_AGN__c = null;
                    
                    cr.Address_Line_1_AGN__c = null;
                    cr.Address_Line_2_AGN__c = null;
                    cr.Address_Type_AGN__c = null;
                    cr.Billing_AGN__c = null;
                    cr.Brick_AGN__c = null;
                    cr.Business_AGN__c = null;
                    cr.City_AGN__c = null;
                    cr.Home_AGN__c = null;
                    cr.Country_AGN__c = null;
                    cr.Mailing_AGN__c = null;
                    cr.Zip_AGN__c = null;
                    cr.Shipping_AGN__c = null;                
                    cr.Fax_AGN__c = null;
                    cr.Appt_Required_AGN__c = null;
                    cr.Phone_AGN__c = null;
                    cr.Receptionist_Name_AGN__c = null;
                    cr.Phone_2_AGN__c = null;
                    cr.Receptionist_Email_AGN__c = null;
                    //R005
                    cr.Address_Line_3_AGN__c = null;
                    cr.State_AGN__c = null;
                    //R008
                    cr.Primary_Address_AGN__c= 'Yes';
                    
                }
                else {          
                    // Reload details
                    if(associatedAddressId != null)
                        fetchAddress(associatedAddressId);   
                }
            }
        }
        
        
        /* Load details of address onto the page
    */
        private void fetchAddress(String id) {
            system.debug('===== Inside [fetchAddress] =====');
            
            if(cr.Request_Status_AGN__c == 'Processing' && dcrId != null){
                List<DCR_AGN__c> dcrAddrlist = [SELECT Id,Address_AGN__c,Address_Line_1_AGN__c,Address_Type_AGN__c,Address_Line_2_AGN__c,Billing_AGN__c,Brick_AGN__c,
                                                Business_AGN__c,City_AGN__c,Home_AGN__c,Country_AGN__c,Mailing_AGN__c,Zip_AGN__c,Shipping_AGN__c,
                                                Fax_AGN__c,Appt_Required_AGN__c,Phone_AGN__c,Receptionist_Name_AGN__c,Phone_2_AGN__c,Receptionist_Email_AGN__c,
                                                Address_Line_3_AGN__c,State_AGN__c,Primary_Address_AGN__c
                                                FROM DCR_AGN__c
                                                WHERE Id =:dcrId
                                               ];
                if (dcrAddrlist.size() != 1) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.HCO_Address_Not_Found));
                    //'Unable to find address for the Business Account that has been selected'));
                }
                else
                {
                    cr.Address_AGN__c = dcrAddrlist[0].Address_AGN__c;
                    cr.Address_Line_1_AGN__c = dcrAddrlist[0].Address_Line_1_AGN__c;
                    cr.Address_Type_AGN__c = dcrAddrlist[0].Address_Type_AGN__c;
                    cr.Address_Line_2_AGN__c = dcrAddrlist[0].Address_Line_2_AGN__c;
                    cr.Billing_AGN__c = dcrAddrlist[0].Billing_AGN__c;
                    cr.Brick_AGN__c = dcrAddrlist[0].Brick_AGN__c;
                    cr.Business_AGN__c = dcrAddrlist[0].Business_AGN__c;
                    cr.City_AGN__c = dcrAddrlist[0].City_AGN__c;
                    cr.Home_AGN__c = dcrAddrlist[0].Home_AGN__c;
                    cr.Country_AGN__c = dcrAddrlist[0].Country_AGN__c;
                    cr.Mailing_AGN__c = dcrAddrlist[0].Mailing_AGN__c;
                    cr.Zip_AGN__c = dcrAddrlist[0].Zip_AGN__c;
                    cr.Shipping_AGN__c = dcrAddrlist[0].Shipping_AGN__c;               
                    cr.Fax_AGN__c = dcrAddrlist[0].Fax_AGN__c;
                    cr.Appt_Required_AGN__c = dcrAddrlist[0].Appt_Required_AGN__c;
                    cr.Phone_AGN__c = dcrAddrlist[0].Phone_AGN__c;
                    cr.Receptionist_Name_AGN__c = dcrAddrlist[0].Receptionist_Name_AGN__c;
                    cr.Phone_2_AGN__c = dcrAddrlist[0].Phone_2_AGN__c;
                    cr.Receptionist_Email_AGN__c = dcrAddrlist[0].Receptionist_Email_AGN__c;
                    //R005
                    cr.Address_Line_3_AGN__c = dcrAddrlist[0].Address_line_3_AGN__c;
                    cr.State_AGN__c = dcrAddrlist[0].State_AGN__c;
                    //R008
                    cr.Primary_Address_AGN__c = dcrAddrlist[0].Primary_Address_AGN__c;              
                }
            }
                else {
                    List<Address_vod__c> addressList = [SELECT Id, Name, City_vod__c, State_vod__c, Country_vod__c, Zip_vod__c, Address_line_2_vod__c,Address_Line_3_AGN__c,
                                                        Phone_vod__c, Phone_2_vod__c, Fax_vod__c, Receptionist_Email_AGN__c, Receptionist_Name_AGN__c,address_type_vod__c,
                                                        Billing_vod__c,Brick_vod__c,Business_vod__c,Home_vod__c,Mailing_vod__c,Shipping_vod__c,Appt_Required_vod__c,
                                                        Primary_vod__c
                                                        FROM Address_vod__c WHERE Id = :id ];
                   
                    if (addressList.size() != 1) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.HCO_Address_Not_Found));
                        //'Unable to find address for the Business Account that has been selected'));
                    }
                    else {
                        cr.Address_AGN__c = addressList[0].Id;
                        cr.Address_Line_1_AGN__c = addressList[0].Name;
                        cr.Address_Type_AGN__c = addressList[0].address_type_vod__c;
                        cr.Address_Line_2_AGN__c = addressList[0].Address_line_2_vod__c;
                        cr.Billing_AGN__c = addressList[0].Billing_vod__c;
                        cr.Brick_AGN__c = addressList[0].Brick_vod__c;
                        cr.Business_AGN__c = addressList[0].Business_vod__c;
                        cr.City_AGN__c = addressList[0].City_vod__c;
                        cr.Home_AGN__c = addressList[0].Home_vod__c;
                        cr.Country_AGN__c = addressList[0].Country_vod__c;
                        cr.Mailing_AGN__c = addressList[0].Mailing_vod__c;
                        cr.Zip_AGN__c = addressList[0].Zip_vod__c;
                        cr.Shipping_AGN__c = addressList[0].Shipping_vod__c;               
                        cr.Fax_AGN__c = addressList[0].Fax_vod__c;
                        cr.Appt_Required_AGN__c = addressList[0].Appt_Required_vod__c;
                        cr.Phone_AGN__c = addressList[0].Phone_vod__c;
                        cr.Receptionist_Name_AGN__c = addressList[0].Receptionist_Name_AGN__c;
                        cr.Phone_2_AGN__c = addressList[0].Phone_2_vod__c;
                        cr.Receptionist_Email_AGN__c = addressList[0].Receptionist_Email_AGN__c;
                        //R005
                        cr.Address_Line_3_AGN__c = addressList[0].Address_line_3_AGN__c;
                        cr.State_AGN__c = addressList[0].State_vod__c;
                        //R008
                        cr.Primary_Address_AGN__c = addressList[0].Primary_vod__c == true ?'Yes':'No';              
                    }
                }
            }
        
        /**
        * Submit the DCR record
        */
        public PageReference submit() 
        {
            
            system.debug('===== Inside [submit] =====');

            Savepoint sp = Database.setSavePoint();
            boolean createTask = True;
            boolean hasAffiliation = false;
            DCR_AGN__c baseDCR  = new DCR_AGN__c();
            List<DCR_AGN__c> idcr = new List<DCR_AGN__c>();
            Integer pAffCount = 0; 
            Boolean pAffDelCheck = false;
            //R008 1026
            if((isMslUser && isBusinessAccount)||(isClusterUser && isBusinessAccount))
                cr.Country_Code_AGN__c = [select Alpha_2_Code_vod__c from Country_vod__c where Id = :cr.Account_Country_AGN__c].Alpha_2_Code_vod__c;
     
            //BEGIN - R008 - Req.961
            if (isMslUser || isClusterUser)
            {
                //configSettingsMap
                string loggedInUserProfileName = [select Name from Profile where Id = :loggedInUser.ProfileId].Name;
                string userBU = loggedInUser.Division == null ? 'ZZ': loggedInUser.Division; 

                for(DCR_Configuration_Settings_AGN__c dcs2: [select Id,Manager_Approved_AGN__c,Local_Admin_Approved_AGN__c,
                                    Local_Approver_AGN__c,Business_Unit_AGN__c,External_Id_AGN__c
                                    FROM DCR_Configuration_Settings_AGN__c
                                    WHERE Country_Code_AGN__c = :cr.Country_Code_AGN__c  
                                    AND Profile_AGN__c = :loggedInUserProfileName]) 
                {
                    configSettingsMap2.put(dcs2.External_Id_AGN__c,dcs2);
                }   

               if ((dcrRecordType == 'HCO_Insert_Company_Managed' || dcrRecordType == 'HCO_Update_Company_Managed' ||
                     dcrRecordType == 'HCP_Insert_Company_Managed' || dcrRecordType == 'HCP_Update_Company_Managed'))
                {
                   
                    cr.Auto_Approved_AGN__c = loggedInUser.DCR_Self_Approved__c;
                    String loggedInUserKeyWithBU2 = cr.Country_Code_AGN__c + '_' +userBU + '_' + loggedInUserProfileName;
                    String loggedInUserKeyWithOutBU2  = cr.Country_Code_AGN__c + '_' +'ZZ' + '_' + loggedInUserProfileName;
                    //Loop over config settings.
                    for (String dcrsetting : configSettingsMap2.keySet())
                    {
                        if(configSettingsMap2.containsKey(loggedInUserKeyWithBU2)) // BU match found 
                        {
                            system.debug('4========BU match=========');
                            if (cr.Auto_Approved_AGN__c == False && configSettingsMap2.get(loggedInUserKeyWithBU2).Local_Admin_Approved_AGN__c == True){
                                cr.DCR_Approver_AGN__c = configSettingsMap2.get(loggedInUserKeyWithBU2).Local_Approver_AGN__c;
                            }
                            if (cr.Auto_Approved_AGN__c == False && configSettingsMap2.get(loggedInUserKeyWithBU2).Manager_Approved_AGN__c == True)
                            {
                                cr.DCR_Approver_AGN__c = loggedInUser.ManagerId;
                            }
                            if (cr.Auto_Approved_AGN__c == True &&  (dcrId == null || cr.CreatedById == UserInfo.getUserId()))
                            {
                                cr.DCR_Approver_AGN__c = UserInfo.getUserId();
                            }
                        }
                        // BU specific Approver setting NOT found in Config Setting . Hence pick up the one with ZZ
                        else if (configSettingsMap2.containsKey(loggedInUserKeyWithOutBU2))
                        {
                            system.debug('5========BU dont match=========');
                            if (cr.Auto_Approved_AGN__c == False && configSettingsMap2.get(loggedInUserKeyWithOutBU2).Local_Admin_Approved_AGN__c == True){
                                cr.DCR_Approver_AGN__c = configSettingsMap2.get(loggedInUserKeyWithOutBU2).Local_Approver_AGN__c;
                            }
                            if (cr.Auto_Approved_AGN__c == False && configSettingsMap2.get(loggedInUserKeyWithOutBU2).Manager_Approved_AGN__c == True)
                            {
                                cr.DCR_Approver_AGN__c = loggedInUser.ManagerId;
                            }
                            if (cr.Auto_Approved_AGN__c == True &&  (dcrId == null || cr.CreatedById == UserInfo.getUserId()))
                            {
                                cr.DCR_Approver_AGN__c = UserInfo.getUserId();
                            }
                        }
                        else
                        {
                            system.debug('===============No DCR Admin settings found==================');
                        }
                    }             
                }
                else
                {
                    cr.Auto_Approved_AGN__c = false;
                }
            }
            //END - R008 - Req.961
     
            if((cr.CreatedById == loggedInUser.Id && dcrId != null) || dcrId == null ){
                
                /*** Submission Validations ***/
                if(isBusinessAccountChange && cr.Account_AGN__c == cr.Primary_Business_Accnt_AGN__c ){
                    cr.Request_Status_AGN__c = 'Processing';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.DCR_Same_Parent_Account));
                    // 'Primary Parent Business Account cannot be same as the Business Account selected in the DCR.')); 
                    return null;
                }
                
                if(isPersonAccountAdd && (cr.Primary_Affiliation_AGN__c == null || cr.Primary_Affiliation_AGN__c == 'No') && cr.Is_Child_DCR_AGN__c == false){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.DCR_No_Primary_Affiliation));
                    // 'A Person Account should have at least one Primary Affiliated Business Account.')); 
                    return null;
                }
                /*
                //External ID check validation - Person/Buisness Account Create
                */
               
                //Address validation
                if(isBusinessAccountChange && cr.Address_AGN__c!= null){
                    List<Address_vod__c> currentAddressAffiliation = [select Id,Primary_vod__c from Address_vod__c where
                                                                     Id = :cr.Address_AGN__c AND Account_vod__c = :cr.Account_AGN__c 
                                                                     and Primary_vod__c = true limit 1];
                    
                    if(currentAddressAffiliation.size() != 0){
                        if(currentAddressAffiliation[0].Primary_vod__c == true){
                            if(cr.Primary_Address_AGN__c == null || cr.Primary_Address_AGN__c == 'No'){  
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.DCR_Address_Error));
                                return null;
                            }
                        }
                    }
                }    
                //END - Address Validation            
               
                
                // if(cr.Auto_Approved_AGN__c == True && (dcrId == null || cr.CreatedById == UserInfo.getUserId())){
                //     cr.Request_Status_AGN__c = Accepted ;
                //     createTask = false;
                // }else{
                //     cr.Request_Status_AGN__c = Submitted;                
                // }


                try
                {               
                    if(dcrId == null){
                        //========  
                        // Only for person account change with affiliation changes
                         
                            if(isPersonAccountChange) {
                                for (w_AffiliationWrapper wrp: w_WrapperList) {
                                    if(wrp.v_selected == true){
                                        hasAffiliation = true;
                                    }
                                }
                            }
                        
                            if(isPersonAccountChange && w_WrapperList.size() == 0 && cr.Account_AGN__c == null) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.DCR_Select_Primary_Affiliation));
                                // 'A Person Account should have at least one Primary Affiliated Business Account. Please select one Primary Business Account.'
                                return null;
                            }

                            if(isPersonAccountChange && (hasAffiliation || cr.Account_AGN__c != null)) {
                               
                                System.debug('== Split DCR Section for person account change and affiliation changes ==');
                                Integer index = 0;

                                /*for (Integer i= 0; i< WrapperList.size() ; i++){
                                     if(WrapperList[i].selected == true){
                                        DCR_AGN__c affWrapperDCR = new DCR_AGN__c();
                                        affWrapperDCR = cr.clone();
                                        affWrapperDCR.Account_AGN__c = WrapperList[i].accDetails.Parent_Account_vod__c;
                                        affWrapperDCR.Primary_Affiliation_AGN__c = WrapperList[i].primaryAffiliation;
                                        affWrapperDCR.Work_Status_AGN__c = WrapperList[i].accDetails.Work_Status_AGN__c;
                                        affWrapperDCR.Role_AGN__c = WrapperList[i].accDetails.OK_Role__c;
                                        affWrapperDCR.Delete_Affiliation_AGN__c = WrapperList[i].deleteAffiliation;
                                        affWrapperDCR.DCR_Type_AGN__c = 'HCP Affiliation';
                                        idcr.add(affWrapperDCR);
                                        affWrapperDCR = null;
                                    }
                                }*/
                                for (Integer i= 0; i< w_WrapperList.size() ; i++){
                                     if(w_WrapperList[i].v_selected == true){
                                        DCR_AGN__c affWrapperDCR = new DCR_AGN__c();
                                        affWrapperDCR = cr.clone();
                                        affWrapperDCR.Account_AGN__c = w_WrapperList[i].v_parentAccount;
                                        affWrapperDCR.Primary_Affiliation_AGN__c = w_WrapperList[i].v_primaryAffiliation;
                                        affWrapperDCR.Work_Status_AGN__c = w_WrapperList[i].v_workStatus;
                                        affWrapperDCR.Role_AGN__c = w_WrapperList[i].v_okRole;
                                        affWrapperDCR.Delete_Affiliation_AGN__c = w_WrapperList[i].v_deleteAffiliation;
                                        affWrapperDCR.DCR_Type_AGN__c = 'HCP Affiliation';
                                        idcr.add(affWrapperDCR);
                                        affWrapperDCR = null;
                                    }
                                }
                                /*if (otherAff != null){
                                    DCR_AGN__c otherAffDCR = new DCR_AGN__c();
                                    otherAffDCR = cr;
                                    if(otherAff.selected == true){
                                        otherAffDCR.Account_AGN__c = otherAff.accDetails.Parent_Account_vod__c;
                                        otherAffDCR.Primary_Affiliation_AGN__c = otherAff.primaryAffiliation;
                                        otherAffDCR.Work_Status_AGN__c = otherAff.accDetails.Work_Status_AGN__c;
                                        otherAffDCR.Role_AGN__c = otherAff.accDetails.OK_Role__c;
                                        otherAffDCR.Delete_Affiliation_AGN__c = otherAff.deleteAffiliation;
                                        if (otherAff.primaryAffiliation == 'Yes')
                                            index = index + 1;
                                        idcr.add(otherAffDCR);
                                    }
                                }*/
                                if (w_otherAff != null){
                                    DCR_AGN__c otherAffDCR = new DCR_AGN__c();
                                    otherAffDCR = cr;
                                    //if(w_otherAff.v_selected == true){
                                        otherAffDCR.Account_AGN__c = w_otherAff.v_parentAccount;
                                        otherAffDCR.Primary_Affiliation_AGN__c = w_otherAff.v_primaryAffiliation;
                                        otherAffDCR.Work_Status_AGN__c = w_otherAff.v_workStatus;
                                        otherAffDCR.Role_AGN__c = w_otherAff.v_okRole;
                                        otherAffDCR.Delete_Affiliation_AGN__c = w_otherAff.v_deleteAffiliation;
                                        if (w_otherAff.v_primaryAffiliation == 'Yes')
                                            index = index + 1;
                                        idcr.add(otherAffDCR);
                                    //}
                                }
                                if (idcr.size() > 0) {
                                    //BEGIN- Check Primary Affiliation Count
                                    Boolean isPrimaryAffSelected = false ;
                                    List<Child_Account_vod__c> ca_vod = new List<Child_Account_vod__c>([SELECT Id, Parent_Account_vod__c,Child_Account_vod__c, Primary_vod__c 
                                                                    FROM Child_Account_vod__c WHERE Child_Account_vod__c = :cr.Contact_AGN__c
                                                                    AND Primary_vod__c = :System.Label.Common_Yes_vod]);
                                    for (DCR_AGN__c pAffcheck : idcr){
                                        if (ca_vod.size() > 0){
                                            if (ca_vod[0].Parent_Account_vod__c == pAffcheck.Account_AGN__c){
                                                isPrimaryAffSelected = true; 
                                            }
                                        }
                                      
                                        //Amlan
                                        if(pAffcheck.Primary_Affiliation_AGN__c == 'Yes' && pAffcheck.Delete_Affiliation_AGN__c == false){
                                            pAffCount++;
                                        }
                                    }
                                    if(isPrimaryAffSelected == false && ca_vod.size() > 0){
                                        pAffCount ++;
                                    }
                                    //END- Check Primary Affiliation Count
                                    //BEGIN - Affiliation validation
                                    System.debug('== pAffCount ==>'+pAffCount + '== pAffDelCheck ==>'+pAffDelCheck);
                                    if(pAffCount < 1){
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.DCR_Select_Primary_Affiliation));
                                        // 'A Person Account should have at least one Primary Affiliated Business Account. Please select one Primary Business Account.'
                                        return null;
                                    }
                                    else if(pAffCount > 1){
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.DCR_Multiple_Primary_Affiliation));
                                        // 'Person Account should not have multiple Primary Affiliation'
                                        return null;
                                    }
                                    
                                    // Updating DCR Status value on Submission
                                    for(DCR_AGN__c updDcrStatus : idcr) {
                                        if(updDcrStatus.Auto_Approved_AGN__c == True && (dcrId == null || updDcrStatus.CreatedById == UserInfo.getUserId())){
                                            updDcrStatus.Request_Status_AGN__c = Accepted ;
                                            createTask = false;
                                        }else{
                                            updDcrStatus.Request_Status_AGN__c = Submitted;                
                                        }
                                    }

                                    //END - Affiliation validation
                                    baseDCR = idcr[0];
                                    baseDCR.DCR_Type_AGN__c = 'Base HCP Affiliation'; // Product Metrics will be tagged to this DCR record.
                                    
                                    
                                    //Updating null checkbox fields
                                    baseDCR.Appt_Required_AGN__c = (baseDCR.Appt_Required_AGN__c == null ? false : baseDCR.Appt_Required_AGN__c);
                                    baseDCR.Billing_AGN__c = (baseDCR.Billing_AGN__c == null ? false : baseDCR.Billing_AGN__c);
                                    baseDCR.Business_AGN__c = (baseDCR.Business_AGN__c == null ? false : baseDCR.Business_AGN__c);
                                    baseDCR.Home_AGN__c = (baseDCR.Home_AGN__c == null ? false : baseDCR.Home_AGN__c);
                                    baseDCR.Mailing_AGN__c = (baseDCR.Mailing_AGN__c == null ? false : baseDCR.Mailing_AGN__c);
                                    baseDCR.Shipping_AGN__c = (baseDCR.Shipping_AGN__c == null ? false : baseDCR.Shipping_AGN__c);
                                    baseDCR.Avocis_placed_AGN__c = (baseDCR.Avocis_placed_AGN__c == null ? false : baseDCR.Avocis_placed_AGN__c);
                                    

                                    insert baseDCR;
                                    idcr.remove(0);
                                    List<DCR_AGN__c> listdcr =  new List<DCR_AGN__c>();
                                    if (idcr.size() > 0){
                                        for(DCR_AGN__c affdcr : idcr)
                                        {
                                            affdcr.Parent_DCR_ID_AGN__c=baseDCR.Id;
                                            listdcr.add(affdcr);
                                        }
                                        insert listdcr;
                                    }
                                    if (baseDCR.Id != null)
                                        insertDCRProductMetrics(baseDCR );
                                }
                            }
                        // For other cases excluding person account change with affiliation
                        else {
                            System.debug('== No-Split DCR Section excluding person account change with affiliation ==');
                            
                            // Updating DCR Status value on Submission
                            if(cr.Auto_Approved_AGN__c == True && (dcrId == null || cr.CreatedById == UserInfo.getUserId())){
                                cr.Request_Status_AGN__c = Accepted ;
                                createTask = false;
                            }else{
                                cr.Request_Status_AGN__c = Submitted;                
                            }

                            //Updating null checkbox fields
                            cr.Appt_Required_AGN__c = (cr.Appt_Required_AGN__c == null ? false : cr.Appt_Required_AGN__c);
                            cr.Billing_AGN__c = (cr.Billing_AGN__c == null ? false : cr.Billing_AGN__c);
                            cr.Business_AGN__c = (cr.Business_AGN__c == null ? false : cr.Business_AGN__c);
                            cr.Home_AGN__c = (cr.Home_AGN__c == null ? false : cr.Home_AGN__c);
                            cr.Mailing_AGN__c = (cr.Mailing_AGN__c == null ? false : cr.Mailing_AGN__c);
                            cr.Shipping_AGN__c = (cr.Shipping_AGN__c == null ? false : cr.Shipping_AGN__c);
                            cr.Avocis_placed_AGN__c = (cr.Avocis_placed_AGN__c == null ? false : cr.Avocis_placed_AGN__c);

                            insert cr;
                            if (cr.Id != null)
                                insertDCRProductMetrics(cr);
                            }
                       
                       //*************Child DCR Logic********************Business Account Add*****************************
                        if (isBusinessAccountAdd){
                            processCompositeDCRforBusinessAccount(cr, addExistingCHCO, addExistingCHCP, addNewCHCO, addNewCHCP);
                            //system.debug('value of chkAccMatch inside isBusinessAccountAdd '+chkAccMatch);
                        }  
                        if(chkAccMatchHCP==1 || chkAccMatchHCO==1)
                        {
                        
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.MSL_Country_Code_Error));
                         return null;
                        }
                       //************************ DCR Task Creation After Submission *******************************
                       // Person Account - Change Request
                        if(isPersonAccountChange && hasAffiliation) {
                            if(createTask){
                                createTaskforApprover(baseDCR);
                                for (DCR_AGN__c objDCR : idcr)
                                    createTaskforApprover(objDCR);
                            }     
                        }
                        // Business Account - Add Request
                        else if(isBusinessAccountAdd){
                            // Main Parent CR
                                createTaskforApprover(cr);
                            // Child CR
                            if(addExistingCHCP.size() > 0){
                                createTaskforApprover(addExistingCHCP[0]);
                            }
                            if(addExistingCHCO.size() > 0){
                                createTaskforApprover(addExistingCHCO[0]);
                            }       
                            if(addNewCHCO.size() > 0){
                                createTaskforApprover(addNewCHCO[0]);
                            }      
                            if(addNewCHCP.size() > 0){
                                createTaskforApprover(addNewCHCP[0]);
                            }        
                                       
                        }
                    } // CR Update for All other cases where dcr != null and Task Creation
                    else{
                        // Updating DCR Status value on Submission
                        if(cr.Auto_Approved_AGN__c == True && (dcrId == null || cr.CreatedById == UserInfo.getUserId())){
                            cr.Request_Status_AGN__c = Accepted ;
                            createTask = false;
                        }else{
                            cr.Request_Status_AGN__c = Submitted;                
                        }

                        update cr;
                        updateDCRProductMetrics(cr);
                        if(createTask)
                            createTaskforApprover(cr);
                    }
                }catch(System.DMLException e){
                     if (sp != null) 
                        Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.DML_Error_Msg));
                    //'The Request faced an error during submission. Please contact your administrator.')); 
                    system.debug('DML EXCEPTION during submit(): '+e);
                    return null;
                }catch(System.Exception e1){
                     if (sp != null) 
                        Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.DML_Error_Msg));
                    //'The Request faced an error during submission. Please contact your administrator.')); 
                    system.debug('EXCEPTION during submit(): '+e1);
                    return null;
                }

                //*************************************************************
                 
                if(isPersonAccountChange && hasAffiliation){
                     processDCRTarget(baseDCR,dcrRecordType);
                     for (DCR_AGN__c dRec : idcr){
                         processDCRTarget(dRec,dcrRecordType);
                     }
                }
                else{
                    processDCRTarget(cr,dcrRecordType);
                }
                if (addExistingCHCO.size() > 0)
                {
                    for (DCR_AGN__c cr1 : addExistingCHCO)
                    {
                        dcrRecordType = dcrRTMapByName.get(cr1.RecordTypeId);
                        system.debug('calling processDCRTarget for exhco');
                        processDCRTarget(cr1,dcrRecordType);
                    }
                }
                if (addExistingCHCP.size() > 0)
                {
                    for (DCR_AGN__c cr2 : addExistingCHCP)
                    {
                        dcrRecordType = dcrRTMapByName.get(cr2.RecordTypeId);
                        system.debug('calling processDCRTarget for exhcp');
                        processDCRTarget(cr2,dcrRecordType);
                    }
                }
                if (addNewCHCO.size() > 0){
                    for (DCR_AGN__c cr3 : addNewCHCO)
                    {
                        dcrRecordType = dcrRTMapByName.get(cr3.RecordTypeId);
                        system.debug('calling processDCRTarget for newhco');
                        processDCRTarget(cr3,dcrRecordType);
                    }
                }
                if (addNewCHCP.size() > 0){
                    for (DCR_AGN__c cr4 : addNewCHCP)
                    {
                        dcrRecordType = dcrRTMapByName.get(cr4.RecordTypeId);
                        system.debug('calling processDCRTarget for newhcp');
                        processDCRTarget(cr4,dcrRecordType);
                    }
                }
                //***********************************************************
                if(w_WrapperList != null) {
                    Schema.DescribeSObjectResult destination = DCR_AGN__c.SObjectType.getDescribe();
                    return new PageReference('/'+destination.getKeyPrefix()).setRedirect(true);
                }
                else{
                    return new PageReference('/apex/AGN_DCR?id='+cr.Id).setRedirect(true);
                }
                   
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.DCR_Submitter_Error));
                //'Only the Requestor can submit the Request.'));
                return null;
            } 
        }

        public PageReference cancel() {
            Schema.DescribeSObjectResult destination = DCR_AGN__c.SObjectType.getDescribe();
            return new PageReference('/'+destination.getKeyPrefix()).setRedirect(true);
        }
       
        public void processCompositeDCRforBusinessAccount(DCR_AGN__c cr, List<DCR_AGN__c> addExistingCHCO, List<DCR_AGN__c> addExistingCHCP, List<DCR_AGN__c> addNewCHCO, List<DCR_AGN__c> addNewCHCP)
        {
            system.debug('inside ###########processCompositeDCRforBusinessAccount############');
            DCR_AGN__c pRec = [select Auto_Approved_AGN__c,TAAF_AGN__c,DCR_Approver_AGN__c,
                               RecordTypeId,RecordType.Name,Account_Name_AGN__c,P_Business_Account_Id_AGN__c,
                               Request_Status_AGN__c,Provisional_Contact_AGN__c,Country_Code_AGN__c
                               from DCR_AGN__c 
                               where id =:cr.id];

            //**********Add Existing HCP Logic**********************
            chkAccMatchHCP =   processAddExistingCHCP (cr,addExistingCHCP,pRec); 
            //**********Add New HCP Logic**********************
            processAddNewCHCP(cr,addNewCHCP,pRec);  
            //****************Add New Child HCO*********************  
            processAddNewCHCO(cr,addNewCHCO,pRec);   
            //**************** Add Existing Child HCO*********************
            chkAccMatchHCO = processAddExistingCHCO(cr,addExistingCHCO,pRec);
        }
        //************************End of Process buisness account method - Composite DCR*****************************************************************
        public void createTaskforApprover(DCR_AGN__c dcr){
            system.debug('===== Inside [createTaskforApprover] =====');
            Task newTask = new Task();
            newTask.WhatId = dcr.id;
            newTask.ownerId = dcr.DCR_Approver_AGN__c;
            newTask.Subject = dcr_task_subject;
            newTask.priority= 'Normal';
            newTask.status = 'Not Started';
            newTask.isReminderSet = True;
            try{
                //system.debug('Inside create task-------->'+newTask);
                insert newTask;
            }
            catch(System.DmlException e){
                system.debug(e.getMessage());
            }
        }
        // Method to delete task created for Approver in case of Send back for Revision
         public void deleteTaskforApprover(DCR_AGN__c dcr){
            system.debug('===== Inside [deleteTaskforApprover] =====');
            List<Task> delTask = new List<Task>([SELECT id FROM Task where WhatId = :dcr.id]);
            try{
                //system.debug('Inside delete task-------->'+newTask);
                if (delTask.size() > 0 )
                    delete delTask;
            }
            catch(System.DmlException e){
                system.debug(e.getMessage());
            }
        }
        
        //R007 - modified for Product Metrics edit from Approval screen
        public PageReference approveRequest(){
            system.debug('===== Inside [approveRequest] =====');
            if (!cr.Has_Product_Metrics__c)
            {
                //Approve Req Change
                if(cr.Is_Child_DCR_AGN__c==true && CR.Request_Entity_AGN__c=='HCP' && cr.Request_Type_AGN__c=='Change')
                { 
                    list<DCR_AGN__c>  parentdcr= new list<DCR_AGN__c>([select id,P_Business_Account_Id_AGN__c,Request_Status_AGN__c from DCR_AGN__c where id=:cr.Parent_DCR_ID_AGN__c]);      
                    if(parentdcr[0].Request_Status_AGN__c=='Accepted')
                    {
                        cr.Account_AGN__c= parentdcr[0].P_Business_Account_Id_AGN__c;
                        cr.Primary_Affiliation_AGN__c='No';
                        cr.Request_Status_AGN__c = 'Accepted' ;     
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.DCRChild_Approval_Error));
                        return null;
                    }
                }
                else if(cr.Is_Child_DCR_AGN__c==true && CR.Request_Entity_AGN__c=='HCP' && cr.Request_Type_AGN__c=='Add')
                {  
                    list<DCR_AGN__c>  parentdcr= new list<DCR_AGN__c>([select id,P_Business_Account_Id_AGN__c,Request_Status_AGN__c from DCR_AGN__c where id=:cr.Parent_DCR_ID_AGN__c]); 
                    if(parentdcr[0].Request_Status_AGN__c=='Accepted')
                    {
                        cr.Account_AGN__c= parentdcr[0].P_Business_Account_Id_AGN__c;
                        cr.Primary_Affiliation_AGN__c='Yes';
                        cr.Request_Status_AGN__c = 'Accepted' ;     
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.DCRChild_Approval_Error));
                        return null;
                    }
                }
                else if(cr.Is_Child_DCR_AGN__c==true && CR.Request_Entity_AGN__c=='HCO'  && cr.Request_Type_AGN__c=='Add')
                {
                    list<DCR_AGN__c>  parentdcr= new list<DCR_AGN__c>([select id,P_Business_Account_Id_AGN__c,Request_Status_AGN__c from DCR_AGN__c where id=:cr.Parent_DCR_ID_AGN__c]); 
                    if(parentdcr[0].Request_Status_AGN__c=='Accepted')
                    {
                        cr.Primary_Business_Accnt_AGN__c= parentdcr[0].P_Business_Account_Id_AGN__c;
                        cr.Primary_Affiliation_AGN__c='Yes';
                        cr.Request_Status_AGN__c = 'Accepted' ;     
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.DCRChild_Approval_Error));
                        return null;
                    }
                }
                else if(cr.Is_Child_DCR_AGN__c==true && CR.Request_Entity_AGN__c=='HCO'  && cr.Request_Type_AGN__c=='Change')
                {
                    list<DCR_AGN__c>  parentdcr= new list<DCR_AGN__c>([select id,P_Business_Account_Id_AGN__c,Request_Status_AGN__c from DCR_AGN__c where id=:cr.Parent_DCR_ID_AGN__c]); 
                    if(parentdcr[0].Request_Status_AGN__c=='Accepted')
                    {
                       // cr.Primary_Business_Accnt_AGN__c= parentdcr[0].P_Business_Account_Id_AGN__c;
                        cr.Primary_Affiliation_AGN__c='No';
                        cr.Request_Status_AGN__c = 'Accepted' ;     
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.DCRChild_Approval_Error));
                        return null;
                    }
                }
              //-----------------------------------------------child dcr-----------------------------------------------------  
                else
                {
                   cr.Request_Status_AGN__c = Accepted ;  
                }
               
                //end
                try{
                    update cr;
                }catch(System.DMLException e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Approval_Error));
                    //'The Request faced an error during approval. Please contact your administrator.'));  
                    system.debug('DML EXCEPTION during approveRequest(): '+e);
                    return null;
                }catch(System.Exception e1){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Approval_Error));
                    // 'The Request faced an error during approval. Please contact your administrator.'));  
                    system.debug('EXCEPTION during approveRequest(): '+e1);
                    return null;
                }
            }      
            else
            {
                //call product metric method
                //Change in Request
                if(cr.Is_Child_DCR_AGN__c==true && CR.Request_Entity_AGN__c=='HCP')
                {
                    list<DCR_AGN__c>  parentdcr= new list<DCR_AGN__c>([select id,P_Business_Account_Id_AGN__c,Request_Status_AGN__c from DCR_AGN__c where id=:cr.Parent_DCR_ID_AGN__c]);   
                    if(parentdcr[0].Request_Status_AGN__c=='Accepted')
                    {
                        cr.Account_AGN__c= parentdcr[0].P_Business_Account_Id_AGN__c;
                        cr.Primary_Affiliation_AGN__c='Yes';
                        cr.Request_Status_AGN__c = Accepted ;     
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.DCRChild_Approval_Error));
                        return null;
                    }
                }
                //call product metric method
                updateDCRProductMetrics(cr);
                system.debug('===== Back from [updateDCRProductMetrics] =====');
                cr.Request_Status_AGN__c = Accepted ;
                //end
                try{
                        update cr;
                    }
                catch(System.DMLException e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Approval_Error));
                    //'The Request faced an error during approval. Please contact your administrator.'));  
                    system.debug('DML EXCEPTION during approveRequest(): '+e);
                    return null;
                }catch(System.Exception e1){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Approval_Error));
                    // 'The Request faced an error during approval. Please contact your administrator.'));  
                    system.debug('EXCEPTION during approveRequest(): '+e1);
                    return null;
                }
            }
            //return new PageReference('/apex/AGN_DCR?id='+cr.Id).setRedirect(true);
            processDCRTarget(cr,dcrRecordType);
            Schema.DescribeSObjectResult destination = DCR_AGN__c.SObjectType.getDescribe();
            return new PageReference('/'+destination.getKeyPrefix()).setRedirect(true);  
        }
        
          //R007 - Apurba
          public PageReference revisionRequest(){
            system.debug('===== Inside [revisionRequest] =====');
            cr.Request_Status_AGN__c = 'Send Back for Revision' ;
            cr.Is_Reviewed_AGN__c = true;
            boolean deleteTask = True;
            enableSubmit =true;
            viewReadOnly = false;
            viewReadWrite = true;
            try{
                update cr;
                //R008 - Call DCR Process Method
               processDCRTarget(cr,dcrRecordType);
            }catch(System.DMLException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Revision_Comments_Req));
                system.debug('DML EXCEPTION during approveRequest(): '+e); 
                return null;
            }catch(System.Exception e1){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Revision_Comments_Req));
                system.debug('EXCEPTION during approveRequest(): '+e1);
                return null;
            }
            processDCRTarget(cr,dcrRecordType);
            if(deleteTask)
              deleteTaskforApprover(cr);
            
            return new PageReference('/apex/AGN_DCR?id='+cr.Id).setRedirect(true);
        } 
        //End
        
        public PageReference rejectRequest(){
            system.debug('===== Inside [rejectRequest] =====');
            if (cr.Approver_Comment_AGN__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Approver_Comments_Req));
                //'Please provide comments in Approver Comment field to reject a Request.'));  
                return null;            
            }else{
                cr.Request_Status_AGN__c = Rejected;
                try{
                    update cr;
                  
                }catch(System.DMLException e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Rejection_Error));
                    //'The Request faced an error during rejection. Please contact your administrator.'));  
                    system.debug('DML EXCEPTION during rejectRequest(): '+e);
                    return null;
                }catch(System.Exception e1){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Rejection_Error));
                    //'The Request faced an error during rejection. Please contact your administrator.'));  
                    system.debug('EXCEPTION during rejectRequest(): '+e1);
                    return null;
                }
                 //R008 - Call DCR Process Method
                 processDCRTarget(cr,dcrRecordType);
                 return new PageReference('/apex/AGN_DCR?id='+cr.Id).setRedirect(true);
            }
        }
        
        public void insertcDCRProductMetrics(DCR_AGN__c cr) 
          {
             system.debug('==========================Inside [insertcDCRProductMetrics] ================'); 
            if(selectcDCRProductMetrics(cr) > 0) {
                system.debug('value of cr'+cr.Name);
                cr.Has_Product_Metrics__c=true;
                system.debug('Going to insert value of selectedcDCRProductMetricsList    '+selectedDCRProductMetricsList);
                insert selectedDCRProductMetricsList;
            }
         }
        
        
        public integer selectcDCRProductMetrics(DCR_AGN__c par)
        {
               system.debug('value of par'+par);
            system.debug('============================ Inside [selectchildProductMetrics]========================= =====');
            
            List<integer> remIdx = new List<integer>();
            integer idx;
            
            system.debug('value of cdcrProdMetrWrappers'+cdcrProdMetrWrappers);
            system.debug('value of size of dcrProdMetrWrappers'+cdcrProdMetrWrappers.size());
           
            for (DCRProductMetricsWrapper pmw: cdcrProdMetrWrappers){
                if (pmw.selected){
                    pmw.dcrProductMetrics.DCR_AGN__c = par.id;
                    selectedDCRProductMetricsList.add(pmw.dcrProductMetrics);
                    
                    idx = 0;
                    for(DCR_Product_Metrics_AGN__c pm: productMetricsRemoveList) {
                        if(pm.Product_AGN__c == pmw.dcrProductMetrics.Product_AGN__c) {
                            remIdx.add(idx);
                        }
                        else {
                            idx++;
                        }
                    }
                }
            }
          
            for(integer i: remIdx) {
                productMetricsRemoveList.remove(i);
            }
            return(selectedDCRProductMetricsList.size());
        }
        
        
        public void typeControl()
        { 
            AccountSubtypePicklistValuesToShow = new list<SelectOption>();
            List <DCR_Picklist_Values_AGN__c> custPickVal_AccountSubtype_List = DCR_Picklist_Values_AGN__c.getAll().values();
            for(DCR_Picklist_Values_AGN__c pvl : custPickVal_AccountSubtype_List) 
            {
                if(pvl.Country_Code_AGN__c == loggedInUser.Country_Code__c && cr.Account_Type_AGN__c!=NULL) 
                {
                    if(pvl.Account_Type_AGN__c.contains(cr.Account_Type_AGN__c))
                    {
                      AccountSubtypePicklistValuesToShow.add(new SelectOption(pvl.Base_Value_AGN__c,pvl.Translated_Value_AGN__c));
                    
                    }
                }
            } 
        }
        
        // Load Custom Picklist Items in Account Subtype
        public List<SelectOption> setCustomPicklistItems(List <DCR_Picklist_Values_AGN__c> CustomPicklistValuesList, String selectedCountryCode) {
            picklistValuesToShow = new List<SelectOption>();
            
            for(DCR_Picklist_Values_AGN__c pvl : CustomPicklistValuesList) {
                if(pvl.Country_Code_AGN__c == selectedCountryCode) {
                    picklistValuesToShow.add(new SelectOption(pvl.Base_Value_AGN__c,pvl.Translated_Value_AGN__c));
                }
            }
            return picklistValuesToShow;
        }

        public void setsubCustomPicklistItems(List <SelectOption> picklistValuesToShow , DCR_AGN__c cr)
        {
            if(cr.Type_AGN__c != null)
                picklistValuesToShow.add(new SelectOption(cr.Type_AGN__c,cr.Type_AGN__c));
        }
       
        public class wrapTarget {
            public String dcrField  {get;set;}
            public String tgtObject {get;set;}
            public String tgtField  {get;set;}
           
            public wrapTarget(String dFld,String tObj,String tFld) {
                dcrField  = dFld;
                tgtObject = tObj;
                tgtField  = tFld;
            }
        }
       
        // Isolate selected DCR Product Metrics for insert
        public integer selectDCRProductMetrics(DCR_AGN__c par){
            system.debug('===== Inside [selectDCRProductMetrics] =====');
            List<integer> remIdx = new List<integer>();
            integer idx;
            
            for (DCRProductMetricsWrapper pmw: dcrProdMetrWrappers){
                if (pmw.selected){
                    pmw.dcrProductMetrics.DCR_AGN__c = par.id;
                    selectedDCRProductMetricsList.add(pmw.dcrProductMetrics);
                    
                    idx = 0;
                    for(DCR_Product_Metrics_AGN__c pm: productMetricsRemoveList) {
                        if(pm.Product_AGN__c == pmw.dcrProductMetrics.Product_AGN__c) {
                            remIdx.add(idx);
                        }
                        else {
                            idx++;
                        }
                    }
                }
            }
            for(integer i: remIdx) {
                productMetricsRemoveList.remove(i);
            }
            return(selectedDCRProductMetricsList.size());
        }
        
        public string clickedProductId { get; set; }
        public string clickedProductName { get; set; }
        
        
        public void addToProductMetricsRemoveList() {
            system.debug('===== Inside [addToProductMetricsRemoveList] =====');
            productsForRemoveList.add(clickedProductId);
        }
        
        public void insertDCRProductMetrics(DCR_AGN__c cr) {
            system.debug('===== Inside [insertDCRProductMetrics] =====');
            if(selectDCRProductMetrics(cr) > 0) {
                insert selectedDCRProductMetricsList;
            }
        }
        
        public void updateDCRProductMetrics(DCR_AGN__c cr) {
            system.debug('===== Inside [updateDCRProductMetrics] =====');
            productMetricsRemoveList = [SELECT Id,Product_AGN__c,Product_AGN__r.Name FROM DCR_Product_Metrics_AGN__c WHERE DCR_AGN__c = :cr.id AND Product_AGN__c IN :productsForRemoveList];
            selectDCRProductMetrics(cr);
            system.debug('===== Back from [selectDCRProductMetrics] ===== selectedDCRProductMetricsList.size() ==>> ' + selectedDCRProductMetricsList.size());
            if (selectedDCRProductMetricsList.size () > 0) {
                upsert selectedDCRProductMetricsList;
                system.debug('===== [updateDCRProductMetrics] selectedDCRProductMetricsList ==>> ' + selectedDCRProductMetricsList);
                }
            if (productMetricsRemoveList.size () > 0)
                delete productMetricsRemoveList;
        }
        
        public class DCRProductMetricsWrapper {
            public DCR_Product_Metrics_AGN__c dcrProductMetrics {get; set;}
            public boolean selected {get; set;}
            public string selectedCheckbox {get{return ((selected == true) ? 'checked' : null);}}
            public string dcrProduct {get; set;}
            public Id dcrProductId {get; set;}
            public string dcrDetailProductName {get; set;}
            
            public DCRProductMetricsWrapper(Product_vod__c userProd) {
                dcrProductMetrics = new DCR_Product_Metrics_AGN__c();
                dcrProductMetrics.Product_AGN__c = userProd.id;
                dcrProductMetrics.Detail_Group_AGN__c = getProductGroupId(userProd.id);
                dcrProduct = userProd.name;
                selected = false;
                dcrProductId = userProd.id;
                dcrDetailProductName = getProductGroupName(userProd.id);
            }
        }
        public static Id getProductGroupId(id prodId) {
            system.debug('===== Inside [getProductGroupId] =====');
            for(Product_Group_vod__c prdGrp: productGroupList) {
                if(prdGrp.Product_vod__c == prodId) {
                    return(prdGrp.Product_Catalog_vod__c);
                }
            }
            return(null);
        }
        
        public static string getProductGroupName(id prodId) {
            system.debug('===== Inside [getProductGroupName] =====');
            for(Product_Group_vod__c prdGrp: productGroupList) {
                if(prdGrp.Product_vod__c == prodId) {
                    return(prdGrp.Product_Catalog_vod__r.Name);
                }
            }
            return(null);
        }

        Public Class AffiliationWrapper{
            public Child_Account_vod__c accDetails {get; set;}
            public String fullAddress {get; set;}
            public boolean selected {get; set;}
            public String primaryAffiliation {get; set;}
            public boolean deleteAffiliation {get; set;}
            public Decimal beds {get; set;}
            public Decimal department {get; set;}
            public String speciality1 {get; set;}
            public String agnSpecialty {get; set;}
           
            public AffiliationWrapper(){}

            Public AffiliationWrapper(Child_Account_vod__c accRec, Address_vod__c addr){
                accDetails = accRec;
                fullAddress = addr.Name+ ' ' +
                    (addr.Address_line_2_vod__c == null ? '' : addr.Address_line_2_vod__c) + ' ' +
                    (addr.Address_line_3_AGN__c == null ? '' : addr.Address_line_3_AGN__c) + ' ' +
                    (addr.City_vod__c == null ? '' : addr.City_vod__c) + ' ' +
                    (addr.Zip_vod__c == null ? '' : addr.Zip_vod__c) + ' ' +
                    (addr.Brick_vod__c == null ? '' : addr.Brick_vod__c) + ' ' +
                    (addr.State_vod__c == null ? '' : addr.State_vod__c) + ' ' +
                    (addr.Country_vod__c == null ? '' : addr.Country_vod__c) ;
                selected = false;
                //primaryAffiliation = accRec.Network_Primary_vod__c == true ? 'Yes' : 'No';
                
                if(accRec.Child_Account_vod__r.Primary_Parent_vod__c == accRec.Parent_Account_vod__c)
                    primaryAffiliation = 'Yes';
                else
                    primaryAffiliation = 'No';
                deleteAffiliation = false;
            }  
        }
       
        //R008.1 - Apurba
         Public Class w_AffiliationWrapper{
            //child acc
            public string v_childAccount {get;set;}
            public string v_parentAccount {get;set;}
            public string v_parentAccountName {get;set;}
            public string v_workStatus {get;set;}
            public string v_okRole {get;set;}
            public String v_childPrimaryParent {get;set;}
            public String v_primaryAffiliation {get; set;}
            //account
            public Decimal v_beds {get; set;}
            public String v_beds1 {get; set;}
            public Decimal v_department {get; set;}
            public String v_department1 {get; set;}
            public String v_speciality1 {get; set;}
            public String v_agnSpecialty {get; set;}
            //address
            public String v_address {get; set;}
            //save aff
            public boolean v_selected {get; set;}
            //delete aff
            public boolean v_deleteAffiliation {get; set;}
           
            public w_AffiliationWrapper(){}
            //childAccount,parentAccount,workStatus,okRole,childPrimaryParent,beds,department,speciality1,agnSpecialty,address)
            Public w_AffiliationWrapper(String childAccount,String parentAccount,String parentAccountName,String workStatus,String okRole,String childPrimaryParent,Decimal beds,Decimal department, String speciality1,String agnSpecialty, String address){
                v_childAccount = childAccount;
                v_parentAccount = parentAccount;
                v_parentAccountName = parentAccountName;
                v_workStatus = workStatus;
                v_okRole = okRole;
                v_beds = beds;
                v_department = department;
                v_speciality1 = speciality1;
                v_agnSpecialty = agnSpecialty;
                v_address = address;
                v_selected = false;
               
                //Angshu - Primary flag  
                if(childPrimaryParent == parentAccount)
                    v_primaryAffiliation = 'Yes';
                else
                    v_primaryAffiliation = 'No';
                v_deleteAffiliation = false;
            }  
        }

        //END :: R008.1

        public List<SelectOption> getOptionsYesNo() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('No',System.Label.Common_No_vod));
            options.add(new SelectOption('Yes',System.Label.Common_Yes_vod));
            return options;
        }

        // =========================== CODE TO DETECT CHANGES MADE TO ACCOUNT IN DCR =============================== 
        Public String detectChanges() {
            String accountId;
            if(isBusinessAccount) {
                accountId = cr.Account_AGN__c;
                oADR = [SELECT Id,Name,Account_vod__c,External_ID_vod__c,Controlling_Address_vod__c,Address_line_2_vod__c,Address_Line_3_AGN__c,
                        State_vod__c,City_vod__c,Zip_vod__c,Brick_vod__c,Country_Code__c,Country_vod__c,address_type_vod__c,Primary_vod__c,
                        Receptionist_Email_AGN__c,Receptionist_Name_AGN__c,Business_vod__c,Mailing_vod__c,Shipping_vod__c,Billing_vod__c,Home_vod__c,
                        Phone_vod__c,Phone_2_vod__c,Fax_vod__c,Appt_Required_vod__c,Address_status_vod__c,Controlled_Address_vod__c
                        FROM Address_vod__c WHERE id = :cr.Address_AGN__c];
                oADR_PR = [SELECT Id FROM Address_vod__c WHERE Account_vod__c = :cr.Account_AGN__c AND Primary_vod__c = true];
                oMEMB = new List<Child_Account_vod__c>();
            }
            else if(!isBusinessAccount) {
                accountId = cr.Contact_AGN__c;
                oADR = new List<Address_vod__c>();
                oMEMB = [SELECT Name,OK_Role__c,Parent_Account_vod__c,Work_Status_AGN__c,Child_Account_vod__c,Copy_Address_vod__c,Network_Primary_vod__c
                         FROM Child_Account_vod__c WHERE Child_Account_vod__c = :cr.Contact_AGN__c AND Parent_Account_vod__c = :cr.Account_AGN__c];
            }
           
            oACC = [SELECT Salutation,IsPersonAccount,FirstName,LastName,Gender_vod__c,Primary_Parent_vod__c,Account_Type__c,Consent_to_Contact_AGN__c,
                    Education_Speciality_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Email_Internal_AGN__c,PersonEmail,Fax,Fax_Internal_AGN__c,
                    PersonMobilePhone,Mobile_Internal_AGN__c,Workplace_AGN__c,Specialty_Allergan_1_AGN__c,Sub_Specialty_Allergan_AGN__c,
                    Additional_Specialties_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,Website,
                    Type_AGN__c,Consent_to_Phone_AGN__c,Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,Middle_vod__c,Do_not_send_Mail__c,KOL_vod__c,
                    RecordTypeId,Other_title_information_AGN__c,Status_AGN__c,Do_not_Visit_AGN__c,Language_vod__c,Target__c,PersonBirthdate,
                    Graduation_School_AGN__c,Graduation_Year_AGN__c,Phone_Internal_AGN__c,Calling_Name_AGN__c,Other_Name_AGN__c,Description,
                    NS_Headache_Target_Centre_AGN__c,No_Orders_vod__c,Order_Type_vod__c,Default_Order_Type_vod__c,Country_Code__c,Country_vod__c,
                    Distribution_ID_AGN__c,External_ID2_AGN__c,External_ID4_AGN__c,Physician_Registration_Reference_AGN__c,Name,Phone,Beds__c,
                    Departments__c,Patients_AGN__c,Account_Group_vod__c,Institution_Site_AGN__c,Organization_Registration_Reference_AGN__c,
                    Account_Group_AGN__c,Requested_from_DCR_AGN__c,AGN_DCR_Ref__c
                    FROM Account WHERE Id = :accountId];
           
            //AGNLabelTranslator t = new AGNLabelTranslator();
           
            String type = 'DCR_AGN__c';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> schemaFieldMap = leadSchema.getDescribe().fields.getMap();
           
            ChangeString = '<table border="1" bgcolor="#00FF00"><tr><th>Field Name</th><th>Old Value</th><th>New Value</th></tr>';
            for(String fmap : fieldMap.keyset()) {
                String dcrVal;
                String tgtVal;
                String dcrValUrl = '';
                String tgtValUrl = '';
                wrapTarget fmapTarget = fieldMap.get(fmap);
                
                if((fmapTarget.tgtObject == 'Account' || fmapTarget.tgtObject == 'Account_HCP' || fmapTarget.tgtObject == 'Account_HCO') && oACC.size()>0) {
                    if((fmapTarget.tgtObject == 'Account') || (fmapTarget.tgtObject == 'Account_HCO' && cr.Request_Entity_AGN__c == HCO) || (fmapTarget.tgtObject == 'Account_HCP' && cr.Request_Entity_AGN__c == HCP))
                    {
                        dcrVal = toString(cr.get(fmapTarget.dcrField));
                        tgtVal = toString(oACC[0].get(fmapTarget.tgtField));
                        if(oACC[0].get(fmapTarget.tgtField) instanceof Id)
                            tgtValUrl = '<a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + tgtVal + '">' + tgtVal + '</a>';
                    }
                }
                else if(fmapTarget.tgtObject == 'Address_vod__c' && oADR.size()>0 && isBusinessAccount) {
                    dcrVal = toString(cr.get(fmapTarget.dcrField));
                    tgtVal = toString(oADR[0].get(fmapTarget.tgtField));
                    if(oADR[0].get(fmapTarget.tgtField) instanceof Id)
                        tgtValUrl = '<a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + tgtVal + '">' + tgtVal + '</a>';
                }
                else if(fmapTarget.tgtObject == 'Child_Account_vod__c' && oMEMB.size()>0 && isPersonAccount) {
                    dcrVal = toString(cr.get(fmapTarget.dcrField));
                    tgtVal = toString(oMEMB[0].get(fmapTarget.tgtField));
                    if(oMEMB[0].get(fmapTarget.tgtField) instanceof Id)
                        tgtValUrl = '<a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + tgtVal + '">' + tgtVal + '</a>';
                }
                if(cr.get(fmapTarget.dcrField) instanceof Id)
                    dcrValUrl = '<a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + dcrVal + '">' + dcrVal + '</a>';
               
                if (dcrVal != tgtVal) {
                    if(tgtVal.length() == 0)
                        ChangeString += '<tr><td>' + schemaFieldMap.get(fmapTarget.dcrField).getDescribe().getLabel() + '</td><td></td><td>' + (dcrValUrl=='' ? dcrVal : dcrValUrl) + '</td></tr>';
                    else if(dcrVal.length() == 0)
                        ChangeString += '<tr><td>' + schemaFieldMap.get(fmapTarget.dcrField).getDescribe().getLabel() + '</td><td>' + (tgtValUrl=='' ? tgtVal : tgtValUrl) + '</td><td></td></tr>';
                    else
                        ChangeString += '<tr><td>' + schemaFieldMap.get(fmapTarget.dcrField).getDescribe().getLabel() + '</td><td>' + (tgtValUrl=='' ? tgtVal : tgtValUrl) + '</td><td>' + (dcrValUrl=='' ? dcrVal : dcrValUrl) + '</td></tr>';
                }
            }
            if(oMEMB.size() > 0){
                if(oMEMB[0].Network_Primary_vod__c != (cr.Primary_Affiliation_AGN__c == 'Yes'))
                    ChangeString += '<tr><td>' + schemaFieldMap.get('Primary_Affiliation_AGN__c').getDescribe().getLabel() + '</td><td>' + (oMEMB[0].Network_Primary_vod__c==true ? 'Yes' : 'No') + '</td><td>' + cr.Primary_Affiliation_AGN__c + '</td></tr>';
                if(cr.Delete_Affiliation_AGN__c)
                    ChangeString += '<tr><td>' + schemaFieldMap.get('Delete_Affiliation_AGN__c').getDescribe().getLabel() + '</td><td></td><td>Yes</td></tr>';
            }

            ChangeString = ChangeString + '</table>';
            //cr.DCR_Changes_AGN__c = ChangeString;
            if(ChangeString == '<table border="1" bgcolor="#00FF00"><tr><th>Field Name</th><th>Old Value</th><th>New Value</th></tr></table>')
                return('No Changes Found');
            else
                return (ChangeString);
        }

        // =========================== BEGIN Processing to update/insert DCR to Target Entity =============================== 
        public static void processDCRTarget(DCR_AGN__c dcr, String dcrRecordType)
        {
            
            String Accepted = 'Accepted';
            String Rejected = 'Rejected';
            String Submitted = 'Submitted';
            String Active = 'Active';
            String Inactive = 'Inactive';
            String Pending_Validation = 'Pending_Validation';
            if(dcrRecordType == 'HCO_Insert_Data_Provider_Managed' || dcrRecordType =='HCP_Insert_Data_Provider_Managed')
            {
                if(dcr.Request_Status_AGN__c == Submitted && dcr.Provisional_Contact_AGN__c == true && dcr.Is_Reviewed_AGN__c == false)
                {
                  if(dcr.Is_Child_DCR_AGN__c == false)
                    AGN_DCR_Request_Process_Class.createNewProvisionalAccount(dcr,Pending_Validation);
                  if(dcr.Is_Child_DCR_AGN__c == true)
                    AGN_DCR_Request_Process_Class.createNewProvisionalAccountCDCR(dcr,Pending_Validation);
                }  
            }
           
            if(dcrRecordType == 'HCO_Insert_Company_Managed' || dcrRecordType == 'HCP_Insert_Company_Managed')
            {   
              system.debug('value of dcr after ****************** ' +dcr.Id);  
                if(dcr.Request_Status_AGN__c == Submitted &&  dcr.Provisional_Contact_AGN__c == true)
                {
                    if(dcr.Is_Reviewed_AGN__c == false)
                    {
                      if(dcr.Is_Child_DCR_AGN__c == false)
                         AGN_DCR_Request_Process_Class.createNewProvisionalAccount(dcr,Pending_Validation);
                      if(dcr.Is_Child_DCR_AGN__c == true)
                      AGN_DCR_Request_Process_Class.createNewProvisionalAccountCDCR(dcr,Pending_Validation);
                    }
                    else
                    {
                         AGN_DCR_Request_Process_Class.updateExistingAccount(dcr,Pending_Validation,2);
                    }
                }
                if(dcr.Request_Status_AGN__c == Accepted  && dcr.Provisional_Contact_AGN__c == true)
                {
                    if((dcr.P_Person_Account_Id_AGN__c != null && dcr.Request_Entity_AGN__c == 'HCP') || (dcr.P_Business_Account_Id_AGN__c != null && dcr.Request_Entity_AGN__c == 'HCO'))
                        AGN_DCR_Request_Process_Class.updateExistingAccountStatus(dcr,Active);
                    else{
                        if(dcr.Is_Child_DCR_AGN__c == false){
                            AGN_DCR_Request_Process_Class.createNewProvisionalAccount(dcr,Active);
                        }         
                        if(dcr.Is_Child_DCR_AGN__c == true )
                            AGN_DCR_Request_Process_Class.createNewProvisionalAccountCDCR(dcr,Active);
                    }
                }
                if(dcr.Request_Status_AGN__c == 'Send Back for Revision' && dcr.Provisional_Contact_AGN__c == true)
                {
                    AGN_DCR_Request_Process_Class.updateExistingAccountStatus(dcr,'Send Back for Revision');
                }
                if(dcr.Request_Status_AGN__c == Rejected  && dcr.Provisional_Contact_AGN__c == true)
                {
                    AGN_DCR_Request_Process_Class.updateExistingAccountStatus(dcr,Inactive);
                }
               if(dcr.Request_Status_AGN__c == Accepted && dcr.Provisional_Contact_AGN__c == false && dcr.Auto_Approved_AGN__c == false)
                {
                    if(dcr.Is_Child_DCR_AGN__c == false)
                       AGN_DCR_Request_Process_Class.createNewProvisionalAccount(dcr,Active);
                    if(dcr.Is_Child_DCR_AGN__c == true)
                       AGN_DCR_Request_Process_Class.createNewProvisionalAccountCDCR(dcr,Active);
                }
               
                if(dcr.Request_Status_AGN__c == Accepted  && dcr.Auto_Approved_AGN__c == true && dcr.Provisional_Contact_AGN__c == false)
                {
                   
                    if(dcr.Is_Child_DCR_AGN__c == false){
                        AGN_DCR_Request_Process_Class.createNewProvisionalAccount(dcr,Active);
                    }
                    if(dcr.Is_Child_DCR_AGN__c == true)
                    {                 
                       system.debug('calling child dcr process class'+dcr);
                       AGN_DCR_Request_Process_Class.createNewProvisionalAccountCDCR(dcr,Active); 
                    }
                        
                }
            }
            // update case - existing Account - so need not to create provisional account
            if(dcrRecordType == 'HCO_Update_Company_Managed' || dcrRecordType == 'HCP_Update_Company_Managed')
            {
                system.debug('going inside HCO_Update_Company_Managed or HCP_Update_Company_Managed '+dcr.name);
                if(dcr.Request_Status_AGN__c == Accepted  && dcr.Auto_Approved_AGN__c == false && dcr.Provisional_Contact_AGN__c == false)
                {
                    if(dcr.Is_Child_DCR_AGN__c == false)
                        AGN_DCR_Request_Process_Class.updateExistingAccount(dcr,Active,1);
                    if(dcr.Is_Child_DCR_AGN__c == true)
                        AGN_DCR_Request_Process_Class.createNewProvisionalAccountCDCR(dcr,Active);
                }
                if(dcr.Request_Status_AGN__c == Rejected  && dcr.Provisional_Contact_AGN__c == true)
                {
                    if(dcr.Is_Child_DCR_AGN__c == true)
                       AGN_DCR_Request_Process_Class.removeAffilitaionifRejected(dcr);
                }         
               
                if(dcr.Request_Status_AGN__c == Accepted  && dcr.Auto_Approved_AGN__c == true)
                {
                    if(dcr.Is_Child_DCR_AGN__c == false)
                        AGN_DCR_Request_Process_Class.updateExistingAccount(dcr,Active,1);
                    if(dcr.Is_Child_DCR_AGN__c == true)
                        AGN_DCR_Request_Process_Class.createNewProvisionalAccountCDCR(dcr,Active);
                }
                
                //Affiliation Deletion should be a part of Request Type = Change
                if(dcr.Request_Status_AGN__c == Accepted && dcr.Delete_Affiliation_AGN__c == true)
                {
                    AGN_DCR_Request_Process_Class.removeAffiliation(dcr);
                }
                
                if(dcr.Request_Status_AGN__c == Submitted &&  dcr.Provisional_Contact_AGN__c == true && dcr.Is_Reviewed_AGN__c == false)
                {
                    if(dcr.Is_Child_DCR_AGN__c == true)
                       AGN_DCR_Request_Process_Class.createNewProvisionalAccountCDCR(dcr,Pending_Validation);
                }
                
                if(dcr.Request_Status_AGN__c == Accepted  && dcr.Provisional_Contact_AGN__c == true)
                {
                    if(dcr.Is_Child_DCR_AGN__c == false)
                        AGN_DCR_Request_Process_Class.updateExistingAccount(dcr,Active,1);
                }
            }
        }
        //**********************************END Process DCR Request Class***************************************** 
        //************************Begin  Process buisness account method - Composite DCR*****************************************************************
        //Method 1
        public Integer processAddExistingCHCP(DCR_AGN__c cr,List<DCR_AGN__c> addExistingCHCP,DCR_AGN__c pRec)
        {
        //DCR_AGN__c pRec = [select Auto_Approved_AGN__c,TAAF_AGN__c,DCR_Approver_AGN__c,RecordTypeId,RecordType.Name,Account_Name_AGN__c,P_Business_Account_Id_AGN__c,Request_Status_AGN__c,Provisional_Contact_AGN__c from DCR_AGN__c where id =:cr.id];
            Integer chkAccMatchvarHCP =0;    
            for(integer i = 0;i<addExistingCHCP.size();i++)
            { 
                addExistingCHCP[i].Parent_DCR_ID_AGN__c = cr.Id;
                addExistingCHCP[i].Request_Entity_AGN__c = 'HCP';
                addExistingCHCP[i].Request_Type_AGN__c = 'Change';
                if(cr.Auto_Approved_AGN__c ==  true)
                {
                   addExistingCHCP[i].Request_Status_AGN__c = '';
                }
                else
                {
                    addExistingCHCP[i].Request_Status_AGN__c = 'Submitted'; 
                }
                addExistingCHCP[i].DCR_Approver_AGN__c = pRec.DCR_Approver_AGN__c; 
                if (pRec.RecordType.Name.contains('Company'))         
                    addExistingCHCP[i].RecordTypeId = dcrRTMap.get('HCP_Update_Company_Managed');
                else
                    addExistingCHCP[i].RecordTypeId = dcrRTMap.get('HCP_Update_Data_Provider_Managed');

                addExistingCHCP[i].Is_Child_DCR_AGN__c = true;
                addExistingCHCP[i].TAAF_AGN__c = pRec.TAAF_AGN__c;
                addExistingCHCP[i].Auto_Approved_AGN__c = pRec.Auto_Approved_AGN__c;
                addExistingCHCP[i].Provisional_Contact_AGN__c = pRec.Provisional_Contact_AGN__c;
            }
            
            if(addExistingCHCP.size() > 0 && cr.Auto_Approved_AGN__c  ==  true)
            {
                if(pRec.Request_Status_AGN__c == 'Accepted')
                {
                    addExistingCHCP[0].Account_AGN__c =  pRec.P_Business_Account_Id_AGN__c;
                    addExistingCHCP[0].Primary_Affiliation_AGN__c = 'No';
                    addExistingCHCP[0].Request_Status_AGN__c  =  'Accepted' ;     
                }
            }
            if (addExistingCHCP.size() > 0) 
            {   
                insert addExistingCHCP;
            }

            //**********Existing HCP Logic*********************     
            for(integer i = 0;i<addExistingCHCP.size();i++)
            {
                Id x  =  addExistingCHCP[i].Contact_AGN__c;
                list<Account> cacc =  new list<Account>([Select FirstName,LastName,Type_AGN__c,Sub_Type_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Salutation,
                            Privacy_AGN__c,Privacy_law_status_AGN__c,Sub_Specialty_Allergan_AGN__c,Phone_Internal_AGN__c,
                            PersonEmail,Fax,PersonMobilePhone,Workplace_AGN__c,KOL_vod__c,Target__c,Other_title_information_AGN__c,
                            Language_vod__c,No_Orders_vod__c,Default_Order_Type_vod__c,Physician_Registration_Reference_AGN__c,
                            External_ID_vod__c,External_ID2_AGN__c,External_ID4_AGN__c,Status_AGN__c,Middle_vod__c,Gender_vod__c,
                            Education_Speciality_AGN__c,Additional_Specialties_AGN__c,Calling_Name_AGN__c,Consent_to_Email_AGN__c,
                            Consent_to_Mail_AGN__c,Consent_to_Phone_AGN__c,Consent_to_Contact_AGN__c,Do_not_Phone_Call_AGN__c,
                            Do_not_send_Mail__c,Avocis_placed_AGN__c,Position_at_Primary_Institution_AGN__c,Do_not_Visit_AGN__c,Country_Code__c,
                            Customer_Consent_AGN__c,Owner_AGN__c,Avocis_date_AGN__c,Do_not_send_Fax_AGN__c,Order_Type_vod__c,Beds__c,
                            Departments__c,Phone,PersonBirthdate,Graduation_Year_AGN__c,Graduation_School_AGN__c,Influential_profile_AGN__c,
                            Distribution_ID_AGN__c,Description,Specialty_Allergan_1_AGN__c,Website,Other_Name_AGN__c,NS_Headache_Target_Centre_AGN__c,
                            Fax_Internal_AGN__c,Email_Internal_AGN__c,Country_vod__c
                            FROM Account  where id = :x limit 1]);
                       
                    //R008.1 - Country code fix for MSL & cluster
                    String childAccCountryCode = [Select Alpha_2_Code_vod__c from Country_vod__c where Id =: cacc[0].Country_vod__c].Alpha_2_Code_vod__c;  
                    
system.debug('value of childAccCountryCode '+childAccCountryCode);
system.debug('value of pRec.Country_Code_AGN__c '+pRec.Country_Code_AGN__c);    
                
                    if (!childAccCountryCode.equals(pRec.Country_Code_AGN__c))
                    {
                    
                        chkAccMatchvarHCP = 1;
                    }
                    else
                    {
                        chkAccMatchvarHCP = 0;    
                        if(addExistingCHCP[i].Contact_AGN__c != null)
                        {  
                            addExistingCHCP[i].Account_Type_AGN__c = [select Name from RecordType where Id = :cacc[0].RecordTypeId].Name;
                            addExistingCHCP[i].FirstName_AGN__c = cacc[0].FirstName;
                            addExistingCHCP[i].Last_Name_AGN__c = cacc[0].LastName;
                            addExistingCHCP[i].Type_AGN__c = cacc[0].Type_AGN__c;
                            //addExistingCHCP[i].Account_Type_AGN__c = cacc[0].Sub_Type_AGN__c;
                            addExistingCHCP[i].Specialty_1_AGN__c = cacc[0].Specialty_1_AGN__c;
                            addExistingCHCP[i].Specialty_2_AGN__c = cacc[0].Specialty_2_AGN__c;
                            addExistingCHCP[i].Specialty_Allergan_1_AGN__c = cacc[0].Specialty_Allergan_1_AGN__c;
                            addExistingCHCP[i].Salutation_AGN__c = cacc[0].Salutation;
                            addExistingCHCP[i].Privacy_AGN__c = cacc[0].Privacy_AGN__c;
                            addExistingCHCP[i].Privacy_law_status_AGN__c = cacc[0].Privacy_law_status_AGN__c;
                            addExistingCHCP[i].Sub_Specialty_Allergan_AGN__c = cacc[0].Sub_Specialty_Allergan_AGN__c;
                            addExistingCHCP[i].Phone_Internal_AGN__c = cacc[0].Phone_Internal_AGN__c;
                            addExistingCHCP[i].Email_AGN__c = cacc[0].PersonEmail;
                            addExistingCHCP[i].Fax_AGN__c = cacc[0].Fax;
                            addExistingCHCP[i].Mobile_AGN__c = cacc[0].PersonMobilePhone;
                            addExistingCHCP[i].Workplace_AGN__c = cacc[0].Workplace_AGN__c;
                            addExistingCHCP[i].KOL_AGN__c = cacc[0].KOL_vod__c;
                            addExistingCHCP[i].Target_AGN__c = cacc[0].Target__c;
                            addExistingCHCP[i].JobTitle_AGN__c = cacc[0].Other_title_information_AGN__c;
                            addExistingCHCP[i].Language_AGN__c = cacc[0].Language_vod__c;
                            addExistingCHCP[i].No_Orders_AGN__c = cacc[0].No_Orders_vod__c;
                            addExistingCHCP[i].Default_Order_Type_AGN__c = cacc[0].Default_Order_Type_vod__c;
                            addExistingCHCP[i].Type_AGN__c = cacc[0].Type_AGN__c;
                            addExistingCHCP[i].Physician_Registration_Reference_AGN__c = cacc[0].Physician_Registration_Reference_AGN__c;
                            addExistingCHCP[i].DCR_External_ID1_AGN__c = cacc[0].External_ID_vod__c;
                            addExistingCHCP[i].DCR_External_ID2_AGN__c = cacc[0].External_ID2_AGN__c;
                            addExistingCHCP[i].DCR_External_ID4_AGN__c = cacc[0].External_ID4_AGN__c;
                            addExistingCHCP[i].DCR_External_ID_AGN__c = cacc[0].External_ID_vod__c;
                            addExistingCHCP[i].Account_Status_AGN__c = cacc[0].Status_AGN__c;
                            addExistingCHCP[i].Middle_Name_AGN__c = cacc[0].Middle_vod__c;
                            addExistingCHCP[i].Gender_AGN__c = cacc[0].Gender_vod__c;
                            addExistingCHCP[i].Education_Speciality_AGN__c = cacc[0].Education_Speciality_AGN__c;
                            addExistingCHCP[i].Additional_Specialties_AGN__c = cacc[0].Additional_Specialties_AGN__c;
                            addExistingCHCP[i].Calling_Name_AGN__c = cacc[0].Calling_Name_AGN__c;
                            addExistingCHCP[i].Consent_to_Email_AGN__c = cacc[0].Consent_to_Email_AGN__c;
                            addExistingCHCP[i].Consent_to_Mail_AGN__c = cacc[0].Consent_to_Mail_AGN__c;
                            addExistingCHCP[i].Consent_to_Phone_AGN__c = cacc[0].Consent_to_Phone_AGN__c;
                            addExistingCHCP[i].Consent_to_Contact_AGN__c = cacc[0].Consent_to_Contact_AGN__c;
                            addExistingCHCP[i].Do_not_Phone_Call_AGN__c = cacc[0].Do_not_Phone_Call_AGN__c;
                            addExistingCHCP[i].Do_not_send_Mail_AGN__c = cacc[0].Do_not_send_Mail__c;
                            addExistingCHCP[i].Do_not_Visit_AGN__c = cacc[0].Do_not_Visit_AGN__c;
                            addExistingCHCP[i].Do_not_send_Fax_AGN__c = cacc[0].Do_not_send_Fax_AGN__c;
                            addExistingCHCP[i].Order_Type_AGN__c = cacc[0].Order_Type_vod__c;
                            addExistingCHCP[i].Avocis_date_AGN__c = cacc[0].Avocis_date_AGN__c;
                            addExistingCHCP[i].Avocis_placed_AGN__c = cacc[0].Avocis_placed_AGN__c ;
                            addExistingCHCP[i].Owner_AGN__c = cacc[0].Owner_AGN__c;
                            addExistingCHCP[i].Customer_Consent_AGN__c = cacc[0].Customer_Consent_AGN__c ;
                            addExistingCHCP[i].Position_at_Primary_Institution_AGN__c =  cacc[0].Position_at_Primary_Institution_AGN__c;
                            addExistingCHCP[i].Account_Phone_AGN__c  =  cacc[0].Phone;
                            addExistingCHCP[i].Email_Internal_AGN__c = cacc[0].Email_Internal_AGN__c; 
                            addExistingCHCP[i].Fax_Internal_AGN__c = cacc[0].Fax_Internal_AGN__c;
                            addExistingCHCP[i].NS_Headache_Target_Centre_AGN__c = cacc[0].NS_Headache_Target_Centre_AGN__c;
                            addExistingCHCP[i].Other_Name_AGN__c = cacc[0].Other_Name_AGN__c;
                            addExistingCHCP[i].Website_AGN__c = cacc[0].Website ;
                            addExistingCHCP[i].Distribution_ID_AGN__c  = cacc[0].Distribution_ID_AGN__c;
                            addExistingCHCP[i].Influential_profile_AGN__c = cacc[0].Influential_profile_AGN__c;
                            addExistingCHCP[i].Graduation_School_AGN__c = cacc[0].Graduation_School_AGN__c ;
                            addExistingCHCP[i].Graduation_Year_AGN__c = cacc[0].Graduation_Year_AGN__c ;
                            addExistingCHCP[i].PersonBirthdate_AGN__c = cacc[0].PersonBirthdate;
                            addExistingCHCP[i].Description_AGN__c = cacc[0].Description;
                            //R008.1 fixed
                            addExistingCHCP[i].Country_Code_AGN__c = childAccCountryCode;
                        } 
                    }
                }
                upsert addExistingCHCP;
                //system.debug('value of addExistingCHCP'+addExistingCHCP[0]);
            return chkAccMatchvarHCP ;
        }
        //End method 1
        //Method 2
        public void processAddNewCHCP(DCR_AGN__c cr,List<DCR_AGN__c> addNewCHCP,DCR_AGN__c pRec )
        {
            
            for(integer i = 0;i<addNewCHCP.size();i++)
            {
                system.debug('inside forloop of processAddNewCHCP');
                addNewCHCP[i].Parent_DCR_ID_AGN__c = cr.Id;
                addNewCHCP[i].Request_Entity_AGN__c = 'HCP';
                addNewCHCP[i].Request_Type_AGN__c = 'Add';
                if(cr.Auto_Approved_AGN__c  ==  true)
                {
                   addNewCHCP[i].Request_Status_AGN__c = '';
                }
                else{
                    addNewCHCP[i].Request_Status_AGN__c = 'Submitted'; }
                addNewCHCP[i].DCR_Approver_AGN__c = pRec.DCR_Approver_AGN__c; 
                if (pRec.RecordType.Name.contains('Company'))         
                    addNewCHCP[i].RecordTypeId = dcrRTMap.get('HCP_Insert_Company_Managed');
                else
                    addNewCHCP[i].RecordTypeId = dcrRTMap.get('HCP_Insert_Data_Provider_Managed');
                addNewCHCP[i].Is_Child_DCR_AGN__c = true;
                addNewCHCP[i].Country_Code_AGN__c = pRec.Country_Code_AGN__c;
                addNewCHCP[i].TAAF_AGN__c = pRec.TAAF_AGN__c;
                addNewCHCP[i].Provisional_Contact_AGN__c =pRec.Provisional_Contact_AGN__c;
                addNewCHCP[i].Auto_Approved_AGN__c = pRec.Auto_Approved_AGN__c;
            }
            //Auto Approved  stamping of New Child HCP                  
            if(addNewCHCP.size() > 0 && cr.Auto_Approved_AGN__c  ==  true)
            {
                if(pRec.Request_Status_AGN__c == 'Accepted')
                {
                    addNewCHCP[0].Account_AGN__c = pRec.P_Business_Account_Id_AGN__c;
                    addNewCHCP[0].Primary_Affiliation_AGN__c = 'Yes'; 
                }
            }       
            if(addNewCHCP.size()>0)  
            {
                Database.SaveResult sr =  Database.insert(addNewCHCP[0]);  
                if(sr.isSuccess())
                { 
                    insertcDCRProductMetrics(addNewCHCP[0]); 
                    upsert addNewCHCP;       
                }
                if(cr.Auto_Approved_AGN__c  ==  true)
                    addNewCHCP[0].Request_Status_AGN__c  = 'Accepted';
                else
                    addNewCHCP[0].Request_Status_AGN__c  = 'Submitted';
                upsert addNewCHCP;
            }         
        }
        //end method 2
        //Method 3
        public void processAddNewCHCO(DCR_AGN__c cr,List<DCR_AGN__c> addNewCHCO,DCR_AGN__c pRec )
        {
            for(integer i = 0;i<addNewCHCO.size();i++)
            {
                addNewCHCO[i].Parent_DCR_ID_AGN__c = cr.Id;
                addNewCHCO[i].Request_Entity_AGN__c = 'HCO';
                addNewCHCO[i].Request_Type_AGN__c = 'Add';
                if(cr.Auto_Approved_AGN__c  ==  true)
                {
                    addNewCHCO[i].Request_Status_AGN__c = '';
                }
                else
                {
                    addNewCHCO[i].Request_Status_AGN__c = 'Submitted';
                }
                addNewCHCO[i].DCR_Approver_AGN__c = pRec.DCR_Approver_AGN__c;

                if (pRec.RecordType.Name.contains('Company'))
                    addNewCHCO[i].RecordTypeId = dcrRTMap.get('HCO_Insert_Company_Managed');      
                else
                    addNewCHCO[i].RecordTypeId = dcrRTMap.get('HCO_Insert_Data_Provider_Managed');
                addNewCHCO[i].Is_Child_DCR_AGN__c = true;
                addNewCHCO[i].Country_Code_AGN__c = pRec.Country_Code_AGN__c;
                addNewCHCO[i].TAAF_AGN__c = pRec.TAAF_AGN__c;
                addNewCHCO[i].Provisional_Contact_AGN__c = pRec.Provisional_Contact_AGN__c;
                addNewCHCO[i].Auto_Approved_AGN__c =pRec.Auto_Approved_AGN__c;
            }    
            if(addNewCHCO.size() > 0 && cr.Auto_Approved_AGN__c  ==  true)
            {      
                
                if(pRec.Request_Status_AGN__c == 'Accepted')
                {
                    addNewCHCO[0].Account_AGN__c =  pRec.P_Business_Account_Id_AGN__c;
                    addNewCHCO[0].Primary_Affiliation_AGN__c = 'Yes';
                    addNewCHCO[0].Request_Status_AGN__c  =  'Accepted' ;     
                }
            }       
            if(addNewCHCO.size() > 0)
            insert addNewCHCO; 
        }
        // End Method 3
        //Method 4
        public integer processAddExistingCHCO(DCR_AGN__c cr,List<DCR_AGN__c> addExistingCHCO,DCR_AGN__c pRec )
        {
            integer chkAccMatchvarHCO=0;
            system.debug('going inside processAddExistingCHCO ');
            system.debug('value of cr '+cr);
            for(integer i = 0;i<addExistingCHCO.size();i++)
            {
                system.debug('going inside for loop processAddExistingCHCO ');
                addExistingCHCO[i].Parent_DCR_ID_AGN__c = cr.Id;
                addExistingCHCO[i].Request_Entity_AGN__c = 'HCO';
                addExistingCHCO[i].Request_Type_AGN__c = 'Change';

                if(cr.Auto_Approved_AGN__c  ==  true){
                    addExistingCHCO[i].Request_Status_AGN__c = '';
                }
                else{
                    addExistingCHCO[i].Request_Status_AGN__c = 'Submitted';
                }
                addExistingCHCO[i].DCR_Approver_AGN__c = pRec.DCR_Approver_AGN__c;

                if (pRec.RecordType.Name.contains('Company'))         
                    addExistingCHCO[i].RecordTypeId = dcrRTMap.get('HCO_Update_Company_Managed');
                else
                    addExistingCHCO[i].RecordTypeId = dcrRTMap.get('HCO_Update_Data_Provider_Managed');

                addExistingCHCO[i].Is_Child_DCR_AGN__c = true; 
                addExistingCHCO[i].TAAF_AGN__c = pRec.TAAF_AGN__c;
                addExistingCHCO[i].Provisional_Contact_AGN__c = pRec.Provisional_Contact_AGN__c;
                addExistingCHCO[i].Auto_Approved_AGN__c = pRec.Auto_Approved_AGN__c;
                addExistingCHCO[0].Primary_Affiliation_AGN__c = 'No';
            }

            if(addExistingCHCO.size() > 0 && cr.Auto_Approved_AGN__c  ==  true)
            {
                if(pRec.Request_Status_AGN__c == 'Accepted')
                {
                    addExistingCHCO[0].Primary_Affiliation_AGN__c = 'No';
                    addExistingCHCO[0].Request_Status_AGN__c  =  'Accepted' ;     
                }
            } 
            if(addExistingCHCO.size() > 0)            
                insert addExistingCHCO;
            //fetch Existing Child HCO records after submit
            for(integer i = 0;i<addExistingCHCO.size();i++)
            {
                ID x1  =  addExistingCHCO[i].Account_AGN__c;
                list<Account> cacco =  new list<Account>([Select Name,Sub_Type_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Salutation,
                Privacy_AGN__c,Privacy_law_status_AGN__c,Sub_Specialty_Allergan_AGN__c,Phone_Internal_AGN__c,
                PersonEmail,Fax,PersonMobilePhone,Workplace_AGN__c,KOL_vod__c,Target__c,Other_title_information_AGN__c,
                Language_vod__c,No_Orders_vod__c,Default_Order_Type_vod__c,Type_AGN__c,Physician_Registration_Reference_AGN__c,
                External_ID_vod__c,External_ID2_AGN__c,External_ID4_AGN__c,Status_AGN__c,Middle_vod__c,Gender_vod__c,
                Education_Speciality_AGN__c,Additional_Specialties_AGN__c,Calling_Name_AGN__c,Consent_to_Email_AGN__c,
                Consent_to_Mail_AGN__c,Consent_to_Phone_AGN__c,Consent_to_Contact_AGN__c,Do_not_Phone_Call_AGN__c,
                Do_not_send_Mail__c,Address_AGN__c,Fax_Internal_AGN__c,Avocis_date_AGN__c,Avocis_placed_AGN__c,Customer_Consent_AGN__c,
                IS_Rank_AGN__c,IS_Type_AGN__c,Owner_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,Partner_Rep_Name_AGN__c,
                Partner_Team_Name_AGN__c,Position_at_Primary_Institution_AGN__c,Do_not_send_Fax_AGN__c,Do_not_Visit_AGN__c,
                Sales_Credit_Limit_AGN__c,Organization_Registration_Reference_AGN__c,Website,Email_Internal_AGN__c,Target_AGN__c,
                Order_Type_vod__c,Beds__c,Departments__c,Institution_Site_AGN__c,NS_Headache_Target_Centre_AGN__c,Other_Name_AGN__c,
                Description,Account_Group_AGN__c ,Primary_Parent_vod__c,Country_vod__c,Patients_AGN__c,Account_Group_vod__c,Distribution_ID_AGN__c,
                Specialty_Allergan_1_AGN__c,Country_Code__c,Phone
                FROM Account  where id = :x1 limit 1]);                    
                // querying for address fields
                List<Address_vod__c> addr  = [SELECT Account_vod__c,Address_line_2_vod__c,Address_Line_3_AGN__c,Address_status_vod__c,address_type_vod__c,
                Billing_vod__c,Brick_vod__c,Business_Account_AGN__c,Shipping_vod__c,Mailing_vod__c,Appt_Required_vod__c,
                Business_vod__c,Home_vod__c,City_vod__c,Name,Receptionist_Name_AGN__c,
                Receptionist_Email_AGN__c,Country_vod__c,Phone_vod__c,Zip_vod__c,Phone_2_vod__c FROM Address_vod__c where Account_vod__c = :x1 limit 1];
                
                //R008.1 - Country code fix for MSL & cluster
                String childAccCountryCode = [Select Alpha_2_Code_vod__c from Country_vod__c where Id =: cacco[0].Country_vod__c].Alpha_2_Code_vod__c;             
                if (!childAccCountryCode.equals(pRec.Country_Code_AGN__c))
                {
                    chkAccMatchvarHCO = 1;
                }
                else
                {
                    chkAccMatchvarHCO = 0;
                    if(addExistingCHCO[i].Account_AGN__c != null)
                    {   
                        addExistingCHCO[i].Account_Type_AGN__c = [select Name from RecordType where Id = :cacco[0].RecordTypeId].Name;
                        addExistingCHCO[i].Account_Name_AGN__c = cacco[0].Name;
                        addExistingCHCO[i].Type_AGN__c = cacco[0].Type_AGN__c;  
                        addExistingCHCO[i].Email_Internal_AGN__c = cacco[0].Email_Internal_AGN__c; 
                        //addExistingCHCO[i].Account_Type_AGN__c = cacco[0].Sub_Type_AGN__c;
                        addExistingCHCO[i].Fax_Internal_AGN__c = cacco[0].Fax_Internal_AGN__c;
                        addExistingCHCO[i].Specialty_1_AGN__c = cacco[0].Specialty_1_AGN__c;
                        addExistingCHCO[i].Website_AGN__c = cacco[0].Website ;
                        addExistingCHCO[i].Specialty_2_AGN__c = cacco[0].Specialty_2_AGN__c;
                        addExistingCHCO[i].Privacy_AGN__c = cacco[0].Privacy_AGN__c;
                        addExistingCHCO[i].Privacy_law_status_AGN__c = cacco[0].Privacy_law_status_AGN__c;
                        addExistingCHCO[i].Sub_Specialty_Allergan_AGN__c = cacco[0].Sub_Specialty_Allergan_AGN__c;
                        addExistingCHCO[i].Phone_Internal_AGN__c = cacco[0].Phone_Internal_AGN__c;
                        addExistingCHCO[i].Email_AGN__c = cacco[0].PersonEmail;
                        addExistingCHCO[i].Fax_AGN__c = cacco[0].Fax;
                        addExistingCHCO[i].Mobile_AGN__c = cacco[0].PersonMobilePhone; 
                        addExistingCHCO[i].Workplace_AGN__c = cacco[0].Workplace_AGN__c; 
                        addExistingCHCO[i].Specialty_Allergan_1_AGN__c = cacco[0].Specialty_Allergan_1_AGN__c; 
                        addExistingCHCO[i].KOL_AGN__c = cacco[0].KOL_vod__c;
                        addExistingCHCO[i].NS_Headache_Target_Centre_AGN__c = cacco[0].NS_Headache_Target_Centre_AGN__c;
                        addExistingCHCO[i].Target_AGN__c = cacco[0].Target__c;
                        addExistingCHCO[i].Language_AGN__c = cacco[0].Language_vod__c;
                        addExistingCHCO[i].No_Orders_AGN__c = cacco[0].No_Orders_vod__c; 
                        addExistingCHCO[i].Organization_Registration_Reference_AGN__c = cacco[0].Organization_Registration_Reference_AGN__c;
                        addExistingCHCO[i].Default_Order_Type_AGN__c = cacco[0].Default_Order_Type_vod__c;
                        addExistingCHCO[i].Physician_Registration_Reference_AGN__c = cacco[0].Physician_Registration_Reference_AGN__c;
                        addExistingCHCO[i].DCR_External_ID1_AGN__c = cacco[0].External_ID_vod__c;
                        addExistingCHCO[i].DCR_External_ID2_AGN__c = cacco[0].External_ID2_AGN__c;
                        addExistingCHCO[i].DCR_External_ID4_AGN__c = cacco[0].External_ID4_AGN__c; 
                        addExistingCHCO[i].Account_Group_AGN__c = cacco[0].Account_Group_AGN__c;
                        addExistingCHCO[i].DCR_External_ID_AGN__c = cacco[0].External_ID_vod__c;
                        addExistingCHCO[i].Additional_Specialties_AGN__c = cacco[0].Additional_Specialties_AGN__c; 
                        addExistingCHCO[i].Calling_Name_AGN__c = cacco[0].Calling_Name_AGN__c; 
                        addExistingCHCO[i].Other_Name_AGN__c = cacco[0].Other_Name_AGN__c;
                        addExistingCHCO[i].Institution_Site_AGN__c = cacco[0].Institution_Site_AGN__c; 
                        addExistingCHCO[i].Description_AGN__c = cacco[0].Description;
                        addExistingCHCO[i].Patients_AGN__c = cacco[0].Patients_AGN__c;
                        addExistingCHCO[i].Consent_to_Email_AGN__c = cacco[0].Consent_to_Email_AGN__c;
                        addExistingCHCO[i].Consent_to_Mail_AGN__c = cacco[0].Consent_to_Mail_AGN__c;
                        addExistingCHCO[i].Consent_to_Phone_AGN__c = cacco[0].Consent_to_Phone_AGN__c;
                        addExistingCHCO[i].Consent_to_Contact_AGN__c = cacco[0].Consent_to_Contact_AGN__c;
                        addExistingCHCO[i].Do_not_Phone_Call_AGN__c = cacco[0].Do_not_Phone_Call_AGN__c;
                        addExistingCHCO[i].Do_not_send_Mail_AGN__c = cacco[0].Do_not_send_Mail__c;
                        addExistingCHCO[i].Do_not_Visit_AGN__c = cacco[0].Do_not_Visit_AGN__c;
                        addExistingCHCO[i].Do_not_send_Fax_AGN__c = cacco[0].Do_not_send_Fax_AGN__c;
                        addExistingCHCO[i].Order_Type_AGN__c = cacco[0].Order_Type_vod__c;
                        addExistingCHCO[i].Beds_AGN__c = cacco[0].Beds__c;
                        addExistingCHCO[i].Departments_AGN__c = cacco[0].Departments__c;
                        addExistingCHCO[i].Address_Whanin_AGN__c =  cacco[0].Address_AGN__c ;
                        addExistingCHCO[i].Avocis_date_AGN__c = cacco[0].Avocis_date_AGN__c;
                        addExistingCHCO[i].Avocis_placed_AGN__c  =  cacco[0].Avocis_placed_AGN__c ;
                        addExistingCHCO[i].IS_Rank_AGN__c =   cacco[0].IS_Rank_AGN__c;
                        addExistingCHCO[i].IS_Type_AGN__c = cacco[0].IS_Type_AGN__c; 
                        addExistingCHCO[i].Owner_AGN__c = cacco[0].Owner_AGN__c ; 
                        addExistingCHCO[i].Partner_Email_AGN__c =  cacco[0].Partner_Email_AGN__c ;
                        addExistingCHCO[i].Partner_Emp_Code_AGN__c =  cacco[0].Partner_Emp_Code_AGN__c ;
                        addExistingCHCO[i].Partner_Rep_Name_AGN__c =   cacco[0].Partner_Rep_Name_AGN__c ;
                        addExistingCHCO[i].Partner_Team_Name_AGN__c =   cacco[0].Partner_Team_Name_AGN__c ;
                        addExistingCHCO[i].Sales_Credit_Limit_AGN__c =  cacco[0].Sales_Credit_Limit_AGN__c;
                        addExistingCHCO[i].Target_Whanin_AGN__c  = cacco[0].Target_AGN__c; 
                        addExistingCHCO[i].Distribution_ID_AGN__c  = cacco[0].Distribution_ID_AGN__c;
                        addExistingCHCO[i].Account_Phone_AGN__c  =  cacco[0].Phone;
                        addExistingCHCO[i].Account_Country_AGN__c = cacco[0].Country_vod__c;
                        addExistingCHCO[i].Account_Group_AGN__c = cacco[0].Account_Group_vod__c ;
                        addExistingCHCO[i].Primary_Business_Accnt_AGN__c = cacco[0].Primary_Parent_vod__c;
                        //Fixed R008.1
                        addExistingCHCO[i].Country_Code_AGN__c = childAccCountryCode;
                        //address fields
                        addExistingCHCO[i].Address_Type_AGN__c = addr[0].address_type_vod__c;
                        addExistingCHCO[i].Address_Line_2_AGN__c = addr[0].Address_line_2_vod__c;
                        addExistingCHCO[i].Address_Line_3_AGN__c = addr[0].Address_Line_3_AGN__c;
                        addExistingCHCO[i].Address_Line_1_AGN__c = addr[0].Name;
                        addExistingCHCO[i].Billing_AGN__c = addr[0].Billing_vod__c;
                        addExistingCHCO[i].Brick_AGN__c = addr[0].Brick_vod__c;
                        addExistingCHCO[i].Business_AGN__c = addr[0].Business_vod__c;
                        addExistingCHCO[i].City_AGN__c = addr[0].City_vod__c;
                        addExistingCHCO[i].Home_AGN__c = addr[0].Home_vod__c;
                        addExistingCHCO[i].Country_AGN__c = addr[0].Country_vod__c;
                        addExistingCHCO[i].Shipping_AGN__c = addr[0].Shipping_vod__c;
                        addExistingCHCO[i].Mailing_AGN__c = addr[0].Mailing_vod__c;
                        addExistingCHCO[i].Appt_Required_AGN__c = addr[0].Appt_Required_vod__c;
                        addExistingCHCO[i].Receptionist_Name_AGN__c = addr[0].Receptionist_Name_AGN__c;
                        addExistingCHCO[i].Receptionist_Email_AGN__c = addr[0].Receptionist_Email_AGN__c;
                        addExistingCHCO[i].Phone_AGN__c = addr[0].Phone_vod__c;
                        addExistingCHCO[i].Phone_2_AGN__c = addr[0].Phone_2_vod__c;
                        addExistingCHCO[i].Zip_AGN__c = addr[0].Zip_vod__c;
                    }   
                }
                if(addExistingCHCO.size() > 0)   
                    upsert addExistingCHCO;
                    //system.debug('value of addExistingCHCO'+addExistingCHCO[0]);
            }
            return chkAccMatchvarHCO;
        }
    }