global without sharing class HubsController2{

   public list<hub> hubs {get;set;}

   public HubsController2() {

        string sProfile = [select name from profile where id=: UserInfo.getProfileId()].name;  

        list<Hubs__c> hubsList = [select Hub_name__c, Hub_open__c, Reason_for_close__c from Hubs__c where profile__c=:sProfile];

        hubs = new list<hub>();
        
        for (Hubs__c h :hubsList){
            hub hubItem = new hub();

            hubItem.name = h.Hub_Name__c;
            hubItem.status = h.Hub_Open__c;
            hubItem.closeReason = h.Reason_for_close__c;
            hubItem.currentStatus = h.Hub_Open__c;
            hubItem.currentReason = h.Reason_for_close__c;
            hubItem.hubs = h;
            hubs.add(hubItem);

        }                               
          

    }



    private static List<Schema.PicklistEntry> getCloseReasons() {
        return  Hub_Status_Audit__c.Reason_for_close__c.getDescribe().getPicklistValues();
    }

    public List<SelectOption> getReasons(){

          
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> listValues  = getCloseReasons();
        options.add(new SelectOption('', ''));
        for (Schema.PicklistEntry listItem :listValues){
            options.add(new SelectOption(listItem.getLabel(), listItem.getValue()));
        }
        return options;
    } 
    


    
    global class hub{
        
        public string name{get;set;}
        public boolean status{get;set;}
        public string closeReason{get;set;}
        @TestVisible private boolean currentStatus{get;set;}
        @TestVisible private string currentReason{get;set;}
        @TestVisible private hubs__c hubs {get;set;}
                
    }

    webservice static string getProfileName(){
        
        string sProfile = [select name from profile where id=: UserInfo.getProfileId()].name; 
        return sProfile;
        
    }

    public PageReference saveAll(){
        try {
            list<Hubs__c> hubList= new list<Hubs__c>();
            list<Hub_Status_Audit__c> auditList = new list<Hub_Status_Audit__c>();
            list<Hubs__c> hubsUpdate = new list<Hubs__c>();
            set<string> hubNames = new set<string>();
           

            string sMsg = '';
            boolean bUpdate = false;
                     
            for (hub h :hubs){
                h.hubs.Hub_open__c = h.status;
                h.hubs.Reason_for_close__c = h.closeReason;
                if (h.hubs.Hub_open__c != h.currentStatus || h.hubs.Reason_for_close__c != h.currentReason){
                    
                    hubNames.add(h.hubs.Hub_name__c);
                    boolean bOpen = h.hubs.Hub_open__c;
                    string sReason = h.hubs.Reason_for_close__c;
                    bUpdate = true;
                    if(!bOpen){
                        if(string.isBlank(sReason)){
                            if(string.isBlank(sMsg)){
                                bUpdate = false;
                                sMsg = 'Close Reason must be entered when Hub is closed';
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, sMsg);
                                ApexPages.addMessage(myMsg);
                                break;
                            }
                        }
                    } else {
                        sReason = '';
                        h.hubs.Reason_for_close__c = sReason;
                    }
                    hubList.add(h.hubs);
                    Hub_Status_Audit__c hubsAudit = new Hub_Status_Audit__c();
                    hubsAudit = new Hub_Status_Audit__c(); 
                    hubsAudit.Change_date__c = system.Today();
                    hubsAudit.Change_time__c = system.Now();
                    hubsAudit.Hub_Name__c = h.Name;
                    hubsAudit.Reason_for_close__c = sReason;
                    boolean hubStatus = h.hubs.Hub_open__c;
                    if (hubStatus){
                        hubsAudit.Status__c = 'Open';
                    } else {
                        hubsAudit.Status__c = 'Closed';
                    }
                    auditList.add(hubsAudit );
               }
            }
            
            if (!hubNames.isEmpty()){
                hubsUpdate = [select Hub_name__c, Hub_open__c, Reason_for_close__c from Hubs__c where Hub_name__c in :hubNames];
                string sItemName = '';
                string sItemReason = '';
                boolean bItemOpen = false;
                for (Hubs__c h :hubList){
                    sItemName = h.Hub_name__c;
                    sItemReason = h.Reason_for_close__c;
                    bItemOpen = h.Hub_open__c;
                    for (Hubs__c hu :hubsUpdate){
                        if(hu.Hub_Name__c == sItemName){
                            hu.Hub_open__c = bItemOpen;
                            hu.Reason_for_close__c = sItemReason;
                        }
                    }
                }  
            }
            update hubsUpdate;
            
            if (!auditList.isEmpty()){
                insert auditList;
            }

        } catch (exception e){
            system.debug( e.getMessage() + ' : ' + + e.getStackTraceString());
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage() + ' : ' + + e.getStackTraceString());
            ApexPages.addMessage(errMsg);
            return null;            
        }
        return null;
        
    }

}