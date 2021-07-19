/*
Type Name: AGN_ProductWrapper
28-07-2016 - SG - Initial Version
Reason: Wrapper class to enable selection of product on new Case.
*/
public class AGN_ProductWrapper {
	
	public Product_vod__c product {get;set;}
	public boolean selected {get;set;}
	
	public AGN_ProductWrapper(Product_vod__c prod){
		this.product = prod;
		this.selected = false;
	}
	
	public class SetConWrapper implements Iterator<list<AGN_ProductWrapper>>{

	    public integer i {get;set;}
	    public integer pagesize {get;set;}
	    public integer resultsize {get;set;}
	    public integer pagenumber {get;set;}
	    public list<AGN_ProductWrapper> innerList{get;set;}
	    public list<AGN_ProductWrapper> requestedList{get;set;}
	    	   
	           
	    public SetConWrapper(list<AGN_ProductWrapper> sobjectList)
	    {
	        i = 0;
	        pagesize = 5;
	        pageNumber = 0;       
	        innerList = sobjectList;
	        resultsize = innerList.size();
	        requestedList = new list<AGN_ProductWrapper>();            
	    }
	    
	    public boolean hasprevious(){
	      if (i <= pageSize) return false;
	      else return true;
	    }
	    
	    public boolean hasnext(){
	        if (i >= innerList.size()) return false;
	        else return true;
	    }
	    
	    public list<AGN_ProductWrapper> previous(){
	              
	       requestedList = new list<AGN_ProductWrapper>(); 
	       pagenumber--;
	       integer size = innerList.size(); 
	       if(i == size)
	       {
	           if(math.mod(size, pageSize) > 0)
	           {    
	               i = size - math.mod(size, pageSize);
	           }
	           else
	           {
	               i = (size - pageSize);
	           } 
	       }
	       else
	       {
	           i = (i - pageSize);
	       }
	             
	       for(integer start = (i - pageSize); start < i; ++start)
	       {
	           requestedList.add(innerList[start]);
	       }
	                  
	       return requestedList;
	   }   
	    
	    public list<AGN_ProductWrapper> next(){ 
	              
	       requestedList = new list<AGN_ProductWrapper>();
	       pagenumber++; 
	       integer startNumber;
	       integer size = innerList.size();
	       if(hasNext())
	       {  
	           if(size <= (i + pageSize))
	           {
	               startNumber = i;
	               i = size;
	           }
	           else
	           {
	               i = (i + pageSize);
	               startNumber = (i - pageSize);
	           }
	           
	           for(integer start = startNumber; start < i; start++)
	           {
	               requestedList.add(innerList[start]);
	           }
	       } 
	       return requestedList;
	   } 
       
	}
    
}