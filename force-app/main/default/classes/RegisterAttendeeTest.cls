@isTest
private class RegisterAttendeeTest {

    @TestSetup
    static void testSetup(){
        
        // normally use a factory here so that data remains consistent with rules
        Event__c evt = new Event__c();
        evt.Name = 'Test Event';
        evt.Start__c = Date.today();
        evt.End__c = Date.today();
        evt.Status__c = 'Active';
        insert evt;
    }

    @isTest
    public static void testRegisterSuccess() {

        String domain = System.URL.getSalesforceBaseURL().toExternalForm();

        RegisterAttendee.RegistrationDetails details = new RegisterAttendee.RegistrationDetails();
        details.fName = 'Test';
        details.lName = 'Testerson';
        details.evtName = 'Test Event';
        details.key = 'testKey';
        String body = JSON.serialize(details);
        System.debug('RegisterAttendeeTest.testRegister - ' + body);

        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = domain + '/rest/services/apexrest/register';
        req.requestBody = Blob.valueOf(body);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new HttpMockBuilder(body, 200, 'OK'));

        Test.startTest();

            RegisterAttendee.register();

        Test.stopTest();

        String attendeeName = details.fName + ' ' + details.lName;
        List<Attendee__c> newAttendees = [SELECT Id, Event__r.Name FROM Attendee__c WHERE Name = :attendeeName];
        System.assertEquals(newAttendees.isEmpty(), false);
        System.assertEquals(details.evtName, newAttendees[0].Event__r.Name);
    }

    @isTest
    public static void testRegisterInvalidKey() {

        String domain = System.URL.getSalesforceBaseURL().toExternalForm();

        RegisterAttendee.RegistrationDetails details = new RegisterAttendee.RegistrationDetails();
        details.fName = 'Test';
        details.lName = 'Testerson';
        details.evtName = 'Test Event';
        details.key = 'hackerTime';
        String body = JSON.serialize(details);
        System.debug('RegisterAttendeeTest.testRegister - ' + body);

        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = domain + '/rest/services/apexrest/register';
        req.requestBody = Blob.valueOf(body);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new HttpMockBuilder(body, 200, 'OK'));

        Test.startTest();

            RegisterAttendee.register();

        Test.stopTest();

        String attendeeName = details.fName + ' ' + details.lName;
        List<Attendee__c> newAttendees = [SELECT Id, Event__r.Name FROM Attendee__c WHERE Name = :attendeeName];
        System.assertEquals(newAttendees.isEmpty(), true);
    }

    @isTest
    public static void testRegisterInvalidEvent() {

        List<Event__c> evts = [SELECT Id, Status__c FROM Event__c];
        for(Event__c evt : evts){
            evt.Status__c = 'Draft';
        }
        update evts;

        String domain = System.URL.getSalesforceBaseURL().toExternalForm();

        RegisterAttendee.RegistrationDetails details = new RegisterAttendee.RegistrationDetails();
        details.fName = 'Test';
        details.lName = 'Testerson';
        details.evtName = 'Test Event';
        details.key = 'testKey';
        String body = JSON.serialize(details);
        System.debug('RegisterAttendeeTest.testRegister - ' + body);

        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = domain + '/rest/services/apexrest/register';
        req.requestBody = Blob.valueOf(body);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new HttpMockBuilder(body, 200, 'OK'));

        Test.startTest();

            RegisterAttendee.register();

        Test.stopTest();

        String attendeeName = details.fName + ' ' + details.lName;
        List<Attendee__c> newAttendees = [SELECT Id, Event__r.Name FROM Attendee__c WHERE Name = :attendeeName];
        System.assertEquals(newAttendees.isEmpty(), true);
    }
}
