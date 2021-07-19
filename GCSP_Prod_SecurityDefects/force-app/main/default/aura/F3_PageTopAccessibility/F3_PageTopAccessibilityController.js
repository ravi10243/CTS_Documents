({
	fireAccessibilityEvent : function (component, event, helper) {
        try{
            let action = event.target.value;
            let accessibilityEvent = $A.get("e.c:AccessibilityControlEvent");
            accessibilityEvent.setParams({
                "action": action
            });
            accessibilityEvent.fire();
        } catch (err) {
            console.error(err);
        }
    }
})