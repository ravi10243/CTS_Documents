/**************************************************************************************************************************
@ Class:          AGN_AMI_CustomMetadataUtils
@ Version:        1.0
@ Author:         Ambroz Khan (mdambroz.khan@cognizant.com)
@ Purpose:        Utility class for deploying changes in metadata.
@ PMO:            CR-3468: Vault code changes for UK admin.
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 28.07.2020 / Ambroz Khan / Created the class.
***************************************************************************************************************************/
public class AGN_AMI_CustomMetadataUtils implements Metadata.DeployCallback {
    public String Labels = 'Label';
    //Inteface method 
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        try{
			if (result.status == Metadata.DeployStatus.Succeeded) {
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				List<string> to = new List<string>();
				to.add(UserInfo.getUserEmail());
				email.setToAddresses(to);
				email.setSubject(system.Label.AGN_AMI_VaultcodeMailSubject);
				email.setHtmlBody(system.Label.AGN_AMI_Vaultcode_Mail);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
				
			} else {
				// Add Error Logging
			}
		}catch(exception e){
			AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_CustomMetadataUtils','handleResult');
        }
    }
    public static void updateCustomMetadata(String metdataName, Map<String,Map<String, Object>> metadataRecordMap, String notificationMessage){
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for(String recordDevName : metadataRecordMap.keySet()){
            //if()
            Metadata.CustomMetadata cMetadata = new Metadata.CustomMetadata();
            cMetadata.fullName = metdataName + '.' + recordDevName;
            cMetadata.label = (String)metadataRecordMap.get(recordDevName).get('Label');
            for(String key : metadataRecordMap.get(recordDevName).keySet()){
                if(key == 'Label') {
                    continue;
                }
                Metadata.CustomMetadataValue cMetadataValue = new Metadata.CustomMetadataValue();
                cMetadataValue.Field = key;
                cMetadataValue.Value = metadataRecordMap.get(recordDevName).get(key); 
                cMetadata.values.add(cMetadataValue);
            }
            mdContainer.addMetadata(cMetadata);
        }
        AGN_AMI_CustomMetadataUtils callback = new AGN_AMI_CustomMetadataUtils();
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
    }
}