/*
01/23/15    SB @ IC    00110773
*/
public class AGN_CoolNetLoginController {
    
    private String startUrl;
    private String countryCode;//FetchCountryCode to Show Popup 
    public String username { get; set; }
    public String password { get; set; }
    public Integer count { get; set; }
    public String error { get; set; }
    public Boolean remember { get; set; }
    public Case supportCase { get; set; }
    public Boolean forgot { get; set; }
    public Boolean reset { get; set; }
    public Boolean displaypopup { get; set; }
    
    public AGN_CoolNetLoginController() {
        System.debug('coolNetLoggedInUser## '+UserInfo.getUserId());
        startUrl = ApexPages.currentPage().getParameters().get('startURL');
        String redirect = ApexPages.currentPage().getParameters().get('redirect');
        //FetchCountryCode to Show Popup
        countryCode = ApexPages.currentPage().getParameters().get('countryCode');
        system.debug('Arijit00: ' + startUrl + ' : ' + redirect);
        displaypopup = false;
        if (redirect != null) {
            startUrl = '/apex/CommunitiesLogin?redirect='+redirect;
            if (ApexPages.currentPage().getParameters().containsKey('new'))
                startUrl += '&new';
        }
        else //Newly Added
        {
            startUrl = '/apex/AGN_CoolNetHomePage';
             if(String.isNotBlank(countryCode)){
               startUrl += '?countryCode=' + countryCode;
            }
        }
        count = 0;
        forgot = false;
        Cookie savedUsername = ApexPages.currentPage().getCookies().get('coolnet-username');
        if (savedUsername != null) {
            username = savedUsername.getValue();
            remember = true;
        }
        
    }
    
    public void initCase() {
        forgot = false;
        supportCase = new Case(SuppliedEmail = username,Type = 'CoolNet',Sub_Type_AGN__c = 'Login Issue',Origin = 'Email',Priority = 'Low',Subject = 'CoolNet Log-in Attempt Failed');
        
        error = 'Maximum login attempts reached. Please enter the following information and submit to open a case with CoolSculpting Customer Support.';
    }
    
    public void forgotPassword() {
        count = 0;
        forgot = true;
        reset = false;
    }
    
    public PageReference login() 
    {
        System.debug('loginMethodEnters##');
        System.debug('loginMethodEnters##  '+username + ' ' + password);
        error = null;
        if (String.isBlank(username) || String.isBlank(password)) 
        {
            error = 'You must enter both a username and password.';
            return null;
        }
        
        count++;
        if (count > 3) return null;
        
        list<User> users = [SELECT Id,Country_Code__c FROM User WHERE IsActive = true AND Username = :username];
        system.debug('users## ' + users);
        PageReference result;
        if (users.isEmpty()) 
        {
            System.debug('userEmpty##');
            error = 'The username you entered is invalid. Your username should be the email address you registered with.';
        } 
        else 
        {
            system.debug('result2##: ' + username + ' : ' + password + ' : ' + startUrl);
            result = Site.login(username,password,startUrl);
            
            system.debug('result3##: ' + result);
            if (result == null){
               System.debug('loginFailed## ');
               error = 'Your login attempt has failed. The password may be incorrect, or your location or login time may be restricted. Please contact the administrator at your company for help.';
            }   
            else 
            {
               System.debug('loginPassed## ');
               if (remember) ApexPages.currentPage().setCookies(new list<Cookie>{new Cookie('coolnet-username',username,null,60*60*24*90,false)});
               else ApexPages.currentPage().setCookies(new list<Cookie>{new Cookie('coolnet-username',null,null,0,false)});
            }
        }
        if (result == null && count >= 3) 
            initCase();
        
        return result;
        
    }
    
    public void submitUsername() {
        error = null;
        if (String.isBlank(username)) {
            error = 'You must enter your username.';
            return;
        }
        
        count++;
        if (count > 3) return;
        
        list<User> users = [SELECT Id,Country_Code__c  FROM User WHERE IsActive = true AND Username = :username];
        PageReference result;
        if (users.isEmpty()) {
            error = 'The username you entered is invalid. Your username should be the email address you registered with.';
            if (count >= 3) initCase();
        } else {
            Site.forgotPassword(username);
            reset = true;
        }
    }
    
    public void submitCase() {
        try {
            if (String.isBlank(supportCase.SuppliedEmail) || String.isBlank(supportCase.SuppliedName) || String.isBlank(supportCase.SuppliedCompany) || String.isBlank(supportCase.SuppliedPhone)) {
                error = 'All fields are required.';
                return;
            }
            if (supportCase.SuppliedEmail.indexOf('@') <= 0 || supportCase.SuppliedEmail.lastIndexOf('.') < supportCase.SuppliedEmail.indexOf('@')+1) {
                error = 'The email address you entered is not valid.';
                return;
            }
            
            try {
                list<Contact> cons = [SELECT Name FROM Contact WHERE Email = :supportCase.SuppliedEmail ORDER BY CreatedDate DESC];
                if (cons.size() == 1) {
                    supportCase.ContactId = cons[0].Id;
                } else if (cons.size() > 1) {
                    for (Contact con : cons) {
                        if (con.Name == supportCase.SuppliedName) {
                            supportCase.ContactId = con.Id;
                            break;
                        }
                    }
                }
            } catch (Exception e) {}
            
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.assignmentRuleHeader.useDefaultRule = true;
            
            Database.insert(supportCase,dmlo);
        } catch (Exception e) {
            error = e.getMessage();
        }
    }
}