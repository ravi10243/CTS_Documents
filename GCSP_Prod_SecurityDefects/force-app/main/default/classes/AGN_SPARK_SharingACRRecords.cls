/**
 *
 * @Class Name: AGN_SPARK_SharingACRRecords
 * @Created Date: 
 * @Description: Class to set apex sharing for Allergan Customer Registration record for the community user 
 * @Author: 
 * @History     :  
 */
public class AGN_SPARK_SharingACRRecords {
    
    /*
    *  Method to set public access for community user 
    */
	public static boolean setACRAccessForUser(Id recordId, Id userId){
        
		Allergan_Customer_Registration_AGN__Share cReg  = new Allergan_Customer_Registration_AGN__Share();
        cReg.ParentId = recordId;
		cReg.UserOrGroupId = userId;
		cReg.AccessLevel = 'All';
		cReg.RowCause = Schema.Allergan_Customer_Registration_AGN__Share.RowCause.Manual;
        Database.SaveResult sr = Database.insert(cReg,false);
        if(sr.isSuccess()){
			return true;
		}else {
		 Database.Error err = sr.getErrors()[0];
		 if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
			err.getMessage().contains('AccessLevel')){
				return true;
			}else{
				return false;
			}
		}
	}
}