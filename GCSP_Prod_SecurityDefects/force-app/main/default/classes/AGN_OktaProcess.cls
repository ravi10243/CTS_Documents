public class AGN_OktaProcess{
    
    
    public static void processADRequestOkta(Allergan_Customer_Registration_AGN__c crRecord ){
        
        
        //   userCreateOkta(JSON.serialize(crRecord));
        
        System.debug('in processADRequestOkta @@ : ');
        //System.debug('@@personAccountId@@@ : '+personAccountId);
        System.debug('crRecordId @@ : '+crRecord.Id);
        String oktaId;
        String soldToId;
        String countryCode;
        
        countryCode=crRecord.Country_Code_AGN__c;
        
        Account personAcct = [select Id, PersonContactId, Okta_Id_AGN__c,Primary_Parent_vod__c, Primary_Parent_vod__r.External_ID2_AGN__c, 
                      Customer_Registration_AGN__c, FirstName, LastName, PersonEmail, Phone from Account where Id =: crRecord.Account_AGN__c limit 1];
        
        System.debug('personAcct details @@ : '+personAcct.Id+' '+personAcct.PersonContactId);
        User existingUser = null;
        if(personAcct!=null){
            
            try{
                existingUser= [Select Id From User Where ContactId=: personAcct.PersonContactId Limit 1]; 
                
            }catch(Exception e){
            }
        }else{
            //existingUser =new User();
            //userCreateOkta(JSON.serialize(crRecord));
        }
        // account okta id present or not
        // if existingUser not found
        // create okta user then personaccount field stamp then create user(future method)
        
        if(personAcct!= null && personAcct.Primary_Parent_vod__c!= null){
            oktaId = personAcct.Okta_Id_AGN__c;
            soldToId  =   personAcct.Primary_Parent_vod__r.External_ID2_AGN__c;
        }
        System.debug('soldToId @@ : '+soldToId);
        //if Okta is not enabled and requested for Okta access  then first Check for duplicate user in SF
        if(!crRecord.Okta_Enabled_AGN__c && existingUser == null){
            //check for duplicates
            boolean checkuser = checkForDuplicateCustomer(crRecord.Email_AGN__c, crRecord.Country_Code_AGN__c);
            //if duplicate found show page error
            if(checkuser){
                //show page error message
                return;
            }
        }
        
        //personAcct != null  && existingUser== null && !crRecord.Okta_Enabled_AGN__c && crRecord.Allergan_Direct_Access_Requested_AGN__c && crRecord.Online_Registration_AGN__c
        
        System.debug('@@personAcct@@ = '+ personAcct);
        System.debug('@@existingUser@@ = '+ existingUser);
        System.debug('@@crRecord.Okta_Enabled_AGN__c@@ = '+ crRecord.Okta_Enabled_AGN__c);
        System.debug('@@crRecord.Allergan_Direct_Access_Requested_AGN__c@@ = '+ crRecord.Allergan_Direct_Access_Requested_AGN__c);
        System.debug('@@crRecord.Online_Registration_AGN__c@@ = '+ crRecord.Online_Registration_AGN__c);
        
        //if Person Account is presnt then update the account  else create new person account accordingly so that user can be navigated to home page after login
        
        // 3.2.1.1 scenario for new online registration via portal and being processed by MDM
        // 3.2.3.1 & 3.2.3.2 scenario for existing portal user with AD access have added or modified new address and being processed by MDM
        if( personAcct != null && existingUser!= null && crRecord.Okta_Enabled_AGN__c){
            
            System.debug('case@@ 3.2.1.1');
            //1.Send AD (shipto and BillTo id) attribute to Okta
            updateAdAttributeToOkta(soldToId, oktaId,countryCode, crRecord.Id);
            //personAcct.Customer_Registration_AGN__c = 'Complete';
            personAcct.Customer_Registration_AGN__c = 'Complete';
            update personAcct;
            system.debug('personAcct---->'+personAcct);
        }
        
        //3.2.2.1 scenario for existing portal user(UKI) requested for AD access via OAM portal or CS and being processed by CS
        if( personAcct != null && existingUser!= null && !crRecord.Okta_Enabled_AGN__c){
            System.debug('case@@ 3.2.2.1');
            System.debug('personAcct Id @@ '+personAcct.Id);
            System.debug('personAcct PersonContactId @@ '+personAcct.PersonContactId);            
            System.debug('serialize personAcct '+JSON.serialize(personAcct));
            
            //This will create an Okta user with updated AD attributes
            if(!countryCode.equalsIgnoreCase('CA')){
                createOktaUser(JSON.serialize(crRecord), JSON.serialize(personAcct), soldToId, countryCode, crRecord.Id);    
            }else{
                createOktaUser(JSON.serialize(crRecord), JSON.serialize(personAcct), soldToId, countryCode, crRecord.Id, crRecord.Language_AGN__c);
            }
        }
        
        //3.2.1.2 scenario for new internal registration via CS and being processed by MDM
        //3.2.2.2 scenario for existing account(who does not have any online access), portal access is being enabled and processed by CS
        else if(personAcct != null  && existingUser== null && !crRecord.Okta_Enabled_AGN__c && crRecord.Allergan_Direct_Access_Requested_AGN__c && crRecord.Online_Registration_AGN__c){
            
            System.debug('case@@ 3.2.1.2');        
            
            //This will create an Okta user with updated AD attributes
            if(!countryCode.equalsIgnoreCase('CA')){
                createOktaUser(JSON.serialize(crRecord), JSON.serialize(personAcct), soldToId, countryCode, crRecord.Id);
            }else{
                createOktaUser(JSON.serialize(crRecord), JSON.serialize(personAcct), soldToId, countryCode, crRecord.Id, crRecord.Language_AGN__c);
            }
            personAcct.Customer_Registration_AGN__c = 'Complete';
            update personAcct;
            //create comunity user via future method
            if(!countryCode.equalsIgnoreCase('CA')){
                createCommunityUser(personAcct.Id);
            }else{
                createCommunityUser(personAcct.Id, crRecord.Language_AGN__c);
            }
            system.debug('personAcct 3.2.1.2---->'+personAcct);
        } 
        
        else if(personAcct == null){
            
            System.debug('case@@personAcct==null');
            //1.Create Person Account
            //2.create comunity user via future method
            //3.create Okta user 
            //4.Add AD attribute in the request
            //5.personAcct.Customer_Registration_AGN__c = 'Completed';            
        }   
    }
    
    
    @Future(callout=true)
    public static Void updateAdAttributeToOkta(String soldToId,String oktaId,String countryCode,String registrationid){ 
        
        System.debug('updateAdAttributeToOkta response countryCode == '+countryCode); 
        // System.debug('soldToId @@@ : '+soldToId);
        // System.debug('oktaId @@@ : '+oktaId);
        //System.debug('registrationId @@@ : '+registrationId);
        if(!String.isEmpty(soldToId) && !String.isEmpty(oktaId)){
            
            
            String systemPermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_System_Permissions_AGN__c');
            String sitePermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_Site_Permissions_AGN__c');
            String directUserRole = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_User_Role_AGN__c');
            
            Map<String,List<String>> dataMap = getBillToShipToSapId(soldToId);           
            System.debug('updateAdAttributeToOkta shiptoValueActive : '+dataMap.get('shiptoValueActive'));
            System.debug('updateAdAttributeToOkta shiptoValueInActive : '+dataMap.get('shiptoValueInActive'));
            System.debug('updateAdAttributeToOkta billtoValueActive : '+dataMap.get('billtoValueActive'));
            System.debug('updateAdAttributeToOkta billtoValueInactive : '+dataMap.get('billtoValueInactive'));
            
            
            Map<String,List<String>> data=getBillToShipToFilter(dataMap.get('billtoValueActive'),dataMap.get('shiptoValueActive'),
                                                                dataMap.get('billtoValueInactive'),dataMap.get('shiptoValueInActive'),oktaId, countryCode);
            
            System.debug('updateAdAttributeToOkta billToActiveList : '+data.get('billToActiveList'));
            System.debug('updateAdAttributeToOkta shipToActiveList : '+data.get('shipToActiveList'));
            
            String reqBody = prepareOktaJsonString(data.get('billToActiveList'),data.get('shipToActiveList'),systemPermission,sitePermission,directUserRole);
            System.debug('reqBody xxxx== '+reqBody);
            //AGN_OktaUtils a = new AGN_OktaUtils();
            AGN_OktaUtils a = new AGN_OktaUtils(countryCode,'');
            String response = a.UpdateUser(oktaId,reqBody);
            System.debug('response xxxx == '+response); 
            
        }
        else{
            
            String systemPermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_System_Permissions_AGN__c');
            String sitePermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_Site_Permissions_AGN__c');
            String directUserRole = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_User_Role_AGN__c');
            
            
            System.debug('updateAdAttributeToOkta else part');
            System.debug('regisraion id@@@@@ '+registrationid);
            Allergan_Customer_Registration_AGN__c accountAgnC=[SELECT Account_AGN__c FROM Allergan_Customer_Registration_AGN__c WHERE Id = : registrationid];
            
            Account primaryVodC= [SELECT Primary_Parent_vod__c FROM Account WHERE Id=:accountAgnC.Account_AGN__c limit 1];
            Account externalId2= [SELECT External_ID2_AGN__c FROM Account WHERE Id =: primaryVodC.Primary_Parent_vod__c limit 1];
            
            String soldToSapId=externalId2.External_ID2_AGN__c;
            System.debug('soldToSapId@@@  '+soldToSapId); 
            
            Account primaryVodCOkta= [SELECT Okta_Id_AGN__c FROM Account WHERE Id=:accountAgnC.Account_AGN__c ];
            
            String IdOkta = primaryVodCOkta.Okta_Id_AGN__c;
            
            System.debug('oktaUserId xxxx@@== '+IdOkta);
            
            //String IdOkta= getOktaUserId(registrationid);
            
            System.debug('oktaUserId xxxx@@== '+IdOkta);
            
            Map<String,List<String>> dataMap = getBillToShipToSapId(soldToId);           
            System.debug('shiptoValueActive : '+dataMap.get('shiptoValueActive'));
            System.debug('shiptoValueInActive : '+dataMap.get('shiptoValueInActive'));
            System.debug('billtoValueActive : '+dataMap.get('billtoValueActive'));
            System.debug('billtoValueInactive : '+dataMap.get('billtoValueInactive'));
            
            
            Map<String,List<String>> data=getBillToShipToFilter(dataMap.get('billtoValueActive'),dataMap.get('shiptoValueActive'),
                                                                dataMap.get('billtoValueInactive'),dataMap.get('shiptoValueInActive'),IdOkta, countryCode);
            
            System.debug('billToActiveList : '+data.get('billToActiveList'));
            System.debug('shipToActiveList : '+data.get('shipToActiveList'));
            
            String reqBody = prepareOktaJsonString(data.get('billToActiveList'),data.get('shipToActiveList'),systemPermission,sitePermission,directUserRole);
            System.debug('reqBody xxxx== '+reqBody);
            //AGN_OktaUtils a = new AGN_OktaUtils();
            AGN_OktaUtils a = new AGN_OktaUtils(countryCode,'');
            String response = a.UpdateUser(oktaId,reqBody);
            System.debug('response xxxx == '+response); 
            
        }
    }
    
    public static String prepareOktaJsonString(String[] billToSapIdValue,String[] shipToSapIdValue,String systemPermission,String sitePermission,String directUserRole){
        String profileStart='{"profile": {';
        String profileEnd='} }';
        String billToAccountStart='"ad_associated_payer_accounts": [';
        String billToAccountEnd=']';
        String shipToAccountStart='"ad_associated_shipto_accounts": [';
        String shipToAccountEnd=']';
        
        String systemPermissionStart='"ad_system_permissions": [';
        String systemPermissionEnd=']';
        String sitePermissionStart='"ad_site_permissions": [';
        String sitePermissionEnd=']';
        String adRole='"ad_user_role":' ;
        String billtoFinalText='';
        String shiptoFinalText='';
        String billtoDetails='';
        String shiptoDetails='';
        String doubleQuotes='\"';
        String systemPermissionText='';
        String sitePermissionText='';
        String adRoleText='';
        String response='';
        
        if(billToSapIdValue.size() > 0){
            for (Integer i = 0; i<billToSapIdValue.size(); i++) {
                billtoFinalText+=doubleQuotes;
                billtoFinalText+=billToSapIdValue[i];
                billtoFinalText+=doubleQuotes;
                billtoFinalText+=',';
                
            }
            billtoFinalText=billtoFinalText.subString(0,billtoFinalText.length()-1);
            
            billtoDetails=billToAccountStart+billtoFinalText+billToAccountEnd;
            
        }else{
            
            billtoDetails=billToAccountStart+billToAccountEnd;
        }
        
        if(shipToSapIdValue.size() > 0){
            for (Integer i = 0; i<shipToSapIdValue.size(); i++) {
                shiptoFinalText+='\"';
                shiptoFinalText+=shipToSapIdValue[i];
                shiptoFinalText+='\"';
                shiptoFinalText+=',';
                
                // system.debug('shiptoFinalText: '+shiptoFinalText);
            }
            shiptoFinalText=shiptoFinalText.subString(0,shiptoFinalText.length()-1);
            shiptoDetails=shipToAccountStart+shiptoFinalText+shipToAccountEnd;
            
        }else{
            
            shiptoDetails=shipToAccountStart+shipToAccountEnd;
        }        
        
        systemPermissionText = systemPermissionStart+systemPermission+systemPermissionEnd;
        sitePermissionText=sitePermissionStart+sitePermission+sitePermissionEnd;
        adRoleText=adRole+directUserRole;
        response=profileStart+billtoDetails+','+shiptoDetails+','+sitePermissionText+','+systemPermissionText+','+adRoleText+profileEnd;
        System.debug('response=== '+response);
        return response;
    }
    
    public static String formatedADAttributeString(String soldToId, String countryCode,String registrationid){  
        
        System.debug('response countryCode == '+countryCode); 
        System.debug('soldToId @@@ : '+soldToId);
        String reqBody;
        System.debug('registrationId @@@ : '+registrationId);
        if(!String.isEmpty(soldToId)){
            String systemPermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_System_Permissions_AGN__c');
            String sitePermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_Site_Permissions_AGN__c');
            String directUserRole = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_User_Role_AGN__c');
            
            Map<String,List<String>> dataMap = getBillToShipToSapId(soldToId);           
            System.debug('shiptoValueActive : '+dataMap.get('shiptoValueActive'));
            System.debug('shiptoValueInActive : '+dataMap.get('shiptoValueInActive'));
            System.debug('billtoValueActive : '+dataMap.get('billtoValueActive'));
            System.debug('billtoValueInactive : '+dataMap.get('billtoValueInactive'));
            
            
            reqBody = getADAttributeJsonString(dataMap.get('billtoValueActive'),dataMap.get('shiptoValueActive'),systemPermission,sitePermission,directUserRole);   
        }
        else{
            
            System.debug('updateAdAttributeToOkta else part');
            System.debug('regisraion id@@@@@ '+registrationid);
            Allergan_Customer_Registration_AGN__c accountAgnC=[SELECT Account_AGN__c FROM Allergan_Customer_Registration_AGN__c WHERE Id = : registrationid];
            
            Account primaryVodC= [SELECT Primary_Parent_vod__c FROM Account WHERE Id=:accountAgnC.Account_AGN__c limit 1];
            Account externalId2= [SELECT External_ID2_AGN__c FROM Account WHERE Id =: primaryVodC.Primary_Parent_vod__c limit 1];
            
            String soldToSapId=externalId2.External_ID2_AGN__c;
            System.debug('soldToSapId@@@  '+soldToSapId);             
            
            
            String systemPermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_System_Permissions_AGN__c');
            String sitePermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_Site_Permissions_AGN__c');
            String directUserRole = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_User_Role_AGN__c');
            
            
            Map<String,List<String>> dataMap = getBillToShipToSapId(soldToId);           
            System.debug('shiptoValueActive : '+dataMap.get('shiptoValueActive'));
            System.debug('shiptoValueInActive : '+dataMap.get('shiptoValueInActive'));
            System.debug('billtoValueActive : '+dataMap.get('billtoValueActive'));
            System.debug('billtoValueInactive : '+dataMap.get('billtoValueInactive'));
            
            reqBody = getADAttributeJsonString(dataMap.get('billtoValueActive'),dataMap.get('shiptoValueActive'),systemPermission,sitePermission,directUserRole);
        }
        return reqBody;
    }
    
    public static String getADAttributeJsonString(String[] billToSapIdValue,String[] shipToSapIdValue,String systemPermission,String sitePermission,String directUserRole){
        
        String billToAccountStart='"ad_associated_payer_accounts": [';
        String billToAccountEnd=']';
        String shipToAccountStart='"ad_associated_shipto_accounts": [';
        String shipToAccountEnd=']';
        
        String systemPermissionStart='"ad_system_permissions": [';
        String systemPermissionEnd=']';
        String sitePermissionStart='"ad_site_permissions": [';
        String sitePermissionEnd=']';
        String adRole='"ad_user_role":' ;
        String billtoFinalText='';
        String shiptoFinalText='';
        String billtoDetails='';
        String shiptoDetails='';
        String doubleQuotes='\"';
        String systemPermissionText='';
        String sitePermissionText='';
        String adRoleText='';
        String response='';
        
        if(billToSapIdValue.size() > 0){
            for (Integer i = 0; i<billToSapIdValue.size(); i++) {
                billtoFinalText+=doubleQuotes;
                billtoFinalText+=billToSapIdValue[i];
                billtoFinalText+=doubleQuotes;
                billtoFinalText+=',';
                
            }
            billtoFinalText=billtoFinalText.subString(0,billtoFinalText.length()-1);
            
            billtoDetails=billToAccountStart+billtoFinalText+billToAccountEnd;
            
        }else{
            
            billtoDetails=billToAccountStart+billToAccountEnd;
        }
        
        if(shipToSapIdValue.size() > 0){
            for (Integer i = 0; i<shipToSapIdValue.size(); i++) {
                shiptoFinalText+='\"';
                shiptoFinalText+=shipToSapIdValue[i];
                shiptoFinalText+='\"';
                shiptoFinalText+=',';
                
                // system.debug('shiptoFinalText: '+shiptoFinalText);
            }
            shiptoFinalText=shiptoFinalText.subString(0,shiptoFinalText.length()-1);
            shiptoDetails=shipToAccountStart+shiptoFinalText+shipToAccountEnd;
            
        }else{
            
            shiptoDetails=shipToAccountStart+shipToAccountEnd;
        }        
        
        systemPermissionText = systemPermissionStart+systemPermission+systemPermissionEnd;
        sitePermissionText = sitePermissionStart + sitePermission + sitePermissionEnd;
        adRoleText = adRole + directUserRole;
        response = billtoDetails+','+shiptoDetails+','+sitePermissionText+','+systemPermissionText+','+adRoleText;
        System.debug('response=== '+response);
        return response;
    }
    public static Map<String,List<String>> getBillToShipToSapId(String soldToSapId){
        List<Child_Account_vod__c> childAccountShipToList = [SELECT Child_Account_vod__r.External_id2_agn__c,Child_Account_Status_AGN__c FROM Child_Account_vod__c WHERE parent_Account_vod__r.External_id2_agn__c =: soldToSapId  and Child_Record_Type__c != 'Professional_vod'  and  Ship_To_AGN__c = True];
        List<Child_Account_vod__c> childAccountBillToList = [SELECT Child_Account_vod__r.External_id2_agn__c,Child_Account_Status_AGN__c FROM Child_Account_vod__c WHERE parent_Account_vod__r.External_id2_agn__c =: soldToSapId  and Child_Record_Type__c != 'Professional_vod'  and  Bill_To_AGN__c = True];
        List<Child_Account_vod__c> childAccountSoldTOSameasList = [SELECT Sold_To_AGN__c, Ship_To_AGN__c, Bill_To_AGN__c,Child_Account_Status_AGN__c FROM Child_Account_vod__c WHERE parent_Account_vod__r.External_id2_agn__c =:soldToSapId and  Child_Record_Type__c = 'Professional_vod' limit 1];
        
        
        List<String> shiptoValueActive = new List<String>();
        List<String> billtoValueActive = new List<String>();
        List<String> shiptoValueInActive = new List<String>();
        List<String> billtoValueInactive = new List<String>();
        
        Map<String,String> dataMapBT=new Map<String,String>();
        //Adding SAP ID of BillTo Account
        for(Child_Account_vod__c billTolist:childAccountBillToList){
            dataMapBT.put(billTolist.Child_Account_vod__r.External_id2_agn__c,billTolist.Child_Account_Status_AGN__c);   
            
        }
        System.debug('dataMapBT: '+dataMapBT); 
        Map<String,String> dataMapST=new Map<String,String>();
        //Adding SAP ID of ShipTo Account
        for(Child_Account_vod__c shipTolist:childAccountShipToList){
            
            dataMapST.put(shipTolist.Child_Account_vod__r.External_id2_agn__c,shipTolist.Child_Account_Status_AGN__c);   
            
        }  
        System.debug('dataMapST: '+dataMapST); 
        
        for (String sapId : dataMapST.keySet()){
            
            if('Active'.equalsIgnoreCase(dataMapST.get(sapId))){
                
                shiptoValueActive.add(sapId);
            }else{
                
                shiptoValueInActive.add(sapId);               
            }
            
        }
        for (String sapId : dataMapBT.keySet()){
            
            if('Active'.equalsIgnoreCase(dataMapBT.get(sapId))){
                
                billtoValueActive.add(sapId);
            }else{
                
                billtoValueInactive.add(sapId);               
            }
            
        }
        if(!childAccountSoldTOSameasList.isEmpty()){
            if(childAccountSoldTOSameasList[0].Sold_To_AGN__c){
                
                if(childAccountSoldTOSameasList[0].Ship_To_AGN__c && childAccountSoldTOSameasList[0].Child_Account_Status_AGN__c=='Active'){ //SoldTo Account is also ShipTo
                    shiptoValueActive.add(soldToSapId);
                }else{
                    
                    shiptoValueInActive.add(soldToSapId);
                }
                
                if(childAccountSoldTOSameasList[0].Bill_To_AGN__c && childAccountSoldTOSameasList[0].Child_Account_Status_AGN__c=='Active'){ //SoldTo Account is also BillTo
                    billtoValueActive.add(soldToSapId);
                }else{
                    
                    billtoValueInactive.add(soldToSapId);   
                }
            }
        }
        
        
        System.debug('shiptoValueActive: '+shiptoValueActive); 
        System.debug('shiptoValueInActive: '+shiptoValueInActive); 
        
        System.debug('billtoValueActive: '+billtoValueActive); 
        System.debug('billtoValueInactive: '+billtoValueInactive); 
        
        
        
        Map<String,List<String>> dataMap = new Map<String,List<String>>();
        dataMap.put('shiptoValueActive', shiptoValueActive);
        dataMap.put('shiptoValueInActive', shiptoValueInActive);
        dataMap.put('billtoValueActive', billtoValueActive);
        dataMap.put('billtoValueInactive', billtoValueInactive);
        
        return dataMap;
    }
    
    public static String getOktaUserId(String registrationid){
        String oktaUserId;
        System.debug('registrationid getOktaUserId xxxx== '+registrationid);
        Allergan_Customer_Registration_AGN__c accountAgnC=[SELECT Account_AGN__c FROM Allergan_Customer_Registration_AGN__c WHERE Id = : registrationid];
        
        Account primaryVodC= [SELECT Okta_Id_AGN__c FROM Account WHERE Id=:accountAgnC.Account_AGN__c ];
        
        oktaUserId=primaryVodC.Okta_Id_AGN__c;
        //  System.debug('Account_AGN__c xxxx== '+accountAgnC.Account_AGN__c);
        System.debug('oktaUserId xxxx== '+oktaUserId);
        return oktaUserId;
    }
    // add extentention
    
    public static boolean checkForDuplicateCustomer(String email, String Country_Code) {
        
        string newUserName = email + '.' +  (String)OAM_User_Settings__c.getValues(Country_Code).get('Username_Suffix__c');
        
        for (User u: [select Id from User where UserName =: newUserName and isActive = true limit 1]) {
            return true;
        }
        return false;
    }
    
    
    
    @Future(callout=true)
    public static void createOktaUser(String customerStr, String customerAccountStr, String soldToId, String countryCode,String registrationid) {
        //public static void createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Account customerAccount) { 
        Allergan_Customer_Registration_AGN__c customer = (Allergan_Customer_Registration_AGN__c)JSON.deserialize(customerStr, Allergan_Customer_Registration_AGN__c.class);
        Account customerAccount = (Account)JSON.deserialize(customerAccountStr, Account.class);
        String returnMessage = 'FAILURE';
        // AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? this.username : this.userEmail;
        System.debug('customerStr @@@ : '+customerStr);
        System.debug('customerAccountStr @@@ : '+customerAccountStr);
        System.debug('customerAccount Id @@@ : '+customerAccount.Id);
        System.debug('customer.Email_AGN__c @@@ : '+customer.Email_AGN__c);
        System.debug('setting username @@@ : '+(String)OAM_User_Settings__c.getValues(customer.Country_Code_AGN__c).get('Username_Suffix__c') );
        
        
        String userName = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? customer.Email_AGN__c + '.' + (String)OAM_User_Settings__c.getValues(customer.Country_Code_AGN__c).get('Username_Suffix__c') : customer.Email_AGN__c;
        System.debug('userName @@@ : '+userName);
        
        //AGN_OktaUtils oUtil = new AGN_OktaUtils();
        AGN_OktaUtils oUtil = new AGN_OktaUtils(customer.Country_Code_AGN__c,'');
        //checking if user is present in OKTA
        String okatMessage = oUtil.isPresentInOkta(userName);
        System.debug('okatMessage @@@ : '+okatMessage);
        Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
        
        String messagetype = (String) m.get('messagetype');
        System.debug('messagetype @@@ : '+messagetype);
        //ERROR -> User not found, need to create the user
        if (messagetype.equalsIgnoreCase('ERROR')) {
            //String soldToId, String countryCode,String registrationid
            String adAttributesBody =  formatedADAttributeString(soldToId, countryCode, registrationid);   
            string reqBody = '{"profile":' +
                +'{"firstName": "' + customer.First_Name_AGN__c + '",' +
                +'"lastName": "' + customer.Last_Name_AGN__c + '",' +
                +'"email": "' + customer.Email_AGN__c.toLowerCase() + '",' +
                +'"login": "' + userName.toLowerCase() + '",' +
                +'"ad_has_consented_gdpr": "true",' +
                + adAttributesBody +
                +'},' +
                +'"credentials":{' +
                //+'"password" : '+
                //+'{"value": "'+ oktaPassword +'"'+
                //+'},'+
                +'"recovery_question":' +
                +'{"question": "' + 'Name of this company?' + '","answer": "' + 'ALLERGAN' + '"' +
                +'}' +
                +'},' +
                +'"groupIds": [' + (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Okta_SF_Community_Group_Id_AGN__c')+ ']}';
            //+'"groupIds": ["' + (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Okta_SF_Community_Group_Id_AGN__c')+ '"]}';
            system.debug('reqBody@@@@ ==== '+reqBody);
            String userCreateMsg = oUtil.CreateUser(reqBody);
            system.debug('userCreateMsg@@@@ ==== '+userCreateMsg);
            Map < String, Object > userCreateMsgMap = (Map < String, Object > ) JSON.deserializeUntyped(userCreateMsg);
            
            system.debug('userCreateMsgMap@@@@ ==== '+userCreateMsgMap);
            
            if (String.valueOf(userCreateMsgMap.get('messagetype')).equalsIgnoreCase('SUCCESS')) {
                returnMessage = 'SUCCESS';
                String userOktaId = String.valueOf(userCreateMsgMap.get('Id'));
                system.debug('userOktaId ==== '+userOktaId);
                
                if (!String.isEmpty(userOktaId)) {
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    update acc;
                }
                
                SendExpiryLinkChangePassword(customer, customerAccount);
            }
        }
        //User found
        else {
            String userOktatatus = (String) m.get('Status');
            String userOktaId = (String) m.get('Id');
            
            system.debug('userOktatatus ==== '+userOktatatus);
            system.debug('userOktaId$$ ==== '+userOktaId);
            system.debug('else part createOktaUserSendLink userOktaId ==== '+userOktaId);
            //Not inactive (DEPROVISIONED)
            if (!userOktatatus.equalsignorecase('DEPROVISIONED')) {
                oUtil.AddUserToGroup((String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Okta_SF_Community_Group_Id_AGN__c'), userOktaId);
                returnMessage = 'SUCCESS';
                
                if (!String.isEmpty(userOktaId)) {
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    update acc;
                }
                
                SendExpiryLinkChangePassword(customer, customerAccount);
            } else {
                returnMessage = 'DEPROVISIONED';
            }
        }
        
        //return returnMessage;
    }
    
    @Future(callout=true)
    public static void createOktaUser(String customerStr, String customerAccountStr, String soldToId, String countryCode,String registrationid, String userLocale) {
        
        //public static void createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Account customerAccount) { 
        Allergan_Customer_Registration_AGN__c customer = (Allergan_Customer_Registration_AGN__c)JSON.deserialize(customerStr, Allergan_Customer_Registration_AGN__c.class);
        Account customerAccount = (Account)JSON.deserialize(customerAccountStr, Account.class);
        String returnMessage = 'FAILURE';
        // AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? this.username : this.userEmail;
        System.debug('customerStr @@@ : '+customerStr);
        System.debug('customerAccountStr @@@ : '+customerAccountStr);
        System.debug('customerAccount Id @@@ : '+customerAccount.Id);
        System.debug('customer.Email_AGN__c @@@ : '+customer.Email_AGN__c);
        System.debug('setting username @@@ : '+(String)OAM_User_Settings__c.getValues(customer.Country_Code_AGN__c).get('Username_Suffix__c') );
        
        
        String userName = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? customer.Email_AGN__c + '.' + (String)OAM_User_Settings__c.getValues(customer.Country_Code_AGN__c).get('Username_Suffix__c') : customer.Email_AGN__c;
        System.debug('userName @@@ : '+userName);
        
        //AGN_OktaUtils oUtil = new AGN_OktaUtils();
        AGN_OktaUtils oUtil = new AGN_OktaUtils(customer.Country_Code_AGN__c,'');
        //checking if user is present in OKTA
        String okatMessage = oUtil.isPresentInOkta(userName);
        System.debug('okatMessage @@@ : '+okatMessage);
        Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
        
        String messagetype = (String) m.get('messagetype');
        System.debug('messagetype @@@ : '+messagetype);
        //ERROR -> User not found, need to create the user
        if (messagetype.equalsIgnoreCase('ERROR')) {
            //String soldToId, String countryCode,String registrationid
            String adAttributesBody =  formatedADAttributeString(soldToId, countryCode, registrationid);   
            string reqBody = '{"profile":' +
                +'{"firstName": "' + customer.First_Name_AGN__c + '",' +
                +'"lastName": "' + customer.Last_Name_AGN__c + '",' +
                +'"email": "' + customer.Email_AGN__c.toLowerCase() + '",' +
                +'"login": "' + userName.toLowerCase() + '",' +
                +'"ad_has_consented_gdpr": "true",' +
                + adAttributesBody +
                +'},' +
                +'"credentials":{' +
                //+'"password" : '+
                //+'{"value": "'+ oktaPassword +'"'+
                //+'},'+
                +'"recovery_question":' +
                +'{"question": "' + 'Name of this company?' + '","answer": "' + 'ALLERGAN' + '"' +
                +'}' +
                +'},' +
                +'"groupIds": [' + (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Okta_SF_Community_Group_Id_AGN__c')+ ']}';
            //+'"groupIds": ["' + (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Okta_SF_Community_Group_Id_AGN__c')+ '"]}';
            system.debug('reqBody@@@@ ==== '+reqBody);
            String userCreateMsg = oUtil.CreateUser(reqBody);
            system.debug('userCreateMsg@@@@ ==== '+userCreateMsg);
            Map < String, Object > userCreateMsgMap = (Map < String, Object > ) JSON.deserializeUntyped(userCreateMsg);
            
            system.debug('userCreateMsgMap@@@@ ==== '+userCreateMsgMap);
            
            if (String.valueOf(userCreateMsgMap.get('messagetype')).equalsIgnoreCase('SUCCESS')) {
                returnMessage = 'SUCCESS';
                String userOktaId = String.valueOf(userCreateMsgMap.get('Id'));
                system.debug('userOktaId ==== '+userOktaId);
                
                if (!String.isEmpty(userOktaId)) {
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    update acc;
                }
                
                SendExpiryLinkChangePassword(customer, customerAccount, userLocale);
            }
        }
        //User found
        else {
            String userOktatatus = (String) m.get('Status');
            String userOktaId = (String) m.get('Id');
            
            system.debug('userOktatatus ==== '+userOktatatus);
            system.debug('userOktaId$$ ==== '+userOktaId);
            system.debug('else part createOktaUserSendLink userOktaId ==== '+userOktaId);
            //Not inactive (DEPROVISIONED)
            if (!userOktatatus.equalsignorecase('DEPROVISIONED')) {
                oUtil.AddUserToGroup((String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Okta_SF_Community_Group_Id_AGN__c'), userOktaId);
                returnMessage = 'SUCCESS';
                
                if (!String.isEmpty(userOktaId)) {
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    update acc;
                }
                
                SendExpiryLinkChangePassword(customer, customerAccount, userLocale);
            } else {
                returnMessage = 'DEPROVISIONED';
            }
        }
        
        //return returnMessage;
    }
    
    private static void updateOktaUserIdInAccount(Account customerAccount, String oktaUserId, String passwordResetToken) {
        
        System.debug('in updateOktaUserIdInAccount @@token@@@ ' + passwordResetToken);
        System.debug('in updateOktaUserIdInAccount @@customerAccountId@@@ ' + customerAccount.Id);
        Account acc = [Select Okta_Id_AGN__c, Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccount.Id];
        System.debug('in @@acc.Okta_Id_AGN__c@@@ ' + acc.Okta_Id_AGN__c );
        if (!String.isEmpty(oktaUserId)) {
            acc.Okta_Id_AGN__c = oktaUserId;
        }
        if (!String.isEmpty(passwordResetToken)) {
            acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        }
        update acc;
    }
    private static void updateOktaUserIdInAccount(Id customerAccountId, String oktaUserId, String passwordResetToken) {
        
        System.debug('@@customerAccountId@@@ ' + customerAccountId);
        Account acc = [Select Okta_Id_AGN__c, Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccountId];
        if (!String.isEmpty(oktaUserId)) {
            System.debug('@@updateOktaUserIdInAccount@@@OktaID ' + oktaUserId);
            acc.Okta_Id_AGN__c = oktaUserId;
        }
        if (!String.isEmpty(passwordResetToken)) {
            acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        }
        update acc;
    }
    
    public static void SendExpiryLinkChangePassword(Allergan_Customer_Registration_AGN__c customer, Account customerAccount) {
        String dataToEncrypt;
        String encryptedData;
        String privateKey = (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Encrypt_Decrypt_Private_Key_AGN__c');//AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        
        //Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(AGN_OAMConstant.TOKENVALIDTILL));
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Activation_Token_Valid_Till_AGN__c')));
        
        String passwordResetToken = cUtil.getRandomKey();
        
        dataToEncrypt = '{' +
            +'"portalusername": "' + customer.Email_AGN__c + '.' + (String)OAM_User_Settings__c.getValues(customer.Country_Code_AGN__c).get('Username_Suffix__c')+ '",' +
            +'"portaluseremail": "' + customer.Email_AGN__c + '",' +
            +'"countrycode": "' + customer.Country_Code_AGN__c + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        //updateOktaUserIdInAccount(customerAccount, '', passwordResetToken);
        
        //Update generated password reset token with the Account/Customer
        Account acc = [Select Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccount.Id];
        acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        update acc;
        
        String userName = customer.Email_AGN__c;
        //SendMail(customer.First_Name_AGN__c, userName, customer.Email_AGN__c, encryptedData);
        SendWelcomeMail(customer, encryptedData);
    }
    
    public static void SendExpiryLinkChangePassword(Allergan_Customer_Registration_AGN__c customer, Account customerAccount, String userLocale) {
        String dataToEncrypt;
        String encryptedData;
        String privateKey = (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Encrypt_Decrypt_Private_Key_AGN__c');//AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        
        //Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(AGN_OAMConstant.TOKENVALIDTILL));
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Activation_Token_Valid_Till_AGN__c')));
        String passwordResetToken = cUtil.getRandomKey();
        
        dataToEncrypt = '{' +
            +'"portalusername": "' + customer.Email_AGN__c + '.' + (String)OAM_User_Settings__c.getValues(customer.Country_Code_AGN__c).get('Username_Suffix__c')+ '",' +
            +'"portaluseremail": "' + customer.Email_AGN__c + '",' +
            +'"countrycode": "' + customer.Country_Code_AGN__c + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        //updateOktaUserIdInAccount(customerAccount, '', passwordResetToken);
        
        //Update generated password reset token with the Account/Customer
        Account acc = [Select Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccount.Id];
        acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        update acc;
        
        String userName = customer.Email_AGN__c;
        SendWelcomeMail(customer, encryptedData, userLocale);  
    }
    
    public static void SendWelcomeMail(Allergan_Customer_Registration_AGN__c customer, String encryptedData){
        Decimal expirationInDays = (Decimal)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Activation_Token_Valid_Till_AGN__c')/24;
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.First_Name_AGN__c,
                '{!Recipient.LastName}' => customer.Last_Name_AGN__c,
                '{!Recipient.Email}' => customer.Email_AGN__c,
                '{!Recipient.Business_Account_SAP_ID__c}' => customer.Business_Account_SAP_ID__c,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd'),
                '{!ExpiryLink}' => (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Community_Base_URL_AGN__c') + (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Community_Suffix_AGN__c') + '/AGN_CustomerPortalOktaForceChgPWD?token=' + encryptedData
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email_AGN__c, null, null, null, mapSubjectParams, null, mapBodyParams));
        String senderEmailAddress = (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Sender_Email_AGN__c');
        if(listEmailMessageWrapper.size() > 0){
            //second parameter of sendEmail() is email template name (e.g: Self Registration: Welcome Email_CS-IT)
            String emailTemplateName = 'Self Registration: Welcome Email_CS-'+ customer.Country_Code_AGN__c.toUpperCase();
            
            EmailTemplate[] emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateName limit 1];
            if(emailTemplate.isEmpty())
            {
                emailTemplateName = 'Self Registration: Welcome Email-'+ customer.Country_Code_AGN__c.toUpperCase();
            }
            
            AGN_OAMCustomerRegUtils.sendEmail(listEmailMessageWrapper, emailTemplateName, senderEmailAddress);
        }
    }
    public static void SendWelcomeMail(Allergan_Customer_Registration_AGN__c customer, String encryptedData, String userLocale){
        
        Decimal expirationInDays = (Decimal)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Activation_Token_Valid_Till_AGN__c')/24;
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        
        String lang;
        System.debug('SendWelcomeMail -- customer.Country_Code_AGN__c ->' +customer.Country_Code_AGN__c);
        System.debug('SendWelcomeMail -- userLocale ->' +userLocale);
        if(customer.Country_Code_AGN__c.equalsIgnoreCase('CA')){
            if(!String.isEmpty(userLocale)){
                if(userLocale.containsIgnoreCase('en')){
                    lang = 'en_US';
                }else if(userLocale.containsIgnoreCase('fr')){
                    lang = 'fr';
                }
                else{
                    lang = (String)OAM_User_Settings__c.getValues(customer.Country_Code_AGN__c).get('User_Language__c');
                }
            }
            else{
                lang = (String)OAM_User_Settings__c.getValues(customer.Country_Code_AGN__c).get('User_Language__c');
            }
        }
        else{
            lang = (String)OAM_User_Settings__c.getValues(customer.Country_Code_AGN__c).get('User_Language__c');
        }
        
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.First_Name_AGN__c,
                '{!Recipient.LastName}' => customer.Last_Name_AGN__c,
                '{!Recipient.Email}' => customer.Email_AGN__c,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd'),
                '{!ExpiryLink}' => (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Community_Base_URL_AGN__c') + (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Community_Suffix_AGN__c') + '/AGN_CustomerPortalOktaForceChgPWD?token=' + encryptedData + '&language='+lang
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email_AGN__c, null, null, null, mapSubjectParams, null, mapBodyParams));   
        
        String senderEmailAddress = (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Sender_Email_AGN__c');
        
        if(listEmailMessageWrapper.size() > 0){
            //second parameter of sendEmail() is email template name (e.g: Self Registration: Welcome Email_CS-IT)
            String emailTemplateName = 'Self Registration: Welcome Email_CS-'+ lang.toUpperCase();
            
            EmailTemplate[] emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateName limit 1];
            if(emailTemplate.isEmpty())
            {
                emailTemplateName = 'Self Registration: Welcome Email-'+ lang.toUpperCase();
            }
            
            AGN_OAMCustomerRegUtils.sendEmail(listEmailMessageWrapper, emailTemplateName, senderEmailAddress);
        }
    }
    
    @future
    //  public static void createCommunityUser(ID customerRegId, Id customerAccountId,String soldToId, String oktaId) { 
    public static void createCommunityUser(Id customerAccountId) {
        
        System.debug('@@in createCommunityUser@@');
        string alias = '';
        Account customer = [select Id, Name, PersonContactId, FirstName, Country_Code__c, LastName, PersonEmail, Phone, Customer_Category_AGN__c, Customer_Sub_Category_AGN__c from Account where Id =: customerAccountId limit 1];
        OAM_User_Settings__c allDetails = OAM_User_Settings__c.getInstance(customer.Country_Code__c);
        User customerUser = new User();
        
        try {
            
            alias = AGN_OAMCustomerRegUtils.generateRandomString(8);
            
            customerUser.Email = customer.PersonEmail.toLowerCase();
            customerUser.Phone = customer.Phone;
            customerUser.FirstName = customer.FirstName;
            customerUser.LastName = customer.LastName;
            customerUser.Alias = alias;
            customerUser.LanguageLocaleKey = allDetails.User_Language__c;
            customerUser.EmailEncodingKey = 'UTF-8';
            customerUser.LocalesIdKey = allDetails.User_Locale__c;
            customerUser.TimezonesIdKey = allDetails.User_Timezone__c;
            customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1].Id;
            customerUser.UserName = customer.PersonEmail.toLowerCase() + '.' +  (String)OAM_User_Settings__c.getValues(customer.Country_Code__c).get('Username_Suffix__c');
            customerUser.ContactId = customer.PersonContactId;
            customerUser.Country_Code__c = customer.Country_Code__c;
            customerUser.Division = customer.Customer_Sub_Category_AGN__c;
            customerUser.FederationIdentifier = customer.PersonEmail.toLowerCase(); //SSO Mapping
            
            insert customerUser;
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        System.debug('@@customerUser.id @@'+customerUser.id);
        // return customerUser.id;
    }
    
    
    public static Map<String,List<String>> getBillToShipToFilter(List<String> billToSapIdActiveSF,
                                                                 List<String> shipToSapIdActiveSF,                                                                 
                                                                 List<String> billToSapIdInActiveSF,
                                                                 List<String> shipToSapIdInActiveSF,
                                                                 String oktaId,
                                                                 String countryCode
                                                                )
    {
        String OKTABASEURL = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_Base_URL_AGN__c');
        String OKTAAPIKEY = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_API_Key_AGN__c');
        
        Map<String,List<String>> dataMap=null;
        
        List<String> billToSapIdActiveOkta =new List<String>();
        List<String> shipToSapIdActiveOkta= new List<String>();
        HttpResponse response = AGN_Okta.GetUserDetails(OKTABASEURL, OKTAAPIKEY, oktaId);
        if(response != null){
            
            dataMap = new Map<String,List<String>>();
            //found user
            if (response.getStatusCode() == 200) {
                AGN_OktaUserSuccessResponse respUser = AGN_OktaUserSuccessResponse.parse(response.getBody());
                
                shipToSapIdActiveOkta=respUser.profile.ad_associated_shipto_accounts;
                billToSapIdActiveOkta=respUser.profile.ad_associated_payer_accounts;
                
            }
            
            System.debug('shipToSapIdActiveOkta : '+shipToSapIdActiveOkta);
            System.debug('billToSapIdActiveOkta : '+billToSapIdActiveOkta);                                                         
            
            if(billToSapIdActiveOkta !=null && !billToSapIdActiveOkta.isEmpty()){
                billToSapIdActiveSF.addAll(billToSapIdActiveOkta);
                
            }
            if(shipToSapIdActiveOkta !=null && !shipToSapIdActiveOkta.isEmpty()){
                shipToSapIdActiveSF.addAll(shipToSapIdActiveOkta);   
                
            }
            
            
            // System.debug('Add Two List billToSapIdActiveSF : '+billToSapIdActiveSF);
            // System.debug('Add Two List shipToSapIdActiveSF : '+shipToSapIdActiveSF);
            
            Set<String>  billToActiveSet = new Set<String>(billToSapIdActiveSF);
            Set<String>  shipToActiveSet = new Set<String>(shipToSapIdActiveSF);                                                                     
            System.debug('billToActiveSet : '+billToActiveSet);
            System.debug('shipToActiveSet : '+shipToActiveSet);                                                                              
            Set<String>  billToInActiveSet = new Set<String>(billToSapIdInActiveSF);
            Set<String>  shipToInActiveSet = new Set<String>(shipToSapIdInActiveSF);               
            System.debug('billToInActiveSet : '+billToInActiveSet);
            System.debug('shipToInActiveSet : '+shipToInActiveSet);                                                         
            
            for(String sapIdBillTo: billToInActiveSet){
                if(billToActiveSet.contains(sapIdBillTo))
                    billToActiveSet.remove(sapIdBillTo);
            }
            // system.debug('====billToActiveSet==='+billToActiveSet);
            // system.debug('====billToInActiveSet==='+billToInActiveSet);                                                         
            
            for(String sapIdShipTo: shipToInActiveSet){
                if(shipToActiveSet.contains(sapIdShipTo))
                    shipToActiveSet.remove(sapIdShipTo);
            }
            // system.debug('====shipToActiveSet==='+shipToActiveSet);
            // system.debug('====shipToInActiveSet==='+shipToInActiveSet);   
            List<String> listShipTo=new List<String>();
            listShipTo.addAll(shipToActiveSet); 
            List<String> listBillTo=new List<String>();
            listBillTo.addAll(billToActiveSet);
            dataMap.put('shipToActiveList',listShipTo); 
            dataMap.put('billToActiveList',listBillTo);  
            
            system.debug('====billToActiveList final==='+listShipTo);
            system.debug('====billToInActiveList final==='+listBillTo);        
        }    
        
        
        return dataMap;
    }
    
    @future
    public static void createCommunityUser(Id customerAccountId , String selectedUserLocale) {
        system.debug('customerAccountId>>>>>>>>>>>>>>>>>>>>>'+customerAccountId);
        string alias = '';
        Account customer = [select Id, Name, PersonContactId, FirstName, Country_Code__c, LastName, PersonEmail, Phone, Customer_Category_AGN__c, Customer_Sub_Category_AGN__c from Account where Id =: customerAccountId limit 1];
        OAM_User_Settings__c allDetails = OAM_User_Settings__c.getInstance(customer.Country_Code__c);
        User customerUser = new User();
        if(customer.Country_Code__c == 'CA'){
            if(String.isNotBlank(selectedUserLocale)){
                if(selectedUserLocale.containsIgnoreCase('en')){
                    customerUser.LanguageLocaleKey = 'en_US';
                    customerUser.LocalesIdKey = 'en_CA';
                }else if(selectedUserLocale.containsIgnoreCase('fr')){
                    customerUser.LanguageLocaleKey = 'fr';
                    customerUser.LocalesIdKey = 'fr_CA'; 
                }
            }else{
                customerUser.LanguageLocaleKey = allDetails.User_Language__c;
                customerUser.LocalesIdKey = allDetails.User_Locale__c; 
            }
        }else{
            customerUser.LanguageLocaleKey = allDetails.User_Language__c;
            customerUser.LocalesIdKey = allDetails.User_Locale__c; 
        }
        
        
        try {     
            alias = AGN_OAMCustomerRegUtils.generateRandomString(8);
            
            customerUser.Email = customer.PersonEmail.toLowercase();
            customerUser.Phone = customer.Phone;
            customerUser.FirstName = customer.FirstName;
            customerUser.LastName = customer.LastName;
            customerUser.Alias = alias;
            customerUser.EmailEncodingKey = 'UTF-8';
            customerUser.TimezonesIdKey = allDetails.User_Timezone__c;
            customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1].Id;
            customerUser.UserName = customer.PersonEmail.toLowercase() + '.' + (String)OAM_User_Settings__c.getValues(customer.Country_Code__c).get('Username_Suffix__c');
            customerUser.ContactId = customer.PersonContactId;
            customerUser.Country_Code__c = customer.Country_Code__c;
            customerUser.Division = customer.Customer_Sub_Category_AGN__c;
            customerUser.FederationIdentifier = customer.PersonEmail.toLowercase(); //SSO Mapping
            
            insert customerUser;
            
            system.debug('@@@@@ customerUser @@@@'+customerUser);
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        //return customerUser.Id;
    }
}