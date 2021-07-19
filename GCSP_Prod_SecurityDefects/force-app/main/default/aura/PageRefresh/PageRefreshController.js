({
        refreshFocusedTab : function(component, event, helper) {
            alert('here');
            var workspaceAPI = component.find("workspace");
            alert(workspaceAPI);
            console.log(workspaceAPI);
            
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                alert('here2');
                var focusedTabId = response.tabId;
                workspaceAPI.refreshTab({
                          tabId: focusedTabId,
                          includeAllSubtabs: true
                 });
            })
            .catch(function(error) {
                alert('here3');
                console.log(error);
            });
        }
    })