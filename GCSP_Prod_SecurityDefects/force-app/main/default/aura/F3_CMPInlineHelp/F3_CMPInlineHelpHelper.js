({
    setDefaultStyles : function(component) {
        let fontStyle = component.get("v.fontStyle");
        let fontSize = component.get("v.fontSize");
        let backgroundColor = component.get("v.backgroundColor");
		let fontColor = component.get("v.color");
       
        
        let bodyBackground = "background-color:" + backgroundColor;
        let textStyle = "font-style:" + fontStyle + "; font-size:" + fontSize + "px; color:" + fontColor;
        component.set("v.bodyBackground", bodyBackground);
        component.set("v.textStyle", textStyle);
    },
    applyStyleAction : function(component, action) {
        action(component, "v.bodyBackground");
        action(component, "v.textStyle");
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