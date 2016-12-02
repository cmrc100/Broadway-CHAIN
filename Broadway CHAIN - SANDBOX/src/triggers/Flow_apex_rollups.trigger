trigger Flow_apex_rollups on Flow_information__c (after insert, after update) {    
    List <Id> clientIds = new List<Id> ();
    List <Contact> clients = new List<Contact>();
    List <AggregateResult> flowforms = new List<AggregateResult>();
    for(Flow_information__c flow:trigger.new){
        clientIds.add(flow.client__c);
    }
  // Retrieve location actions record type Ids for New rough sleeper
    id NewRecordTypeID = Schema.SObjectType.Flow_information__c.RecordTypeInfosByName.get('New rough sleeper').RecordTypeId; 
    
  //Define list of records which can be counted  
    clients = [Select Id, Count_of_new_rs_flow_forms__c From Contact Where Id In :clientIds];
    flowforms = [Select Client__c, Count(Id) From Flow_information__c Where Client__c IN: clientIds
            AND RecordTypeId = :NewRecordTypeID
            Group By Client__c];
    for(AggregateResult ar: flowforms){
        for(Contact c:clients){
            if(ar.get('Client__c') == c.Id){
                c.Count_of_new_rs_flow_forms__c = Decimal.ValueOf(String.ValueOf(ar.get('expr0')));
            }
        }
    }
    update(clients);
}