public class AGN_GetChildCraForTemplate {
    
    public Id crId {get;set;} 
    public List<Allergan_Customer_Address_AGN__c> cra {get{
       return getchildInfo();
    }set;}


    public List<Allergan_Customer_Address_AGN__c> getchildInfo() {
        return [SELECT Address_Line_1_AGN__c, Zip_AGN__c, Sold_To_AGN__c, Ship_To_AGN__c, Bill_To_AGN__c, Company_Name_AGN__c, SAP_ID_AGN__c FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =: crId];

    }
}