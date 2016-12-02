public with sharing class ClientTriggerHelper {

    public static void copyNotes(set<Id> clientIds){
system.debug(' @@@@@@@@@   clientIds    ' + clientIds);           
        list<Timeline_Event__c> timelineEventList = new list<Timeline_Event__c>();
        timelineEventList = [select Private_notes_CSTM__c, Private_notes_Passage__c, Validation_rule_bypass_apex__c,
                                            Client__c, Private_notes_St_Mungo_s__c, Private_notes_Westminster__c
                                        from Timeline_Event__c 
                                        where Private_Westmister_Notes_Copy_Over__c = true
                                        and Length_of_Notes__c > 0
                                        and Client__c in :clientIds
                                        order by Date__c desc limit 10];
               
        for(Timeline_Event__c tl :timelineEventList){
                                                                                            
            if(string.isnotBlank(tl.Private_notes_CSTM__c)){
                tl.Private_notes_Westminster__c = tl.Private_notes_CSTM__c;
            }                                    
        
            if(string.isnotBlank(tl.Private_notes_Passage__c)){
                tl.Private_notes_Westminster__c = tl.Private_notes_Passage__c;
            }                                    

            if(string.isnotBlank(tl.Private_notes_St_Mungo_s__c)){
                tl.Private_notes_Westminster__c = tl.Private_notes_St_Mungo_s__c;
            }
            tl.Validation_rule_bypass_apex__c = true;                                             
        }
        
        if (!timelineEventList.isEmpty()){
            ProcessorControl.inFutureContext = true;
            update timelineEventList;
        }            
        
        
    }

}