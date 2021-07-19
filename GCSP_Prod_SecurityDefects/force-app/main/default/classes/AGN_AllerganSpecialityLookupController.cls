public class AGN_AllerganSpecialityLookupController {
    
    public String query {get; set;}
    public List<Specialty_Allergan_AGN__c> specList {get; set;}
    public String GAS_LOOKUP {set;get;}
    public AGN_AllerganSpecialityLookupController(){
    
        String lang = UserInfo.getLanguage() ;
         List<Message_vod__c> labels = [SELECT Name,Text_vod__c 
                                    FROM Message_vod__c 
                                    WHERE Language_vod__c = :lang AND 
                                    Category_vod__c = 'Account' AND 
                                    Name LIKE 'GAS_LOOKUP%' AND
                                    Active_vod__c = true] ;
         if(labels!=null && labels.size()>0){
             GAS_LOOKUP=String.escapeSingleQuotes(labels[0].Text_vod__c);
         }
    }
    public PageReference runQuery()
    {
        User usrDetails = [select Country_Code__c,MA_Medical_Affairs_AGN__c,MA_User_Country_Code_AGN__c,Cluster_User_AGN__c,Profile.Name from User where id=:UserInfo.getuserid()];
        if(usrDetails.MA_Medical_Affairs_AGN__c == 'Yes' || usrDetails.Profile.Name == 'System Administrator'){
            if(query == NULL || query == '')
                specList = [select Name,Country_Code_AGN__c from Specialty_Allergan_AGN__c limit 1000];
            else{
                string cond = '%' + query + '%';
                specList = [select Name,Country_Code_AGN__c from Specialty_Allergan_AGN__c where Name like : cond];
            }
        }else if(usrDetails.Cluster_User_AGN__c){
            if(query == NULL || query == '')
                specList = [select Name,Country_Code_AGN__c from Specialty_Allergan_AGN__c where Country_Code_AGN__c=:usrDetails.MA_User_Country_Code_AGN__c];
            else{
                string cond = '%' + query + '%';
                specList = [select Name,Country_Code_AGN__c from Specialty_Allergan_AGN__c where Country_Code_AGN__c=:usrDetails.MA_User_Country_Code_AGN__c AND Name like : cond];
            }
        }else if(usrDetails.Profile.Name != 'System Administrator'){
            if(query == NULL || query == '')
                specList = [select Name,Country_Code_AGN__c from Specialty_Allergan_AGN__c where Country_Code_AGN__c=:usrDetails.Country_Code__c];
            else{
                string cond = '%' + query + '%';
                specList = [select Name,Country_Code_AGN__c from Specialty_Allergan_AGN__c where Country_Code_AGN__c=:usrDetails.Country_Code__c AND Name like : cond];
            }
        }            
        return null;
    }
}