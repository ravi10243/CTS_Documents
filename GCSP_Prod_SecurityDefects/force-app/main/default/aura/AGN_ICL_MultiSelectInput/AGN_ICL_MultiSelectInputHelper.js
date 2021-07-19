({

    setInfoText: function(component, labels) {

        if (labels.length === 0) {

            component.set("v.infoText", "Select an option...");

        }

        if (labels.length === 1) {

            component.set("v.infoText", labels[0]);

        }

        else if (labels.length > 1) {

            component.set("v.infoText", labels.length + " options selected");

        }

    },

    

    getSelectedValues: function(component){

        var options = component.get("v.options_");

        console.log('options:='+options);

        var values = [];

        if(options!==undefined){

            options.forEach(function(element) {

                if (element.selected) {

                    values.push(element.Name);

                }

            });

        }

   return values;

    },

    

    getSelectedLabels: function(component){

        var options = component.get("v.options_");

        var labels = [];

        if(options!==undefined){

            options.forEach(function(element) {

                if (element.selected) {

                    labels.push(element.Name);

                }

            });  

        }

        

        return labels;

    },

    

    despatchSelectChangeEvent: function(component,values){
		
        //($A.get("e.c:AGN_ICL_MultiSelectChangeEvent")).setParams({
           // "message": 'Cool'
        //}).fire();
        var compEvent = component.getEvent("SelectedBrandValues");
		console.log('Values in Event'+values);
        var car = ["AB","BC","CD"];
        compEvent.setParams({ "values": values });
		//compEvent.setParams({ "message": 'Cool' });
        compEvent.fire();

    }

})