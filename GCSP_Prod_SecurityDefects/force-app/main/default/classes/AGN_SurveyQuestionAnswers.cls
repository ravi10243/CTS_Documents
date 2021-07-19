public class AGN_SurveyQuestionAnswers {

    public String Selected_Ans {get;set;}
    String getContractExihibitID=ApexPages.currentPage().getParameters().get('id');
    public String Language {get;set;}
    public List<Survey_Question_Answers_Map> question_answer {get;set;}
    public Contract_Exhibit__c ce{get;set;}
    public Boolean survey_answer {get;set;}
    public String Page_Language {get;set;}
    //public User Exhibit_Owner {get;set;}
    public StringCarrier defaultLanguage {get; set;}
    //private Map<String, String> finalquestionAnswerMap;
    //public String answeredQuestion{get; set;}
    public Account AccountName{get;set;}
    BC_Setting_AGN__c bcs=[select BC_Survey_QuestionLanguage_Available_AGN__c from BC_Setting_AGN__c where setupownerid=:UserInfo.getOrganizationId()];
    
    Public AGN_SurveyQuestionAnswers()
    {
    //Survey_Answered();
        Language= ApexPages.currentPage().getParameters().get('language');  
        //finalquestionAnswerMap = new Map<String,String>();
        ce=[Select Id,Name,Primary_Institution__c,Survey_Answered_AGN__c,Language_code_AGN__c,Ownerid from Contract_Exhibit__c where Id=:getContractExihibitID];
        survey_answer = ce.Survey_Answered_AGN__c;
        AccountName=[Select Id, Name from Account where ID=:ce.Primary_Institution__c];
        Page_Language = ce.Language_code_AGN__c;
        //Exhibit_Owner = [Select id,Managerid,Manager.Email from User where id =:ce.Ownerid];
    }
    public List<Survey_Question_Answers_Map> getFetching_survey_questions()
    {
        Map<Id,List<SelectOption>> Type_Answers_map = new Map<Id,List<SelectOption>>();
        question_answer = new List<Survey_Question_Answers_Map>();
        for(BC_Survey_Answer_AGN__c survey_ans: [Select id,name,Answer_AGN__c,isActive_AGN__c,BC_Survey_Answer_Type_AGN__c,Language_AGN__c,Display_order_AGN__c,weightage_AGN__c from BC_Survey_Answer_AGN__c where isActive_AGN__c = true and Language_AGN__c =:Language order by Display_order_AGN__c])
        {
            List<SelectOption> temporary_ans = new List<SelectOption>();
            if(Type_Answers_map.containsKey(survey_ans.BC_Survey_Answer_Type_AGN__c))
            {
                temporary_ans = Type_Answers_map.get(survey_ans.BC_Survey_Answer_Type_AGN__c);
                temporary_ans.add(new SelectOption(survey_ans.Answer_AGN__c,survey_ans.Answer_AGN__c));
                Type_Answers_map.put(survey_ans.BC_Survey_Answer_Type_AGN__c,temporary_ans);
            }
            else
            {
                temporary_ans.add(new SelectOption(Label.AGN_BCSurvey_None,Label.AGN_BCSurvey_None));
                temporary_ans.add(new SelectOption(survey_ans.Answer_AGN__c,survey_ans.Answer_AGN__c));
                Type_Answers_map.put(survey_ans.BC_Survey_Answer_Type_AGN__c,temporary_ans);
            }
        }
        
        for(BC_Survey_Question_AGN__c survey_que : [Select id,name,isActive_AGN__c,Required_Question_AGN__c,Question_Type_AGN__c,BC_Survey_Answer_Type_AGN__c,Display_order_AGN__c,Language_AGN__c,Question_AGN__c from BC_Survey_Question_AGN__c where isActive_AGN__c = true and Language_AGN__c =: Language order by Display_order_AGN__c])
        {
            //finalquestionAnswerMap.put(survey_que.Id,'--None--');
            List<SelectOption> ans_options = new List<SelectOption>();
            if(survey_que.BC_Survey_Answer_Type_AGN__c !=null)
            {
                ans_options = Type_Answers_map.get(survey_que.BC_Survey_Answer_Type_AGN__c);
                question_answer.add(new Survey_Question_Answers_Map(survey_que.Id,survey_que.Question_AGN__c,ans_options,survey_que.Display_order_AGN__c,survey_que.Required_Question_AGN__c,survey_que.Question_Type_AGN__c));
                //question_answer.add(new Survey_Question_Answers_Map(survey_que,ans_options));
            }
        }
        return question_answer;
    }
    public Pagereference Survey_question_answer_Transaction()
    {
        Pagereference result = null;
        Contract_Exhibit__c con_exhibit = [Select id,Survey_Answered_AGN__c from Contract_Exhibit__c where id =:getContractExihibitID];
        if(con_exhibit.Survey_Answered_AGN__c == true)
        {
            Pagereference page = null;
            page = new PageReference('/apex/AGN_BC_Survey_Already_Completed');
            page.getParameters().put('nooverride', '1');
            page.getParameters().put('ID',getContractExihibitID);
            page.getParameters().put('Language',Language);
            page.setRedirect(true);
            return page;
        }
        else
        {
        List<BC_Survey_Transaction_AGN__c> survey_transactions = new List<BC_Survey_Transaction_AGN__c>();
        Set<String> ans_list = new Set<String>();
        Map<String,String> ans_weightage = new Map<String,String>();
        for(Survey_Question_Answers_Map ans: question_answer)
        {
            ans_list.add(ans.Selected_ans);
        }
        for(BC_Survey_Answer_AGN__c sur_ans : [Select id,name,Answer_AGN__c,weightage_AGN__c from BC_Survey_Answer_AGN__c where Answer_AGN__c IN:ans_list])
        {
            ans_weightage.put(sur_ans.Answer_AGN__c,sur_ans.weightage_AGN__c);
        }
        for(Survey_Question_Answers_Map sqam : question_answer)
        {
            BC_Survey_Transaction_AGN__c single_transaction = new BC_Survey_Transaction_AGN__c();
            single_transaction.Contract_Exhibit_AGN__c = ce.ID;
            //single_transaction.Customer_Contact_Email_AGN__c = sqam.Selected_ans;
            single_transaction.Question_AGN__c = sqam.question_id;
            single_transaction.Language_AGN__c = Language;
            single_transaction.answer_weightage_AGN__c = ans_weightage.get(sqam.Selected_ans);
            single_transaction.Exhibit_Owner_AGN__c = ce.OwnerId;
            single_transaction.Question_Type_AGN__c = sqam.que_type;
            if(sqam.disp_order != 500)
            {
                if(Label.AGN_BCSurvey_None != sqam.Selected_ans)
                {
                    single_transaction.Answer_AGN__c = sqam.Selected_ans;   
                    survey_transactions.add(single_transaction);
                }
            }
            else if(sqam.disp_order == 500 && String.isNotBlank(sqam.Selected_ans))
            {
                single_transaction.Customer_Contact_Email_AGN__c = sqam.Selected_ans;
                survey_transactions.add(single_transaction);
            }
        }
        insert survey_transactions;
        List<BC_Survey_Transaction_AGN__c> survey_transactions_update = new List<BC_Survey_Transaction_AGN__c>();
        for(BC_Survey_Transaction_AGN__c sur_tran : survey_transactions)
        {
            sur_tran.Ownerid = sur_tran.Exhibit_Owner_AGN__c;
            survey_transactions_update.add(sur_tran);
        }
        update survey_transactions_update;
        ce.Survey_Answered_AGN__c = true;
        update ce;
        result = new PageReference('/apex/AGN_BC_Survey_Thanks');
        result.getParameters().put('ID',getContractExihibitID);
        result.getParameters().put('Language',Language);
        result.setRedirect(true);
        return result;
        }
    }    
    public Pagereference Survey_Answered()
    {
        System.debug('@@@@@@@@testing '+ce.Survey_Answered_AGN__c);
        Pagereference page = null;
        //List<BC_Survey_Transaction_AGN__c> tran = [select id,name from BC_Survey_Transaction_AGN__c where Contract_Exhibit_AGN__c =:getContractExihibitID];
        //Contract_Exhibit__c con_exhibit = [Select id,Survey_Answered_AGN__c from Contract_Exhibit__c where id =:getContractExihibitID];
        //if(con_exhibit.Survey_Answered_AGN__c == true)
        if(survey_answer) //|| tran.size()>0)
        {
            //String s = bcs.Site_Url_AGN__c+'/apex/AGN_BC_Survey_Already_Completed';
            page = new PageReference('/apex/AGN_BC_Survey_Already_Completed');
            page.getParameters().put('nooverride', '1');
            page.getParameters().put('ID',getContractExihibitID);
            page.getParameters().put('Language',Language);
            page.setRedirect(true);
        }
        return page;
    }
    public class Survey_Question_Answers_Map
    {
        public String question {get;set;}
        public String question_id {get;set;}
        public String Selected_ans {get;set;}
        public List<SelectOption> Answers {get;set;}
        public Decimal disp_order {get;set;}
        public Boolean req_que {get;set;}
        public String que_type {get;set;}
        //public BC_Survey_Question_AGN__c que_record {get;set;}
        
       /* public Survey_Question_Answers_Map(BC_Survey_Question_AGN__c querec,List<SelectOption> ans)
        {
            this.Answers = ans;
            this.que_record = querec;
        }*/
       
       
        public Survey_Question_Answers_Map(String que_id,String que,List<SelectOption> ans,Decimal diporder,Boolean required,String type)
        {
            this.question_id = que_id;
            this.question = que;
            this.Answers = ans;
            this.disp_order = diporder;
            this.req_que = required;
            this.que_type = type;
        }
    }
}