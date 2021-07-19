({
    setDefaultStyles : function(component, helper) {
        let brandJSON = JSON.parse(component.get("v.currentSitePage").DefaultPageForm.BrandingJSON__c)[0];
        component.set("v.headerJson", brandJSON);
        helper.setStyles(component, helper, brandJSON);
    },
    setStyles : function(component, helper, JSON) {
        helper.setStyle(component, helper, JSON.ListElement[0], "v.headerStyle");
        helper.setStyle(component, helper, JSON.ListElement[1], "v.descriptionStyle");
        helper.setStyle(component, helper, JSON.ListElement[2], "v.portalStyle");
    },
    getCorrectProperty : function(property) {
        switch(property) {
            case "font-color" : return "color";
            default: return property;
        }
    },
    getCorrectPropertyValue : function(key, value) {
        switch(key) {
            case "font-size": return value.includes("px") ? value : value + "px";
            default: return value;
        }
	},
    setStyle : function(component, helper, JSON, attribute) {
        const styler = (current, property) => current + ";" + helper.getCorrectProperty(property.PropertyKey) 
                							   		  + ":" + helper.getCorrectPropertyValue(property.PropertyKey, property.PropertyValue);
        let styleString = JSON.ListProperty.reduce(styler, "");
        component.set(attribute, styleString);
    },
    applyStyleAction : function(component, action) {
        action(component, "v.headerStyle");
        action(component, "v.descriptionStyle");
        action(component, "v.portalStyle");
    },
    increaseFontSize: function(component, style) {
        let styleString = component.get(style);
        component.set(style, styleString.replace(/\d+px/g, (match) => (parseInt(match) + 2) + "px"));
    },
    decreaseFontSize : function(component, style) {
        let styleString = component.get(style);
        component.set(style, styleString.replace(/\d+px/g, (match) => (parseInt(match) - 2) + "px"));
    },
    increaseLetterSpacing : function(component, style) {
        let styleString = component.get(style);
        styleString.includes("letter-spacing: 0.2em") ? "" : component.set(style, styleString + '; letter-spacing: 0.2em');
    },
    highContrastWhite : function(component, style) {
        let styleString = component.get(style) + ';';
        component.set(style, styleString.replace(/(background-color|color)\:.{3,19};/g, match => { 
            return match.includes("background") ? "background-color: black; " : "color: white;"
        }));
    },
    highContrastYellow : function(component, style) {
        let styleString = component.get(style) + ';';
        component.set(style, styleString.replace(/(background-color|color)\:.{3,19};/g, match => { 
            return match.includes("background") ? "background-color: black; " : "color: yellow;"
        }));
    }
})