/* Created during Allergan Core Veeva Application Release R14
 * Requirement ID: PMO # 1786
 * Use: Used to create automated DCRs (Data_Change_Request_vod__c records) for Deletion of 
 *      Affiliation (Child_Account_vod__c records) and Inactivation of addresses
 * The method checkDelete() is called from the Visualforce page AGN_DeleteChildAccountDCR which is used to override
 * the Delete method of Child_Account_vod__c object.
 * The method inActiveDCR() is called from the Inactivate Address button in Address_vod__c layouts
*/


global class AGN_Delete_ChildAccount_Controller {
   Child_Account_vod__c childAccRec = new Child_Account_vod__c();
   String ReqType = 'Child_Account_vod';
    
   public AGN_Delete_ChildAccount_Controller(ApexPages.Standardcontroller std)
   {
      childAccRec = (Child_Account_vod__c)std.getRecord();
   }
    
   public PageReference checkDelete()
   {
       String dcrID;
      System.debug('## childAccRec: '+ childAccRec);
      if ([select Primary_vod__c from Child_Account_vod__c where Id =: childAccRec.Id LIMIT 1].Primary_vod__c == System.Label.Common_No_vod)
      {
          System.debug('## inside IF');
          dcrID = deleteDCR();
          return new PageReference('/' + dcrID).setRedirect(true);
      }
      else
      {
          System.debug('## inside ELSE');
          return null;
      }
   }

    public String deleteDCR(){
        String dcrID;
        String recTypeID = [select Id from RecordType where Name =: ReqType and SobjectType = 'Data_Change_Request_vod__c' AND IsActive = true LIMIT 1].Id;
        Data_Change_Request_vod__c dcr = new Data_Change_Request_vod__c();
        dcr.Status_vod__c = 'Submitted_vod';
        dcr.DCR_Status_AGN__c = 'Saved';
        dcr.Type_vod__c = 'Delete_vod';
        dcr.RecordTypeId = recTypeID;
        dcr.Child_Account_vod__c = childAccRec.Id;
        if(ReqType.equalsIgnoreCase('Child_Account_vod')){
            dcr.Account_vod__c = [select Child_Account_vod__c from Child_Account_vod__c where Id =: childAccRec.Id LIMIT 1].Child_Account_vod__c;
        }
        insert dcr;
        system.debug('DCR Acc= '+ dcr.Account_vod__c);
        system.debug('Child Acc= '+ dcr.Child_Account_vod__c);
        dcrID = dcr.Id;
        createDCRLine(dcrID);
        system.debug('dcr= '+ dcr);
        system.debug('dcrID= '+ dcrID);
        return dcrID;
    }
    
    public void createDCRLine(String dcrID){
        Data_Change_Request_Line_vod__c dcrLine = new Data_Change_Request_Line_vod__c();
        dcrLine.Field_Name_vod__c = 'Id';
        dcrLine.New_Value_vod__c = childAccRec.Id;
        dcrLine.Field_API_Name_vod__c = 'Id';
        dcrLine.Data_Change_Request_vod__c = dcrID;
        insert dcrLine;
        system.debug('dcrLine= '+ dcrLine);
    } 
    
    webservice static String inActiveDCR(String ReqstType,String ReqID){
        String dcrID;
        String recTypeID = [select Id from RecordType where Name =: ReqstType and SobjectType = 'Data_Change_Request_vod__c' AND IsActive = true LIMIT 1].Id;
        Data_Change_Request_vod__c dcr = new Data_Change_Request_vod__c();
        dcr.Status_vod__c = 'Submitted_vod';
        dcr.DCR_Status_AGN__c = 'Saved';
        dcr.Type_vod__c = 'Edit_vod';
        dcr.RecordTypeId = recTypeID;
        dcr.Address_vod__c = ReqID;
        if(ReqstType.equalsIgnoreCase('Address_vod') && String.isNotBlank(ReqID)){
            dcr.Account_vod__c = [select Account_vod__c from Address_vod__c where id =: ReqID].Account_vod__c;
        }
        insert dcr;
        dcrID = dcr.Id;
        createInactiveDCRLine(dcrID);
        system.debug('dcr= '+ dcr);
        system.debug('dcrID= '+ dcrID);
        return dcrID;
    }
    public static void createInactiveDCRLine(String dcrID){
        Data_Change_Request_Line_vod__c dcrLine = new Data_Change_Request_Line_vod__c();
        dcrLine.Field_Name_vod__c = 'Inactive_vod';
        dcrLine.New_Value_vod__c = String.valueOf(true);
        dcrLine.Field_API_Name_vod__c = 'Inactive_vod__c';
        dcrLine.Data_Change_Request_vod__c = dcrID;
        insert dcrLine;
        system.debug('dcrLine= '+ dcrLine);
    } 
    
}