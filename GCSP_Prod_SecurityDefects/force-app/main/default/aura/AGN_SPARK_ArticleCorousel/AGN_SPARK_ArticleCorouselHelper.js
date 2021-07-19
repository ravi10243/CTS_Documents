({
    // Get clinical knowledgeArticle 
    knowledgeArticle : function(component, event, helper) {
        var action = component.get("c.getRecentArticles");
        action.setParams({
            articleType : component.get("v.KnowledgeArticlesType")
        });
        action.setCallback(this, function(response){
           
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set('v.KnowledgeArticles', response.getReturnValue());
            }
        });
        $A.enqueueAction(action); 
    },
    
    // On of select article 
    displayArticle : function(component, event, helper){
        var selectedArticle = event.currentTarget;
        var articleId = selectedArticle.dataset.value;

    },
    
    // Rerender Carousel after page load
    initCarousel : function (){

        if($(window).width()>=765){    

            $('.owl-carousel').owlCarousel({
                loop:false,
                margin:10,
                nav:true,
                responsive:{
                    768:{
                        items:3
                    },
                    1000:{
                        items:3
                    }
                }
            });
            
            $(document).on("click", ".next-recmnd", function () {
                $('.owl-carousel .owl-next').trigger('click');                
            });
            $(document).on("click", ".prev-recmnd", function () {
                $('.owl-carousel .owl-prev').trigger('click');
            });
            $(".viewall_desktop").on("click",function(){
                // alert("test");                
            });
        }else{

            $('.owl-carousel').addClass('off');
            $(".load_more").on("click",function(){

                $(this).css("display","none");
                $(".owl-carousel .item").css("display","block");
                $(".load_less").css("display","block");
            });
            $(".load_less").on("click",function(){
                $(this).css("display","none");
                $(".owl-carousel .item").hide().slice(0,3).show();;
                $(".load_more").css("display","block");
            });
        }        
      	
    },
    
    // navigateTo Articles Details page
    navigateToArticlesDetails : function (component, event, helper) {
        var articleId = event.currentTarget.getAttribute("data-articleId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
         	"url" : '/knowledge-hub?id='+articleId
        });
        urlEvent.fire();
    },
    
    
    
})