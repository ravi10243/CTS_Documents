public class AGN_CustomMetadataInfo {
  private String developerName , label , objectName;
  private Map<String , Object> fieldValueMap;
    public AGN_CustomMetadataInfo() {
        this.fieldValueMap = new Map<String , Object>();
    } 
    
    
    public Map<String , Object> mapFieldValue(){
        return this.fieldValueMap;
    }
    public String ObjectName(){
        return this.objectName;
    }
    public String DeveloperName(){
        return this.developerName;
    }
    public String Label(){
        return this.label;
    }
    public void setFieldValueMap(Map<String , Object> mapValue){
        this.fieldValueMap = mapValue;
    }
    public void setDeveloperName(String value){
        this.developerName = value;
    }
    
    public void setLabel(String value){
        this.Label = value;
    }
    
    public void setObjectName(String value){
        this.objectName = value;
    }
}