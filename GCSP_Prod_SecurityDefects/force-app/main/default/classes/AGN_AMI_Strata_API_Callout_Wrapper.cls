public class AGN_AMI_Strata_API_Callout_Wrapper{
  
      public String veevaId;
      public String survey_rating;
  
   /** Public List<Strata_Options> strata_Options ;
    
    public class Strata_Options {
        public String veevaId;  //2233
        public String survey_rating;   
    }*/
    
    
    public static List<AGN_AMI_Strata_API_Callout_Wrapper> parse(String json){
        return (List<AGN_AMI_Strata_API_Callout_Wrapper>) System.JSON.deserialize(json, List<AGN_AMI_Strata_API_Callout_Wrapper>.class);
    }

    /** static testMethod void testParse() {
        String json=        '[{"veevaId":"2233","survey.rating":3},{"veevaId":"0011j00000q1VbLAAU","survey.rating":5},{"veevaId":"1234","survey.rating":3}]';
        fromJSON obj = parse(json);
        System.assert(obj != null);
    }*/
}