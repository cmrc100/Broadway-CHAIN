trigger BeforeTimelineEvent on Timeline_Event__c (before insert, before update) {
	
	Timeline t = new Timeline();
	t.beforeTimeline(Trigger.new, Trigger.oldMap);	 
}