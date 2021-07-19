({
	onDragOver : function(component, event, helper) 
    {
        event.preventDefault();
    },
    onDrop: function(component, event, helper)
    {  
        //event.preventDefault();
        component.set("v.dropEntity",null);
        var eventData = event.dataTransfer.getData("dropEntity");
        //alert(eventData);
        var eventAttribute = JSON.parse(eventData);
        component.set("v.dropEntity",eventAttribute);
        console.log('DropEntity--'+JSON.stringify(eventAttribute));        
    },
})