// This class is created as the Controller class of the Visualforce Page - AGN_Case_Survey_Question_Answers
// Author - Rahul Mitra
// Created Date - 16/12/2019
// Last Modified By - Rahul Mitra
public without sharing class AGN_CaseSurveyQuestionAnswers 
{
    
    public String  Page_Language 		  {get;set;}
    public String  Language      		  {get;set;}
    public Integer QLength       		  {get;set;}
    public Boolean survey_answer 		  {get;set;}
    public Case    getcase       		  {get;set;}
    public Allergan_Survey_AGN__c lstsurv {get;set;}
    
    public List<AGN_CaseSurveyQuestionAnswers_Wrapper> questionanswers {get;set;}
    public List<Case> caselist;
    public List<Allergan_Survey_AGN__c> surveylist;
    
    String getCaseId = ApexPages.currentPage().getParameters().get('id');
    String recTypeId;
    
    
    List<Survey_Email_Question_Answer_AGN__c> lstQA;
    List<Id> allMeetingsId;
    
    public AGN_CaseSurveyQuestionAnswers()
    {
        Language  = ApexPages.currentPage().getParameters().get('Language');
        
        recTypeId = [Select id from RecordType where SobjectType = 'Survey_Email_Question_Answer_AGN__c' AND DeveloperName = 'Allergan_Case_Survey_AGN'][0].id;
        
        caselist = [Select Id,ContactEmail,Contact.Name,ContactId,Status,Type,Service_AGN__c,Country_Code_AGN__c,
                    Case_Survey_Link_2_AGN__c,Case_Survey_Email_Sent_AGN__c,
                    Case_Survey_Language_AGN__c from Case where Id=:getCaseId LIMIT 1];
        survey_answer = False;
        if(caselist.size()>0)
        {
            getcase = caselist[0];
            surveylist = [Select id,Survey_Answered_AGN__c from Allergan_Survey_AGN__c where Case_AGN__c =:getCaseId ORDER BY CreatedDate DESC LIMIT 1];
            if(surveylist.size()>0)
            {
                lstsurv = surveylist[0];
                survey_answer = lstsurv.Survey_Answered_AGN__c;	        
                questionanswers = questionanswerssurvey();   
            }
        }
    }
    
    public List<AGN_CaseSurveyQuestionAnswers_Wrapper> questionanswerssurvey()
    {
        lstQA = [Select id,name,Country_Code_AGN__c,Survey_Email_Category_AGN__c,
                 Survey_Email_Language_AGN__c,Survey_Email_Question_AGN__c,
                 Survey_Email_Service_AGN__c,Question_Order_AGN__c,Survey_Email_Answers_AGN__c,
                 Required_AGN__c,Active_AGN__c
                 from Survey_Email_Question_Answer_AGN__c where
                 Country_Code_AGN__c =:getcase.Country_Code_AGN__c and
                 RecordTypeId =: recTypeId and
                 Active_AGN__c = True and
                 Survey_Email_Category_AGN__c =: getcase.Type and
                 Survey_Email_Service_AGN__c =: getcase.Service_AGN__c and
                 Survey_Email_Language_AGN__c =:Language ORDER By Question_Order_AGN__c];
        
        QLength = lstQA.size();
        if(QLength > 0)
        {
        List<AGN_CaseSurveyQuestionAnswers_Wrapper> c =  new List<AGN_CaseSurveyQuestionAnswers_Wrapper>();
        for(Survey_Email_Question_Answer_AGN__c a:lstQA)
        {
            c.add(new AGN_CaseSurveyQuestionAnswers_Wrapper(a));
        }
        return c;
        }
        else
        {
            return null;
        }
    }
    public Pagereference Survey_Transactions()
    {
        Pagereference survcomp = null;
        //Case trans_case = [Select id,Case_Survey_Completed_AGN__c from case where Id =:getCaseId];
        //{
        if(lstsurv.Survey_Answered_AGN__c == true)
        {
            Pagereference page = null;
            page = new PageReference('/apex/AGN_Case_Survey_Already_Completed');
            page.getParameters().put('nooverride', '1');
            page.getParameters().put('ID',getCaseId);
            page.getParameters().put('Language',Language);
            page.setRedirect(true);
            return page; 
        }
        else
        {
            List<Survey_Email_Transaction_AGN__c> w =  new List<Survey_Email_Transaction_AGN__c>();
            for(AGN_CaseSurveyQuestionAnswers_Wrapper e:questionanswers)
            {
                Survey_Email_Transaction_AGN__c survemtran = new Survey_Email_Transaction_AGN__c();
                survemtran.Language_AGN__c         = Language;
                survemtran.Question_Answer_AGN__c  = e.a.id;
                survemtran.Case_AGN__c             = getCaseId;
                survemtran.Answer_AGN__c           = e.selected_ans;
                survemtran.Contact_Email_AGN__c    = getcase.ContactEmail;
                survemtran.Survey_Question_AGN__c  = e.a.Survey_Email_Question_AGN__c;
                survemtran.Allergan_Survey_AGN__c  = lstsurv.id;
                w.add(survemtran);
            }
            insert w;
            //getcase.Case_Survey_Completed_AGN__c = True;
            //update getcase;
            lstsurv.Survey_Answered_AGN__c = True;
            update lstsurv;
            survcomp = new PageReference('/apex/AGN_Case_Survey_Thanks');
            survcomp.getParameters().put('ID',getCaseId);
            survcomp.getParameters().put('Language',Language);
            survcomp.setRedirect(true);
            return survcomp;
        }
        // }
    }
    
    
    public class AGN_CaseSurveyQuestionAnswers_Wrapper
    {
        public Survey_Email_Question_Answer_AGN__c a {get;set;}
        public List<SelectOption> b                  {get;set;}
        public String selected_ans                   {get;set;}
        
        public AGN_CaseSurveyQuestionAnswers_Wrapper(Survey_Email_Question_Answer_AGN__c a)
        {
            this.a = a;
            this.b = new List<Selectoption>();
            if(a.Survey_Email_Answers_AGN__c != Null)
            {
                List<String> t = a.Survey_Email_Answers_AGN__c.split(';');
                b.add(new SelectOption('',''));
                for (String q:t)
                {
                    b.add(new SelectOption(q,q));
                }
            }
        }
    }
    public Pagereference Survey_Answered()
    {
        Pagereference page = null;
        if(survey_answer)
        {
            page = new PageReference('/apex/AGN_Case_Survey_Already_Completed');
            page.getParameters().put('nooverride', '1');
            page.getParameters().put('ID',getCaseId);
            page.getParameters().put('Language',Language);
            page.setRedirect(true);
        }
        else
        {
            if(caselist.isEmpty() || surveylist.isEmpty() || lstQA.isEmpty())
            {
            page = new PageReference('/apex/AGN_Case_Survey_Error_Message');
            page.getParameters().put('nooverride', '1');
            page.getParameters().put('ID',getCaseId);
            page.getParameters().put('Language',Language);
            page.setRedirect(true);
            }
        }
        return page;
    }
}