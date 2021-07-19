public with sharing class AGN_CaseViewFieldsPicker{
    
    public CaseToApproveFieldSet_AGN__c caseFieldSet {get; set;}
    public List <SelectOption> availableFields {get; set;}
    public List <String> selectedFields {get; set;}
    public List<SelectOption> selectField {get;set;}
    public boolean isEdit {get; set;}
    public boolean isReorder {get;set;}
    public boolean isAdd {get;set;}
    private string retURL;
    public string fullURL{get;set;}
    public Boolean isConsole{get;set;}
    public String selected {get;set;}
    public List<String> reorderList {get;set;}
    public List<SelectOption> choose {get;set;}
    public Map<String,String> reorderMap {get;set;}
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    List<Case> availView {get;set;}
    public String userAgent{get;set;}
    public Boolean isIpad{get;set;}
    public List<SelectOption> fieldconlist {get;set;}
    public String fieldcon1 {get;set;}
    public String fieldcon2 {get;set;}
    public String fieldcon3 {get;set;}
    public List<SelectOption> operatorlist {get;set;}
    public String operator1 {get;set;}
    public String operator2 {get;set;}
    public String operator3 {get;set;}
    public String value1 {get;set;}
    public String value2 {get;set;}
    public String value3 {get;set;}
    public Boolean isFilter{get;set;}
    public Boolean showFilter{get;set;}
    public Boolean showCommandLink{get;set;}
    public String filterLogic {get;set;}
    public Boolean noError {get;set;}
    public Boolean showError {get;set;}
    public List<SelectOption> depConditionList1 {get;set;}
    public List<SelectOption> depConditionList2 {get;set;}
    public List<SelectOption> depConditionList3 {get;set;}
    public String depCondition1 {get;set;}
    public String depCondition2 {get;set;}
    public String depCondition3 {get;set;}
    public Map<String,String> nameType = new Map<String,String>();
    public Boolean isDep1 {get;set;}
    public Boolean isDep2 {get;set;}
    public Boolean isDep3 {get;set;}
    public String lookupVal1='';
    public String lookupVal2='';
    public String lookupVal3='';
    //For adding newly created view to user's Custom Setting to return to new view in the approval page
    GCSP_Items_to_Approve_AGN__c newView;
    string userId;
    String userNm;
    
    public AGN_CaseViewFieldsPicker(){
        //===Add===//
        
        //End
        string fsId = apexPages.currentPage().getParameters().get('id');
        retURL = apexPages.currentPage().getParameters().get('URL');
        system.debug('retURL   '+retUrL);
        fullURL = Apexpages.currentPage().getUrl();
        if(fullURL.contains('Console'))
            isConsole=true;
        else
            isConsole=false;
        system.debug('fullURL '+fullURL+'   isConsole '+isConsole);
        set<string> setSelectedFields = new set<string>();
        choose = new List<SelectOption>();
        choose.add(new SelectOption('1',System.Label.CaseAdd_AGN));
        choose.add(new SelectOption('2',System.Label.CaseRemove_AGN));
        choose.add(new SelectOption('3',System.Label.CaseAddFilter_AGN));
        reorderMap = new Map<String,String>();
        selectedFields = new List <String>();
        selectField = new List<SelectOption>();
        leftselected = new List<String>();
        rightselected = new List<String>();
        availView = new List<Case>();
        fieldconlist = new List<SelectOption>();
        fieldconlist.add(new SelectOption('None',System.Label.CaseNone_AGN));
        operatorlist = new List<SelectOption>();
        userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        
        if(userAgent.contains('iPad') || userAgent.contains('iPhone'))
            isIpad=true;
        else
            isIpad=false;
        
        if (fsId != null) {
            isEdit = true;
            caseFieldSet = [SELECT Id, Name,Value_1_AGN__c,Value_2_AGN__c,Value_3_AGN__c,Selectedfields_AGN__c, User_AGN__c,Where_Clause_AGN__c,Filter_1_AGN__c,Filter_2_AGN__c,Filter_3_AGN__c,Operator_1_AGN__c,Operator_2_AGN__c,Operator_3_AGN__c,Filter_Logic_AGN__c FROM CaseToApproveFieldSet_AGN__c WHERE Id =: fsId];
            if (caseFieldSet.Selectedfields_AGN__c != null){
                for (string field : caseFieldSet.Selectedfields_AGN__c.split(';')){
                    setSelectedFields.add(field);
                }
            }
        } else {
            isEdit = false;
            caseFieldSet = new CaseToApproveFieldSet_AGN__c();
            caseFieldSet.User_AGN__c = UserInfo.getUserId();
        }
        availableFields = new List <SelectOption>();
        
        Schema.SObjectType newsObject = Schema.getGlobalDescribe().get('Case');
        Map<String, Schema.SObjectField> o = newsObject.getDescribe().fields.getMap();
        for ( Schema.SObjectField field : o.values() ) {
            if (field.getDescribe().getName() != 'Id' && field.getDescribe().getName() != 'CaseNumber' && field.getDescribe().getName() !='AccountId') {
                if (!setSelectedFields.contains(field.getDescribe().getName())) {
                    availableFields.add(new SelectOption(field.getDescribe().getName(), field.getDescribe().getLabel()));                    
                } else {
                    selectField.add(new SelectOption(field.getDescribe().getName(), field.getDescribe().getLabel()));
                    leftvalues.add(field.getDescribe().getLabel());
                    //system.debug('field.getDescribe().getLabel()=====>'+field.getDescribe().getLabel());
                    if(string.valueOf(field.getDescribe().getType()) != 'double' && string.valueOf(field.getDescribe().getType()) != 'date' && string.valueOf(field.getDescribe().getType()) != 'datetime')
                    	fieldconlist.add(new SelectOption(field.getDescribe().getName(),field.getDescribe().getLabel()));
                    nameType.put(field.getDescribe().getName(), field.getDescribe().getLabel());
                    reorderMap.put(field.getDescribe().getLabel(),field.getDescribe().getName());                                       
                }
            }
        }
    }
    
    public void operatorlistFill(){
        operatorlist.add(new SelectOption('=','equals'));
        operatorlist.add(new SelectOption('!=','not equals'));
        operatorlist.add(new SelectOption('%','starts with'));
        operatorlist.add(new SelectOption('%%','contains'));
        operatorlist.add(new SelectOption('%e','ends with'));
        operatorlist.add(new SelectOption('IN','in'));
        
    }
    
    public PageReference getConditions(){
        if(operatorlist == NULL || operatorlist.size() == 0){
              operatorlistFill();
        } 
        //============ For Lookup Fields =================
        Schema.DescribeSObjectResult objSchema = Case.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        String fielddataType1 = '';
        String fielddataType2 = '';
        String fielddataType3 = '';
                  
        if(fieldcon1 != NULL && fieldcon1 != 'None')        
            fielddataType1 = string.valueOf(fieldMap.get(fieldcon1).getDescribe().getType());        
        if(fieldcon2 != NULL && fieldcon2 != 'None')
            fielddataType2 = string.valueOf(fieldMap.get(fieldcon2).getDescribe().getType());
        if(fieldcon3 != NULL && fieldcon3 != 'None')
            fielddataType3 = string.valueOf(fieldMap.get(fieldcon3).getDescribe().getType());
        
        if(fielddataType1 == 'reference'){
            if(fieldcon1.contains('__c'))
                lookupVal1 = fieldcon1.substring(0, fieldcon1.length()-1) + 'r.Name';
            else
                lookupVal1 = fieldcon1.substring(0, fieldcon1.length()-2) + '.Name';
        }else if(fielddataType1 != 'reference'){
            lookupVal1 = '';
        }
        if(fielddataType2 == 'reference'){
            if(fieldcon2.contains('__c'))
                lookupVal2 = fieldcon2.substring(0, fieldcon2.length()-1) + 'r.Name';
            else
                lookupVal2 = fieldcon2.substring(0, fieldcon2.length()-2) + '.Name';
        }else if(fielddataType2 != 'reference'){
            lookupVal2 = '';
        }
        if(fielddataType3 == 'reference'){
            if(fieldcon3.contains('__c'))
                lookupVal3 = fieldcon3.substring(0, fieldcon3.length()-1) + 'r.Name';
            else
                lookupVal3 = fieldcon3.substring(0, fieldcon3.length()-2) + '.Name';
        }else if(fielddataType3 != 'reference'){
            lookupVal3 = '';
        }
        if(fieldcon1=='None'){
            fieldcon2 = 'None';
            fieldcon3 = 'None';
            filterLogic = '';
        }
        if(fieldcon2=='None'){            
            fieldcon3 = 'None';
            filterLogic = '';
        }
        if(isFilter && fieldcon1 != NULL && fieldcon1 != 'None' && fieldcon2 != NULL && fieldcon2 != 'None' && (filterLogic == NULL || filterLogic == ''))           
            filterLogic = '1 AND 2';
        if(isFilter && fieldcon1 != NULL && fieldcon1 != 'None' && fieldcon2 != NULL && fieldcon2 != 'None' && fieldcon3 != NULL && fieldcon3 != 'None'){
            if(filterLogic == NULL || filterLogic == '')
                filterLogic = '1 AND 2 AND 3';
            else if(!filterLogic.contains('3')){
                if(filterLogic.contains('or') || filterLogic.contains('OR'))
                    filterLogic += ' OR 3';
                else
                    filterLogic += ' AND 3';
            }                
        }
        return null;
    }
    
    public PageReference reorderchoose(){
        system.debug('selected '+selected);
        if(selected=='1')
        { 
            isAdd=true;
            isReorder=false;
            isFilter=false;
        }else if(selected=='2'){
            isAdd=false;
            isReorder=true;
            isFilter=false;
        }else{
            isAdd=false;
            isReorder=false;
            isFilter=true;
            if(caseFieldSet.Filter_1_AGN__c != NULL && caseFieldSet.Filter_1_AGN__c != ''){
                fieldcon1 = caseFieldSet.Filter_1_AGN__c;
                if(operatorlist == NULL || operatorlist.size() == 0){
                    operatorlistFill();
                }                
            } 
            if(caseFieldSet.Filter_2_AGN__c != NULL && caseFieldSet.Filter_2_AGN__c != '')
                fieldcon2 = caseFieldSet.Filter_2_AGN__c;
            if(caseFieldSet.Filter_3_AGN__c != NULL && caseFieldSet.Filter_3_AGN__c != '')
                fieldcon3 = caseFieldSet.Filter_3_AGN__c;
            if(caseFieldSet.Operator_1_AGN__c != NULL && caseFieldSet.Operator_1_AGN__c != '')
                operator1 = caseFieldSet.Operator_1_AGN__c;
            if(caseFieldSet.Operator_2_AGN__c != NULL && caseFieldSet.Operator_2_AGN__c != '')
                operator2 = caseFieldSet.Operator_2_AGN__c;
            if(caseFieldSet.Operator_3_AGN__c != NULL && caseFieldSet.Operator_3_AGN__c != '')
                operator3 = caseFieldSet.Operator_3_AGN__c;
            if(caseFieldSet.Value_1_AGN__c != NULL && caseFieldSet.Value_1_AGN__c != '')
                value1 = caseFieldSet.Value_1_AGN__c;
            if(caseFieldSet.Value_2_AGN__c != NULL && caseFieldSet.Value_2_AGN__c != '')
                value2 = caseFieldSet.Value_2_AGN__c;
            if(caseFieldSet.Value_3_AGN__c != NULL && caseFieldSet.Value_3_AGN__c != '')
                value3 = caseFieldSet.Value_3_AGN__c;
            if(caseFieldSet.Filter_Logic_AGN__c != NULL && caseFieldSet.Filter_Logic_AGN__c != '')
                filterLogic = caseFieldSet.Filter_Logic_AGN__c;
            system.debug('fieldcon1 = '+fieldcon1+' fieldcon2 = '+fieldcon2 + ' fieldcon3 = '+fieldcon3);
            system.debug('operator1 = '+operator1+' operator2 = '+operator2 + ' operator3 = '+operator3);
            system.debug('value1 = '+value1+' value2 = '+value2 + ' value3 = '+value3);
        } 
        return null;    
    }
    
    
    
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
    
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
    
    
    
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    public Pagereference doSave(){
        
        String filterCondition1 = '';
        String filterCondition2 = '';
        String filterCondition3 = '';
        String condNumber = '';    
        
        if(isEdit==false)       
            caseFieldSet.Selectedfields_AGN__c = '';
        else if(isEdit==true && isAdd==true)
            caseFieldSet.Selectedfields_AGN__c+=';';
        else if(isEdit==true && isReorder==true)
        {
            system.debug('rightvalues '+rightvalues.size());
            if(rightvalues.isEmpty() || rightvalues.size()==0)
            { 
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.CaseSaveErrorMessage_AGN));
                return null;
            }
            caseFieldSet.Selectedfields_AGN__c = '';
            for(String a:rightvalues)
            {
                String value=reorderMap.get(a);
                caseFieldSet.Selectedfields_AGN__c = caseFieldSet.Selectedfields_AGN__c+value+';';
            }
            caseFieldSet.Selectedfields_AGN__c = caseFieldSet.Selectedfields_AGN__c.removeEnd(';');        
            upsert caseFieldSet;
        }else if(isFilter==true){
            noError = true;
            if(fieldcon1 != 'None' && fieldcon1 != NULL){
                String op1 = operatorValue(operator1,value1.trim(),fieldcon1);
                filterCondition1 += ( (lookupVal1 != null && lookupVal1 != '') ? lookupVal1 : fieldcon1) + ' ' + op1;
                caseFieldSet.Filter_1_AGN__c = fieldcon1;
                caseFieldSet.Value_1_AGN__c = value1;
                caseFieldSet.Operator_1_AGN__c = operator1;
            }
            if(fieldcon1 == 'None'){
                filterCondition1 = '';
                caseFieldSet.Filter_1_AGN__c = '';
                caseFieldSet.Value_1_AGN__c = '';
                caseFieldSet.Operator_1_AGN__c = '';
                filterCondition2 = '';
                caseFieldSet.Filter_2_AGN__c = '';
                caseFieldSet.Value_2_AGN__c = '';
                caseFieldSet.Operator_2_AGN__c = '';
                filterCondition3 = '';
                caseFieldSet.Filter_3_AGN__c = '';
                caseFieldSet.Value_3_AGN__c = '';
                caseFieldSet.Operator_3_AGN__c = '';
                caseFieldSet.Where_Clause_AGN__c = '';
                caseFieldSet.Filter_Logic_AGN__c = '';
            }
            if(fieldcon1 != 'None' && fieldcon1 != NULL && fieldcon2 != 'None' && fieldcon2 != NULL){
                String op2 = operatorValue(operator2,value2.trim(),fieldcon2);
                filterCondition2 += ( (lookupVal2 != null && lookupVal2 != '') ? lookupVal2 : fieldcon2) + ' ' + op2;
                caseFieldSet.Filter_2_AGN__c = fieldcon2;
                caseFieldSet.Value_2_AGN__c = value2;
                caseFieldSet.Operator_2_AGN__c = operator2;
                caseFieldSet.Filter_Logic_AGN__c = filterLogic;             
            }
            if(fieldcon2 == 'None'){                
                filterCondition2 = '';
                caseFieldSet.Filter_2_AGN__c = '';
                caseFieldSet.Value_2_AGN__c = '';
                caseFieldSet.Operator_2_AGN__c = '';
                filterCondition3 = '';
                caseFieldSet.Filter_3_AGN__c = '';
                caseFieldSet.Value_3_AGN__c = '';
                caseFieldSet.Operator_3_AGN__c = '';
                caseFieldSet.Where_Clause_AGN__c = '';
                caseFieldSet.Filter_Logic_AGN__c = '';
            }
            if(fieldcon1 != 'None' && fieldcon1 != NULL && fieldcon2 != 'None' && fieldcon2 != NULL && fieldcon3 != 'None' && fieldcon3 != NULL){
                String op3 = operatorValue(operator3,value3.trim(),fieldcon3);
                filterCondition3 += ( (lookupVal3 != null && lookupVal3 != '') ? lookupVal3 : fieldcon3) + ' ' + op3;
                caseFieldSet.Filter_3_AGN__c = fieldcon3;
                caseFieldSet.Value_3_AGN__c = value3;
                caseFieldSet.Operator_3_AGN__c = operator3;
                caseFieldSet.Filter_Logic_AGN__c = filterLogic;
            }               
            if(fieldcon3 == 'None'){            
                filterCondition3 = '';
                caseFieldSet.Filter_3_AGN__c = '';
                caseFieldSet.Value_3_AGN__c = '';
                caseFieldSet.Operator_3_AGN__c = '';
            }
            
            List<GCSP_Items_to_Approve_AGN__c> filterConditions = [select Filter_Logic_AGN__c,Number_of_Conditions_AGN__c from GCSP_Items_to_Approve_AGN__c where Filter_Record_AGN__c=true];
            system.debug('<========= filterConditions =========>'+filterConditions);
            if(filterLogic !=null && filterLogic!=''){
                for(GCSP_Items_to_Approve_AGN__c var : filterConditions)
                {
                    system.debug('<========= var.Filter_Logic_AGN__c =========>'+var.Filter_Logic_AGN__c);
                    if(filterLogic !=null && filterLogic!=''){
                        if(filterCondition1 != '' && filterCondition2 != '' && filterCondition3==''){
                            if(filterLogic.equalsIgnoreCase(var.Filter_Logic_AGN__c) && var.Number_of_Conditions_AGN__c=='2'){
                                noError = false;
                                condNumber = '2';
                                break; 
                            }                        
                        }else if(filterCondition1 != '' && filterCondition2 != '' && filterCondition3 != ''){
                            system.debug('inside filterCondition1===>'+filterCondition1+'====filterCondition2====>'+filterCondition2+'======filterCondition3=====>'+filterCondition3);
                            if(filterLogic.equalsIgnoreCase(var.Filter_Logic_AGN__c) && var.Number_of_Conditions_AGN__c=='3'){
                                noError = false;
                                condNumber = '3';
                                break;
                            }
                        }                 
                    }                
                }  
            }else {
                if(filterCondition2 == null || filterCondition2 == '')
                    noError = false;
            }
            
            if(noError){
                showError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.CaseWrongFilterLogic_AGN));
                return null;
            }
            if(filterLogic != null && filterLogic != '' && condNumber=='2'){
                if(filterLogic.contains('OR') || filterLogic.contains('or'))
                    caseFieldSet.Where_Clause_AGN__c = filterCondition1 + ' OR ' + filterCondition2;
                else if(filterLogic.contains('AND') || filterLogic.contains('and'))
                    caseFieldSet.Where_Clause_AGN__c = filterCondition1 + ' AND ' + filterCondition2;
            }else if(filterLogic != null && filterLogic != '' && condNumber=='3'){
                if(filterLogic.contains('(')){
                    caseFieldSet.Where_Clause_AGN__c = '';
                    List<String> con =  filterLogic.split(' ');
                    for(String s : con){
                        if(s.contains('(')){
                            if(s.contains('1') && filterCondition1 != '')
                                caseFieldSet.Where_Clause_AGN__c += '( ' + filterCondition1;
                            if(s.contains('2') && filterCondition1 != '' && filterCondition2 != '')
                                caseFieldSet.Where_Clause_AGN__c += '( ' + filterCondition2;
                            if(s.contains('3') && filterCondition1 != '' && filterCondition2 != '' && filterCondition3 != '')
                                caseFieldSet.Where_Clause_AGN__c += '( ' + filterCondition3;
                        }else if(s.contains(')')){
                            if(s.contains('1') && filterCondition1 != '')
                                caseFieldSet.Where_Clause_AGN__c += filterCondition1 + ' )';
                            if(s.contains('2') && filterCondition1 != '' && filterCondition2 != '')
                                caseFieldSet.Where_Clause_AGN__c += filterCondition2 + ' )';
                            if(s.contains('3') && filterCondition1 != '' && filterCondition2 != '' && filterCondition3 != '')
                                caseFieldSet.Where_Clause_AGN__c += filterCondition3 + ' )';
                        }
                        else{
                            if(s=='1' && filterCondition1 != '')
                                caseFieldSet.Where_Clause_AGN__c += filterCondition1;
                            if(s=='2' && filterCondition1 != '' && filterCondition2 != '')
                                caseFieldSet.Where_Clause_AGN__c += filterCondition2;
                            if(s=='3' && filterCondition1 != '' && filterCondition2 != '' && filterCondition3 != '')
                                caseFieldSet.Where_Clause_AGN__c += filterCondition3;
                            if(s=='OR' || s=='or')
                                caseFieldSet.Where_Clause_AGN__c += ' OR ';
                            if(s=='AND' || s=='and')
                                caseFieldSet.Where_Clause_AGN__c += ' AND ';
                        }
                    }
                }
                else{
                    caseFieldSet.Where_Clause_AGN__c = '';
                    List<String> con =  filterLogic.split(' ');
                    for(String s : con){
                        if(s=='1' && filterCondition1 != '')
                            caseFieldSet.Where_Clause_AGN__c += filterCondition1;
                        if(s=='2' && filterCondition1 != '' && filterCondition2 != '')
                            caseFieldSet.Where_Clause_AGN__c += filterCondition2;
                        if(s=='3' && filterCondition1 != '' && filterCondition2 != '' && filterCondition3 != '')
                            caseFieldSet.Where_Clause_AGN__c += filterCondition3;
                        if(s=='OR' || s=='or')
                            caseFieldSet.Where_Clause_AGN__c += ' OR ';
                        if(s=='AND' || s=='and')
                            caseFieldSet.Where_Clause_AGN__c += ' AND ';
                    }
                }                    
            }else{
                caseFieldSet.Where_Clause_AGN__c = filterCondition1;
            }
                
            upsert caseFieldSet;
        }       
        
    if(isReorder!=true || isReorder!=null)
    {
        if((selectedFields.size()==0 || selectedFields==null) && isReorder!=true)
        {
           // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.CaseSelectFieldsError_AGN));
            return null;
        }
        for (String option : selectedFields){            
            if(!caseFieldSet.Selectedfields_AGN__c.contains(option) && (caseFieldSet.Selectedfields_AGN__c!='' || caseFieldSet.Selectedfields_AGN__c!=null ))
                caseFieldSet.Selectedfields_AGN__c += option + ';';
        }
        system.debug('caseFieldSet '+caseFieldSet);
        caseFieldSet.SelectedFields_AGN__c = caseFieldSet.SelectedFields_AGN__c.removeEnd(';');        
        upsert caseFieldSet;
        userId= UserInfo.getUserId();
        userNm=UserInfo.getName();
        newView=GCSP_Items_to_Approve_AGN__c.getValues(userNm);
        newView=new GCSP_Items_to_Approve_AGN__c(Name=userNm,User_Id_AGN__c=userId,Last_accessed_view_AGN__c=caseFieldSet.Id);
        upsert newView User_Id_AGN__c;
    }
    return null;
}

