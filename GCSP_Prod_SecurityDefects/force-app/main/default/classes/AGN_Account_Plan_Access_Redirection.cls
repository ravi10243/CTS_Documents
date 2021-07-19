Public Class AGN_Account_Plan_Access_Redirection 
{
   
    Public String PlanId {get;set;}
    Public String extRecordtypeId {get;set;}
    public String PlanRecordtypeId;
    public PageReference page;
    List<String> User_Access_Record_type_list;
    public AGN_Account_Plan_Access_Redirection(ApexPages.StandardController controller)
    {
        page = ApexPages.currentPage();
        PlanId = controller.getrecord().Id;
        Account_Plan_vod__c Plan_record = (Account_Plan_vod__c)controller.getRecord();
        PlanRecordtypeId = Plan_record.RecordTypeId;
        extRecordtypeId = Plan_record.RecordTypeId;
        List<RecordTypeInfo> All_Acc_Plan_recordtype_List = Account_Plan_vod__c.SObjectType.getDescribe().getRecordTypeInfos();
        User_Access_Record_type_list = new List<String>();
        for(RecordTypeInfo rti : All_Acc_Plan_recordtype_List)
        {
            if(rti.isAvailable())
            {
                User_Access_Record_type_list.add(rti.getRecordTypeId());
                System.debug('Available: '+rti.getRecordTypeId());
            }
        }
    }

    Public PageReference AccessCheck()
    {
        PageReference result = null;
        if(User_Access_Record_type_list.contains(PlanRecordtypeId))
        {
            System.debug('Done');
            result = new PageReference('/'+PlanId);
            result.getParameters().put('nooverride', '1');
            result.setRedirect(true);
        }
        return result;
    }
    
     Public PageReference EditRedirection()
    {
        PageReference result = null;
        Map<String, String> params  =  page.getParameters(); 
        String retURL_val = params.get('retURL');
        if(User_Access_Record_type_list.contains(PlanRecordtypeId))
        {
                result = new PageReference('/'+PlanId+'/e?retURL='+retURL_val);
                result.getParameters().put('nooverride', '1');
                result.setRedirect(true);
        }
        return result;
    }
}