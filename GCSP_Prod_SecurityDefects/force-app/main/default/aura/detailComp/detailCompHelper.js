({
  getRecord : function(component) {
   var fields = component.get("v.fieldsToShow");
   var recordId = component.get("v.recordId");
   var action = component.get("c.getRecords");
   var fieldList = fields.split(',');
   var fieldMap = new Object();
   console.log(fieldList);
   component.set("v.fieldList",fieldList);
   action.setParams({
     recordId:recordId,
     fieldsToShow:fields
   });
  
   action.setCallback(this,function(a){
     console.log(a.getReturnValue());
     var sobjectrecord = a.getReturnValue();
     for (var idx in sobjectrecord) {
        $A.createComponent(
           "lightning:accordionSection",
         {
           "name": sobjectrecord[idx]["Id"],
           "label": sobjectrecord[idx]["Name"] ,
         },
         function(newCmp){
            //Add the field list to the body array
            if (component.isValid()) {
               var body = component.get("v.body");
               body.push(newCmp);
               component.set("v.body", body);
         }
       }
    );
       
      }
   
  component.set("v.detailRecord",a.getReturnValue());
 });
 $A.enqueueAction(action);
 }
})