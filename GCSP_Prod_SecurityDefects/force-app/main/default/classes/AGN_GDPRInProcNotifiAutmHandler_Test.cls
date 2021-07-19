/** 
******************************************************************************
Apex Class Name - AGN_GDPRInProcNotifiAutmHandler_Test
//Version - 1.0
Version - 2.0
Modified Date - Feb 24, 2021
Modified By - SG
Function - Trigger handler for AGN_GDPRInProcNotifiAutm

Modification Log : 
--------------------------------------------------------------------------------

* Developer               Date                 Description
* -------------------     ------------         -----------------------
* SG                    02/24/2021           R2_2021 PMO No:3629 Test scenario added for HCP primary address update based on primary affiliation update.
**********************************************************************************
*/
@isTest
public class AGN_GDPRInProcNotifiAutmHandler_Test {
    
    /* Account acc = new Account();
acc.Name ='testAccount';
acc.GDPR_Notification_Status_AGN__c = 'Direct Mail Failed';
acc.GDPR_Notification_Received_AGN__c = false;
acc.Country_vod__c = cv.Id;
acc.Country_Code__c = 'GB'; 
insert acc; */
    
    /*      Account_Territory_Loader_vod__c atl = new Account_Territory_Loader_vod__c();
atl.Territory_vod__c = ';CEO;';
atl.Account_vod__c = acc.Id;
atl.External_ID_vod__c = acc.Id;
atl.Mobile_ID_vod__c = acc.id;
insert atl; */
    //DPR_InProcNotifiAutmHandler gipnah = new GDPR_InProcNotifiAutmHandler();
    //  GDPR_InProcNotifiAutmHandler.execute();
    //Create Account
    
    /*      boolean flag = true; 
for(account acc: accList){
if(flag){
acc.GDPR_Notification_Status_AGN__c = 'Direct Mail Failed';  
flag = false;  
}

else{
acc.GDPR_Notification_Status_AGN__c = 'In-Person Notification Delivered';  

}
}
update accList; */
    //   accList[1].Country_Code__c = '';
    //  accList[1].GDPR_Notification_Status_AGN__c = 'Direct Mail Failed';
    
    
    
