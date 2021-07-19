/**
 * --------------
 * Allergan GDPR
 * March 2018
 * --------------
 * Gigya error class
 */

public class AGNGigyaError {

	public Integer code;
	public String message;
	public String details;

	override public String toString() {
			String result = '';
			if (code != null && code > 0) {
					result += '[' + code + '] ';
			}
			if (message != null && message.length() > 0) {
					result += message + ' ';
			}
			if (details != null && details.length() > 0) {
					result += '(' + details + ')';
			}
			return result;
	}
}