public without sharing  class AGN_ICL_TestRegFormCtrl {
    public String name {get;set;}
    public Account Clinic_details {get;set;}
    public Account Clinic_Admin_details {get;set;}
    public Locator_Listing_AGN__c newLocator {get;set;}
    public static final String USERNAME_SUFFIX = 'icl';
    public AGN_ICL_TestRegFormCtrl()
    {
    }
    /*
@AuraEnabled
public static List<String> getSalutaionList(){

List<SelectOption> options = new List<SelectOption>();
List<String> salutation = new List<String>();
options.add(new SelectOption( '', '--Select--'));
Schema.DescribeFieldResult fieldResult = Account.Salutation.getDescribe();     
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
for( Schema.PicklistEntry f : ple){
options.add(new SelectOption( f.getValue(), f.getLabel()));
salutation.add(f.getValue());
}   

return salutation;
}*/
    
    @AuraEnabled
    public static Account fetchClinicAdminDetails()
    {
        // Gets User Details with Business Account ID//0015E00000khM83QAE
        Account acc ;
        /*String loc_id = [Select id,name from User where id =:Userinfo.getUserId() limit 1]
        if(loc_id != null)
        {
            String acc_id = [select id,name,Clinic_Admin_AGN__c from Locator_Listing_AGN__c where id=:loc_id limit 1][0].Clinic_Admin_AGN__c;
            acc = [Select Id,Salutation,FirstName,Country_Code__c,LastName,PersonEmail,Primary_Parent_vod__c from Account where Id=:acc_id];
        }*/
        AccountContactRelation ac = new AccountContactRelation();
        User u = [Select id,name,Country_code__c,LanguageLocaleKey,contactId,Email from User where ID=:UserInfo.getUserId() limit 1];
        
        String conid = u.ContactId;
        List<AccountContactRelation> acc_con = [SELECT AccountId,Account.name,Account.Recordtype.name,Account.IsPersonAccount,ContactId,EndDate,Id,IsActive FROM AccountContactRelation WHERE ContactId =:conid and Account.IsPersonAccount = true];
      
        if(acc_con.size()==1)
        {
            ac = acc_con.get(0);
            acc = [Select Id,Salutation,FirstName,Country_Code__c,LastName,PersonEmail,Primary_Parent_vod__c from Account where Id=:ac.AccountId];
        }
       /* else
        {
            //acc = [Select Id,Salutation,FirstName,Country_Code__c,LastName,PersonEmail,Primary_Parent_vod__c from Account where Id='0015E00000ktzlz'];
        }*/
        /*Account a = new Account();
a.FirstName = 'abc';
a.LastName = 'sdfdfj';
a.PersonEmail = 'dfdjfn@gmail.com';*/
        return acc;  
    }
    
    @AuraEnabled
    public static Account fetchClinicDetails(Id loclstId)
    {
        Locator_Listing_AGN__c loc = [Select id,name,Account_AGN__c from Locator_Listing_AGN__c where Id=:loclstId limit 1];
        Account clnc = new Account();
        if(loc != null)
        {
            clnc = [Select Id,Name from Account where Id=:loc.Account_AGN__c]; 
        }
        
        return clnc;  
    }  
    
    @AuraEnabled
    public static List<String> getCommunityURL()
    {
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        List<String> commURL = new List<String>();
        commURL.add((String)portalSetting.ICL_Community_Portal_Base_URL_AGN__c);
        commURL.add((String)portalSetting.ICL_Community_Portal_Suffix_AGN__c);
        return commURL;
    }

    
    @AuraEnabled
    public static Locator_Listing_AGN__c fetchLocatorListing(Id locId)
    {
       
        Locator_Listing_AGN__c loclstng = new Locator_Listing_AGN__c();
            loclstng  = [Select Id,Name,Brand_AGN__c,Email_AGN__c,Ask_Question_Email_AGN__c,Enquiriy_Email_AGN__c,
                                            Clinic_Experience_AGN__c,Request_Call_Email_AGN__c,Open_Evenings_Email_AGN__c,
                                            Offer_Evenings_AGN__c,Testimonial_Available_AGN__c,Phone_Number_AGN__c,Website_AGN__c,Google_Url_AGN__c,Street_AGN__c,
                                            City_AGN__c,Country_AGN__c,Zip_Code_AGN__c,Clinic_Experience_Site_AGN__c,State_Providence_Region_AGN__c,Monday_Open_Hours_AGN__c,
                                            Monday_Close_Hours_AGN__c,Tuesday_Open_Hours_AGN__c,Tuesday_Close_Hours_AGN__c,
                                            Wednesday_Open_Hours_AGN__c,Wednesday_Close_Hours_AGN__c,
                                            Thursday_Open_Hours_AGN__c,Thursday_Close_Hours_AGN__c,
                                            Friday_Open_Hours_AGN__c,Friday_Close_Hours_AGN__c,Saturday_Open_Hours_AGN__c,
                                            Saturday_Close_Hours_AGN__c,Sunday_Open_Hours_AGN__c,
                                            Sunday_Close_Hours_AGN__c from Locator_Listing_AGN__c where Id=:locId]; 
       
       
        return loclstng;  
    }  
    
    @AuraEnabled
    public static List<String> getBrandPicklistValues()
    {
        List<String> picklistval = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Locator_Listing_AGN__c').getDescribe().fields.getMap().get('Brand_AGN__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            picklistval.add(f.getValue());
        }   
        
        return picklistval;
    }
    
    public List<Schema.FieldSetMember> getAccountFieldSet()
    {
        Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Account.fieldSets.getMap();
        Schema.FieldSet fieldSetObj = FsMap.get('AGN_ICL_Account_Default');
       
        /*Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Account');
Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('AGN_ICL_Account_Default');*/
        return fieldSetObj.getFields();
    }
    
    
   
    //Check for duplicate Users with the email address
     @TestVisible private Static Boolean CheckDuplicateClinicAdmin(String adminemail)
    {
        String newUsername =  adminemail + USERNAME_SUFFIX;
        List<User> u = [Select Id,name,Username from User where Username =:newUsername];
        if(u.size() > 0)
        {
            return true;
        }
        return false;
    }
    
    //Create Person Account for clinic admin
    
    
    @AuraEnabled
    public static Map<String,List<AGN_ICL_Layout_Field__mdt>> getCountryWiseFields()
    {
        String CountryCode = [Select id,name,Country_Code__c  from User where id =:UserInfo.getUserId()][0].Country_Code__c;
        
        Map<String,List<AGN_ICL_Layout_Field__mdt>> section_field_map = new Map<String,List<AGN_ICL_Layout_Field__mdt>>();
        List<AGN_ICL_Layout_Field__mdt> fields = [Select id,Section_Header__c,Field_Regex_AGN__c,Field_for_AGN__c,Field_API_Name_AGN__c,Field_Sobject_API_Name_AGN__c,Field_Label_AGN__c,Field_Of_HCP_or_HCA_AGN__c,Field_Sort_Order_AGN__c,Field_Type_AGN__c,IsPicklist_AGN__c,Required_AGN__c,Country_Code_AGN__c from AGN_ICL_Layout_Field__mdt WHERE Field_Of_HCP_or_HCA_AGN__c = 'SignUp' and Country_Code_AGN__c =:CountryCode order by Field_Sort_Order_AGN__c];
        for(AGN_ICL_Layout_Field__mdt iclmdt : fields)
        {
            if(section_field_map.containsKey(iclmdt.Section_Header__c))
            {
                
                List<AGN_ICL_Layout_Field__mdt> temp = section_field_map.get(iclmdt.Section_Header__c);
                temp.add(iclmdt);
                section_field_map.put(iclmdt.Section_Header__c,temp);
            }
            else
            {
               
                List<AGN_ICL_Layout_Field__mdt> temp = new List<AGN_ICL_Layout_Field__mdt>();
                temp.add(iclmdt);
                section_field_map.put(iclmdt.Section_Header__c,temp);
            }
        }
        
        //return fields;
        return section_field_map;
    }
    
    @AuraEnabled
    public Static boolean updateRec(String loc , String lc_Id)
    {  
        //Locator_Listing_AGN__c loc , String lc_Id
       
        Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(loc);
       
        //String str =  (String)m.get('Monday_Close_Hours_AGN__c');
        //String[] s =((String)m.get('Monday_Close_Hours_AGN__c')).split(':');
        //Time t = Time.newInstance(Integer.valueof(((String)m.get('Monday_Close_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Monday_Close_Hours_AGN__c')).split(':')[1].trim()),0,0);//new Time(m.get('Monday_Close_Hours_AGN__c')+'Z');
       
        /*Locator_Listing_AGN__c lc = (Locator_Listing_AGN__c)JSON.deserialize(loc, Locator_Listing_AGN__c.class);         
       */
        Locator_Listing_AGN__c lc = new Locator_Listing_AGN__c();
        lc.Id = lc_Id;
        //lc.Monday_Close_Hours_AGN__c = t;
         //update lc;
     //  Locator_Listing_AGN__c lc = new Locator_Listing_AGN__c();
        try{
        lc.Id=lc_Id;
       
        lc.Name = (String)m.get('Name');//loc.Name;
        lc.Email_AGN__c = (String)m.get('Email_AGN__c');//loc.Email_AGN__c;
        lc.Street_AGN__c = (String)m.get('Street_AGN__c');//loc.Street_AGN__c;
        lc.Testimonial_Available_AGN__c = (Boolean)m.get('Testimonial_Available_AGN__c');//loc.Testimonial_Available_AGN__c;
        lc.Offer_Evenings_AGN__c = (Boolean)m.get('Offer_Evenings_AGN__c');//loc.Offer_Evenings_AGN__c;
        lc.Request_Call_Email_AGN__c = (String)m.get('Request_Call_Email_AGN__c');//loc.Request_Call_Email_AGN__c;
        lc.Open_Evenings_Email_AGN__c = (String)m.get('Open_Evenings_Email_AGN__c');//loc.Open_Evenings_Email_AGN__c;
        lc.Ask_Question_Email_AGN__c = (String)m.get('Ask_Question_Email_AGN__c');//loc.Ask_Question_Email_AGN__c;
        lc.Enquiriy_Email_AGN__c = (String)m.get('Enquiriy_Email_AGN__c');//loc.Enquiriy_Email_AGN__c;
        lc.Google_Url_AGN__c = (String)m.get('Google_Url_AGN__c');//loc.Google_Url_AGN__c;
        lc.Website_AGN__c = (String)m.get('Website_AGN__c');//loc.Website_AGN__c;
        lc.Clinic_Experience_AGN__c = (Decimal)m.get('Clinic_Experience_AGN__c');//loc.Clinic_Experience_AGN__c;
        lc.Street_AGN__c =  (String)m.get('Street_AGN__c');//loc.Street_AGN__c;
        lc.City_AGN__c = (String)m.get('City_AGN__c');//loc.City_AGN__c;
        lc.State_Providence_Region_AGN__c = (String)m.get('State_Providence_Region_AGN__c');//loc.State_Providence_Region_AGN__c;
        lc.Zip_Code_AGN__c = (String)m.get('Zip_Code_AGN__c');//loc.Zip_Code_AGN__c;
        lc.Country_AGN__c = (String)m.get('Country_AGN__c');//loc.Country_AGN__c;
        lc.Brand_AGN__c = (String)m.get('Brand_AGN__c');//loc.Brand_AGN__c;
        lc.Clinic_Experience_Site_AGN__c = (String)m.get('Clinic_Experience_Site_AGN__c');
        lc.Phone_Number_AGN__c = (String)m.get('Phone_Number_AGN__c');
            
        /*Map<String,String> time_fieldMap = new Map<String,String>();
        time_fieldMap.put('Monday_Open_Hours_AGN__c',(String)m.get('Monday_Open_Hours_AGN__c'));
            time_fieldMap.put('Monday_Close_Hours_AGN__c',(String)m.get('Monday_Close_Hours_AGN__c'));
            time_fieldMap.put('Tuesday_Open_Hours_AGN__c',(String)m.get('Tuesday_Open_Hours_AGN__c'));
            time_fieldMap.put('Tuesday_Close_Hours_AGN__c',(String)m.get('Tuesday_Close_Hours_AGN__c'));
            time_fieldMap.put('Wednesday_Open_Hours_AGN__c',(String)m.get('Wednesday_Open_Hours_AGN__c'));
            time_fieldMap.put('Wednesday_Close_Hours_AGN__c',(String)m.get('Wednesday_Close_Hours_AGN__c'));
            time_fieldMap.put('Thursday_Open_Hours_AGN__c',(String)m.get('Thursday_Open_Hours_AGN__c'));
            time_fieldMap.put('Thursday_Close_Hours_AGN__c',(String)m.get('Thursday_Close_Hours_AGN__c'));
            time_fieldMap.put('Friday_Open_Hours_AGN__c',(String)m.get('Friday_Open_Hours_AGN__c'));
            time_fieldMap.put('Friday_Close_Hours_AGN__c',(String)m.get('Friday_Close_Hours_AGN__c'));
            time_fieldMap.put('Saturday_Open_Hours_AGN__c',(String)m.get('Saturday_Open_Hours_AGN__c'));
            time_fieldMap.put('Saturday_Close_Hours_AGN__c',(String)m.get('Saturday_Close_Hours_AGN__c'));
            time_fieldMap.put('Sunday_Open_Hours_AGN__c',(String)m.get('Sunday_Open_Hours_AGN__c'));
            time_fieldMap.put('Sunday_Close_Hours_AGN__c',(String)m.get('Sunday_Close_Hours_AGN__c'));*/
            /*for(String day : time_fieldMap.keySet())
            {
                lc.day = '';
            }*/
            
            lc.Monday_Open_Hours_AGN__c = (String)m.get('Monday_Open_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Monday_Open_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Monday_Open_Hours_AGN__c')).split(':')[1].trim()),0,0) : null ;
            lc.Monday_Close_Hours_AGN__c = (String)m.get('Monday_Close_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Monday_Close_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Monday_Close_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Tuesday_Open_Hours_AGN__c = (String)m.get('Tuesday_Open_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Tuesday_Open_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Tuesday_Open_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Tuesday_Close_Hours_AGN__c = (String)m.get('Tuesday_Close_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Tuesday_Close_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Tuesday_Close_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Wednesday_Open_Hours_AGN__c = (String)m.get('Wednesday_Open_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Wednesday_Open_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Wednesday_Open_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Wednesday_Close_Hours_AGN__c = (String)m.get('Wednesday_Close_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Wednesday_Close_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Wednesday_Close_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Thursday_Open_Hours_AGN__c = (String)m.get('Thursday_Open_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Thursday_Open_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Thursday_Open_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Thursday_Close_Hours_AGN__c = (String)m.get('Thursday_Close_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Thursday_Close_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Thursday_Close_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Friday_Open_Hours_AGN__c = (String)m.get('Friday_Open_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Friday_Open_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Friday_Open_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Friday_Close_Hours_AGN__c = (String)m.get('Friday_Close_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Friday_Close_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Friday_Close_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Saturday_Open_Hours_AGN__c = (String)m.get('Saturday_Open_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Saturday_Open_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Saturday_Open_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Saturday_Close_Hours_AGN__c = (String)m.get('Saturday_Close_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Saturday_Close_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Saturday_Close_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Sunday_Open_Hours_AGN__c = (String)m.get('Sunday_Open_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Sunday_Open_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Sunday_Open_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            lc.Sunday_Close_Hours_AGN__c = (String)m.get('Sunday_Close_Hours_AGN__c') != null ? Time.newInstance(Integer.valueof(((String)m.get('Sunday_Close_Hours_AGN__c')).split(':')[0].trim()),Integer.valueof(((String)m.get('Sunday_Close_Hours_AGN__c')).split(':')[1].trim()),0,0) : null;
            
            update lc;
        }
        catch(Exception ex)
        {
            
        }
        return true;
        
    }
    @AuraEnabled
    public static String imagefetch(ID loclstId)       
    {
       
        Locator_Listing_AGN__c ac=[select id,Clinic_Image_AGN__c from Locator_Listing_AGN__c where id=:loclstId];
        return ac.Clinic_Image_AGN__c;
    }
    @AuraEnabled
    public static String locatorimage(Id parentId,String fileName1,String contentType,String base64Data)
  {
      
       base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
     
    String fetchimage;
    //String attachmentBody = EncodingUtil.base64Encode(attach[0].Body);
    String attachmentBody = EncodingUtil.base64Encode(EncodingUtil.base64Decode(base64Data));
    String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
   
    List<AWS_Login_AGN__c> al= AWS_Login_AGN__c.getall().values();
    
    String key = al[0].key_AGN__c; //AWS key
    String secret = al[0].secret_AGN__c; //AWS Secret key
    String bucketname = al[0].bucket_AGN__c; //AWS bucket name
    String host = al[0].host_AGN__c;
    String method = 'PUT';
    //String filename = attach[0].ParentId + '-' + attach[0].Name;
    
    String filename = parentId + '-' + fileName1;
    
         
    HttpRequest req = new HttpRequest();
    
    req.setMethod(method);
    req.setEndpoint('https://' + bucketname + '.' + host + '/' + filename);
    req.setHeader('Host', bucketname + '.' + host);
    req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
    req.setHeader('Content-Encoding', 'UTF-8');
   // req.setHeader('Content-type', attach[0].ContentType);
   req.setHeader('Content-type', contentType);
    req.setHeader('Connection', 'keep-alive');
    req.setHeader('Date', formattedDateString);
    req.setHeader('ACL', 'public-read-write');
   // req.setBodyAsBlob(attach[0].Body);
   req.setBodyAsBlob(EncodingUtil.base64Decode(base64Data));
    //String stringToSign = 'PUT\n\n' + attach[0].ContentType + '\n' + formattedDateString + '\n' + '/' + bucketname + '/' + filename;
      
      String stringToSign = 'PUT\n\n' + contentType + '\n' + formattedDateString + '\n' + '/' + bucketname + '/' + filename;
   
    Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
    String signedKey  = EncodingUtil.base64Encode(mac);
   
    String authHeader = 'AWS' + ' ' + key + ':' + signedKey ;
   
         
    req.setHeader('Authorization',authHeader);
   
    Http http = new Http();
    HTTPResponse res = http.send(req);
   

    if(filename!=null && res.getStatusCode()==200)
    {
        Locator_Listing_AGN__c ac=[select id,Clinic_Image_AGN__c from Locator_Listing_AGN__c where id=:parentId];
   
   ac.Clinic_Image_AGN__c='https://s3-eu-west-1.amazonaws.com/allergan-icl/'+filename;
        //ac.Clinic_Image_AGN__c='https://' + host +'/' + bucketname +'/' + filename;
        ac.Picture_Available_AGN__c=true;
         update ac;
        fetchimage = ac.Clinic_Image_AGN__c;
            
         }
      if(filename==null)
      {
          fetchimage=null;
                }
     
            return fetchimage;
  }
    @AuraEnabled
    public static boolean showhidebackbutton(Id loclstId)
    {
         Locator_Listing_AGN__c fetchlocator=[select Clinic_Admin_AGN__c from Locator_Listing_AGN__c where id=:loclstId];
        List<Locator_Listing_AGN__c> findlocator=[select ID from Locator_Listing_AGN__c where Clinic_Admin_AGN__c=:fetchlocator.Clinic_Admin_AGN__c and Active_AGN__c=true];
        if(findlocator.size()>1)
             return true;	
		else
            return false;
	}
        
}