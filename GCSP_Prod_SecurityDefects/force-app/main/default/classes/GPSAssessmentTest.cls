@isTest
private class GPSAssessmentTest {

    @isTest
    static void setDataCollectionPeriod1() {
        GPS_Assessment__c assessment = GPSCreateTestData.createAssessment(false);
        assessment.Data_Period_Collection_AGN__c = '1';
        assessment.Data_Collection_Period_1_AGN__c = System.today();

        // Validate after insert
        insert assessment;
        assessment = [SELECT Id, Data_Period_Collection_AGN__c, Data_Collection_Period_1_AGN__c FROM GPS_Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals('1', assessment.Data_Period_Collection_AGN__c);
        System.assertEquals(System.today(), assessment.Data_Collection_Period_1_AGN__c);

        // Validate after update when collection changed to '2'
        assessment.Data_Period_Collection_AGN__c = '2';
        update assessment;
        assessment = [SELECT Id, Data_Period_Collection_AGN__c, Data_Collection_Period_1_AGN__c FROM GPS_Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals('2', assessment.Data_Period_Collection_AGN__c);
        System.assertEquals(System.today(), assessment.Data_Collection_Period_1_AGN__c);

        // Validate after update when collection changed to null
        assessment.Data_Period_Collection_AGN__c = null;
        update assessment;
        assessment = [SELECT Id, Data_Period_Collection_AGN__c, Data_Collection_Period_1_AGN__c FROM GPS_Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals(null, assessment.Data_Period_Collection_AGN__c);
        System.assertEquals(null, assessment.Data_Collection_Period_1_AGN__c);
    }

    @isTest
    static void setDataCollectionPeriod2() {
        GPS_Assessment__c assessment = GPSCreateTestData.createAssessment(false);
        assessment.Data_Period_Collection_AGN__c = '2';
        assessment.Data_Collection_Period_2_AGN__c = System.today();

        // Validate after insert
        insert assessment;
        assessment = [SELECT Id, Data_Period_Collection_AGN__c, Data_Collection_Period_2_AGN__c FROM GPS_Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals('2', assessment.Data_Period_Collection_AGN__c);
        System.assertEquals(System.today(), assessment.Data_Collection_Period_2_AGN__c);

        // Validate after update when collection changed to '1'
        assessment.Data_Period_Collection_AGN__c = '1';
        update assessment;
        assessment = [SELECT Id, Data_Period_Collection_AGN__c, Data_Collection_Period_2_AGN__c FROM GPS_Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals('1', assessment.Data_Period_Collection_AGN__c);
        System.assertEquals(null, assessment.Data_Collection_Period_2_AGN__c);

        // Validate after update when collection changed to null
        assessment.Data_Period_Collection_AGN__c = null;
        assessment.Data_Collection_Period_2_AGN__c = System.today();
        update assessment;
        assessment = [SELECT Id, Data_Period_Collection_AGN__c, Data_Collection_Period_2_AGN__c FROM GPS_Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals(null, assessment.Data_Period_Collection_AGN__c);
        System.assertEquals(null, assessment.Data_Collection_Period_2_AGN__c);
    }

    @isTest
    static void clearCustomQuestionFields() {
        GPS_Assessment__c assessment = GPSCreateTestData.createAssessment(false);
        // If any of the custom question types are null, then clear the corresponding fields
        assessment.Custom_Question_1_Type_AGN__c           = null;
        assessment.Custom_Question_1_List_Of_Values_AGN__c = 'Option 1';
        assessment.Custom_Question_1_AGN__c                = 'test question value 1';

        assessment.Custom_Question_2_Type_AGN__c           = null;
        assessment.Custom_Question_2_List_Of_Values_AGN__c = 'Option 1';
        assessment.Custom_Question_2_AGN__c                = 'test question value 2';

        assessment.Custom_Question_3_Type_AGN__c           = null;
        assessment.Custom_Question_3_List_Of_Values_AGN__c = 'Option 1';
        assessment.Custom_Question_3_AGN__c                = 'test question value 3';

        assessment.Custom_Question_4_Type_AGN__c           = null;
        assessment.Custom_Question_4_List_Of_Values_AGN__c = 'Option 1';
        assessment.Custom_Question_4_AGN__c                = 'test question value 4';

        insert assessment;

        Test.startTest();

        assessment = [
            SELECT Id, Custom_Question_1_Type_AGN__c, Custom_Question_1_List_Of_Values_AGN__c, Custom_Question_1_AGN__c,
                Custom_Question_2_Type_AGN__c, Custom_Question_2_List_Of_Values_AGN__c, Custom_Question_2_AGN__c,
                Custom_Question_3_Type_AGN__c, Custom_Question_3_List_Of_Values_AGN__c, Custom_Question_3_AGN__c,
                Custom_Question_4_Type_AGN__c, Custom_Question_4_List_Of_Values_AGN__c, Custom_Question_4_AGN__c
            FROM GPS_Assessment__c
            WHERE Id = :assessment.Id
        ];
        System.assertEquals(null, assessment.Custom_Question_1_Type_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_1_List_Of_Values_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_1_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_2_Type_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_2_List_Of_Values_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_2_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_3_Type_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_3_List_Of_Values_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_3_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_4_Type_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_4_List_Of_Values_AGN__c);
        System.assertEquals(null, assessment.Custom_Question_4_AGN__c);

        Test.stopTest();
    }


}