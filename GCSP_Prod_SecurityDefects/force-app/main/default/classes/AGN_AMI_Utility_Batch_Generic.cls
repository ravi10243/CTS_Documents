global class AGN_AMI_Utility_Batch_Generic implements Database.Batchable<sObject>,Database.Stateful{
    
    
    public Set<String> possibleDmlOperation = new Set<String>{'Insert','Update','Delete','Upsert','Undelete','Reset'};
    public String dmlOperation;
    public List<SObject> sobjList = new List<SObject>();        
    
    global AGN_AMI_Utility_Batch_Generic(List<SObject> sobjListPassed,String dmlOperationPassed)       
    {
        sobjList = sobjListPassed;  
        if(possibleDmlOperation.contains(dmlOperationPassed)) 
            dmlOperation = dmlOperationPassed;                                      
    }
    
    global List<SObject> start(Database.BatchableContext BC) {
        
        return sobjList;    
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        if(dmlOperation == 'Insert')
            Insert scope;
        else if(dmlOperation == 'Update')
            Update scope;    
        else if(dmlOperation == 'Delete')
            Delete scope;    
        else if(dmlOperation == 'Upsert')
            Upsert scope;    
        else if(dmlOperation == 'Undelete')
            Undelete scope; 
        else if(dmlOperation == 'Reset'){
            List<User> usrLIst=new List<User>();
            for(Sobject s:scope){
                usrLIst.add((User)s);
            }
            for(User u:usrLIst){
                System.setPassword(u.Id,'TeamAMI@231');
            }
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
    }          
}