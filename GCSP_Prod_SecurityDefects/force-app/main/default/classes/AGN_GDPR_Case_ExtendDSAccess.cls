/* 
@Class name : AGN_GDPR_Case_ExtendDSAccess
@Createdate : 12.07.2019
@modified date: 08.03.2020
@Author : GDPR Case management Project Team
@Description: This is batch class to extend users access on Case. 
@Change Done: Requirement DSRm 25, DSRm Release 2
*/

public class AGN_GDPR_Case_ExtendDSAccess implements Schedulable
{
    public void execute(SchedulableContext SC)
    {
        List<User> UserList = new List<User>();
        List<Case> CaseList = new List<Case>(); 
        Map<Id, Case> mapUserCase = new Map<Id, Case>();
        set <Id> userContactId = new set<Id>();
        List<User> ActiveUser = [SELECT Id,ContactId,LastLoginDate,Access_Till_AGN_GDPR__c,
                                 First_Notification_AGN_GDPR__c,Second_Notification_AGN_GDPR__c,
                                 Number_of_Notification_AGN_GDPR__c  
                                 FROM User WHERE IsActive = true AND Position_AGN__c IN ('GDPR','CCPA')
                                 AND Access_Till_AGN_GDPR__c!=null];

        if(ActiveUser.size() > 0)
        {
            for(user objUser : ActiveUser)
            {
                userContactId.add(objUser.ContactId);
            }
            List<Case> lstCase = New List<Case>();
            lstCase = [Select Id, Need_Extension_AGN_GDPR__c,
                       CaseNumber,Currently_Accessible_AGN__c,
                       ContactId from Case where ContactId in : userContactId];
            
            for(Case ObjCase : lstCase)
            {
                if(ObjCase.Currently_Accessible_AGN__c)
                {
                    mapUserCase.put(ObjCase.ContactId, ObjCase);
                }
            }
            
            System.debug('Active Case List are' +mapUserCase);
            List<AGN_GDPR_LoginExtension__c> CSDays = AGN_GDPR_LoginExtension__c.getAll().values();
            Integer DBefNotify = Integer.valueOf(CSDays[0].Day_Before_Notification_AGN_GDPR__c);
            for(user coluser : ActiveUser)
            {
                user finaluserlist = new user();
                case objcasenew = new case();
                case objcaseupdate = new case();

                if(date.today() >= coluser.Access_Till_AGN_GDPR__c)
                {
                    System.debug('Inside Deactivation Loop');
                    if(mapUserCase.size() > 0)
                    {
                        objcasenew = mapUserCase.get(coluser.ContactId);
                        system.debug('==> Check Value of Map ' + objcasenew);
                        system.debug('==> UserContactId : ' + coluser.ContactId);
                        if(!objcasenew.Need_Extension_AGN_GDPR__c)
                        {
                            System.debug('User should be deactivated');
                            finaluserlist.Id = coluser.Id;
                            finaluserlist.IsActive = false; //deactivate the user
                            finaluserlist.User_active_date_AGN__c = null;
                            objcaseupdate.Currently_Accessible_AGN__c = false;
                            objcaseupdate.Id = objcasenew.Id;
                            UserList.add(finaluserlist);
                            CaseList.add(objcaseupdate);
                        }
                    }
                    else
                    {
                        System.debug('User should be deactivated');
                        finaluserlist.Id = coluser.Id;
                        finaluserlist.IsActive = false; //deactivate the user
                        finaluserlist.User_active_date_AGN__c = null;
                        objcaseupdate.Currently_Accessible_AGN__c = false;
                        objcaseupdate.Id = objcasenew.Id;
                        UserList.add(finaluserlist);
                        CaseList.add(objcaseupdate);
                    }
                }
                else if(date.today() == (coluser.Access_Till_AGN_GDPR__c - DBefNotify))
                {
                    System.debug('Before Deactivation Date');
                    if(coluser.First_Notification_AGN_GDPR__c != true)
                    {
                        System.debug('It is the time for sending first notification');
                        finaluserlist.First_Notification_AGN_GDPR__c = true;
                        finaluserlist.Number_of_Notification_AGN_GDPR__c = '0';
                        finaluserlist.Id = coluser.Id;
                        UserList.add(finaluserlist);
                    }
                    else if(coluser.Second_Notification_AGN_GDPR__c != true)
                    {
                        System.debug('It is the time for sending second notification');
                        finaluserlist.Second_Notification_AGN_GDPR__c = true;
                        finaluserlist.Id = coluser.Id;
                        UserList.add(finaluserlist);
                    }
                }
            }
            if(UserList.size() > 0)
            {            
                update UserList;
                System.debug('The Updated User List is' +UserList);
            }
            if(CaseList.size() > 0)
            {
                Set<Id> SetCaseId = new Set<Id>();
                for(Case C : CaseList)
                {
                    SetCaseId.add(C.Id);
                }
                CaseInaccessible(SetCaseId);
                System.debug('The Updated Case List is' +CaseList);
            } 
        }
    }
    
    @future
    public static void CaseInaccessible(Set<Id> CId)
    {
        List<case> CaseList = [Select Id, Need_Extension_AGN_GDPR__c,Currently_Accessible_AGN__c, CaseNumber, ContactId from Case where Id in :CId];
        if(CaseList.size()>0)
            {
            system.debug('Process Builder ==> ' + CaseList);
            Case objCase = new Case();
            objcase.Id = CaseList[0].Id;      
            objcase.Currently_Accessible_AGN__c = false;            
            update objcase;
            }
    }
    
}