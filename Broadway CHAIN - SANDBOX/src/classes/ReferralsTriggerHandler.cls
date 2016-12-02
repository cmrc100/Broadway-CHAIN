Public class ReferralsTriggerHandler{

    static map<string, string> authorityMap = new map<string, string>();
    
    public ReferralsTriggerHandler(){
        
        list<string> laNames = new list<string>();
        
        laNames.add ('Birmingham City Council');
        laNames.add ('Coventry City Council');
        laNames.add ('Dudley Borough Council');                                    
        laNames.add ('Nuneaton and Bedworth Borough Council');
        laNames.add ('Rugby Borough Council');
        laNames.add ('Sandwell Borough Council');
        laNames.add ('Solihull Borough Council');
        laNames.add ('Stratford-on-Avon District Council');
        laNames.add ('Walsall Borough Council');
        laNames.add ('Warwick District Council');
        laNames.add ('Wolverhampton City Council');
        
        list<Local_Authority__c> laList = [Select Id, Name from Local_Authority__c where name in:
                                            laNames];

        for(Local_authority__c la :laList){
            authorityMap.put(la.Id, la.Name);
        }
    
    }

    public void shareWithMidlands(list<Referrals__c> refList){
        
        list<Referrals__c> refShareList = null;
        
        try {
            refShareList = [select Id, Name, ConnectionReceivedId from Referrals__c
                                where Id in:refList and Local_Authority__c in :authorityMap.keySet()];
        } catch (exception e){
            refShareList = null;
        }
        if (refShareList != null){
            if (refShareList.size() > 0){                                        
                doShare(refShareList);                                                     
            }
        }
        
    }

    private void doShare(list<Referrals__c> refShareList){
    
        // Define connection id 
        Id networkId = ConnectionHelper.getConnectionId('Midland Heart'); 
        
        Set<Id> localReferralsSet = new Set<Id>(); 
        List<Referrals__c> localReferrals = new List<Referrals__c>(); 
        Set<Id> sharedReferralsSet = new Set<Id>();    
        
        // only share records created in this org, do not add contacts received from another org. 
        for (Referrals__c newReferral : refShareList) { 
            if (newReferral.ConnectionReceivedId == null) { 
                localReferralsSet.add(newReferral.Id); 
                localReferrals.add(newReferral);
                sharedReferralsSet.add(newReferral.Id); 
            }         
        } 

        if (localReferralsSet.size() > 0) {                        
            
            /*
            
            // Get the referral network record connections 
            for (PartnerNetworkRecordConnection referralSharingRecord :  
                                      [SELECT p.Status, p.LocalRecordId, p.ConnectionId 
                                       FROM PartnerNetworkRecordConnection p              
                                       WHERE p.LocalRecordId IN :localReferralsSet]) { 
                      
                // for each partner connection record for contact's account, check if it is active 
                if ((referralSharingRecord.status.equalsignorecase('Sent') 
                  || referralSharingRecord.status.equalsignorecase('Received')) 
                  && (referralSharingRecord.ConnectionId == networkId)) { 
                    sharedReferralsSet.add(referralSharingRecord.LocalRecordId); 
                }               
            } 
            
            */        
            
            if (sharedReferralsSet.size() > 0) { 
                List<PartnerNetworkRecordConnection> referralConnections =  new  List<PartnerNetworkRecordConnection>(); 
                
                for (Referrals__c newReferral : localReferrals) { 
      
                    if (sharedReferralsSet.contains(newReferral.Id)) { 
                       
                        PartnerNetworkRecordConnection newConnection = 
                          new PartnerNetworkRecordConnection( 
                              ConnectionId = networkId, 
                              LocalRecordId = newReferral.Id, 
                              SendClosedTasks = false, 
                              SendOpenTasks = false, 
                              SendEmails = false); 
                              
                        referralConnections.add(newConnection); 
                    
                    } 
                } 
      
                if (referralConnections.size() > 0 ) { 
                       database.insert(referralConnections); 
                } 
            } 
        }     
    
    
    }

}