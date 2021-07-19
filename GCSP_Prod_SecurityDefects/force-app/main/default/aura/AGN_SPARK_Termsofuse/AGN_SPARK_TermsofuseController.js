({
	doInit : function(component, event, helper) {
        
        
        helper.getPageImages(component);
	},
    afterRender: function (component, helper) {
    var svg = component.find("facebook");
        var value = svg.getElement().innerText;
        value = value.replace("<![CDATA[", "").replace("]]>", "");
        svg.getElement().innerHTML = value; 
    }
    
    
})