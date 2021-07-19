/* Modified by :ICL Project Team
   Decription : 1.Added New method CallApprovalProcess ()  for Spring 21 release by salesforce to call an apporval process from batch class.
                2.Added new method isCluster() as a  part of ICL wave 3 development for cluster country logic.
                3.Added getVaultFromLoc(),getVaultLoggedUser()  as a part of Vault Code Changes for LATAM.
                4.Added line 24 as a  part of ICL wave 3 development for cluster country logic. 
   Release :ICL Wave-3
*/
@RestResource(urlMapping='/v1/Locator_Listing_AGN__c/*')
global class AGN_ICL_SendLocatorListingData {
    
    
    @HttpGet
    global static List<AGN_ICL_SendLocatorListingData.ClinicInformation> getListofLocations()
    {
        RestResponse res = RestContext.response;
        List<Locator_Listing_AGN__c> loc;
        List<AGN_ICL_SendLocatorListingData.ClinicInformation> clinicdata = new List<AGN_ICL_SendLocatorListingData.ClinicInformation>();
        RestRequest request = RestContext.request;
        String lat = request.params.get('lat');
        String log = request.params.get('log');
        String Distance = request.params.get('dist');
        String requestingsite = request.params.get('reqsite');
        String country = request.params.get('country');
        String nullcheck ='';
        
         try{
            Decimal lat1 = Decimal.valueOf(lat);
            Decimal log1 = Decimal.valueOf(log);
            Integer Distance1 = Integer.valueOf(Decimal.valueOf(Distance).round(System.RoundingMode.UP));
           
            String query = 'Select id,name,Cluster_Country_AGN__c,Account_AGN__c,Account_AGN__r.name,Account_ID_AGN__c,Active_AGN__c,Ask_Question_Email_AGN__c,'+
                +'BD_Participant_AGN__c,Book_Consultation_AGN__c,Brand_AGN__c,City_AGN__c,Clinic_Admin_AGN__c,Country_Code_AGN__r.Alpha_2_Code_vod__c,Clinic_Admin_Email_AGN__c,Clinical_Investigator_AGN__c,'+
                +'Clinic_Experience_AGN__c,VIP_AGN__c,Clinic_Image_AGN__c,Clinic_Experience_Site_AGN__c,Clinic_Status_AGN__c,Consent_AGN__c,Country_AGN__c,Country_Shadow_AGN__c,Email_AGN__c,Enquiriy_Email_AGN__c,'+
                +'Friday_Close_Hours_AGN__c,Friday_Open_Hours_AGN__c,GeoLocation_AGN__c,GeoLocation_AGN__latitude__s,GeoLocation_AGN__longitude__s,Google_Url_AGN__c,Monday_Close_Hours_AGN__c,Monday_Open_Hours_AGN__c,'+
                +'Offer_Evenings_AGN__c,Open_Evenings_Email_AGN__c,Phone_Number_AGN__c,Picture_Available_AGN__c,Registered_For_Clinic_Locator_AGN__c,'+
                +'Request_Call_Email_AGN__c,Saturday_Close_Hours_AGN__c,Saturday_Open_Hours_AGN__c,State_Providence_Region_AGN__c,Street_AGN__c,Sunday_Close_Hours_AGN__c,'+
                +'Sunday_Open_Hours_AGN__c,Testimonial_Available_AGN__c,Thursday_Close_Hours_AGN__c,Thursday_Open_Hours_AGN__c,Tuesday_Close_Hours_AGN__c,'+
                +'Tuesday_Open_Hours_AGN__c,Website_AGN__c,Wednesday_Close_Hours_AGN__c,Wednesday_Open_Hours_AGN__c,Zip_Code_AGN__c,Clinic_Type_AGN__c,Google_URL_France_AGN__c,'+
                +'(Select id,Salutation_AGN__c,name,First_Name_AGN__c,Consent_AGN__c,Practitioner_Image_AGN__c,Practitioner_Image_Available_AGN__c,Brand_AGN__c,Gender_AGN__c,Email_AGN__c,Last_Name_AGN__c,Locator_Listing_AGN__c,Practitioner_Status_AGN__c,'+
                +'Qualification_AGN__c,Status_AGN__c,Type_AGN__c,Type_Of_Physician_AGN__c,Years_of_Experience_AGN__c from Practitioner_Listings__r where Consent_AGN__c='+'true'+' AND Brand_AGN__c includes (\''+requestingsite+'\''+')'+')';
            //+'from Locator_Listing_AGN__c where Active_AGN__c='+'true'+' AND Country_Code_AGN__r.Alpha_2_Code_vod__c =\''+country+'\''+' AND Brand_AGN__c includes (\''+requestingsite+'\''+')'+'AND DISTANCE(GeoLocation_AGN__c,GEOLOCATION('+lat1+','+log1+'),\'km\') < '+Distance1;
            
           // Added the below lines of code for cluster country logic to mitigate different funtionalities at the website end.
             
                     AGN_ICL_Portal_Settings__c settings = AGN_ICL_Portal_Settings__c.getOrgDefaults();
                     List<String> listsettings=new List<String>();
                     listsettings.add(settings.Site_core_country_AGN__c);
                     if(!listsettings.IsEmpty())
                     {
                          if(settings.Site_core_country_AGN__c.contains(country))
                             {
                    
                                  if(Distance1 == -1)
                                    {
                                        query = query +'from Locator_Listing_AGN__c where Active_AGN__c='+'true'+' AND Cluster_Country_AGN__c =\''+country+'\''+' AND Brand_AGN__c includes (\''+requestingsite+'\''+')';
                                    }
                                  else
                                    {
                                         query = query +'from Locator_Listing_AGN__c where Active_AGN__c='+'true'+' AND Cluster_Country_AGN__c =\''+country+'\''+' AND Brand_AGN__c includes (\''+requestingsite+'\''+')'+'AND DISTANCE(GeoLocation_AGN__c,GEOLOCATION('+lat1+','+log1+'),\'km\') < '+Distance1;
                                     }
                            
                             }
                             else
                             {
                                     if(Distance1 == -1)
                                       {
                                            query = query +'from Locator_Listing_AGN__c where Active_AGN__c='+'true'+' AND Country_Code_AGN__r.Alpha_2_Code_vod__c =\''+country+'\''+' AND Brand_AGN__c includes (\''+requestingsite+'\''+')';
                                       }
                                     else
                                     {
                                           query = query +'from Locator_Listing_AGN__c where Active_AGN__c='+'true'+' AND Country_Code_AGN__r.Alpha_2_Code_vod__c =\''+country+'\''+' AND Brand_AGN__c includes (\''+requestingsite+'\''+')'+'AND DISTANCE(GeoLocation_AGN__c,GEOLOCATION('+lat1+','+log1+'),\'km\') < '+Distance1;
                                     }
                             }
                      }       
                    if(listsettings.IsEmpty())
                    {
                        if(Distance1 == -1)
                               {
                                    query = query +'from Locator_Listing_AGN__c where Active_AGN__c='+'true'+' AND Country_Code_AGN__r.Alpha_2_Code_vod__c =\''+country+'\''+' AND Brand_AGN__c includes (\''+requestingsite+'\''+')';
                               }
                        else
                             {
                                    query = query +'from Locator_Listing_AGN__c where Active_AGN__c='+'true'+' AND Country_Code_AGN__r.Alpha_2_Code_vod__c =\''+country+'\''+' AND Brand_AGN__c includes (\''+requestingsite+'\''+')'+'AND DISTANCE(GeoLocation_AGN__c,GEOLOCATION('+lat1+','+log1+'),\'km\') < '+Distance1;
                            }
                    }
             //End
             
            loc = Database.query(query);
           
            if(loc.size()>0)
            {
                
                for(Locator_Listing_AGN__c loclst : loc)
                {
                    
                    ClinicInformation clinic = new ClinicInformation();
                    Clinic_Hours clinic_hour = new Clinic_Hours();
                    Clinic_Open_Hours clinic_open = new Clinic_Open_Hours();
                    Clinic_Close_Hours clinic_close = new Clinic_Close_Hours();
                    Clinic_Address clinic_add = new Clinic_Address();
                    
                    //Clinic Information
                    clinic.clinicName = loclst.name;
                    
                    
                    //Adding country code in Response
                    clinic.countrycode=loclst.Country_Code_AGN__r.Alpha_2_Code_vod__c;
                    clinic.clustercountrycode=loclst.Cluster_Country_AGN__c;
                    
                    
                   if(clinic.askQuestion_Email==NULL)
                    {
                        clinic.askQuestion_Email=nullcheck;
                    }
                    else
                    {
                        clinic.askQuestion_Email =loclst.Ask_Question_Email_AGN__c;  
                    }
                    //clinic.askQuestion_Email =loclst.Ask_Question_Email_AGN__c;
                    if(clinic.clinic_experience==NULL)
                    {
                        clinic.clinic_experience=nullcheck;
                    }
                    else
                    {
                        clinic.clinic_experience =loclst.Clinic_Experience_Site_AGN__c;
                    }
                    // clinic.clinic_experience =loclst.Clinic_Experience_Site_AGN__c;
                    /*if(clinic.email==NULL)
                        {
                        clinic.email=nullcheck;
                        }
                        else
                        {
                        clinic.email =loclst.Email_AGN__c;
                        }*/
                    clinic.email =loclst.Email_AGN__c;
                    if(clinic.enquiry_email==NULL)
                    {
                        clinic.enquiry_email=nullcheck;
                    }
                    else
                    {
                        clinic.enquiry_email =loclst.Enquiriy_Email_AGN__c;
                    }
                    // clinic.enquiry_email =loclst.Enquiriy_Email_AGN__c;
                    clinic.clinicId = loclst.id;
                    /* if(clinic.vipbool==NULL)
                        {
                        clinic.vipbool=nullcheck;
                        }
                        else
                        {
                        clinic.vipbool = loclst.VIP_AGN__c;
                        } */
                    clinic.vipbool = loclst.VIP_AGN__c;
                    
                    
                    clinic.book_consultation_url =loclst.Book_Consultation_AGN__c;
                    
                    
                    if(clinic.google_url==NULL)
                    {
                        clinic.google_url=nullcheck;   
                    }
                    else
                    {
                        clinic.google_url =loclst.Google_Url_AGN__c;
                    }
                    // clinic.google_url =loclst.Google_Url_AGN__c;
                    /*if(clinic.website_url==NULL)
                        {
                        clinic.website_url=nullcheck;
                        }
                        else
                        {
                        clinic.website_url = loclst.Website_AGN__c;
                        }*/
                    clinic.website_url = loclst.Website_AGN__c;
                    /* if(clinic.offerEvenings==NULL)
                        {
                        clinic.offerEvenings=nullcheck;
                        }
                        else
                        {
                        clinic.offerEvenings =loclst.Offer_Evenings_AGN__c;
                        } */
                    clinic.offerEvenings =loclst.Offer_Evenings_AGN__c;
                    if(clinic.open_evening_email==NULL)
                    {
                        clinic.open_evening_email=nullcheck;
                    }
                    else
                    {
                        clinic.open_evening_email =loclst.Open_Evenings_Email_AGN__c;
                    }
                    // clinic.open_evening_email =loclst.Open_Evenings_Email_AGN__c;
                    //clinic.phone_no =loclst.Phone_Number_AGN__c;
                    clinic.request_call_email =loclst.Request_Call_Email_AGN__c;
                    Clinic.Clinic_Type =loclst.Clinic_Type_AGN__c;
                    Clinic.google_url_france =loclst.Google_URL_France_AGN__c;
                    // clinic.seo =loclst.SEO_AGN__c; // SEO implementation
                    /*  if(clinic.testimonial_available==NULL)
                        {
                        clinic.testimonial_available=nullcheck;
                        }
                        else
                        {
                        clinic.testimonial_available =loclst.Testimonial_Available_AGN__c;
                        } */
                    clinic.testimonial_available =loclst.Testimonial_Available_AGN__c;
                    
                    clinic.clinicpicture_available = loclst.Picture_Available_AGN__c;
                    clinic.clinic_image = loclst.Clinic_Image_AGN__c;
                    clinic.clinic_contact = loclst.Phone_Number_AGN__c;
                    clinic.lat = loclst.GeoLocation_AGN__Latitude__s;
                    clinic.longi = loclst.GeoLocation_AGN__longitude__s;
                    
                    //Clinic Address to be kept together
                    clinic_add.city =loclst.City_AGN__c;
                    clinic_add.country =loclst.Country_AGN__c;
                    /*if(clinic_add.state==NULL)
                        {
                        clinic_add.state=nullcheck;
                        }
                        else
                        {
                        clinic_add.state =loclst.State_Providence_Region_AGN__c;   
                        }*/
                    clinic_add.state =String.isNotEmpty(loclst.State_Providence_Region_AGN__c)?loclst.State_Providence_Region_AGN__c:nullcheck;
                    clinic_add.street =loclst.Street_AGN__c;
                   // clinic_add.zip_code =loclst.Zip_Code_AGN__c;
                    clinic_add.zip_code =String.isNotEmpty(loclst.Zip_Code_AGN__c)?loclst.Zip_Code_AGN__c:nullcheck;
                    clinic.clinic_address = clinic_add;
                    
                    
                    clinic_hour.Monday = String.valueOf(loclst.Monday_Open_Hours_AGN__c)==null ? ( String.valueOf(loclst.Monday_Close_Hours_AGN__c)==null ? '-' : '-'+(String.valueOf(loclst.Monday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Monday_Close_Hours_AGN__c).split(':')[1]))
                        : ( String.valueOf(loclst.Monday_Close_Hours_AGN__c)== null ? (String.valueOf(loclst.Monday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Monday_Open_Hours_AGN__c).split(':')[1]):(String.valueOf(loclst.Monday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Monday_Open_Hours_AGN__c).split(':')[1]+'-'+String.valueOf(loclst.Monday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Monday_Close_Hours_AGN__c).split(':')[1]));
                            
                            clinic_hour.Tuesday = String.valueOf(loclst.Tuesday_Open_Hours_AGN__c)==null ? ( String.valueOf(loclst.Tuesday_Close_Hours_AGN__c)==null ? '-' : '-'+(String.valueOf(loclst.Tuesday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Tuesday_Close_Hours_AGN__c).split(':')[1]))
                            : ( String.valueOf(loclst.Tuesday_Close_Hours_AGN__c)== null ? (String.valueOf(loclst.Tuesday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Tuesday_Open_Hours_AGN__c).split(':')[1]):(String.valueOf(loclst.Tuesday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Tuesday_Open_Hours_AGN__c).split(':')[1]+'-'+String.valueOf(loclst.Tuesday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Tuesday_Close_Hours_AGN__c).split(':')[1]));
                                
                                clinic_hour.Wednesday = String.valueOf(loclst.Wednesday_Open_Hours_AGN__c)==null ? ( String.valueOf(loclst.Wednesday_Close_Hours_AGN__c)==null ? '-' : '-'+(String.valueOf(loclst.Wednesday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Wednesday_Close_Hours_AGN__c).split(':')[1]))
                                : ( String.valueOf(loclst.Wednesday_Close_Hours_AGN__c)== null ? (String.valueOf(loclst.Wednesday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Wednesday_Open_Hours_AGN__c).split(':')[1]):(String.valueOf(loclst.Wednesday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Wednesday_Open_Hours_AGN__c).split(':')[1]+'-'+String.valueOf(loclst.Wednesday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Wednesday_Close_Hours_AGN__c).split(':')[1]));
                                    
                                    clinic_hour.Thursday = String.valueOf(loclst.Thursday_Open_Hours_AGN__c)==null ? ( String.valueOf(loclst.Thursday_Close_Hours_AGN__c)==null ? '-' : '-'+(String.valueOf(loclst.Thursday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Thursday_Close_Hours_AGN__c).split(':')[1]))
                                    : ( String.valueOf(loclst.Thursday_Close_Hours_AGN__c)== null ? (String.valueOf(loclst.Thursday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Thursday_Open_Hours_AGN__c).split(':')[1]):(String.valueOf(loclst.Thursday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Thursday_Open_Hours_AGN__c).split(':')[1]+'-'+String.valueOf(loclst.Thursday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Thursday_Close_Hours_AGN__c).split(':')[1]));
                                        
                                        clinic_hour.Friday = String.valueOf(loclst.Friday_Open_Hours_AGN__c)==null ? ( String.valueOf(loclst.Friday_Close_Hours_AGN__c)==null ? '-' : '-'+(String.valueOf(loclst.Friday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Friday_Close_Hours_AGN__c).split(':')[1]))
                                        : ( String.valueOf(loclst.Friday_Close_Hours_AGN__c)== null ? (String.valueOf(loclst.Friday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Friday_Open_Hours_AGN__c).split(':')[1]):(String.valueOf(loclst.Friday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Friday_Open_Hours_AGN__c).split(':')[1]+'-'+String.valueOf(loclst.Friday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Friday_Close_Hours_AGN__c).split(':')[1]));
                                            
                                            clinic_hour.Saturday = String.valueOf(loclst.Saturday_Open_Hours_AGN__c)==null ? ( String.valueOf(loclst.Saturday_Close_Hours_AGN__c)==null ? '-' : '-'+(String.valueOf(loclst.Saturday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Saturday_Close_Hours_AGN__c).split(':')[1]))
                                            : ( String.valueOf(loclst.Saturday_Close_Hours_AGN__c)== null ? (String.valueOf(loclst.Saturday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Saturday_Open_Hours_AGN__c).split(':')[1]):(String.valueOf(loclst.Saturday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Saturday_Open_Hours_AGN__c).split(':')[1]+'-'+String.valueOf(loclst.Saturday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Saturday_Close_Hours_AGN__c).split(':')[1]));
                                                
                                                clinic_hour.Sunday = String.valueOf(loclst.Sunday_Open_Hours_AGN__c)==null ? ( String.valueOf(loclst.Sunday_Close_Hours_AGN__c)==null ? '-' : '-'+(String.valueOf(loclst.Sunday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Sunday_Close_Hours_AGN__c).split(':')[1]))
                                                : ( String.valueOf(loclst.Sunday_Close_Hours_AGN__c)== null ? (String.valueOf(loclst.Sunday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Sunday_Open_Hours_AGN__c).split(':')[1]):(String.valueOf(loclst.Sunday_Open_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Sunday_Open_Hours_AGN__c).split(':')[1]+'-'+String.valueOf(loclst.Sunday_Close_Hours_AGN__c).split(':')[0]+':'+String.valueOf(loclst.Sunday_Close_Hours_AGN__c).split(':')[1]));
                                                    
                                                    clinic.clinc_hours = clinic_hour;
                    
                    //Clinic Open hours to be kept together 
                    clinic_open.monday_open_hour =loclst.Monday_Open_Hours_AGN__c;
                    clinic_open.tuesday_open_hour =loclst.Tuesday_Open_Hours_AGN__c;
                    clinic_open.wednesday_open_hour =loclst.Wednesday_Open_Hours_AGN__c;
                    clinic_open.thursday_open_hour =loclst.Thursday_Open_Hours_AGN__c;
                    clinic_open.friday_open_hour =loclst.Friday_Open_Hours_AGN__c;
                    clinic_open.saturday_open_hour =loclst.Saturday_Open_Hours_AGN__c;
                    clinic_open.sunday_open_hour =loclst.Sunday_Open_Hours_AGN__c; 
                    clinic.clinc_open_hour = clinic_open;
                    
                    //Clinic Close hours to be kept together 
                    clinic_close.monday_close_hour =loclst.Monday_Close_Hours_AGN__c;
                    clinic_close.tuesday_close_hour =loclst.Tuesday_Close_Hours_AGN__c;
                    clinic_close.wednesday_close_hour =loclst.Wednesday_Close_Hours_AGN__c;
                    clinic_close.thursday_close_hour =loclst.Thursday_Close_Hours_AGN__c;
                    clinic_close.friday_close_hour =loclst.Friday_Close_Hours_AGN__c;
                    clinic_close.saturday_close_hour =loclst.Saturday_Close_Hours_AGN__c;
                    clinic_close.sunday_close_hour =loclst.Sunday_Close_Hours_AGN__c;
                    clinic.clinc_close_hour = clinic_close;
                    
                    //Practitioners list to be created
                 
                    List<Practitioner_In_Clinic> practitioners_list = new List<Practitioner_In_Clinic>();
                    for(Practitioner_Listing_AGN__c practlst : loclst.Practitioner_Listings__r)
                    {
                        
                        Practitioner_In_Clinic practitioner = new Practitioner_In_Clinic();
                        practitioner.salutation = practlst.Salutation_AGN__c;
                        practitioner.firstName = practlst.First_Name_AGN__c;
                        practitioner.lastName = practlst.Last_Name_AGN__c;
                        practitioner.email = practlst.Email_AGN__c;
                        practitioner.gender = practlst.Gender_AGN__c;
                        practitioner.practitionerimageurl = practlst.Practitioner_Image_AGN__c;
                        practitioner.type_of_physician = practlst.Type_AGN__c; 
                        practitioner.yearofexperience = practlst.Years_of_Experience_AGN__c;
                        practitioner.qualification = practlst.Qualification_AGN__c;
                        practitioner.practitionerpicture_available = practlst.Practitioner_Image_Available_AGN__c;
                        practitioners_list.add(practitioner);
                    }
                   
                    clinic.practitioners = practitioners_list;
                    
                    clinicdata.add(clinic);
                   
                }
                
            }
            //res.responseBody = Blob.valueOf(JSON.serialize(clinicdata));
            //res.statusCode = 200;
        }
        catch(Exception ex)
        {
           
            res.responseBody = Blob.valueOf(ex.getMessage());
            res.statusCode = 500;
        }
        //List<Test_4__c>
        return clinicdata;
    }
    global class ClinicInformation
    {
        public String clinicId;
        public String clinicName;
        public String askQuestion_Email;
        public String clinic_experience;
        public String email;
        public String enquiry_email;
        public String google_url;
        public String website_url;
        public String book_consultation_url;
        public Boolean offerEvenings;
        public String open_evening_email;
        public String clinic_contact;
        public String clinic_image; // remaining
        public String request_call_email;
        // public String seo; // SEO implementation
        public Boolean testimonial_available;
        public Boolean clinicpicture_available;
        public Boolean vipbool;
        public Decimal lat;
        public Decimal longi;
        public List<Practitioner_In_Clinic> practitioners;
        public Clinic_Hours clinc_hours;
        public Clinic_Open_Hours clinc_open_hour;
        public Clinic_Close_Hours clinc_close_hour;
        public Clinic_Address clinic_address;
        public String Clinic_Type;
        public String google_url_france;
        //Adding country code in Response
        public String countrycode;
        public String clustercountrycode;
        public ClinicInformation()
        {
            
        }
    }
    
    global Class Practitioner_In_Clinic{
        //public String clinicName;
        public String salutation;
        public String firstName;
        public String lastName;
        public String email;
        public String gender;
        public String practitionerimageurl;
        public String type_of_physician;
        public Decimal yearofexperience;
        public String qualification;
        public Boolean practitionerpicture_available;
        
        public Practitioner_In_Clinic()
        {
            
        }
    }
    
    global Class Clinic_Hours{
        public String Monday;
        public String Tuesday;
        public String Wednesday;
        public String Thursday;
        public String Friday;
        public String Saturday;
        public String Sunday;
        
        public Clinic_Hours()
        {
            
        }
    }
    
    global Class Clinic_Open_Hours{
        public Time monday_open_hour;
        public Time tuesday_open_hour; 
        public Time wednesday_open_hour; 
        public Time thursday_open_hour; 
        public Time friday_open_hour; 
        public Time saturday_open_hour;
        public Time sunday_open_hour;
        public Clinic_Open_Hours()
        {
            
        }
    }
    
    global Class Clinic_Close_Hours{
        public Time monday_close_hour;
        public Time tuesday_close_hour;
        public Time wednesday_close_hour;
        public Time thursday_close_hour;
        public Time friday_close_hour;
        public Time saturday_close_hour;
        public Time sunday_close_hour;
        
        public Clinic_Close_Hours()
        {
            
        }
    }
    
    global Class Clinic_Address{
        public String street;
        public String state;
        public String zip_code;
        public String city;
        public String country;
    }
}