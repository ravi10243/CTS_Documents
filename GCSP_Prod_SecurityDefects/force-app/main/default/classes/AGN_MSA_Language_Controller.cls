/**
***** @date- 16/July/2019
***** @Release- 19R2.1 Req. 2475
***** @Description- Controller created to generate Conga template language specific for selected countries.
**/

Public Class AGN_MSA_Language_Controller {
    public List<SelectOption> countryCodeList{get;set;}
    public String selectedCountry{get;set;}
    public Opportunity opprtnty {get;set;}
    public Boolean activeGenerateButton {get;set;}
    public Boolean isSaved {get; set;}
    String countrycode{get;set;}
    //Id Oppid;
    
    public AGN_MSA_Language_Controller(){
        //Oppid =ApexPages.currentPage().getParameters().get('id');
        opprtnty = [Select id, Name, Country_AGN__c, Alternate_Language_for_MSA_AGN__c, PDM_Template_ID_AGN__c, Contact_AGN__c, StageName, Conga_Template_IDer_Shadow_AGN__c from opportunity where id=:ApexPages.currentPage().getParameters().get('id')];//NM CC
        countrycode = opprtnty.country_AGN__c;
        activeGenerateButton = false;
        isSaved = false;
    }
    
    public List<SelectOption> getCountryCode(){
        List<SelectOption> countrieLst = new List<SelectOption>();
        countrieLst.add(new SelectOption('','-None-'));
        if(countrycode=='CH'){
            countrieLst.add(new SelectOption('German','German'));
            countrieLst.add(new SelectOption('French','French'));
        }
        else if(countrycode=='BE'){
            countrieLst.add(new SelectOption('French','French'));
            countrieLst.add(new SelectOption('Dutch','Dutch'));
        }
        else if(countrycode=='LU'){
            countrieLst.add(new SelectOption('French','French'));
            countrieLst.add(new SelectOption('Dutch','Dutch'));
        }
        return countrieLst;
    }
    
    public PageReference save(){
        if(String.isBlank(selectedCountry)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.AGN_No_Value_Error));
            activeGenerateButton = false;
            isSaved = false;
        }
        else{
            try{
                // AG CC
               if(Schema.sObjectType.Opportunity.fields.Alternate_Language_for_MSA_AGN__c.isUpdateable())
                    
                  { 
                     opprtnty.Alternate_Language_for_MSA_AGN__c=selectedCountry;
                  }
                activeGenerateButton = true;
                isSaved = true;
                update opprtnty;
                System.debug('====== updated opportunity  ======= '+opprtnty);
                
              }
            catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            }
        }
        return null;
    }
    
    public PageReference refresh(){
        isSaved = false;
        activeGenerateButton = false;
        return null;
    }
    
    public PageReference generate(){
        String SessionId1 = Userinfo.getSessionID();
        String ServerURL1 = Url.getSalesforceBaseUrl().toExternalForm();
        AGN_Settings__c setting =AGN_Settings__c.getinstance();
        String URL = setting.API_Partner_URL_AGN__c;
        String QueryID2= setting.QueryID_AGN__c;
        String Organizationid = UserInfo.getOrganizationId();
        String DC_parameter ;
        Opportunity opp = [Select id, Name, Country_AGN__c, Alternate_Language_for_MSA_AGN__c, PDM_Template_ID_AGN__c, Contact_AGN__c, StageName, Conga_Template_IDer_Shadow_AGN__c from opportunity Where Id=:ApexPages.currentPage().getParameters().get('id')]; //NM CC
        String Template_ID;        
        if(opp.PDM_Template_ID_AGN__c != null){
            Template_ID = opp.PDM_Template_ID_AGN__c ;
            System.debug('======== Template_ID PDM ========'+Template_ID );
        }
        else {
            Template_ID = opp.Conga_Template_IDer_Shadow_AGN__c;
            System.debug('======== Template_ID Conga ========'+Template_ID );
        }
        
        
        if(opp.Contact_AGN__c == null){
           DC_parameter='1';
                   }
        else{
            DC_parameter ='0';
        }
        system.debug('Organizationid = '+ Organizationid);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://composer.congamerge.com/');
        req.setMethod('GET');
        String salesforceURL = EncodingUtil.urlEncode(ServerURL1+'/services/Soap/u/21.0/'+Organizationid,'UTF-8');
        Pagereference newPage = new pagereference('https://composer.congamerge.com/');
        newPage.getParameters().put('sessionId',SessionId1);
        newPage.getParameters().put('serverUrl',URL);
        newPage.getParameters().put('id',opp.Id);
        newPage.getParameters().put('templateid',Template_ID);
        newPage.getParameters().put('QueryId',QueryID2);
        newPage.getParameters().put('FP0','1');
        newPage.getParameters().put('OFN','Coolsculpting+MSA+-'+opp.Name);
        newPage.getParameters().put('LG1','MSA+Generated');
        newPage.getParameters().put('LG0','0');
        newPage.getParameters().put('LG3','1');
        newPage.getParameters().put('LG4','1');
        newPage.getParameters().put('MFTS0','MSA_Issue_Date_AGN__c');
        newPage.getParameters().put('MFTSValue0','Today');
        newPage.getParameters().put('MFTS1','MSA_Generated_Stage_AGN__c');
        newPage.getParameters().put('MFTSValue1',opp.StageName);
        newPage.getParameters().put('DS7','1');
        newPage.getParameters().put('BML','Hold+while+the+MSA+is+generated+please');
        newPage.getParameters().put('DC',DC_parameter);
        newPage.getParameters().put('DCL','PRIMARY+CONTACT+REQUIRED++Please+close+this+window+and+select+a+Primary+Contact+on+your+Opportunity+in+the+Contact+Roles+related+list.');
       //newPage.getParameters().put('DCL','PRIMARY+CONTACT+REQUIRED++Please+close+this+window+and+select+a+Primary+Contact+on+your+Opportunity+in+the+Contact+Roles+related+list.');
        return newPage;
    }
    
}