@isTest(SeeAllData=true)
public class AGN_AMI_VaultcodeController_Test {
    //Validating the Deployment Success with change in the Vault codes.
    @isTest
    public static void AGN_AMI_VaultcodeControllerTestMethod(){
        Test.startTest();
        User adminUser1 = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(adminUser1){
            AGN_AMI_Vaultcode_Controller zinc = new AGN_AMI_Vaultcode_Controller();
            zinc.edit();
            system.debug('zincvalues' + zinc);
            AMI_Page_Zinc_Mapping_AGN__mdt temp = zinc.zincdata[0];            
            temp.ZINC_AGN__c = 'changes1';
            zinc.zincdata[0] = temp;
            zinc.save();            
            zinc.cancel();
            zinc.goToEditPage();
            zinc.refresh (); 
            zinc.getData();

        }
    }
        @isTest
    public static void AGN_AMI_VaultcodeControllerTestMethod2(){
        Test.startTest();
        User adminUser1 = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(adminUser1){
            AGN_AMI_Vaultcode_Controller zinc = new AGN_AMI_Vaultcode_Controller();
            // Instantiate the callback.
            Metadata.DeployCallback callback = new AGN_AMI_CustomMetadataUtils();
            // Create test result and context objects.
            Metadata.DeployResult result = new Metadata.DeployResult();
            result.numberComponentErrors = 0;
            result.status = Metadata.DeployStatus.Succeeded;
            Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
            // Invoke the callback's handleResult method.
            callback.handleResult(result, context);
        }
    }    
    //Validating the Deployment Failure
    @isTest
    public static void AGN_AMI_VaultcodeControllerTestMethod3(){
        Test.startTest();             
        // Creating Admin User
        User adminUser1 = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(adminUser1){
            AGN_AMI_Vaultcode_Controller zinc = new AGN_AMI_Vaultcode_Controller();
            zinc.edit();
            AMI_Page_Zinc_Mapping_AGN__mdt temp = zinc.zincdata[0];
            temp.ZINC_AGN__c = 'changes2';
            zinc.zincdata[0] = temp;
            Metadata.DeployCallback callback = new AGN_AMI_CustomMetadataUtils();
            Metadata.DeployResult result = new Metadata.DeployResult();
            result.numberComponentErrors = 0;
            result.status = Metadata.DeployStatus.Failed;
            Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
            callback.handleResult(result, context);
        }
    }
    AGN_AMI_CustomMetadataUtils zinc2 = new AGN_AMI_CustomMetadataUtils();
}