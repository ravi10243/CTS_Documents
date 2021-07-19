//Apex class created so that Brand protection users cannot see Legal team attachments as per requirement

public class AGN_Brandprotectionattachment
{

//Declaration of Parameters

public Allergan_Incident_AGN__c bprparentid;
public List<attachment> attch {get;set;}
public List <Profile> profilename {get;set;}
public List<User> UserDivision{get;set;}


/*public Attachment attach {
  get {
          if (attach == null)
            attach = new Attachment();
              return attach;
     }
  set;
  }*/
     
//Declaration of Parameters     
      
//Construction initialisation
     
public AGN_Brandprotectionattachment(ApexPages.StandardController controller)
      {
          this.bprparentid=(Allergan_Incident_AGN__c)controller.getRecord();
          
              profilename=[select Name from profile where id=:Userinfo.getprofileId()];
              UserDivision=[select Id,Division from User where id=:UserInfo.getUserId()];
        
                   
          try
           { 
              //checking current users profile and dispalying data accordingly
              
                 if(profilename.get(0).Name.equals(Label.AGN_BP_LegalTeamProfileName)==true && UserDivision.get(0).Division.contains(Label.AGN_Legal_Name))
             
              
                 {
                      attch=[select Id,Name,parentID,CreatedBy.name,LastModifiedDate,owner.profile.name from attachment where parentid=:bprparentid.id order by createddate desc];  
                 
                 
                 } 
               else
                {
                   
                     attch=[select Id,parentID,Name,CreatedBy.name,LastModifiedDate,owner.profile.name from attachment where parentid=:bprparentid.id and (NOT CreatedBy.profile.name=:Label.AGN_BP_LegalTeamProfileName) order by createddate desc];
                }
                    
             } 
           
            catch(exception e)
             {
           
             }
             
            
       }
     /*  public pagereference upload()
       {
       Attachment newattach=new Attachment();
           newattach.ParentId = bprparentid.id; // the record the file is attached to
                  newattach.Body = attach.body;
                newattach.Name = attach.name;
                insert newattach;
            Pagereference pg=new Pagereference (ApexPages.currentPage().getUrl());
             pg.setredirect(true);
            return pg;
       }*/

  }