/*************************************************************************************************************************
@ Class:          AGN_ContentDistribution_Handler 
@ Version:        1.0
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        This class is used to make calls to required class for ContentDistribution Trigger
@ PMO:            CR-3334: Infocus tab introduction
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.07.2020 / Ayush Basak / Created the trigger.
***************************************************************************************************************************/

public class AGN_ContentDistribution_Handler {
    
    public static void onAfterInsertHandler(List<ContentDistribution> newList, Map<Id, ContentDistribution> newMap){
        AGN_AMI_ContentDelivery_Helper.linkUpdateHelper(newList);
    }
    
    public static void onAfterUpdateHandler(List<ContentDistribution> newList, Map<Id, ContentDistribution> newMap, 
                                            List<ContentDistribution> oldList, Map<Id, ContentDistribution> oldMap){
        AGN_AMI_ContentDelivery_Helper.linkUpdateHelper(newList);
    }
    
    
}