public class AGN_OktaUserFailedResponse {

	public String errorCode;
	public String errorSummary;
	public String errorLink;
	public String errorId;
	public List<ErrorCauses> errorCauses;

	public class ErrorCauses {
		public String errorSummary;
	}
	
	public static AGN_OktaUserFailedResponse parse(String json) {
		return (AGN_OktaUserFailedResponse) System.JSON.deserialize(json, AGN_OktaUserFailedResponse.class);
	}
}