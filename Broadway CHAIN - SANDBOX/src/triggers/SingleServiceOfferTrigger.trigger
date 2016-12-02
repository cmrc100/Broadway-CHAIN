trigger SingleServiceOfferTrigger on Single_Service_Offer__c (after insert, after update, after delete) {
	
	set<Id> SSOIds = new set<Id>();
	set<Id> NSNOEventIds = new set<Id>();
	
    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){

 		SSOIds = trigger.newMap.keySet();
        
        SingleServiceOfferTriggerHelper.updateContact(trigger.newMap);
        SingleServiceOfferTriggerHelper.updateTimelineCounter(trigger.newMap);
        if(trigger.isAfter && trigger.isUpdate)
        {       
         // Check whether update is to Timeline event record association or NSNO Event association            
            set<Id> timelineEventIds  = new set<Id>();
            
            for(Single_Service_Offer__c sso : trigger.new){    
                if(trigger.oldMap.get(sso.id).Timeline_Event__c != sso.Timeline_Event__c){                
                    if (string.isnotBlank(trigger.oldMap.get(sso.id).Timeline_Event__c)) {
                        timelineEventIds.add(trigger.oldMap.get(sso.id).Timeline_Event__c);
                    }
                }
                if(trigger.oldMap.get(sso.id).NSNO_Event__c != sso.NSNO_Event__c){                
                    if (string.isnotBlank(trigger.oldMap.get(sso.id).NSNO_Event__c)) {
                        NSNOEventIds.add(trigger.oldMap.get(sso.id).NSNO_Event__c);
                    }
                }                                 
            }
            if(!timelineEventIds.isEmpty()){
                system.debug(' @@@  TimelineEventIds List ' +  timelineEventIds);
                SingleServiceOfferTriggerHelper.updateSSOTimelineCounter(timelineEventIds, null);
            }
           
         }
                
    }
    
    if (trigger.isAfter && trigger.isDelete){
    	SSOIds = trigger.oldMap.keySet();
        SingleServiceOfferTriggerHelper.updateContact(trigger.oldMap);
        SingleServiceOfferTriggerHelper.updateTimelineCounter(trigger.oldMap);  
    }
    
    SingleServiceOfferTriggerHelper.updateNSNOEvents(SSOIds, NSNOEventIds);
    
}