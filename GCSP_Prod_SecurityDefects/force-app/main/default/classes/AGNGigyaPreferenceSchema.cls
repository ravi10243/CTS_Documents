/**
 * --------------
 * Allergan GDPR
 * March 2018
 * --------------
 * This class represents a Gigya Preference Schema object.
 */

public class AGNGigyaPreferenceSchema {
    public String description, type, preferenceId;
    public Decimal currentDocVersion;
    public Boolean required;

    public AGNGigyaPreferenceSchema(){
    }

    public AGNGigyaPreferenceSchema(String preferenceId, String description) {
        this.preferenceId = preferenceId;
        this.description = description;
        this.type = 'consent';
        this.required = false;
        this.currentDocVersion = 1.0;
    }
}