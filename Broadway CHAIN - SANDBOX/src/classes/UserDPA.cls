global class UserDPA{
    
    
    public UserDPA() {
        usr = [select dpa_agreement__c from User where id=:UserInfo.getUserId()];
        usrDPA = usr.dpa_agreement__c;
    }


    public User usr;
   

    public User getusr(){
        return usr;
    }
    
   // Property declaration
    public boolean usrDPA {
        get {
            return usrDPA;
        }
        set;
    } 

    public PageReference updateDPA(){
        
        PageReference pg = new PageReference(URL.getSalesforceBaseUrl().toExternalForm());
        try{        
            usr.dpa_agreement__c = usrDPA;
            update usr;
            return pg;
        } catch (exception e){
            system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
            return null;  
        }    
        
        return pg;
    }

    webservice static string checkAndRedirect(){
        
        string sReturn ='';
        
        User usrRec = [select dpa_agreement__c from User where id=:UserInfo.getUserId()];
        boolean usrRecDPA = usrRec.dpa_agreement__c;        

        if (!usrRecDPA){
            sReturn = '/apex/DPATerms';
        }
        
        return sReturn;
    }


}