    private static List<Account> testDataCreation(String StatusVod){
        
        Country_vod__c  cv = new Country_vod__c();
        cv.CurrencyIsoCode = 'GBP';
        cv.Name = 'CR';
        insert cv; 
        AGN_GDPRInProcNotifiAutmHelper.getCountryCode(cv.id); 
        AGN_GDPRInProcNotifiAutmHelper.getRoleCustomSetting(cv.id); 
        
        List<Account> accList = new List<Account>();
        
        for(Integer i=0; i<3 ; i++){
            
            Account acc = new Account();
            acc.Name ='testAccount'+i;
            if(i==0)   acc.GDPR_Notification_Status_AGN__c = 'Direct Mail Notification Sent';
            else  acc.GDPR_Notification_Status_AGN__c = 'Direct Mail Failed';
            if(i == 0)  acc.GDPR_Notification_Received_AGN__c = true;
            acc.GDPR_Notification_Received_AGN__c = false;
            acc.Country_vod__c = cv.Id;
            acc.Country_Code__c = 'GB'; 
            accList.add(acc);
        }
        Insert accList;
        
        
        Account_Territory_Loader_vod__c atl2 = new Account_Territory_Loader_vod__c();
        atl2.Territory_vod__c = ';CEO;';
        atl2.Account_vod__c = accList[0].Id;
        atl2.External_ID_vod__c = accList[0].Id;
        atl2.Mobile_ID_vod__c = accList[0].id;
        insert atl2;
        
        
        List<MC_Cycle_vod__c> lstCPlan = new List<MC_Cycle_vod__c>();
        for(Integer i=0;i<2;i++){
            MC_Cycle_vod__c cvp = new MC_Cycle_vod__c();
            cvp.OwnerId = UserInfo.getUserId();
            cvp.Status_vod__c  = 'In_Progress_vod';
            cvp.End_Date_vod__c = System.today()+1;
            cvp.Start_Date_vod__c = System.today();
            //cvp.Territory_vod__c = 'TestTerritory'; 
            lstCPlan.add(cvp);
        }
        insert lstCPlan;
        
        
        List<MC_Cycle_Plan_vod__c> lstMCPlan = new List<MC_Cycle_Plan_vod__c>();
        
        for(Integer i=0;i<2;i++){
            MC_Cycle_Plan_vod__c cvp = new MC_Cycle_Plan_vod__c();
            cvp.OwnerId = UserInfo.getUserId();
            cvp.Status_vod__c  = 'In_Progress_vod';
            //cvp.End_Date_vod__c = System.today();
            //cvp.Start_Date_vod__c = System.today();
            cvp.Cycle_vod__c = lstCPlan.get(i).Id;
            cvp.Territory_vod__c = 'TestTerritory'; 
            lstMCPlan.add(cvp);
        }
        insert lstMCPlan;
        
        //MC_Cycle_Plan_Target_vod__c
        List<MC_Cycle_Plan_Target_vod__c> lstMCPlanT = new List<MC_Cycle_Plan_Target_vod__c>(); 
        
        for(Integer i=0;i<2;i++){
            MC_Cycle_Plan_Target_vod__c cpTag = new MC_Cycle_Plan_Target_vod__c();
            cpTag.Target_vod__c = accList[0].Id;
            cpTag.Status_vod__c =StatusVod;
            cpTag.Cycle_Plan_vod__c = lstMCPlan[i].Id;
            lstMCPlanT.add(cpTag);
        }
        Insert lstMCPlanT;
        
        MC_Cycle_Plan_Target_vod__c cpTag = new MC_Cycle_Plan_Target_vod__c();
        cpTag.Target_vod__c = accList[2].Id;
        cpTag.Status_vod__c ='';
        cpTag.Cycle_Plan_vod__c = lstMCPlan[0].Id;
        insert cpTag;
        
        boolean flag = true; 
        for(account acc: accList){
            if(flag){
                acc.GDPR_Notification_Status_AGN__c = 'Direct Mail Failed';  
                flag = false;  
            }
            
            else{
                acc.GDPR_Notification_Status_AGN__c = 'In-Person Notification Delivered';  
                
            }
        }
        
        return accList;
        
        
    }
  //R2_2021 PMO No:3629 ->HCP primary address update based on primary affiliation update.
    private static List<Account> testDataForHCA(){
        RecordType hospitalRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Hospital_vod'];
        List<Account> lstAccount = new List<Account>();
        for(Integer i = 0; i < 2; i++) {
            Account acc = new Account(
                Name         = 'Name' + i,
                RecordTypeId = hospitalRecordType.Id,
                Target__c    = true
            );
            lstAccount.add(acc);
        }

        insert lstAccount;
        return lstAccount;
       // return null;
    }
     private static List<Address_vod__c> testDataForAddress(List<Account> lstAccount){
        RecordType ComMainRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Address_vod__c' AND DeveloperName = 'CompanyMaintained'];
        List<Address_vod__c> lstAddress = new List<Address_vod__c>();
        for(Integer i = 0; i < 2; i++) {
            Address_vod__c add = new Address_vod__c(
                Name         = 'Test Address' + i,
                RecordTypeId = ComMainRecordType.Id,
                Account_AGN__c = lstAccount[i].id,
                Account_vod__c = lstAccount[i].id,
                Address_line_2_vod__c = 'Add 2'+i,
                Address_Line_3_AGN__c = 'Add 3'+i,
                address_type_vod__c = 'Address',
                City_vod__c = 'City'+i,
                Country_Code__c = 'GB',
                Country_vod__c = 'United Kingdom',
                //Controlled_Address_vod__c = TRUE,
                License_Status_vod__c = 'Valid_vod',
                Primary_vod__c = TRUE,
                Zip_vod__c = '123456'+i
            );
            lstAddress.add(add);
        }

        insert lstAddress;
        return lstAddress;
    }
    private static List<Account> testDataForHCP(List<Account> lstAccount,List<Address_vod__c> lstAddress ){
        List<Account> lstHCP = new List<Account>();
        
        RecordType hcpRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Professional_vod'];       
            
                Account acc = new Account(
                    FirstName             = 'Name' ,
                    LastName              = 'Person Account',
                    RecordTypeId = hcpRecordType.Id,	
                    Primary_Parent_vod__c = lstAccount[0].Id,
                    Target__c             = true
                );
                lstHCP.add(acc);
                insert lstHCP;
        RecordType ComMainRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Address_vod__c' AND DeveloperName = 'CompanyMaintained'];
        List<Address_vod__c> hcpAddress = new List<Address_vod__c>();
        for(Integer i = 0; i < 2; i++) {
            Address_vod__c add = new Address_vod__c(
                Name         = 'Test Address' + i,
                RecordTypeId = ComMainRecordType.Id,
                Account_AGN__c = lstHCP[0].id,
                Account_vod__c = lstHCP[0].id,
                Address_line_2_vod__c = 'Add 2'+i,
                Address_Line_3_AGN__c = 'Add 3'+i,
                address_type_vod__c = 'Address',
                City_vod__c = 'City'+i,
                Country_Code__c = 'GB',
                Country_vod__c = 'United Kingdom',
                Controlled_Address_vod__c = TRUE,
                Controlling_Address_vod__c = lstAddress[i].id,
                License_Status_vod__c = 'Valid_vod',
                Primary_vod__c = TRUE,
                Zip_vod__c = '123456'+i
            );
            hcpAddress.add(add);
        }
        insert hcpAddress;
                return lstHCP;        
    }
    //End of R2_2021 PMO No:3629 
    static testMethod void myTest1(){
        List<Account> lstAcc = testDataCreation('Active_vod');
        List<Account> lstAcc2 = testDataCreation('Merged_vod');
        
        Test.startTest();
        update lstAcc;
        update lstAcc2;
        //R2_2021 PMO No:3629 ->HCP primary address update based on primary affiliation update.
        List<Account> lstAccount = testDataForHCA(); 
        List<Address_vod__c> lstAddress = testDataForAddress(lstAccount);
        List<Account> lstHCP = testDataForHCP(lstAccount,lstAddress);
      
        
        For(Account a:lstHCP){
        a.Primary_Parent_vod__c=lstAccount[1].id;
        
		update a;
         //End of R2_2021 PMO No:3629 
        }
        Test.stopTest();
        
        /*       List<Account> accList = [select Id,name,GDPR_Notification_Status_AGN__c from Account where (not name like '%2') limit 2];
Account acc;
List<Account> accListToUpdate = new List<Account>();
if(!accList.isEmpty() && accList.size()>1){
acc = accList.get(0);
acc.GDPR_Notification_Status_AGN__c = 'Direct Mail Failed';
accListToUpdate.add(acc);

Account accNew = accList.get(1);
accNew.GDPR_Notification_Status_AGN__c = 'In-Person Notification Delivered';
accListToUpdate.add(accNew);

update accListToUpdate;
} */
    }
    static testMethod void myTest2(){
        
        /*       List<Account> accList = [select Id,name,GDPR_Notification_Status_AGN__c from Account where name like '%2' limit 1];
System.assertNotEquals(accList.size(), 0);
List<Account> accListToUpdate = new List<Account>();
if(!accList.isEmpty()){
Account accIns = accList.get(0);
accIns.GDPR_Notification_Status_AGN__c = 'Direct Mail Failed';
accListToUpdate.add(accIns);

update accListToUpdate;
}       */
    }
    static testMethod void myTest3(){
        /*  Country_vod__c  cv = new Country_vod__c();
cv.CurrencyIsoCode = 'GBP';
cv.Name = 'CR';
insert cv; 

Account acc = new Account();
acc.Name ='testAccount';
acc.GDPR_Notification_Status_AGN__c = 'Direct Mail Failed';
acc.GDPR_Notification_Received_AGN__c = false;
acc.Country_vod__c = cv.Id;
acc.Country_Code__c = 'GB'; 
insert acc;

Account_Territory_Loader_vod__c atl = new Account_Territory_Loader_vod__c();
atl.Territory_vod__c = ';CEO;';
atl.Account_vod__c = acc.Id;
atl.External_ID_vod__c = acc.Id;
atl.Mobile_ID_vod__c = acc.id;
insert atl;
//DPR_InProcNotifiAutmHandler gipnah = new GDPR_InProcNotifiAutmHandler();
GDPR_InProcNotifiAutmHandler.execute();  */
    }
    
    
}