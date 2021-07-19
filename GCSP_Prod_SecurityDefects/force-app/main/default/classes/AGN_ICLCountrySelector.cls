/*
Modified by :ICL Project Team
Description: Added Vault code and Cluster Logic as part of ICL Wave3 Project.
			 Added line 15 and 48 as a part of Two Column Layout change for Canada
Release :ICL Wave-3
*/
public class AGN_ICLCountrySelector {
    
    public StringCarrier defaultLanguage {get; set;}    
    public String lang { get; set; }
    public String ccode { get; set; }
    public string country {get;set;}
    public String SelectOptn {get; set;}
    //Added as part of two Column Layout for Canada
    public Boolean is_TwoColumn{get;set;}
    public String user_country_CLUSTER ;
    Map<string,string> uniqueCountryList;
    // String PAGENAME = 'AGN_ICL_SiteLanding_Page';
    public List<SelectOption> optns {get;set;}
    List<AGN_ICL_Country_Settings__c> lstSettings;
    String newlstSettings;
    List<AGN_ICL_Country_Settings__c> lstRedLinks = new List<AGN_ICL_Country_Settings__c>();
    public String imageURL{get;set;}
    User user;
    string retURL;
    
    public String PrivacyLinkURL{get;set;}
    //Added as part of Vault Code Changes LATAM
    public String VaultCode{get;set;}
    
    public AGN_ICLCountrySelector()
    {
       
        PrivacyLinkURL = Label.AGN_ICL_Defualt_Privacy_Link;
        newlstSettings=[select Name from AGN_ICL_Country_Settings__c where Language_AGN__c = NULL].Name;
        lstSettings=[select Name,Country_AGN__c,Redirect_URL_AGN__c from AGN_ICL_Country_Settings__c where OAM_Country_AGN__c=false and Language_AGN__c != NULL order by Name];
        uniqueCountryList=new Map<string,string>();
        optns = new List<SelectOption>();
        user = [Select Country_code__c,LanguageLocaleKey from user where id =: Userinfo.getUserid() limit 1];
        
        if(ApexPages.currentPage().getParameters().get('country') != null)
        {
            AGN_ICL_Country_Settings__c aur = [Select Name,Redirect_URL_AGN__c,Enable_Two_Column_Layout_AGN__c
                                               from AGN_ICL_Country_Settings__c 
                                               where Country_AGN__c = :ApexPages.currentPage().getParameters().get('country') Limit 1];
            country = aur.Name;
            //Added the below line as part of Two Column layout for Canada
            is_TwoColumn = aur.Enable_Two_Column_Layout_AGN__c;
            //End
            List<Document> dc=[SELECT id,Body FROM Document WHERE Folder.name = 'AGN_ICL_Flags' and name=:country];
            imageURL='/servlet/servlet.FileDownload?file=';
            imageURL=imageURL+dc[0].id;
            
            
         
            AGN_ICL_Country_Settings__c ic=[SELECT Language_AGN__c,country_agn__c FROM AGN_ICL_Country_Settings__c where Name=:country and OAM_Country_AGN__c=false ];
           
            
            lang=ic.Language_AGN__c; 
            // defaultLanguage = new StringCarrier();
            //defaultLanguage.value = ic.Language_AGN__c ;
            
            
            //}
            PrivacyLinkURL = AGN_ICL_PageFooterController.getPrivacyLinkURL(ApexPages.currentPage().getParameters().get('country'));
            //Added below line as a part of Vault Code requirement for ICLWave3
            VaultCode = AGN_ICL_PageFooterController.getFooter(ApexPages.currentPage().getParameters().get('country'));
        }
        else
        {
            getDefCountryICLUser(); 
            
        }  
        user_country_CLUSTER = AGN_ICL_UtlityClass.isCluster(country);
    } 
    
