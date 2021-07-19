public class AGNGigyaValidationException extends Exception {
	public Integer errorCode;
    public String errorMessage, errorDetail;

		public AGNGigyaValidationException(Integer errorCode, String errorMessage) {
			this(errorCode, errorMessage, errorMessage);
		}

		public AGNGigyaValidationException(Integer errorCode, String errorMessage, String errorDetail) {
        this.errorCode=errorCode;
        this.errorMessage=errorMessage;
        this.errorDetail=errorDetail;

				String result = '';
				if (errorCode != null && errorCode > 0) {
						result += '[' + errorCode + '] ';
				}
				if (errorMessage != null && errorMessage.length() > 0) {
						result += errorMessage + ' ';
				}
				if (errorDetail != null && errorDetail.length() > 0) {
						result += '(' + errorDetail + ')';
				}

				this.setMessage(result);
    }
}