({
    fetchClinic : function(component, event, helper) {
        
        component.set("v.spinner",true);
        component.set("v.showGAInit",true);
        var pageURL=document.URL;
        pageURL =pageURL.split(".com")[1];
        pageURL =pageURL.split("?")[0];
        var pageTitile=document.title;
        component.set("v.GTMPageURL",pageURL);
        component.set("v.GTMPageTitle",pageTitile);
        component.set("v.ispreviousdisable",true);
        $A.get('e.force:refreshView').fire();
        helper.FetchCliniclist(component,event);
       /* var action1 = component.get("c.fetchUserDetails");
        
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.UserName", response.getReturnValue());
            }
        });
        $A.enqueueAction(action1);*/
        //TM2.0 Portal banner related change//
        var serverAction = component.get("c.isSiteUnderMaintenance");
        serverAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isSiteUnderMaintenance", response.getReturnValue());
            }
        });
        $A.enqueueAction(serverAction);
        //TM2.0 Portal banner related change//
        
    var action1 = component.get("c.getclinicadminname");
        
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.UserName", response.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
        var action2 = component.get("c.fetchUsercountry");
        action2.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.countryCode", response.getReturnValue());
            }
        });
        $A.enqueueAction(action2);
    },
    
    RedirectDetailPage : function(component, event, helper) {
        var target = event.getSource();
        var txtVal = target.get("v.value");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/agn-icl-detailpage?lcid="+txtVal
        });
        urlEvent.fire();
    },
    NewClinic : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
                "url": "/agn-icl-newclinicregistration"
            });
        urlEvent.fire();
        
    },
    logout : function(component, event) {
        var baseUrl = $A.get("$Label.c.AGN_ICL_Community_Base_URL");
        var suffixUrl = $A.get("$Label.c.AGN_ICL_Community_Suffix");
        var url = baseUrl + suffixUrl;
        component.set("v.fireLogout", true);
        var action = component.get("c.fetchUsercountry");
        var country;
        action.setCallback(this, function(a) {
              var usr=a.getReturnValue();
             console.log('country1',usr);
            window.location.replace(url + '/AGN_ICL_Portal_Logout?country='+usr);
 		 });
        $A.enqueueAction(action); 
        
              
    },
    NextPage : function(component, event) {
        var stval = component.get("v.start");
        var endval = component.get("v.end");
        var previousval = component.get("v.previous");
        var diffval = endval - stval;
        
        var cliniclst = component.get("v.clinicDetails");
        if(diffval>10)
        {
            var paginationList = [];
            for(var i=stval; i<stval+10; i++)
            {
                paginationList.push(cliniclst[i]);
            }
            //component.set("v.previous",stval);
            //component.set("v.start",stval+10);
            component.set("v.isnextdisable",false);
            component.set("v.ispreviousdisable",false);
            component.set("v.paginationclinicDetails",paginationList);
        }
        else
        {
            var paginationList = [];
            for(var i=stval; i<endval; i++)
            {
                paginationList.push(cliniclst[i]);
            }
            //component.set("v.previous",stval);
            //component.set("v.previous",stval);
            //component.set("v.start",stval+10);
            component.set("v.ispreviousdisable",false);
            component.set("v.paginationclinicDetails",paginationList);
            component.set("v.isnextdisable",true);
        }
        component.set("v.previous",stval);
        component.set("v.start",stval+10);
        
    },
    PreviousPage : function(component, event) {
        var stval = component.get("v.start");
        var endval = component.get("v.end");
        var previousval = component.get("v.previous");
        var diffval = endval - stval;
        var cliniclst = component.get("v.clinicDetails");
        
        var paginationList = [];
      
            for(var i=previousval-10; i<previousval; i++)
            {
                paginationList.push(cliniclst[i]);
            }
            component.set("v.start",stval-10);
            
       
        if(previousval-10 === 0)
        {
            component.set("v.ispreviousdisable",true);
        }
        else
        {
            component.set("v.previous",previousval-10);
        }
        
        
            component.set("v.isnextdisable",false);
        
        component.set("v.paginationclinicDetails",paginationList);
    },
     deleteClinic: function(component,event,helper){  
        var delConfirmMSg = $A.get("$Label.c.AGN_ICL_ClinicDelete_Confirm");
        if(confirm(delConfirmMSg))
    	helper.deleteClinicById(component,event);
             
    },
    editClinic: function(component,event,helper){ 
        var target = event.getSource();
        var txtVal = target.get("v.value");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/agn-icl-detailpage?edit=true&lcid="+txtVal
        });
        urlEvent.fire();
    }
})