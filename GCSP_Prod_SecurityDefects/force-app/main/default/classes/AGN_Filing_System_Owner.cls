/* 
@Class name : AGN_Filing_System_Owner
@Createdate : 17.10.2019
@modified date: 30.03.2020
@Author : GDPR Case management Project Team
@Description: Trigger Handler Class for Filing System. It is used for two functions: 1) To assign Owner of Filing System either queue or User as per User selection in time of asset creation.
2) To make an asset active based on its Application status and effective date of application for task assignment. (Added Method:FilingSystemActiveCheck Requirement ID: 40 DSRm March Release 2) )
*/
public class AGN_Filing_System_Owner {
    
    public static void FilingSystemShare(List<Asset_Register_AGN__c> assetDetailsList)
    {
        List<AGN_CCPA_Primary_Owner_Assignment__c> lstCustSetting = new List<AGN_CCPA_Primary_Owner_Assignment__c>();
        
        try
        {
            List<Asset_Register_AGN__Share> asset_sharing_list = new List<Asset_Register_AGN__Share>();
            List<Asset_Register_AGN__c> updated_asset_details_list = new List<Asset_Register_AGN__c>();
            Asset_Register_AGN__Share asset_share = new Asset_Register_AGN__Share();
            List<Group> grpObjectList = new List<Group>();
            grpObjectList = [SELECT DeveloperName,Id,Name FROM Group WHERE Name LIKE :('%' + System.Label.AGN_CCPA_Queue_Prefix + '%')]; 
            
            for(Asset_Register_AGN__c asset_details:assetDetailsList){               
                if(asset_details.AGN_Assign_Primary_Owner_in_queue__c == true) {
                    System.debug('Owner Will be queue');                        
                    
                    lstCustSetting = AGN_CCPA_Primary_Owner_Assignment__c.getAll().values();
                    Map<String, String> mapbunitQueue = new Map<String,String>(); 
                    
                    for(AGN_CCPA_Primary_Owner_Assignment__c obj : lstCustSetting){
                        mapbunitQueue.put(obj.AGN_Business_Unit__c, obj.AGN_Primary_Owner_Queue__c);
                    }
                    for(String bunit:mapbunitQueue.keySet()){
                        System.debug('Top Level Business Unit:'+bunit);
                        if(asset_details.Top_Level_Business_Unit_GDPR_AGN__c==bunit)
                        {           
                            String queueName = mapbunitQueue.get(bunit);
                            System.debug('QueueForBU:'+queueName);
                            
                            for(Group grpObject:grpObjectList)
                            {
                                if(grpObject.Name == queueName)
                                {   
                                    System.debug('Assigned Queue:'+queueName);
                                    asset_details.OwnerId = grpObject.Id;
                                    updated_asset_details_list.add(asset_details);
                                }
                            }
                        }    
                    }                    
                }                
                else
                {   
                    System.debug('Owner will be logged in user');
                    if(asset_details.OwnerId ==Null)
                    {
                        asset_details.OwnerId = UserInfo.getUserId();
                        updated_asset_details_list.add(asset_details);
                    }
                }               
            }
            if(updated_asset_details_list.size() > 0)
            {
                update(updated_asset_details_list);
            }
            System.debug('Size of Asset List:'+updated_asset_details_list.size());
            
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    public static void FilingSystemActiveCheck(List<Asset_Register_AGN__c> newasset, List<Asset_Register_AGN__c> oldasset, Id rt)
    {
        Integer noOfDaysBetweenDates;
        Date startDate;
        Date endDate = Date.valueOf(System.today());
        Boolean currentYearLeapYear;
        Boolean previousYearLeapYear;
        for (Asset_Register_AGN__c newarg:newasset)
        {
            for (Asset_Register_AGN__c oldarg:oldasset)
            {
                //Checking the newlist with the old list to check whether the asset is approved
                if(newarg.Id==oldarg.Id)
                {
                    if((newarg.Application_Status_AGN__c!=oldarg.Application_Status_AGN__c) || (newarg.IsApproved_AGN__c!=oldarg.IsApproved_AGN__c) || (newarg.Effective_Date_Application_Status_AGN__c!=oldarg.Effective_Date_Application_Status_AGN__c) && newarg.RecordTypeId==rt)
                    {
                        System.debug('IsChanged');
                        
                        if(newarg.IsApproved_AGN__c==false)
                        {
                            newarg.Is_Active_AGN__c=false;
                        }
                        else if(newarg.Application_Status_AGN__c== System.Label.AGN_App_Status_Active || newarg.Application_Status_AGN__c== System.Label.AGN_App_Status_Retired && newarg.IsApproved_AGN__c==true)
                        {
                            System.debug('Application status Active');
                            newarg.Is_Active_AGN__c=True;
                        }
                        else if(newarg.Application_Status_AGN__c== System.Label.AGN_App_Status_Divested && newarg.IsApproved_AGN__c==true)  
                            
                        {
                            System.debug('Application status Divested');
                                if(newarg.Effective_Date_Application_Status_AGN__c > System.Today())
                                {
                                    newarg.Is_Active_AGN__c=True;
                                }
                                else
                                {
                                newarg.Is_Active_AGN__c=False;
                                }
                        }
                        else if(newarg.Application_Status_AGN__c== System.Label.AGN_App_Status_Decommissioned || newarg.Application_Status_AGN__c== System.Label.AGN_App_Status_Archived && newarg.IsApproved_AGN__c==true) 
                        {
                            System.debug('Application status Decommissioned/Archived');
                            // added logic : to include decommissioned asset with 365 days time period(Requirement ID:40 March Release)
                            
                            startDate = Date.valueOf(newarg.Effective_Date_Application_Status_AGN__c);
                            noOfDaysBetweenDates = startDate.daysBetween(endDate);
                            currentYearLeapYear = Date.isLeapYear(System.today().year());
                            previousYearLeapYear = Date.isLeapYear(newarg.Effective_Date_Application_Status_AGN__c.year());                        
                            System.debug('no of days:'+noOfDaysBetweenDates);
                            
                            if(newarg.Effective_Date_Application_Status_AGN__c > System.Today())
                            {
                                newarg.Is_Active_AGN__c=True;
                            }
                            else if(newarg.Effective_Date_Application_Status_AGN__c<=System.Today() && (!currentYearLeapYear && !previousYearLeapYear && noOfDaysBetweenDates <= 365) || (previousYearLeapYear || currentYearLeapYear && noOfDaysBetweenDates <= 366))
                            {
                                newarg.Is_Active_AGN__c=True;
                            }
                            
                            else
                            {
                                newarg.Is_Active_AGN__c=False;
                            }
                        }  
                    }
                    
                }
            }
        }
    }
}