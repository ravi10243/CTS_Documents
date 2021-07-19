public class AGN_CoolNet_SearchController {
    public string selvalue{get;set;}
    string srchval;
    public List<Marketing_Content_AGN__c> lstContent{get;set;}
    public integer dataCount{get;set;}
    public string contId{get;set;}
    public string contLink{get;set;}
    public string Content_Type{get;set;}
    public string nameCont{get;set;}
    public boolean isDigitalAsset{get;set;}
    public List<Marketing_Link_AGN__c> allLink{get;set;}
    public Map<String,String> ContentToFullPath {get;set;}
    string userCountry;
    List<Marketing_Folder_AGN__c> lstMarketingFolder;
    public Map<String,Marketing_Folder_AGN__c> mapIdToFolder {get;set;}
    public Map<String,String> mapFoldertoParentData {get;set;}
    
    public AGN_CoolNet_SearchController()
    {
        
        ////userCountry=[select Country_Code_AGN__c from user where id=:UserInfo.getUserId() Limit 1].Country_Code_AGN__c;
        //userCountry=[select Country_Code__c from user where id=:UserInfo.getUserId() Limit 1].Country_Code__c; //Commented by Avijit, reason : MEA Rollout
        userCountry = AGN_CoolNetUtils.getUserCountryCode(); //Added by Avijit, reason : MEA Rollout
        Content_Type='';
        lstContent=new List<Marketing_Content_AGN__c>();
        allLink=new List<Marketing_Link_AGN__c>();
        selvalue = ApexPages.currentPage().getParameters().get('SelSearch');
        if(selvalue!='')
        {
            srchval = '%'+ selvalue + '%';  
            /*List<List<sobject>> searchLst=[Find :srchval
                                           in all Fields returning
                                           Marketing_Content_AGN__c(Id,Name,Content_Type_AGN__c,Marketing_Folder_AGN__c)];*/
            /*lstContent  = [Select Name,Content_Type_AGN__c,Marketing_Folder_AGN__c from Marketing_Content_AGN__c where name like :srchval  and Country_AGN__r.Country_Name__c=:userCountry];*/ //Blocked by Arijit-Country Dependency
            //Added by Arijit
            lstContent  = [Select Name,Content_Type_AGN__c,Marketing_Folder_AGN__c from Marketing_Content_AGN__c where name like :srchval  and Country_AGN__r.Country_Name_vod__c=:userCountry];
            /*for(Marketing_Content_AGN__c a:(List <Marketing_Content_AGN__c>)searchLst[0])
            {
                lstContent.add(a);   
            }*/
        }
        else
        {
            /*lstContent=[Select Name,Content_Type_AGN__c,Marketing_Folder_AGN__c from Marketing_Content_AGN__c where Country_AGN__r.Country_Name__c=:userCountry];*/ //Blocked by Arijit-Country
            //Added by Arijit
            lstContent=[Select Name,Content_Type_AGN__c,Marketing_Folder_AGN__c from Marketing_Content_AGN__c where Country_AGN__r.Country_Name_vod__c=:userCountry];
        }
        dataCount=lstContent.size();
        GetFullPath();

      
    }
    public String GetPath(Marketing_Content_AGN__c  objContent){
        String ContentPath='' ;
        
        if(mapIdToFolder.containskey(objContent.Marketing_Folder_AGN__c)){
        ContentPath=GetParent(mapIdToFolder.get(objContent.Marketing_Folder_AGN__c));
        }
    
        return ContentPath;
    }
    
     public String GetParent(Marketing_Folder_AGN__c objFolder){
        String ParentPath='' ;
        
        /*
        if(objFolder.Parent_Folder_AGN__c==null && objFolder.Marketing_Data_AGN__c!=null){
            if(mapFoldertoParentData.containsKey(String.Valueof(objFolder.Id))){
                ParentPath=mapFoldertoParentData.get(String.Valueof(objFolder.Id));
            }
        }else{
            ParentPath=objFolder.Name+' : '+GetParent(mapIdToFolder.get(objFolder.Parent_Folder_AGN__c));
        }
    */
      
        if(mapIdToFolder.containsKey(String.Valueof(objFolder.Parent_Folder_AGN__c))){
                ParentPath=GetParent(mapIdToFolder.get(objFolder.Parent_Folder_AGN__c))+' > '+objFolder.Name;
                
            
        }else{
            ParentPath=mapFoldertoParentData.get(String.Valueof(objFolder.Parent_Folder_AGN__c))+' > '+objFolder.Name;
           
        }
    
        return ParentPath;
    }
    
    public void GetFullPath(){
    
        Set<String> setContentIds=new Set<String>();
        ContentToFullPath =new Map<String,String>();
        String FullPath='';
        mapFoldertoParentData =new Map<String,String>();
        mapIdToFolder =new Map<String,Marketing_Folder_AGN__c >();
        for(Marketing_Content_AGN__c temp : lstContent){
            setContentIds.add(temp.Marketing_Folder_AGN__c);
        }
        
        /*lstMarketingFolder=[select Name,Parent_Folder_AGN__c,Marketing_Data_AGN__c from Marketing_Folder_AGN__c where Country_AGN__r.Country_Name__c=:userCountry and Parent_Folder_AGN__c!=null ];*/ //Blocked by Arijit-Country
        //Added by Arijit
        lstMarketingFolder=[select Name,Parent_Folder_AGN__c,Marketing_Data_AGN__c from Marketing_Folder_AGN__c where Country_AGN__r.Country_Name_vod__c=:userCountry and Parent_Folder_AGN__c!=null ];
        
        if(lstMarketingFolder !=null && lstMarketingFolder.size()>0){
           for(Marketing_Folder_AGN__c temp: lstMarketingFolder ){
               
               mapIdToFolder .put(String.valueof(temp.ID),temp);
           }
        }
        /*lstMarketingFolder=[select Name,Parent_Folder_AGN__c,Marketing_Data_AGN__r.name,Marketing_Data_AGN__r.Marketing_Position_AGN__c from Marketing_Folder_AGN__c where Marketing_Data_AGN__c!=null and Country_AGN__r.Country_Name__c=:userCountry ];*/ //Blocked by Arijit-Country
        //Added by Arijit
        lstMarketingFolder=[select Name,Parent_Folder_AGN__c,Marketing_Data_AGN__r.name,Marketing_Data_AGN__r.Marketing_Position_AGN__c from Marketing_Folder_AGN__c where Marketing_Data_AGN__c!=null and Country_AGN__r.Country_Name_vod__c=:userCountry ];
        
        system.debug('sujoy mapIdToFolder  '+mapIdToFolder );
        if(lstMarketingFolder !=null && lstMarketingFolder.size()>0){
           for(Marketing_Folder_AGN__c temp: lstMarketingFolder ){
               
               mapFoldertoParentData.put(String.valueof(temp.ID),'STEP '+temp.Marketing_Data_AGN__r.Marketing_Position_AGN__c+' > '+temp.Marketing_Data_AGN__r.name+' > '+temp.name);
           }
        }
        system.debug('sujoy mapFoldertoParentData '+mapFoldertoParentData);
         for(Marketing_Content_AGN__c temp : lstContent){
                FullPath='';
                FullPath= GetPath(temp);   
                ContentToFullPath.put(temp.id,FullPath);
                
            }
           
    }
    public PageReference contUrl()
    {
        contLink='';
        nameCont='';
        isDigitalAsset=false;
        allLink = [Select Content_Type_AGN__c,name,Marketing_Content_AGN__r.id,Is_Primary_Link_AGN__c,Marketing_Content_AGN__r.Name,Is_Digital_Asset_AGN__c,File_Link_AGN__c
                   from Marketing_Link_AGN__c ];
        for(Marketing_Link_AGN__c ml: allLink)
        {
            if(String.Valueof(ml.Marketing_Content_AGN__r.id)==contId  && ml.Is_Primary_Link_AGN__c==true)
            {
                contLink=ml.Content_Type_AGN__c=='PDF'?ml.File_Link_AGN__c+'#toolbar=0&scrollbar=0':ml.File_Link_AGN__c;
                nameCont=ml.Marketing_Content_AGN__r.Name;
                isDigitalAsset=ml.Is_Digital_Asset_AGN__c;
                Content_Type=ml.Content_Type_AGN__c;
            }
        }
        system.debug('contLink'+contId);
        return null;
    } 
}