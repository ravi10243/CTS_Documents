public class AGN_AMI_Custom_Error_Controller {
        //Variable Declaration
        public String failingPageResponse { get; set; }

        public PageReference yourPageLevelAction()
       {
          failingPageResponse = Site.getErrorDescription();
          return null;
        }//yourPageLevelAction
    }//