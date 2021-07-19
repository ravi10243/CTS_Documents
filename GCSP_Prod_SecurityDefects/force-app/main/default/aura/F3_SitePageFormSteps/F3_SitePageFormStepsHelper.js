({
    setDefaultStyles : function(component) {
        component.set("v.tableStyle", "background-color: white;");
        component.set("v.headingStyle", "background-color: white; color: black; font-size: 22px;");
        component.set("v.descriptionStyle", "color: black; font-size: 14px; padding-top: 1em");
        component.set("v.progressIndicatorStyle", "padding-top: 2em; padding-bottom: 2em; background-color: white; height: 100%;");
    },
    applyStyleAction : function(component, action) {
        action(component, "v.tableStyle");
        action(component, "v.headingStyle");
        action(component, "v.descriptionStyle");
        action(component, "v.progressIndicatorStyle");
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
            return match.includes("background") ? "background-color: black;" : "color: white;"
        }));
    },
    highContrastYellow : function(component, style) {
        let styleString = component.get(style) + ';';
        component.set(style, styleString.replace(/(background-color|color)\:.{3,19};/g, match => { 
            return match.includes("background") ? "background-color: black;" : "color: yellow;"
        }));
    }
})