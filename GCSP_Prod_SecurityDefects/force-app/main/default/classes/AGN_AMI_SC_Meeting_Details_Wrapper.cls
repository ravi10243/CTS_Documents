//This is the Wrapper class that is AGN_AMI_SC_All_Event_Controller,AGN_AMI_SC_Event_Detail_Controller,AGN_AMI_SC_My_Event_Controller to generate a customisted 
//list of details for each Events
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public class AGN_AMI_SC_Meeting_Details_Wrapper {
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
    
    public AGN_AMI_SC_Meeting_Details_Wrapper(Medical_Event_vod__c meeting, boolean registered,String facultyName)
    {
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
        this.dates = meeting.Start_Time_vod__c.format('dd-MM-YYYY HH:mm',UserInfo.getTimeZone().getID()) + ' - ' + meeting.End_Time_vod__c.format('dd-MM-YYYY HH:mm',UserInfo.getTimeZone().getID());
    }
    
}