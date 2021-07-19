public class AGN_Sample_Limit_creation_Redirection {

    public AGN_Sample_Limit_creation_Redirection(ApexPages.StandardController controller) { 
    }

    Public pagereference NewRedirection(){
        pagereference page= null;
        Profile P1 = [Select id,name from Profile where id=:UserInfo.getProfileId()];
        if( P1.name=='System Administrator')
        {
            page =new PageReference('/'+Sample_Limit_vod__c.SobjectType.getDescribe().getKeyPrefix()+'/e');
            page.getParameters().put('nooverride', '1');
            
        }
    return page;
    }
}