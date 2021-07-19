({
    setDefaultStyles : function(component) {
        let headerFontStyle = component.get("v.headerFontStyle");
        let headerFontSize = component.get("v.headerFontSize");
        let backgroundColor = component.get("v.backgroundColor");
        let headerColor = component.get("v.headerColor");
        
        let style = 'font-style:' + headerFontStyle 

        + ';font-size:' + headerFontSize + 'px' 
                + ';background-color:'+ backgroundColor
        + ';color:' + headerColor;
        component.set("v.headerStyle", style);
    },
    applyStyleAction : function(component, action) {
        action(component, "v.headerStyle");
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