public class AGN_MI_Email_Template_Controller {    
    
    public Account ACCOUNT = new Account();
    public Medical_Inquiry_vod__c MI = new Medical_Inquiry_vod__c();
    public List<Address_vod__c> ADDRESS = new List<Address_vod__c>();
    public User USER =new User();
    public AGN_MIR_Setting__c MIRSETTINGS=new AGN_MIR_Setting__c();
    
    public Id MI_Id {get;set;}
    
    public string MI_name{get;set;}
    public string First_Name {get;set;}
    public string Last_Name {get;set;}
    public string Allergan_Specialty_Name {get;set;}
    public string Primary_Parent_Name {get;set;}
    public string Source {get;set;}
    public string Delivery_Method {get;set;}
    public string Full_Address {get;set;}
    public string City {get;set;}
    public string State {get;set;}
    public string Zip {get;set;}
    public string Country {get;set;}
    public string Product {get;set;}
    public string RepName {get;set;}
    public string Priority {get;set;}
    public string Question {get;set;}
    public string Email {get;set;}   
    public string Fax {get;set;}    
    public string Phone {get;set;}
    public string Misc {get;set;}
    public string Country_Code {get;set;}  
    public string MIR_Code {get;set;}  
    public string MIR_Country_Code {get;set;}
    public User createdByUser;
    public User UserProfile;
    //RepPhone variable defined for R16 PMO 2124
	//RepPhone variable redefined to RepEmail R3_Minor_2019 2724
    public string RepEmail {get;set;}
    //public string MI_Country_Code {get;set;}  
    
    public String getMI_Code(){
        
        MI=getMI();
        MIRSETTINGS=getMIRsetting();
        MIR_Country_Code=MIRSETTINGS.Country_Code_AGN__c;
        UserProfile = [select Name, Profile.Name, Email from User where id = : MI.CreatedById LIMIT 1];
        //MIR_Code logic has been defined for 19R2 PMO 2454
        if(UserProfile.Profile.Name == 'AGN MSL - Platform' || UserProfile.Profile.Name == 'AGN MSL Admin' ){
            MIR_Code=MIRSETTINGS.MSL_Code_AGN__c;
        }
        else{
            MIR_Code=MIRSETTINGS.Code_AGN__c;
        }
        MI_details();
        return MIR_Code;
    }
    
    public Medical_Inquiry_vod__c getMI(){
        Medical_Inquiry_vod__c medInq = new Medical_Inquiry_vod__c();
        medInq= [select id,name,Account_vod__c,Address_Line_1_vod__c,Address_Line_2_vod__c,City_vod__c,State_vod__c,
                 Zip_vod__c,Country_vod__c,Country_Code__c,Delivery_Method_AGN__c,Product_Catalog_AGN__c,CreatedByid,Inquiry_Text__c,
                 Email_vod__c,Fax_Number_vod__c,Phone_Number_vod__c,Delivery_Method_vod__c from Medical_Inquiry_vod__c where id=:MI_Id LIMIT 1];
        system.debug('MI_Id '+MI_Id);
        system.debug(medInq);
        system.debug('delivery method: '+medInq.Delivery_Method_AGN__c);
        return medInq;       
    }
    
    public Account getAccount(){
        
        Account acc = new Account();
        acc=[select firstname,lastname,Specialty_Allergan_1_AGN__c,Primary_Parent_vod__c,Phone ,PersonEmail
             from Account where ispersonaccount = true  and id = :MI.Account_vod__c];
        system.debug(acc);
        return acc;
    }
    
    public List<Address_vod__C> getAddress(){
        //updated for bug fix
        List<Address_vod__c> addr = [select Name,Address_Line_2_vod__c,City_vod__c,State_vod__c,Zip_vod__c,Country_vod__c 
                                     from Address_vod__c where Primary_vod__c =: true and Account_vod__c = : MI.Account_vod__c];
        system.debug(addr);
        if(addr.size()>0)
            return addr;
        else
            return NULL;
        //end of updated code
    }
    
    //MSL Code has been added in query for 19R2 PMO 2454
    public AGN_MIR_Setting__c getMIRsetting(){
        AGN_MIR_Setting__c MIR_sttng = new AGN_MIR_Setting__c();
        MIR_sttng=[select Code_AGN__c,MSL_Code_AGN__c,Country_Code_AGN__c 
                   from AGN_MIR_Setting__c where Country_Code_AGN__c =: MI.Country_Code__c];
        system.debug(MIR_sttng);
        return MIR_sttng;
    }
    
