/***************************************************************************
 * @File Name          : AGN_CalloutUtils.cls
 * @Description        : This is the generic class for webservice callout
 * @Author             : Avijit Gorai
 * @Group              : 
 * @Last Modified By   : Avijit Gorai
 * @Last Modified On   : 30/3/2020
 * 
 * @Usage              :
 * 
 * HttpResponse resp;
 * Map<String,String> headers = new Map<String, String>();
 * headers.put('Accept', 'application/json');
 * headers.put('Content-Type', 'application/json');
 * AGN_CalloutUtils callout = new AGN_CalloutUtils();
 *       
 *   callout
 *       .endPoint(endPointUrl)               
 *       .method(methodName)            
 *       .addHeader(headers)
 *       .body(requestBody)    
 *       .timeout(timeout);
 *  try{
 *      //sending request
 *      resp = callout.send();
 *  }
 *  catch(AGN_CalloutUtils.AGN_CalloutUtilsException ex){
 *      throw ex;
 *  }
 * 
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    30/3/2020   AG     Initial Version
 ****************************************************************************/

public class AGN_CalloutUtils {
    public class AGN_CalloutUtilsException extends Exception {}
    
    public HttpRequest request;
    public Http httpInstance;
    public HttpResponse response;       
    
    private String method;
    private String endpoint;
    private String body;
    private Integer timeout;
    private String clientCertificateName;
    private Map<String,String> headers;
    private Map<String,List<String>> parameters;
    
    public AGN_CalloutUtils(){      
        response = new HttpResponse();
        httpInstance = new Http(); 
        headers = new Map<String,String>();
        parameters = new Map<String,List<String>>();
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param endpoint 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils endPoint(String endpoint){
        this.endPoint = endpoint;
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param body 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils body(String body){
        this.body = body;
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param o 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils bodyToJson(Object o){
        this.body = JSON.serialize(o);
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param timeout 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils timeout(Integer timeout){
        this.timeout = timeout;
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param clientCertificateName 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils setClientCertificateName(String clientCertificateName){
        this.clientCertificateName = clientCertificateName;
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param key 
    * @param body 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils addHeader(String key, String body){
        this.headers.put(key,body);
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param method 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils method(String method){
        this.method = method;
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param collectionHeaders 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils addHeader(Map<String,String> collectionHeaders){
        for( String header : collectionHeaders.keySet() ) {                        
            this.headers.put(header,collectionHeaders.get(header));
        }               
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param key 
    * @param value 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils addParameter(String key,String value){
        
        if( parameters.get(key) == null ) {
            parameters.put(key,  new List<String>() );
        }
        
        parameters.get(key).add(value);
        
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param collectionParameters 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils addParameter(Map<String,List<String>> collectionParameters){
        for(String parameter : collectionParameters.keySet() ) {                        
            this.parameters.put(parameter,collectionParameters.get(parameter));
        }               
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @param key 
    * @param values 
    * @return String 
    **/
    public String buildParameter(String key, List<String> values){        
        String parameter = '';
        Integer count = 0;        
        for(String value : values){
            count++;
            parameter += value;
            parameter += (count == values.size()) ? '' : ',';
        }
        return parameter;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @return String 
    **/
    public String buildQueryStringParameter(){
        
        String queryString = this.endpoint;
        
        if(!parameters.isEmpty()){
            queryString  += '?';        
            Integer count = 0;  
            for(String key : parameters.keySet()) {                                                                 
                if(count==0){
                    queryString += key + '=' + buildParameter(key,parameters.get(key));    
                }else{
                    queryString += '&' + key + '=' + buildParameter(key,parameters.get(key));    
                }
                count++;                
            }
        }   
        
        return queryString;
    }
        
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @return AGN_CalloutUtils 
    **/
    public AGN_CalloutUtils builder(){
        if(!String.isNotBlank(this.method) || String.isEmpty(this.method)){
            throw new AGN_CalloutUtilsException('Method not found!');           
        }
        
        if(!String.isNotBlank(this.endpoint) || String.isEmpty(this.endpoint)){
            throw new AGN_CalloutUtilsException('Endpoint not found!');           
        }
        
        if(this.timeout!=null && this.timeout > 120000){
            throw new AGN_CalloutUtilsException('Timeout maximum exceeded!');           
        }
        
        this.request = new HttpRequest();              
        this.request.setEndpoint(this.endpoint);      
        this.request.setMethod(this.method);      
        
        if(this.body!=null){
            this.request.setBody(this.body);
        }
        
        if(this.timeout!=null){
            this.request.setTimeout(this.timeout);
        }
        
        if(!String.isEmpty(this.clientCertificateName)){
            this.request.setClientCertificateName(this.clientCertificateName);
        }
        
        if(!headers.isEmpty()){
            for(String header : headers.keySet()) {                        
                request.setHeader(header, headers.get(header));
            }
        }  
        
        if(!parameters.isEmpty()){
            this.request.setEndpoint(buildQueryStringParameter());
        }
        
        return this;
    }
    
    /**
    * @description 
    * @author AG | 30/3/2020 
    * @return HttpResponse 
    **/
    public HttpResponse send() {               
        
        try {
            this.builder();
            response = httpInstance.send(this.request);
        } catch(AGN_CalloutUtilsException ex) {
            throw new AGN_CalloutUtilsException(ex.getMessage());   
        }
        return response;
    }
}