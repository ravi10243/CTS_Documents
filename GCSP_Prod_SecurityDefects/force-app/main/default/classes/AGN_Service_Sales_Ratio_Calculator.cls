global class AGN_Service_Sales_Ratio_Calculator implements schedulable {

    global void execute(SchedulableContext SC)
    {
        calculateRatio();
    }
    
   Public static String getShortMonth(Integer intMonth){
        String retVal='';
        if(intMonth==1){
             retVal='Jan';
        }
        if(intMonth==2){
             retVal='Feb';
        }
        if(intMonth==3){
             retVal='March';
        }
        if(intMonth==4){
             retVal='April';
        }
        if(intMonth==5){
             retVal='May';
        }
        if(intMonth==6){
             retVal='June';
        }
        if(intMonth==7){
             retVal='July';
        }
        if(intMonth==8){
             retVal='Aug';
        }
        if(intMonth==9){
             retVal='Sep';
        }
        if(intMonth==10){
             retVal='Oct';
        }
        if(intMonth==11){
             retVal='Nov';
        }
        if(intMonth==12){
             retVal='Dec';
        }

        return retVal;
    }
    
    global void calculateRatio()
    {

        //Map<Integer,Integer> data1 = new Map<Integer,Integer>();
        //Map<Integer,Integer> data2 = new Map<Integer,Integer>();
        //Map<String,Decimal> data3 = new Map<String,Decimal>();
        List<Service_Sales_Ratio_AGN__c> ssRatioList1 = new List<Service_Sales_Ratio_AGN__c>();
        List<Service_Sales_Ratio_AGN__c> ssRatioList2 = new List<Service_Sales_Ratio_AGN__c>(); 
        List<Service_Sales_Ratio_AGN__c> ssRatioList3 = new List<Service_Sales_Ratio_AGN__c>();
        List<Service_Sales_Ratio_AGN__c> ssRatioList4 = new List<Service_Sales_Ratio_AGN__c>();
        Integer month;
        Integer year;
        Integer numberOfCases;
        Integer numberOfSO;
        Integer currentMonth = datetime.now().month();
        Integer currentYear = datetime.now().year();
        Integer checkValue1=0;
        Integer checkValue2=0;
        //System.debug('Current Year: '+CurrentYear);
        //AggregateResult[] groupedResults = [select count(id) numberOfCases,CALENDAR_MONTH(CreatedDate) month from Case where Service_AGN__c ='Customer Service Issues' and CALENDAR_YEAR(CreatedDate) = :CurrentYear group by CALENDAR_MONTH(CreatedDate) order by count(id)];        
        //Getting service issues values as per month and year.      
        AggregateResult[] groupedResults = [select count(id) numberOfCases,CALENDAR_MONTH(CreatedDate) month,CALENDAR_YEAR(CreatedDate) year from Case where Service_AGN__c ='Customer Service Issues' and CALENDAR_MONTH(CreatedDate) = :currentMonth and CALENDAR_YEAR(CreatedDate) = :currentYear group by CALENDAR_MONTH(CreatedDate),CALENDAR_YEAR(CreatedDate) order by count(id)];
        //Getting the list of existed ServiceSalesRatio records.
        List<Service_Sales_Ratio_AGN__c> ratioValues = [Select Id, Months_AGN__c ,Year_AGN__c,No_of_Cases_AGN__c,No_of_Sales_Order_AGN__c from Service_Sales_Ratio_AGN__c];
            if(groupedResults!=null && !groupedResults.isEmpty()){
                for(AggregateResult ar: groupedResults) {
                        month = Integer.valueOf(ar.get('month'));
                        year = Integer.valueOf(ar.get('year'));  
                        numberOfCases = Integer.valueOf(ar.get('numberOfCases'));
                        if(ratioValues!=null && !ratioValues.isEmpty()){
                           for(Service_Sales_Ratio_AGN__c r: ratioValues ){         
                                if(r.Months_AGN__c ==month && r.Year_AGN__c == year){
                                //AG CC(82)
                                if(Schema.sObjectType.Service_Sales_Ratio_AGN__c.fields.No_of_Cases_AGN__c.isUpdateable()){
                                    r.No_of_Cases_AGN__c = numberOfCases;
                                    }
                                //Update r;
                                ssRatioList3.add(r);
                                checkValue1=1;
                                break;
                                }
                           }
                        } 
                    Date dateOfCases = Date.newInstance(year,month,01);     
                    //AG CC(92)
                    If(checkValue1==0
                    && Schema.sObjectType.Service_Sales_Ratio_AGN__c.fields.Month_AGN__c.isCreateable() 
                    && Schema.sObjectType.Service_Sales_Ratio_AGN__c.fields.Months_AGN__c.isCreateable()
                    && Schema.sObjectType.Service_Sales_Ratio_AGN__c.fields.Year_AGN__c.isCreateable()
                    && Schema.sObjectType.Service_Sales_Ratio_AGN__c.fields.No_of_Cases_AGN__c.isCreateable()
                    && Schema.sObjectType.Service_Sales_Ratio_AGN__c.fields.Date_AGN__c.isCreateable()
                    ){ 
                    Service_Sales_Ratio_AGN__c numberOfCaseRecordtype = new Service_Sales_Ratio_AGN__c(Month_AGN__c=getShortMonth(month),Months_AGN__c=month,Year_AGN__c=year,No_of_Cases_AGN__c=numberOfCases,Date_AGN__c=dateOfCases);
                    ssRatioList1.add(numberOfCaseRecordtype);
                    } 
                    checkValue1=0; 
               }
             } 
             //AG CC
             if(Service_Sales_Ratio_AGN__c.sObjectType.getDescribe().isUpdateable() &&
                ssRatioList3 !=null && !ssRatioList3.isEmpty()){
                update ssRatioList3; 
             }
          //AggregateResult[] groupedResults1 = [select count(id) numberOfOrgs,CALENDAR_MONTH(CreatedOn_AGN__c) month from Sales_Order_AGN__c where CALENDAR_YEAR(CreatedOn_AGN__c) = :CurrentYear group by CALENDAR_MONTH(CreatedOn_AGN__c) order by count(id)];    
          //Getting Sales Order values as per month and year.
          AggregateResult[] groupedResults1= [select count(id) numberOfOrgs,CALENDAR_MONTH(CreatedOn_AGN__c) month,CALENDAR_YEAR(CreatedOn_AGN__c) year from Sales_Order_AGN__c where CALENDAR_MONTH(CreatedOn_AGN__c) != null and CALENDAR_YEAR(CreatedOn_AGN__c) != null group by CALENDAR_MONTH(CreatedOn_AGN__c),CALENDAR_YEAR(CreatedOn_AGN__c) order by count(id)];
            if(groupedResults1!=null && !groupedResults1.isEmpty()){
                for(AggregateResult ar: groupedResults1){
                    month = Integer.valueOf(ar.get('month')); 
                    year = Integer.valueOf(ar.get('year')); 
                    numberOfSO = Integer.valueOf(ar.get('numberOfOrgs'));
                    if(ratioValues!=null && !ratioValues.isEmpty()){
                        for(Service_Sales_Ratio_AGN__c r: ratioValues ){ 
                                    
                                   if(r.Months_AGN__c ==month && r.Year_AGN__c == year){ 
                                     //AG CC(112)
                                    if(Schema.sObjectType.Service_Sales_Ratio_AGN__c.fields.No_of_Sales_Order_AGN__c.isUpdateable()){
                                        r.No_of_Sales_Order_AGN__c= numberOfSO;
                                        }
                                        //Update r;
                                        ssRatioList4.add(r);
                                        checkValue2=1;
                                        break;
                                    }         
                        }
                    }
                    Date dateOfSalesOrders = Date.newInstance(year,month,01);
                    If(checkValue2==0){
                    Service_Sales_Ratio_AGN__c numberOfSoRecortype = new Service_Sales_Ratio_AGN__c(Month_AGN__c=getShortMonth(month),Months_AGN__c=month,Year_AGN__c=year,No_of_Sales_Order_AGN__c=numberOfSO,Date_AGN__c=dateOfSalesOrders);
                    ssRatioList2.add(numberOfSoRecortype);  
                    }
                    checkValue2=0;
                }  
            }
            //AG CC
            if(Service_Sales_Ratio_AGN__c.sObjectType.getDescribe().isUpdateable() &&
                ssRatioList4 !=null && !ssRatioList4.isEmpty()){
                update ssRatioList4; 
             }
            for(Service_Sales_Ratio_AGN__c  s:ssRatioList1){
              for(Service_Sales_Ratio_AGN__c  s1:ssRatioList2){    
                 If(s1.Months_AGN__c == s.Months_AGN__c && s1.Year_AGN__c == s.Year_AGN__c){
                    s.No_of_Sales_Order_AGN__c = s1.No_of_Sales_Order_AGN__c;
                    break;
                 }
              }
            }
            if(ssRatioList1 !=null && !ssRatioList1.isEmpty()){
                database.saveresult[] srList = database.insert(ssRatioList1, true);
                   //insert ssRatioList1;
                for(Database.SaveResult sr : srList) {    
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully Inserted value Id: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    } 
                 }  
            }      
           
           /* System.debug('data1: '+data1);
        System.debug('data2: '+data2);
    
        
        Decimal ratio;
        List<Decimal> ratioList = new List<Decimal>();
        //List<Service_Sales_Ratio_AGN__c> ratioValues = [Select Month_AGN__c ,ServiceBySales_Ratio_AGN__c from Service_Sales_Ratio_AGN__c];
        
        for(Integer mn=1; mn<=12;mn++)
        {
            
            if(data1.containsKey(mn) && data2.containsKey(mn))
            {
              ratio = ((Decimal)(data1.get(mn)) /(Decimal)(data2.get(mn))).setScale(6);
              data3.put(getShortMonth(mn),ratio);
            }
            else
            {
              data3.put(getShortMonth(mn),0.0);  
            }
           
        }
        System.debug('ratioValuesPrev: '+ratioValues);
        List<String> monthValue = new List<String>();
        monthValue.addAll(data3.keySet());
        for(Service_Sales_Ratio_AGN__c  rv: ratioValues)
        {
           for(String mnths: monthValue)
           {
               if(rv.Month_AGN__c == mnths)
               {
                   rv.ServiceBySales_Ratio_AGN__c = data3.get(mnths);
                   System.debug(rv.Month_AGN__c+' '+rv.ServiceBySales_Ratio_AGN__c);
                   System.debug(mnths+' '+data3.get(mnths));
               }
           }
        }
       
        Database.SaveResult[] srList = Database.update(ratioValues, true);
        for(Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully Updated value Id: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Service Sales Ratio fields that affected this error: ' + err.getFields());
                }
            }
        }*/
        
        
    }
    
}