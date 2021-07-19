({
    setDefaultStyles : function(component) {
        component.set("v.bodyBackground", "background-color: #fffff0;");
		component.set("v.portalLabelStyle", "background-color: #f7f7f7; font-weight: bold; color: #2C3539;");
    },
    applyStyleAction : function(component, action) {
        //action(component, "v.bodyBackground");
        action(component, "v.portalLabelStyle");
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
            console.log(match);
            return match.includes("background") ? "background-color: #1F262A; " : "color: white;"
        }));
    },
    highContrastYellow : function(component, style) {
        let styleString = component.get(style) + ';';
        component.set(style, styleString.replace(/(background-color|color)\:.{3,19};/g, match => { 
            return match.includes("background") ? "background-color: #2C3539; " : "color: yellow;"
        }));
    }
})