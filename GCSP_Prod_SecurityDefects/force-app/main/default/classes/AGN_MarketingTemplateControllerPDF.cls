public class AGN_MarketingTemplateControllerPDF {

    // public MAP<string, string> params{get;set;}
    public string params {get;set;}
    
     public AGN_MarketingTemplateControllerPDF ()
     {
        
        //MAP<string, string> params = ApexPages.currentPage().getParameters().get('pdfdata');
        params = ApexPages.currentPage().getParameters().get('pdfdata');
        system.debug('sujoy_PDF '+params );
        
    
     }
     
     public String getHTMLContent(){
        return params;
     }
    
}