    public List<SelectOption> getcountryList()
    {
        List<SelectOption> optns = new List<Selectoption>();
        for(AGN_ICL_Country_Settings__c country : lstSettings ) 
            uniqueCountryList.put(country.Name, country.Name); 
        optns.add(new selectOption(newlstSettings,newlstSettings));         
        for(string countryName : uniqueCountryList.keySet())
            
            optns.add(new selectOption(countryName, countryName));  
        
        return optns;
    }
    public pagereference moveToCommunity()
    {
       
        Pagereference pr;  
            for(AGN_ICL_Country_Settings__c temp:lstSettings){
                if(temp.Name==country && temp.Name != newlstSettings){
                    retURL=temp.Redirect_URL_agn__c;
                        AGN_ICL_Country_Settings__c ic= [SELECT Language_AGN__c,country_agn__c FROM AGN_ICL_Country_Settings__c where Name=:country and OAM_Country_AGN__c=false ];
                   
                    lang=ic.Language_AGN__c; 
                    //defaultLanguage = new StringCarrier();
                    // defaultLanguage.value = ic.Language_AGN__c ;
                    ccode=ic.country_agn__c ;
                    // }
                   
                    pr=new pagereference(retURL+'/AGN_ICL_Registration?lang='+lang+'&country='+ccode);
                    
                }
                
                
                if(temp.Name==newlstSettings)
                {
                    pr=new pagereference(retURL);
                }
            }    
        
        return pr; 
    }  
    
    @TestVisible
    private void getDefCountryICLUser(){
        country='';
        string username='134768';
        string password='DoENCBmkZJLh';
        String retURL='';
        String UserIP=ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
       
        if(UserIP!=null){
           
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://geoip.maxmind.com/geoip/v2.1/country/'+UserIP);
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);            
            req.setMethod('GET');
            req.setHeader('content-type','application/json');
                    
            Http http = new Http();
            HTTPResponse res = http.send(req);            
            String retBody=  res.getBody(); 
            Integer reStStatus = res.getStatusCode();
          
            AGN_ICL_JsonApex detail1;
            try{
                if(retBody!=''){             
                    detail1= (AGN_ICL_JsonApex)JSON.deserialize(retBody, AGN_ICL_JsonApex.class);
                    if(detail1.country.Names.en!=null)
                    {
                        country = detail1.country.Names.en;
                        AGN_ICL_Country_Settings__c ic=[SELECT Language_AGN__c FROM AGN_ICL_Country_Settings__c where Name=:country and OAM_Country_AGN__c=false ];
                      
                        lang=ic.Language_AGN__c;
                        // defaultLanguage = new StringCarrier();
                        //  defaultLanguage.value = ic.Language_AGN__c ;
                        // }
                        List<Document> dc=[SELECT id,Body FROM Document WHERE Folder.name = 'AGN_ICL_Flags' and name=:country];
                        imageURL='/GlobalClinicLocator/servlet/servlet.FileDownload?file=';
                        imageURL=imageURL+dc[0].id;
                        
                        String ec=ApexPages.currentPage().getParameters().get('ec');
                        if(ec!=null)
                        {
                            imageURL='/servlet/servlet.FileDownload?file=';
                            imageURL=imageURL+dc[0].id;
                        }
                    }
                }
                
                
            }
            catch(exception e)
            {
                
                getcountryList();
                List<Document> dc=[SELECT id,Body FROM Document WHERE Folder.name = 'AGN_ICL_Flags' and name='Select your country'];
                imageURL='/GlobalClinicLocator/servlet/servlet.FileDownload?file=';
                imageURL=imageURL+dc[0].id;
            }
        }
    }
    
    public class User_IP_Detail
    {
        public String country_name;
        public String country;
        public String city;
    }
    
    public PageReference countryRedirect()
    {
        PageReference pr;
        pr = new PageReference(Label.AGN_ICL_Redirectlink + '?country='+ AGN_ICL_Country_Settings__c.getValues(country).Country_AGN__c);
      
        return pr;
 
        
    }
}