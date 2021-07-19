public class AGN_AMI_Static_Labels 
{
    public static String attendeeStatusCancelled = 'Cancelled';
    public static String attendeeStatusInvited = 'Invited';
    public static String attendeeStatusRegistered = 'Registered';
    public static String attendeeStatusAccepted = 'Accepted';
    public static String attendeeStatusAttended = 'Attended';
    public static String attendeeStatusPhysically = 'Physically-Attended_AGN';
    public static String attendeeStatusRemoved = 'Invitation_Removed_AGN';
    public static String meetingStatusLive = 'Live';
    public static String meetingStatusPlanned = 'Planned';
    public static String meetingStatusRecorded = 'Recorded';
    public static String meetingStatusCancelled = 'Cancelled';
    public static String meetingStatusFollowUp = 'Follow Up';
    public static String meetingTypePublic = 'Public';
    public static String meetingTypePrivate = 'Private';
    public static String meetingRecordType = 'AMI_Portal_Event_AGN';
    public static String MCActivityWorkshopRecordType = 'AMI_WR_AGN';
    public static String MCActivityLPRecordType = 'AMI_LP_AGN';
    public static String MCActivityLastLoginRecordType = 'AMI_Last_Login_AGN';
    public static String meetingNotificationEMail = 'AGN_AMI_Meeting_Share_Notification';
    public static String meetingAttendeeRecordtype = 'Portal_Attendee_AGN';
    public static String EJCModuleRecordtype = 'Module_AGN';
    public static String EJCCallRecordtype = 'Call_AGN';
    public static String EJCEventRecordtype = 'Related_Event_AGN';
    public static String EJCSurveyRecordtype = 'Survey_AGN';
    public static String EJCTaskTypePre = 'Pre-task';
    public static String EJASTaskTypePre = 'Pre-task';
    public static String EJASTaskTypePost = 'Post-task';
    public static String workshopTypePublic = 'Public';
    public static String workshopTypePrivate = 'Private';
    public static String meetingStatusPostView = 'Post View';// Strata POC
    public static String meetingStatusPreview = 'Preview';// Strata POC
    
    public static Map<String,String> emailAlertText1 = new Map<String, String>{
        //'GB' => System.Label.AGN_AMI_Meeting_Share_P1,
        'IT' => System.Label.AGN_AMI_Meeting_Share_P1_IT
    };
    public static Map<String,String> emailAlertSubject = new Map<String, String>{
        //'GB' => System.Label.AGN_AMI_Meeting_Share_Subject,
        'IT' => System.Label.AGN_AMI_Meeting_Share_Subject_IT
    };
    public static Map<String,String> emailAlertText2 = new Map<String, String>{
        //'GB' => System.Label.AGN_AMI_Meeting_Share_P2,
        'IT' => System.Label.AGN_AMI_Meeting_Share_P2_IT
    };
    public static Map<String,String> emailAlertText3 = new Map<String, String>{
        //'GB' => System.Label.AGN_AMI_Meeting_Share_P3,
        'IT' => System.Label.AGN_AMI_Meeting_Share_P3_IT
    };
    public static Map<String,String> emailAlertText4 = new Map<String, String>{
        //'GB' => System.Label.AGN_AMI_Meeting_Share_P4,
        'IT' => System.Label.AGN_AMI_Meeting_Share_P4_IT
    };
    public static Map<String,String> alertTitle = new Map<String, String>{
        //'GB' => System.Label.AGN_AMI_Alert_Title,
        'IT' => System.Label.AGN_AMI_Alert_Title_IT
    };
    public static Map<String,String> alertText1 = new Map<String, String>{
        //'GB' => System.Label.AGN_AMI_Alert_Text_1,
        'IT' => System.Label.AGN_AMI_Alert_Text_1_IT
    };
    public static Map<String,String> alertText2 = new Map<String, String>{
        //'GB' => System.Label.AGN_AMI_Alert_Text_2,
        'IT' => System.Label.AGN_AMI_Alert_Text_2_IT
    };
    public static Map<String,String> alertText3 = new Map<String, String>{
        //'GB' => System.Label.AGN_AMI_Alert_Text_3,
        'IT' => System.Label.AGN_AMI_Alert_Text_3_IT
    };
}