/*
*------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Arijit Mandal & Avijit Pal
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        1.0
* @created        
* @modified      15-Nov-2019
* @Class Name	 AGN_GDPR_Case_Login_Controller     
* ----------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019    		
* Login Controller for AGN_GDPR_Case_Login VF PAGE for Community Login.
*-------------------------------------------------------------------------------------------------------------------------+
*/


public class AGN_GDPR_Case_Login_Controller 
{   
    private String startUrl;
    public String username { get; set; }
    public String password { get; set; }
    public Integer count { get; set; }
    public String error { get; set; }
    public Boolean remember { get; set; }
    public Case supportCase { get; set; }
    public Boolean forgot { get; set; }
    public Boolean reset { get; set; }
   
    public AGN_GDPR_Case_Login_Controller()
    {
        startUrl = ApexPages.currentPage().getParameters().get('startURL');
        String redirect = ApexPages.currentPage().getParameters().get('redirect');
        system.debug('START URL --> ' + startUrl + ' REDIRECT URL --> ' + redirect);
        
        if (redirect != null)
        {
            startUrl = '/apex/CommunitiesLogin?redirect='+redirect;
            if (ApexPages.currentPage().getParameters().containsKey('new'))
                startUrl += '&new';
        }
        else 
        {
            //Redirecting to Home Page of the Comunity Setting the URL Here
            startUrl = '/AGN_GDPR_Case_Home';
        }
        //Count for Number of attempts 
        count = 0;
        forgot = false;
        Cookie savedUsername = ApexPages.currentPage().getCookies().get('dsrm-username');
        if (savedUsername != null)
        {
            username = savedUsername.getValue();
            remember = true;
        }
    }
    
    public void initCase()
    {
        forgot = false;
        supportCase = new Case(SuppliedEmail = username,Type = 'dsrm',Sub_Type_AGN__c = 'Login Issue',Origin = 'Email',Priority = 'Low',Subject = 'dsrm Log-in Attempt Failed'); 
        error = System.Label.AGN_DSRM_Community_MaxLogin;
    }
    
    public void forgotPassword() 
    {
        count = 0;
        forgot = true;
        reset = false;
    }
    
    public PageReference login() 
    {
        error = null;
        if (String.isBlank(username) || String.isBlank(password)) 
        {
            error = System.Label.AGN_DSRM_Community_PassUsername;
            return null;
        }
        
        count++;
        if (count > 3) return null;
        
        // fetch .dsrm in the username as an suffix from the custom label
        String suffix= System.Label.AGN_DSRM_Community_Suffix;
        
        String uName = username+'.'+suffix;
        
        System.debug('Modified UserName --> '+uName);
        
        list<User> users = [SELECT Id,ContactId,Access_Till_AGN_GDPR__c,LastLoginDate FROM User WHERE IsActive = true AND Username = :uName];
        system.debug('User Details --> ' + users);
        PageReference result;
        if (users.isEmpty()) 
        {
            error = System.Label.AGN_DSRM_Community_InvalidUsername;
        } 
        else 
        {
            system.debug('UserName --> ' + username + ' : ' + users[0].LastLoginDate + ' : ' + startUrl);
            result = Site.login(uName,password,startUrl);
            
            //Section for Deactivation Date
            //Fetching values from Custom Setting AGN_GDPR_LoginExtension__c
            List<AGN_GDPR_LoginExtension__c> CSDays = AGN_GDPR_LoginExtension__c.getAll().values();
            Integer DaysToExtend = Integer.valueOf(CSDays[0].Days_to_Extend_AGN_GDPR__c);
            
            User ULogin = new User();
            ULogin.Id = users[0].id;
            if (users[0].Access_Till_AGN_GDPR__c == null)
            {
                try
                {
                    ULogin.Access_Till_AGN_GDPR__c = users[0].LastLoginDate.date() + DaysToExtend;
                    update ULogin;
                }
                catch(DmlException e) 
                {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
      
            }
            system.debug('Access_Till_AGN_GDPR__c > ' + ULogin.Access_Till_AGN_GDPR__c);
        
            List<Case> CaseList= [Select Id,Status from Case where ContactId =:users[0].ContactId AND Currently_Accessible_AGN__c = true];
            
            //Updating the Case Status
             if(CaseList[0].Status!='Closed')
            {
                system.debug('Case ID --> ' + CaseList[0].Id);
                try
                {
                    Case objCase = new Case();
                    objCase.Id = CaseList[0].Id;
                    objCase.Status = 'Closed';
                    update objCase;
                    System.debug('Case Closed');
              	}
                 catch(DmlException e) 
                {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }                
            }
                
            if (result == null)
                error = System.Label.AGN_DSRM_Community_LoginFailed;
            else 
            {
                if (remember) ApexPages.currentPage().setCookies(new list<Cookie>{new Cookie('dsrm-username',uName,null,60*60*24*90,false)});
                else ApexPages.currentPage().setCookies(new list<Cookie>{new Cookie('dsrm-username',null,null,0,false)});
            }
        }
        
        if (result == null && count >= 3) 
            initCase();
        
        return result;
  	}
    
    public void submitUsername()
    {
        String suffix= System.Label.AGN_DSRM_Community_Suffix;
        String uName = username+'.'+suffix;
        
        error = null;
        if (String.isBlank(uName))
        {
            error = System.Label.AGN_DSRM_Community_UserNameReq;
            return;
        }
        
        count++;
        if (count > 3) return;
        
        list<User> users = [SELECT Id FROM User WHERE IsActive = true AND Username = :uName];
        PageReference result;
        if (users.isEmpty()) 
        {
            error = System.Label.AGN_DSRM_Community_InvalidUsername;
            if (count >= 3) initCase();
        }
        else
        {
            Site.forgotPassword(uName);
            reset = true;
        }
    }
    
    public void submitCase()
    {
        try 
        {
            if (String.isBlank(supportCase.SuppliedEmail) || String.isBlank(supportCase.SuppliedName) || String.isBlank(supportCase.SuppliedCompany) || String.isBlank(supportCase.SuppliedPhone)) 
            {
                error = System.Label.AGN_DSRM_Community_AllFieldsReq;
                return;
            }
            if (supportCase.SuppliedEmail.indexOf('@') <= 0 || supportCase.SuppliedEmail.lastIndexOf('.') < supportCase.SuppliedEmail.indexOf('@')+1)
            {
                error = System.Label.AGN_DSRM_Community_InvalidEmail;
                return;
            }
            
            try 
            {
                list<Contact> cons = [SELECT Name FROM Contact WHERE Email = :supportCase.SuppliedEmail ORDER BY CreatedDate DESC];
                if (cons.size() == 1)
                {
                    supportCase.ContactId = cons[0].Id;
                }
                else if (cons.size() > 1)
                {
                    for (Contact con : cons) 
                    {
                        if (con.Name == supportCase.SuppliedName)
                        {
                            supportCase.ContactId = con.Id;
                            break;
                        }
                    }
                }
            } 
            catch (Exception e) {}
            
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.assignmentRuleHeader.useDefaultRule = true;
            
            Database.insert(supportCase,dmlo);
        }
        catch (Exception e)
        {
            error = e.getMessage();
        }
    }
}