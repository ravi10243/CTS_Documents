public class AGN_Alert_User_Action_Update{

       public static void AlertUser_Insert( ID alrtID, String alrtCC, String alrtBU )
       {
           List<User> Aler_Grp_User = new List<User>();
           List<Alert_User_Action_vod__c> Alert_User = new List<Alert_User_Action_vod__c>(); 
           
           Aler_Grp_User = [SELECT Id, Country_Code__c, IsActive, Alert_BU_Group_AGN__c FROM User
                               WHERE Country_Code__c = :alrtCC AND IsActive = True 
                               AND Alert_BU_Group_AGN__c = :alrtBU];
           
           if (Aler_Grp_User.size()!=0) {
               for (User loopUser : Aler_Grp_User) {
               
                    Alert_User_Action_vod__c alUser = new Alert_User_Action_vod__c();
                    //AG CC(16-17)
                    if (Schema.sObjectType.Alert_User_Action_vod__c.fields.Alert_vod__c.isCreateable()){
                        alUser.Alert_vod__c = alrtId;
                        }
                    if (Schema.sObjectType.Alert_User_Action_vod__c.fields.User_vod__c.isCreateable()){
                        alUser.User_vod__c = loopUser.Id;
                        }
                    
                    Alert_User.add(alUser);
                  }
                  //AG CC
                  if(Alert_User_Action_vod__c.sObjectType.getDescribe().isCreateable()){
                    insert Alert_User;
                    }
              }
       
       }
       
       
       public static void AlertUser_Delete( ID alrtID, String alrtBU )
       {
               
            List<Alert_User_Action_vod__c> Alert_User_del = new List<Alert_User_Action_vod__c>();
            Alert_User_del = [Select User_vod__c From Alert_User_Action_vod__c WHERE 
                                    Alert_vod__c =:alrtId AND 
                                    User_vod__r.Alert_BU_Group_AGN__c = : alrtBU];
                    //AG CC(36)
                    if (Alert_User_Action_vod__c.sObjectType.getDescribe().isDeletable() && Alert_User_del.size()!=0) {
                       delete Alert_User_del;
                    }
       
       
       }

}