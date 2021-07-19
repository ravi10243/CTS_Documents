public without sharing class AGN_AMI_Internal_FooterController
 {
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
    List<AMI_AGN_Redirection_Links__c> lstRedLinks;
    public AMI_Footer_Visibility_Settings_AGN__c lstFooterVis {get;set;}
    public String cstmLabel ;
    public boolean footer_check;
	
    public String DefaultTab ='default';
    Public Map<String, String> tabZinMapping {get; set;}
	
    public AGN_AMI_Internal_FooterController()
    {
        ZINCNumber = '';
        footerZinc = '';
        cstmLabel = System.Label.AGN_AMI_Date_Of_Preparation;
        
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        /*OLA Changes Start for Footer*/
        footer_check=false;
        List<AGN_AMI_MENA_Mapping__mdt> menaSettings = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c,AGN_AMI_Footer_Check__c from AGN_AMI_MENA_Mapping__mdt Where MasterLabel =:userDetails.maskedUserCountryName ]) ;
        if(menaSettings.size() > 0){
            for(AGN_AMI_MENA_Mapping__mdt m:menaSettings){                              
                footer_check= m.AGN_AMI_Footer_Check__c;             
            }
        }
        if(!footer_check){
        	userCountryName =  userDetails.userCountryName;
        }
        else{
            userCountryName=userDetails.maskedUserCountryName;
        }
        /*OLA Changes END For Footer*/
        user =  userDetails.user;
        lstRedLinks=[select country_AGN__c,
                     Report_Adverse_Event_AGN__c,
                     Botox_AGN__c,
                     Juvederm_AGN__c,
                     About_AGN__c
                     from AMI_AGN_Redirection_Links__c
                    where country_AGN__c=:userCountryName Limit 1];
                                            system.debug('userCountryName is:'+userCountryName);
        repAdvEvnt=lstRedLinks.size()>0?lstRedLinks[0].Report_Adverse_Event_AGN__c:'';
        botoxLink=lstRedLinks.size()>0?lstRedLinks[0].Botox_AGN__c:'';
        juvedermLink=lstRedLinks.size()>0?lstRedLinks[0].Juvederm_AGN__c:'';
        aboutLink=lstRedLinks.size()>0?lstRedLinks[0].About_AGN__c:'';
        
        supportLink = System.Label.AGN_AMI_Support_Page;
        contactUsLink = System.Label.AGN_AMI_CONTACT_US_Page;
        tncLink = System.Label.AGN_AMI_TnC_Page;
        privpolLink = System.Label.AGN_AMI_Privacy_Page;
        
        lstFooterVis = AMI_Footer_Visibility_Settings_AGN__c.getValues(userCountryName);
        
        //Adding Dynamic Zinc Number
        List<AMI_Page_Zinc_Mapping_AGN__mdt> APZList = [Select ZINC_AGN__c,Date_of_Preparation_AGN__c, Disclaimer_Text_AGN__c, Report_Adverse_Event_Box_AGN__c 
                      from AMI_Page_Zinc_Mapping_AGN__mdt 
                      where Page_Name_AGN__c = 'AGN_AMI_Internal_Footer'
                      and Country_AGN__c =: userCountryName limit 1];
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
        List<AMI_Page_Zinc_Mapping_AGN__mdt> APZMList = [Select ZINC_AGN__c, Date_of_Preparation_AGN__c 
                      from AMI_Page_Zinc_Mapping_AGN__mdt 
                      where Page_Name_AGN__c =: pageName 
                      and Country_AGN__c =: userCountryName limit 1];
        if(APZMList.size()>0)
        {
            /*OLA Changes Start*/
            //ZINCNumber = ((APZMList[0].ZINC_AGN__c!=null)?APZMList[0].ZINC_AGN__c:'')+' '+cstmLabel +' '+ ((APZMList[0].Date_of_Preparation_AGN__c!=null)?APZMList[0].Date_of_Preparation_AGN__c:'');
            ZINCNumber = ((APZMList[0].ZINC_AGN__c!=null)?APZMList[0].ZINC_AGN__c:'')+' '+((APZMList[0].Date_of_Preparation_AGN__c!=null)?(cstmLabel +' '+APZMList[0].Date_of_Preparation_AGN__c):'');
            /*OLA Changes END*/
        }
        else
        {
            //ZINCNumber = pageName;
            String curriculumId = ApexPages.currentPage().getParameters().get('currId');
            String moduleId = ApexPages.currentPage().getParameters().get('lRDId');
            String eventId = ApexPages.currentPage().getParameters().get('eventId');
            //ZINCNumber = curriculumId + moduleId;
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
		//CR3468 Begins - Accomodating Vault codes changes for All Events Page and Tabs
        List<AMI_Page_Zinc_Mapping_AGN__mdt> tabZincs = [SELECT ZINC_AGN__c, Date_of_Preparation_AGN__c, Page_Name_AGN__c 
                                                         		FROM AMI_Page_Zinc_Mapping_AGN__mdt 
                                                         WHERE Page_Name_AGN__c Like : (pageName+'%')
                                                         AND Country_AGN__c =: userCountryName];
        tabZinMapping = new Map<String, String> ();
        for(AMI_Page_Zinc_Mapping_AGN__mdt zinc : tabZincs)
        {
            if(zinc.Page_Name_AGN__c !=null ) {
                List<String> pageNameSplit = zinc.Page_Name_AGN__c.split('#');
                String tabName;
                if(pageNameSplit.size()>1 )
                    tabName = pageNameSplit[1];
                else
                    tabName = DefaultTab;
                String displayValue = ((zinc.ZINC_AGN__c!=null)?zinc.ZINC_AGN__c:'')+' '+cstmLabel +' '+ ((zinc.Date_of_Preparation_AGN__c!=null)?zinc.Date_of_Preparation_AGN__c:'');
                
                if(zinc.ZINC_AGN__c!=null && !String.isBlank(zinc.ZINC_AGN__c) ) {
                    tabZinMapping.put(tabName, displayValue);
                }
            }
        }
        //CR3468 Ends
    }    
}