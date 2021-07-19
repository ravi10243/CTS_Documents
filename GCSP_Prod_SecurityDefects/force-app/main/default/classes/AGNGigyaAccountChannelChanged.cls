/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* Class used in Account Updated process builder.
*/

public class AGNGigyaAccountChannelChanged {

	@InvocableMethod(label='Channel changed' description='This method sends the updates on Gigya')
	public static void run(List<AGNGigyaAccountChannelChangedVariables> vars) {
		if(AGNGigyaRESTHelper.environmentEnabled() == false) return;

		Database.executebatch(new AGNGigyaAccountChannelChangedBatch(vars), 10);
	}
}