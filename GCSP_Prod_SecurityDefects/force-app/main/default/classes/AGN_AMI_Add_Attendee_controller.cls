/*
This code is written to add multiple attendees for a meeting.
Based on education journey selection from drop down corresponding attendee list will be visible. From this data table multiple users
can be selected for this meeting. Kaushik-12.12.2018

The class has been modified to add pagination to result list and allow search by email address - Ayush 23-03-2019
Implementation of CR 2: Admin add non-AMI HCP to Meeting Attendees: Veeva SFMC Integration Wave 4 Date: 10/19/2020
Implementation of CR 7b: Delink advanced serach option for admin add attendee with Veeve_Integration_Enabled_AGN__c
*/
public without sharing class AGN_AMI_Add_Attendee_controller{
    
    public  Medical_Event_vod__c  currentEventsRecord {get;set;}
    private String journey;
    private list<Account> acc;
    //public list<Account> selectedlist;
    
    public string educationjourney{get;set;}
    public string FilterCountry{get;set;}//Added for Add Attendee CR 06.15.2020
    public list<wrapperlist> myoriginal {get; set;}    
    public boolean disablePrevious{get;set;} 
    public boolean disableNext{get;set;} 
    public Integer pageNumber {get; set;}
    public Integer totalPages {get; set;}
    public String inputEmail {get; set;}
    public String inputSpec {get; set;}
	public String inputAttendee {get; set;} //CR 2
    public String inputEvent {get; set;}
    public String inputSegment {get; set;}
    public String actionSource {get; set;}
    public String actionSourceOld {get; set;}
    public Boolean selectAll {get; set;}
	public Boolean filterFlag=false; //CR 2
    Set<String> filteredAccountList {get; set;}
    //PMO#3017 to get the city from the controller
    public String inputCity {get; set;}
    public Integer tableStart {get; set;}
    public Integer tableSize {get; set;}
    public Boolean getMAAccounts;
    public boolean tooManyRecords {get; set;}
    public Integer totalRecords {get; set;}
    Set<String> CountryList {get;set;}
	//Set<String> NewCountryList {get;set;}//CR 2
    Set<String> TempCountryList{get;set;}
	//String NewCountryCode;//CR 2
    public boolean isMena {get;set;}
    public boolean showAdvanceSearch {get; set;}
    public AGN_AMI_Add_Attendee_controller(ApexPages.StandardController controller) {
        tableSize = 5; 
        tableStart = 0;
        
        String eventId = ApexPages.currentPage().getParameters().get('Id');
        currentEventsRecord = [select id,name,Meeting_Type_Picklist_AGN__c,AGN_AMI_Business_Unit__c, Country_Code__c from Medical_Event_vod__c where id = :eventId];
        getMAAccounts = (currentEventsRecord.AGN_AMI_Business_Unit__c == 'Medical Aesthetics');
		/******  of CR 7b start****/
        //showAdvanceSearch = AMI_User_Settings_AGN__c.getValues(currentEventsRecord.Country_Code__c).Veeve_Integration_Enabled_AGN__c;
		showAdvanceSearch=true;
		/******  of CR 7b end****/
        myoriginal = new list<wrapperlist>();
        disablePrevious = true;
        disableNext = true;
		//NewCountryCode=currentEventsRecord.Country_Code__c;//CR 2
        //selectedlist = new list<account>();
         /*AMI MENA changes- Start*/ 
        CountryList=new Set<String>() ;
		//NewCountryList=new Set<String>{'AU','ES','BR','GB','RU','TR','IT','CA','FR','DE'} ;//CR 2
        isMena=false;
        List<AGN_AMI_MENA_Mapping__mdt> menaCountryListMdt = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c from 
                                      AGN_AMI_MENA_Mapping__mdt Where AGN_AMI_Parent_Country_Code__c =:currentEventsRecord.Country_Code__c ]) ;
        if(menaCountryListMdt.size() > 0){
            
            for(AGN_AMI_MENA_Mapping__mdt m:menaCountryListMdt){
                CountryList.add(m.AGN_AMI_Child_Country_Code__c);
            }
            isMena=true;
        }
        CountryList.add(currentEventsRecord.Country_Code__c);
       
        /*AMI MENA changes- End*/ 
    }
    //Changes for Add Attendee CR 06.15.2020 Start
    public List<SelectOption> getClusterCountries()
    {
		List<SelectOption> options = new List<SelectOption>();        
        
        List<AGN_AMI_MENA_Mapping__mdt> menaCountryListMdt = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c from 
                                      AGN_AMI_MENA_Mapping__mdt Where AGN_AMI_Parent_Country_Code__c =:currentEventsRecord.Country_Code__c  ]) ;
        if(menaCountryListMdt.size() > 0){           
            options.add(new SelectOption(menaCountryListMdt[0].AGN_AMI_Parent_Country_Code__c,[Select AGN_Country_Name__c From Country_vod__c 
                                                                             Where Name=:menaCountryListMdt[0].AGN_AMI_Parent_Country_Code__c].AGN_Country_Name__c));
            for(AGN_AMI_MENA_Mapping__mdt m:menaCountryListMdt){               
                options.add(new SelectOption(m.AGN_AMI_Child_Country_Code__c,[Select AGN_Country_Name__c From Country_vod__c 
                                                                             Where Name=:m.AGN_AMI_Child_Country_Code__c].AGN_Country_Name__c));
            }         
        }
        options=selectOptionSortByLabel(options);
        options.add(0,new SelectOption('--Select One--','--Select One--'));
        options.add(1,new SelectOption('None','All'));
        return options;
    }
    public static list<selectOption> selectOptionSortByLabel(list<selectOption>
                                                            selectOptionsToSort) {
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1){
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;
        
        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];
        selectOptionsToSort.remove(pivot);
        for(selectOption SO : selectOptionsToSort){
            if(SO.getLabel() <= pivotValue.getLabel()){
                lessSelectOption.add(SO);
            }else if(SO.getLabel() > pivotValue.getLabel()){
                greaterSelectOption.add(SO);   
            }
        }
        list<selectOption> sortedSelectOptions = new list<selectOption>(); 
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return SortedSelectOptions;
    }
    //Changes for Add Attendee CR 06.15.2020 END
    public List<SelectOption> getItems() {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','-–Select One--'));
        options.add(new SelectOption('0','No Level'));
        options.add(new SelectOption('1','Level 1'));
        options.add(new SelectOption('2','Level 2'));
        options.add(new SelectOption('3','Level 3'));
        options.add(new SelectOption('4','Level 4'));
        
        return options;
        
    }
    
    /* Proceed method is used to fetch list of attendees KAUSHIK 12.17.2018 */
    
    public void proceed(){       
        //change for add attendee CR 19.06.2020 start
		filterFlag=false; //CR 2
        if(FilterCountry!='None' && isMena==true)
        {
            TempCountryList=new Set<String>(CountryList);
            CountryList.clear();
            CountryList.add(FilterCountry);
        }
        //change for add attendee CR 19.06.2020 end
        tooManyRecords = false;
        set<Id> myid = new set<id>();
        list<AMI_HCP_Profile_AGN__c> mylist1;
        set<Id> attendee_history = new set<Id>(); //This is used to capture historical attendee ids
        For (Event_Attendee_Vod__c existing:[select Account_Vod__c from Event_Attendee_Vod__c where Medical_Event_vod__c =:currentEventsRecord.Id])
            attendee_history.add(existing.Account_Vod__c);
        String query = 'select id,name,phone,AGN_AMI_ENABLED__C,PersonEmail,AMI_Educational_Journey__c FROM ACCOUNT ' + 
            'WHERE AGN_AMI_ENABLED__C=true ' + 
            'and Country_code__c = \'' + currentEventsRecord.Country_Code__c + '\' ' + 
            'and id NOT IN :attendee_history' + 
            'order by name ASC';
        if(educationjourney != '0')
        {
            
            mylist1= [SELECT ID,Account_AGN__c,AMI_Education_AGN__c FROM AMI_HCP_Profile_AGN__c 
                     /*AMI MENA changes- Start*/
                      //WHERE AMI_Education_AGN__c = :educationjourney and (Account_AGN__r.Country_code__c = :currentEventsRecord.Country_Code__c 
                        //                                                  or Account_AGN__r.Country_vod__r.Name = :currentEventsRecord.Country_Code__c)];
                      WHERE AMI_Education_AGN__c = :educationjourney and (Account_AGN__r.Country_code__c in :CountryList
                                                                         or Account_AGN__r.Country_vod__r.Name in :CountryList)];
            		   /*AMI MENA changes- End*/	
        }
        else
        {
            mylist1= [SELECT ID,Account_AGN__c,AMI_Education_AGN__c FROM AMI_HCP_Profile_AGN__c 
                      /*AMI MENA changes- Start*/
                      //where (Account_AGN__r.Country_code__c = :currentEventsRecord.Country_Code__c 
                        //     or Account_AGN__r.Country_vod__r.Name = :currentEventsRecord.Country_Code__c)];
                      where (Account_AGN__r.Country_code__c in :CountryList
                            or Account_AGN__r.Country_vod__r.Name in :CountryList)];
                      /*AMI MENA changes- End*/
        }
        filter();
        
        
        
        for(AMI_HCP_Profile_AGN__c ami :mylist1){
            myid.add(ami.Account_AGN__c);
        }
        system.debug('actionSource>>>'+actionSource);
        list<account> acc2;
        //PMO#3017 added the like operator for the query string in line 111
        //PMO#3017 Updated the query with the name as the search string with name and the city of Address object
        if(actionSource == 'Email')
        {
            system.debug('comming here in loop');
            String accName = '%'+inputEmail+'%';
            List<Address_vod__c> addrs = [select account_vod__c,account_vod__r.name,account_vod__r.phone,account_vod__r.AGN_AMI_ENABLED__C,account_vod__r.PersonEmail,city_vod__c FROM Address_vod__c WHERE account_vod__r.AGN_AMI_ENABLED__C=true and (account_vod__r.PersonEmail =:inputEmail OR account_vod__r.name LIKE :accName OR (city_vod__c LIKE : accName))];
            system.debug('addrs>>>>>'+addrs);
            List <Id> accIds = new List<Id>();
            if(addrs!=null && !addrs.isEmpty() ){
                for(Address_vod__c add : addrs){
                    if(add.City_vod__c == inputEmail){
                        accIds.add(add.Account_vod__c);
                    }
                    else if(add.account_vod__r.name.contains(inputEmail)){
                        accIds.add(add.Account_vod__c);
                    }
                    else if(add.account_vod__r.PersonEmail == inputEmail){
                        accIds.add(add.Account_vod__c);
                    }
                }
                 system.debug('accIds>>>>>'+accIds);
                system.debug('attendee_history>>>>'+attendee_history);
				system.debug('AMI ATD Email  '+ getMAAccounts);
                system.debug('CountryList>>>>'+CountryList);
                    /**** CR 2 start ****/
				
					acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,Business_Unit_AGN__c,PersonEmail,AMI_Educational_Journey__c,(SELECT Id, City_vod__c FROM Address_vod__r)
							FROM ACCOUNT 
							WHERE Business_Unit_AGN__c includes ('Medical Aesthetics') and  AGN_AMI_SC_Enabled__c = false//CR 2
							//and id NOT IN :attendee_history
							and (id IN: accIds OR (name LIKE:accName OR PersonEmail = :inputEmail))
							 /*AMI MENA changes- Start*/
							//and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c)
							and (Country_code__c in :CountryList
								or Country_vod__r.Name in : CountryList)
							/*AMI MENA changes- End*/
							order by name ASC];
						system.debug('acc2>>>>>'+acc2);
					
				/**** CR 2 end ****/	
           Integer j = 0;
                while (j < acc2.size())
                {
                    if(attendee_history.contains(acc2.get(j).id) )
                    {
                        acc2.remove(j);
                    }else
                    {
                        j++;
                    }
                }               
            }
            else{
				system.debug('AMI ATD Email else '+ getMAAccounts);
                /**** CR 2 start ****/
				
                acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,Business_Unit_AGN__c,PersonEmail,AMI_Educational_Journey__c,(SELECT Id, City_vod__c FROM Address_vod__r)
                        FROM ACCOUNT 
                        WHERE Business_Unit_AGN__c includes ('Medical Aesthetics')  and  AGN_AMI_SC_Enabled__c = false//CR 2
                        and (PersonEmail = :inputEmail OR name LIKE:accName)
                       // and id NOT IN :attendee_history 
                        /*AMI MENA changes- Start*/
                        //and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c)
                        and (Country_code__c in : CountryList
                            or Country_vod__r.Name in : CountryList)
                        /*AMI MENA changes- End*/                         
                        order by name ASC];
				
                /**** CR 2 end ****/
                 Integer j = 0;
                while (j < acc2.size())
                {
                    if(attendee_history.contains(acc2.get(j).id) )
                    {
                        acc2.remove(j);
                    }else
                    {
                        j++;
                    }
                }
            }
        }
        else if(actionSource == 'Filter')
        {
		 String accName = '%'+inputEmail+'%';
            
            if(myid.size() > 0 && inputEmail == null)
			{
				system.debug('AMI ATD  Filter if  '+ getMAAccounts);
                /**** CR 2 start ****/
				   
                      acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,PersonEmail,Business_Unit_AGN__c,AMI_Educational_Journey__c
                        FROM ACCOUNT 
                        WHERE ID IN :myid 
                        and Business_Unit_AGN__c includes ('Medical Aesthetics') and  AGN_AMI_SC_Enabled__c = false //CR 2
                       // and id NOT IN :attendee_history 
                        and id in :filteredAccountList
                        and (name LIKE:accName OR PersonEmail = :inputEmail)
                        /*AMI MENA changes- Start*/
                        //and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c) 
                        and (Country_code__c in : CountryList
                            or Country_vod__r.Name in : CountryList)
                        /*AMI MENA changes- End*/   
                        order by name ASC];
                system.debug('acc2>>>>>1'+acc2);
					
                /**** CR 2 end ****/
                Integer j = 0;
                while (j < acc2.size())
                {
                    if(attendee_history.contains(acc2.get(j).id) )
                    {
                        acc2.remove(j);
                    }else
                    {
                        j++;
                    }
                }
			}
            else
			{	
                    system.debug('AMI ATD  Filter else 1 '+ getMAAccounts);	
                /**** CR 2 start ****/
					
						//system.debug('inside AMI ATD  Filter else 1 '+ Boolean.valueOf(inputAttendee));	
				        if(inputAttendee != null && inputAttendee != '')
						{
							system.debug('inside AMI ATD  Filter else 1 '+ Boolean.valueOf(inputAttendee)+filteredAccountList.size());
                            if(! filteredAccountList.isEmpty()){
								acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,PersonEmail,Business_Unit_AGN__c,AMI_Educational_Journey__c
								FROM ACCOUNT 
								WHERE Business_Unit_AGN__c includes ('Medical Aesthetics') and  AGN_AMI_SC_Enabled__c = false//CR 2
								and AGN_AMI_ENABLED__C = :Boolean.valueOf(inputAttendee)
								//and id NOT IN :attendee_history 
								and id in :filteredAccountList
								/*AMI MENA changes- Start*/
								//and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c) 
								and (Country_code__c in :CountryList
									or Country_vod__r.Name in : CountryList)
								/*AMI MENA changes- End*/   
                                        order by name ASC];
                                Integer j = 0;
                                while (j < acc2.size())
                                {
                                    if(attendee_history.contains(acc2.get(j).id) )
                                    {
                                        acc2.remove(j);
                                    }else
                                    {
                                        j++;
                                    }
                                }
                            
                            }
                            else{
                                    if(filterFlag){
										acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,PersonEmail,Business_Unit_AGN__c,AMI_Educational_Journey__c
										FROM ACCOUNT 
										WHERE Business_Unit_AGN__c includes ('Medical Aesthetics') and  AGN_AMI_SC_Enabled__c = false//CR 2
										and AGN_AMI_ENABLED__C = :Boolean.valueOf(inputAttendee)
										//and id NOT IN :attendee_history 
										and id in :filteredAccountList
										/*AMI MENA changes- Start*/
										//and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c) 
										and (Country_code__c in :CountryList
											or Country_vod__r.Name in : CountryList)
										/*AMI MENA changes- End*/   
                                                order by name ASC];
                                        Integer j = 0;
                                        while (j < acc2.size())
                                        {
                                            if(attendee_history.contains(acc2.get(j).id) )
                                            {
                                                acc2.remove(j);
                                            }else
                                            {
                                                j++;
                                            }
                                        }
                                    
                                    }
                            else{
											acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,PersonEmail,Business_Unit_AGN__c,AMI_Educational_Journey__c
										FROM ACCOUNT 
										WHERE Business_Unit_AGN__c includes ('Medical Aesthetics') and  AGN_AMI_SC_Enabled__c = false//CR 2
										and AGN_AMI_ENABLED__C = :Boolean.valueOf(inputAttendee)
										//and id NOT IN :attendee_history 
										/*AMI MENA changes- Start*/
										//and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c) 
										and (Country_code__c in :CountryList
											or Country_vod__r.Name in : CountryList)
										/*AMI MENA changes- End*/   
										order by name ASC];
                                Integer j = 0;
                                while (j < acc2.size())
                                {
                                    if(attendee_history.contains(acc2.get(j).id) )
                                    {
                                        acc2.remove(j);
                                    }else
                                    {
                                        j++;
                                    }
                                }
                            }	
                            }			
								
                            }
						else
						{
							//system.debug('inside AMI ATD  Filter else 1 else '+ Boolean.valueOf(inputAttendee));
						acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,PersonEmail,Business_Unit_AGN__c
                        FROM ACCOUNT 
                        WHERE Business_Unit_AGN__c includes ('Medical Aesthetics') and  AGN_AMI_SC_Enabled__c = false //CR 2
                       // and id NOT IN :attendee_history 
                        and id in :filteredAccountList
                        /*AMI MENA changes- Start*/
                        //and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c) 
                        and (Country_code__c in :CountryList
                            or Country_vod__r.Name in : CountryList)
                        /*AMI MENA changes- End*/   
                        order by name ASC];
                            
                            Integer j = 0;
                            while (j < acc2.size())
                            {
                                if(attendee_history.contains(acc2.get(j).id) )
                                {
                                    acc2.remove(j);
                                }else
                                {
                                    j++;
                                }
                            }
						}
					
                /**** CR 2 end ****/
			
             system.debug('acc2>>>>>2'+acc2);}
        }        
        else
        {
			system.debug('AMI ATD  Filter else else'+ getMAAccounts);	
            if(educationjourney != '0' && educationjourney !='None')//change for add attendee CR 19.06.2020 
            { 
                /**** CR 2 start ****/
               
			           acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,PersonEmail,Business_Unit_AGN__c,AMI_Educational_Journey__c
                        FROM ACCOUNT 
                        WHERE ID IN :myid 
                        and Business_Unit_AGN__c includes ('Medical Aesthetics') and  AGN_AMI_SC_Enabled__c = false //CR 2
                       // and id NOT IN :attendee_history 
                        /*AMI MENA changes- Start*/
                        //and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c) 
                        and (Country_code__c in :CountryList
                            or Country_vod__r.Name in : CountryList)
                        /*AMI MENA changes- End*/   
                        order by name ASC];
                Integer j = 0;
                while (j < acc2.size())
                {
                    if(attendee_history.contains(acc2.get(j).id) )
                    {
                        acc2.remove(j);
                    }else
                    {
                        j++;
                    }
                }
				    
                /**** CR 2 end ****/
            }
            else
            {
				system.debug('AMI ATD Filter 2 '+ getMAAccounts);	
                //change for add attendee CR 19.06.2020 start
                if(FilterCountry!='None' && isMena==true)
        		{
                    /**** CR 2 start ****/
                    
					acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,PersonEmail,Business_Unit_AGN__c,AMI_Educational_Journey__c
                            FROM ACCOUNT 
                            WHERE Business_Unit_AGN__c includes ('Medical Aesthetics') and  AGN_AMI_SC_Enabled__c = false//CR 2
                            //and id NOT IN :attendee_history 
                            /*AMI MENA changes- Start*/
                            //and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c) 
                            and (Country_code__c in :CountryList
                                or Country_vod__r.Name in : CountryList)
                            /*AMI MENA changes- End*/   
                            order by name ASC];
					
                    /**** CR 2 end ****/
                    Integer j = 0;
                    while (j < acc2.size())
                    {
                        if(attendee_history.contains(acc2.get(j).id) )
                        {
                            acc2.remove(j);
                        }else
                        {
                            j++;
                        }
                }
        		}
                else
                {
					system.debug('AMI ATD Filter else 3'+ getMAAccounts);	
					
                        /**** CR 2 start ****/
                    acc2 = [select id,name,phone,Country_code__c,AGN_AMI_ENABLED__C,PersonEmail,Business_Unit_AGN__c,AMI_Educational_Journey__c
                            FROM ACCOUNT 
                            WHERE ID NOT IN :myid 
                            and Business_Unit_AGN__c includes ('Medical Aesthetics') and  AGN_AMI_SC_Enabled__c = false //CR 2
                            //and id NOT IN :attendee_history 
                            /*AMI MENA changes- Start*/
                            //and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c) 
                            and (Country_code__c in :CountryList
                                or Country_vod__r.Name in : CountryList)
                            /*AMI MENA changes- End*/   
                            order by name ASC];
					
                    /**** CR 2 end ****/
                    Integer j = 0;
                    while (j < acc2.size())
                    {
                        if(attendee_history.contains(acc2.get(j).id) )
                        {
                            acc2.remove(j);
                        }else
                        {
                            j++;
                        }
                    }
                }
                //change for add attendee CR 19.06.2020 end
            }
        
         system.debug('acc2>>>>>3'+acc2);}
        system.debug('acc2>>>>>outside loop'+acc2);
        myoriginal.clear(); 
        
        Integer batchSize = Integer.valueOf(System.Label.AGN_AMI_Attendee_Insert_Limit);
        for(Account a11:acc2) 
        {
            if(myoriginal.size()>=batchSize)
            {
                tooManyRecords = true;
                continue;
            } 
            myoriginal.add(new wrapperlist(a11));  
        }   
        totalRecords = acc2.size(); 
        if(! myoriginal.isEmpty() )
        {
            //truncateResult();
            pageNumber = 1;
            Integer overflow = (math.mod(myoriginal.size(),tableSize)>0)? 1 : 0;
            totalPages = myoriginal.size()/tableSize + overflow;
            if(pageNumber != totalPages)
                disableNext = false;
			else
			   disableNext = true;
        }
        else
        {
            pageNumber = 0;
            totalPages = 0;
            disablePrevious = true;
            disableNext = true;
        }
        //change for add attendee CR 19.06.2020 start
		System.debug('disable Next '+disableNext);
        if(FilterCountry!='None' && isMena==true)
        {
       		 CountryList=TempCountryList;
        }
        //change for add attendee CR 19.06.2020 END
    }
    
    /*Cancel is used to return to meeting page KAUSHIK 12.17.2018 */
    
    public PageReference cancel(){
        String eventId = ApexPages.currentPage().getParameters().get('id');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    
    /*Addevent is used to add attendee KAUSHIK 12.17.2018 */
    
    public void addtoevent(){
        Set<Id> selAccs = new Set<Id>();
        for(wrapperlist wl : myoriginal){
            if(wl.selected == true){
                selAccs.add(wl.accId);                
            }
        }
        try{
            
            List<Event_Attendee_Vod__c> myattendeelist = new list<Event_Attendee_Vod__c>();
            //  Id recordtypeid = [Select ID FROM RecordType WHERE SobjectType='Event_Attendee_vod__c' AND Developername = 'Portal_Attendee_AGN'].Id;
            Id recordtypeid = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get('Portal Attendee').getRecordTypeId();
            for (Id w :selAccs){
                Event_Attendee_Vod__c myeventattendee = new Event_Attendee_Vod__c();
                myeventattendee.Medical_Event_vod__c = (String) currentEventsRecord.Id;
                //myeventattendee.RecordTypeID = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_Attendee_Record_Type_AGN).getRecordTypeId();
                myeventattendee.recordtypeid = recordtypeid;
                myeventattendee.Account_vod__c = w;
                myattendeelist.add(myeventattendee);
            }
            If (educationjourney !='None' && (myattendeelist==null || myattendeelist.size()<1) ){ apexpages.addMessage(New ApexPages.Message(ApexPages.SEVERITY.WARNING,'Please select at least one record')) ;}
            If (educationjourney=='None' && inputEmail == null){apexpages.addMessage(New ApexPages.Message(ApexPages.SEVERITY.WARNING,'Please select education journey from drop down')) ;}
            If  (myattendeelist.size()>0) {
                Insert myattendeelist;
                apexpages.addMessage(New ApexPages.Message(ApexPages.Severity.CONFIRM,'Attendee added')) ;}
        }
        
        catch(exception e){
            system.debug('Error occurred') ;
        }
        proceed();
    }
    public void setPages()
    {
        if(pageNumber == 1)
            disablePrevious = true;
        else
            disablePrevious = false;
        if(pageNumber == totalPages)
            disableNext = true;
        else
            disableNext = false;
    }
    public void goToBegining()
    {
        pageNumber = 1;
        tableStart = 0;
        setPages();
    }
    public void goToPrevious()
    {
        pageNumber = pageNumber - 1;
        tableStart = tableStart - tableSize;
        setPages();
        
    }
    public void goToNext()
    {
        pageNumber = pageNumber + 1;
        tableStart = tableStart + tableSize;
        setPages();
    }
    public void goToLast()
    {
        pageNumber = totalPages;
        tableStart = (totalPages-1)*tableSize;
        disableNext = true;
        setPages();
    }
    
    
    public class wrapperlist{
        //public account acc1{get;set;}
        public boolean selected{get;set;}
        public String accId {get; set;}
        public String accName {get; set;}
        public String accEmail {get; set;}
		public String accAttendee {get; set;}
        public String accEJ {get; set;}
        /*AMI MENA changes- Start*/
        public String CountryCode {get; set;}
        /*AMI MENA changes- END*/
        public wrapperlist(account a){
            
            //acc1 = a;
            accId = a.Id;
            accName = a.Name;
            accEmail = a.PersonEmail;
            accEJ=a.AMI_Educational_Journey__c;//AMI-CR-3990-changes
			if(a.AGN_AMI_ENABLED__C)
			accAttendee='AMI';
			else
			accAttendee='Non AMI';
            selected = false;
            /*AMI MENA changes- Start*/
            CountryCode=a.Country_Code__c;
            /*AMI MENA changes- END*/
        } 
    }
    
    
    public void addAllAddendees()
    {        
        //change for add attendee CR 19.06.2020 start
        if(FilterCountry!='None' && isMena==true)
        {
            TempCountryList=new Set<String>(CountryList);
            CountryList.clear();
            CountryList.add(FilterCountry);
        }
        //change for add attendee CR 19.06.2020 END
        list<Event_Attendee_Vod__c> insertAttendeelist = new list<Event_Attendee_Vod__c>();
        set<Id> attendee_history = new set<Id>(); //This is used to capture historical attendee ids
        for(Event_Attendee_Vod__c existing :[select Account_Vod__c from Event_Attendee_Vod__c where Medical_Event_vod__c =:currentEventsRecord.Id]){
            attendee_history.add(existing.Account_Vod__c);	
        }
        List<Account> allAccountlist = [select id,name,phone,AGN_AMI_ENABLED__C,Country_code__c,PersonEmail,AMI_Educational_Journey__c 
                                        FROM ACCOUNT 
                                        WHERE ((AGN_AMI_ENABLED__C = :getMAAccounts 
                                                or AGN_AMI_SC_Enabled__c = : (!getMAAccounts))
                                               and (AGN_AMI_ENABLED__C = true
                                                    or AGN_AMI_SC_Enabled__c = true))
                                        and id NOT IN :attendee_history 
                                        /*AMI MENA changes- Start*/
                                        //and (Country_code__c = :currentEventsRecord.Country_Code__c or Country_vod__r.Name =:currentEventsRecord.Country_Code__c)
                                        and (Country_code__c in :CountryList
                                            or Country_vod__r.Name in : CountryList)
                                        /*AMI MENA changes- End*/  
                                        order by name ASC];
        
        List<String> accIdList = new List<String>();
        Id recordtypeid = Schema.SObjectType.Event_Attendee_Vod__c.getRecordTypeInfosByDeveloperName().get('Portal_Attendee_AGN').getRecordTypeId();
        for(Account accAMI : allAccountlist){
            accIdList.add(accAMI.Id);
        }
        
        if(!accIdList.isEmpty()) {
            AGN_AMI_Attendee_Insert_Batch insertBatch = new AGN_AMI_Attendee_Insert_Batch(accIdList, currentEventsRecord.Id);
            Database.executeBatch(insertBatch, Integer.valueOf(System.Label.AGN_AMI_Attendee_Insert_Limit));
            apexpages.addMessage(New ApexPages.Message(ApexPages.Severity.CONFIRM,'Your request is being processed. Attendees will be reflected on the event, once completed.')) ;
            
        }else{
            //change for add attendee CR 19.06.2020 start
            if(isMena==false || FilterCountry!='--Select One--'){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'All Attendee have been already added.'));
            }
            //change for add attendee CR 19.06.2020 end
        }
        //change for add attendee CR 19.06.2020 start
        if(FilterCountry!='None' && isMena==true)
        {
       		 CountryList=TempCountryList;
        }
        myoriginal.clear();       
        //change for add attendee CR 19.06.2020 END
    }
    public List<SelectOption> getSegments()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Segmentation_and_Targeting_AGN__c.Segment_AGN__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Select')); 
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
        return options;
    }
	 /**** CR 2 start ****/
	public List<SelectOption> getAttendee()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select')); 
		options.add(new SelectOption('true', 'AMI')); 
		options.add(new SelectOption('false', 'Non AMI')); 
             
        return options;
    }
	 /**** CR 2 end ****/
    public List<SelectOption> getSpeciality()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<sObject> specList;
        if(AMI_User_Settings_AGN__c.getInstance(currentEventsRecord.Country_Code__c).Country_Managed_Specialty_AGN__c)
            specList = [Select id, Name from Specialty_Allergan_AGN__c 
                        /*AMI MENA changes- Start*/
                       // where Country_code_AGN__c = :currentEventsRecord.Country_Code__c
                         where Country_code_AGN__c in :CountryList
                        /*AMI MENA changes- END*/
                       ];
        else
            specList = [Select id, Name from Specialty_AGN__c 
                         /*AMI MENA changes- Start*/
                       // where Country_code_AGN__c = :currentEventsRecord.Country_Code__c
                         where Country_code_AGN__c in :CountryList
                        /*AMI MENA changes- END*/
                       ];
        options.add(new SelectOption('', 'Select')); 
        for(sObject obj : specList)
        {
            options.add(new SelectOption(obj.Id, (String)obj.get('Name')));
        }       
        return options;
    }
    public List<SelectOption> getEvent()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Medical_Event_vod__c> meetingList = [Select id, Name from Medical_event_vod__c 
                                                  where RecordType.DEveloperName =: AGN_AMI_Static_Labels.meetingRecordType 
                                                  /*AMI MENA changes- Start*/
                                                    //and Country_code__c = :currentEventsRecord.Country_Code__c 
                                                    and Country_code__c in :CountryList
                                                    /*AMI MENA changes- End*/  
                                                  order by End_Time_vod__c desc];
        options.add(new SelectOption('', 'Select')); 
        for(Medical_Event_vod__c obj : meetingList)
        {
            options.add(new SelectOption(obj.Id, obj.Name));
        }       
        return options;
    }
    public void filter()
    {
        List<Account> specFilter;
        List<Event_Attendee_vod__c> attendeeFilter;
        List<Segmentation_and_Targeting_AGN__c> productFilter;
        Set<String> specFilterId = new Set<String>();
        Set<String> attendeeFilterId = new Set<String>();
        Set<String> productFilterId = new Set<String>();
        filteredAccountList = new Set<String>();
        if(inputSpec != null && inputSpec != '')
        {
            specFilter = [Select Id from Account where Specialty_Allergan_1_AGN__c = :inputSpec or Specialty_1_AGN__c = :inputSpec];
            for(Account acc : specFilter)
            {
                specFilterId.add(acc.Id);
            }
			filterFlag=true;//CR 2
        }
        if(inputEvent != null && inputEvent != '')
        {
            attendeeFilter = [Select Account_vod__c from Event_attendee_vod__c where Medical_event_vod__c = :inputEvent];
            for(Event_attendee_vod__c attendee : attendeeFilter)
            {
                attendeeFilterId.add(attendee.Account_vod__c);
            }
			filterFlag=true; //CR 2
        }
        if(inputSegment != null && inputSegment != '')
        {
            productFilter = [Select Account_AGN__c from Segmentation_and_Targeting_AGN__c where Segment_AGN__c =: inputSegment];
            for(Segmentation_and_Targeting_AGN__c segment : productFilter)
            {
                productFilterId.add(segment.Account_AGN__c);
            }
			filterFlag=true;//CR 2
        }
        if(inputSpec != null && inputEvent != null && inputSegment != null)
        {
            attendeeFilterId.retainAll(productFilterId);
            specFilterId.retainAll(attendeeFilterId);
            filteredAccountList.addall(specFilterId);
        }
        else if(inputSpec != null && inputEvent != null && inputSegment == null)
        {
            specFilterId.retainAll(attendeeFilterId);
            filteredAccountList.addall(specFilterId);
        }
        else if(inputSpec != null && inputEvent == null && inputSegment != null)
        {
            specFilterId.retainAll(productFilterId);
            filteredAccountList.addall(specFilterId);
        }
        else if(inputSpec == null && inputEvent != null && inputSegment != null)
        {
            attendeeFilterId.retainAll(productFilterId);
            filteredAccountList.addall(attendeeFilterId);
        }
        else if(inputSpec != null && inputEvent == null && inputSegment == null)
        {
            filteredAccountList.addall(specFilterId);
        }
        else if(inputSpec == null && inputEvent == null && inputSegment != null)
        {
            filteredAccountList.addall(productFilterId);
        }
        else if(inputSpec == null && inputEvent != null && inputSegment == null)
        {
            filteredAccountList.addall(attendeeFilterId);
        }
    }
    public void clear()
    {
        inputSpec = null;
        inputEvent = null;
        inputSegment = null;
		inputAttendee = null; //CR 2
        actionSource = actionSourceOld;
        proceed();
    }
    public void selectAllList()
    {
        List<wrapperlist> tempMyOriginal = new List<wrapperlist>();
        for(wrapperlist wl : myoriginal)
        {
            wrapperlist temp = wl;
            temp.selected = selectAll;
            tempMyOriginal.add(temp);
        }
        myoriginal = tempMyOriginal;
    }
}