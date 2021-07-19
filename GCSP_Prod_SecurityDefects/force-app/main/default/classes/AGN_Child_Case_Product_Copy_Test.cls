@isTest
Public class AGN_Child_Case_Product_Copy_Test{

        static testmethod void copy_product(){
        User thisuer=[select Id from user where id=:UserInfo.getUserId()];
        system.runAs(thisuer){
            Test.startTest();
            //Account Acc=[select Id from Account limit 1];
            Product_vod__c prod= new Product_vod__c (Name='Test Prod');
            insert prod;
            Case parentCase=new Case(); 
            insert parentCase;
            Case_Product_List_AGN__c parentCaseproduct=new Case_Product_List_AGN__c(Case_AGN__c=parentCase.id,Product_AGN__c=prod.id); 
            insert parentCaseproduct;
            system.debug('@@@parentcase@@@'+parentCaseproduct.Case_AGN__c);
            Case Childcase=new Case(parentId=parentcase.id);
            insert Childcase;
            //Case_Product_List_AGN__c childCaseproduct=new Case_Product_List_AGN__c(Case_AGN__c=Childcase.id);
            //insert childCaseproduct;
            //system.debug('###testchildcase###'+childCaseproduct.Case_AGN__c);
            
            AGN_Child_Case_Product_Copy.futureChildCopy(parentCase.id); 
            
           // system.assertEquals(Acc.id,childcase.id);
            //system.debug('%%%childcaseproduct%%%'+updatedcaseprodList);
            //system.assertequals(Childcase.id,updatedcaseprodList[0].Case_AGN__c);
            
            Test.stopTest();
            List<Case_Product_List_AGN__c> updatedcaseprodList=[select Case_AGN__c,Product_AGN__c from Case_Product_List_AGN__c where Case_AGN__c=:Childcase.id];
            system.assertEquals(1,updatedcaseprodList.size());
        }
    }

}