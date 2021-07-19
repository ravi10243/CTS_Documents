({
    getAccounts : function(component, helper) {
        var action = component.get("c.getLimitedAccounts");
        action.setStorable();
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Response Time: '+((new Date().getTime())-requestInitiatedTime));
                component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
                component.set("v.allData", response.getReturnValue());
               // component.set("v.data", response.getReturnValue());
                component.set("v.currentPageNumber",1);
               // helper.buildData(component, helper);
            }
        });
        var requestInitiatedTime = new Date().getTime();
        $A.enqueueAction(action);
    },
    
    /*
     * this function will build table data
     * based on current page selection
     * */
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
            	data.push(allData[x]);
            }
        }
        component.set("v.data", data);
        
        helper.generatePageList(component, pageNumber);
    },
    
    /*
     * this function generate page list
     * */
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    },
    deleteClinicById : function(component, event) {
           var target = event.getSource();
           var txtVal = target.get("v.value");
           var clinicList = component.get("v.paginationclinicDetails");
           var action = component.get("c.delClinicById");
           action.setParams({loc : clinicList[txtVal]});
           action.setCallback(this, function(response) {
               if(response.getReturnValue())
               {
                  
                   this.FetchCliniclist(component, event); 
                  
               }
               else
               {
                   this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
               }

        });
        $A.enqueueAction(action);
	},
    
    editClinicById : function(component, event) {
           var target = event.getSource();
           var txtVal = target.get("v.value");
           var practitionerList = component.get("v.paginationclinicDetails");
        component.set("v.clinicDetails",clinicList[txtVal]);
        component.set("v.openModal", true);
    },
    showTosteMessage : function(component, title, type, message, mode) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent){
            toastEvent.setParams({
                title: title,
                type: type,
                message: message,
                mode: mode
            });
            toastEvent.fire();
        }
        // if not running in LEX or SF1, toast is not available - use alert
        else {
            alert(message);
        }
    },
    
    FetchCliniclist : function(component, event){
        var action = component.get("c.fetchClinicDetails");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.clinicDetails", response.getReturnValue());
                component.set("v.spinner",false);
                var cliniclength = response.getReturnValue().length;
                var Countryname=response.getReturnValue()[0].Country_AGN__c;
                component.set("v.GTMCountry",Countryname);
                component.set("v.previous",0);
                component.set("v.start",10);
                component.set("v.end",cliniclength);
                console.log('cliniclength'+cliniclength);
                if(cliniclength > 10)
                {
                    var paginationList = [];
                    for(var i=0; i<10; i++)
                    {
                        paginationList.push(response.getReturnValue()[i]);
                    }
                    component.set("v.paginationclinicDetails",paginationList);
                }
                else
                {
                    component.set("v.paginationclinicDetails", response.getReturnValue());
                    component.set("v.isnextdisable",true);
                }
            }
        });
        
        $A.enqueueAction(action);

    }
   
 })