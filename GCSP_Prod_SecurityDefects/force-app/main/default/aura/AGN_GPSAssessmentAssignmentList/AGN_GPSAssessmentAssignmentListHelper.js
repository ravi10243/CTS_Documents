({
    getAssessments : function(component, event) {
        var action = component.get('c.getGPSAssessmentsForListView');
        action.setParams({
            'ownerId'        : component.get('v.userId'),
            'sortField'      : component.get('v.sortField'),
            'sortIsAsc'      : component.get('v.sortIsAsc'),
            'recordsPerPage' : component.find('recordsPerPage').get('v.value'),
            'pageNumber'     : component.get('v.pageNumber')
        })

        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            if(response.getState() === 'SUCCESS') {
                component.set('v.assessmentStats', response.getReturnValue());
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);

        var totalsAction = component.get('c.getGPSAssessmentsTotalCountForListView');
        totalsAction.setParams({
            'ownerId' : component.get('v.userId')
        });
        totalsAction.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var totalRecords = response.getReturnValue();
                component.set('v.totalRecords', totalRecords);

                var recordsPerPage = component.find('recordsPerPage') ? component.find('recordsPerPage').get('v.value') : '';
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
    },
})