public without sharing class AGN_CaseEmailTemplateController {
    //Variables de componente
    public Id thisCaseId {get; set;}
    public Id thisUserId {get; set;}
    public String thisUserName {get; set;}
    public string CaseUrl{get{
             string url='https://'+System.URL.getSalesforceBaseUrl().getHost()+'/'+thisCaseId;
             return url;   }}
       
    public Case getCase(){
            Case cs = new Case();
            if(thisCaseId!=null){
              String query = 'SELECT ';
              for(Schema.SObjectField nameAPIfield : Schema.SObjectType.Case.fields.getMap().values()){
                query += query=='SELECT '?String.ValueOf(nameAPIfield):', '+String.ValueOf(nameAPIfield);
              }
              query += ', Account.Name, Contact.Name, Sales_Rep_Requester_AGN__r.Name, CreatedBy.Name ';
              query +=' FROM Case WHERE Id=\''+thisCaseId+'\'';
              cs= DataBase.query(query);
            }
            return cs;
    }
    
    public List<Case_Product_List_AGN__c> getItemsListProdSAP() {
            list<Case_Product_List_AGN__c> listCaseSAPProduct = new list<Case_Product_List_AGN__c>();
            if(thisCaseId!=null){
                listCaseSAPProduct=[SELECT Id, Case_AGN__c, Product_AGN__r.Name, Quantity_AGN__c, SAP_Product_List_AGN__r.Name FROM Case_Product_List_AGN__c WHERE Case_AGN__c=:thisCaseId];
            }
            return listCaseSAPProduct; 
    }
    
    
   /* public String getFecha(){
        String strReturn;
        if(thisCaseId!=null){
            Datetime createdDate = getCaso().CreatedDate;
            if(createdDate!=null){
                strReturn = String.valueOf(createdDate.day()+'/'+createdDate.month()+'/'+createdDate.year());
            }
        }
        return strReturn;
    } */
    
  /*  public String getNome(){
        String actor;
        QueueSobject queue;
        User user;
        
        if(thisCaseId!=null){
            try{
                list<ProcessInstance> pi=[SELECT Id, (SELECT Id, ActorId FROM Workitems) FROM ProcessInstance WHERE TargetObjectId=:thisCaseId AND Status='Pending'];
                actor=pi[0].Workitems[0].ActorId;
            }catch(Exception e){}
        }
        
        if(actor!=null && actor!=''){
            try{
                queue=[SELECT Id, Queue.Name, Queue.Id FROM QueueSobject WHERE Queue.Id=:actor LIMIT 1];
                actor=queue.Queue.Name;
            }catch(Exception e1){
                try{
                    user=[SELECT Id, Name FROM User WHERE Id=:actor];
                    actor=user.Name;
                }catch(Exception e2){
                    return e2.getMessage();
                }
            }
        }
        return actor;
    }*/
    
  /*  public String getApprovalId(){
        String Id;
        
        if(thisCaseId!=null){
            try{
                list<ProcessInstance> pi=[SELECT Id, (SELECT Id, ActorId FROM Workitems) FROM ProcessInstance WHERE TargetObjectId=:thisCaseId AND Status='Pending'];
                Id=pi[0].Workitems[0].Id;
            }catch(Exception e){}
        }
        
        return Id;
    } 8/
    
   /* static testmethod void unitTest(){
        AGN_CaseEmailTemplateController cetc = new AGN_CaseEmailTemplateController();
        cetc.getCaso();
        cetc.getItemsListProdSAP();
        cetc.getApprovalId();
        cetc.getFecha();
    }*/
}