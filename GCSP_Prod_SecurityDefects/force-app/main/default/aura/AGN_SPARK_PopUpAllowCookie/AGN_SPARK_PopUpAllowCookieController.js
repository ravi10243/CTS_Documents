({
	popupLogin : function(component, event, helper) {
        var d = new Date();
        d.setTime(d.getTime() + (365 * 24 * 60 * 60 * 1000));
        var expires = "expires="+d.toUTCString();
        document.cookie = "cookieAckg=true;" + expires + ";path=/";
        $A.util.addClass(component.find('popUpLogin'), 'slds-hide');
        
	},
    showReadMore: function(component, event, helper) {
        $A.util.removeClass(component.find('readMore'), 'slds-hide');
        $A.util.addClass(component.find('readMoreBtn'), 'slds-hide');
        $A.util.addClass(component.find('popup_login'), 'scrollClass');
	},
    showReadLess: function(component, event, helper) {
        $A.util.addClass(component.find('readMore'), 'slds-hide');
        $A.util.removeClass(component.find('readMoreBtn'), 'slds-hide');
        $A.util.removeClass(component.find('popup_login'), 'scrollClass');
	},
    getCookie: function(cname) {
        //alert('Inside getCookie');
        var name = cname + "=";
        var ca = document.cookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];
            alert(c);
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    },
    
    doInit : function(component, event, helper) {
        
       
           
    },
})