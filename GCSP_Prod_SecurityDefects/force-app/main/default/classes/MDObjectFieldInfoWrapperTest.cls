@isTest
public class MDObjectFieldInfoWrapperTest {
	@isTest
    public static void wrapperTest(){
        Test.startTest();
        MDObjectFieldInfoWrapper wrapper = new MDObjectFieldInfoWrapper();
        wrapper.FieldLabel = 'TestLabel';
        wrapper.FieldAPIName = 'TestAPIName';
        System.assertEquals('TestLabel', wrapper.FieldLabel);
        System.assertEquals('TestAPIName', wrapper.FieldAPIName);
        
        Test.stopTest();
    }
}