public String operatorValue(String operator , String value, String fieldcon){
    String fullCondition = '';
    Map<String,String> pickMap = new Map<String,String>();
    Schema.SObjectType newsObject = Schema.getGlobalDescribe().get('Case');
    Map<String, Schema.SObjectField> o = newsObject.getDescribe().fields.getMap();
    for(Schema.SObjectField field : o.values()) {
        String apiname=field.getDescribe().getName();
        String type = string.valueOf(field.getDescribe().getType());
        if(apiname.equals(fieldcon) && type=='picklist'){            
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pl : ple){
                pickMap.put(pl.getLabel(), pl.getValue());
            }            
        }                       
    }
    if(operator != 'in'){
        if(pickMap != Null && pickMap.containsKey(value))
            value = pickMap.get(value);
    }    
    if(operator == '=' || operator == '!='){        
        fullCondition = operator +' '+ '\'' + value + '\'';
        return fullCondition;
    }else if(operator == 'in'){
        List<String> val = new List<String>();
        String finalValue = '';
		String transVal = '';        
            if(value.contains(',')){
                val = value.split(',');
                for(String s : val){
                    String temp = s.substring(1,s.length()-1);
                    if(pickMap != Null && pickMap.containsKey(temp)){
                       transVal += '\'' + pickMap.get(temp) + '\'' + ',';
                    }                    
                }
                finalValue = transVal.substring(0,transVal.length()-1);
            } 
                        
        fullCondition = operator +' '+ '(' + ( (finalValue == '') ? value : finalValue) + ')';
        return fullCondition;
    }else{
        if(operator == '%'){
            fullCondition = ' LIKE '+'\''+value+'%'+'\'';
            return fullCondition;
        }
        if(operator == '%%'){
            fullCondition = ' LIKE '+'\'' + '%' + value + '%' + '\'';
            return fullCondition;
        }
        if(operator == '%e'){
            fullCondition = ' LIKE '+ '\'' + '%' + value + '\'';
            return fullCondition;
        }else{
            return fullCondition;
        }        
    }
}

public Pagereference doCancel(){
    return null;
}
}