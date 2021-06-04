@isTest
private class EventHandlerTest {
    static Integer maxCount = 100;

    @TestSetup
    static void testSetup(){
        System.debug('\tEventHandler.testSetup - Start');

        // This should be taken from a Factory to standardize record creation
        
        List<Event__c> events = new List<Event__c>();

        for(Integer count = 0; count < maxCount; count++){

            Event__c evt = new Event__c();
            evt.Name = 'Test Event ' + count;
            evt.Start__c = Date.today().addDays(count);
            evt.End__c = Date.today().addDays(count);
            events.add(evt);
        }

        insert events;

        System.debug('\tEventHandler.testSetup - End');
    }

    @isTest
    public static void testBeforeInsertSuccess() {
        System.debug('\tEventHandler.testBeforeInsertSuccess - Start');

        List<Event__c> events = [SELECT Id FROM Event__c];
        delete events;

        Test.startTest();

            Event__c evt = new Event__c();
            evt.Name = 'Test Event ';
            evt.Start__c = Date.today();
            evt.End__c = Date.today();
            evt.Description__c = 'This is a test event that should insert suucessfully';
            insert evt;

        Test.stopTest();

        List<Event__c> newEvents = [SELECT Id, OwnerId FROM Event__c];
        System.assertEquals(false, newEvents.isEmpty());
        System.assertEquals(UserInfo.getUserId(), newEvents[0].OwnerId);

        System.debug('\tEventHandler.testBeforeInsertSuccess - End');
    }

    @isTest
    public static void testBeforeInsertFail() {
        System.debug('\tEventHandler.testBeforeInsertFail - Start');

        List<Event__c> events = [SELECT Id FROM Event__c];
        System.debug('\tEventHandler.testBeforeInsertFail - current events count: ' + events.size());

        Test.startTest();

            try {
                Event__c evt = new Event__c();
                evt.Name = 'Test Event ';
                evt.Start__c = Date.today();
                evt.End__c = Date.today();
                evt.Description__c = 'This is a test event that should fail';
                insert evt;

                System.assert(false);
            } catch (Exception e) {
                System.assert(true);
            }

        Test.stopTest();

        List<Event__c> newEvents = [SELECT Id, OwnerId FROM Event__c];
        System.assertEquals(maxCount, newEvents.size());

        System.debug('\tEventHandler.testBeforeInsertFail - End');
    }
}
