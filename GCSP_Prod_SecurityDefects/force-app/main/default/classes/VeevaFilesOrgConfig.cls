public without sharing class VeevaFilesOrgConfig implements VeevaOrgConfig{

    public boolean isOrgConfigured(){
        String profileId = UserInfo.getProfileId();
        List<Id> permissionSetIds = new List<Id>();
        for(PermissionSetAssignment assignment: [Select PermissionSetId from PermissionSetAssignment where AssigneeId =: UserInfo.getUserId()]){
        	permissionSetIds.add(assignment.PermissionSetId);
        }
        String field = 'PermissionsChatterEnabledForUser';
        Set<String> objectFields = Schema.SObjectType.PermissionSet.fields.getMap().keySet();
		if(!objectFields.contains(field.toLowerCase())) {
            field = 'PermissionsLightningExperienceUser';
        }
        for(sObject permissionSet: Database.query('Select ' + field + ' from PermissionSet where ProfileId = :profileId or Id IN :permissionSetIds')){
            if((boolean)permissionSet.get(field)){
                return true;
            }
        }
        return false;
    }
}