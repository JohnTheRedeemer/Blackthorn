trigger Event on Event__c (before insert) {

    EventHandler handler = new EventHandler();

    handler.beforeInsert(Trigger.new);
}