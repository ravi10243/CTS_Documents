public without sharing class AGN_AMI_Workshop_Controller 
{
    User user;
    // DQ - HCP Harmonization Start
    Account accountRecord;
    // DQ - HCP Harmonization End
    String userCountryName;
    public String userLanguage {get; set;}
    public List<SelectOption> productList {get; set;}
    public List<SelectOption> difficultyList {get; set;}
    public String selectedProduct {get; set;}
    public String selectedDifficulty {get; set;}
    public List<workshopWrapper> workshopList {get; set;}
    public workshopWrapper upcomingWorkshop {get; set;}
    public AMI_Web_Visibility_Settings_AGN__c AWV {get; set;}
    public String registrationURL {get; set;}
    public Integer workshopCount {get; set;}
    
    public List<workshopWrapper> wrksrch;
    public String wrkSearchDateStart {get; set;} //Search date start
    public String startDate;
    public String endDate;
    public String wrkSearchDateEnd {get; set;} //Search date end
    public String searchString {get; set;} //Search String
    public List<workshopWrapper> fullWorkshopList {get; set;}
    public String deregId {get; set;}
    public AGN_AMI_Workshop_Controller()
    {
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        //userDetails  = AGN_AMI_Utility_class.getUserDeails();   
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        // DQ - HCP Harmonization Start
        accountRecord = userDetails.accountRecord;
        // DQ - HCP Harmonization End
        AWV = AMI_Web_Visibility_Settings_AGN__c.getValues(userCountryName);
        productList = getProducts();
        difficultyList = getDifficulties();
        workshopList = getWorkshops();
        
        wrksrch=new List<workshopWrapper>();
        fullWorkshopList= new List<workshopWrapper>();
        if (workshopList.size() > 0){
            fullWorkshopList.addAll(workshopList);
        }
        
    }
    public list<SelectOption> getProducts()
    {
        Map<String,List<Schema.PicklistEntry>> productMap = AGN_AMI_Utility_class.getDependentPicklistValues(AMI_Workshop_AGN__c.Product_AGN__c);
        system.debug(productMap);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-',System.Label.AGN_AMI_Workshop_Option_All));
        List<Schema.PicklistEntry> ple = productMap.get(userCountryName);
        if(ple != null)
        {
            for( Schema.PicklistEntry f : ple)
            {
                system.debug(JSON.serialize(f));
                options.add(new SelectOption(f.getValue(),f.getLabel()));
            }
        }
        selectedProduct = options[0].getValue(); 
        return options;
    }
    public List<SelectOption> getDifficulties()
    {
        Map<String,List<Schema.PicklistEntry>> productMap = AGN_AMI_Utility_class.getDependentPicklistValues(AMI_Workshop_AGN__c.Difficultly_AGN__c);
        system.debug(productMap);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-',System.Label.AGN_AMI_Workshop_Option_All));
        List<Schema.PicklistEntry> ple = productMap.get(userCountryName);
        if( ple != null)
        {
            for( Schema.PicklistEntry f : ple)
            {
                //options.add(new SelectOption(f.getLabel(), f.getValue()));
                options.add(new SelectOption(f.getValue(),f.getLabel()));
            }     
        }
        //selectedDifficulty = options[0].getValue();
        selectedDifficulty = options[0].getValue();
        System.debug(selectedDifficulty);
        return options;
    }
    public void updateWorkshops()
    {
        workshopList = getWorkshops();
        if (workshopList.size() > 0){
            fullWorkshopList.addAll(workshopList);
        }
    }
    public List<workshopWrapper> getWorkshops()
    {
        List<workshopWrapper> listWorkshopDisplay = new List<workshopWrapper>();
        
        Datetime startDate;
        Datetime endDate;
        if(!String.isBlank(wrkSearchDateStart))
        {
            List<String> startList = wrkSearchDateStart.split('/');
            startDate = datetime.newInstance(Integer.valueOf(startList[2]),Integer.valueOf(startList[1]),Integer.valueOf(startList[0]));
        }
        if(!String.isBlank(wrkSearchDateEnd))
        {
            List<String> endList = wrkSearchDateEnd.split('/');
            endDate = datetime.newInstance(Integer.valueOf(endList[2]),Integer.valueOf(endList[1]),Integer.valueOf(endList[0]));
        }  
        String query = 'Select id, Cost_AGN__c, Date_AGN__c, Difficultly_AGN__c, Name_AGN__c, Product_AGN__c, '
            + 'Location_AGN__c, External_Registration_AGN__c, External_Registration_Link_AGN__c, Slots_AGN__c, '
            + 'Registration_Close_Date_AGN__c, Open_in_New_Tab_AGN__c, Workshop_Type_AMI_AGN__c '
            + 'from AMI_Workshop_AGN__c '
            + 'where Country_AGN__r.Name = :userCountryName '
            + 'and Past_Workshop_AGN__c = false ' 
            + 'and Active_AGN__c = true ';
        if(selectedDifficulty != '-')
            query = query + 'and Difficultly_AGN__c = :selectedDifficulty ';
        if(selectedProduct != '-')
            query = query + 'and Product_AGN__c = :selectedProduct ';
        if(searchString != null && searchString != '')
            query = query + 'and Name_AGN__c like \'%'+searchString+'%\' ';
        if(wrkSearchDateStart != null && wrkSearchDateStart != '')
            query = query + 'and Date_AGN__c >= :startDate ';
        if(wrkSearchDateEnd != null && wrkSearchDateEnd != '')
            query = query + 'and Date_AGN__c <= :endDate ';
        query = query + 'order by Date_AGN__c asc';
        List<AMI_Workshop_AGN__c> listWorkshop = Database.query(query);
        Set<id> workshopIds = new Set<id>();
        System.debug(selectedDifficulty + '_' + selectedProduct);
        for(AMI_Workshop_AGN__c workshop : listWorkshop)
        {
            workshopIds.add(workshop.Id);
        }
        System.debug('workshopIds@@@@@' + workshopIds);
        
        List<AMI_Workshop_Attendee_AGN__c> listWorkShopAttendees = [Select Account_AGN__c, AMI_Workshop_AGN__c, Status_AGN__c
                                                                    from AMI_Workshop_Attendee_AGN__c
                                                                    where AMI_Workshop_AGN__c in :workshopIds];
        List<AMI_Workshop_Faculty_AGN__c> listWorkShopFaculties = [Select AMI_Faculty_AGN__r.Name_AGN__c, AMI_Workshop_AGN__c
                                                                   from AMI_Workshop_Faculty_AGN__c
                                                                   where AMI_Workshop_AGN__c in :workshopIds
                                                                   and Is_Primary_AGN__c = true
                                                                   order by LastModifiedDate Desc];
        system.debug('listWorkShopAttendees@@@@' + listWorkShopAttendees);
        //Map of Workshop Ids and (Map of Status and (List of Attendee.AccountIds))
        Map<String,Map<String,Set<String>>> attendeeMap = new Map<String,Map<String,Set<String>>>();
        Set<String> attendeeAccountSet = new  Set<String>();
        for(AMI_Workshop_Attendee_AGN__c attendee : listWorkShopAttendees)
        {
            Map<String,Set<String>> workshopMap;
            Set<String> accountSet;
            System.debug(attendeeMap);
            System.debug(attendee + '---' + attendee.AMI_Workshop_AGN__c);
            if(attendeeMap.containsKey(attendee.AMI_Workshop_AGN__c))
            {
                workshopMap = attendeeMap.get(attendee.AMI_Workshop_AGN__c);
                if(workshopMap.containsKey(attendee.Status_AGN__c))
                {
                    accountSet = workshopMap.get(attendee.Status_AGN__c);
                }
                else
                {
                    accountSet = new Set<String>(); 
                }
            }  
            else
            {
                workshopMap = new Map<String,Set<String>>();
                accountSet = new Set<String>();
            } 
            System.debug(accountSet);
            accountSet.add(attendee.Account_AGN__c);
            attendeeAccountSet.add(attendee.Account_AGN__c);
            System.debug(accountSet);
            workshopMap.put(attendee.Status_AGN__c,accountSet);
            attendeeMap.put(attendee.AMI_Workshop_AGN__c,workshopMap);
            System.debug('attendeeMap@@@@' + attendeeMap);
        }
        System.debug(attendeeMap);
        
        Map<String,String> facultyNameMap = new Map<String,String>();
        
        for(AMI_Workshop_Faculty_AGN__c faculties : listWorkShopFaculties)
        {
            if(facultyNameMap.containsKey(faculties.AMI_Workshop_AGN__c))
                continue;
            else
                facultyNameMap.put(faculties.AMI_Workshop_AGN__c,faculties.AMI_Faculty_AGN__r.Name_AGN__c);
            
        }
        for(AMI_Workshop_AGN__c workshop : listWorkshop)
        {
            String wrkstatus;
            String facultyName;
            if(facultyNameMap.containsKey(workshop.Id))
                facultyName = facultyNameMap.get(workshop.Id);
            else
                facultyName = '';
            system.debug('attendeeAccountSet@@@' + attendeeAccountSet);
            system.debug('accid@@@' + accountRecord.Id);
                         
            if(workshop.Workshop_Type_AMI_AGN__c == AGN_AMI_Static_Labels.workshopTypePublic)
                {   
                    system.debug('entering if@@@');
                    system.debug('attendeeMap@@@'+ attendeeMap);
                    wrkstatus=SetStatus(attendeeMap,accountRecord,workshop);
                    listWorkshopDisplay.add(new workshopWrapper(workshop,wrkstatus,facultyName));
                }
            else if(workshop.Workshop_Type_AMI_AGN__c == AGN_AMI_Static_Labels.workshopTypePrivate)
            {
                if(attendeeMap.containsKey(workshop.Id) &&  attendeeAccountSet.contains(accountRecord.Id))
                {
                     system.debug('entering elseif@@@');
                   wrkstatus=SetStatus(attendeeMap,accountRecord,workshop);
                    listWorkshopDisplay.add(new workshopWrapper(workshop,wrkstatus,facultyName)); 
                }
            }
            }
              
        
        if(!listWorkshopDisplay.isEmpty())
            upcomingWorkshop = listWorkshopDisplay[0];
        workshopCount = listWorkshopDisplay.size();
        return listWorkshopDisplay;
    }
    public void updateRegistrationFrame()
    {
        system.debug(registrationURL);
    }
    public class workshopWrapper
    {
        public AMI_Workshop_AGN__c workshop {get; set;}
        public String workshopDate {get; set;}
        public String status {get; set;}
        public String facultyName {get; set;}
        
        public workshopWrapper(AMI_Workshop_AGN__c workshop, String status, string facultyName)
        {
            this.workshop = workshop;
            this.workshopDate = workshop.Date_AGN__c.format('dd/MM/yyyy');
            this.Status = status;
            this.facultyName = facultyName;
        }
    }
    public void deregister()
    {
        AMI_Workshop_Attendee_AGN__c delRecord = [Select Id, Status_AGN__c 
                                                  from AMI_Workshop_Attendee_AGN__c 
                                                  where AMI_Workshop_AGN__c =: deregId
                                                  and Account_AGN__c =: accountRecord.Id
                                                  Limit 1
                                                 ];
        delRecord.Status_AGN__c = 'Cancelled';
        try
        {
            update delRecord;
            updateWorkshops();
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
    public string SetStatus(Map<String,Map<String,Set<String>>> attendeeMap,Account accountRecord,AMI_Workshop_AGN__c workshop)
    {
        string status='';
        if(attendeeMap.containsKey(workshop.Id))
        {              
            if(attendeeMap.get(workshop.Id).containsKey('Approved') && 
               attendeeMap.get(workshop.Id).get('Approved').contains(accountRecord.Id))
                status = 'Registered';
            else if(attendeeMap.get(workshop.Id).containsKey('Rejected') && 
                    attendeeMap.get(workshop.Id).get('Rejected').contains(accountRecord.Id))
                status = 'Cancelled';
            else if(workshop.Slots_AGN__c != null && attendeeMap.containsKey(workshop.Id) 
                    && attendeeMap.get(workshop.Id).containsKey('Approved') 
                    && workshop.Slots_AGN__c <= attendeeMap.get(workshop.Id).get('Approved').size())
                status = 'Full';
            else if(workshop.Registration_Close_Date_AGN__c != null && workshop.Registration_Close_Date_AGN__c < system.today())
            {
                status = 'Closed';
            }
            else
                status = 'Register';
        }    
        else if(workshop.Registration_Close_Date_AGN__c != null && workshop.Registration_Close_Date_AGN__c < system.today())
        {
            system.debug(workshop.Registration_Close_Date_AGN__c + '++' + system.today());
            status = 'Closed';
        }
        else
        {
            status = 'Register';
        }
        return status;
    }
}