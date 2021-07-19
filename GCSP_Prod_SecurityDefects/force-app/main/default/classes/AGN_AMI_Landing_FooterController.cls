public class AGN_AMI_Landing_FooterController
 {
     public string country {get; set;}
    public string language;
    public string repAdvEvnt{get;set;}
    public string botoxLink{get;set;}
    public string juvedermLink{get;set;}
    public String supportLink{get; set;}
    public String contactUsLink{get; set;}
    public String tncLink{get; set;}
    public String privpolLink{get; set;}
    public String aboutLink {get;set;}
    public String ZINCNumber {get; set;}
    public String footerZinc {get; set;}
    public String footerDisclaimer {get; set;}
    public String footerBox {get; set;}
    public String cstmLabel ;
    List<AMI_AGN_Redirection_Links__c> lstRedLinks;
    public AMI_Footer_Visibility_Settings_AGN__c lstFooterVis {get;set;}
    public Boolean is_MENA;
	public String user_country_MENA;
    public AGN_AMI_Landing_FooterController()
    {
        cstmLabel = System.Label.AGN_AMI_Date_Of_Preparation;
        country=ApexPages.currentPage().getParameters().get('country');
        /*AMI MENA changes- Start*/ 
        is_MENA=false;
        List<AGN_AMI_MENA_Mapping__mdt> menaSettings = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c,AGN_AMI_Footer_Check__c from AGN_AMI_MENA_Mapping__mdt Where MasterLabel =:country ]) ;
        if(menaSettings.size() > 0){
            for(AGN_AMI_MENA_Mapping__mdt m:menaSettings){
                user_country_MENA=m.AGN_AMI_Parent_Country_Code__c;
                /*OLA Changes Start For footer*/
                if(m.AGN_AMI_Footer_Check__c==false){
                	is_MENA=true;
                }
                /*OLA Changes END For Footer*/
            }
        }
        /*AMI MENA changes- End*/ 
        system.debug('country-->'+country);
        language= ApexPages.currentPage().getParameters().get('lang');
        /*AMI MENA changes- Start*/ 
        if(!is_MENA){
        lstRedLinks=[select country_AGN__c,
                     Report_Adverse_Event_AGN__c,
                     Botox_AGN__c,
                     Juvederm_AGN__c,
                     About_AGN__c
                     from AMI_AGN_Redirection_Links__c
                    where country_AGN__c=:country Limit 1];
        }else{
            lstRedLinks=[select country_AGN__c,
                     Report_Adverse_Event_AGN__c,
                     Botox_AGN__c,
                     Juvederm_AGN__c,
                     About_AGN__c
                     from AMI_AGN_Redirection_Links__c
                    where country_AGN__c=:user_country_MENA Limit 1];
        }
        /*AMI MENA changes- End*/ 
        system.debug('lstRedLinks-->'+lstRedLinks);
        repAdvEvnt=lstRedLinks.size()>0?lstRedLinks[0].Report_Adverse_Event_AGN__c:'';
        botoxLink=lstRedLinks.size()>0?lstRedLinks[0].Botox_AGN__c:'';
        juvedermLink=lstRedLinks.size()>0?lstRedLinks[0].Juvederm_AGN__c:'';
        aboutLink = lstRedLinks.size()>0?lstRedLinks[0].About_AGN__c:'';
        supportLink = System.Label.AGN_AMI_Support_Page + '?country=' + country + '&lang=' + language;
        contactUsLink = System.Label.AGN_AMI_CONTACT_US_Page + '?country=' + country + '&lang=' + language;      
        tncLink = System.Label.AGN_AMI_TnC_Page + '?country=' + country + '&lang=' + language;
        privpolLink = System.Label.AGN_AMI_Privacy_Page + '?country=' + country + '&lang=' + language;
		/*AMI MENA changes- Start*/ 
        if(!is_MENA){
        	lstFooterVis = AMI_Footer_Visibility_Settings_AGN__c.getValues(country);
        }else{
            lstFooterVis = AMI_Footer_Visibility_Settings_AGN__c.getValues(user_country_MENA);
        }
        /*AMI MENA changes- End*/ 
        system.debug('lstFooterVis-->'+lstFooterVis);
        //Dynamic ZINC Number
        /*AMI MENA changes- Start*/ 
        List<AMI_Page_Zinc_Mapping_AGN__mdt> APZList = new List<AMI_Page_Zinc_Mapping_AGN__mdt>();
        if(!is_MENA){
        APZList=   [Select ZINC_AGN__c,Date_of_Preparation_AGN__c, Disclaimer_Text_AGN__c, Report_Adverse_Event_Box_AGN__c 
                      from AMI_Page_Zinc_Mapping_AGN__mdt 
                      where Page_Name_AGN__c = 'AGN_AMI_Landing_Footer'
                      and Country_AGN__c =: country limit 1];
        }else{
            APZList=   [Select ZINC_AGN__c,Date_of_Preparation_AGN__c, Disclaimer_Text_AGN__c, Report_Adverse_Event_Box_AGN__c 
                      from AMI_Page_Zinc_Mapping_AGN__mdt 
                      where Page_Name_AGN__c = 'AGN_AMI_Landing_Footer'
                      and Country_AGN__c =: user_country_MENA limit 1];
        }
        /*AMI MENA changes- End*/ 
        if(APZList.size()>0)
        {
            footerDisclaimer = APZList[0].Disclaimer_Text_AGN__c;
            footerBox = APZList[0].Report_Adverse_Event_Box_AGN__c;
            /*OLA Changes Start*/
            //footerZinc = APZList[0].ZINC_AGN__c +' '+cstmLabel +' '+ APZList[0].Date_of_Preparation_AGN__c;
              footerZinc = APZList[0].ZINC_AGN__c +' '+((APZList[0].Date_of_Preparation_AGN__c!=null)?(cstmLabel +' '+APZList[0].Date_of_Preparation_AGN__c):'');
            /*OLA Canges END*/
        }
            
        String pageURL = Apexpages.currentPage().getUrl();
        String pageName;
        if(pageURL.lastIndexOf('/') != -1)
        {
            if(pageURL.indexOf('?') != -1)
            {
                pageName = pageURL.substring(pageURL.lastIndexOf('/')+1,pageURL.indexOf('?'));
            }
            else
            {
                pageName = pageURL.substring(pageURL.lastIndexOf('/')+1);
            }
        }
        List<AMI_Page_Zinc_Mapping_AGN__mdt> APZMList = [Select ZINC_AGN__c,Date_of_Preparation_AGN__c 
                      from AMI_Page_Zinc_Mapping_AGN__mdt 
                      where Page_Name_AGN__c =: pageName 
                      and Country_AGN__c =: country limit 1];
        if(APZMList.size()>0)
            /*OLA Changes Start*/
            //ZINCNumber = APZMList[0].ZINC_AGN__c +' '+cstmLabel+' '+  APZMList[0].Date_of_Preparation_AGN__c;
            ZINCNumber = ((APZMList[0].ZINC_AGN__c!=null)?APZMList[0].ZINC_AGN__c:'')+' '+((APZMList[0].Date_of_Preparation_AGN__c!=null)?(cstmLabel +' '+APZMList[0].Date_of_Preparation_AGN__c):'');
        	/*OLA Changes END*/
    }
    

}