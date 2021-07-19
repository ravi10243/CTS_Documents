global  class AGN_ContractController
{
    public Id contractId{get;set;}
    public string name{get;set;}
    Global string globalAccId2 ;
    List<Id> globalAccId = new List<Id>();
    
    List<Address_vod__c> contractPartnerList = new List<SObject>();
    List<Address_vod__c> contractPartnerListTemp = new List<SObject>();
    
    public  List<Contract_vod__c> getCONTRACTLIST()
    {
        List<Contract_vod__c> CONTRACTLIST;
        
        CONTRACTLIST= [SELECT Name,Contract_Type_AGN__c,Owner_Expiration_Notice_AGN__c,End_Date_vod__c  FROM Contract_vod__c WHERE Id=: contractId];
        
        system.debug('Order'+CONTRACTLIST);
        
        return CONTRACTLIST;
        
    }
    
    public list<Contract_Partner_vod__c> getCONTRACTLINES(){
        List<Contract_Partner_vod__c> CONTRACTLINES;
        return CONTRACTLINES;
        
    }
    
    public  List<Address_vod__c> getcontractPartnerList()
        
    {
        List<Contract_Partner_vod__c> CONTRACTLINES;
        ID accntID;
        CONTRACTLINES= [select ID, Account_vod__c from Contract_Partner_vod__c WHERE Contract_vod__r.Id=: contractId order by Account_vod__r.Name];
        
        
        for (Contract_Partner_vod__c cpid :CONTRACTLINES)
        {
            
            globalAccId .add(cpid.Account_vod__c);
            
        }
        
        contractPartnerList = [select Account_vod__r.Name, Account_vod__r.Primary_Parent_vod__r.Name, 
                               Name,Address_line_2_vod__c,Address_Line_3_AGN__c,City_vod__c,State_vod__c,Zip_4_vod__c,Country_vod__c FROM Address_vod__c 
                               WHERE Account_vod__c = :globalAccId and Primary_vod__c=TRUE
                              ];
        
       
        
        return contractPartnerList;
        
    }
    public  List<Address_vod__c > getCONTRACTLINES1()
    {
        List<Address_vod__c > CONTRACTLINES1;
        
        
        CONTRACTLINES1= [SELECT Name,Address_line_2_vod__c,Address_Line_3_AGN__c,City_vod__c,State_vod__c,Zip_4_vod__c,Country_vod__c FROM Address_vod__c WHERE Account_vod__c =:globalAccId and Primary_vod__c=TRUE order by Account_vod__r.Name];
        
        
        return CONTRACTLINES1;
        
    }
    public List<Account> getPrimaryAccount()
    {
        List<Account> PrimaryAccount;
        
        PrimaryAccount=[SELECT Primary_Parent_vod__r.Name FROM Account WHERE Id =: globalAccId ];
        system.debug('@@@@'+PrimaryAccount.size());
        
        return PrimaryAccount;
    }
}