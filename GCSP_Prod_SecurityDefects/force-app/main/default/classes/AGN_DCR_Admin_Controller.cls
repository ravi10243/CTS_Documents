public class AGN_DCR_Admin_Controller{

     ID dcrId;
    
    public List<SelectOption> AccountTypeOptions;
    public List<SelectOption> ActionTypeOptions;
    public List<SelectOption> ApprovalTypeOptions;
    
    public string selectedAccountType {get; set;}
    public string selectedActionType {get; set;}
    public string selectedApprovalType {get; set;}
    
    Map <string,string> rtMap = new Map <string,string>();
    public ID dcrRecordTypeId;
    
    public DCR_Configuration_Settings_AGN__c configSettings;
    public boolean showApprovalQuestion {get; set;}

    public string retUrl;
    
    public  AGN_DCR_Admin_Controller(ApexPages.StandardController controller){
        
        dcrId = controller.getId();
        
        system.debug('@@ Inside Controller Contructor');
        AccountTypeOptions = new List<SelectOption>();
        ActionTypeOptions = new List<SelectOption>();
        ApprovalTypeOptions = new List<SelectOption>();
        
        selectedAccountType = '';
        selectedActionType = '';
        selectedApprovalType = '';
        
        for (RecordType rt : [select id,DeveloperName from RecordType where sobjectType = 'DCR_AGN__c'])
        {
            rtMap.put(rt.DeveloperName,rt.Id);
        }
        

        User loggedInUser = [select  Country_Code__c,Division,Profile.Name 
                             from User where Id = :UserInfo.getUserId()];
        string userBU = (loggedInUser.Division == null ? 'ZZ': loggedInUser.Division);
        configSettings = [select DCR_Type_AGN__c, Company_Managed_AGN__c, Data_Provider_Managed_AGN__c,Immediate_Territory_Alignment_AGN__c,Provisional_Contact_Required_AGN__c,
                          HCO_Create_Allowed_AGN__c, HCO_Update_Allowed_AGN__c, HCP_Create_Allowed_AGN__c, HCP_Update_Allowed_AGN__c, Show_Product_Metrics_AGN__c,
                          Territory_Alignment_After_Approval_AGN__c,Business_Unit_AGN__c
                          from DCR_Configuration_Settings_AGN__c 
                          where Country_Code_AGN__c = :loggedInUser.Country_Code__c 
                          AND Profile_AGN__c = :loggedInUser.Profile.Name 
                          AND Business_Unit_AGN__c IN ('ZZ',:userBU)
                          ORDER BY Business_Unit_AGN__c ASC LIMIT 1];
        system.debug('@@ configSettings: '+configSettings);
        if(configSettings.Company_Managed_AGN__c == TRUE && configSettings.Data_Provider_Managed_AGN__c == TRUE){
           showApprovalQuestion = TRUE;
        }else{
           showApprovalQuestion = FALSE;
        }
        
        retUrl = apexPages.currentPage().getURL();
    }

    public List<SelectOption> getAccountTypeOptions(){        
        
        List<SelectOption> options = new List<SelectOption>();
        if(configSettings.DCR_Type_AGN__c == 'Both HCP and HCO'){
            options.add(new SelectOption('HCP',System.Label.Person_Account));
            options.add(new SelectOption('HCO',System.Label.Business_Account));
        }
        if(configSettings.DCR_Type_AGN__c == 'HCO Only'){
            options.add(new SelectOption('HCO',System.Label.Business_Account));
        }
        if(configSettings.DCR_Type_AGN__c == 'HCP Only'){
            options.add(new SelectOption('HCP',System.Label.Person_Account));
        }
        system.debug('@@ Account Type options: '+options);
        return options;
   }
    
    public List<SelectOption> getApprovalTypeOptions(){
        List<SelectOption> options = new List<SelectOption>();
        if(configSettings.Company_Managed_AGN__c == TRUE && configSettings.Data_Provider_Managed_AGN__c == TRUE){
            options.add(new SelectOption('DataProvider',System.Label.Data_Provider_Managed));
            options.add(new SelectOption('Self',System.Label.Self_Managed));
        }
        else if(configSettings.Company_Managed_AGN__c == TRUE){
            options.add(new SelectOption('Self',System.Label.Self_Managed));
        }
        else if(configSettings.Data_Provider_Managed_AGN__c == TRUE){
            options.add(new SelectOption('DataProvider',System.Label.Data_Provider_Managed));
        }
        else{
            options.add(new SelectOption('None',System.Label.None));
        }
        return options;
    } 
    
    
    public List<SelectOption> getActionTypeOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Add',System.Label.Create_New));
        options.add(new SelectOption('Change',System.Label.Update_Existing));
        system.debug('@@ Action Type options: '+options);
        return options;
   }
    
    public PageReference gotoDCR(){
        
        if(selectedAccountType == 'HCP' && selectedActionType == 'Add' && configSettings.HCP_Create_Allowed_AGN__c == False){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,System.Label.New_Person_Account_not_Allowed);
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(selectedAccountType == 'HCP' && selectedActionType == 'Change' && configSettings.HCP_Update_Allowed_AGN__c == False){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,System.Label.Update_Person_Account_not_Allowed);
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(selectedAccountType == 'HCO' && selectedActionType == 'Add' && configSettings.HCO_Create_Allowed_AGN__c == False){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,System.Label.New_Business_Account_not_Allowed);
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(selectedAccountType == 'HCO' && selectedActionType == 'Change' && configSettings.HCO_Update_Allowed_AGN__c == False){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,System.Label.Update_Business_Account_not_Allowed);
            ApexPages.addMessage(myMsg);
            return null;
        }        
        
        selectRecordType();        
        //ApexPages.PageMessage
        
        
        system.debug('@@ retURL = '+retUrl);
        
        string paramString = '?'+
            'returnUrl='+retUrl+
            '&accntType='+selectedAccountType+
            '&actionType='+selectedActionType+
            '&approvalType='+selectedApprovalType+
            '&ita='+configSettings.Immediate_Territory_Alignment_AGN__c+
            '&provisionalContact='+configSettings.Provisional_Contact_Required_AGN__c+
            '&showProdMetr='+configSettings.Show_Product_Metrics_AGN__c+
            '&taaf='+configSettings.Territory_Alignment_After_Approval_AGN__c+
            '&rtId='+dcrRecordTypeId
            ;
        
        system.debug('@@ paramString: '+paramString);
        
        //return new PageReference('/apex/TestPage'+paramString).setRedirect(true);         
        
        return new PageReference('/apex/AGN_DCR'+paramString).setRedirect(false);         
            
    }
    
    public void selectRecordType(){
        if(selectedAccountType == 'HCP'){
            if(selectedActionType == 'Add'){
                if(selectedApprovalType == 'DataProvider'){
                    dcrRecordTypeId = rtMap.get('HCP_Insert_Data_Provider_Managed_AGN');                    
                }else{
                    dcrRecordTypeId = rtMap.get('HCP_Insert_Company_Managed_AGN'); 
                }
            }else{
                if(selectedApprovalType == 'DataProvider'){
                    dcrRecordTypeId = rtMap.get('HCP_Update_Data_Provider_Managed_AGN');                    
                }else{
                    dcrRecordTypeId = rtMap.get('HCP_Update_Company_Managed_AGN'); 
                }                
            }
        }else{
            if(selectedActionType == 'Add'){
                if(selectedApprovalType == 'DataProvider'){
                    dcrRecordTypeId = rtMap.get('HCO_Insert_Data_Provider_Managed_AGN');                    
                }else{
                    dcrRecordTypeId = rtMap.get('HCO_Insert_Company_Managed_AGN'); 
                }
            }else{
                if(selectedApprovalType == 'DataProvider'){
                    dcrRecordTypeId = rtMap.get('HCO_Update_Data_Provider_Managed_AGN');                    
                }else{
                    dcrRecordTypeId = rtMap.get('HCO_Update_Company_Managed_AGN'); 
                }                
            }            
        }
    }
}