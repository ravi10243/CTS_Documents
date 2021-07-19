/**
* 
* @description This class encapsulates the Email message fields.
*/
public with sharing class AGN_EmailMessageWrapper {
	/** 
	* 
	* @description Constructs an email message.
	* @param String The 'from' email address.
	* @param Id The 'to' address as Id. Populating the Salesforce Id in the 'to' address field doesn't count against the limits. 
	* @param String The 'bcc' email address.
	* @param String The subject of the email.
	* @param String The text of the email. Text can be plain or in html.
	*/
	public AGN_EmailMessageWrapper(String fromAddr, Id toAddrId, String bccAddr, String sub, String body) {
		this(fromAddr, null, toAddrId, bccAddr, sub, body, null);
	}
	
	/** 
	* 
	* @description Constructs an email message.
	* @param String The 'from' email address.
	* @param Id The 'to' address as Id. Populating the Salesforce Id in the 'to' address field doesn't count against the limits. 
	* @param String The subject of the email.
	* @param String The text of the email. Text can be plain or in html.
	*/
	public AGN_EmailMessageWrapper(String fromAddr, Id toAddrId, String sub, String body) {
		this(fromAddr, null, toAddrId, null, sub, body, null);
	}
	
	public AGN_EmailMessageWrapper(String fromAddr, String toAddr, String sub, String body) {
		this(fromAddr, toAddr, null, sub, body, null);
	}
	
	public AGN_EmailMessageWrapper(String fromAddr, Id toAddrId, String sub, Map<String, String> mapSubjectParams, Map<String, String> mapBodyParams) {
		this(fromAddr, null, toAddrId, null, sub, mapSubjectParams, null, mapBodyParams );
	}
	
	/** 
	* 
	* @description Constructs an email message.
	* @param String The 'from' email address.
	* @param Id The 'to' address as Id. Populating the Salesforce Id in the 'to' address field doesn't count against the limits. 
	* @param Map<String, String> A map of key/value pairs to replace the dyncamic placeholders in the email body. The key should 
	*								match the dynamic placeholder in the email text. For e.g. a dynamic placeholder will look like
	*								{!Case.Name}, while key/value pair will look like '{!Case}', 'FEED-00001'. 
	*/
	public AGN_EmailMessageWrapper(String fromAddr, Id toAddrId, Map<String, String> mapParams) {
		this(fromAddr, null, toAddrId, null, null, null, mapParams);
	}
	
	/** 
	* 
	* @description Constructs an email message.
	* @param String The 'from' email address.
	* @param Id The 'to' address as Id. Populating the Salesforce Id in the 'to' address field doesn't count against the limits.
	* @param String The subject of the email. 
	* @param Map<String, String> A map of key/value pairs to replace the dyncamic placeholders in the email body. The key should 
	*								match the dynamic placeholder in the email text. For e.g. a dynamic placeholder will look like
	*								{!Case.Name}, while key/value pair will look like '{!Case.Name}', 'FEED-00001'. 
	*/
	public AGN_EmailMessageWrapper(String fromAddr, Id toAddrId, String sub, Map<String, String> mapParams) {
		this(fromAddr, null, toAddrId, null, sub, null, mapParams);
	}
	

	/** 
	* 
	* @description Constructs an email message.
	* @param String The 'from' email address.
	* @param String The 'to' email address.
	* @param String The 'bcc' email address.
	* @param String The subject of the email.
	* @param String The text of the email. Text can be plain or in html.
	* @param Id The 'to' address as Id. Populating the Salesforce Id in the 'to' address field doesn't count against the limits. 
	* @param Map<String, String> A map of key/value pairs to replace the dyncamic placeholders in the email body. The key should 
	*								match the dynamic placeholder in the email text. For e.g. a dynamic placeholder will look like
	*								{!Case.Name}, while key/value pair will look like '{!Case.Name}', 'FEED-00001'. 
	*/
	public AGN_EmailMessageWrapper(String fromAddr, String toAddr, Id toAddrId, String bccAddr, String sub, String body, Map<String, String> mapBodyParams) {
		this.FromAddress = fromAddr;
		this.ToAddress = toAddr;
		this.ToAddressId = toAddrId;
		this.BccAddress = bccAddr;
		this.Subject = sub;
		this.Body = body;
		this.ParameterBodyMap = mapBodyParams;
	}
	
	public AGN_EmailMessageWrapper(String fromAddr, String toAddr, String bccAddr, String sub, String body, Map<String, String> mapBodyParams) {
		this.FromAddress = fromAddr;
		this.ToAddress = toAddr;
		this.BccAddress = bccAddr;
		this.Subject = sub;
		this.Body = body;
		this.ParameterBodyMap = mapBodyParams;
	}
	
	/** 
	* 
	* @description Constructs an email message.
	* @param String The 'from' email address.
	* @param String The 'to' email address.
	* @param String The 'bcc' email address.
	* @param String The subject of the email.
	* @param String The text of the email. Text can be plain or in html.
	* @param Id The 'to' address as Id. Populating the Salesforce Id in the 'to' address field doesn't count against the limits. 
	* @param Map<String, String> A map of key/value pairs to replace the dyncamic placeholders in the email body. The key should 
	*								match the dynamic placeholder in the email text. For e.g. a dynamic placeholder will look like
	*								{!Case.Name}, while key/value pair will look like '{!Case.Name}', 'FEED-00001'. 
	*/
	public AGN_EmailMessageWrapper(String fromAddr, String toAddr, Id toAddrId, String bccAddr, String sub, Map<String, String>  mapSubjectParams, String body, Map<String, String> mapBodyParams) {
		this.FromAddress = fromAddr;
		this.ToAddress = toAddr;
		this.ToAddressId = toAddrId;
		this.BccAddress = bccAddr;
		this.Subject = sub;
		this.ParameterSubjectMap = mapSubjectParams;
		this.Body = body;
		this.ParameterBodyMap = mapBodyParams;
	}
	
	/** 
	* 
	* @description Gets or sets the From Address.
	*/
	public String FromAddress { get; set; }
	
	/** 
	* 
	* @description Gets or sets the To Address.
	*/
	public String ToAddress { get; set; }
	
	/** 
	* 
	* @description Gets or sets the To Address as Id.
	*/
	public Id ToAddressId { get; set; }
	
	/** 
	* 
	* @description Gets or sets the BCC Address.
	*/
	public String BccAddress { get; set; }
	
	/** 
	* 
	* @description Gets or sets the subject of the email.
	*/
	public String Subject { get; set; }
	
	public Map<String, String> ParameterSubjectMap { get; set; }
	/** 
	* 
	* @description Gets or sets the text of the email.
	*/
	public String Body { get; set; }
	
	/** 
	* 
	* @description Gets or sets the parameter map.
	*/
	public Map<String, String> ParameterBodyMap { get; set; }
}