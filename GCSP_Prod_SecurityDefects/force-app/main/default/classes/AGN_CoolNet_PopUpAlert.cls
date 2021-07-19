public class AGN_CoolNet_PopUpAlert
{
    public boolean displayPopup {get; set;} 
    private String countryCode;//FetchCountryCode to Show Popup
    public List<CoolNet_Terms_Conditions_AGN__c> tnc{get;set;}
    
    public boolean displayTermsConditions {get; set;}
    public String loggedInUser {get; set;} 
    public AGN_CoolNet_PopUpAlert(){
        termsAndConditions = this.termsAndConditionsValue();
        tnc = New List<CoolNet_Terms_Conditions_AGN__c>();
        //FetchCountryCode to Show Popup
        countryCode = ApexPages.currentPage().getParameters().get('countryCode');
        List<User> usersList = [SELECT Id,Username,Country_Code__c,CoolNet_Terms_AGN__c FROM User WHERE IsActive = true AND Country_Code__c='AN' 
        AND Id = :UserInfo.getUserId()];
        
        tnc= [select Terms_AGN__c from CoolNet_Terms_Conditions_AGN__c where Country_Code_AGN__c='AN'];
        //DisplayPopup - Make displaypopup true if countryCode is 'AN' and if coolnet User checkbox is not checked already.
        //System.debug('UserList## '+usersList.isEmpty() + '   '+  countryCode+ '   '+usersList.get(0).CoolNet_Terms_AGN__c);
         if(!usersList.isEmpty() && !usersList.get(0).CoolNet_Terms_AGN__c && usersList.get(0).Country_Code__c.contains('AN')){
               
               
               displaypopup = true;
           }
        displayTermsConditions = false;
        if(countryCode == 'GB'){
          List<User> users = [SELECT Id,Username,Country_Code__c FROM User WHERE IsActive = true and id = :UserInfo.getUserId()];
            if(!users.isEmpty()){
                loggedInUser = users.get(0).Username;
            }
            showTermsAndConditions(loggedInUser); 
        }
          
           
    }
    
    //PMO - 3627 
    public boolean acceptTerms { get; set;}
    public void showTermsAndConditions(String user){
         
        //Cookie counter = ApexPages.currentPage().getCookies().get('counter');
        
        String keyName = user+'_acceptterms';
        System.debug('Cookie key '+ keyName);
        try{
            Map<String, System.Cookie> cookieMap = ApexPages.currentPage().getCookies();
             System.debug('Cookie keyset '+ cookieMap);
            if(cookieMap != null && cookieMap.containsKey(keyName)){
                Cookie cookieTerm = cookieMap.get(keyName);
                if(cookieTerm != null){
                   acceptTerms = Boolean.valueof(cookieTerm.getValue()); 
                   system.debug('Cookie value '+ cookieTerm.getValue());
                }
                 
            }
           system.debug('Cookie Map '+ cookieMap);
        
        if(!acceptTerms) {
          displayTermsConditions = true;    
        }
        
        }
        Catch(Exception e ){
            displayTermsConditions = true;  
            System.debug('Exception occurred in cookies ' + e.getMessage());
        }
        
    }
    public void closePopup(){      
        displayPopup = false;  
    }    
    public void redirectPopup()
    {
        List<User> usersList = [SELECT Id,Country_Code__c,CoolNet_Terms_AGN__c FROM User WHERE IsActive = true AND Country_Code__c='AN' AND Id = :UserInfo.getUserId()];
        system.debug('users## ' + usersList);
        tnc = [select Terms_AGN__c from CoolNet_Terms_Conditions_AGN__c where Country_Code_AGN__c='AN'];
        //DisplayPopup - Make displaypopup true if countryCode is 'AN' and if coolnet User checkbox is not checked already.
       //System.debug('UserList## '+usersList.isEmpty() + '   '+usersList.get(0).CoolNet_Terms_AGN__c);
        if(usersList.isEmpty() && !usersList.get(0).CoolNet_Terms_AGN__c && usersList.get(0).Country_Code__c.contains('AN'))
          {
            
            displaypopup = true;
            update usersList;
        }
        usersList.get(0).CoolNet_Terms_AGN__c = true;
        update usersList;
        displayPopup = false;
    }
    
      //PMO - 3627
     public PageReference storeTermsConditions()
    {
        //System.debug('Call apex method from javascript');
        Pagereference pr = new Pagereference('/apex/AGN_CoolNetHomePage?countryCode=GB');
        String keyName = loggedInUser +'_acceptterms';
        Integer expiryTime = 395*24*3600;
        Cookie cook = new Cookie(keyName, 'true', null, expiryTime, false);
        ApexPages.currentPage().setCookies(new Cookie[]{cook});
        pr.setRedirect(true);
        return pr;
        
    }
    
    public PageReference logOut()
    {
        return null;
        
    }
    
    //PMO - 3627
    public String termsAndConditions {get; set;}
    public String termsAndConditionsValue(){
        String s = 'This Copyright Licence Agreement (“Licence”), is made by and between: '+ '<br/>' 
                +'Allergan Ltd (“Allergan”) and the Customer, the details for which appear '+'<br/>'
                +'below. “Allergan” shall be taken to include all Allergan affiliated '+'<br/>'
                +'companies.'+'<br/>'
                +'In consideration of the Customer agreeing to be bound by the terms and '+'<br/>'
                +'condition set out herein, Allergan hereby grants the Customer a non-exclusive '+'<br/>'
                +'royalty-free licence to use, copy, print, publish and/or distribute certain '+'<br/>'
                +'images, print and other copyright materials belonging to Allergan (“Allergan '+'<br/>'
                +'Copyright Materials”) solely in the Territory identified in the Customer Order '+'<br/>'
                +'Form on the following terms and conditions: '+'<br/>'
                +'1. Term and termination. The Licence shall commence on the date of '+'<br/>'
                +'signature hereof and shall continue indefinitely, subject to the right of either '+'<br/>'
                +'party to terminate the License on at least three (3) months’ written notice '+'<br/>'
                +'at any time; PROVIDED THAT Allergan may terminate this Licence at any '+'<br/>'
                +'time on one (1) month’s prior written notice for any reason whatsoever. '+'<br/>'
                +'Upon termination of the Licence, the Customer shall immediately cease '+'<br/>'
                +'using the Allergan Copyright Materials and shall return all such Allergan '+'<br/>'
                +'Copyright Materials to Allergan. '+'<br/>'
                +'2. Allergan Copyright Materials. The parties shall agree the form and '+'<br/>'
                +'content of the Allergan Copyright Materials to be supplied by Allergan to '+'<br/>'
                +'Customer hereunder, and shall keep a record thereof, including the date '+'<br/>'
                +'of supply. The Customer shall not make any changes to the Allergan '+'<br/>'
                +'Copyright Materials without the prior written consent of Allergan. Allergan '+'<br/>'
                +'reserves the right to change the Allergan Copyright Materials at any time, '+'<br/>'
                +'and to require the Customer to cease using them by giving the Customer '+'<br/>'
                +'no less than one (1) month prior written notice. '+'<br/>'
                +'3. Use of Allergan Copyright Materials. The Customer may use, copy, '+'<br/>'
                +'print, publish and/or distribute the Allergan Copyright Materials for any '+'<br/>'
                +'lawful business purpose via any electronic, hard copy or other medium; '+'<br/>'
                +'PROVIDED THAT the Customer hereby warrants and undertakes that '+'<br/>'
                +'it will only use the Allergan Copyright Materials in accordance with all '+'<br/>'
                +'applicable laws and regulations, including without limitation laws relating '+'<br/>'
                +'to advertising, promoting and selling pharmaceutical and medical device '+'<br/>'
                +'healthcare products. '+'<br/>'
                +'4. Customer materials. The Customer shall supply Allergan with a sample '+'<br/>'
                +'of all of its materials containing the Allergan Copyright Materials. '+'<br/>'
                +'5. Indemnity and liability. The Customer hereby indemnifies Allergan '+'<br/>'
                +'against any claims for loss, damage, costs, expenses, injury or death '+'<br/>'
                +'to third parties arising (directly or indirectly) out of or concerned with '+'<br/>'
                +'the negligence, breach of duty of care or any other act or omission of '+'<br/>'
                +'the Customer arising under this Licence and the use of the Allergan '+'<br/>'
                +'Copyright Materials. Allergan make no guarantee or warranty that '+'<br/>'
                +'the Allergan Copyright Materials are fit for the purpose intended. Any '+'<br/>'
                +'condition, warranty or other term, which might otherwise be implied or '+'<br/>'
                +'incorporated within this Licence by reason of statute or common law or '+'<br/>'
                +'otherwise, is hereby excluded to the fullest extent permitted by law and in '+'<br/>'
                +'no circumstances shall Allergan be liable for any indirect or consequential '+'<br/>'
                +'loss or damage of any nature or description no matter how arising. '+'<br/>'
                +'6. Intellectual property rights. All intellectual property rights including '+'<br/>'
                +'without limitation those involving or relating to trade names, trademarks, '+'<br/>'
                +'database protection rights, patentable inventions, non patentable '+'<br/>'
                +'processes or know how, computer software, designs and/or copyright'+'<br/>'
                +'relating to the Allergan Copyright Materials and/or any of Allergan '+'<br/>'
                +'products (“IPR”) are the sole property of Allergan. Allergan is making no '+'<br/>'
                +'grant either actual or implied to Customer of any of its IPR, except as '+'<br/>'
                +'explicitly contained herein. Customer shall not use, register or attempt to '+'<br/>'
                +'register in any jurisdiction, or otherwise appropriate or adopt, any name, '+'<br/>'
                +'mark or logo that is confusingly similar to Allergan’s IPR. At no time during '+'<br/>'
                +'the term of these Conditions or thereafter shall the Customer attack, '+'<br/>'
                +'challenge or file any application with respect to any Allergan IPR. '+'<br/>'
                +'7. Copyright notice. The Customer shall display the following copyright '+'<br/>'
                +'notice on any Customer materials that use the Allergan Copyright '+'<br/>'
                +'Materials: ‘Reproduced with permission from Allergan; © Allergan '+'<br/>'
                +'2009’. '+'<br/>'
                +'8. No partnership. The Customer shall not in any way create the impression '+'<br/>'
                +'that it is acting as an agent or representative of Allergan, or that it is '+'<br/>'
                +'engaged in co-promotion activities with Allergan. Nothing in this Licence '+'<br/>'
                +'will create any partnership or joint venture between Allergan and the '+'<br/>'
                +'Customer, and neither party will have the authority to act as agent for or '+'<br/>'
                +'enter into any commitments on behalf of the other. '+'<br/>'
                +'9. Non-Assignment. This Licence is personal to the Customer and may not '+'<br/>'
                +'be assigned or otherwise transferred without first obtaining Allergan’s prior '+'<br/>'
                +'written consent. Allergan may freely assign the Licence or any benefit '+'<br/>'
                +'arising under it to any associated company or for any legitimate business '+'<br/>'
                +'purpose. '+'<br/>'
                +'10. Governing Law. This Licence shall be construed in accordance with the '+'<br/>'
                +'laws of Ireland and any dispute arising in relation to these Conditions shall '+'<br/>'
                +'be subject to the jurisdiction of the Irish courts. '+'<br/>'
                +'1st Floor, Marlow International, The Parkway, Marlow, Buckinghamshire SL7 1YL '+'<br/>'
                +'10001P'+'<br/>';
        return s;
    }
    
}