global class AGN_CoolNet_MarketingWrapper implements Comparable
{
    public boolean isFolder {get; set;}
    public String folderName {get; set;}
    public string contentType{get;set;}
    public Id folderId {get; set;} 
    public Id parentId {get; set;}
    public Decimal postion {get; set;}
    public List<Marketing_Link_AGN__c> lstLinks {get;set;}
    global Integer compareTo(Object obj)
    { 
        if(((AGN_CoolNet_MarketingWrapper)obj).postion<this.postion)
            return 1;
        else
            return -1;
    }
    public AGN_CoolNet_MarketingWrapper(boolean isFolder,String folderName,Id folderId,Id parentId, Decimal postion,string contentType)
    {

        this.isFolder=isFolder;
        this.folderName=folderName;
        this.folderId=folderId;
        this.parentId=parentId;
        this.postion=postion;
        this.contentType=contentType;

    }
    
    public AGN_CoolNet_MarketingWrapper(boolean isFolder,String folderName,Id folderId,Id parentId, Decimal postion,string contentType,List<Marketing_Link_AGN__c> lstLinks)
    {

        this.isFolder=isFolder;
        this.folderName=folderName;
        this.folderId=folderId;
        this.parentId=parentId;
        this.postion=postion;
        this.contentType=contentType;
        this.lstLinks=lstLinks;
        
    }
    
    /*public AGN_CoolNet_MarketingWrapper(String contentName,Id contentId,List<Marketing_Link_AGN__c> contentLinkList,Id parentId,Decimal postion,string contentType)
    {
        isFolder=false;
        this.contentName=contentName;
        this.contentType=contentType;
        this.contentId=contentId;
        this.parentId=parentId;
        this.contentLinkList=contentLinkList;
        this.postion=postion;
    }*/
    /*public AGN_CoolNet_MarketingWrapper(String contentName,Id contentId,Id parentId,Decimal postion,string contentType)
    {
        isFolder=false;
        this.contentName=contentName;
        this.contentId=contentId;
        this.parentId=parentId;
        this.postion=postion;
        this.contentType=contentType;
    }*/
    
}