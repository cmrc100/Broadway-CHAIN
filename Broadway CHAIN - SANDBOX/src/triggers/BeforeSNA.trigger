trigger BeforeSNA on Support_Needs_Assessment__c (before insert, before update) {
    // Trigger simply updates the Client__c field (looup to Contact) with the contact from the person account linked via Client2__c...
    // First, find the IDs of the clients (Accounts) affected here...
    // set <Id> acctsSet = new set <Id> ();
    // for (Support_Needs_Assessment__c sna : Trigger.new) acctsSet.add(sna.Client2__c);
    // Next,  make a map to get the relevant Account info (PersonContactID in this case...)
    // Map <Id,Account> ClientQueryMap = new Map<Id,Account>([Select ID, PersonContactId From Account where Id IN: acctsSet]);
    // Finally, if the account HAS a contact ID, update the relevant field in SFDC.
    // for (Support_Needs_Assessment__c sna : Trigger.new) {
    //    if (ClientQueryMap.get(sna.Client2__c).PersonContactID != null) {
    //        sna.Client__c = ClientQueryMap.get(sna.Client2__c).PersonContactID;
    //    } 
    // }
}