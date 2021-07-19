({
	setFilteredForms : function(forms, component) {
        let currentPage = component.get("v.currentPage");
		let recordsPerPage = component.get("v.recordsPerPage");
        component.set("v.filteredForms", forms);
        let startIndex = (currentPage - 1) * recordsPerPage;
        let endIndex = startIndex + recordsPerPage;
        if(forms.length < endIndex) {
            component.set("v.currentBatch", forms.slice(startIndex));
            component.set("v.finalPage", true);
        } else {
            component.set("v.currentBatch", forms.slice(startIndex, endIndex));
            component.set("v.finalPage", forms.length == endIndex);
        }
	}
})