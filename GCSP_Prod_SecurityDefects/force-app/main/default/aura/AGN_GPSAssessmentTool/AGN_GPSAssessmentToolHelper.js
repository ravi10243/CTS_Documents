({
    getUserInfo : function(component, event) {
        console.log('currentuser');
        var action = component.get('c.getCurrentUser');
        action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() == 'SUCCESS') {
                var user = response.getReturnValue();
                console.log(user);
                component.set('v.userId', user.Id);
                component.set('v.user', user);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getSettings : function(component, event) {
        console.log('currentuser');
        var action = component.get('c.getGPSSettings');
        action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() == 'SUCCESS') {
                var settings = response.getReturnValue();
                component.set('v.settings', settings);
                component.set('v.view', settings.View_AGN__c);
            }
        });
        $A.enqueueAction(action);
    },
})