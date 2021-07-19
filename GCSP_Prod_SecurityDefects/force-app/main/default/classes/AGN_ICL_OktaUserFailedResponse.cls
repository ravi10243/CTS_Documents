public class AGN_ICL_OktaUserFailedResponse {

	public String errorCode;
	public String errorSummary;
	public String errorLink;
	public String errorId;
	public List<ErrorCauses> errorCauses;

	public class ErrorCauses {
		public String errorSummary;
	}
	
	public static AGN_ICL_OktaUserFailedResponse parse(String json) {
		return (AGN_ICL_OktaUserFailedResponse) System.JSON.deserialize(json, AGN_ICL_OktaUserFailedResponse.class);
	}
}