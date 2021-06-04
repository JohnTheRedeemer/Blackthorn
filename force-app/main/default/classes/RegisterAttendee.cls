@RestResource(urlMapping='/register')
global class RegisterAttendee {

    private static String key = 'testKey';
    
    @HttpPost
    global static void register(){
        System.debug('RegisterAttendee.register - start');

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        Set<String> validStatuses = new Set<String>{ 'Pending', 'Active' };

        try {
            System.debug('RegisterAttendee.register - ' + req);
            System.debug('RegisterAttendee.register - ' + req.requestBody);
            String jsonDetails = req.requestBody.toString();
            RegistrationDetails details = (RegistrationDetails)JSON.deserialize(jsonDetails, RegistrationDetails.class);

            if(details.key <> key){
                String keyErrMsg = 'Supplied key does not match';
                System.debug('RegisterAttendee.register - ' + keyErrMsg);
                res.responseBody = Blob.valueOf(keyErrMsg);
                res.statusCode = 401;
                return;
            }

            List<Event__c> evts = [SELECT Id 
                                    FROM Event__c 
                                    WHERE (Id = :details.evtId
                                    OR Name = :details.evtName)
                                    AND Status__c IN :validStatuses
                                    AND Entry_Type__c = 'Free'];

            if(evts.isEmpty()){
                throw new RegisterException('Could not find valid event');
            }

            Attendee__c attendee = new Attendee__c();
            attendee.Name = details.fName + ' ' + details.lName;
            attendee.Event__c = evts[0].Id;
            insert attendee;

        } catch(Exception ex){

            System.debug('RegisterAttendee.register - ' + ex.getMessage());
            res.responseBody = Blob.valueOf(ex.getMessage());
            res.statusCode = 400;
            return;
        }

        res.responseBody = Blob.valueOf('Successfully added attendee!');
        res.statusCode = 200;

        System.debug('RegisterAttendee.register - end');
    }

    private class RegisterException extends Exception { }

    @TestVisible
    private class RegistrationDetails {
        public String fName { get; set; }
        public String lName { get; set; }
        public String evtName { get; set; }
        public String evtId { get; set; }
        public String key { get; set; }
    }
}
