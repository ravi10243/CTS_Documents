({
    doInit : function(component, event, helper) {        
       component.set("v.currYear", ''+new Date().getFullYear());
       helper.fetchFooterSettings(component);
       
	},
    afterRender: function (component, helper) {
    var svg = component.find("facebook");
        var value = svg.getElement().innerText;
        value = value.replace("<![CDATA[", "").replace("]]>", "");
        svg.getElement().innerHTML = value; 
    },
	moveToAASite : function(component, event, helper) {        
        helper.navigateToPage('https://www.allergan.co.uk/home/aa');
	},
	/*showMyAccount : function(component, event, helper) {        
        helper.navigateToPage('/my-account-details');
	},
    showTermsOfUse : function(component, event, helper) { 

        helper.navigateToPage('/terms-of-use');
	},
    showPrivacyPolicy : function(component, event, helper) {        
        helper.navigateToPage('/privacy-policy');
	},
    showContactus : function(component, event, helper) {        
        helper.navigateToPage('/contactus');
	},
    showLoginPage : function(component, event, helper) {        
        helper.navigateToPage('login');
	},
    
    showHomePage : function(component, event, helper) {        
        helper.navigateToPage('/');
	},*/
})