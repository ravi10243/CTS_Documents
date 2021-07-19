public class AGN_ICL_JsonApex {
    
    public class Names {
        public String fr;
        public String ja;
        public String ru;
        public String de;
        public String en;
        public String es;
    }
    
    public class Continent {
        public String code;
        public Integer geoname_id;
        public Names names;
    }
    
    public class Maxmind {
        public Integer queries_remaining;
    }
    
    public Continent continent;
    public Country country;
    public Maxmind maxmind;
    public Country registered_country;
    public Traits traits;
    
    public class Country {
        public Boolean is_in_european_union;
        public String iso_code;
        public Integer geoname_id;
        public Names names;
    }
    
    public class Traits {
        public String ip_address;
    }
    
    
    public static AGN_ICL_JsonApex parse(String json) {
        return (AGN_ICL_JsonApex) System.JSON.deserialize(json, AGN_ICL_JsonApex.class);
    }
}