trigger Timeline_Events_Rollup on Timeline_Event__c (after insert, after update, after delete) {
    List<Id> contactIds = new List<Id>();
    set<Id> timelineEventIds = new set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Timeline_Event__c t : Trigger.new) {
            if (Trigger.isInsert){
        		contactIds.add(t.Client__c);          	
            }
            if (Trigger.isUpdate){				  
                //if(trigger.oldMap.get(t.id).CSTM_Private_Action_plan__c != t.CSTM_Private_Action_plan__c){
					contactIds.add(trigger.oldMap.get(t.id).Client__c);
                //}
            }
            timelineEventIds = trigger.newMap.keySet();          
        }
    } else if (Trigger.isDelete) {
        for (Timeline_Event__c t : Trigger.old) {
            contactIds.add(t.Client__c);
            timelineEventIds = trigger.oldMap.keySet();
        }
    }
    
    if (!system.isBatch() && !ProcessorControl.inFutureContext){
        TimelineEventRollupValues.TriggerRollup(contactIds, Trigger.isInsert);
    }

    TimelineEventRollupValues.updateContactActionPlan(contactIds);
    TimelineEventRollupValues.updateNSNOEvents(timelineEventIds);

	
	
	Timeline t = new Timeline();
	if(Trigger.isInsert || Trigger.isUpdate)
	{
			t.updateClientInfo(Trigger.new, Trigger.oldMap, Trigger.isDelete);
			t.updatePrison(Trigger.new);
	}		
	if(Trigger.isDelete)
	{
		t.updateClientInfo(Trigger.old, Trigger.oldMap, Trigger.isDelete);
		t.updatePrison(Trigger.old);	
	}	    
    
}