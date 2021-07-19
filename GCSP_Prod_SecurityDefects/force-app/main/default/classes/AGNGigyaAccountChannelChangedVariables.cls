public class AGNGigyaAccountChannelChangedVariables {
 public AGNGigyaAccountChannelChangedVariables(List<AGNGigyaAccountChannelChangedVariables> varList){

    }
    public AGNGigyaAccountChannelChangedVariables(){

    }
    @InvocableVariable(label='accountId' required=true)
    public Id accountId;

    @InvocableVariable(label='Is email based' required=true)
    public Boolean isEmailBased;

    @InvocableVariable(label='Old Channel' required=false)
    public String oldChannel;

    @InvocableVariable(label='New Channel' required=false)
    public String newChannel;
}