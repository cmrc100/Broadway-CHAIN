trigger ClientTriggers on Account (after update) {

    //Update private Westminster notes if Date first seen rough sleeping is updated 
    set<Id> clientIds = new set<Id>();
    
    if (trigger.isAfter && trigger.isUpdate){

        for (Account a :trigger.new){
            // check for Date first seen rough sleeping update
            if(trigger.oldMap.get(a.id).Date_First_Seen_Rough_Sleeping__pc != a.Date_First_Seen_Rough_Sleeping__pc){
                clientIds.add(a.PersonContactId);               
            }                               
        }
        if (!clientIds.isEmpty()){
            // Update client Private Westminster notes field
            ClientTriggerHelper.copyNotes(clientIds);
        }
        
    }   
    
    
}