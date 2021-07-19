/*
Type Name: AGN_Child_Case_Product_Copy
Reason: Utility class to copy products from parent case into child. Invoked from process builder, for individual case records.
*/

public class AGN_Child_Case_Product_Copy {

     
    @InvocableMethod
	public static void copyProductList(list<Case> parentCase){
         
         futureChildCopy(parentCase[0].id);
    }
     
    @future
   	public static void futureChildCopy(ID parId){
		//get latest created child case record
		list<Case> childCaseList = [select id from Case where parentid =: parId order by createdDate desc];
                         
        list<Case_Product_List_AGN__c > proListtoInser =new List<Case_Product_List_AGN__c >();
        //get all prouducts from parent case
        for(Case_Product_List_AGN__c p : [select id,Name,Case_AGN__c,Product_AGN__c,Quantity_AGN__c,SAP_Product_List_AGN__c  from Case_Product_List_AGN__c  where Case_AGN__c = :parId]){
            Case_Product_List_AGN__c cpl = new Case_Product_List_AGN__c();
            cpl.Case_AGN__c =  childCaseList[0].id ;        
            cpl.Product_AGN__c=p.Product_AGN__c;             
            cpl.Quantity_AGN__c=p.Quantity_AGN__c;
            
            cpl.SAP_Product_List_AGN__c=p.SAP_Product_List_AGN__c;
                
            proListtoInser.add(cpl);
        }         
        
        insert proListtoInser;       
	}

}