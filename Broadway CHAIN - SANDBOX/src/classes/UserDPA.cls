global class UserDPA{
    
    public DateTime lastlogin{get;set;}
    
    public boolean getloggedInNow(){
    	
		User u = [SELECT LastLoginDate FROM User WHERE Id =:UserInfo.getUserId()];
		lastlogin = u.LastLoginDate;
		
		system.debug(' @@@ ' + system.now() > lastlogin.addSeconds(20) + ' - ' + system.now() + ' - ' + lastlogin.addSeconds(20));
		if (system.now() > lastlogin.addSeconds(20) ){
			return false;
		} else {
			return true;
		}    	
    	
    }
    
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