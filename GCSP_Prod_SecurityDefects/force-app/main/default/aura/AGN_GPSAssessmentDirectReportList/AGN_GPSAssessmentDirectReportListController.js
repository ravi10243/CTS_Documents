({
    doInit : function(component, event, helper) {
        console.log('start');
        var page = component.get('v.page') || 1;
        console.log('page:' + page);
        // get the select option (drop-down) values.
        var recordToDisply = component.find('recordSize').get('v.value');
        console.log('recordToDisply:' + recordToDisply);
        helper.fetchDirectReports(component, page, recordToDisply);
        helper.fetchTotalRecords(component, event, recordToDisply);
    },
    previousPage : function(component, event, helper) {
        // this function call on click on the previous page button
        var page = component.get('v.page') || 1;
        // get the previous button label
        var direction = event.getSource().get('v.label');
        // get the select option (drop-down) values.
        var recordToDisply = component.find('recordSize').get('v.value');
        // set the current page,(using ternary operator.)
        page = direction === 'Previous Page' ? (page - 1) : (page + 1);
        // call the helper function
        helper.fetchDirectReports(component, page, recordToDisply);

    },
    nextPage : function(component, event, helper) {
        // this function call on click on the next page button
        console.log('next');
        var page = component.get('v.page') || 1;
        // get the next button label
        var direction = event.getSource().get('v.label');
        // get the select option (drop-down) values.
        var recordToDisply = component.find('recordSize').get('v.value');
        // set the current page,(using ternary operator.)  '(page + 1)'
        page = direction === 'Previous Page' ? (page - 1) : (page + 1);
        // call the helper function
        helper.fetchDirectReports(component, page, recordToDisply);
    },
    onSelectChange : function(component, event, helper) {
        // this function call on the select opetion change,
        var page = 1
        var recordToDisply = component.find('recordSize').get('v.value');
        helper.fetchDirectReports(component, page, recordToDisply);
        helper.fetchTotalRecords(component, event, recordToDisply);
    },
    showUserAssessments : function(component, event, helper) {
        //alert(event.target.dataset.userid);
        console.log(event.target.id);
        var userId = event.target.id;
        console.log('userId='+userId);
        component.set('v.isOpen', true);
        component.find('assessmentAssignments').set('v.userId', userId);
        console.log(component.find('assessmentAssignments').get('v.userId'));
    },
    closeModal: function(component, event, helper) {
      // for Hide/Close Model,set the 'isOpen' attribute to 'Fasle'
      component.set('v.isOpen', false);
    },
})