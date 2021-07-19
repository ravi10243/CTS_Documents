Global class AGN_MI_emailHelper 
{
    public static void sendTriggerEmail(List<Medical_Inquiry_vod__c> minquiry) 
    {
    Map <ID,AGN_MIR_Setting__c> Medical = new Map <ID,AGN_MIR_Setting__c >(); 
    Map <String,ID> userdetail = new Map <String,ID >(); 
    LIST<AGN_MIR_Setting__c> mir = [Select ID,UserId_AGN__c,Code_AGN__c,Country_Code_AGN__c,Email_AGN__c,Mail_BCC_AGN__c,Mail_CC_AGN__c,User_Name_AGN__c,Template_Id_AGN__c from AGN_MIR_Setting__c ];
    list<String> useridset=new list<String>();
    
        
        for(integer k=0;k<mir.size();k++)
        {
        string value= mir[k].User_Name_AGN__c;
            useridset.add(string.escapeSingleQuotes(value)); //cc_AD
        }   

        list<user> userid=new list<user>([select id,name from user where name in:useridset]);
    
            for ( Medical_Inquiry_vod__c mi : minquiry)
                {
                    
                    For(AGN_MIR_Setting__c custset : mir )
                    {
                    system.debug('value of mi.Country_code_AGN__C ======= '+mi.Country_Code__c);
                    system.debug('value of CUSTOM.Country_code_AGN__C ======= '+custset.Country_code_AGN__C);
                    
                         if(custset.Country_code_AGN__C==mi.Country_Code__c)
                         {
                         system.debug('value of mi.id ======= '+mi.id);
                         system.debug('value of mi.Country_code_AGN__C ======= '+custset.Country_code_AGN__C);
                            Medical.put(mi.id,custset);
                         }
                    
                    }
                }
                
                system.debug('value of medical is '+Medical);
                
                    For(AGN_MIR_Setting__c mirset : mir )
                    {
                        For(user userset : userid )
                        {
                             if(userset.name==mirset.User_Name_AGN__c)
                             {
                                userdetail.put(userset.name,userset.id);
                             }
                        }
                    }
            
                system.debug('value of userdetail is '+userdetail);
            List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
            
            if(Medical.size()>0)
            {
                        for ( Medical_Inquiry_vod__c mi : minquiry)
                                {
                                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                    // decode the contents of the field and convert it to a blob
                                    if(mi.Signature_vod__c!=null)
                                    {
                                        Blob body = EncodingUtil.base64Decode(mi.Signature_vod__c);
                                    
                                        
                                        efa.setFileName('signature.png');
                                        efa.setBody(body);
                                        efa.setContentType('image/png');
                                    }
                                        AGN_MIR_Setting__c gettingval = new AGN_MIR_Setting__c();
                                        ID username;
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        system.debug('value of mi.id ----- '+mi.id);
                                        system.debug('value of mi.id ======= '+mi.Country_Code__c);
                                        gettingval= Medical.get(mi.id);
                                        system.debug('value of gettingval is '+gettingval);
                                        string namesearch =gettingval.User_Name_AGN__c; 
                                        username=userdetail.get(namesearch);
                                        system.debug('value of username is '+username);
                                        mail.setTemplateId(gettingval.Template_Id_AGN__c);
                                        mail.setTargetObjectId(username);
                                        List<String> cc = new List<String>();
                                        cc.add(gettingval.Mail_CC_AGN__c);
                                        mail.setCcAddresses(cc);
                                        List<String> bcc = new List<String>();
                                        bcc.add(gettingval.Mail_BCC_AGN__c);
                                        mail.setBccAddresses(bcc);


                                        mail.setReplyTo('MIR@example.com');
                                        mail.setSenderDisplayName('Apex Attachment');     
                                        mail.setWhatId(mi.id);    
                                        mail.setBccSender(false);
                                        mail.setUseSignature(false);
                                        mail.setSaveAsActivity(false);
                                        
                                                if(mi.Signature_vod__c!=null)
                                                    {
                                                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa} );
                                                    }
                                                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                                    lstMails.add(mail);
                                    
                                    
                                }
            
                
                Messaging.sendEmail(lstMails);
                
            }   
    
    }
}