({
	// Your renderer method overrides go here
	afterRender: function (component, helper) {
        var socialSites = ["facebook_mobile","instagram_mobile" ];
        socialSites.forEach(sitesIteration);

        function sitesIteration(item) {
           var svg = component.find(item);
           var value = svg.getElement().innerText;
           value = value.replace("<![CDATA[", "").replace("]]>", "");
           svg.getElement().innerHTML = value; 
           //alert(item);
        }
         
        
       
    }
})