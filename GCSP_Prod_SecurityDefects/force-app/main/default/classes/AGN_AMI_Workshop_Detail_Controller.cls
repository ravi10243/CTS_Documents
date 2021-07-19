public without sharing class AGN_AMI_Workshop_Detail_Controller 
{
    User user;
    // DQ - HCP Harmonization Start
    Account accountRecord;
    Contact contactRecord;
    // DQ - HCP Harmonization End
    String userCountryName;
    public String userLanguage {get; set;}
    
    public AMI_Workshop_AGN__c workshop {get; set;}
    public AMI_Workshop_Faculty_AGN__c primaryFaculty {get; set;}
    public List<AMI_Workshop_Faculty_AGN__c> faculties {get; set;}
    public List<AMI_Workshop_Agenda_AGN__c> agendas {get; set;}
    public AMI_Workshop_Attendee_AGN__c attendee {get; set;}
	public String clickedFaculty {get; set;}
    public AMI_Workshop_Faculty_AGN__c selectedFaculty {get; set;}
    public string attendeeStatus {get; set;}
    public String formattedDate {get; set;}
    public string deregId {get; set;}
    public string workshopDate {get; set;}
    public AMI_Web_Visibility_Settings_AGN__c AWV {get; set;}
    
    public AGN_AMI_Workshop_Detail_Controller()
    {
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails(); 
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        // DQ - HCP Harmonization Start
        accountRecord = userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;
        // DQ - HCP Harmonization End
        String workshopId = ApexPages.currentPage().getParameters().get('workshopId');
        AWV = AMI_Web_Visibility_Settings_AGN__c.getValues(userCountryName);
        
        workshop = [Select Id, Name_AGN__c, Location_AGN__c, Date_AGN__c, 
                    Detail_Header_AGN__c, Detail_Description_AGN__c, Address_AGN__c,
                    Cost_AGN__c, CurrencyIsoCode, Slots_AGN__c, Registration_Close_Date_AGN__c
                    from AMI_Workshop_AGN__c 
                    where Id =: workshopId limit 1];
        
        formattedDate = workshop.Date_AGN__c.format('hh:mm a');
        String workshopMonth;
        switch on workshop.Date_AGN__c.format('MM') {
            when '01' {	
                workshopMonth = Label.AGN_AMI_Jan;
            }
            when '02' {	
                workshopMonth = Label.AGN_AMI_Feb;
            }	
            when '03' {	
                workshopMonth = Label.AGN_AMI_Mar;
            }	
            when '04' {	
                workshopMonth = Label.AGN_AMI_Apr;
            }	
            when '05' {	
                workshopMonth = Label.AGN_AMI_May;
            }	
            when '06' {	
                workshopMonth = Label.AGN_AMI_Jun;
            }	
            when '07' {	
                workshopMonth = Label.AGN_AMI_Jul;
            }	
            when '08' {	
                workshopMonth = Label.AGN_AMI_Aug;
            }	
            when '09' {	
                workshopMonth = Label.AGN_AMI_Sep;
            }	
            when '10' {	
                workshopMonth = Label.AGN_AMI_Oct;
            }	
            when '11' {	
                workshopMonth = Label.AGN_AMI_Nov;
            }	
            when '12' {	
                workshopMonth = Label.AGN_AMI_Dec;
            }	
        }
		workshopDate = workshop.Date_AGN__c.format('dd') + ' ' + workshopMonth + ' ' + workshop.Date_AGN__c.format('yy');
        faculties = [Select Id, Is_Primary_AGN__c, AMI_Faculty_AGN__r.Name_AGN__c, 
                     Faculty_Brief_AGN__c,AMI_Faculty_AGN__r.Image_URL_AGN__c 
                     from AMI_Workshop_Faculty_AGN__c 
                     where AMI_Workshop_AGN__c =: workshopId 
                     order by Is_Primary_AGN__c desc, LastModifiedDate desc];
        agendas = [Select Agenda_Text_AGN__c 
                   from AMI_Workshop_Agenda_AGN__c 
                   where AMI_Workshop_AGN__c =: workshopId 
                   order by Sequence_AGN__c asc];
        List<AMI_Workshop_Attendee_AGN__c> attendeeList = [Select Status_AGN__c, Workshop_Details_AGN__c, Account_Details_AGN__c 
                                                           from AMI_Workshop_Attendee_AGN__c 
                                                           where AMI_Workshop_AGN__c =: workshopId 
                                                           and Account_AGN__c =: accountRecord.Id limit 1];
        List<AMI_Workshop_Attendee_AGN__c> otherAttendeeList = [Select Id 
                                                                from AMI_Workshop_Attendee_AGN__c 
                                                                where AMI_Workshop_AGN__c =: workshopId 
                                                               	and Status_AGN__c = 'Approved'];
        
        if(!attendeeList.isEmpty())
        {
            attendee = attendeeList[0];
            attendeeStatus = attendee.Status_AGN__c;
            if(attendeeStatus == 'Cancelled' && workshop.Registration_Close_Date_AGN__c < System.today())
                attendeeStatus = 'Closed';
            else if(attendeeStatus== 'Invited')
                 attendeeStatus = 'Open';
        }
        else if(!otherAttendeeList.isEmpty() && workshop.Slots_AGN__c <= otherAttendeeList.size())
        {
            attendeeStatus = 'Full';
        }
        else if(workshop.Registration_Close_Date_AGN__c < System.today())
        {
            system.debug(workshop.Registration_Close_Date_AGN__c + '++' + System.today());
            attendeeStatus = 'Closed';
        }
        else
        {
            attendeeStatus = 'Open';
        }
            
        if(!faculties.isEmpty())
            selectedFaculty = faculties[0];
        for(AMI_Workshop_Faculty_AGN__c faculty : faculties)
        {
            if(faculty.Is_Primary_AGN__c)
            {
                primaryFaculty = faculty;
                break;
            }
        }
    }
    
    
    
    // To avoid page error when the page is reached without workshop id
    public PageReference goToHome()
    {
        PageReference pr;
        if(ApexPages.currentPage().getParameters().get('workshopId')!=null)
            pr = null;
        else
            pr = new PageReference(System.Label.AGN_AMI_Home_Page);
        return pr;
    }
    
    // Method refreshes the highlighted faculty in the page.
    public PageReference changeSelectFaculty()
    {
        System.debug(clickedFaculty);
        for(AMI_Workshop_Faculty_AGN__c wf : faculties)
        {
            if(wf.Id == clickedFaculty)
               selectedFaculty = wf; 
        }
        return null;
    }
    
    // Method Saves the attendee Records
    public PageReference register()
    {
        List<AMI_Workshop_Attendee_AGN__c> isRegistered = [Select Id, Status_AGN__c, AMI_Workshop_AGN__r.Date_AGN__c 
                                                           from AMI_Workshop_Attendee_AGN__c 
                                                           where AMI_Workshop_AGN__c =: workshop.Id 
                                                           and Account_AGN__c =: accountRecord.Id 
                                                           Limit 1];
        AMI_Workshop_Attendee_AGN__c attendee;
        if(! isRegistered.isEmpty())
            attendee = isRegistered[0];
        else
        {
            attendee = new AMI_Workshop_Attendee_AGN__c();
            attendee.Account_AGN__c = accountRecord.Id;
            attendee.Contact_AGN__c = contactRecord.Id;
            attendee.AMI_Workshop_AGN__c = workshop.Id;            
        }
            
        attendee.Status_AGN__c = 'Approved';
        try
        {
            upsert attendee;
            attendeeStatus = 'Approved';
            system.debug('status@@@'+ attendee);
            sendNotification(attendee, true);
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
        }
        return null;
    }
    
    // Check and send notification to admins
    public void sendNotification(AMI_Workshop_Attendee_AGN__c attendee, boolean reg)
    {
        AMI_User_Settings_AGN__c aus = AMI_User_Settings_AGN__c.getValues(userCountryName);
        AMI_Workshop_Attendee_AGN__c attendeeDetail = [Select Workshop_Details_AGN__c,AMI_Workshop_AGN__r.Date_AGN__c, Account_Details_AGN__c 
                                                           from AMI_Workshop_Attendee_AGN__c where id =: attendee.Id Limit 1];
        system.debug('date@@@'+ attendeeDetail.AMI_Workshop_AGN__r.Date_AGN__c);
        String FormattedTime = attendeeDetail.AMI_Workshop_AGN__r.Date_AGN__c.format('HH:mm',aus.User_Timezone__c);
        system.debug('FormattedTime@@@'+ FormattedTime);
        if(AWV.Workshop_Notification_AGN__c)
        {
            system.debug('entering if@@@');
            EmailTemplate template;
            if(reg)  
                template = [SELECT DeveloperName, Id, body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'AGN_AMI_Workshop_Registration_Notification' limit 1];              
            else 
                template = [SELECT DeveloperName, Id, body, HtmlValue, Subject  FROM EmailTemplate WHERE DeveloperName = 'AGN_AMI_Workshop_Deregistration_Notification' limit 1];
            String htmlBody = template.HtmlValue;
            system.debug('htmlBody@@@' + htmlBody);
            
            system.debug(htmlBody);
            Map<String, String> mapBodyParams = new Map<String, String> 
            {
            	'{!AMI_Workshop_Attendee_AGN__c.Workshop_Details_AGN__c}' => attendeeDetail.Workshop_Details_AGN__c,
                '{!AMI_Workshop_Attendee_AGN__c.Account_Details_AGN__c}' => attendeeDetail.Account_Details_AGN__c,
                'AMI_Workshop_Attendee_AGN__c.FormattedTime' => FormattedTime
            };
            for (String key : mapBodyParams.keySet()) {
                htmlBody = htmlBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
                //plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
            }
            //template.Body = body;
            system.debug(template);
            system.debug(htmlBody);
            List<String> emailIdList = new List<String>();
            if(AWV.Workshop_Email_List_AGN__c.contains(';'))
            { 
                emailIdList = AWV.Workshop_Email_List_AGN__c.split(';');
                  if(!Test.isRunningTest())
                AGN_AMI_Utility_class.sendNotification(template, htmlBody, emailIdList, template.Subject, attendee.Id);
            }
            else if(! String.isBlank(AWV.Workshop_Email_List_AGN__c))
            {
                emailIdList.add(AWV.Workshop_Email_List_AGN__c);
                  if(!Test.isRunningTest())
                AGN_AMI_Utility_class.sendNotification(template, htmlBody, emailIdList, template.Subject, attendee.Id);
            }
        }
    }
    public void deregister()
    {
        AMI_Workshop_Attendee_AGN__c delRecord = [Select Id, Status_AGN__c, AMI_Workshop_AGN__r.Date_AGN__c  
                                                  from AMI_Workshop_Attendee_AGN__c 
                                                  where AMI_Workshop_AGN__c =: deregId
                                                  and Account_AGN__c =: accountRecord.Id
                                                  Limit 1
                                                 ];
        delRecord.Status_AGN__c = 'Cancelled';
        try
        {
            update delRecord;
        	attendeeStatus = 'Open';
            sendNotification(delRecord, false);
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
}