/**
 * @description       : Case landing page controller
 * @author            : Dev Team
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   10-16-2016   Dev Team   Initial Version
**/
public with sharing class AGN_NewCaseLandingPageController {
    
    public Case_Configuration_AGN__c caseConfig;
    
    public List<SelectOption> caseCountryList {get; set;}
    public List<SelectOption> caseServiceList {get; set;}
    public List<SelectOption> caseCategoryList {get; set;}
    public List<SelectOption> caseReasonList {get; set;}
    
    public string selectedCountry {get; set;}
    public string selectedService {get; set;}
    public string selectedCategory {get; set;}
    public string selectedReason {get; set;}
    
    public Boolean disableService {get; set;}
    public Boolean disableCategory {get; set;}
    public Boolean disableReason {get; set;}
    public Boolean disableNextBtn {get; set;}
    
    string loggedInUserCountry;
    public string caseURL;
    public string paramString;
    
    public string accntId;    
    public string parentCaseID;
    
    Boolean flag;
    Boolean isPersonAccount;
    List<String> tempList;
    
    public AGN_NewCaseLandingPageController(ApexPages.StandardController std){
        
        /** Initialize variables **/
        accntId = ApexPages.currentPage().getParameters().get('def_account_id');
        parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');       
        loggedInUserCountry = [select Country_Code__c from User where Id = :UserInfo.getUserId()].Country_Code__c;        
        disableService = true ; 
        disableCategory = true;
        disableReason = true;
        disableNextBtn = true ;
        caseURL = '';
        
                       
        tempList = new List<String>();
        
        AggregateResult[] groupedResults= [SELECT Country_AGN__r.Alpha_2_Code_vod__c  cCode, Country_AGN__r.AGN_Country_Name__c cName FROM Case_Configuration_AGN__c 
                                            where Active_AGN__c = True AND Country_AGN__c!= NULL
                                            GROUP BY Country_AGN__r.AGN_Country_Name__c, Country_AGN__r.Alpha_2_Code_vod__c 
                                            ORDER BY Country_AGN__r.AGN_Country_Name__c];
         
        AggregateResult[] groupedResultsWithoutCountryLookup = [SELECT Country_Code_AGN__c cCode, Country_Name_AGN__c cName FROM Case_Configuration_AGN__c 
                                            where Active_AGN__c = True AND Country_AGN__c= Null AND Country_Code_AGN__c != Null AND  Country_Name_AGN__c != Null
                                            GROUP BY Country_Name_AGN__c, Country_Code_AGN__c
                                            ORDER BY Country_Name_AGN__c ];
        
        if(groupedResultsWithoutCountryLookup != Null)
            groupedResults.addAll(groupedResultsWithoutCountryLookup); 
                
        /** Initialize the Country List **/
        caseCountryList = new List<SelectOption>();
        
        if(groupedResults.size()==1)
        {
            AggregateResult ar = groupedResults[0];
            String opnLvl = (String) ar.get('cName');
            String opnVal = (String) ar.get('cCode');
            if(opnLvl!=null && opnVal!= null){
                caseCountryList.add(new SelectOption(opnVal,opnLvl));
                selectedCountry = opnVal;
            }
            countrySelected();
        }
        
        if(groupedResults.size()>1){
        caseCountryList.add(new SelectOption('None','Select a country'));
        
        for (AggregateResult ar : groupedResults)  {
            String opnLvl = (String) ar.get('cName');
            String opnVal = (String) ar.get('cCode');
            if(opnLvl!=null && opnVal!= null)
                caseCountryList.add(new SelectOption(opnVal,opnLvl));
            
        }
        }        
    }
    
    public void countrySelected(){
        
        disableService = false ;
        disableCategory = true;
        disableReason = true;
        disableNextBtn = true ;
        selectedCategory = 'None';
        selectedReason = 'None';
        //PMO 2906 Added by Avik Shaw on 02/15/2021
        String CS_Service_Event = System.label.AGN_CoolSculpting_Service_Event;
    
        /** Initialize the Service List **/
        caseServiceList = new List<SelectOption>();
        caseServiceList.add(new SelectOption('None','Select a service'));                
        tempList = new List<String>();
        //PMO 2906 Added by Avik Shaw on 02/15/2021 - query filter condition: Service_AGN__c !=: CS_Service_Event 
        for(Case_Configuration_AGN__c cc : [select Service_AGN__c from Case_Configuration_AGN__c where Country_Code_AGN__c=: selectedCountry AND 
        Service_AGN__c !=: CS_Service_Event AND Active_AGN__c = True ORDER BY Service_AGN__c] ){
            flag = false;
            for(String s : tempList){
                if(s == cc.Service_AGN__c){
                    flag = true;
                    break;
                }                        
            }
            if(flag == false){
                tempList.add(cc.Service_AGN__c);
                caseServiceList.add(new SelectOption(cc.Service_AGN__c, cc.Service_AGN__c));
            }
        }
    }   
    
    public void serviceSelected(){
        
        disableCategory = true;
        disableReason = true;
        disableNextBtn = true ;
        selectedCategory = 'None';
        selectedReason = 'None';
        
        if(selectedService != 'None'){            
            disableCategory = false;
            caseCategoryList = new List<SelectOption>();
            caseCategoryList.add(new SelectOption('None','Select a category'));
            
            tempList = new List<String>();  
            Set<String> userCountryCodes = new Set<String>() ;  
            for(Case_Configuration_AGN__c cc : [select Category_AGN__c from Case_Configuration_AGN__c 
            where Country_Code_AGN__c = :selectedCountry AND Service_AGN__c = :selectedService and Active_AGN__c = True order by Category_AGN__c] )
            {
                //userCountryCodes.add(cc.Country_Code_AGN__c) ; 
                flag = false;
                for(String s : tempList){
                    if(s == cc.Category_AGN__c){
                        flag = true;
                        break;
                    }                        
                }
                if(flag == false){
                    tempList.add(cc.Category_AGN__c);
                    caseCategoryList.add(new SelectOption(cc.Category_AGN__c, cc.Category_AGN__c));
                }                   
            }
        }
    }
    
    public void categorySelected(){        
        disableReason = true;
        disableNextBtn = true ;
        selectedReason = 'None';
        if(selectedCategory != 'None'){
            disableReason = false;
            caseReasonList = new List<SelectOption>();
            caseReasonList.add(new SelectOption('None','Select a reason'));
            
            tempList = new List<String>();
            for(Case_Configuration_AGN__c cc : [select  Reason_AGN__c from Case_Configuration_AGN__c 
                                                WHERE Service_AGN__c = :selectedService and Category_AGN__c = :selectedCategory AND 
                                                Country_Code_AGN__c = :selectedCountry AND Active_AGN__c = True ORDER BY Reason_AGN__c] ){
                flag = false;
                for(String s : tempList){
                    if(s == cc.Reason_AGN__c){
                        flag = true;
                        break;
                    }                        
                } 
                if(flag == false){
                    tempList.add(cc.Reason_AGN__c);
                    caseReasonList.add(new SelectOption(cc.Reason_AGN__c, cc.Reason_AGN__c));
                } 
                
            }
        }
    }
    
    public void reasonSelected(){   
    
            disableNextBtn = false ;
    }
    
    public PageReference gotoNewCase(){
        if(selectedService == null || selectedService == 'None' || selectedCategory == null || selectedCategory == 'None' || selectedReason == null || selectedReason == 'None'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a valid Service, Category and Reason to Proceed');
            ApexPages.addMessage(myMsg);
            return null;            
        }else{
            fetchCaseURL();
            return new PageReference(caseURL).setRedirect(false);
        }
        
    }
    
    public void fetchCaseURL(){        
        caseConfig= new Case_Configuration_AGN__c();
        //caseConfig = [select Static_Category_AGN__c,Case_Record_Type__c, VF_applicable_AGN__c, VF_Page_Name_AGN__c, Entitlement_AGN__c, Product_Required_AGN__c from Case_Configuration_AGN__c where Service_AGN__c = :selectedService and Category_AGN__c = :selectedCategory and Reason_AGN__c =:selectedReason and Country_Code_AGN__c = :loggedInUserCountry and Active_AGN__c = True];
        caseConfig = [select Static_Category_AGN__c,Case_Record_Type__c, VF_applicable_AGN__c, VF_Page_Name_AGN__c, Entitlement_AGN__c, 
        Product_Required_AGN__c from Case_Configuration_AGN__c 
        where Service_AGN__c = :selectedService and Category_AGN__c = :selectedCategory and 
        Reason_AGN__c =:selectedReason and 
        Country_Code_AGN__c = :selectedCountry and Active_AGN__c = True];

        
        ID caseRecTypeID = [select Id from RecordType where SObjectType = 'Case' and Name = :caseConfig.Case_Record_Type__c Limit 1].Id;
        
        paramString = 
            'recordType=' + caseRecTypeID +
            '&caseService=' + selectedService +
            '&caseCategory=' + selectedCategory + 
            '&caseReason=' + selectedReason +
            '&caseStaticCategory=' + caseConfig.Static_Category_AGN__c +
            '&caseProduct=' + caseConfig.Product_Required_AGN__c +
            '&countryCode=' + selectedCountry 
            ;
        
        if(caseConfig.Entitlement_AGN__c != null)
            paramString = paramString + '&entitlementId=' + caseConfig.Entitlement_AGN__c;
        
        if(accntId != null && accntId != '')
            paramString = paramString + '&def_account_id=' + accntId;
        
        if(parentCaseId != null && parentCaseId != '')
            paramString = paramString + '&def_parent_id=' + parentCaseId;
        
        if (caseConfig.VF_applicable_AGN__c)
            caseURL = '/apex/' + caseConfig.VF_Page_Name_AGN__c + '?' + paramString;
        else 
            caseURL = '/flow/' + caseConfig.VF_Page_Name_AGN__c + '?' + paramString + '&retURL=/apex/AGN_NewCaseLandingPage';

    }
}