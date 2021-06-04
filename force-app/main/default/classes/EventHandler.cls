public with sharing class EventHandler {
    public EventHandler() {

    }

    public void beforeInsert(List<Event__c> newEvents){


        newEvents = checkEventMax(newEvents);
    }

    private List<Event__c> checkEventMax(List<Event__c> events){

        System.debug('EventHandler.checkEventMax - Start');
        
        // could toss the Developer Name in a custom label so if we want multiple versions
        // we can switch the label instead of hard coding the DeveloperName
        System.debug('EventHandler.checkEventMax - Getting metadata');
        List<Max_User_Events__mdt> maxEvents = [SELECT MasterLabel, Error_Message__c, Max_Amount__c
                                                FROM Max_User_Events__mdt
                                                WHERE DeveloperName = 'Max_Per_Month'];

        // making assumption that if nothing is configured, we can freely create as many as we want
        if(maxEvents.isEmpty() == true){
            System.debug('EventHandler.checkEventMax - Could not find any metadata for limiting events per month');
            return events;
        }

        Max_User_Events__mdt maxAmount = maxEvents[0];
        System.debug('EventHandler.checkEventMax - Max amount metadata: ' + maxAmount);

        Map<Id, List<Event__c>> userEventCounts = new Map<Id, List<Event__c>>();

        for(Event__c evt : events){

            if(userEventCounts.containsKey(evt.OwnerId) == false){
                userEventCounts.put(evt.OwnerId, new List<Event__c>());
            }
        }

        // discovered the fact that related owner fields aren't available in Test classes, so this is the workaround
        // https://trailblazer.salesforce.com/issues_view?id=a1p30000000SwHDAA0
        Map<Id, String> userMap = new Map<Id, String>();
        for(User u : [SELECT Id, Name FROM User WHERE Id IN :userEventCounts.keyset()]){
            userMap.put(u.Id, u.Name);
        }
        System.debug('EventHandler.checkEventMax - Users: ' + userMap);

        for(Event__c evt : [SELECT Id, OwnerId, Owner.Name
                                FROM Event__c 
                                WHERE OwnerId IN :userEventCounts.keyset()
                                AND CreatedDate = THIS_MONTH]){
                    
            userEventCounts.get(evt.OwnerId).add(evt);
        }

        System.debug('EventHandler.checkEventMax - Users and events: ' + userEventCounts);

        for(Event__c evt : events){

            Integer evtCount = userEventCounts.get(evt.OwnerId).size();

            if(evtCount >= maxAmount.Max_Amount__c){
                System.debug('EventHandler.checkEventMax - User is over limit!');
                String errorMessage = maxAmount.Error_Message__c;
                if(userMap.containsKey(evt.OwnerId)){
                    errorMessage = errorMessage.replace('<<Name>>', userMap.get(evt.OwnerId));
                } else {
                    errorMessage = errorMessage.replace('<<Name>>', 'N/A');
                }
                
                errorMessage = errorMessage.replace('<<User ID>>', evt.OwnerId);
                errorMessage = errorMessage.replace('<<Maximum>>', String.valueOf(maxAmount.Max_Amount__c));

                System.debug(errorMessage);

                evt.addError(errorMessage);
            } else {
                userEventCounts.get(evt.OwnerId).add(evt);
            }
        }

        System.debug('EventHandler.checkEventMax - Users and events: ' + userEventCounts);
        System.debug('EventHandler.checkEventMax - End');

        return events;
    }
}
