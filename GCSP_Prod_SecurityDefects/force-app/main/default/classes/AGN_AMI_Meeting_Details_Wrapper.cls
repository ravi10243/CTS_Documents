public class AGN_AMI_Meeting_Details_Wrapper {
    public Medical_Event_vod__c meeting {get; set;}
    public boolean registered {get; set;}
    public String facultyName {get; set;}
    public String startDate {get; set;}
    public String startMonth {get; set;}
    public String startYear {get; set;}
    public String EndDate {get; set;}
    public String EndMonth {get; set;}
    public String EndYear {get; set;}
    public String dates {get; set;}
    public date st;
    public date en;
    public integer a;
    public string eventStartTime{get;set;}
    public string eventStartTimeIn24hrs='HH:mm z';
    public string days{get;set;}
    public string hours{get;set;}
    public string mins{get;set;}
    public string total_time{get;set;}
    public integer day;
    public integer hour;
    public integer min;
    
   // public Double time1; 
    
    public AGN_AMI_Meeting_Details_Wrapper(Medical_Event_vod__c meeting, boolean registered,String facultyName)
    {   //this.time1= meeting.Time_Duration_AGN__c;
        this.meeting = meeting;
        this.facultyName = facultyName;
        this.registered = registered;
        this.startDate = meeting.Start_Time_vod__c.format('dd');
        this.EndDate = meeting.End_Time_vod__c.format('dd');
        switch on meeting.Start_Time_vod__c.format('MM') {
            when '01' {	
                this.startMonth = Label.AGN_AMI_Jan;
            }
            when '02' {	
                this.startMonth = Label.AGN_AMI_Feb;
            }	
            when '03' {	
                this.startMonth = Label.AGN_AMI_Mar;
            }	
            when '04' {	
                this.startMonth = Label.AGN_AMI_Apr;
            }	
            when '05' {	
                this.startMonth = Label.AGN_AMI_May;
            }	
            when '06' {	
                this.startMonth = Label.AGN_AMI_Jun;
            }	
            when '07' {	
                this.startMonth = Label.AGN_AMI_Jul;
            }	
            when '08' {	
                this.startMonth = Label.AGN_AMI_Aug;
            }	
            when '09' {	
                this.startMonth = Label.AGN_AMI_Sep;
            }	
            when '10' {	
                this.startMonth = Label.AGN_AMI_Oct;
            }	
            when '11' {	
                this.startMonth = Label.AGN_AMI_Nov;
            }	
            when '12' {	
                this.startMonth = Label.AGN_AMI_Dec;
            }	
        }
        switch on meeting.End_Time_vod__c.format('MM') {
            when '01' {	
                this.EndMonth = Label.AGN_AMI_Jan;
            }
            when '02' {	
                this.EndMonth = Label.AGN_AMI_Feb;
            }	
            when '03' {	
                this.EndMonth = Label.AGN_AMI_Mar;
            }	
            when '04' {	
                this.EndMonth = Label.AGN_AMI_Apr;
            }	
            when '05' {	
                this.EndMonth = Label.AGN_AMI_May;
            }	
            when '06' {	
                this.EndMonth = Label.AGN_AMI_Jun;
            }	
            when '07' {	
                this.EndMonth = Label.AGN_AMI_Jul;
            }	
            when '08' {	
                this.EndMonth = Label.AGN_AMI_Aug;
            }	
            when '09' {	
                this.EndMonth = Label.AGN_AMI_Sep;
            }	
            when '10' {	
                this.EndMonth = Label.AGN_AMI_Oct;
            }	
            when '11' {	
                this.EndMonth = Label.AGN_AMI_Nov;
            }	
            when '12' {	
                this.EndMonth = Label.AGN_AMI_Dec;
            }	
        }
        this.startYear = meeting.Start_Time_vod__c.format('YYYY');
        this.EndYear = meeting.End_Time_vod__c.format('YYYY');  
        
        //CR3383- Fetching start time for upcoming events
        this.eventStartTime=meeting.Start_Time_vod__c.format(eventStartTimeIn24hrs,UserInfo.getTimeZone().getID());

        //CR3262 - Timezone added to string formatting
     /*render second date if start date and end date are same*/
        st=meeting.Start_Time_vod__c.date();
         en=meeting.End_Time_vod__c.date();
         a=st.daysBetween(en);

        if(a==0)
        {
            this.dates = meeting.Start_Time_vod__c.format('dd-MM-YYYY HH:mm',UserInfo.getTimeZone().getID()) 
            + ' - ' + meeting.End_Time_vod__c.format('HH:mm z',UserInfo.getTimeZone().getID());
        }
        else
        { 
            this.dates =meeting.Start_Time_vod__c.format('dd-MM-YYYY HH:mm',UserInfo.getTimeZone().getID()) 
            + ' - ' + meeting.End_Time_vod__c.format('dd-MM-YYYY HH:mm z',UserInfo.getTimeZone().getID());
       }
        
           //PM0 3488 For displaying Time duration    
        day = Integer.valueOf((meeting.End_Time_vod__c.getTime() - meeting.Start_Time_vod__c.getTime())/(1000*60*60*24));  
       	hour = Integer.valueOf((meeting.End_Time_vod__c.getTime() - meeting.Start_Time_vod__c.getTime())/(1000*60*60)) - (day * 24);
       	min = Integer.valueOf((meeting.End_Time_vod__c.getTime() - meeting.Start_Time_vod__c.getTime())/(1000*60)) - (day * 24 * 60) - (hour * 60);
        system.debug('time_duration'+day);
        if(day>0){
            if(day==1)
            {
                days=day+' '+ system.label.AGN_AMI_Day ;
            }
            else
            {
                days=day+' '+ system.label.AGN_AMI_Event_Banner_Days;
                
            }
            
        }
          
        if(hour>0)
        {
            
            if(hour==1)
            {
                
                hours=hour+' '+system.label.AGN_AMI_hr;
            }
            
            else{
                hours=hour+' '+system.label.AGN_AMI_Event_Banner_Hours;
                
            }                
            
        }
        if(min>0)
        {
            if(min==1){
                
                
                mins = min + ' '+system.label.AGN_AMI_sinMin; 
            }
            else
            {
                
                mins = min +' '+system.label.AGN_AMI_Event_Banner_Min;
            }
            
        }
        
        total_time=((days!=null)?days:'')+' '+((hours!=null)?hours:'') + ' ' +((mins!=null)?mins:'') ;
        
        
      

    
    }
    
}