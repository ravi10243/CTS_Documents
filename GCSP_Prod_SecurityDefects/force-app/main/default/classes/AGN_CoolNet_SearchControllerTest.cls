@isTest(SeeAllData=false)
public class AGN_CoolNet_SearchControllerTest {
static string userCountry;
static Marketing_Content_AGN__c obj5;

     static void CreateData(){
         ////userCountry=[select Country_Code_AGN__c from user where id=:UserInfo.getUserId() Limit 1].Country_Code_AGN__c;
         userCountry=[select Country_Code__c from user where id=:UserInfo.getUserId() Limit 1].Country_Code__c;
         ////Country_AGN__c objcn=new  Country_AGN__c ();
         Country_vod__c objcn=new  Country_vod__c(); //Added by Arijit
         objcn.Country_Name_vod__c=userCountry;
         insert objcn;
         
         Recordtype rtMain=[select id from Recordtype where sobjecttype='Marketing_Folder_AGN__c' and developername ='Main_Folder_AGN'];
         Recordtype rtSub=[select id from Recordtype where sobjecttype='Marketing_Folder_AGN__c' and developername ='Sub_Folder_AGN'];
         
         Marketing_Data_AGN__c obj1=new Marketing_Data_AGN__c();

         obj1.Category_AGN__c='Internal Marketing';
         obj1.Marketing_Position_AGN__c=1;
         obj1.Name='Resource Center';
         insert obj1;
         
         
         Marketing_Folder_AGN__c obj2=new Marketing_Folder_AGN__c();

         obj2.recordtypeid=rtMain.Id;
         obj2.Marketing_Data_AGN__c=obj1.Id;
         obj2.Status_AGN__c='Active';
         obj2.Folder_Position_AGN__c=1;
         obj2.Name='WEBSITE CONTENT';
         obj2.Country_AGN__c=objcn.Id;
         insert obj2;
         
         
         Marketing_Folder_AGN__c obj3=new Marketing_Folder_AGN__c();

         obj3.recordtypeid=rtSub.Id;
         obj3.Parent_Folder_AGN__c=obj2.Id;
         obj3.Status_AGN__c='Active';
         obj3.Folder_Position_AGN__c=2;
         obj3.Name='WEBSITE CONTENT1';
         obj3.Country_AGN__c=objcn.Id;
         insert obj3;

         Marketing_Folder_AGN__c obj4=new Marketing_Folder_AGN__c();

         obj4.recordtypeid=rtSub.Id;
         obj4.Parent_Folder_AGN__c=obj3.Id;
         obj4.Status_AGN__c='Active';
         obj4.Folder_Position_AGN__c=3;
         obj4.Name='CONTENT MODULES';
         obj4.Country_AGN__c=objcn.Id;
         insert obj4;
         
         obj5=new Marketing_Content_AGN__c();

         obj5.Marketing_Folder_AGN__c=obj4.Id;
         obj5.Content_Type_AGN__c=' JPEG';
         obj5.Content_Position_AGN__c=1;
         obj5.Name='Lorem Ipsum';
         obj5.Country_AGN__c=objcn.Id;
         insert obj5;
         
         Marketing_Link_AGN__c obj6=new Marketing_Link_AGN__c();

         obj6.Marketing_Content_AGN__c=obj5.Id;
         obj6.Content_Type_AGN__c=' JPEG';
         obj6.Is_Digital_Asset_AGN__c=false;
         obj6.Name='Lorem Ipsum';
         obj6.Is_Primary_Link_AGN__c=true;
         obj6.File_Link_AGN__c='http://www.gstatic.com/webp/gallery/1.jpg';
         insert obj6;
         
     }
         
     static testMethod void TestMain() {

         CreateData();
         
         PageReference pageRef = Page.AGN_CoolNet_Search;

        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('SelSearch', 'Lorem Ipsum');
    
        AGN_CoolNet_SearchController objTest= new AGN_CoolNet_SearchController();
         
         objTest.contId=obj5.id;
         PageReference url1=objTest.contUrl();
         
         
         
         System.assertNotEquals(objTest.dataCount,0);
        
         System.assertNotEquals(objTest.contLink,null);

     }

}