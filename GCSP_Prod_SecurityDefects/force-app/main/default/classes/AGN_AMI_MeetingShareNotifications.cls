global class AGN_AMI_MeetingShareNotifications implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        // Access initialState here 
        String query = 'Select UserOrGroupId, Parent.Meeting_Name_AGN__c, UserOrGroup.Email, Parent.Country_code__c, Parent.Description_vod__c, Parent.Start_Time_vod__c, Parent.Name ' 
            + 'from Medical_Event_vod__Share ' 
            + 'where Parent.RecordType.DeveloperName = \'' + AGN_AMI_Static_Labels.meetingRecordType + '\' ' 
            + 'and UserOrGroup.Email != null '
            + 'and RowCause = \'Manual\' ' 
            + 'and LastModifiedDate = YESTERDAY';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> batch)
    {
        List<Medical_Event_vod__Share> shareList = (List<Medical_Event_vod__Share>) batch;
        AGN_AMI_MeetingShareNotifications.triggerAMIEventShareNotifications(shareList);
    }
    global void finish(Database.BatchableContext BC) 
    {
        // Access initialState here 
    }
    public static void triggerAMIEventShareNotifications(List<Medical_Event_vod__Share> shareList)
    {
        AGN_AMI_MeetingShareNotifications.notifyReps(shareList);
        AGN_AMI_MeetingShareNotifications.sendNotification(shareList);
    }
    public static void createMeetingAlert()
    {
        List<Medical_Event_vod__c> newMeetingList;
        try
        {
            newMeetingList = [Select id, Meeting_Name_AGN__c, Name, Start_Time_vod__c, Country_Code__c 
                              from Medical_Event_vod__c 
                              where RecordType.DeveloperName = :AGN_AMI_Static_Labels.meetingRecordType
                              and createdDate = YESTERDAY];
        }
        catch(Exception ex)
        {
            //Error Logger to be added
        }
        List<Alert_vod__c> createAlerts = new List<Alert_vod__c>();
        for(Medical_Event_vod__c me : newMeetingList)
        {
            Alert_vod__c alert = new Alert_vod__c();
            alert.Activation_Date_vod__c = DateTime.Now();
            alert.Expiration_Date_vod__c = me.Start_Time_vod__c;
            alert.AMI_Related_Meeting_AGN__c = me.Meeting_Name_AGN__c;
            alert.Name = AGN_AMI_Static_Labels.alertTitle.get(me.Country_Code__c);
            alert.Public_vod__c = false;
            alert.Dismissible_vod__c = false;
            alert.Priority_vod__c = 'Important';
            alert.Alert_Text_vod__c = AGN_AMI_Static_Labels.alertText1.get(me.Country_Code__c) 
                + ' ' + me.Name + AGN_AMI_Static_Labels.alertText2.get(me.Country_Code__c)
                + ' ' + me.Start_Time_vod__c 
                + ' ' + AGN_AMI_Static_Labels.alertText3.get(me.Country_Code__c);
            createAlerts.add(alert);
        }
        try
        {
            if(!createAlerts.isEmpty())
                insert createAlerts;            
        }
        catch(Exception ex)
        {
            //Error Logger to be added
        }
    }
    public static void notifyReps(List<Medical_Event_vod__Share> shareList) 
    {
        AGN_AMI_MeetingShareNotifications.createMeetingAlert();
        Set<String> uniqueMeetings = new Set<String>();
        for(Medical_Event_vod__Share share : shareList)
        {
            uniqueMeetings.add(share.Parent.Meeting_Name_AGN__c);
        }
        List<Alert_vod__c> alertList = [Select id, AMI_Related_Meeting_AGN__c from Alert_vod__c where AMI_Related_Meeting_AGN__c in: uniqueMeetings];
        List<Alert_User_Action_vod__c> insertAlertUser = new List<Alert_User_Action_vod__c>();
        for(Medical_Event_vod__Share share : shareList)     
        {
            for(Alert_vod__c alert : alertList)
            {
                if(share.Parent.Meeting_Name_AGN__c == alert.AMI_Related_Meeting_AGN__c)
                {
                    Alert_User_Action_vod__c alertUser = new Alert_User_Action_vod__c();
                    alertUser.Alert_vod__c = alert.Id;
                    alertUser.User_vod__c = share.UserOrGroupId;
                    insertAlertUser.add(alertUser);
                }
                
            }
        }
        try
        {
            if(!insertAlertUser.isEmpty())
                insert insertAlertUser;            
        }
        catch(Exception ex)
        {
            //Error Logger to be added
        }
    }
    public static void sendNotification(List<Medical_Event_vod__Share> shareList)
    {
        EmailTemplate template = [SELECT DeveloperName, Id, Body, HtmlValue, Subject 
                                  FROM EmailTemplate 
                                  WHERE DeveloperName = :AGN_AMI_Static_Labels.meetingNotificationEMail 
                                  limit 1];
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Medical_Event_vod__Share share : shareList)
        {
            String htmlBody = template.HtmlValue;
            String plainBody = template.Body;
            Map<String, String> mapBodyParams = new Map<String, String> 
            {
                '{!Medical_Event_vod__c.Name}' => share.Parent.Name,
                '{!Medical_Event_vod__c.Start_Time_vod__c}' => share.Parent.Start_Time_vod__c.format(),
                '{!Medical_Event_vod__c.Description_vod__c}' => share.Parent.Description_vod__c,
                '{!$Label.AGN_AMI_Meeting_Share_P1}' => AGN_AMI_Static_Labels.emailAlertText1.get(share.Parent.Country_Code__c),
                '{!$Label.AGN_AMI_Meeting_Share_P2}' => AGN_AMI_Static_Labels.emailAlertText2.get(share.Parent.Country_Code__c),
                '{!$Label.AGN_AMI_Meeting_Share_P3}' => AGN_AMI_Static_Labels.emailAlertText3.get(share.Parent.Country_Code__c),
                '{!$Label.AGN_AMI_Meeting_Share_P4}' => AGN_AMI_Static_Labels.emailAlertText4.get(share.Parent.Country_Code__c)
            };
            for (String key : mapBodyParams.keySet()) 
            {
                htmlBody = htmlBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
                plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
            }
            String subject = AGN_AMI_Static_Labels.emailAlertSubject.get(share.Parent.Country_Code__c);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> toEmails = new List<String>();
            toEmails.add(share.UserOrGroup.Email);
            email.setToAddresses(toEmails);
            email.setTemplateId(template.Id);
            email.setSaveAsActivity(false);
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);
            emailList.add(email);
        }
        Messaging.sendEmail(emailList, true);
    }
}