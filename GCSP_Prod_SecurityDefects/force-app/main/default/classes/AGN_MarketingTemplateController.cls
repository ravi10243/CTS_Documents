public class AGN_MarketingTemplateController {
    
    public String SelSearch { get; set; }
    public string userId{get;set;}
    public String ContentHTML{get;set;}
    
    
    public String jsonPickListValues {get;set;}
    public String jsonImageValues {get;set;}
    public String jsonChangerValues {get;set;}
    
    public Map<String,List<String>> mapPicklist{get;set;}
    public Map<String,List<String>> mapImage{get;set;}
    public String jsonmapPicklist {get;set;}
    public String jsonmapImage {get;set;}
    
    public Map<String,List<String>> mapChangerText{get;set;}
    public Map<String,List<String>> mapChangerKey{get;set;}
    public String jsonmapChangerText {get;set;}
    public String jsonmapChangerKey {get;set;}
    
    
    public String TemplateId  {get;set;}
    string userCountry;    
      
 
    public AGN_MarketingTemplateController ()
    {
          
          Template_Market_Content_AGN__c objMarketTemplate ;   
          Marketing_Template_AGN__c objCurrentTemplate;       
          ////userCountry=[select Country_Code_AGN__c from user where id=:UserInfo.getUserId() Limit 1].Country_Code_AGN__c;
          userCountry=[select Country_Code__c from user where id=:UserInfo.getUserId() Limit 1].Country_Code__c;
          system.debug('Arijit: ' + userCountry);
          TemplateId  ='';
              
          String strTemplateId = ApexPages.currentPage().getParameters().get('template_name'); 
          if(strTemplateId!=null){
              
              SetPickListNames();
              
              /*List<Template_Market_Content_AGN__c> lstMarketTemplates=[select Content_Market_HTML__c,Marketing_Template_AGN__c from Template_Market_Content_AGN__c where Marketing_Template_AGN__r.name=:strTemplateId and Country_AGN__r.Country_Name__c=:userCountry LIMIT 1 ];*/ //Blocked by Arijit
              //Added by Arijit
              List<Template_Market_Content_AGN__c> lstMarketTemplates=[select Content_Market_HTML__c,Marketing_Template_AGN__c from Template_Market_Content_AGN__c where Marketing_Template_AGN__r.name=:strTemplateId and Country_AGN__r.Country_Name_vod__c=:userCountry LIMIT 1 ]; 
              system.debug('Arijit1: ' + lstMarketTemplates);
              if(lstMarketTemplates!=null && lstMarketTemplates.size()>0){
                 
                 List<Marketing_Template_AGN__c > lstMainTemplates=[select Content_HTML_AGN__c from Marketing_Template_AGN__c where id=:lstMarketTemplates[0].Marketing_Template_AGN__c LIMIT 1];
                 if(lstMainTemplates!=null && lstMainTemplates.size()>0){
                     objCurrentTemplate=lstMainTemplates[0];
                 }
                 ContentHTML=lstMarketTemplates[0].Content_Market_HTML__c ;
                 TemplateId=objCurrentTemplate.Id;              
                                  
              }else{
                  List<Marketing_Template_AGN__c > lstMainTemplates=[select Content_HTML_AGN__c from Marketing_Template_AGN__c where name=:strTemplateId LIMIT 1 ];
                  
                  if(lstMainTemplates!=null && lstMainTemplates.size()>0){
                  
                      objCurrentTemplate=lstMainTemplates[0];
                      ContentHTML=objCurrentTemplate.Content_HTML_AGN__c;
                      TemplateId=objCurrentTemplate.Id;       
                  } 
                                   
              }
                   
                   SetPickListData();
                 
                   SetImageData();
                 
                   SetChangerData();
          }
          system.debug('Sujoy'+ContentHTML);
    }
    
    public void SetPickListData(){
    
        List<String> lstItem=new List<String>() ;
        mapPicklist=new Map<String,List<String>>();
        jsonmapPicklist ='';
          
        if(TemplateId!=''){
              
              String currentVal='';
              List<Template_Dropdown_Data_AGN__c > lstData=[select Instance_AGN__c,Value_AGN__c from Template_Dropdown_Data_AGN__c where Marketing_Template_AGN__c=:TemplateId  order by Instance_AGN__c];
              if(lstData!=null && lstData.size()>0){
                  for(Template_Dropdown_Data_AGN__c  temp : lstData){
                     
                      if(currentVal!='' && currentVal!=temp.Instance_AGN__c){
                          
                          mapPicklist.put(currentVal,lstItem);
                          lstItem=new List<String>();
                          
                      }
                      lstItem.add(temp.Value_AGN__c );
                      currentVal=temp.Instance_AGN__c;
                  }
                  mapPicklist.put(currentVal,lstItem);
                  jsonmapPicklist =JSON.serialize(mapPicklist);
                  system.debug('Abhishek'+jsonmapPicklist);
              }
              
          }    
    }
    
    
   
     public void SetImageData(){
        List<String> lstItem=new List<String>() ;
        mapImage=new Map<String,List<String>>();
        jsonmapImage ='';
        
        if(TemplateId!=''){
              
              String currentVal='';
              List<Template_Image_Data_AGN__c > lstData=[select Instance_AGN__c,Image_Link_AGN__c from Template_Image_Data_AGN__c where Marketing_Template_AGN__c=:TemplateId  order by Instance_AGN__c];
              if(lstData!=null && lstData.size()>0){
                  for(Template_Image_Data_AGN__c  temp : lstData){
                                                                  
                      if(currentVal!='' && currentVal!=temp.Instance_AGN__c){
                          
                          mapImage.put(currentVal,lstItem);
                          lstItem=new List<String>();
                          
                      }
                      lstItem.add(temp.Image_Link_AGN__c );
                      currentVal=temp.Instance_AGN__c;
                  }
                  
                  mapImage.put(currentVal,lstItem);
                  
                  jsonmapImage =JSON.serialize(mapImage);
              }
          }    
    }
    
    
    
    
    
    public void SetChangerData(){
    
        List<String> lstItem=new List<String>() ;
        List<String> lstItem1=new List<String>() ;
        
        mapChangerText=new Map<String,List<String>>();
        mapChangerKey=new Map<String,List<String>>();
        
        jsonmapChangerKey ='';
        jsonmapChangerText='';
        
        if(TemplateId!=''){
              
              String currentVal='';
              List<Template_Text_Changer_AGN__c> lstData=[select Instance_AGN__c,Key_Text_AGN__c,Changer_Text_AGN__c from Template_Text_Changer_AGN__c where Marketing_Template_AGN__c=:TemplateId  order by Instance_AGN__c];
              if(lstData!=null && lstData.size()>0){
                  for(Template_Text_Changer_AGN__c  temp : lstData){
                                                                  
                      if(currentVal!='' && currentVal!=temp.Instance_AGN__c){
                          
                          mapChangerKey.put(currentVal,lstItem);
                          lstItem=new List<String>();
                          
                          mapChangerText.put(currentVal,lstItem1);
                          lstItem1=new List<String>();
                          
                      }
                      lstItem.add(temp.Key_Text_AGN__c );
                      lstItem1.add(temp.Changer_Text_AGN__c );
                      currentVal=temp.Instance_AGN__c;
                  }
                  
                  mapChangerKey.put(currentVal,lstItem);
                  mapChangerText.put(currentVal,lstItem1);
                  
                  jsonmapChangerKey =JSON.serialize(mapChangerKey);
                  jsonmapChangerText =JSON.serialize(mapChangerText);
                  system.debug('Abhishek'+jsonmapChangerKey);
                  system.debug('Abhishek'+jsonmapChangerText);
              }
          }    
    }
    
    
    public void SetPickListNames(){
    
           List<String> lstPicklistItems;
           
           Schema.DescribeFieldResult fieldResult = Template_Dropdown_Data_AGN__c.Instance_AGN__c.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
           lstPicklistItems =new List<String>();
            
           for( Schema.PicklistEntry f : ple)
           {
               lstPicklistItems.add(f.getValue());
           }       
           jsonPickListValues =JSON.serialize(lstPicklistItems);
           
           
           fieldResult = Template_Image_Data_AGN__c.Instance_AGN__c.getDescribe();
           ple = fieldResult.getPicklistValues();
           lstPicklistItems =new List<String>();
            
           for( Schema.PicklistEntry f : ple)
           {
               lstPicklistItems.add(f.getValue());
           }       
           jsonImageValues =JSON.serialize(lstPicklistItems);
           
           
           
           fieldResult = Template_Text_Changer_AGN__c.Instance_AGN__c.getDescribe();
           ple = fieldResult.getPicklistValues();
           lstPicklistItems =new List<String>();
            
           for( Schema.PicklistEntry f : ple)
           {
               lstPicklistItems.add(f.getValue());
           }       
           jsonChangerValues =JSON.serialize(lstPicklistItems);
           system.debug('Abhishek'+jsonChangerValues);
      
    }
}