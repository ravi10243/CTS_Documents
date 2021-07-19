public without sharing class AGN_AMI_InFocus_Controller  
{
    public User user {get; set;} 
    public String userLanguage {get;set;}
    Id userId;
    account accountrecord;
    String userCountryName{get;set;}
    public List<AMI_InFocus_AGN__c> listInFocus {get; set;}
    public AMI_InFocus_AGN__c selectedInFocus {get; set;}
    public String filter{get; set;}
    public static String Const_In_Focus= 'In_Focus';
    public static String Const_type='type';
    public String urlString{get; set;}
    public String clickedVideo {get; set;}
    
    public AGN_AMI_InFocus_Controller()
    {
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        accountrecord=userDetails.accountrecord;
        System.debug(userCountryName);
        //Filter added as part of 3334
        filter=ApexPages.currentPage().getParameters().get(Const_type);
        filter=filter!=Null ?filter:Const_In_Focus;
        
        /*AMI Specialty Care - Added condition for AGN_AMI_Business_Unit__c */
        // 3334 - Query Updated with recordtype filter
        listInFocus = [Select Id, Name_AGN__c, Description_AGN__c, AMI_Image_URL_AGN__c, Video_URL_AGN__c,RecordTypeId,RecordType.name  
                       from AMI_InFocus_AGN__c
                       where Country_AGN__r.Name =: userCountryName and Active_AGN__c = true
                       and AGN_AMI_Business_Unit__c=: AGN_AMI_SC_Static_Labels.medicalAesthetics
                       and RecordType.DeveloperName =:filter 
                       order by Sequence_AGN__c ASC NULLS LAST];
        if( !listInFocus.isEmpty() )
        {
            selectedInFocus = listInFocus[0];
        }
        
    }
    public PageReference changeVideo()
    {
        /*CR - 3763- Start */
        String clickedPdf=Apexpages.currentPage().getParameters().get('clickedPdf');
        clickedVideo = clickedVideo != null ? clickedVideo : clickedPdf;
        /*CR - 3763- End */
        for(AMI_InFocus_AGN__c inFocus : listInFocus)
        {
            if(inFocus.Id == clickedVideo)
            {
                selectedInFocus = inFocus;
                break;
            }
        }
        /*CR - 3763- Start */
        try{
            list<AMI_Trend_Tracking_AGN__c> trendtrackList=[select id,AMI_HCP_Name_AGN__c,AMI_Trend_AGN__c,AMI_Number_of_Views_AGN__c,AMI_Trend_Record_Type_Name_AGN__c from AMI_Trend_Tracking_AGN__c where AMI_HCP_Name_AGN__c=:accountRecord.id and AMI_Trend_AGN__c=:selectedInFocus.ID];
            if(trendtrackList !=null && !trendtrackList.isEmpty()){
                trendtrackList[0].AMI_Number_of_Views_AGN__c=trendtrackList[0].AMI_Number_of_Views_AGN__c+1;
                trendtrackList[0].AMI_Last_view_Date_Time_AGN__c=datetime.now();
                update trendtrackList;
            }
            else{
                trendtrackList.add(new AMI_Trend_Tracking_AGN__c(AMI_HCP_Name_AGN__c=accountRecord.id,
                                                                  AMI_Number_of_Views_AGN__c=1,
                                                                  AMI_Trend_AGN__c=selectedInFocus.id,
                                                                  AMI_Last_view_Date_Time_AGN__c=datetime.now(),
                                                                  RecordTypeId=schema.SObjectType.AMI_Trend_Tracking_AGN__c.getRecordTypeinfosByName().get('AMI Trend Track').getRecordTypeId(),
                                                                  AMI_Trend_Record_Type_Name_AGN__c=selectedInFocus.RecordType.name));
                insert trendtrackList;
            }
            list<AMI_Trend_Tracking_Item_AGN__c> apdtList=new list<AMI_Trend_Tracking_Item_AGN__c>();
            if(trendtrackList !=null && !trendtrackList.isEmpty()){
                apdtList.add(new AMI_Trend_Tracking_Item_AGN__c(AMI_HCP_Name_AGN__c=accountRecord.id,
                                                               AMI_view_Date_Time_AGN__c=datetime.now(),
                                                                AMI_Trend_Content_Name_AGN__c=selectedInFocus.id,
                                                               AMI_Portal_Tracking_Name_AGN__c=Trendtracklist[0].id));
                insert apdtlist;
            }
        }catch(Exception ex){
            system.debug('Exception : '+ex.getMessage());
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_InFocus_Controller','changeVideo');
        }  
        /*CR - 3763- End */
        
        return null;
    }
}