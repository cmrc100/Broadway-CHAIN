public with sharing class SingleServiceOfferTriggerHelper {

    // Updates Single Service Offer (SSO) related fields on the parent client record with equivalent fields
    // of the most recently created Single Service Offer record
    public static void updateContact (map<Id, Single_Service_Offer__c> ssoMap){
        
        try{
            // extract list of clients related to updated/inserted SSO records 
            list<Single_Service_Offer__c> ssoList = [select Client__r.Id from Single_Service_Offer__c where id in:ssoMap.keySet() ALL ROWS];
            
            set<string> clientIdList = new set <string>();
            
            // populate client id list
            for (Single_Service_Offer__c sso :ssoList){
                clientIdList.add(sso.Client__r.Id);
            }
            
            if (!clientIdList.isEmpty()){
                // extract client SSO fields and the most recently created SSO record related to the client
                list<Contact> contactList = [select Id, Special_Action__c, Date_NSNO_offer_made__c, Team_making_single_service_offer__c,
                                                Offer_Outcome__c,
                                                (select Date_offer_made__c, Team_making_SSO__c,Single_Service_Offer__c,
                                                            Offer_outcome__c, Timeline_Event__c
                                                            from Single_Service_Offers__r order by Date_offer_made__c desc, Id desc LIMIT 1)
                                                from contact where id in :clientIdList];

                for (contact c :contactList){                   
                    if (c.Single_Service_Offers__r.isEmpty()){ // blank out values if no SSO's exist
                        c.Special_Action__c = '';
                        c.Date_NSNO_offer_made__c = null;
                        c.Team_making_single_service_offer__c = ''; 
                        c.Offer_Outcome__c = '';                                                                     
                    } else {
                        // stamp client fields with field values from SSO record
                        c.Special_Action__c = c.Single_Service_Offers__r[0].Single_Service_Offer__c;
                        c.Date_NSNO_offer_made__c = c.Single_Service_Offers__r[0].Date_offer_made__c;
                        c.Team_making_single_service_offer__c = c.Single_Service_Offers__r[0].Team_making_SSO__c; 
                        c.Offer_Outcome__c = c.Single_Service_Offers__r[0].Offer_outcome__c;
                           }
                }
                
                update contactList;
            }   
            
            
            
        } catch (exception e){
            
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());              
        }   
        
        
        
        
    }


    // Updates count of related Single Service Offer (SSO) held on associated Timeline Event record
    public static void updateTimelineCounter (map<Id, Single_Service_Offer__c> ssoMap){
        
        try{
            // extract list of clients related to updated/inserted SSO records 
            list<Single_Service_Offer__c> ssoList = [select Timeline_Event__c from Single_Service_Offer__c where id in:ssoMap.keySet() ALL ROWS];
            
            set<Id> timelineIdList = new set <Id>();
            
            // populate timeline event id list
            for (Single_Service_Offer__c sso :ssoList){
                timelineIdList.add(sso.Timeline_Event__c);
            }
            
            updateSSOTimelineCounter(timelineIdList, null);
            
        } catch (exception e){
            
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());              
        }   
        
        
    }
    
    public static void updateSSOTimelineCounter(set<Id> timelineIdList, map<Id, Timeline_Event__c> timelineEventList){

        
        if (!timelineIdList.isEmpty()){
            
            if (timelineEventList  == null) {
                // extract SSO Count field from timeline event records
                timelineEventList = new map<Id, Timeline_Event__c>([select Id, SSO_Count__c 
                                                                    from Timeline_Event__c 
                                                                    where id in :timelineIdList]);
            }
                                                                                                      
            map<Id, boolean> timelineUpdated = new map<Id, boolean>();
            for (Id tId :timelineEventList.keySet()){
                timelineUpdated.put(tId, false);
            }
            
            List <AggregateResult> SSOs = new List<AggregateResult>();
            // get current record counts    
            SSOs = [Select Timeline_Event__c, Count(Id) recCount 
                        From Single_Service_Offer__c Where Timeline_Event__c in: timelineIdList
                        group by Timeline_Event__c];            
            
            // update timeline event records
            for(AggregateResult ar: SSOs){
                if (string.isnotBlank(string.valueOf(ar.get('Timeline_Event__c')))){              
                    timelineEventList.get((string.valueOf(ar.get('Timeline_Event__c')))).SSO_Count__c = Decimal.ValueOf(String.ValueOf(ar.get('recCount'))); 
                    timelineUpdated.put(string.valueOf(ar.get('Timeline_Event__c')), true);
                }
            } 
            
            // set count to 0 if no SSO's exist                             
            for (Id tId :timelineEventList.keySet()){
                if (timelineUpdated.get(tId) == false){
                    timelineEventList.get(tId).SSO_Count__c = 0;
                }
            }
            
                
            update timelineEventList.values();
        }           
        
    }
    
    // Utility method to update all SSO Counter fields on all Timeline event records
    
    public static void updateAllSSOCounters(list<Timeline_Event__c>timelineEventList){

        try{        
            set<Id> timelineIdList = new set<Id>();
            if (!timelineEventList.isEmpty()){
                Map<Id, Timeline_Event__c> timelineMap = new Map<Id, Timeline_Event__c>(timelineEventList);
                timelineIdList  = timelineMap.keySet();
                updateSSOTimelineCounter(timelineIdList, timelineMap);
            }

        } catch (exception e){
            
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());              
        }       
    
    }

    // Triggered from SSO changes 
    // to update the SSO count value held 
    // on the associated NSNO Event object 
    public static void updateNSNOEvents( set<Id> SSOIds, set<Id> NSNOEventIds){
        
        set<Id> NSNOEventIdList = new set<Id>();
        if (!NSNOEventIds.isEmpty()){
            NSNOEventIdList.addAll(NSNOEventIds);
        }
        list<Single_Service_Offer__c> SSOs = new list<Single_Service_Offer__c>();        
system.debug(' @@@@@@@@@@@@  SSOIDs   ' + SSOIds);      
        try{
            if (!SSOIds.isEmpty()){
                SSOs = [Select NSNO_Event__c from Single_Service_Offer__c 
                                        where Id in :SSOIds ALL ROWS];    
                
                if(!SSOs.isEmpty()){
                    for(Single_Service_Offer__c SSO :SSOs){
                        if (string.isnotBlank(SSO.NSNO_Event__c)){
                            NSNOEventIdList.add(SSO.NSNO_Event__c);
                        }
                    }

                }
            }
system.debug(' @@@@@@@@@@@@  NSNOEventIdList   ' + NSNOEventIdList);                
            if (!NSNOEventIdList.isEmpty()){
                
                map<Id, NSNO_Event__c> NSNOEventsMap = new map<Id, NSNO_Event__c>([select Count_of_SSOs__c
                                                                                    from NSNO_Event__c where id in :NSNOEventIdList]);
                
                AggregateResult [] allSSOs = [select NSNO_Event__c nsnoId, count (Id) RecordCount 
                                    From Single_Service_Offer__c  where
                                    NSNO_Event__c in :NSNOEventIdList
                                    Group By NSNO_Event__c];
                if (!allSSOs.isEmpty()){
                    for (AggregateResult ar :allSSOs){
                        string recId = string.valueOf(ar.get('nsnoId'));
                        integer recCount = integer.valueOf(ar.get('RecordCount'));
                        NSNOEventsMap.get(recId).Count_of_SSOs__c = recCount;
                    }
                } else {
                    for (NSNO_Event__c nsno :NSNOEventsMap.values())
                    {            
                        nsno.Count_of_SSOs__c = 0;                      
                    }                
                 
                }               
                
                update NSNOEventsMap.values();
            }
        
        } catch (exception e){
            
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());   
        }
    
    }
    
    
}