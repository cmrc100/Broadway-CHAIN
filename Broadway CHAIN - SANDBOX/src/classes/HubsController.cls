global with sharing class HubsController{

    
    public HubsController() {

        string sProfile = [select name from profile where id=: UserInfo.getProfileId()].name;  

        hubs = [select Hub_name__c, Hub_open__c from Hubs__c where profile__c=:sProfile];

    }


    public list<Hubs__c> hubs {get;set;}
   
    public void updateValues(){
    
        update hubs;
    
    }


    webservice static string updateHub(string hubName, boolean hubStatus){
        
        try{
            if (hubStatus){
                hubStatus = false;
            } else {
                hubStatus = true;
            }
            list<Hubs__c> hubsUpdate = [select Hub_name__c, Hub_open__c from Hubs__c where Hub_name__c=:hubName];   
            map<string, Hub_Status_Audit__c> hubsAuditList = new map<string,Hub_Status_Audit__c>();
            for (Hubs__c h :hubsUpdate){
                h.Hub_open__c = hubStatus;
                string status = '';
                if (hubStatus){
                    status = 'Open';
                } else {
                    status = 'Closed';
                }
                Hub_Status_Audit__c hubsAudit = new Hub_Status_Audit__c(); 
                hubsAudit.Change_date__c = system.Today();
                hubsAudit.Change_time__c = system.Now();
                hubsAudit.Hub_Name__c = h.Hub_name__c;
                hubsAudit.Status__c = status;
                hubsAuditList.put(h.Hub_name__c, hubsAudit);                
            }
            update hubsUpdate;
            insert hubsAuditList.values();            
            
            return('');
            
        } catch (exception e){
            system.debug(e.getMessage());
            return('An error has occurred, please report the following error : ' + e.getMessage());
        }
    
    }

    webservice static string getProfileName(){
        
        string sProfile = [select name from profile where id=: UserInfo.getProfileId()].name; 
        return sProfile;
        
    }


}