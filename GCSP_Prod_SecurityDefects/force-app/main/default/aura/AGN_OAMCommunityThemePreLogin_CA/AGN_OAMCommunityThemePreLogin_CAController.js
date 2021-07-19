({
    init : function(component, event, helper) {
        helper.fetchFooterConsents(component, event);
        var today = $A.localizationService.formatDate(new Date(), "YYYY");
        component.set('v.today', today);
        //console.log($A.get("$Locale.language"));
    },
	scriptsLoaded : function(component, event, helper) {
		jQuery.noConflict();
        jQuery(document).mouseup(function (e){
            var container= jQuery('.footer_popup');
            if (!container.is(e.target)&& container.has(e.target).length === 0) {
                container.hide();
            }
        });
        jQuery(".footer .privacy-statement").on('click', function() {
            jQuery('.condition-text').hide();
            jQuery('.footer_popup').show();
            jQuery('.privacy-text').show();
                    
    	});
    
    	jQuery(".footer .condition-use").on('click', function() {
            jQuery('.privacy-text').hide();
            jQuery('.footer_popup').show();
            jQuery('.condition-text').show();
                    
    	});
	}
})