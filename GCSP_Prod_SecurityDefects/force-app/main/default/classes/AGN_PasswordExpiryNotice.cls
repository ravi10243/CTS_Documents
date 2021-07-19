global class AGN_PasswordExpiryNotice implements Database.Batchable<SObject>{

  
  
   global Database.QueryLocator start(Database.BatchableContext bc) {
            
            
            Datetime remindDate = DateTime.Now().AddDays(-83); //7 days before expiry, expiry being 90days after password reset
            Datetime remindDate2 = DateTime.Now().AddDays(-84);
            
           
            system.debug('date...'+remindDate );
            return Database.getQueryLocator(
                [SELECT Id, Name, Email, FirstName, LastPasswordChangeDate, Country_Code__c FROM User 
                WHERE IsActive = True AND LastPasswordChangeDate<:remindDate AND LastPasswordChangeDate>:remindDate2 AND Country_Code__c!='' ]
            );
            
    }
    
    
   global void execute(Database.BatchableContext BC, List<User> scope){
   
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            AGN_Settings__c settings = AGN_Settings__c.getOrgDefaults();
            String Notify_Country = settings.Password_Expiry_Notify_AGN__c;
            Datetime ExpiryDate;
            String ChngPassURL = URL.getSalesforceBaseUrl().toExternalForm() + '/_ui/system/security/ChangePassword?';
            system.debug('URL.....'+ChngPassURL);
                        
            system.debug('Settings....'+Notify_Country);
            for(User m : scope) {
            
             IF (Notify_Country.contains(m.Country_Code__c)){
             
                ExpiryDate = m.LastPasswordChangeDate.AddDays(90);
             
                List<String> toAddresses = new List<String>();
                List<String> bccAddresses = new List<String>();          
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                toAddresses.add(m.Email);
                mail.setToAddresses(toAddresses);
                mail.setSubject(System.Label.AGN_Subject_PassExpiry);
                bccAddresses.add('CognizantVeevaSupport@cognizant.com');
                mail.setBccAddresses(bccAddresses);
                String messageBody = '<html><body style="background-color:#D5D8DC;"><table style="background-color:white; height: 500px; margin-left: auto; margin-right: auto;" width="550"><tbody><tr><td><p>&nbsp;</p><hr size="5" COLOR="#2532bd"/><p><span style="color: #2532bd; font-size: 15px;">' + System.Label.Dear + ' ' + m.FirstName + ',</span></p><br><p><span style="color: #2532bd; font-size: 15px;">' + System.Label.AGN_Your_Pass_Expiry + '</span><br/><span style="color: #2532bd; font-size: 15px;">' + System.Label.AGN_Pass_Expiry_Below + '</span></p><br><table style="height: 59px; border-color: #000000; float: left;" border="1" width="500"><tbody><tr><td style="border-color: #000000;"><span style="color: #000000; font-size: 15px;">' + System.Label.AGN_User_Name + '</span></td><td style="border-color: #000000;">' + m.Name + '</td></tr><tr><td style="border-color: #000000;"><span style="color: #000000; font-size: 15px;">' + System.Label.AGN_LastPasswordReset + '</span></td><td style="border-color: #000000;">' + m.LastPasswordChangeDate.format('yyyy-MM-dd') + ' (YYYY-MM-DD)</td></tr><tr><td style="border-color: #000000;"><span style="color: #000000; font-size: 15px;">' + System.Label.AGN_PassExpiryDate + '</span></td><td style="border-color: #000000;">' + ExpiryDate.format('yyyy-MM-dd') + ' (YYYY-MM-DD)</td></tr></tbody></table><br><br><br><br><br><p><span style="color: #2532bd; font-size: 15px;">' + System.Label.AGN_Click_Below + '</span></p><p><a href="' + ChngPassURL + '"><span style="font-size: 15px;">' + ChngPassURL + '</span></a></p><br><p><span style="color: #2532bd; font-size: 15px;">' + System.Label.Best_Regards + '</span></p><br><p><strong><span style="font-size: 13px;">**' + System.Label.Do_Not_Reply + '**</span></strong></p><hr size="5" COLOR="#2532bd"/><p>&nbsp;</p></td></tr></tbody></table></body></html>';
                                
               // <html><body>Hi ' + m.Name + ',<br><br>Your account Expires in 7 days. <br>Kindly reset your password.<br><br><b>Regards,</b><br>System Admin</body></html>';
                mail.setHtmlBody(messageBody); 
                mailList.add(mail); 
                system.debug('Email for....'+m.name);
                
                }
                system.debug('All Users...'+m.Name + '...' +m.LastPasswordChangeDate);      
            } 
            
            Messaging.sendEmail(mailList);
    
    
   } 
   
   global void finish(Database.BatchableContext BC){
   }
   

}