trigger Client_Alerts_Rollup on Client_Alerts__c (after insert, after update, after delete) {
    List<Id> contactIds = new List<Id>();
    List<Contact> contacts = new List<Contact>();
    
    Integer NumberOfClientAlerts = 0;
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Client_Alerts__c t : Trigger.new) {
            contactIds.add(t.Client__c);
        }
    }
    else if (Trigger.isDelete) {
        for (Client_Alerts__c t : Trigger.old) {
            contactIds.add(t.Client__c);
        }
    }
    
    Map<Id, List<Client_Alerts__c>> clientAlertByContactId = new  Map<Id, List<Client_Alerts__c>>();
    for (Client_Alerts__c ThisClientAlert : [SELECT Id, Alert_Type__c, RecordType.Name, Client__c FROM Client_Alerts__c WHERE Client__c IN :contactIds]) {
        if (!clientAlertByContactId.containsKey( ThisClientAlert.Client__c)) {
            clientAlertByContactId.put( ThisClientAlert.Client__c, new List<Client_Alerts__c>() );
        }
        
        clientAlertByContactId.get(ThisClientAlert.Client__c).add(ThisClientAlert);
    }
    
    for (Id contactId : contactIds) {
        Contact c = new Contact(Id=contactId);
        List<Client_Alerts__c> clientAlerts = clientAlertByContactId.get(contactId);
        NumberOfClientAlerts = 0;
        
        if (clientAlerts != null) {
            for (Client_Alerts__c ThisClientAlert : clientAlerts) {
                if (ThisClientAlert.RecordType.Name == 'Client alerts_visible' && (ThisClientAlert.Alert_Type__c == 'Serious assault - actual or threatened' || ThisClientAlert.Alert_Type__c == 'Serious self-neglect or self-harm' || ThisClientAlert.Alert_Type__c == 'Wanted by the police in relation to a serious crime')) {
                    NumberOfClientAlerts++;
                }
            }
        }
        
        c.Number_of_client_alerts_apex__c = NumberOfClientAlerts;
        
        contacts.add(c);
    }
    
    update(contacts);
}