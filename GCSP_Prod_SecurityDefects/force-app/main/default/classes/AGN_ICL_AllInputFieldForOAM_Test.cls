@isTest
public class AGN_ICL_AllInputFieldForOAM_Test {
    
   @isTest
    public static void getPicklistValuesTest(){
    String SObjectAPIName ='Locator_Listing_AGN__c';
    String FieldAPIName = 'Brand_AGN__c';
    List<AGN_ICL_AllInputFieldForOAM.PicklistWrapper> wrapperList= new List<AGN_ICL_AllInputFieldForOAM.PicklistWrapper>();
    Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(SObjectAPIName).getDescribe().fields.getMap().get(FieldAPIName).getDescribe();
    List<Schema.PicklistEntry> pickListVal= fieldResult.getPicklistValues();            
    for( Schema.PicklistEntry entry: pickListVal){
        wrapperList.add(new AGN_ICL_AllInputFieldForOAM.PicklistWrapper(entry));
     }
     AGN_ICL_AllInputFieldForOAM.PicklistWrapper wrapper = new AGN_ICL_AllInputFieldForOAM.PicklistWrapper();
     System.Test.startTest();
        wrapperList=AGN_ICL_AllInputFieldForOAM.getPicklistValues(SObjectAPIName,FieldAPIName);
        System.assertEquals(2, picklistval.size());
        System.assertEquals('CoolSculpting', wrapperList[0].label);
        System.assertEquals('Juvederm', wrapperList[1].label);
     System.Test.stopTest();
        }
}