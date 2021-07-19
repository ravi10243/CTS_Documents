global class AGN_AMI_CPD_Curr_Wrapper implements Comparable{
    public String Id {get; set;}
    public Integer sequence {get; set;}
    public String currName {get; set;}
    public String currDesc {get; set;}
    public String imageURL {get; set;}
    public Map<String, List<AMI_Learning_AGN__c>> currTree {get; set;}
    public Integer moduleCount {get; set;}
    
    // Added as part of CPD Tracking Enhancement
    public Map<String, ProgramWrapper> programTree {get; set;}
	public Map<Integer, String> programOrder {get; set;}    
    public AGN_AMI_CPD_Curr_Wrapper() {
        
    }
    global Integer compareTo(Object objToCompare) {
    	return Integer.valueOf(sequence - ((AGN_AMI_CPD_Curr_Wrapper)objToCompare).sequence);
    }
      	
    // Added as part of CPD Tracking Enhancement
    public class ProgramWrapper {
        public String name {get; set;}
        public String id {get; set;}
        public boolean isCompleted {get; set;}
        public integer sequence {get; set;}
        public List<AGN_AMI_CPD_Module_Wrapper> modules {get; set;}
        
        public ProgramWrapper(String name, List<AGN_AMI_CPD_Module_Wrapper> modules) {
            this.name = name;
            modules.sort();
            this.modules = modules;
            this.isCompleted = true;
            for(AGN_AMI_CPD_Module_Wrapper module : modules) {
                if(!module.isCompleted) {
                    this.isCompleted = false;
                    break;
                }
            }
        }
    }
    
}