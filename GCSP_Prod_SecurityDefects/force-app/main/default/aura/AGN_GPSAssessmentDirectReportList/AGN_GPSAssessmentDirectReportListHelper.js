({
    fetchDirectReports : function(component, page, recordToDisply) {
         console.log('start1');
        var action = component.get('c.getDirectReports');
        action.setParams({
            'userId': component.get('v.userId'),
            'pageNumber': page,
            'recordToDisply': recordToDisply
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set('v.wrapperList', response.getReturnValue());
                component.set('v.page',page);

                console.log('page:' + component.get('v.page'));
            } else if(response.getState() == 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchTotalRecords : function(component, event, recordToDisply) {
        console.log('starttot');
        var action = component.get('c.getTotal');
        action.setParams({
            'userId': component.get('v.userId'),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set('v.total',response.getReturnValue());
                component.set('v.pages', Math.ceil(response.getReturnValue() / recordToDisply));

                console.log('total:' + component.get('v.total'));
                console.log('pages:' + component.get('v.pages'));
            } else if(response.getState() == 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchUserAssessments : function(component, event, helper) {
        console.log('startass:' + event.target.id);
        var action = component.get('c.getUserAssessments');
        action.setParams({
            'assessmentId': event.target.id,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set('v.assessments',response.getReturnValue());
            } else if(response.getState() == 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
})