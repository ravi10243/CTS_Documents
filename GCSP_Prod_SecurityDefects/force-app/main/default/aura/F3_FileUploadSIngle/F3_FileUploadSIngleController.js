({
	doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
            
        } else {
            alert('Please Select a Valid File');
        }
    },
 
    handleUploadFinished: function(component, event, helper) {
        alert('Upload start');
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        //helper.getAttachmentList(component);
        component.set("v.fileName", fileName);
        alert('Upload End');
    },
    doInit : function(component, event, helper) {
        try {
            //alert('in DoInit');
            //helper.getAttachmentList(component,event,helper);
        } catch (err) {
            console.log(err);
        }
    }
})