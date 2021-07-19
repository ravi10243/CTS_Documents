({
    getAssessments : function(component, event) {
        var action = component.get('c.getGPSAssessments');
        action.setParams({
            'sortField' : component.get('v.sortField'),
            'sortIsAsc' : component.get('v.sortIsAsc'),
            'recordsPerPage' : component.find('recordsPerPage').get('v.value'),
            'pageNumber' : component.get('v.pageNumber')
        })
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.assessments', response.getReturnValue());
            } else if (response.getState() === 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);

        var totalsAction = component.get('c.getGPSAssessmentsTotalCount');
        totalsAction.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var totalRecords = response.getReturnValue();
                component.set('v.totalRecords', totalRecords);

                var recordsPerPage = component.find('recordsPerPage').get('v.value');
                var totalPages = Math.ceil(totalRecords / recordsPerPage);
                component.set('v.totalPages', totalPages);
            } else if (response.getState() === 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(totalsAction);
    }
})