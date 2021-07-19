public class AGN_AMI_UserLoginController {
public class UserLoginControllerWrapper{
        public string LoginTimeWrap{get;set;}
        public String SourceIpWrap{get;set;}
        public String LoginTypeWrap{get;set;}
        public String StatusWrap{get;set;}
        public String ApplicationWrap{get;set;}
        public String LoginUrlWrap{get;set;}                                       
        public String LoginGeoCountryWrap{get;set;}
        public String NetworkIdWrap{get;set;}
        
        public String Browser{get;set;}
        public String Platform{get;set;}     
        public String TlsProtocol{get;set;}
        public String CipherSuite{get;set;}
        public String City{get;set;}
        public String Subdivision{get;set;}     
        public Decimal Latitude{get;set;}
        public Decimal Longitude{get;set;}
        public String CountryIso{get;set;}   
        public String PostalCode{get;set;}
        public LoginHistory lh{get;set;}
    }
    
    public List<LoginHistory> loginHistoryList{get;set;}
    private User u;
    public AGN_AMI_UserLoginController(ApexPages.StandardController sc){
        u = (User) sc.getRecord();
        
        String downloadExcel = ApexPages.currentPage().getParameters().get('downloadExcel');
        if(String.isBlank(downloadExcel)){
            loginHistoryList = [select LoginTime,SourceIp,LoginType,Status,Application,LoginUrl,LoginGeoId,LoginGeo.country,NetworkId FROM LoginHistory where UserId=: u.Id   order by LoginTime desc limit 10];
        }
        else{
            loginHistoryList = [select LoginTime,SourceIp,LoginType,Status,Application,LoginUrl,LoginGeoId,LoginGeo.country,NetworkId FROM LoginHistory where UserId=: u.Id and LoginTime >= LAST_N_MONTHS:6  order by LoginTime desc];
        }
    }
    
    public List<UserLoginControllerWrapper> getLoginDetails(){
        
        String downloadExcel = ApexPages.currentPage().getParameters().get('downloadExcel');
        if(String.isBlank(downloadExcel)){
            loginHistoryList = [select LoginTime,SourceIp,LoginType,Status,Application,LoginUrl,LoginGeoId,LoginGeo.country,NetworkId FROM LoginHistory where UserId=: u.Id   order by LoginTime desc limit 10];
        }
        else{
            loginHistoryList = [select LoginGeo.PostalCode,LoginGeo.City,LoginGeo.Subdivision,LoginGeo.Latitude,LoginGeo.Longitude,LoginGeo.CountryIso,Browser,Platform,TlsProtocol,CipherSuite,LoginTime,SourceIp,LoginType,Status,Application,LoginUrl,LoginGeoId,LoginGeo.country,NetworkId FROM LoginHistory where UserId=: u.Id and LoginTime >= LAST_N_MONTHS:6  order by LoginTime desc];
        }
        set<id> networkIdset = new set<id>();
        for(LoginHistory lh : loginHistoryList){
            networkIdset.add(lh.NetworkId);
        }
        
        Map<id,Network> networkMap = new Map<id,Network>([select id,name from network where id in : networkIdset]);
        
        List<UserLoginControllerWrapper> lhwList = new List<UserLoginControllerWrapper>();
        for(LoginHistory lh : loginHistoryList){
            UserLoginControllerWrapper lhw = new UserLoginControllerWrapper();
            
            String strConvertedDate = lh.LoginTime.format('dd/MM/yyyy HH:mm:ss');
            lhw.LoginTimeWrap = strConvertedDate;
            lhw.SourceIpWrap = lh.SourceIp;
            lhw.LoginTypeWrap = lh.LoginType;
            lhw.StatusWrap = lh.Status;
            lhw.ApplicationWrap = lh.Application;
            lhw.LoginUrlWrap = lh.LoginUrl;
            lhw.LoginGeoCountryWrap = lh.LoginGeo.country;
            lhw.NetworkIdWrap = networkMap.get(lh.NetworkId).Name;
            if(String.isNotBlank(downloadExcel)){
                lhw.Browser = lh.Browser;
                lhw.Platform= lh.Platform;
                lhw.TlsProtocol= lh.TlsProtocol;
                lhw.CipherSuite=lh.CipherSuite; 
                lhw.City= lh.LoginGeo.City;
                lhw.Subdivision= lh.LoginGeo.Subdivision;
                lhw.Latitude= lh.LoginGeo.Latitude;
                lhw.Longitude= lh.LoginGeo.Longitude;
                lhw.CountryIso= lh.LoginGeo.CountryIso;
                lhw.PostalCode= lh.LoginGeo.PostalCode;
            }
            lhw.lh = lh;
            lhwList.add(lhw);
        }
        return lhwList;
        
    }

}