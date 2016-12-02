public with sharing class HotspotTriggerHelper {

    // Updates Location actions related fields on the parent Country or Area record with equivalent fields
    // of the most recently created Location action record
    public static void updateHotspot (map<Id, Location_actions__c> locMap){
        
        try{
            // extract list of hotspots related to updated/inserted location action records 
            list<Location_actions__c> loclist = [select Location__r.Id from Location_actions__c where id in:locMap.keySet() ALL ROWS];
            
            set<string> hotspotIdList = new set <string>();
            
            // Retrieve location actions record type Ids for Status update and Action Plan
                id StatusRecordTypeID = Schema.SObjectType.Location_actions__c.RecordTypeInfosByName.get('Status Update').RecordTypeId; 
 				id ActionRecordTypeID = Schema.SObjectType.Location_actions__c.RecordTypeInfosByName.get('Action Plan').RecordTypeId;           
            
            // populate location id list
            for (Location_actions__c loc :locList){
                hotspotIdList.add(loc.Location__r.Id);
            }
            
            if (!hotspotIdList.isEmpty()){
                // extract Status location action records
               map<Id, Country_or_area__c> hotspotStatusMap  = new map<Id, Country_or_area__c>([select Id, Hotspot_Status__c, Action_Plan__c,
                                                (select Date_time__c, Status__c, Action_Plan__c
                                                            from Location_actions__r 
                                                    where RecordTypeId =:StatusRecordTypeID
                                                    order by Date_time__c desc, Id desc LIMIT 1)
                                                from Country_or_area__c where id in :hotspotIdList]);
 
				// extract Action Plan location action records
               map<Id, Country_or_area__c> hotspotActionMap  = new map<Id, Country_or_area__c>([select Id, Hotspot_Status__c, Action_Plan__c,
                                                (select Date_time__c, Status__c, Action_Plan__c
                                                            from Location_actions__r 
                                                    where RecordTypeId =:ActionRecordTypeID
                                                    order by Date_time__c desc, Id desc LIMIT 1)
                                                from Country_or_area__c where id in :hotspotIdList]);
 
for (Country_or_area__c c :hotspotStatusMap.values()){
    
    string status = '';
    string action = '';
    
    if (c.Location_actions__r.size() > 0){
        status = c.Location_actions__r[0].Status__c;
    }
    
    Country_or_area__c c2 = hotspotActionMap.get(c.Id);
    if (c2.Location_actions__r.size() > 0){
        action = c2.Location_actions__r[0].Action_Plan__c;
    }    
    
    c.Hotspot_Status__c = status;
    c.Action_Plan__c = action;
    
}
update hotspotStatusMap.values();
 
}

            
            
        } catch (exception e){
            
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());              
        }   
        
        
        
        
    }
}