// This class is created as the Controller class of the Visualforce Page - AGN_AMI_Personalization
// Author - Ayush Basak
// Created Date - 16/11/2018
// Last Modified By - Ayush Basak

public without sharing class AGN_AMI_Personalization_Controller 
{ 
    List<AMI_Personalization_Question_AGN__c> questionList;
    List<AMI_Personalization_Answers_AGN__c> answerList;
    public Map<AMI_Personalization_Question_AGN__c,List<SelectOption>> displayMap {get;set;}    
    public String userType {get; set;}
    public String resultString {get; set;}
    Account accountRecord;
    Contact contactRecord;
    List<User> user;
    public List<String> ListofIds;
    public List<AMI_Personalization_Response_AGN__c> responseList;
    public String responseString {get; set;}
    //Added
    string country;   
    //End
    
    // Contructor is used to fetch the available question of the user and associated answers
    public AGN_AMI_Personalization_Controller()
    {
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        accountRecord =  userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;
        country = userDetails.userCountryName;
        
        questionList = [Select Id, Question_AGN__c, 
                                Question_Coefficient_F1_AGN__c, 
                                Question_Coefficient_F2_AGN__c, 
                                Question_Constant_F1_AGN__c, 
                                Question_Constant_F2_AGN__c from AMI_Personalization_Question_AGN__c where Country_code_AGN__c=:country];
        answerList = [Select Id, Answer_AGN__c, 
                                AMI_Personalization_Question_AGN__c, 
                                Answer_Coefficient_F1_AGN__c, 
                                Answer_Coefficient_F2_AGN__c, 
                                Weightage_AGN__c from AMI_Personalization_Answers_AGN__c where Country_code_AGN__c=:country];
        if(questionList.isEmpty())
		{
			questionList = [Select Id, Question_AGN__c, 
                                Question_Coefficient_F1_AGN__c, 
                                Question_Coefficient_F2_AGN__c, 
                                Question_Constant_F1_AGN__c, 
                                Question_Constant_F2_AGN__c from AMI_Personalization_Question_AGN__c where Country_code_AGN__c = null];
		}
		if(answerList.isEmpty())
		{
        answerList = [Select Id, Answer_AGN__c, 
                                AMI_Personalization_Question_AGN__c, 
                                Answer_Coefficient_F1_AGN__c, 
                                Answer_Coefficient_F2_AGN__c, 
                                Weightage_AGN__c from AMI_Personalization_Answers_AGN__c where Country_code_AGN__c = null];
        }            
        /*Germany Temporary Fix Ends*/
        responseString = '';
        responseList = [Select Id,AMI_Personalization_Answer_AGN__c from AMI_Personalization_Response_AGN__c where Account_AGN__c =: accountRecord.Id];
        for(AMI_Personalization_Response_AGN__c apr : responseList)
        {
            responseString = responseString + apr.AMI_Personalization_Answer_AGN__c + ';';
        }
        displayMap = new Map<AMI_Personalization_Question_AGN__c,List<SelectOption>>();
        
        for(AMI_Personalization_Question_AGN__c apq : questionList)
        {
            List<SelectOption> tempOptionList = new List<SelectOption>();
            List<String> tempResultList = new List<String>();
            for(AMI_Personalization_Answers_AGN__c apa : answerList)
            {
                if(apa.AMI_Personalization_Question_AGN__c == apq.id)
                {
                    tempOptionList.add(new SelectOption(apa.Id,apa.Answer_AGN__c));
                    tempResultList.add(null);
                }
            }
            system.debug(tempResultList.size() + '' + tempOptionList.size());
            displayMap.put(apq,tempOptionList);           
        }
    }
    
    // This method is triggered when user submits his questionaire. 
    // The method calculates the proper category the user is in and saves the response as well as his category against his user account.
    public PageReference processOption()
    {       
        system.debug('###'+resultString);        
        decimal f1 = 0;
        decimal f2 = 0;
        if(resultString.contains(';'))
            ListofIds = resultString.split(';');
        else
            ListofIds = new List<String>();
                system.debug('###'+ListofIds);
        List<AMI_Personalization_Answers_AGN__c> resultAnswerList = [Select Id, Answer_AGN__c, 
                                                                     AMI_Personalization_Question_AGN__c, 
                                                                     Answer_Coefficient_F1_AGN__c, 
                                                                     Answer_Coefficient_F2_AGN__c, 
                                                                     AMI_Personalization_Question_AGN__r.Question_Constant_F1_AGN__c,
                                                                     AMI_Personalization_Question_AGN__r.Question_Constant_F2_AGN__c,
                                                                     AMI_Personalization_Question_AGN__r.Question_Coefficient_F1_AGN__c,
                                                                     AMI_Personalization_Question_AGN__r.Question_Coefficient_F2_AGN__c,
                                                                     Weightage_AGN__c from AMI_Personalization_Answers_AGN__c where id = : ListofIds];
        if(resultAnswerList.size()>0)
        {
            f1 = f1 + resultAnswerList[0].AMI_Personalization_Question_AGN__r.Question_Constant_F1_AGN__c;
            f2 = f2 + resultAnswerList[0].AMI_Personalization_Question_AGN__r.Question_Constant_F2_AGN__c;
            System.debug(f1+' + ' + f2);
            for(AMI_Personalization_Answers_AGN__c APA : resultAnswerList)
            {
                f1 = f1 + APA.AMI_Personalization_Question_AGN__r.Question_Coefficient_F1_AGN__c + APA.Answer_Coefficient_F1_AGN__c*APA.Weightage_AGN__c;
                f2 = f2 + APA.AMI_Personalization_Question_AGN__r.Question_Coefficient_F2_AGN__c + APA.Answer_Coefficient_F2_AGN__c*APA.Weightage_AGN__c;
                System.debug(APA.Answer_Coefficient_F1_AGN__c*APA.Weightage_AGN__c + ' ' + APA.Answer_Coefficient_F2_AGN__c*APA.Weightage_AGN__c + ' ' + APA.AMI_Personalization_Question_AGN__r.Question_Coefficient_F1_AGN__c);
                system.debug(APA.Answer_AGN__c );
            }
        }
        System.debug('$$$'+f1+' + ' + f2);
        if(f2 > (-0.5 * f1))
        {
            if(f2 < (2 * f1))
            {
                userType = 'Practice Innovator';
            }
            else
            {
                userType = 'Treatment entrepreneur';
            }
        }
        else
        {
            if(f2 < (4 * f1))
            {
                userType = 'Skills specialist';
            }
            else
            {
                userType = 'Knowledge seeker';
            }
        }
        try
        {
            updateProfile();
            saveResponses();
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return new PageReference(System.Label.AGN_AMI_Home_Page);
    }
    
    // This method is used to save AMI HCP Profile record against the user with proper data
    public void updateProfile()
    {
        List<AMI_HCP_Profile_AGN__c> AHP = [Select Id from AMI_HCP_Profile_AGN__c where Account_AGN__c =: accountRecord.Id];
        AMI_HCP_Profile_AGN__c updateRecord;
        if(AHP.size()>0)
            updateRecord = AHP[0];
        else
            updateRecord = new AMI_HCP_Profile_AGN__c(Account_AGN__c = accountRecord.Id, Contact_AGN__c = contactRecord.Id);
        updateRecord.HCP_Category_AGN__c = userType;
        updateRecord.User_Completed_AGN__c = true;
        updateRecord.User_Skipped_AGN__c = false;
        upsert updateRecord;
    }
    
    // This method is used to save AMI Personalization Response records against the user with proper data
    public void saveResponses()
    {
        List<AMI_Personalization_Response_AGN__c> delList = [Select Id from AMI_Personalization_Response_AGN__c where Account_AGN__c =: accountRecord.Id];
        List<AMI_Personalization_Response_AGN__c> insertList = new List<AMI_Personalization_Response_AGN__c>();
        for(String id : ListofIds)
        {
            AMI_Personalization_Response_AGN__c APR = new AMI_Personalization_Response_AGN__c(AMI_Personalization_Answer_AGN__c = id, Account_AGN__c = accountRecord.Id, Contact_AGN__c = contactRecord.Id);
            insertList.add(APR);
        }
        delete delList;
        insert insertList;
    }
    
    // This method redirects the user to the AHN_AMI_Home_Page when the user skips and does not want to attempt the questionaire at the moment.
    public PageReference goToHome()
    {
        List<AMI_HCP_Profile_AGN__c> AHP = [Select Id,User_Completed_AGN__c from AMI_HCP_Profile_AGN__c where Account_AGN__c =: accountRecord.Id];
        AMI_HCP_Profile_AGN__c updateRecord;
        if(AHP.size()>0)
            updateRecord = AHP[0];
        else
            updateRecord = new AMI_HCP_Profile_AGN__c(Account_AGN__c = accountRecord.Id, Contact_AGN__c = contactRecord.Id);
        if(!updateRecord.User_Completed_AGN__c)
            updateRecord.User_Skipped_AGN__c = true;
        try
        {
            upsert updateRecord;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return new PageReference(System.Label.AGN_AMI_Home_Page);
    } 
}