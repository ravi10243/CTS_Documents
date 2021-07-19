// This class is created as the Controller class of the Visualforce Component - AGN_AMI_SC_Landing_Footer
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public class AGN_AMI_SC_Landing_FooterController {
     public string country {get; set;}
     String language;
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
     String cstmLabel ;
     List<AGN_AMI_SC_AGN_Redirection_Links__mdt> lstRedLinks;
	 public AGN_AMI_SC_Footer_Visibility_Settings__mdt lstFooterVis {get;set;}
    
    public AGN_AMI_SC_Landing_FooterController()
    {
        cstmLabel = System.Label.AGN_AMI_SC_Date_Of_Preparation;
        country=ApexPages.currentPage().getParameters().get('country');
        language= ApexPages.currentPage().getParameters().get('lang');
        lstRedLinks=[select AGN_AMI_Country__c,
                     AGN_AMI_Report_Adverse_Event__c,
                     AGN_AMI_Botox__c,
                     AGN_AMI_Juvederm__c,
                     AGN_AMI_About__c
                     from AGN_AMI_SC_AGN_Redirection_Links__mdt
                    where AGN_AMI_Country__c=:country Limit 1];
        repAdvEvnt=lstRedLinks.size()>0?lstRedLinks[0].AGN_AMI_Report_Adverse_Event__c:'';
        botoxLink=lstRedLinks.size()>0?lstRedLinks[0].AGN_AMI_Botox__c:'';
        juvedermLink=lstRedLinks.size()>0?lstRedLinks[0].AGN_AMI_Juvederm__c:'';
        aboutLink = lstRedLinks.size()>0?lstRedLinks[0].AGN_AMI_About__c:'';
		system.debug('lstRedLinks--->'+lstRedLinks);        
        supportLink = System.Label.AGN_AMI_SC_Support_Page + '?country=' + country + '&lang=' + language;
        contactUsLink = System.Label.AGN_AMI_SC_CONTACT_US_Page + '?country=' + country + '&lang=' + language;      
        tncLink = System.Label.AGN_AMI_SC_TnC_Page + '?country=' + country + '&lang=' + language;
        privpolLink = System.Label.AGN_AMI_SC_Privacy_Page + '?country=' + country + '&lang=' + language;
        
        
        lstFooterVis = [Select id,AGN_AMI_About_Page__c,AGN_AMI_Botox_Link__c,AGN_AMI_Botox_Link_Botulinum__c,AGN_AMI_Contact_Us_Page__c,AGN_AMI_Juvederm_Link__c,AGN_AMI_Privacy_Policy_Page_Middle__c,
                     AGN_AMI_Privacy_Policy_Page_Right__c,AGN_AMI_Report_an_Adverse_Event_Link__c,AGN_AMI_Report_Box__c,AGN_AMI_Support_Page__c,AGN_AMI_Terms_and_Conditions_Page_Middle__c,
                     AGN_AMI_Terms_and_Conditions_Page_Right__c from AGN_AMI_SC_Footer_Visibility_Settings__mdt where label =:ApexPages.currentPage().getParameters().get('country')]; 
        system.debug('lstFooterVis-->'+lstFooterVis);
        //Dynamic ZINC Number
        
        List<AGN_AMI_SC_Page_Zinc_Mapping__mdt> APZList = [Select ZINC_AGN__c,Date_of_Preparation_AGN__c, Disclaimer_Text_AGN__c, Report_Adverse_Event_Box_AGN__c 
                      from AGN_AMI_SC_Page_Zinc_Mapping__mdt 
                      where Page_Name_AGN__c = 'AGN_AMI_SC_Landing_Footer'
                      and Country_AGN__c =: country limit 1];
       
        if(APZList.size()>0)
        {
            footerDisclaimer = APZList[0].Disclaimer_Text_AGN__c;
            footerBox = APZList[0].Report_Adverse_Event_Box_AGN__c;
            footerZinc = APZList[0].ZINC_AGN__c +' '+cstmLabel +' '+ APZList[0].Date_of_Preparation_AGN__c;
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
        List<AGN_AMI_SC_Page_Zinc_Mapping__mdt> APZMList = [Select ZINC_AGN__c,Date_of_Preparation_AGN__c 
                      from AGN_AMI_SC_Page_Zinc_Mapping__mdt 
                      where Page_Name_AGN__c =: pageName 
                      and Country_AGN__c =: country limit 1];
        if(APZMList.size()>0)
            ZINCNumber = APZMList[0].ZINC_AGN__c +' '+cstmLabel+' '+  APZMList[0].Date_of_Preparation_AGN__c;
    }
    


}