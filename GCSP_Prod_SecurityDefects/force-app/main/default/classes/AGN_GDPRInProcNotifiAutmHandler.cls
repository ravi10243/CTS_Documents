/** 
******************************************************************************
Apex Class Name - AGN_GDPRInProcNotifiAutmHandler
//Version - 1.0
Version - 2.0
Created Date - Aug 07, 2018
Modified Date - Feb 24, 2021
Modified By - SG
Function - Trigger handler for AGN_GDPRInProcNotifiAutm

Modification Log : 
--------------------------------------------------------------------------------

* Developer               Date                 Description
* -------------------     ------------         -----------------------
* Cognizant Team        08/07/2018           Original Version
* SG                    02/24/2021           R2_2021 PMO No:3629 HCP primary address update based on primary affiliation update.
**********************************************************************************
*/ 

public with sharing class AGN_GDPRInProcNotifiAutmHandler {
    
    /**
*@description: To handle After Insert trigger for AGN_GDPRInProcNotifiAutm
*@return: void
**/    
    public static void execute(){
        String accStatusStr = 'Direct Mail Failed';
        String accStatusStrInPersonDel = 'In-Person Notification Delivered';
        String accStatusStrInPersonDelFailed = 'In-Person Notification Delivery Failed';
        //Added by Brazil LGPD team to enable the task creation for in-person delivery for Brazil//
        String accStatusStrInPersonDelInit = 'In-Person Notification Process Initiated';
        String lgpdStatus = 'Email Notification Failed';
        String lgpdStatus2 = 'Unable to notify via Email';
        Set<Id> accIdForStsUpd = new Set<Id>();
        List<Account> accForStsUpd = new List<Account>();
        List<Account> accForLGPDStsUpd = new List<Account>();
        //Added by Brazil LGPD team to enable the task creation for in-person delivery for Brazil//
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> accTaskIdSet = new Set<Id>();
        Set<Id> userRoleIdSet = new Set<Id>();
        Set<String> territoryVodNameSet = new Set<String> ();
        Set<id> UsedAccSet = new Set<id>();
        Set<id> RemaningAccSet = new Set<id>();
        
        Map<Id,String> accIdToAccMap = new Map<Id,String>();
        Map<Id,String> TerritoryIdTerritoryName = new Map<Id,String>();
        Map<Id, List<id>> accIdTerritoryNameMap = new Map<Id, List<id>>();
        Map<id,Set<id>> TerritoryUserSetMap = new Map<id,Set<id>>();
        Map<String,String> csroles = new  Map<String,String>();
        //Map<String,String> userIDByRoleNameMap = new Map<String,String>();
        Map<String,List<Id>> userIDByRoleNameMap = new Map<String,List<Id>>();
        Map<id,set<id>> accountIdUserIdMap = new Map<id,set<id>>();                    
        Map<id,string> countrymap =new Map<id,string>();
        string Enabledcountry = system.label.AGNGDPRCountries;
        List<string> gdprcountries = Enabledcountry.split(';');
        for(Country_vod__c cncode: [SELECT Id,Name FROM Country_vod__c where Name In:gdprcountries]){   
            if(!countrymap.containsKey(cncode.Id))
            {
            countrymap.put(cncode.Id,cncode.Name);
            }
        }
        List<id> checkAccRepeationlst = new List<id>();
        List<Task> taskList = new List<Task>();
        List<Task> lstTaskToInsert = new List<Task>();
        List<Task> notifiedTask = new List<Task>();
       
        //Capture only accounts where status is updated to desired status. 
        for(Account acc : (List<Account>) trigger.new){
            
            string Country_Code = countrymap.get(acc.Country_vod__c);//Added for Brazil as a part of Brazil LGPD project//
            
        /* List<Country_vod__c> CCode = [SELECT Id,name FROM Country_vod__c WHERE Id = :acc.Country_vod__c limit 1];
          string Country_Code = String.valueOf(CCode[0].name);*/
            //Capture only accounts where Status has been updated to Direct Mail Failed.
            if(acc.Country_vod__c!=null)
            {
            
             //Country_Code !='BR' is added as a condition parameter to implement this for countries except Brazil as a part of Brazil LGPD project//   
            if(Country_Code !='BR' && acc.GDPR_Notification_Status_AGN__c != ((Account)trigger.oldMap.get(acc.Id)).GDPR_Notification_Status_AGN__c 
               && acc.GDPR_Notification_Status_AGN__c == accStatusStr 
               && acc.GDPR_Notification_Received_AGN__c == false 
               && !string.isBlank(Country_Code)
               && System.label.AGNGDPRCountries.containsIgnoreCase(Country_Code)){
                   accIdSet.add(acc.Id);
                   accIdToAccMap.put(acc.Id, acc.Lastname);
               }
                //Added as a extra condition to implement this for Brazil as a part of Brazil LGPD project
                else IF(Country_Code =='BR' && acc.LGPD_Notification_Status_AGN__c != ((Account)trigger.oldMap.get(acc.Id)).LGPD_Notification_Status_AGN__c 
               && (acc.LGPD_Notification_Status_AGN__c == lgpdStatus || acc.LGPD_Notification_Status_AGN__c==lgpdStatus2)
               && acc.GDPR_Notification_Received_AGN__c == false 
               && !string.isBlank(Country_Code)
               && System.label.AGNGDPRCountries.containsIgnoreCase(Country_Code)){
                    accIdSet.add(acc.Id);
                   accIdToAccMap.put(acc.Id, acc.Lastname);
                }
                //Added as a extra condition to implement this for Brazil as a part of Brazil LGPD project//
                
                //Country_Code !='BR' is added as a condition parameter to implement this for countries except Brazil as a part of Brazil LGPD project//
            }else If(Country_Code != 'BR' && ((Account)trigger.oldMap.get(acc.Id)).GDPR_Notification_Status_AGN__c == accStatusStr  && 
                        (acc.GDPR_Notification_Status_AGN__c == accStatusStrInPersonDel || acc.GDPR_Notification_Status_AGN__c == accStatusStrInPersonDelFailed)){
                            accTaskIdSet.add(acc.Id);
                        }
            //Added as a extra condition to implement this for Brazil as a part of Brazil LGPD project//
            else If(Country_Code == 'BR' && (((Account)trigger.oldMap.get(acc.Id)).LGPD_Notification_Status_AGN__c == lgpdStatus ||((Account)trigger.oldMap.get(acc.Id)).LGPD_Notification_Status_AGN__c == lgpdStatus2)  && 
                    (acc.LGPD_Notification_Status_AGN__c == accStatusStrInPersonDel || acc.LGPD_Notification_Status_AGN__c == accStatusStrInPersonDelFailed)){
                       accTaskIdSet.add(acc.Id); 
                    }
            //Added as a extra condition to implement this for Brazil as a part of Brazil LGPD project//   
               
        } //acc_loop_Ends.    
        try{
            if(!accIdSet.isEmpty()){               
                List<MC_Cycle_Plan_Target_vod__c> lstMCPlan = new List<MC_Cycle_Plan_Target_vod__c>(); 
                lstMCPlan = [SELECT id
                             ,Target_vod__c
                             ,Cycle_Plan_vod__r.ownerid,Target_vod__r.Country_vod__r.Name 
                             FROM MC_Cycle_Plan_Target_vod__c WHERE Target_vod__c = :accIdSet 
                             AND Status_vod__c ='Active_vod' AND Cycle_Plan_vod__r.Status_vod__c  = 'In_Progress_vod'];
                
                if(lstMCPlan.size()>0)
                {
                    list<Task> tskList = new list<Task>();               
                    for(MC_Cycle_Plan_Target_vod__c MCPT : lstMCPlan){
                        /*if(!checkAccRepeationlst.contains(MCPT.Target_vod__c)){
                            checkAccRepeationlst.add(MCPT.Target_vod__c);
                            UsedAccSet.add(MCPT.Target_vod__c);                        
                        //UsedAccSet.add(MCPT.Target_vod__c);*/
                        Task newTask = new Task();
                        newTask.WhatId = MCPT.Target_vod__c;
                        newTask.OwnerId = MCPT.Cycle_Plan_vod__r.ownerid;
                        if(MCPT.Target_vod__r.Country_vod__r.Name=='BR')
                            newTask.Subject = 'Please Notify In Person or Update the correct Email Id of the HCP';
                        else
                            newTask.Subject = 'Notify In-person';// + ;
                        //newTask.InPerson_Notification_Status_AGN__c= 'Inperson Notification Initiated';
                        newTask.Priority = 'High';
                        newTask.ReminderDateTime = datetime.now();
                        newTask.IsReminderSet = true;
                        newTask.AGN_GDPRNotificationAlert__c = true; 
                        newTask.ActivityDate = System.today()+10;
                        newTask.Status = 'In Progress';                       
                        //newTask.WhatId = accIdToAccMap.keyset()[0]; //accId;
                        
                        //Added by BRAZIL LGPD team for updating the LGPD Notification Status of accounts after task creation//
                        accIdForStsUpd.add(newTask.WhatId);
                        //Added by BRAZIL LGPD team for updating the LGPD Notification Status of accounts after task creation//
                        
                        tskList.add(newTask);
                        
                    }
                    System.debug('tskList : '+tskList);
                    insert tskList;
                    
                    //Added by BRAZIL LGPD team for updating the LGPD Notification Status of accounts after task creation//
                    accForStsUpd=[select Id,Country_Code__c,LGPD_Notification_Status_AGN__c from Account where Id = :accIdForStsUpd];
                    for(Account a : accForStsUpd){
                        
                        if(a.Country_Code__c=='BR'){
                            a.LGPD_Notification_Status_AGN__c=accStatusStrInPersonDelInit;
                            accForLGPDStsUpd.add(a);
                        }
                    }
                    update accForLGPDStsUpd;
                    //Added by BRAZIL LGPD team for updating the LGPD Notification Status of accounts after task creation//
                }
                
                else{
                    list<String> lstNotNullTerritoryVod = new list<String>();
                    //Account want to get the list of territories for is accIdSet here.                
                    List<Account_Territory_Loader_vod__c> accountTerritoryLoaders = new List<Account_Territory_Loader_vod__c>([Select Id
                                                                                                                               ,Territory_vod__c, Account_vod__c, Account_vod__r.Country_vod__c, Account_vod__r.Country_Code__c  FROM 
                                                                                                                               Account_Territory_Loader_vod__c where 
                                                                                                                               Account_vod__c in : accIdSet
                                                                                                                               AND Account_vod__r.Country_Vod__c != null order by CreatedDate asc limit 1]);
                    system.debug('accountTerritoryLoaders'+ accountTerritoryLoaders);
                    System.debug('accountIdUserIdMap.size() : '+accountIdUserIdMap.size());
                    if(!accountTerritoryLoaders.isEmpty())
                    {
                        List<id> territoryIdlst = new List<id>();
                        for(Account_Territory_Loader_vod__c atl : accountTerritoryLoaders ){
                            
                            if(atl.Territory_vod__c != null){
                                list<String> tempList = new list<String>();                           
                                if(atl.Territory_vod__c.startsWith(';')){
                                    atl.Territory_vod__c.removeStart(';');
                                    atl.Territory_vod__c.removeEnd(';');
                                }
                                
                                //tempList = atl.Territory_vod__c.split(';');
                                for(String str :atl.Territory_vod__c.split(';')){
                                    if(!String.isBlank(str)){
                                        tempList.add(str.trim());
                                    }
                                }
                                System.debug('tempList' +tempList);
                                for(string s:tempList){
                                    if(!String.isBlank(s.trim())){
                                        lstNotNullTerritoryVod.add(s.trim());
                                    }
                                }
                                System.debug('lstNotNullTerritoryVod : '+lstNotNullTerritoryVod);
                            }
                            else if(atl.Territory_vod__c == null )
                            {
                                //csroles.put(atl.Account_vod__c,GDPR_InProcNotifiAutmHelper.getRoleCustomSetting(GDPR_InProcNotifiAutmHelper.getCountryCode(atl.Account_vod__r.Country_vod__c)));
                                csroles.put(atl.Account_vod__c,AGN_GDPRInProcNotifiAutmHelper.getRoleCustomSetting(countrymap.get(atl.Account_vod__r.Country_vod__c)));
                            }
                            System.debug('lstNotNullTerritoryVod : '+lstNotNullTerritoryVod);
                            for(String tname : lstNotNullTerritoryVod){
                                if(tname != null && !String.isBlank(tname))
                                {
                                    system.debug(tname+' test '+ AGN_GDPRInProcNotifiAutmHelper.getTerritoryByName(tname.toUpperCase().trim()));
                                    //Avilable Territory
                                    // territoryIdlst.add(id.valueOf(AGN_GDPRInProcNotifiAutmHelper.getTerritoryByName(tname.toUpperCase()).id)); 
                                    territoryIdlst.add(AGN_GDPRInProcNotifiAutmHelper.getTerritoryByName(tname.toUpperCase()).id); 
                                    System.debug('territory id : '+AGN_GDPRInProcNotifiAutmHelper.getTerritoryByName(tname.toUpperCase()).id);
                                    System.debug('territoryIdlst : '+territoryIdlst);
                                }
                            }//END For
                            
                            //To maintain accountId and set of corresponding territory
                            //if(!accIdTerritoryNameMap.containsKey(atl.Account_vod__c)){
                            accIdTerritoryNameMap.put(atl.Account_vod__c,territoryIdlst); 
                            // }
                            // accIdTerritoryNameMap.put(atl.Account_vod__c,territoryIdlst); 
                            territoryVodNameSet.addAll(lstNotNullTerritoryVod); //To capture unique names.    
                        }//End For
                        
                        System.debug('territoryVodNameSet : '+territoryVodNameSet);
                        System.debug('accIdTerritoryNameMap : '+accIdTerritoryNameMap);
                        //Fetch all territory Users by Territory ID
                        TerritoryUserSetMap = AGN_GDPRInProcNotifiAutmHelper.getTerritoryUsers();
                        
                        //Map<id,set<id>> accountIdUserIdMap = new Map<id,set<id>>();                    
                        if(accIdTerritoryNameMap.size()>0){
                            for(id accId:accIdTerritoryNameMap.keySet()){
                                for(id tId:accIdTerritoryNameMap.get(accId)){    
                                    if(TerritoryUserSetMap.containsKey(tId))
                                    {
                                        if(!accountIdUserIdMap.containsKey(accId)){
                                            accountIdUserIdMap.put(accId, TerritoryUserSetMap.get(tId));
                                            System.debug('accountIdUserIdMap : '+accountIdUserIdMap);
                                        }
                                        else{
                                            set<id> setWholeUserId = new Set<id>();
                                            setWholeUserId.addAll(accountIdUserIdMap.get(accId));
                                            setWholeUserId.addAll(TerritoryUserSetMap.get(tId));
                                            accountIdUserIdMap.put(accId,setWholeUserId);
                                        }
                                    }
                                }
                            } 
                        } 
                        
                        
                        list<id> lstTempOwnerId = new List<id>();
                        System.debug('accountIdUserIdMap : '+accountIdUserIdMap);
                        for(id accId:accountIdUserIdMap.keyset()){
                            System.debug(accountIdUserIdMap.get(accId).size());
                            //  id tempOwnerId = new List <Id>(accountIdUserIdMap.get(accId))[0];
                            for(id ids : accountIdUserIdMap.get(accId)){
                                lstTempOwnerId.add(ids); 
                            }
                            Account x=[select ID,Name,Country_code__c from Account where Id = :accId];//Added by Brazil LGPD team//
                            lstTaskToInsert.addAll(AGN_GDPRInProcNotifiAutmHelper.createTask(accId,x,lstTempOwnerId,'Notify In-person ',
                                                                                             'Inperson Notification Initiated','High',datetime.now(), true));                    
                        }
                        
                    }//End IF
                    if(accountTerritoryLoaders.size() == 0 || accountIdUserIdMap.size() == 0) //if Empty
                    {
                        //Condtion
                        system.debug('test_1a '+ (List<Account>)trigger.new);
                        for(Account acc :(List<Account>)trigger.new)
                        {
                            //csroles.put(acc.id,GDPR_InProcNotifiAutmHelper.getRoleCustomSetting(GDPR_InProcNotifiAutmHelper.getCountryCode(acc.Country_vod__c)));
                            csroles.put(acc.id,AGN_GDPRInProcNotifiAutmHelper.getRoleCustomSetting(countrymap.get(acc.Country_vod__c)));
                            system.debug('test_1b '+ csroles);
                        }
                    }    
                    
                    List<id> uidList = new List<id>();
                    for(User u : [Select id, UserRole.Name, UserRoleId from User where UserRole.Name IN : csroles.values() AND isactive = true])
                    {
                        uidList.add(u.id);
                        userIDByRoleNameMap.put(u.UserRole.Name,uidList );
                    }    
                    system.debug('test_2a '+uidList);
                    System.debug('userIDByRoleNameMap : '+userIDByRoleNameMap);
                    for(Id accid : csroles.keySet())
                    {
                        System.debug('::::::::::'+csroles.get(accid));
                        System.debug('::::::::::'+userIDByRoleNameMap.get(csroles.get(accid)));
                        if(csroles.get(accid) != null && userIDByRoleNameMap.get(csroles.get(accid)) != null){
                            Account y=[select ID,Name,Country_code__c from Account where Id = :accId];//Added by Brazil LGPD team//
                            lstTaskToInsert.addAll(AGN_GDPRInProcNotifiAutmHelper.createTask(accid,y,
                                                                                             userIDByRoleNameMap.get(csroles.get(accid))
                                                                                             ,'Notify Inperson '
                                                                                             ,'Inperson Notification Initiated'
                                                                                             ,'High'
                                                                                             ,datetime.now()
                                                                                             , true)); 
                        }   
                    }
                    
                    if(!lstTaskToInsert.isEmpty()){
                        insert lstTaskToInsert;
                        
                        //Added by BRAZIL LGPD team for updating the LGPD Notification Status of accounts after task creation//
                        for(Task t : lstTaskToInsert){
                           accIdForStsUpd.add(t.WhatId); 
                        }
                    accForStsUpd=[select Id,Country_Code__c,LGPD_Notification_Status_AGN__c from Account where Id = :accIdForStsUpd];
                    for(Account a : accForStsUpd){
                        if(a.Country_Code__c=='BR'){
                            a.LGPD_Notification_Status_AGN__c=accStatusStrInPersonDelInit;
                            accForLGPDStsUpd.add(a);
                        }
                    }
                    update accForLGPDStsUpd;
                        //Added by BRAZIL LGPD team for updating the LGPD Notification Status of accounts after task creation//
                    }
                }
            }//IF accIdSet
            
        }Catch (System.EmailException ex) {
            System.debug('============== email exception caught ==============');
            System.debug(ex.getMessage());
        }
        if(!accTaskIdSet.isEmpty())
        {
            for(Account acc : [Select id , (Select id from Tasks where AGN_GDPRNotificationAlert__c = true) 
                               from Account Where id IN : accTaskIdSet])
            {
                for(Task tsk : acc.Tasks)
                {
                    tsk.Status = 'Completed'; 
                    notifiedTask.add(tsk);
                }
            }
            if(!notifiedTask.isEmpty()) 
            {
                update notifiedTask;
            }
        }
    }//End Method
    
    
   //R2_2021 PMO No:3629 ->HCP primary address update based on primary affiliation update.
    public void accountPrimaryAddressChange(Map<ID,ID> hcpHcaMap){
     List<Address_vod__c> addList = new List<Address_vod__c>(); 
     try{        
     For(Address_vod__c add :[Select account_vod__c,Primary_vod__c,Controlling_Address_vod__c,Controlling_Address_vod__r.Primary_vod__c,Controlling_Address_vod__r.Account_vod__r.Id from Address_vod__c where account_vod__c in :hcpHcaMap.keySet()]){
    
        if((add.Controlling_Address_vod__r.Account_vod__r.Id != hcpHcaMap.get(add.account_vod__c)) && (add.Primary_vod__c == true)){
            
             if(Schema.sObjectType.Address_vod__c.fields.Primary_vod__c.isUpdateable()){
                 add.Primary_vod__c = False;
             }
            addList.add(add);
        }
       else if((add.Controlling_Address_vod__r.Account_vod__r.Id == hcpHcaMap.get(add.account_vod__c)) && (add.Controlling_Address_vod__r.Primary_vod__c==TRUE) && (add.Primary_vod__c == False)){
            
           if(Schema.sObjectType.Address_vod__c.fields.Primary_vod__c.isUpdateable()){
                 add.Primary_vod__c = TRUE;
             }
            addList.add(add);
        }
      }
        if(addList.size()>0){
           if(Schema.sObjectType.Address_vod__c.isUpdateable()){
            Update addList;
           }
        }
     }Catch(Exception ex){
         
         AGN_Error_Logger.createExceptionsLog(ex,'AGN_GDPRInProcNotifiAutmHandler','accountPrimaryAddressChange','Address Update failed from AGN_GDPRInProcNotifiAutmHandler');
     }
   }
    //End of R2_2021 PMO No:3629 
}