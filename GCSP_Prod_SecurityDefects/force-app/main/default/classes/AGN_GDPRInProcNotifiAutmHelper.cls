/** 
******************************************************************************
Apex Class Name - AGN_GDPRInProcNotifiAutmHelper
Version - 1.0
Created Date - Aug 07, 2018
Function - Trigger helper for AGN_GDPRInProcNotifiAutm

Division – ADC_DTP

Modification Log : 
--------------------------------------------------------------------------------

* Developer               Date                 Description
* -------------------     ------------         -----------------------
* Cognizant Team        08/07/2018           Original Version
* Namrata Kundu			01/12/2020			 Changes done for TM 2.0
**********************************************************************************
*/ 


public class AGN_GDPRInProcNotifiAutmHelper {
    
    public static Map<String,Territory2> territoryMap = new Map<String,Territory2>();
    public static map<id,set<id>> TerritoryUserSetMap = new map<id,set<id>>();
    public static Map<String,AGN_InPersonNotification__c> customSettingCountryMap = new Map<String,AGN_InPersonNotification__c>();    
    public static map<id,String> countryCodeMap = new map<id,String>();
    
    /**
    *@description: To handle the opreation for the CountryCode
    *@return: string
    **/       
    public static String getCountryCode(Id cid)
    {
        if(countryCodeMap.size() > 0)
        {
            return  countryCodeMap.get(cid);
        }
        for(Country_vod__c country: [Select Name, Id From Country_vod__c])
        {
            countryCodeMap.put(country.id, country.Name);   
        }
        return  countryCodeMap.get(cid);
    }  
    
    /**
    *@description: To handle the opreation for the CountryCode on basis of customsetting value
    *@return: string
    **/ 
    public static String getRoleCustomSetting(String countryCode){
        
        if(customSettingCountryMap.size() > 0)
        {
            AGN_InPersonNotification__c cs = customSettingCountryMap.get(countryCode);         
            return cs != null ? cs.Role__c : null;
        }
        
        customSettingCountryMap = AGN_InPersonNotification__c.getAll();
        System.debug('Countery Code:::::'+ countryCode);
        AGN_InPersonNotification__c cs = customSettingCountryMap.get(countryCode);         
        return cs != null ? cs.Role__c : null; 
    }
    
    /**
    *@description: To handle the opreation for the territory name
    *@return: string
    **/  
    //Changes done for TM 2.0  
    public static Territory2 getTerritoryByName(String tName)
    {
        if(territoryMap.size() > 0)
        {
            return territoryMap.get(tName);
        }
        for(Territory2 t : [Select Name, Id from Territory2])
        {
            territoryMap.put(t.Name.toUpperCase(), t); 
        }
        return territoryMap.get(tName);
    }
    
    /**
    *@description: To handle the opreation for the task creation
    *@return: task
    **/    
    public static list<Task> createTask(Id whatId,Account a,list<id> lstOwnerId,String Subject,
                                        String InPersonNotificatioStatusAGN,string Priority,DateTime ReminderDateTime,boolean IsReminderSet){
                                            list<Task> lstTasks = new list<Task>();
                                            for(id ids : lstOwnerId){
                                                Task newTask = new Task();
                                                newTask.WhatId = whatId;
                                                newTask.OwnerId = ids;
                                                //Added by Brazil LGPD Team
                                                if(a.Country_code__c=='BR')
                                                    newTask.Subject = 'Please Notify In Person or Update the correct Email Id of the HCP';
                                                else
                                                    newTask.Subject = Subject;
                                                //newTask.InPerson_Notification_Status_AGN__c= InPersonNotificatioStatusAGN;
                                                newTask.Priority = Priority;
                                                newTask.ReminderDateTime = ReminderDateTime;
                                                newTask.IsReminderSet = IsReminderSet;
                                                newTask.AGN_GDPRNotificationAlert__c = true;
                                                newTask.ActivityDate = System.today()+10;
                                                newTask.Status = 'In Progress';
                                                system.debug('newTask'+ newTask);
                                                lstTasks.add(newTask);
                                            }
                                            
                                            return lstTasks;
                                            
                                        }
    
    /**
    *@description: To handle the opreation to get territory user
    *@return: map
    **/    
    //Changes done for TM 2.0
    public static map<id,set<id>> getTerritoryUsers(){
        if(TerritoryUserSetMap.size()>0){
            return TerritoryUserSetMap;
        }
        for(UserTerritory2Association ut:[SELECT Id,Territory2Id,UserId from UserTerritory2Association where isActive = true]){
            if(TerritoryUserSetMap.containsKey(ut.Territory2Id)){
                TerritoryUserSetMap.get(ut.Territory2Id).add(ut.UserId);
            }
            else{
                set<ID> setUser = new set<ID>();
                setUser.add(ut.UserId);
                TerritoryUserSetMap.put(ut.Territory2Id,setUser);
            }
        }
        return TerritoryUserSetMap;
    }
    
    
}