    public void MI_details(){
        system.debug('Inside MI_details');
        ACCOUNT=getAccount();
        ADDRESS=getAddress();        
        
        //Email has been added in query for R16 PMO 2124
        createdByUser = [select Name, Profile.Name, Email from User where id = : MI.CreatedById LIMIT 1];
        
        MI_name=MI.Name;
        
        //Priority logic has been defined for 19R2 PMO 2454
        if(createdByUser.Profile.Name == 'AGN MSL - Platform' || createdByUser.Profile.Name == 'AGN MSL Admin'){
            Source='CRM';
            Priority='Med Affairs';
        }else{
            Source='CRM';
            Priority='Normal';
        }
        
        
        //Email has been stored in RepPhone for all users against R17 PMO 2183
		//Email has been stored in RepEmail for all users against R3_Minor_2019 2724
        RepEmail = createdByUser.Email;
        First_Name=ACCOUNT.FirstName;
        Last_Name=ACCOUNT.LastName;
        system.debug('FirstName '+First_Name);
        
        
        //Updated for bug fix
        
        if(ACCOUNT.Specialty_Allergan_1_AGN__c != NULL)
        {
            Allergan_Specialty_Name=[select name from Specialty_Allergan_AGN__c where id = :ACCOUNT.Specialty_Allergan_1_AGN__c].Name;
            system.debug('Allergan_Specialty_Name '+Allergan_Specialty_Name);
        }
        
        if(ACCOUNT.Primary_Parent_vod__c != NULL)
        {
            Primary_Parent_Name=[select name from Account where id = :ACCOUNT.Primary_Parent_vod__c].Name;
            system.debug('Primary_Parent_Name '+Primary_Parent_Name);
        }
        //end of updated code
        
        Delivery_Method=String.valueOf(MI.Delivery_Method_vod__c).replace('_vod', '');
        Product=[select name from Product_vod__C where id = :MI.Product_Catalog_AGN__c].Name;
        RepName=createdByUser.Name;
        Question=MI.Inquiry_Text__c;
        Country=MI.Country_Code__c;
        // MI_Country_Code=MI.Country_Code__c;
        //system.debug(MI_Name+First_Name+Last_Name+Allergan_Specialty_Name+Primary_Parent_Name+Delivery_Method+Product+RepName+Question);
        
        MI_details_by_delivery_method();    
    }
    
    public void MI_details_by_delivery_method()
    {  
        
        String deliveryMethod=MI.Delivery_Method_vod__c;
        
        system.debug('delivery method inside MI_details_by_delivery_method'+deliveryMethod);
        if(MI.Delivery_Method_vod__c=='Urgent_Mail_vod'||MI.Delivery_Method_vod__c=='Mail_vod')
        {
            Full_Address=MI.Address_Line_1_vod__c+(MI.Address_Line_2_vod__c != null ? ' ' + MI.Address_Line_2_vod__c : '');
            City=MI.City_vod__c;
            State=MI.State_vod__c;
            Zip=MI.Zip_vod__c;
            Phone=ACCOUNT.Phone;
            Email=ACCOUNT.PersonEmail;
            system.debug(Full_Address+' '+City+' '+State+' '+Zip+' '+Country+' '+Phone+' '+Email);
        }
        
        else if(MI.Delivery_Method_vod__c=='Email_vod')
        {
            Email=MI.Email_vod__c; 
            Phone=ACCOUNT.Phone;
            // Updated for Bug fix
            if(ADDRESS!=NULL)
            {
                for(Integer i=0;i<ADDRESS.size();i++)
                {
                    Full_Address=ADDRESS.get(i).Name+(ADDRESS.get(i).Address_Line_2_vod__c != null ? ' ' + ADDRESS.get(i).Address_Line_2_vod__c : '');
                    City=ADDRESS.get(i).City_vod__c;
                    State=ADDRESS.get(i).State_vod__c;
                    Zip=ADDRESS.get(i).Zip_vod__c;
                }
            }
            //End of Updated code
        }
        
        else if(MI.Delivery_Method_vod__c=='Fax_vod')
        {
            Phone=ACCOUNT.Phone;
            Email=ACCOUNT.PersonEmail;
            Fax=MI.Fax_Number_vod__c;
            
            // Updated for Bug fix
            if(ADDRESS!=NULL)
            {
                for(Integer i=0;i<ADDRESS.size();i++)
                {
                    Full_Address=ADDRESS.get(i).Name+(ADDRESS.get(i).Address_Line_2_vod__c != null ? ' ' + ADDRESS.get(i).Address_Line_2_vod__c : '');
                    City=ADDRESS.get(i).City_vod__c;
                    State=ADDRESS.get(i).State_vod__c;
                    Zip=ADDRESS.get(i).Zip_vod__c;
                }
            }
            //End of Updated code
        }
        
        else if(MI.Delivery_Method_vod__c=='Phone_vod')
        {
            Phone=MI.Phone_Number_vod__c;
            Email=ACCOUNT.PersonEmail;
            
            // Updated for Bug fix
            if(ADDRESS!=NULL)
            {
                for(Integer i=0;i<ADDRESS.size();i++)
                {
                    Full_Address=ADDRESS.get(i).Name+(ADDRESS.get(i).Address_Line_2_vod__c != null ? ' ' + ADDRESS.get(i).Address_Line_2_vod__c : '');
                    City=ADDRESS.get(i).City_vod__c;
                    State=ADDRESS.get(i).State_vod__c;
                    Zip=ADDRESS.get(i).Zip_vod__c;
                }
            }
            //End of Updated code
        }
        
        //Code section for delivery method =MSL Delivery has been added for R16 PMO 2124
        else if(MI.Delivery_Method_vod__c=='MSL Delivery')
        {
            
            Phone=ACCOUNT.Phone;
            Email=ACCOUNT.PersonEmail;
            
            if(ADDRESS!=NULL)
            {
                for(Integer i=0;i<ADDRESS.size();i++)
                {
                    Full_Address=ADDRESS.get(i).Name+(ADDRESS.get(i).Address_Line_2_vod__c != null ? ' ' + ADDRESS.get(i).Address_Line_2_vod__c : '');
                    City=ADDRESS.get(i).City_vod__c;
                    State=ADDRESS.get(i).State_vod__c;
                    Zip=ADDRESS.get(i).Zip_vod__c;
                }
            }
        }
        //end of R16 PMO 2124 changes
    }   
}