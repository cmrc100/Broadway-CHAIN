trigger setTimelineEventWardValue on Timeline_Event__c (before insert, before update) {
    
    Set<String> TimelineEventBoroughs = new Set<String>();
    Map<String, String> BoroughCountPatch = new Map<String, String>();
    Map<String, String> BoroughSNTWard = new Map<String, String>();
    Map<String, String> BoroughArea = new Map<String, String>();
    map<string, list<string>> timelineEventStreetSiteMap = new map<string, list<string>>();
    map<string, string> hotspotStreetSiteMap = new map<string, string>();
    
    id hotspotRecTypeId  = Schema.SObjectType.Country_or_Area__c.RecordTypeInfosByName.get('Hotspot').RecordTypeId;

    
    for (Timeline_Event__c t : Trigger.new) {
        if (!TimelineEventBoroughs.contains(t.Borough_Street_Site__c)) {
            TimelineEventBoroughs.add(t.Borough_Street_Site__c);
        }
        if (string.isnotBlank(t.Borough_Street_Site__c)){
            list<string> teIdList = timelineEventStreetSiteMap.get(t.Borough_Street_Site__c);
            if (teIdList == null){
                teIdList = new list<string>();
            }
            teIdList.add(t.Id);
            timelineEventStreetSiteMap.put(t.Borough_Street_Site__c, teIdList);
        }
    }

    for (Country_or_Area__c CountryArea : [SELECT Name, Id, Street_site_lookup__c FROM Country_or_Area__c WHERE Street_site_lookup__c IN :timelineEventStreetSiteMap.keySet() 
                                                    and RecordTypeId = :hotspotRecTypeId] ) {
        
        hotspotStreetSiteMap.put(CountryArea.Street_site_lookup__c, CountryArea.Id);
    
    }
        
    for (Country_or_Area__c CountryArea : [SELECT Name, Count_Patch_Pick__c FROM Country_or_Area__c WHERE Name IN :TimelineEventBoroughs]) {
        if (!BoroughCountPatch.containsKey(CountryArea.Name)) {
            BoroughCountPatch.put(CountryArea.Name, CountryArea.Count_Patch_Pick__c);
                        }
    }
        
    for (Country_or_Area__c CountryArea : [SELECT Name, SNT_Ward_Pick__c FROM Country_or_Area__c WHERE Name IN :TimelineEventBoroughs]) {
        if (!BoroughSNTWard.containsKey(CountryArea.Name)) {
            BoroughSNTWard.put(CountryArea.Name, CountryArea.SNT_Ward_Pick__c);
                        }
    }
    
    for (Country_or_Area__c CountryArea : [SELECT Name, Area_Pick__c FROM Country_or_Area__c WHERE Name IN :TimelineEventBoroughs]) {
        if (!BoroughArea.containsKey(CountryArea.Name)) {
            BoroughArea.put(CountryArea.Name, CountryArea.Area_Pick__c);
                        }
    }
    
    for (Timeline_Event__c t : Trigger.new) {
        if (BoroughCountPatch.containsKey(t.Borough_Street_Site__c)) {
            t.Count_Patch__c = BoroughCountPatch.get(t.Borough_Street_Site__c);
              }
        
        string hotspotId = hotspotStreetSiteMap.get(t.Borough_Street_Site__c);
        if (string.isnotBlank(hotspotId)){
            t.Hotspot__c = hotspotId;
        }  
    }
        
    for (Timeline_Event__c t : Trigger.new) {
        if (BoroughSNTWard.containsKey(t.Borough_Street_Site__c)) {
            t.SNT_Ward__c = BoroughSNTWard.get(t.Borough_Street_Site__c);
              }
    }
    
    for (Timeline_Event__c t : Trigger.new) {
        if (BoroughArea.containsKey(t.Borough_Street_Site__c)) {
            t.Area__c = BoroughArea.get(t.Borough_Street_Site__c);
              }
    }       
}