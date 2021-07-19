({
  doInit: function(component, event, helper) {
    helper.setFieldMetadata(component, event);
  },
  handleFieldValueChanged: function(component, event, helper) {
    helper.handleFieldValueChanged(component, event);
  },
  showReportValidity: function(component, event, helper) {
    component.find("inputField").showHelpMessageIfInvalid();
  }
});