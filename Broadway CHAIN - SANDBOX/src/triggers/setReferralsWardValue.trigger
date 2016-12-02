trigger setReferralsWardValue on Referrals__c (before insert, before update) {
    Set<String> ReferralsBoroughs = new Set<String>();
    Map<String, String> RefBoroughCountPatch = new Map<String, String>();
    Map<String, String> RefBoroughURL = new Map<String, String>();
    Map<String, String> RefBoroughWard = new Map<String, String>();
    Map<String, String> RefBoroughSNTWard = new Map<String, String>();
    Map<String, String> RefBoroughArea = new Map<String, String>();

    
    for (Referrals__c t : Trigger.new) {
        if (!ReferralsBoroughs.contains(t.Street_name__c)) {
            ReferralsBoroughs.add(t.Street_name__c);
        }
    }
    
    for (Country_or_Area__c CountryArea : [SELECT Name, Count_Patch__c FROM Country_or_Area__c WHERE Name IN :ReferralsBoroughs ]) {
        if (!RefBoroughCountPatch.containsKey(CountryArea.Name)) {
            RefBoroughCountPatch.put(CountryArea.Name, CountryArea.Count_Patch__c);
                        }
    }
    
    for (Country_or_Area__c CountryArea : [SELECT Name, Location_URL__c FROM Country_or_Area__c WHERE Name IN :ReferralsBoroughs ]) {
        if (!RefBoroughURL.containsKey(CountryArea.Name)) {
            RefBoroughURL.put(CountryArea.Name, CountryArea.Location_URL__c);
                        }
    }
    
    for (Country_or_Area__c CountryArea : [SELECT Name, Ward__c FROM Country_or_Area__c WHERE Name IN :ReferralsBoroughs ]) {
        if (!RefBoroughWard.containsKey(CountryArea.Name)) {
            RefBoroughWard.put(CountryArea.Name, CountryArea.Ward__c);
                        }
    }
    
    for (Country_or_Area__c CountryArea : [SELECT Name, SNT_Ward__c FROM Country_or_Area__c WHERE Name IN :ReferralsBoroughs ]) {
        if (!RefBoroughSNTWard.containsKey(CountryArea.Name)) {
            RefBoroughSNTWard.put(CountryArea.Name, CountryArea.SNT_Ward__c);
                        }
    }
    
    for (Country_or_Area__c CountryArea : [SELECT Name, Area__c FROM Country_or_Area__c WHERE Name IN :ReferralsBoroughs ]) {
        if (!RefBoroughArea.containsKey(CountryArea.Name)) {
            RefBoroughArea.put(CountryArea.Name, CountryArea.Area__c);
                        }
    }
    
    for (Referrals__c t : Trigger.new) {
        if (RefBoroughCountPatch.containsKey(t.Street_name__c)) {
            t.Count_Patch__c = RefBoroughCountPatch.get(t.Street_name__c);
              }
    }
    
    for (Referrals__c t : Trigger.new) {
        if (RefBoroughURL.containsKey(t.Street_name__c)) {
            t.Google_Maps_URL__c = RefBoroughURL.get(t.Street_name__c);
              }
    }
    
    for (Referrals__c t : Trigger.new) {
        if (RefBoroughWard.containsKey(t.Street_name__c)) {
            t.Ward__c = RefBoroughWard.get(t.Street_name__c);
              }
    }
    
    for (Referrals__c t : Trigger.new) {
        if (RefBoroughSNTWard.containsKey(t.Street_name__c)) {
            t.SNT_Ward__c = RefBoroughSNTWard.get(t.Street_name__c);
              }
    }
    
    for (Referrals__c t : Trigger.new) {
        if (RefBoroughArea.containsKey(t.Street_name__c)) {
            t.Area__c = RefBoroughArea.get(t.Street_name__c);
              }
    }       
}