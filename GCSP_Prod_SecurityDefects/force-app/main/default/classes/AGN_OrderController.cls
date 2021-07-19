public  class AGN_OrderController
{
        public Id orderrId{get;set;}
        public string name{get;set;}
        public Order_Line_vod__c addsumrecord {get;set;}
        public List<Order_Line_vod__c> OrderLi{get;set;}
        public Decimal quantitysum {get;set;}
        public Decimal netamountsum {get;set;}
        public Decimal totalpricesum {get;set;}
        public Decimal totaldiscount {get;set;}
        public String countryCode {get;set;}
    
    
    public  List<Order_vod__c> getORDERSLIST()
    {
        List<Order_vod__c> ORDERSLIST ;
        
        ORDERSLIST = [SELECT Account_vod__r.Name,Wholesaler_vod__r.Name,Delivery_Preference_AGN__c,Account_vod__r.RecordType.name,Account_vod__r.External_ID4_AGN__c,
                      Billing_Contact_vod__c,Billing_Address_Line_1_vod__c,Billing_Address_Line_2_vod__c,Ship_To_Address_vod__r.Name,Notes_vod__c,Order_Date_vod__c,
                      Order_Total_Quantity_vod__c,Order_List_Amount_vod__c,Order_Total_Discount_vod__c,Order_Net_Amount_vod__c,Delivery_Date_vod__c,Billing_Address_AGN__c,
                      Ship_To_Address_AGN__c,Delivery_Preference_End_Time_AGN__c,Delivery_Preference_Start_Time_AGN__c,Form_Of_Payment_AGN__c,CreatedBy.Name,CreatedDate,Account_vod__r.phone,Account_vod__r.personemail,Account_vod__r.fax,Account_vod__r.Email_Internal_AGN__c  FROM Order_vod__c WHERE Id=: orderrId ];
            
        return ORDERSLIST;
       
    }
    
    public  List<Order_Line_vod__c> getORDERLINES()
    {
        List<Order_Line_vod__c> ORDERLINES ;
        addsumrecord= new Order_Line_vod__c();
        
        ORDERLINES= [SELECT Product_vod__r.Name,Product_vod__r.Country_Code__c,Description_AGN__c,Total_Price_AGN__c,Final_Net_Price_vod__c,Quantity_vod__c,List_Price_Rule_vod__c,Line_Discount_vod__c,Free_Goods_vod__c,Free_Goods_Override_AGN__c,List_Amount_vod__c,Total_Discount_AGN__c,
                     Net_Price_vod__c,Net_Amount_vod__c,Rule_vod__c,Product_Identifier_AGN__c,Final_Net_Price_Rule_vod__c,Customer_Price_KR_AGN__c,Discount_Amount_AGN__c  FROM Order_Line_vod__c WHERE Order_vod__r.Id=: orderrId];
       
        if(ORDERLINES.size()>0)
        {
        countryCode = ORDERLINES[0].Product_vod__r.Country_Code__c;
        AGN_Order();
       // ORDERLINES.add(addsumrecord);
        }
        
        return ORDERLINES;
        
    }
    
    public  void AGN_Order()
    {
    
        List<Order_Line_vod__c> OrderLi= new List<Order_Line_vod__c> ([select Quantity_vod__c,Total_Price_AGN__c,List_Price_Rule_vod__c,Total_Discount_AGN__c,Net_Amount_vod__c,Customer_Price_KR_AGN__c,Final_Net_Price_Rule_vod__c  FROM Order_Line_vod__c WHERE Order_vod__r.Id=: orderrId]);
        quantitysum=0;
        netamountsum=0;
        totalpricesum=0;
        totaldiscount=0;
        
        for(Order_Line_vod__c orderq : OrderLi)
            {
                Decimal  sumquantity=orderq.Quantity_vod__c;
                Decimal  sumnetamount=orderq.Net_Amount_vod__c;
                Decimal  sumcustomerprice=orderq.Customer_Price_KR_AGN__c;
                quantitysum=quantitysum+ sumquantity;
                netamountsum=netamountsum+ sumnetamount;
                totalpricesum=totalpricesum+ orderq.Total_Price_AGN__c;
                totaldiscount=totaldiscount+ orderq.Total_Discount_AGN__c;

            } 
            system.debug('value of totaldiscount '+totaldiscount);
            addsumrecord.Quantity_vod__c=quantitysum;
            addsumrecord.Net_Amount_vod__c=netamountsum;
            //addsumrecord.Customer_Price_KR_AGN__c=customerpricesum;
    }
    
    
}