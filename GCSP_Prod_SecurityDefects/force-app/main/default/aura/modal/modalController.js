({
    openModal : function(component, event, helper) {
        // for Display Model,set the 'isOpen' attribute to 'true'
        component.set('v.isOpen', true);
        document.body.style.overflow = 'hidden';
        console.log('v.isOpen=' + component.get('v.isOpen'));
    },
    closeModal : function(component, event, helper) {
        // for Hide/Close Model,set the 'isOpen' attribute to 'Fasle'
        component.set('v.isOpen', false);
        document.body.style.overflow = 'auto';
    },
})