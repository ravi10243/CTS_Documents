public class AGN_Case_Survey_Header_Footer{
    
    public String lang{ get; set; }
    
    public AGN_Case_Survey_Header_Footer()
    {
        String urlid=ApexPages.currentPage().getParameters().get('ID');
        List<Case> cs=new List<Case>();
        cs=[select Case_Survey_Language_AGN__c from Case where id=:urlid];
        if(!cs.isEmpty())
        {
            lang=cs[0].Case_Survey_Language_AGN__c;
        }
        else
        {
            lang = 'en_US';
        }
    }
}