// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_Custom_Error_Page
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public class AGN_AMI_SC_Custom_Error_Controller {
    //Variable Declaration
        public String failingPageResponse { get; set; }

        public PageReference yourPageLevelAction()
       {
          failingPageResponse = Site.getErrorDescription();
          return null;
        }//yourPageLevelAction

}