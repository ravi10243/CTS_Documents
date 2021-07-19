/******************************************************************************
    Name        :    AGN_CoolNetIntMarketPageController 
    Purpose     :    Custom Controller for AGN_CoolNetIntMarketpage
    Created By  :    Cognizant 
    Created     :    02/02/2018
    Modified    :    02/02/2018
******************************************************************************/

public class AGN_CoolNetIntMarketPageController {
    
    public List<Marketing_Data_AGN__c> intMarketingDataList {get; set;}
    String intDataCategory = 'Internal Marketing';
    
    /******************************************************************************
    Name        :    AGN_CoolNetIntMarketPageController 
    Purpose     :    Constructor
    Return      :    void 
    Params      :    NA
    ******************************************************************************/

    
    public AGN_CoolNetIntMarketPageController() {
        intMarketingDataList = new List<Marketing_Data_AGN__c>();
        getIntMarketingData();
    }


    /******************************************************************************
    Name        :    getIntMarketingData 
    Purpose     :    Public method to fetch intenal marketing data
    Return      :    void 
    Params      :    NA
    ******************************************************************************/
    
    public void getIntMarketingData() {
        intMarketingDataList = [SELECT Name, Category_AGN__c, Marketing_Position_AGN__c, (SELECT Id FROM Attachments LIMIT 1)
                             FROM Marketing_Data_AGN__c 
                             WHERE Category_AGN__c= :intDataCategory 
                             ORDER BY Marketing_Position_AGN__c ASC];
    }
}