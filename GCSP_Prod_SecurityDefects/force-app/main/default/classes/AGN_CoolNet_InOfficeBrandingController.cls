public class AGN_CoolNet_InOfficeBrandingController
{
    public List<Marketing_Folder_AGN__c> topFolders {get; set;}
    public Id topSelectedFolder {get; set;}
    public Id topSelectedFolder1 {get; set;}
    public Id topSelectedFolder2 {get; set;}
    public Id topSelectedFolder3 {get; set;}
    public Id topSelectedFolder4{get; set;}
    public Id currentFolderId {get; set;} 
    List<Marketing_Link_AGN__c> allLink;
    public string contId{get;set;}
    public string contentId{get;set;}
    public string contLink{get;set;}
    public string Content_Type{get;set;}
    public string nameCont{get;set;}
    public boolean isDigitalAsset{get;set;}
    public List<Marketing_Folder_AGN__c> allFolder{get;set;}
    public Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>> folderMap {get; set;}
    public Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>> folderMap1 {get; set;}
    public Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>> folderMap2 {get; set;}
    public Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>> folderMap3 {get; set;}
    public boolean folderMapIsBlank { get { return folderMap.isEmpty()?true:false; }}
    public boolean folderMapIsBlank1 { get { return folderMap1.isEmpty()?true:false; }}
    public boolean folderMapIsBlank2 { get { return folderMap2.isEmpty()?true:false; }}
    public boolean folderMapIsBlank3 { get { return folderMap3.isEmpty()?true:false; }}
    Id dataId;
    List<AGN_CoolNet_MarketingWrapper> allWrapper;
    List<AGN_CoolNet_MarketingWrapper> mainFolderWrapper;
    public string contL{get;set;}
    string userCountry;
    Map<String,List<Marketing_Link_AGN__c>> mapContentToLinks;
    
    public AGN_CoolNet_InOfficeBrandingController()
    {
        Content_Type='';
        //userCountry=[select Country_Code_AGN__c from user where id=:UserInfo.getUserId() Limit 1].Country_Code_AGN__c; //Blocked by Arijit
        
        //Commented by Avijit, reason : MEA Rollout
        //userCountry=[select Country_Code__c from user where id=:UserInfo.getUserId() Limit 1].Country_Code__c;
        //string userCountry;
        userCountry = AGN_CoolNetUtils.getUserCountryCode(); //Added by Avijit, reason : MEA Rollout
        contL='Loading';
        allWrapper = new List<AGN_CoolNet_MarketingWrapper>();
        mainFolderWrapper = new List<AGN_CoolNet_MarketingWrapper>();
        topFolders=new List<Marketing_Folder_AGN__c>();
        //dataId = 'a3h3B000000E85H';
        dataId=[select Id 
                from Marketing_Data_AGN__c 
                where Category_AGN__c='Internal Marketing' 
                and Name='In-Office Branding' 
                Limit 1].Id;
        folderMap= new Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>>();
        folderMap1= new Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>>();
        folderMap2= new Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>>();
        folderMap3= new Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>>();
        
        getLinkData();  
        gettingTopFolder();
        //gettingFolderMap();
        //system.debug(folderMap);
    }
    public void gettingTopFolder()
    {
        /*allFolder = [Select Country_AGN__c,Country_AGN__r.Country_Name__c,Id,name,Parent_Folder_AGN__r.id,Folder_Position_AGN__c,Marketing_Data_AGN__r.id,RecordTypeId,Parent_Folder_AGN__r.RecordTypeId,(SELECT Id FROM Attachments LIMIT 1)
from Marketing_Folder_AGN__c where Status_AGN__c='Active' order by Folder_Position_AGN__c asc];*/ //Blocked by Arijit- Country Dependency
        
        //Added by Arijit
        allFolder = [Select Country_AGN__c,Country_AGN__r.Alpha_2_Code_vod__c,Id,name,Parent_Folder_AGN__r.id,Folder_Position_AGN__c,Marketing_Data_AGN__r.id,RecordTypeId,Parent_Folder_AGN__r.RecordTypeId,(SELECT Id FROM Attachments LIMIT 1)
                     from Marketing_Folder_AGN__c where Status_AGN__c='Active' order by Folder_Position_AGN__c asc];
        
        RecordType rtMain=[select Id from RecordType where sobjecttype='Marketing_Folder_AGN__c' and developerName='Main_Folder_AGN' Limit 1];
        for(Marketing_Folder_AGN__c mf :allFolder)
        {
            if(mf.Marketing_Data_AGN__c==dataId && mf.RecordTypeId==rtMain.Id)
                topFolders.add(mf);
            /*else if(mf.Parent_Folder_AGN__r.RecordTypeId==rtMain.Id && userCountry==mf.Country_AGN__r.Country_Name__c)
mainFolderWrapper.add(new AGN_CoolNet_MarketingWrapper(true,mf.name,mf.Id,mf.Parent_Folder_AGN__c,mf.Folder_Position_AGN__c,'')); */ //Blocked by Arijit- Country Dependency
            //Added by Arijit-
            else if(mf.Parent_Folder_AGN__r.RecordTypeId==rtMain.Id && userCountry==mf.Country_AGN__r.Alpha_2_Code_vod__c)
                mainFolderWrapper.add(new AGN_CoolNet_MarketingWrapper(true,mf.name,mf.Id,mf.Parent_Folder_AGN__c,mf.Folder_Position_AGN__c,''));
            /*else if(userCountry==mf.Country_AGN__r.Country_Name__c)
allWrapper.add(new AGN_CoolNet_MarketingWrapper(true,mf.name,mf.Id,mf.Parent_Folder_AGN__c,mf.Folder_Position_AGN__c,''));*/ //Blocked by Arijit- Country Dependency
            //Added by Arijit-
            else if(userCountry==mf.Country_AGN__r.Alpha_2_Code_vod__c)
                allWrapper.add(new AGN_CoolNet_MarketingWrapper(true,mf.name,mf.Id,mf.Parent_Folder_AGN__c,mf.Folder_Position_AGN__c,''));
        }
        /*topFolders = [Select name,id,
Folder_Position_AGN__c
from Marketing_Folder_AGN__c 
where Marketing_Data_AGN__c =: dataId
and recordTypeId = '0123B0000001KvhQAE'
order by Folder_Position_AGN__c asc];*/
        
        topSelectedFolder=topFolders.size()>0?topFolders.get(0).id:null;
        topSelectedFolder1=topFolders.size()>1?topFolders.get(1).id:null;
        topSelectedFolder2=topFolders.size()>2?topFolders.get(2).id:null;
        topSelectedFolder3=topFolders.size()>3?topFolders.get(3).id:null;
        gettingFolderMap(topSelectedFolder,topSelectedFolder1,topSelectedFolder2,topSelectedFolder3);
    }
    public void gettingFolderMap(Id topSelFolder,
                                 Id topSelFolder1, 
                                 Id topSelFolder2,
                                 Id topSelFolder3)
    {
        /*List<Marketing_Content_AGN__c> allContent = [Select Id,Content_Type_AGN__c,name,Marketing_Folder_AGN__r.id,Content_Position_AGN__c
from Marketing_Content_AGN__c where Country_AGN__r.Country_Name__c=:userCountry 
order by Content_Position_AGN__c asc];*/ //Blocked by Arijit- Country Dependency
        
        //Added by Arijit-
        List<Marketing_Content_AGN__c> allContent = [Select Id,Content_Type_AGN__c,name,Marketing_Folder_AGN__r.id,Content_Position_AGN__c
                                                     from Marketing_Content_AGN__c where Country_AGN__r.Alpha_2_Code_vod__c=:userCountry 
                                                     order by Content_Position_AGN__c asc];                                           
        /*allLink = [Select Content_Type_AGN__c,name,Marketing_Content_AGN__r.id,Marketing_Content_AGN__r.Name,Is_Digital_Asset_AGN__c,File_Link_AGN__c
from Marketing_Link_AGN__c ];
List<AGN_CoolNet_MarketingWrapper> allWrapper = new List<AGN_CoolNet_MarketingWrapper>();

for(Marketing_Folder_AGN__c mf : allFolder)
allWrapper.add(new AGN_CoolNet_MarketingWrapper(true,mf.name,mf.Id,mf.Parent_Folder_AGN__c,mf.Folder_Position_AGN__c,''));*/
        for(Marketing_Content_AGN__c mc: allContent)
        {
            /* List<Marketing_Link_AGN__c> linkList = new List<Marketing_Link_AGN__c>();
for(Marketing_Link_AGN__c ml : allLink)
{
if(ml.Marketing_Content_AGN__c==mc.id)
linkList.add(ml);
}*/
            allWrapper.add(new AGN_CoolNet_MarketingWrapper(false,
                                                            mc.name,
                                                            mc.Id,
                                                            //linkList,
                                                            mc.Marketing_Folder_AGN__c,
                                                            mc.Content_Position_AGN__c,
                                                            mc.Content_Type_AGN__c,mapContentToLinks.get(mc.Id)
                                                           ));
            /*allWrapper.add(new AGN_CoolNet_MarketingWrapper(false,
mc.name,
mc.Id,
//linkList,
mc.Marketing_Folder_AGN__c,
mc.Content_Position_AGN__c,
mc.Content_Type_AGN__c
));
*/
        }
        putInsideMap(folderMap,topSelFolder,allFolder,allWrapper,mainFolderWrapper);
        putInsideMap(folderMap1,topSelFolder1,allFolder,allWrapper,mainFolderWrapper);
        putInsideMap(folderMap2,topSelFolder2,allFolder,allWrapper,mainFolderWrapper);
        putInsideMap(folderMap3,topSelFolder3,allFolder,allWrapper,mainFolderWrapper);
        /* for(Marketing_Folder_AGN__c mf : allFolder)
{
Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>> mwLV1 = new Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>();
if(mf.Parent_Folder_AGN__r.id==topSelectedFolder)
{
System.debug('In if1');
for(AGN_CoolNet_MarketingWrapper mw1 : allWrapper)
{
Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>> mwLV2 = new Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>();
if(mw1.parentId==mf.id)
{
for(AGN_CoolNet_MarketingWrapper mw2 : allWrapper)
{                            
if(mw2.parentId==mw1.folderId)
{   
List<AGN_CoolNet_MarketingWrapper> mwLV3 = new List<AGN_CoolNet_MarketingWrapper>();
for(AGN_CoolNet_MarketingWrapper mw3 : allWrapper)
{                            
if(mw3.parentId==mw2.folderId)
{                                
mwLV3.add(mw3);
}
}
mwLV2.put(mw2,mwLV3);
}
}
mwLV1.put(mw1, mwLV2);
}
}
system.debug(mf);
folderMap.put(mf,mwLV1);
}            
}*/
        system.debug(folderMap);
    }
    public void putInsideMap(Map<AGN_CoolNet_MarketingWrapper,
                             Map<AGN_CoolNet_MarketingWrapper,
                             Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>> genfolderMap,
                             Id genTopSelFolder,List<Marketing_Folder_AGN__c> allFolder,
                             List<AGN_CoolNet_MarketingWrapper> allWrapper,List<AGN_CoolNet_MarketingWrapper> mainFolderWrapper)
    {
        Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>> mwLV1;
        Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>> mwLV2;
        Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>> mwLV3;
        List<AGN_CoolNet_MarketingWrapper> mwLV4;
        for(AGN_CoolNet_MarketingWrapper mf : mainFolderWrapper)
        {
            mwLV1 = new Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>>();
            if(mf.parentId==genTopSelFolder)
            {
                
                for(AGN_CoolNet_MarketingWrapper mw1 : allWrapper)
                {
                    mwLV2 = new Map<AGN_CoolNet_MarketingWrapper,Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>>();
                    if(mw1.parentId==mf.folderId)
                    {
                        for(AGN_CoolNet_MarketingWrapper mw2 : allWrapper)
                        {      
                            mwLV3 =new Map<AGN_CoolNet_MarketingWrapper,List<AGN_CoolNet_MarketingWrapper>>();                     
                            if(mw2.parentId==mw1.folderId)
                            {
                                for(AGN_CoolNet_MarketingWrapper mw3 : allWrapper)
                                {  
                                    mwLV4 = new List<AGN_CoolNet_MarketingWrapper>();
                                    if(mw3.parentId==mw2.folderId)
                                    {   
                                        for(AGN_CoolNet_MarketingWrapper mw4 : allWrapper)
                                        {                            
                                            if(mw4.parentId==mw3.folderId)
                                            {                              
                                                mwLV4.add(mw4);
                                            }
                                        }
                                        mwLV3.put(mw3,mwLV4);
                                    }
                                    
                                }
                                mwLV2.put(mw2,mwLV3);
                            }
                        }
                        
                        mwLV1.put(mw1, mwLV2);
                    }
                }
                system.debug(mf);
                genfolderMap.put(mf,mwLV1);
                
                system.debug('genfolderMap'+genfolderMap);
            }            
        }
    } 
    public PageReference contUrl()
    {
        contLink='';
        nameCont='';
        isDigitalAsset=false;
        allLink = [Select Is_Primary_Link_AGN__c,Content_Type_AGN__c,name,Marketing_Content_AGN__r.id,Marketing_Content_AGN__r.Name,Is_Digital_Asset_AGN__c,File_Link_AGN__c
                   from Marketing_Link_AGN__c where Is_Primary_Link_AGN__c=true];
        for(Marketing_Link_AGN__c ml: allLink)
        {
            if(String.Valueof(ml.Marketing_Content_AGN__r.id)==contId)
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
    
    public PageReference contUrlSecondary()
    {
        
        contLink='';
        nameCont='';
        isDigitalAsset=false;
        
        if(contId!=null){  
            allLink = [Select Is_Primary_Link_AGN__c,Content_Type_AGN__c,name,Marketing_Content_AGN__r.id,Marketing_Content_AGN__r.Name,Is_Digital_Asset_AGN__c,File_Link_AGN__c
                       from Marketing_Link_AGN__c where Id=:contId];
            if(allLink!=null && allLink.size()>0)
            {
                contLink=allLink[0].Content_Type_AGN__c=='PDF'?allLink[0].File_Link_AGN__c+'#toolbar=0&scrollbar=0':allLink[0].File_Link_AGN__c;
                nameCont=allLink[0].Marketing_Content_AGN__r.Name+' ('+allLink[0].Name+')';
                isDigitalAsset=allLink[0].Is_Digital_Asset_AGN__c;
                Content_Type=allLink[0].Content_Type_AGN__c;
            }
            
        }
        system.debug('contLink'+contId);
        return null;
    }  
    public PageReference contLinkget()
    {
        contL='';
        List<Marketing_Link_AGN__c> lstMLA=new List<Marketing_Link_AGN__c>();
        lstMLA = [Select Content_Type_AGN__c,
                  File_Link_AGN__c
                  from Marketing_Link_AGN__c 
                  where Marketing_Content_AGN__r.id=:contentId and Is_Primary_Link_AGN__c=true Limit 1];
        contL=lstMLA.size()>0?
            lstMLA.get(0).Content_Type_AGN__c=='PDF'?
            lstMLA.get(0).File_Link_AGN__c+'#toolbar=0&scrollbar=0':
        lstMLA.get(0).File_Link_AGN__c:
        '';
        Content_Type=lstMLA.get(0).Content_Type_AGN__c;
        system.debug('contLink'+contL);
        return null;
    } 
    public void getLinkData()
    {
        
        mapContentToLinks=new Map<String,List<Marketing_Link_AGN__c>>();
        Marketing_Link_AGN__c objTemp;
        String prevId='';
        List<Marketing_Link_AGN__c> tempList=new List<Marketing_Link_AGN__c>();
        /*List<Marketing_Link_AGN__c > lstLink = [Select Is_Primary_Link_AGN__c,Content_Type_AGN__c,name,Marketing_Content_AGN__c,
Marketing_Content_AGN__r.id,Marketing_Content_AGN__r.Name,Is_Digital_Asset_AGN__c,
File_Link_AGN__c
from Marketing_Link_AGN__c where Marketing_Content_AGN__r.Country_AGN__r.Country_Name__c=:userCountry  order by Marketing_Content_AGN__r.id];*/ //Blocked by Arijit-
        //Added by Arijit
        List<Marketing_Link_AGN__c > lstLink = [Select Is_Primary_Link_AGN__c,Content_Type_AGN__c,name,Marketing_Content_AGN__c,
                                                Marketing_Content_AGN__r.id,Marketing_Content_AGN__r.Name,Is_Digital_Asset_AGN__c,
                                                File_Link_AGN__c
                                                from Marketing_Link_AGN__c where Marketing_Content_AGN__r.Country_AGN__r.Alpha_2_Code_vod__c=:userCountry  order by Marketing_Content_AGN__r.id];
        for(Marketing_Link_AGN__c ml : lstLink )
        {
            if(!ml.Is_Primary_Link_AGN__c){
                objTemp=new Marketing_Link_AGN__c();
                objTemp.File_Link_AGN__c=ml.Content_Type_AGN__c=='PDF'?ml.File_Link_AGN__c+'#toolbar=0&scrollbar=0':ml.File_Link_AGN__c;
                objTemp.Name=ml.Name;
                objTemp.Id=ml.Id;
                objTemp.Is_Digital_Asset_AGN__c=ml.Is_Digital_Asset_AGN__c;
                
                if(prevId!='' && prevId!=ml.Marketing_Content_AGN__c){
                    mapContentToLinks.put(prevId,tempList);
                    
                    tempList=new List<Marketing_Link_AGN__c>();
                }
                tempList.add(objTemp);
                prevId=ml.Marketing_Content_AGN__c;
            }
            
        }
        mapContentToLinks.put(prevId,tempList);
        
    } 
}