/*****************************************************************************************************************************************************************
Apex  Class- AGNGigyaInterfaceLogPlatformEventHelper
Description- This is a generic class which is used to capture exception parameters.
Developer Name- Mansi Mittal
Development Date- 3 May 2018
********************************************************************************************************************************************************************/


public class AGN_customException extends Exception {
    public Integer errorCode;
    public String errorMessage, errorDetail;
    
    public AGN_customException(Integer errorCode, String errorMessage) {
			this(errorCode, errorMessage, errorMessage);
		}
    
    public AGN_customException(Integer errorCode, String errorMessage, String errorDetail) {
        this.errorCode=errorCode;
        this.errorMessage=errorMessage;
        this.errorDetail=errorDetail;
    }

}