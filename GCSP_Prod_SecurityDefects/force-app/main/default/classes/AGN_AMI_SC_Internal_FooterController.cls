// This class is created as the Controller class of the Visualforce Component - AGN_AMI_SC_Internal_Footer
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public without sharing Class  AGN_AMI_SC_Internal_FooterController{
    User user;
    public String userCountryName {get;set;}
    public String userLanguage {get; set;}
    public string repAdvEvnt{get;set;}
    public string botoxLink{get;set;}
    public string juvedermLink{get;set;}
    public String supportLink{get; set;}
    public String contactUsLink{get; set;}
    public String tncLink{get; set;}
    public String privpolLink{get; set;}
    public String aboutLink{get;set;} 
    public String ZINCNumber {get; set;}
    public String footerZinc {get; set;}
    public String footerDisclaimer {get; set;}
    public String footerBox {get; set;}
    List<AGN_AMI_SC_AGN_Redirection_Links__mdt> lstRedLinks;
    public AGN_AMI_SC_Footer_Visibility_Settings__mdt lstFooterVis {get;set;}
    String cstmLabel ;
    public AGN_AMI_SC_Internal_FooterController()
    {
        ZINCNumber = '';
        footerZinc = '';
        cstmLabel = System.Label.AGN_AMI_Date_Of_Preparation;
        
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        
        lstRedLinks=[select AGN_AMI_Country__c,
                     AGN_AMI_Report_Adverse_Event__c,
                     AGN_AMI_Botox__c,
                     AGN_AMI_Juvederm__c,
                     AGN_AMI_About__c
                     from AGN_AMI_SC_AGN_Redirection_Links__mdt
                     where AGN_AMI_Country__c=:userCountryName Limit 1];
        repAdvEvnt=lstRedLinks.size()>0?lstRedLinks[0].AGN_AMI_Report_Adverse_Event__c:'';
        botoxLink=lstRedLinks.size()>0?lstRedLinks[0].AGN_AMI_Botox__c:'';
        juvedermLink=lstRedLinks.size()>0?lstRedLinks[0].AGN_AMI_Juvederm__c:'';
        aboutLink=lstRedLinks.size()>0?lstRedLinks[0].AGN_AMI_About__c:'';
        
        supportLink = System.Label.AGN_AMI_SC_Support_Page;
        contactUsLink = System.Label.AGN_AMI_SC_CONTACT_US_Page;
        tncLink = System.Label.AGN_AMI_SC_TnC_Page;
        privpolLink = System.Label.AGN_AMI_SC_Privacy_Page;
        
        
        lstFooterVis=[Select id,AGN_AMI_About_Page__c,AGN_AMI_Botox_Link__c,AGN_AMI_Botox_Link_Botulinum__c,AGN_AMI_Contact_Us_Page__c,AGN_AMI_Juvederm_Link__c,AGN_AMI_Privacy_Policy_Page_Middle__c,
                      AGN_AMI_Privacy_Policy_Page_Right__c,AGN_AMI_Report_an_Adverse_Event_Link__c,AGN_AMI_Report_Box__c,AGN_AMI_Support_Page__c,AGN_AMI_Terms_and_Conditions_Page_Middle__c,
                      AGN_AMI_Terms_and_Conditions_Page_Right__c from AGN_AMI_SC_Footer_Visibility_Settings__mdt where label =:userCountryName]; 
        //Adding Dynamic Zinc Number
        List<AGN_AMI_SC_Page_Zinc_Mapping__mdt> APZList = [Select ZINC_AGN__c,Date_of_Preparation_AGN__c, Disclaimer_Text_AGN__c, Report_Adverse_Event_Box_AGN__c 
                                                           from AGN_AMI_SC_Page_Zinc_Mapping__mdt 
                                                           where Page_Name_AGN__c = 'AGN_AMI_SC_Internal_Footer'
                                                           and Country_AGN__c =: userCountryName limit 1];
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
        
        List<AGN_AMI_SC_Page_Zinc_Mapping__mdt> APZMList = [Select ZINC_AGN__c, Date_of_Preparation_AGN__c 
                                                            from AGN_AMI_SC_Page_Zinc_Mapping__mdt 
                                                            where Page_Name_AGN__c =: pageName 
                                                            and Country_AGN__c =: userCountryName limit 1];
        if(APZMList.size()>0)
        {
            ZINCNumber = ((APZMList[0].ZINC_AGN__c!=null)?APZMList[0].ZINC_AGN__c:'')+' '+cstmLabel +' '+ ((APZMList[0].Date_of_Preparation_AGN__c!=null)?APZMList[0].Date_of_Preparation_AGN__c:'');
        }
        else
        {
            String curriculumId = ApexPages.currentPage().getParameters().get('currId');
            String moduleId = ApexPages.currentPage().getParameters().get('lRDId');
            String eventId = ApexPages.currentPage().getParameters().get('eventId');
            if(curriculumId != null)
            {
                List<AMI_Learning_AGN__c> currList = [Select ZINC_AGN__c,Published_Date_AGN__c from AMI_Learning_AGN__c where Id =: curriculumId];
                if(currList.size()>0)
                    ZINCNumber = ((currList[0].ZINC_AGN__c!=null)?currList[0].ZINC_AGN__c:'') + ((currList[0].Published_Date_AGN__c!=null)?' '+cstmLabel +' ' + ((Datetime)currList[0].Published_Date_AGN__c).format('MMMMM yyyy'):'');
            }
            else if(moduleId != null)
            {
                List<AMI_Lrn_Rel_Dtl_AGN__c> modList = [Select Module_AGN__r.ZINC_AGN__c, Module_AGN__r.Published_Date_AGN__c from AMI_Lrn_Rel_Dtl_AGN__c where Id =: moduleId];
                if(modList.size()>0)
                    ZINCNumber = ((modList[0].Module_AGN__r.ZINC_AGN__c!=null)?modList[0].Module_AGN__r.ZINC_AGN__c:'') + ((modList[0].Module_AGN__r.Published_Date_AGN__c!=null)?' '+cstmLabel +' ' + ((Datetime)modList[0].Module_AGN__r.Published_Date_AGN__c).format('MMMMM yyyy'):'');
            }
            else if(eventId != null)
            {
                List<Medical_Event_vod__c> eventList = [Select Start_Time_vod__c,Zinc_Number_AGN__c from Medical_Event_vod__c where Id =: eventId];
                if(! eventList.isEmpty())
                    ZINCNumber = ((eventList[0].Zinc_Number_AGN__c!=null)?eventList[0].Zinc_Number_AGN__c:'');
            }
        }                   
    } 
    
}