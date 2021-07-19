// AGN_DCR2_Key_Indicator //

public without sharing class AGN_DCR2_Key_Indicator {

    // ======== Public Variables ======== //
    public DCR_Account_AGN__c Dcr;
    public boolean showKeyIndicators {get; set;}
    public List<DCR_Key_Indicator_AGN__c> DcrKeyIndicators {get; set;}
    public boolean ReadOnly {get; set;}
    public boolean IsLocked {get; set;}
    public boolean IsNewDcr {get; set;}

    // ======== Private Variables ======== //
    Map<Id,Product_Group_vod__c> productGroupMap = new Map<Id,Product_Group_vod__c>();
    List<Product_Group_vod__c> productGroupList = new List<Product_Group_vod__c>([SELECT Product_vod__c,Product_vod__r.Name,Product_Catalog_vod__c,Product_Catalog_vod__r.Name FROM Product_Group_vod__c]);

// ================================================================ //

    public AGN_DCR2_Key_Indicator(ApexPages.StandardController controller) {
        system.debug('== [AGN_DCR2_Key_Indicator].[Controller] ==');
        system.debug('== [Query:productGroupList] =='+productGroupList);     // == queried in global variable section


        Dcr = (DCR_Account_AGN__c)controller.getRecord();
        Id dcrCreatedId = [SELECT CreatedById FROM DCR_Account_AGN__c WHERE Id = :Dcr.Id].CreatedById;
                system.debug('== [Query:dcrCreatedId] =='+dcrCreatedId);
        Id baseUserId = string.isblank(dcrCreatedId) ? UserInfo.getUserId() : dcrCreatedId;
                system.debug('== [AGN_DCR2_Key_Indicator].[Controller].baseUserId =='+baseUserId);

        List<DCR_Configuration_Settings_AGN__c> dcrConfigSetting = AGN_DCR2_Utilities.fetchDCRConfigSettings(baseUserId);
        if(dcrConfigSetting[0].Show_Product_Metrics_AGN__c == true)
            showKeyIndicators = true;
        else
            showKeyIndicators = false;

        IsNewDcr = ([SELECT RecordType.DeveloperName from DCR_Account_AGN__c WHERE Id = :Dcr.Id].RecordType.DeveloperName).contains('Insert');

        DcrKeyIndicators = new List<DCR_Key_Indicator_AGN__c> ([SELECT Id,Name,Parent_DCR_AGN__c,Delete_Record_AGN__c,Is_Changed_AGN__c,Changed_AGN__c,
                    Parent_DCR_AGN__r.Request_Status_AGN__c,Product_AGN__c,Product_Group_AGN__c,Product_AGN__r.Name,Product_Group_AGN__r.Name,
                    Account_Support_AGN__c,Adoption_AGN__c,Adoption_IMS_AGN__c,Adoption_Level_AGN__c,Advocacy_Profile_AGN__c,Allergan_Potential_AGN__c,
                    Awareness_AGN__c,Continuum_Placement_AGN__c,Customer_Segment_AGN__c,Engagements_AGN__c,Fase_AGN__c,Fixed_Consignment_AGN__c,
                    Growth_Potential_AGN__c,Investigator_Readiness_AGN__c,Investigator_AGN__c,Key_Account_AGN__c,Ophthalmology_Profile_AGN__c,
                    Potential_IMS_AGN__c,Product_Status_AGN__c,Profiling_AGN__c,Ratings_AGN__c,Retina_Profile_AGN__c,Sales_Target_AGN__c,
                    Sector_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c,Segment1_AGN__c,Target_AGN__c,Target_Key_Indicator_AGN__c,Tgt_Account_AGN__c
                    FROM DCR_Key_Indicator_AGN__c WHERE Parent_DCR_AGN__c = :Dcr.Id]);
                    system.debug('== [Query:DcrKeyIndicators] =='+DcrKeyIndicators);

        ReadOnly = true;
        if(DcrKeyIndicators.size() > 0)
            IsLocked = (DcrKeyIndicators[0].Parent_DCR_AGN__r.Request_Status_AGN__c != 'Processing' && DcrKeyIndicators[0].Parent_DCR_AGN__r.Request_Status_AGN__c != 'Sent Back for Revision');
    }


// ================================================================ //

    public void Edit_Key_Indicator() {
        system.debug('== [AGN_DCR2_Key_Indicator].[Save_Key_Indicator] ==');
        ReadOnly = false;
    }


// ================================================================ //

    public void Save_Key_Indicator() {
        system.debug('== [AGN_DCR2_Key_Indicator].[Save_Key_Indicator] ==');
        ReadOnly = true;
        
        system.debug('== [DML:update DcrKeyIndicators] =='+DcrKeyIndicators);
        update DcrKeyIndicators;
        system.debug('== [DML:update DcrKeyIndicators].success ==');

        DcrKeyIndicators = [SELECT Id,Name,Parent_DCR_AGN__c,Delete_Record_AGN__c,Is_Changed_AGN__c,Changed_AGN__c,
                    Product_AGN__c,Product_Group_AGN__c,Product_AGN__r.Name,Product_Group_AGN__r.Name,
                    Account_Support_AGN__c,Adoption_AGN__c,Adoption_IMS_AGN__c,Adoption_Level_AGN__c,Advocacy_Profile_AGN__c,Allergan_Potential_AGN__c,
                    Awareness_AGN__c,Continuum_Placement_AGN__c,Customer_Segment_AGN__c,Engagements_AGN__c,Fase_AGN__c,Fixed_Consignment_AGN__c,
                    Growth_Potential_AGN__c,Investigator_Readiness_AGN__c,Investigator_AGN__c,Key_Account_AGN__c,Ophthalmology_Profile_AGN__c,
                    Potential_IMS_AGN__c,Product_Status_AGN__c,Profiling_AGN__c,Ratings_AGN__c,Retina_Profile_AGN__c,Sales_Target_AGN__c,
                    Sector_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c,Segment1_AGN__c,Target_AGN__c,Target_Key_Indicator_AGN__c,Tgt_Account_AGN__c
                    FROM DCR_Key_Indicator_AGN__c WHERE Parent_DCR_AGN__c = :Dcr.Id];
                    system.debug('== [Query:DcrKeyIndicators] =='+DcrKeyIndicators);
    }


// ================================================================ //

    public void Cancel_Key_Indicator() {
        system.debug('== [AGN_DCR2_Key_Indicator].[Save_Key_Indicator] ==');
        ReadOnly = true;

        DcrKeyIndicators = new List<DCR_Key_Indicator_AGN__c> ([SELECT Id,Name,Parent_DCR_AGN__c,Delete_Record_AGN__c,Is_Changed_AGN__c,Changed_AGN__c,
                    Product_AGN__c,Product_Group_AGN__c,Product_AGN__r.Name,Product_Group_AGN__r.Name,
                    Account_Support_AGN__c,Adoption_AGN__c,Adoption_IMS_AGN__c,Adoption_Level_AGN__c,Advocacy_Profile_AGN__c,Allergan_Potential_AGN__c,
                    Awareness_AGN__c,Continuum_Placement_AGN__c,Customer_Segment_AGN__c,Engagements_AGN__c,Fase_AGN__c,Fixed_Consignment_AGN__c,
                    Growth_Potential_AGN__c,Investigator_Readiness_AGN__c,Investigator_AGN__c,Key_Account_AGN__c,Ophthalmology_Profile_AGN__c,
                    Potential_IMS_AGN__c,Product_Status_AGN__c,Profiling_AGN__c,Ratings_AGN__c,Retina_Profile_AGN__c,Sales_Target_AGN__c,
                    Sector_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c,Segment1_AGN__c,Target_AGN__c,Target_Key_Indicator_AGN__c,Tgt_Account_AGN__c
                    FROM DCR_Key_Indicator_AGN__c WHERE Parent_DCR_AGN__c = :Dcr.Id]);
                    system.debug('== [Query:DcrKeyIndicators] =='+DcrKeyIndicators);
    }

}

// AGN_DCR2_Key_Indicator //