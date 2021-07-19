/*
 *  Controller class for contact us email message component 
 */
public Without Sharing class AGN_SPARK_ContactUs_SendEmail { //added without sharing keyword for Spring '21 release
	
   /*
    *  Method to send email messages from UI
    */
   @AuraEnabled 
   public static boolean sendMailmessage(String name, String fromEmail, String message){
       try {
            if(String.isNotBlank(fromEmail)){
                List<String> emailAddress = new List<String>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                map<string, string> emailSettings = AGN_SPARK_Utility.getSparkTeamEmailSettings();
                
                if(String.isNotBlank(emailSettings.get('toEmail'))){
                   emailAddress = emailSettings.get('toEmail').split(',');
                   List<Messaging.SendEmailResult> result = sendEmail(emailAddress, name, fromEmail, message);
                    if(result[0].success){
                        return true;
                    }
                }            
            }
       } catch(exception e) {
           
       }

       return false;
    }
    
    /*
    *  Method to setup & send email
    */
    private static List<Messaging.SendEmailResult> sendEmail(List<String> toAddress,  String name, String email, String message){

        EmailTemplate template = AGN_SPARK_Utility.getSparkTeamEmailTemplate();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(toAddress);
        mail.setSubject(template.Subject.replace('{custom.Name}', name)); 
       
        mail.setPlainTextBody(template.Body.replace('{custom.Name}', name).replace('{custom.Email}', email).replace('{custom.Message}', message));
        
        return Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
    }
}