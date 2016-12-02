trigger HotspotTrigger on Location_actions__c (after insert, after update, after delete) {

    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        HotspotTriggerHelper.updatehotspot(trigger.newMap);
        if(trigger.isAfter && trigger.isUpdate)
    
    if (trigger.isAfter && trigger.isDelete){
        HotspotTriggerHelper.updatehotspot(trigger.oldMap);
           										}
    }
}