public class AGN_BC_Header_Footer{

    public String lang{ get; set; }
   
    public AGN_BC_Header_Footer()
     {
              
         //String urlid=ApexPages.currentPage().getParameters().get('ID');
         Contract_Exhibit__c ce=new Contract_Exhibit__c();
         ce=[select Language_code_AGN__c from Contract_Exhibit__c where id=:ApexPages.currentPage().getParameters().get('ID')]; //NM CC
         lang=ce.Language_code_AGN__c;
         
         /*BC_Languages_AGN__c bcl=new BC_Languages_AGN__c();
       
        String contractlang,templang;
        boolean isWhitespace = urllang.containsWhitespace();
        if(isWhitespace)
          {
            templang=urllang.deleteWhitespace();
            contractlang  = templang.substring(0, templang.indexOf('('));
          }
        else
        {
            contractlang =urllang;
        }
         bcl= [select Code_AGN__c,Languages_AGN__c from BC_Languages_AGN__c where Languages_AGN__c=:contractlang];
         lang=bcl.Code_AGN__c;*/
     }
  

}