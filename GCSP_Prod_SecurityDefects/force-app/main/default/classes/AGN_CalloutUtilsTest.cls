@isTest
public class AGN_CalloutUtilsTest {
    
    @isTest 
    public static void testExecutionCalloutsUtilsSuccess(){
        
        AGN_CalloutUtils callout = new AGN_CalloutUtils();
        Test.setMock(HttpCalloutMock.class, new AGN_CalloutUtilsMock());
        
        Map<String,List<String>> parameters = new Map<String,List<String>>();
        Map<String,String> headers = new Map<String,String>();
        
        parameters.put('parameter', new List<String>{'','','',''});                
        headers.put('header', 'header');
        
        callout
            .endPoint('http://www.salesforce.com')        	      
            .method('POST')            
            .addHeader('Content-Type','application/json')
            .addParameter('parameter1','')
            .addParameter(parameters)
            .addHeader('header1','valueHeader')
            .addHeader(headers)
            .body('body')
            .bodyToJson('')
            .timeout(10000);
        
        System.Test.startTest();
        callout.send();
        System.Test.stopTest();
        
    }
    
    @isTest 
    public static void testExecutionCalloutsMethodNotFound(){
        
        AGN_CalloutUtils callout = new AGN_CalloutUtils();
        Test.setMock(HttpCalloutMock.class, new AGN_CalloutUtilsMock());
        
        Map<String,List<String>> parameters = new Map<String,List<String>>();
        Map<String,String> headers = new Map<String,String>();
        
        parameters.put('parameter', new List<String>{'','','',''});                
        headers.put('header', 'header');
        
        System.Test.startTest();
        Try{
            callout
                .endPoint('http://www.salesforce.com')        	                  
                .addHeader('Content-Type','application/json')
                .addParameter('parameter1','')
                .addParameter(parameters)
                .addHeader('header1','valueHeader')
                .addHeader(headers)
                .body('body')
                .bodyToJson('')
                .timeout(10000);
            
            callout.send();
        }catch(Exception e){
            System.assert(e.getMessage().contains('Method not found'));
        }
        
        System.Test.stopTest();
        
    }
    
    @isTest 
    public static void testExecutionCalloutsEndPointNotFound(){
        
        AGN_CalloutUtils callout = new AGN_CalloutUtils();
        Test.setMock(HttpCalloutMock.class, new AGN_CalloutUtilsMock());
        
        Map<String,List<String>> parameters = new Map<String,List<String>>();
        Map<String,String> headers = new Map<String,String>();
        
        parameters.put('parameter', new List<String>{'','','',''});                
        headers.put('header', 'header');
        
        System.Test.startTest();
        Try{
            callout
                .method('POST')
                .addHeader('Content-Type','application/json')
                .addParameter('parameter1','')
                .addParameter(parameters)
                .addHeader('header1','valueHeader')
                .addHeader(headers)
                .body('body')
                .bodyToJson('')
                .timeout(10000);
            
            callout.send();
        }catch(Exception e){
            System.assert(e.getMessage().contains('Endpoint not found!'));
        }
        
        System.Test.stopTest();
        
    }
    
    @isTest 
    public static void testExecutionCalloutsTimeOutExceeded(){
        
        AGN_CalloutUtils callout = new AGN_CalloutUtils();
        Test.setMock(HttpCalloutMock.class, new AGN_CalloutUtilsMock());
        
        Map<String,List<String>> parameters = new Map<String,List<String>>();
        Map<String,String> headers = new Map<String,String>();
        
        parameters.put('parameter', new List<String>{'','','',''});                
        headers.put('header', 'header');
        
        System.Test.startTest();
        Try{
            callout
                .endPoint('http://www.salesforce.com')
                .method('POST')
                .addHeader('Content-Type','application/json')
                .addParameter('parameter1','')
                .addParameter(parameters)
                .addHeader('header1','valueHeader')
                .addHeader(headers)
                .body('body')
                .bodyToJson('')
                .timeout(150000);
            
            callout.send();
        }catch(Exception e){
            System.assert(e.getMessage().contains('Timeout maximum exceeded!'));
        }
        
        System.Test.stopTest();
    }
}