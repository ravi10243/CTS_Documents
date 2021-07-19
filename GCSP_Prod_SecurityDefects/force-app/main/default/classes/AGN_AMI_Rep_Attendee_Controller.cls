/*
The class has been modified to add 
CR 24: "As an Australian Rep I can see the full list of Meeting Attendees so I can review my attendees in the context of others"
CR 23: Manage Attendees: Rep able to update attendee status to 'Attended' or 'Physically Attended' for In person events once Meeting is to complete: Cognizant Developer, Veeva SFMC Integration Wave 4 Date: 101/16/2020
12/02/2021 - Upgrading the TM1.0 version of the code to TM2.0 version
 Cognizant Developer 11-11-2020
*/
public without sharing class AGN_AMI_Rep_Attendee_Controller 
{
    public Medical_event_vod__c eventDetails{get; set;}
    public Boolean buttonToggle {get; set;}
    public Boolean buttonToggle2 {get; set;}
    public List<attendeeWrap> attendeeList {get; set;}
    public List<accountWrap> accountList {get; set;}
    public String inputName {get; set;}
	public String CountryCode {get; set;} // change for CR 24
    public Integer addStart {get; set;}
    public Integer addSize {get; set;}
    public Integer viewStart {get; set;}
    public Integer viewSize {get; set;}
    public Boolean disableAddPrevious {get; set;}
    public Boolean disableAddNext {get; set;}
    public Boolean disableViewPrevious {get; set;}
    public Boolean disableViewNext {get; set;}
    public Integer pageNumber {get; set;}
    public Integer totalPages {get; set;}
    public Integer viewPageNumber {get; set;}
    public Integer viewTotalPages {get; set;}
	public Set<string> repMarkCountryCode {get; set;} //CR 23
    Id meetingId;
    List<String> addedAccountList;
	List<String> sharedAccountIdList;// change for CR 24
    
    public AGN_AMI_Rep_Attendee_Controller()
    {
        meetingId = ApexPages.currentPage().getParameters().get('Id');
        eventDetails = [select id,name,Meeting_Type_Picklist_AGN__c,Country_Code__c, AMI_Event_Status_AGN__c 
                        from Medical_Event_vod__c where id = :meetingId];
        
        buttonToggle = ((eventDetails.AMI_Event_Status_AGN__c == AGN_AMI_Static_Labels.meetingStatusPlanned));
        /***** Start CR 23 *********/
		repMarkCountryCode=new Set<string>{'DE','AN','ES','CA'};
		if(!repMarkCountryCode.contains(eventDetails.Country_Code__c))
        buttonToggle2 = ((eventDetails.AMI_Event_Status_AGN__c != AGN_AMI_Static_Labels.meetingStatusPlanned) 
                         && (eventDetails.AMI_Event_Status_AGN__c != AGN_AMI_Static_Labels.meetingStatusLive));
		else
		buttonToggle2=true;	
		/***** End CR 23 *********/	
        addStart = 0;
        addSize = 10;
        viewStart = 0;
        viewSize = 10;
        disableAddPrevious = true;
        disableAddNext = false;
        disableViewPrevious = true;
        disableViewNext = false;
		CountryCode=eventDetails.Country_Code__c;// change for CR 24
        getAttendees();// change for CR 24
        getAccounts();
        
    }
    public void getAttendees()// change for CR 24
    {
		/***** start CR 24 ********/
		List<Account> accountListTemp = new List<Account>();
        sharedAccountIdList=new List<String>();
		List<Event_attendee_vod__c> attendeeListTemp=new List<Event_attendee_vod__c>();
        if(CountryCode=='AN')
		{
		attendeeListTemp = [Select Id, Account_vod__c, Account_vod__r.Name, Account_vod__r.IsPersonAccount, Account_vod__r.FirstName, Account_vod__r.LastName, Status_vod__c 
                                                        from Event_Attendee_vod__c 
                                                        where Medical_event_vod__c = :meetingId 
                                                        order by Account_vod__r.Name limit 1000];
        
		}
		else
		{
        //TM2.0 changes - start
		Map<Id,UserTerritory2Association> UserTerritoryCurrentUserMap = new  Map<Id,UserTerritory2Association>([Select UserId, Territory2Id, IsActive, Id  From UserTerritory2Association  Where isActive=true and userId =:UserInfo.getUserId()]);
		set<Id> TerritoryIdSet = new set<Id>();
		for (UserTerritory2Association ut:UserTerritoryCurrentUserMap.values()) {
			TerritoryIdSet.add(ut.Territory2Id);
		}
		list<Group> map_group = [Select Id, RelatedId from Group where Type='Territory' AND RelatedId IN : TerritoryIdSet];
		List<AccountShare> lst_AccountShare = [Select Id, UserOrGroupId, AccountId from AccountShare where ( UserOrGroupId IN : map_group OR  UserOrGroupId =:UserInfo.getUserId())AND RowCause IN ('Territory', 'TerritoryManual', 'TerritoryRule', 'Territory2AssociationManual')];
		//TM2.0 changes - end
            for (AccountShare accSh:lst_AccountShare)
                sharedAccountIdList.add(accSh.AccountId);
		
		attendeeListTemp = [Select Id, Account_vod__c, Account_vod__r.Name, Account_vod__r.IsPersonAccount, Account_vod__r.FirstName, Account_vod__r.LastName, Status_vod__c 
                                                        from Event_Attendee_vod__c 
                                                        where Account_vod__c in :sharedAccountIdList 
                                                        and Medical_event_vod__c = :meetingId 
                                                        order by Account_vod__r.Name limit 1000];
		
		}		
		/*****end CR 24************/
		attendeeList = new List<attendeeWrap>();
        addedAccountList = new List<String>();
        for(Event_attendee_vod__c attendee : attendeeListTemp)
        {
            attendeeList.add(new attendeeWrap(attendee));
            addedAccountList.add(attendee.Account_vod__c);
        }
        viewPageNumber = 1;
        Integer flowover = (math.mod(attendeeList.size(), viewSize) > 0) ? 1 : 0;
        viewTotalPages = attendeeList.size() / viewSize + flowover;
        if(viewTotalPages == 1)
            disableViewNext = true;
        else
            disableViewNext = false;
    }
    public void getAccounts()
    {
        system.debug(inputName);
        String query = '%' + inputName + '%';
        List<Account> newAccountList;
		/******* change for CR 24 start ****************/
		if(CountryCode!='AN')
		{
			if(inputName != null)
				newAccountList = [Select id, name, phone, PersonEmail,AGN_AMI_ENABLED__C, IsPersonAccount,AMI_Educational_Journey__c from Account 
								  where id not in :addedAccountList
								  and id in :sharedAccountIdList
								  and name LIKE :query and isPersonAccount = true
								  order by Name limit 1000];
			else
				newAccountList = [Select id, name, phone, PersonEmail,AGN_AMI_ENABLED__C, IsPersonAccount,AMI_Educational_Journey__c from Account 
								  where id not in :addedAccountList
								  and id in :sharedAccountIdList
								  and isPersonAccount = true
								  order by Name limit 1000];// change for CR 24
		}
		else
		{
			if(inputName != null)
        	newAccountList = [Select id, name, phone, PersonEmail,AGN_AMI_ENABLED__C, IsPersonAccount,AMI_Educational_Journey__c from Account 
                              where id not in :addedAccountList
                              and name LIKE :query and isPersonAccount = true
                              order by Name limit 1000];
        else
            newAccountList = [Select id, name, phone, PersonEmail,AGN_AMI_ENABLED__C, IsPersonAccount,AMI_Educational_Journey__c from Account 
                              where id not in :addedAccountList and isPersonAccount = true
                              order by Name limit 1000];
		}
        /******* change for CR 24 end ****************/
        accountList = new List<accountWrap>();
        for(Account acc:newAccountList)
        {
            accountList.add(new accountWrap(acc));
        }
        pageNumber = 1;
        Integer flowover = (math.mod(accountList.size(), addSize) > 0) ? 1 : 0;
        totalPages = accountList.size() / addSize + flowover;
        if(totalPages == 1)
            disableAddNext = true;
        else
            disableAddNext = false;
    }
    public void decline()
    {
        List<Event_attendee_vod__c> updateList = new List<Event_attendee_vod__c>();
        for(attendeeWrap al : attendeeList)
        {
            if(al.checked)
            {
                Event_attendee_vod__c attendee = al.attendee;
                attendee.Status_vod__c = 'Invitation Removed';
                updateList.add(attendee);
            }
        }
        try
        {
            if(!updateList.isEmpty())
            	update updateList;
        	ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.AGN_AMI_Rep_Attendee_Removed));
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
        
    }
    public void declineAll()
    {
        List<Event_attendee_vod__c> updateList = new List<Event_attendee_vod__c>();
        for(attendeeWrap al : attendeeList)
        {
            Event_attendee_vod__c attendee = al.attendee;
            attendee.Status_vod__c = 'Invitation Removed';
            updateList.add(attendee);
        }
        if(!updateList.isEmpty())
            update updateList;
    }
    
    public void attended()
    {
        List<Event_attendee_vod__c> updateList = new List<Event_attendee_vod__c>();
        for(attendeeWrap al : attendeeList)
        {
            if(al.checked)
            {
                Event_attendee_vod__c attendee = al.attendee;
                attendee.Status_vod__c = 'Physically-Attended';
                updateList.add(attendee);
            }
        }
        try
        {
            if(!updateList.isEmpty())
            	update updateList;
            ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.AGN_AMI_Rep_Attendee_Mark));
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
        
    }
    public void attendedAll()
    {
        List<Event_attendee_vod__c> updateList = new List<Event_attendee_vod__c>();
        for(attendeeWrap al : attendeeList)
        {
            Event_attendee_vod__c attendee = al.attendee;
            attendee.Status_vod__c = 'Physically-Attended';
            updateList.add(attendee);
        }
        try
        {
            if(!updateList.isEmpty())
            	update updateList;
        	ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.AGN_AMI_Rep_Attendee_Mark));
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
    
    public PageReference backToEvent()
    {
        PageReference pr = new PageReference('/'+eventDetails.Id);
        return pr;
    }
    
    public class attendeeWrap
    {
        public boolean checked {get; set;}
        public Event_attendee_vod__c attendee {get; set;}
        public attendeeWrap(Event_attendee_vod__c attendee)
        {
            this.checked = false;
            this.Attendee = attendee;
        }
    }
    public class accountWrap
    {
        public account acc {get;set;}
        public boolean checked {get;set;}
        public String accAttendee {get; set;}//AMI CR 3896
        public String accEJ {get; set;}// AMI CR-3990
        public accountWrap(Account a)
        {    
            this.acc = a;
            this.checked = false;
            accEJ=a.AMI_Educational_Journey__c;// AMI-CR-3990
            //AMI CR 3896 start
            if(a.AGN_AMI_ENABLED__C)
				accAttendee='AMI';
			else
				accAttendee='Non AMI';
            //AMI CR 3896 End
        } 
    }
    
    public void addtoEvent()
    {
        List<Event_Attendee_Vod__c> insertList = new list<Event_Attendee_Vod__c>();
        Id recordtypeid = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get('Portal Attendee').getRecordTypeId();
        for(accountWrap w : accountList)
        {
            if(w.checked)
            {
                Event_Attendee_Vod__c attendee = new Event_Attendee_Vod__c();
                attendee.Medical_Event_vod__c = meetingId;
                attendee.recordtypeid = recordtypeid;
                attendee.Account_vod__c = w.acc.id;
                insertList.add(attendee);
            }
        }
        system.debug(insertList);
        try
        {
            if(!insertList.isEmpty())
            	insert insertList;
        	ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.AGN_AMI_Rep_Attendee_Invited));
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
        system.debug(insertList);
        getAttendees(); // change for CR 24
        getAccounts();
        system.debug(insertList);
    }
    public void goToAddBegining()
    {
        addStart=0;
        pageNumber = 1;
        disableAddPrevious = true;
        disableAddNext = false;
    }
    public void goToAddPrevious()
    {
        addStart = addStart - addSize;
        pageNumber = pageNumber - 1;
        disableAddNext = false;
        if(pageNumber == 1)
            disableAddPrevious = true;
    }
    public void goToAddNext()
    {
        addStart = addStart + addSize;
        pageNumber = pageNumber + 1;
        disableAddPrevious = false;
        if(pageNumber == totalPages)
            disableAddNext = true;
    }
    public void goToAddLast()
    {
        addStart = (addSize - 1)*totalPages;
        pageNumber = totalPages;
        disableAddPrevious = false;
        disableAddNext = true;
    }
    public void goToViewBegining()
    {
        viewStart=0;
        viewPageNumber = 1;
        disableViewPrevious = true;
        disableViewNext = false;
    }
    public void goToViewPrevious()
    {
        viewStart = viewStart - viewSize;
        viewPageNumber = viewPageNumber - 1;
        disableViewNext = false;
        if(viewPageNumber == 1)
            disableViewPrevious = true;
    }
    public void goToViewNext()
    {
        viewStart = viewStart + viewSize;
        viewPageNumber = viewPageNumber + 1;
        disableViewPrevious = false;
        if(viewPageNumber == viewTotalPages)
            disableViewNext = true;
    }
    public void goToViewLast()
    {
        viewStart = (viewSize - 1)*viewTotalPages;
        viewPageNumber = viewTotalPages;
        disableViewPrevious = false;
        disableViewNext = true;
    }
}