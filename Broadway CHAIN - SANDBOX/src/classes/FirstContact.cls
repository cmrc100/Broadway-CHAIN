public without sharing class FirstContact {


    
    //This class is being used by the FirstContact Wizard. Both the pages share this common controller.
    
    public Contact c {get;set;}
    public Timeline_Event__c te {get;set;}
    public Flow_information__c flowInfo {get;set;}
    
    public Support_Needs_Lifestyle__c sna {get;set;}
    
    String strAccId; 


    public string address{get;set;}
    public string localAuthority{get;set;}
    public string lngLat{get;set;}
    public string lng{get;set;}
    public string lat{get;set;}    
    public string postcode{get;set;}
    public string ward{get;set;}
    public string borough{get; set;}
    public string LSOACode {get; set;}
    public string LSOAName {get; set;}    
    public string MSOACode {get; set;}
    public string MSOAName {get; set;}
    public string wardCode {get; set;}

    private boolean finished = true;
    private boolean success = false;
    private User user = null;
    
    private static map<string, Schema.sobjectField> serviceNeedFieldsDescribe = Schema.getGlobalDescribe().get('Support_Needs_Lifestyle__c').getDescribe().fields.getMap();
    private static map<string, Schema.sobjectField> flowFieldsDescribe = Schema.getGlobalDescribe().get('Flow_information__c').getDescribe().fields.getMap();
    private static map<string, Schema.sobjectField> timelineEventFieldsDescribe = Schema.getGlobalDescribe().get('Timeline_Event__c').getDescribe().fields.getMap();
        
    //Initialize all the variables on startup
    public FirstContact() 
    {
        c = new Contact();
       
        id recTypeID = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('FCF_Outreach - initial TLE').RecordTypeId; 
        //te = (Timeline_Event__c)Timeline_Event__c.sObjectType.newSObject(recTypeId, true); 
        te = new Timeline_Event__c(RecordTypeId = recTypeId, Encounter_Type__c = 'Street Contact');
        
        user = [Select Id, Default_Project_Id__c from User where Id=: UserInfo.getUserId()];
        if(user.Default_Project_Id__c!=null)
        {
            try { te.Project_Team__c = user.Default_Project_Id__c; }catch(Exception e){ system.debug(e.getMessage() + ' : ' + e.getStackTraceString());  }
        }
        
        sna = new Support_Needs_Lifestyle__c();
        //Used in case the button is clicked from some Client record with client ID
        strAccId = ApexPages.currentPage().getParameters().get('aid');
        //fetch the existing client values to pre populate on first page of the wizard
        if(strAccId!=null)
        {
            c = [Select Consent_Date__c, firstname, lastname, Other_Names__c, Nickname__c, DOB_Estimated__c, NINumber__c, Email, Phone, MobilePhone, Gender__c, Birthdate, Ethnic_Origin__c, Nationality__c, Country_Region__c, Consent__c, HPU_Notes__c, HPU_Housing_Options_in_last_12_months__c, Name_of_local_authority__c, Last_longer_term_place_settled_base__c, Status__c, Other_base__c, Reason_for_leaving_settled_base__c, Reason_for_leaving_other__c, Other_reason_for_leaving__c, Contributing_factors__c, Other__c,Other_notes__c,Flow_notes__c,Location_last_settled_base_UK__c,Location_last_settled_base_non_UK__c, Places_stayed_1__c, Places_stayed_2__c, Places_stayed_3__c, Country_1__c, Country_2__c, Country_3__c, Local_authority_UK_1__c, Local_authority_UK_2__c, Local_authority_UK_3__c, Immigration_Status__c, Immigration_notes__c, Preferred_Language__c, Spoken_English_Ability__c, Recourse_to_public_funds__c, Armed_forces_2__c, Date_last_left_armed_forces__c, Care_leaver_2__c, Date_last_left_care__c, Prison_2__c,Date_Last_Left_Prison__c, Name_of_Last_Prison__c, Estimated_Date_Last_Left_Prison__c, Equipment__c, Date_entered_UK__c, Date_entered_UK_status__c from Contact where AccountId =:strAccId];
        }
        
        Map<String,String> parameters = ApexPages.currentPage().getParameters();
        
        if (parameters.containsKey('referral')) {
            c.FirstName = parameters.get('firstName');
            c.LastName = parameters.get('lastName');
            
            if (parameters.containsKey('birthDate')) {
                c.Birthdate = Date.valueOf(parameters.get('birthDate'));
            }
            
            c.DOB_Estimated__c = Boolean.valueOf(parameters.get('dobEstimated'));
            c.Gender__c = parameters.get('gender');
            c.Ethnic_Origin__c = parameters.get('ethnicOrigin');
            te.Borough_Street_Site__c = parameters.get('streetName');
            te.Referral_telephone_website_reference__c = parameters.get('referralId');
        }
        
        useSelectedContact();
        
        contactFields = getcontactFields();
        
    }

    public FirstContact(ApexPages.StandardController controller) {
        user = [Select Id, Default_Project_Id__c from User where Id=: UserInfo.getUserId()];
    }
        
    public string getNextPageUrl(){
        
        string returnUrl = '';
        
        boolean navtoMap = false;
        boolean nonContact = false;
        
        list<string> profilesList = Label.Map_Profiles.split(',');
        list<string> nonContactTLEProfiles = Label.First_Contact_TLE_Non.split(',');
        User usr = [select profileId, Profile.Name from User where Id =:UserInfo.getUserId() ];
        
        if (!nonContactTLEProfiles.isEmpty()){
            for (string profile :nonContactTLEProfiles ) {            
                if (usr.Profile.Name == profile){
                    nonContact = true;
                    break;  
                }
            }
        }
        
        /*
        if (!profilesList.isEmpty()){
            if (profilesList[0] == 'ALL'){
                navtoMap = true;
            } else {
            
                for (string profile :profilesList) {            
                    if (usr.Profile.Name == profile){
                        navtoMap = true;
                        break;  
                    }
                }
            }
        }
        */
string profileTimeline = '';
string precTypeName = '';
try {
list<Profile_Map_Timeline_Event_Record_Type__mdt> profileTEMap = [select DeveloperName from Profile_Map_Timeline_Event_Record_Type__mdt where MasterLabel = :usr.Profile.Name LIMIT 1];
if (!profileTEMap.isEmpty())
    precTypeName = profileTEMap[0].DeveloperName;
    RecordType rt = [select Id, Name from RecordType where SobjectType = 'Timeline_Event__c' and DeveloperName = :precTypeName LIMIT 1];
    profileTimeline = rt.Id;
} catch (exception e){
    profileTimeline = '';
}

        if (nonContact){
            id recTypeID = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('FCF_Reconnection - initial TLE').RecordTypeId;
            if (string.isnotBlank(profileTimeline)){
                recTypeId = profileTimeline;
                te = new Timeline_Event__c(RecordTypeId = recTypeId );
            } else {     
            //te = (Timeline_Event__c)Timeline_Event__c.sObjectType.newSObject(recTypeId, true);                             
                te = new Timeline_Event__c(RecordTypeId = recTypeId, Encounter_Type__c = 'Contact with client');
            }
            
            if(user.Default_Project_Id__c!=null)
            {
                try { te.Project_Team__c = user.Default_Project_Id__c; }catch(Exception e){}
            }
            returnUrl = '/apex/firstcontactpage_tle_3_nomap';
        } else {
            id recTypeID2 = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('FCF_Outreach - initial TLE').RecordTypeId;
            if (string.isnotBlank(profileTimeline)){
                recTypeID2 = profileTimeline;
                te = new Timeline_Event__c(RecordTypeId = recTypeId2);
            } else {             
            //te = (Timeline_Event__c)Timeline_Event__c.sObjectType.newSObject(recTypeId2, true); 
                te = new Timeline_Event__c(RecordTypeId = recTypeId2, Encounter_Type__c = 'Street Contact');
            }
            
            if(user.Default_Project_Id__c!=null)
            {
                try { te.Project_Team__c = user.Default_Project_Id__c; 
                  }catch(Exception e){ system.debug(e.getMessage() + ' : ' + e.getStackTraceString());  }
            }
            returnUrl = '/apex/StreetContactMap2?FirstContact=true';
        }
        
        return returnUrl;
    }

    //Used to redirect to the second page of the wizard
    public PageReference createTimelineEvent()
    { 
        Account dummyAccount = setAccountFields();
        
        Savepoint sp = Database.setSavepoint();
        try{
          insert dummyAccount;
        } catch (System.DmlException e) { //show an error message back on page, in any
            for (Integer i =0; i<e.getNumDml(); ++i) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));
            }
            Database.rollback(sp);
            return null;
        }
        
        Database.rollback(sp);
        sp = null;
        
        PageReference pg = new ApexPages.PageReference(getNextPageUrl());
        pg.setRedirect(false);      
        return pg;
    }
    
    public void saveMap(){

    }
    
    public PageReference saveLocationFC(){
        
        PageReference pg = new ApexPages.PageReference('/apex/firstcontactpage_tle_3_map');
        pg.setRedirect(false);

        te = new Timeline_Event__c();       
        id recTypeID2 = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('FCF_Outreach - initial TLE').RecordTypeId; 
        //te = (Timeline_Event__c)Timeline_Event__c.sObjectType.newSObject(recTypeId2, true); 
        te = new Timeline_Event__c(RecordTypeId = recTypeId2, Encounter_Type__c = 'Street Contact');
        te.Postcode__c = postcode;
        te.Latitude_Longitude__c = lng;
        
        ward = ward.unescapeHtml4();
        te.ward__c = ward;
        
        borough = borough.unescapeHtml4();
        te.Borough_from_map__c = borough;
        
        te.Street_site_borough__c = borough;
        te.Location_URL__c = 'https://www.google.co.uk/maps/place/' + lng;
        te.Lower_super_output_area_LSOA_code__c = LSOACode;
        te.Lower_super_output_area_LSOA__c = LSOAName;
        te.Middle_Layer_Super_Output_MSOA_code__c = MSOACode;
        te.Middle_Layer_Super_Output_area_MSOA__c = MSOAName;
        te.Ward_Code__c = wardCode;
        
        user = [Select Id, Default_Project_Id__c from User where Id=: UserInfo.getUserId()];
system.debug('@@@  User Project/team .... ' + user.Default_Project_Id__c);        
        if(user.Default_Project_Id__c!=null)
        {
            try { te.Project_Team__c = user.Default_Project_Id__c;
               }catch(Exception e){ system.debug(e.getMessage() + ' : ' + e.getStackTraceString());  }
        }        
        /* Postcode validation code block - uncomment or comment as required
        if (string.isBlank(postcode)){
            string info = 'Please move the marker slightly to select a location with a full postcode. This is due to limitations in the google mapping data';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, info));
            pg = null;  
        }
        */
        
        return Pg;
        
    }

    public PageReference saveAndAddFlow(){
system.debug('@@@@@@@@@@@@   calling save ..... ');        
        PageReference pgSave = this.Save();
        PageReference pg = null;
        
        if (success) {
            flowInfo = new Flow_information__c();
            flowInfo.client__c = this.te.Client__c; 
            pg = new PageReference('/apex/Firstcontactpage_flow_4');
            pg.setRedirect(false);
        } else {
            pg = null;
        }
        
        return pg;
        
    }
    

    
    public pageReference saveFlow(){
        
        PageReference pg = null;
        try
        {   
                
            if (finished)
                pg = new PageReference('/' + strAccId);
                
            success = false;
            insert this.flowInfo;
            success = true;
                
        }//Show error message, if any
        catch (System.DmlException e) {
            for(Integer i =0; i<e.getNumDml(); ++i) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));  
            }
            pg = null;
        }

        return pg;    
    
    }
    
    public PageReference saveAndAddSupportNeedsfromTLE(){

        finished = false;
        PageReference pgSave = this.Save();
        
    if (success ){
            PageReference pg = new PageReference('/apex/Firstcontactpage_sna_5');
            pg.setRedirect(false);
            
            return pg;
        } else {
            return null;
        }
    
    }
    
    public PageReference saveAndAddSupportNeeds(){
    
        finished = false;
        PageReference pgSave = this.saveFlow();
        
        if (success ){
            PageReference pg = new PageReference('/apex/Firstcontactpage_sna_5');
            pg.setRedirect(false);
            
            return pg;
        } else {
            return null;
        }
    
    }
    
    public Contact getContact()
    {
        return this.c;
    }
    public Timeline_Event__c getTimeLineEvent()
    {
        return this.te;
    }
    public Support_Needs_Lifestyle__c getSNA()
    {
        return this.sna;
    }
    //Used to redirect the user back to first page of the wizard, in case he is trying to come to the second page directly
    public PageReference checkSourcePage()
    {
        if(c.LastName==null)
            {
                PageReference p = Page.firstcontactpage1;
                p.setRedirect(true); 
                return p;
            }   
        else    
            {
                return null;
            }   
    }
    /*
    public String getIsNotesRequired()
    {
        System.debug('STREET SIE: ' + this.te);
        if(this.te.Street_Site__c!=null)
        {
            Street_Site__c ss = [Select Name from Street_Site__c where Id =: this.te.Street_Site__c];
            if(ss!=null && ss.Name=='Other – Specify in Notes')
                return 'true';  
        }
        return 'false'; 
    }*/
    //On click of the save button on the first page, update/create a client record and timeline event record
    public PageReference Save()
    {
        /*if(getIsNotesRequired() && this.te.Notes__c==null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Notes: You must enter a value'));
            return null;
        }*/
        system.debug ('@@@@@@@@@@@@   save called .. ');
        system.debug(' @@@@  contact ..  ' + this.c);
        system.debug(' @@@@@@@@@@@@   printed contact ...');
        Account a = null;        
        if (string.isBlank(this.selectedAccount)){
            a = setAccountFields();
        } else {
            a = [select Id from Account where Id =:selectedAccount];
        }
        
        Savepoint sp = Database.setSavepoint();
        
             
        try {
            //If button was clicked from a client record, update the existing record
            if (string.isnotBlank(this.selectedAccount)){
                update a;
            }
            else if (strAccId!=null || a.Id!=null) {
                insert a;
            } else {
                //else create a new client record
                insert a;
                strAccId = a.Id;
            }
        } catch (System.DmlException e) { //show an error message back on page, in any
            for (Integer i =0; i<e.getNumDml(); ++i) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));
            }
            Database.rollback(sp);
            success = false;
            PageReference pg1 = new ApexPages.PageReference('/apex/firstcontactpage_client_1');
            pg1.setRedirect(false);
            return pg1;
        }
        
        //For a person account, get the related contact Id
        Account pAccount = [Select PersonContactId from Account where Id=: a.Id];
        
        if(this.te.Client__c==null)
            this.te.Client__c = pAccount.PersonContactId;
        //First COntact form has to create a timeline event of record type encounter, hence fetch the encounet record type id
        //RecordType rtE = [Select Id From RecordType where SobjectType='Timeline_Event__c' and Name='Encounters'];
        //this.te.RecordTypeId = rtE.Id;

        string requiredFields = '';
        for (integer i :timelineEventFields.keySet()){
            list<Schema.FieldSetMember> fldList = timelineEventFields.get(i);            
            for (Schema.FieldSetMember fld :fldList){
                boolean exclude = false;
                string val = string.valueOf(this.te.get(fld.fieldPath));
                if (exclusionFields.containsKey(fld.fieldPath)){
                    if (exclusionFields.get(fld.fieldPath) == 'Timeline_Event__c'){
                        exclude = true;
                    }
                }
                if (string.isBlank(val) && fld.required && !exclude){
                    requiredFields += ' Please enter a value for - ' + fld.label  +  '<br/>';                
                }
            }
        
        }
        
        PageReference pg = new PageReference('/' + a.Id);
        
        if (string.isnotBlank(requiredFields)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, requiredFields));
            pg = null;
            Database.rollback(sp); 
        } else {
            try {
                //as all other values are set on the page, set the record type id of timeline event record and insert
                //insert this.te;
                database.upsert(this.te);
                success = true;
            } catch (System.DmlException e) {//show any error on page
                for (Integer i =0; i<e.getNumDml(); ++i) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));
                    Database.rollback(sp);
                    this.te.Client__c=null;               
                }
                success = false;
                pg =  null;
            }
        }
        //return back to the client record
        return pg;
    }
    //Used to redirect to the second page of the wizard
    public PageReference AddSupportNeeds()
    { 
        PageReference p = Save();
        if(p==null)
            return p;
        PageReference pfinal = Page.firstcontactpage2; 
        return pfinal;
    }
    //Used on teh click of the save button, on second page of wizard
    public PageReference SaveSNA()
    {
        this.sna.Client__c = this.te.Client__c;
        strAccId = this.sna.Client__c; 
        // this.sna.Client2__c = this.strAccId; //TODO: Query Ian if this field is needed
        //Add some validations, if fine, insert the Support Need record, related to the client record
        try
        {   
            if(sna.Alcohol__c!=null || sna.Alcohol_Notes__c!=null || sna.Drugs__c!=null || sna.Drugs_Notes__c!=null || sna.Mental_health_worker__c!=null || sna.Mental_Health_worker_assessed_notes__c!=null || sna.Mental_health_professional__c!=null || sna.Mental_Health_professional_Notes__c!=null || sna.Physical_health__c!=null || sna.Physical_Health_Notes__c!=null || sna.Gambling__c!=null || sna.Gambling_Notes__c!=null || sna.Learning_Disabilities__c!=null || sna.Learning_Disabilities_Notes__c!=null || sna.Sex_Worker__c!=null || sna.Sex_Worker_Notes__c!=null || sna.Other_Vulnerability__c!=null || sna.Other_Vulnerability_Notes__c!=null) 
                insert this.sna;
        }//Show error message, if any
        catch (System.DmlException e) {
            for(Integer i =0; i<e.getNumDml(); ++i) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));  
            }
            return null;
        }
        //return bakc to the client record
        return new PageReference('/' + strAccId);
    }
    //On click of the cancel button 
    public PageReference Cancel()
    {
        id chk = this.te.Client__c;
        strAccId = chk;
        
        try {
            if(strAccId!=null)
                return new PageReference('/' + strAccId);
            else
                return new PageReference('/001/o'); 
        } catch (exception e){
        
            return new PageReference('/001/o');
        }
    }
  
  private Account setAccountFields(){

        //Working only for person accounts
        RecordType rt = [Select Id From RecordType where SobjectType='Account' and isPersonType=true and Name='Client Account'];
        //Set all the contact values populated by user on the form, into a person account
        Account a = new Account(RecordTypeId=rt.Id);
        //if(strAccId!=null)
            //a = new Account(RecordTypeId=rt.Id, Id= strAccId);
        a.firstname = this.c.firstName;
        a.lastName = this.c.lastName;
        a.Nickname__pc = this.c.Nickname__c;
        a.Other_Names__pc = this.c.Other_Names__c;
        a.Gender__pc = this.c.Gender__c;
        a.PersonBirthdate = this.c.Birthdate;
        a.DOB_Estimated__pc = this.c.DOB_Estimated__c;
        a.NINumber__pc = this.c.NINumber__c;
        a.PersonEmail = this.c.Email;
        a.Phone = this.c.Phone;
        a.PersonMobilePhone = this.c.MobilePhone;
        
        a.Ethnic_Origin__pc = this.c.Ethnic_Origin__c;
        a.Nationality__pc=this.c.Nationality__c;
        
        a.Immigration_Status__pc = this.c.Immigration_Status__c;
        a.Immigration_notes__pc = this.c.Immigration_notes__c;
        a.Country_Region__pc = this.c.Country_Region__c;
        
        a.Preferred_Language__pc = this.c.Preferred_Language__c;
        a.Spoken_English_Ability__pc = this.c.Spoken_English_Ability__c;
        
        a.Recourse_to_public_funds__pc = this.c.Recourse_to_public_funds__c;
        
        a.Date_entered_UK__pc = this.c.Date_entered_UK__c; 
        a.Date_entered_UK_status__pc = this.c.Date_entered_UK_status__c;
        
        a.Consent__pc = this.c.Consent__c;
        a.Consent_Date__pc = this.c.Consent_Date__c;
        
        a.Armed_forces_2__pc = this.c.Armed_forces_2__c;
        a.Date_last_left_armed_forces__pc = this.c.Date_last_left_armed_forces__c;
        
        a.Care_leaver_2__pc = this.c.Care_leaver_2__c;
        a.Date_last_left_care__pc = this.c.Date_last_left_care__c;
        
        a.Prison_2__pc = this.c.Prison_2__c;
        a.Date_Last_Left_Prison__pc = this.c.Date_Last_Left_Prison__c;
        
        a.Name_of_Last_Prison__pc = this.c.Name_of_Last_Prison__c;
        a.Estimated_Date_Last_Left_Prison__pc = this.c.Estimated_Date_Last_Left_Prison__c;
        
        a.Equipment__pc = this.c.Equipment__c;
        
        // Flow fields
        
        a.Last_longer_term_place_settled_base__pc = c.Last_longer_term_place_settled_base__c;
        a.Reason_for_leaving_settled_base__pc = c.Reason_for_leaving_settled_base__c;
        
        a.Status__pc = c.Status__c;
        a.Reason_for_leaving_other__pc = c.Reason_for_leaving_other__c;
        
        a.Other_base__pc = c.Other_base__c;
        a.Other_reason_for_leaving__pc = c.Other_reason_for_leaving__c;
        
        a.Contributing_factors__pc = c.Contributing_factors__c;
        
        a.Location_last_settled_base_UK__pc = c.Location_last_settled_base_UK__c;
        a.Location_last_settled_base_non_UK__pc = c.Location_last_settled_base_non_UK__c;
        
        a.Places_stayed_1__pc = c.Places_stayed_1__c;
        a.Places_stayed_2__pc = c.Places_stayed_2__c;
        a.Places_stayed_3__pc = c.Places_stayed_3__c;
        
        a.Country_1__pc = c.Country_1__c;
        a.Country_2__pc = c.Country_2__c;
        a.Country_3__pc = c.Country_3__c;
        
        a.Local_authority_UK_1__pc = c.Local_authority_UK_1__c;
        a.Local_authority_UK_2__pc = c.Local_authority_UK_2__c;
        a.Local_authority_UK_3__pc = c.Local_authority_UK_3__c; 
                     
        a.Other__pc = c.Other__c;
        a.Other_notes__pc = c.Other_notes__c;
        
        a.Flow_notes__pc = c.Flow_notes__c;
        
        a.HPU_Housing_Options_in_last_12_months__pc = c.HPU_Housing_Options_in_last_12_months__c;
        a.HPU_Notes__pc = c.HPU_Notes__c;
        a.Name_of_local_authority__pc = c.Name_of_local_authority__c;
        
        return a;
    
  }



    public PageReference quickSaveClient(){
       
        timelineEventFields = getTimelineEventFields(null);
        PageReference pg = new PageReference('/apex/FCF_Map');
        pg.setRedirect(false);
        
        string requiredFields = '';
        for (integer i :contactFields.keySet()){
            list<Schema.FieldSetMember> fldList = contactFields.get(i);
            for (Schema.FieldSetMember fld :fldList){
                string val = string.valueOf(this.c.get(fld.fieldPath));
                if (string.isBlank(val) && fld.required){
                    requiredFields += ' Please enter a value for - ' + fld.label  +  '<br/>';                
                }
            }
        
        }
        
        if (string.isnotBlank(requiredFields)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, requiredFields));
            pg = null;        
        } else {
            Account a = null;        
            if (string.isBlank(this.selectedAccount)){
                a = setAccountFields();
            } else {
                a = [select Id from Account where Id =:selectedAccount];
            }
            
            Savepoint sp = Database.setSavepoint();
            
                 
            try {
                //If button was clicked from a client record, update the existing record
                if (string.isnotBlank(this.selectedAccount)){
                    update a;
                }
                else if (strAccId!=null || a.Id!=null) {
                    insert a;
                } else {
                    //else create a new client record
                    insert a;
                }
            } catch (System.DmlException e) { //show an error message back on page, in any
                for (Integer i =0; i<e.getNumDml(); ++i) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));
                }
                
                pg = null;
            }
            
            Database.rollback(sp);
        }
        return pg;
    }
    
    public PageReference saveLocationFCMobile(){

        
        if (this.timelineEventFields == null)
            this.timelineEventFields = gettimelineEventFields(null);

                
        PageReference pg = new PageReference('/apex/FCF_Timeline_Event');
        pg.setRedirect(false);

        te = new Timeline_Event__c();       
        id recTypeID2 = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('FCF_Outreach - initial TLE').RecordTypeId; 
        //te = (Timeline_Event__c)Timeline_Event__c.sObjectType.newSObject(recTypeId2, true); 
        te = new Timeline_Event__c(RecordTypeId = recTypeId2, Encounter_Type__c = 'Street Contact');
        te.Postcode__c = postcode;
        te.Latitude_Longitude__c = lng;
        te.ward__c = ward.unescapeHtml4();
        te.Borough_from_map__c = borough.unescapeHtml4();
        te.Street_site_borough__c = borough.unescapeHtml4();
        te.Location_URL__c = 'https://www.google.co.uk/maps/place/' + lng;
        
        te.Lower_super_output_area_LSOA_code__c = LSOACode;
        te.Lower_super_output_area_LSOA__c = LSOAName;
        te.Middle_Layer_Super_Output_MSOA_code__c = MSOACode;
        te.Middle_Layer_Super_Output_area_MSOA__c = MSOAName;
        te.Ward_Code__c = wardCode;
        
        te.FCF_Quick_Entry__c = true;
        
        user = [Select Id, Default_Project_Id__c from User where Id=: UserInfo.getUserId()];
system.debug('@@@  User Project/team .... ' + user.Default_Project_Id__c);        
        if(user.Default_Project_Id__c!=null)
        {
            try { te.Project_Team__c = user.Default_Project_Id__c;
               }catch(Exception e){ system.debug(e.getMessage() + ' : ' + e.getStackTraceString());  }
        }        

        return pg;      
        
    }
    

    public PageReference saveAndAddFlowMobile(){
      
        success = true;
        PageReference pg = null;

        string requiredFields = '';
        
        for (integer i :timelineEventFields.keySet()){
            list<Schema.FieldSetMember> fldList = timelineEventFields.get(i);            
            for (Schema.FieldSetMember fld :fldList){
                boolean exclude = false;
                string val = string.valueOf(this.te.get(fld.fieldPath));
                if (exclusionFields.containsKey(fld.fieldPath)){
                    if (exclusionFields.get(fld.fieldPath) == 'Timeline_Event__c'){
                        exclude = true;
                    }
                }
                if (string.isBlank(val) && fld.required && !exclude){
                    requiredFields += ' Please enter a value for - ' + fld.label  +  '<br/>';                
                }
            }
        
        }
        
        
        if (string.isnotBlank(requiredFields)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, requiredFields));
            pg = null;                
        } else {        
            try {
                PageReference pgSave = this.save();
            } catch (exception e){
                system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
                success = false;
                for(Integer i =0; i<e.getNumDml(); ++i) { 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));  
                }
                pg = null;            
            }
            
            
            if (success) {
              
              if (this.c.Date_First_Seen_Rough_Sleeping__c == null){
              //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You cannot record a Flow information record for a client who has not been seen sleeping rough'));  
              //  return null;
              }
                if (this.c.Count_of_new_rs_flow_forms__c > 0){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You cannot create more than one flow record per client'));
                  return null;
                }
              
                flowFields = getflowFields();
                this.flowInfo = new Flow_information__c();
        for (integer key :flowFields.keySet()){
          list<Schema.FieldSetMember> fList = flowFields.get(key);
          for (Schema.FieldSetMember f :fList){
                    string dataType = '';
                    string fieldName = '';
            dataType = string.valueOf(f.getType());                
            if (dataType == 'PICKLIST'){
              fieldName = string.valueOf(f.getFieldPath());
              string defaultValue = getDefaultPicklistValue(flowFieldsDescribe, fieldName);
              this.flowInfo.put(fieldName, defaultValue);
            }
                            
          }
        }
                
    system.debug('@@@ this.te ... ' + this.te);
    system.debug('@@@ this.contact ... ' + this.c);            
                flowInfo.client__c = this.te.client__c;
                strAccId =  this.te.client__c;
                pg = new PageReference('/apex/FCF_Flow_Information');
                pg.setRedirect(false);
            } else {
                pg = null;
            }
        }
        
        return pg;
        
    }    
    
    public PageReference saveFlowandExit(){
        
        PageReference pg = null;
        success = true;


        string requiredFields = '';
        for (integer i :flowFields.keySet()){
            list<Schema.FieldSetMember> fldList = flowFields.get(i);
            for (Schema.FieldSetMember fld :fldList){
                string val = string.valueOf(this.flowInfo.get(fld.fieldPath));
                if (string.isBlank(val) && fld.required){
                    requiredFields += ' Please enter a value for - ' + fld.label  +  '<br/>';                
                }
            }
        
        }
        
        
        if (string.isnotBlank(requiredFields)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, requiredFields));
            pg = null;                
        } else {

            try
            {   
                strAccId =  this.te.client__c;
                pg = new PageReference('/' + strAccId);
    
    system.debug('@@@@ saveFlowandExit called ! ' + this.flowInfo);
                insert this.flowInfo;
                success = true;
    system.debug('@@@@ saveFlowandExit complete ! ' + success);                
            }//Show error message, if any
            catch (System.DmlException e) {
                for(Integer i =0; i<e.getNumDml(); ++i) { 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));  
                }
                pg = null;
            }
        
        }
        
        return pg;    
    }
    
    public PageReference saveFlowandAddSupportNeeds(){
        
        success = true;
        PageReference pg = null;


        string requiredFields = '';
        for (integer i :flowFields.keySet()){
            list<Schema.FieldSetMember> fldList = flowFields.get(i);
            for (Schema.FieldSetMember fld :fldList){
                string val = string.valueOf(this.flowInfo.get(fld.fieldPath));
                if (string.isBlank(val) && fld.required){
                    requiredFields += ' Please enter a value for - ' + fld.label  +  '<br/>';                
                }
            }
        
        }
        
        
        if (string.isnotBlank(requiredFields)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, requiredFields));
            pg = null;                
        }  else {      
            try {
                insert this.flowInfo;
            }
            catch (System.DmlException e){
                system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
                for(Integer i =0; i<e.getNumDml(); ++i) { 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));  
                }
                pg = null;            
                success = false;        
            }
            if (success) {
                serviceNeedFields = getserviceNeedFields();
                sna = new Support_Needs_Lifestyle__c();
                this.sna.Client__c = this.te.Client__c;
                
        for (integer key :serviceNeedFields.keySet()){
          list<Schema.FieldSetMember> fList = serviceNeedFields.get(key);
          for (Schema.FieldSetMember f :fList){
                    string dataType = '';
                    string fieldName = '';
            dataType = string.valueOf(f.getType());                
            if (dataType == 'PICKLIST'){
              fieldName = string.valueOf(f.getFieldPath());
              string defaultValue = getDefaultPicklistValue(serviceNeedFieldsDescribe, fieldName);
              this.sna.put(fieldName, defaultValue);
            }
                            
          }
        }                
                
                pg = new PageReference('/apex/FCF_Service_Needs');
                pg.setRedirect(false);
            }
        }
        return pg;    
    
    }
    
    public pageReference saveSupportNeedsandExit(){

        string requiredFields = '';
        PageReference pg =null;
        
        for (integer i :serviceNeedFields.keySet()){
            list<Schema.FieldSetMember> fldList = serviceNeedFields.get(i);
            for (Schema.FieldSetMember fld :fldList){
                string val = string.valueOf(this.sna.get(fld.fieldPath));
                if (string.isBlank(val) && fld.required){
                    requiredFields += ' Please enter a value for - ' + fld.label  +  '<br/>';                
                }
            }
        
        }
        
        
        if (string.isnotBlank(requiredFields)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, requiredFields));
            pg = null;                
        }  else {
        
            pg = SaveSNA();
        }
        
        return pg;    
    
    }
    
    public string selectedContact{get; set;}
    public string selectedAccount{get;set;}
    public string selectedClientName {get; set;}
    public map<integer, list<Schema.FieldSetMember>> contactFields {get; set;}
    public map<integer, list<Schema.FieldSetMember>> contactDemographicFields {get; set;}
    public map<integer, list<Schema.FieldSetMember>> contactInstitutionalHistoryFields {get; set;}
    public map<integer, list<string>> contactFieldFormat {get; set;}
    public map<integer, list<string>> contactDemographicFieldFormat {get; set;}
    public map<integer, list<string>> contactInstitutionalHistoryFieldFormat {get; set;}
    public map<integer, list<Schema.FieldSetMember>> timelineEventFields {get; set;}
    public map<integer, list<string>> timelineEventFieldFormat {get; set;}
    public map<integer, list<Schema.FieldSetMember>> flowFields {get; set;}
    public map<integer, list<Schema.FieldSetMember>> flowPlacesStayedFields1 {get; set;}
    public map<integer, list<Schema.FieldSetMember>> flowPlacesStayedFields2 {get; set;}
    public map<integer, list<Schema.FieldSetMember>> flowPlacesStayedFields3 {get; set;}
    public map<integer, list<Schema.FieldSetMember>> flowAdviceFields1 {get; set;}
    public map<integer, list<Schema.FieldSetMember>> flowAdviceFields2 {get; set;}
    public map<integer, list<Schema.FieldSetMember>> flowAdviceFields3 {get; set;}
    public map<integer, list<Schema.FieldSetMember>> flowAdviceFields4 {get; set;}
    public map<integer, list<string>> flowFieldFormat {get; set;}
    public map<integer, list<string>> flowPlacesStayedFieldFormat1 {get; set;}
    public map<integer, list<string>> flowPlacesStayedFieldFormat2 {get; set;}
    public map<integer, list<string>> flowPlacesStayedFieldFormat3 {get; set;}
    public map<integer, list<string>> flowAdviceFormat1 {get; set;}
    public map<integer, list<string>> flowAdviceFormat2 {get; set;}
    public map<integer, list<string>> flowAdviceFormat3 {get; set;}
    public map<integer, list<string>> flowAdviceFormat4 {get; set;}
    public map<integer, list<Schema.FieldSetMember>> serviceNeedFields {get; set;}
    public map<integer, list<string>> serviceNeedFieldFormat {get; set;}
    private map<string, string> exclusionFields = new map<string, string>();
    
    public map<integer, list<Schema.FieldSetMember>> getcontactFields(){
    
        list<Schema.FieldSetMember> fldList = readFieldSet('MobileClientEntry', 'Contact');
        map<integer, list<Schema.FieldSetMember>> returnMap = new map<integer, list<Schema.FieldSetMember>>();
        contactFieldFormat  = new map<integer, list<string>>();
        returnMap =  getObjectFields(fldList, contactFieldFormat, null );       

        fldList = readFieldSet('Demographics', 'Contact');
        contactDemographicFieldFormat = new map<integer, list<string>>();
        contactDemographicFields = getObjectFields(fldList, contactDemographicFieldFormat, null );
           
        fldList = readFieldSet('Institutional_history', 'Contact');
        contactInstitutionalHistoryFieldFormat = new map<integer, list<string>>();
        contactInstitutionalHistoryFields = getObjectFields(fldList, contactInstitutionalHistoryFieldFormat, null );         
        
        
        return returnMap;
    
    }

    public map<integer, list<Schema.FieldSetMember>> gettimelineEventFields(map<string, string>exclusionFields){
        
        map<integer, list<Schema.FieldSetMember>> returnMap = new map<integer, list<Schema.FieldSetMember>>();
        
        if (this.timelineEventFields == null ) {
            list<Schema.FieldSetMember> fldList = readFieldSet('MobileTimelineEventEntry', 'Timeline_Event__c');
            
            timelineEventFieldFormat = new map<integer, list<string>>();
            returnMap =  getObjectFields(fldList, timelineEventFieldFormat, exclusionFields);       
        } else {
            returnMap = this.timelineEventFields ;
        }
        
        return returnMap;
    
    }

    public map<integer, list<Schema.FieldSetMember>> getflowFields(){
    
        list<Schema.FieldSetMember> fldList = readFieldSet('MobileFlowInfoEntry', 'Flow_information__c');
        map<integer, list<Schema.FieldSetMember>> returnMap = new map<integer, list<Schema.FieldSetMember>>();
        flowFieldFormat = new map<integer, list<string>>();
        returnMap =  getObjectFields(fldList, flowFieldFormat, null);       
        
        fldList =  readFieldSet('FlowPlacesStayed1', 'Flow_information__c');
        flowPlacesStayedFieldFormat1 = new map<integer, list<string>>();
        flowPlacesStayedFields1 = getObjectFields(fldList, flowPlacesStayedFieldFormat1, null); 

        fldList =  readFieldSet('FlowPlacesStayed2', 'Flow_information__c');
        flowPlacesStayedFieldFormat2 = new map<integer, list<string>>();
        flowPlacesStayedFields2 = getObjectFields(fldList, flowPlacesStayedFieldFormat2, null); 

        fldList =  readFieldSet('FlowPlacesStayed3', 'Flow_information__c');
        flowPlacesStayedFieldFormat3 = new map<integer, list<string>>();
        flowPlacesStayedFields3 = getObjectFields(fldList, flowPlacesStayedFieldFormat3, null);     

		fldList =  readFieldSet('FlowPlacesStayed1', 'Flow_information__c');
        flowPlacesStayedFieldFormat1 = new map<integer, list<string>>();
        flowPlacesStayedFields1 = getObjectFields(fldList, flowPlacesStayedFieldFormat1, null); 

		fldList =  readFieldSet('AdviceAgency1', 'Flow_information__c');
        flowAdviceFormat1 = new map<integer, list<string>>();
        flowAdviceFields1 = getObjectFields(fldList, flowAdviceFormat1, null); 

		fldList =  readFieldSet('AdviceAgency2', 'Flow_information__c');
        flowAdviceFormat2 = new map<integer, list<string>>();
        flowAdviceFields2 = getObjectFields(fldList, flowAdviceFormat2, null); 

		fldList =  readFieldSet('AdviceAgency3', 'Flow_information__c');
        flowAdviceFormat3 = new map<integer, list<string>>();
        flowAdviceFields3 = getObjectFields(fldList, flowAdviceFormat3, null); 

		fldList =  readFieldSet('AdviceAgency4', 'Flow_information__c');
        flowAdviceFormat4 = new map<integer, list<string>>();
        flowAdviceFields4 = getObjectFields(fldList, flowAdviceFormat4, null);         
        return returnMap;
    
    }

    public map<integer, list<Schema.FieldSetMember>> getserviceNeedFields(){
    
        list<Schema.FieldSetMember> fldList = readFieldSet('MobileSupportNeedsEntry', 'Support_Needs_Lifestyle__c');
        map<integer, list<Schema.FieldSetMember>> returnMap = new map<integer, list<Schema.FieldSetMember>>();
        serviceNeedFieldFormat = new map<integer, list<string>>();
        returnMap =  getObjectFields(fldList, serviceNeedFieldFormat, null);       

        return returnMap;
    
    }
            
    private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    
    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
 
        return fieldSetObj.getFields(); 
    }   
    
    private static map<integer, list<Schema.FieldSetMember>> getObjectFields(list<Schema.FieldSetMember> fldList, map<integer, list<string>> fldFormat, map<string, string>exclusionFields){

        map<integer, list<Schema.FieldSetMember>> returnMap = new map<integer, list<Schema.FieldSetMember>>();
        
        integer counter = 1;
        string key = '';
        list<Schema.FieldSetMember> fldRow = new list<Schema.FieldSetMember>();
        
        for (Schema.FieldSetMember f :fldList){
            if (math.mod(counter, 2) == 0){
                fldRow.add(f);
                returnMap.put(counter, fldRow);
                fldRow = new list<Schema.FieldSetMember>();      
            } else {
                fldRow.add(f);
            }
            counter++;
        }
        if (!fldRow.isEmpty()){
            fldRow.add(fldRow[0]);
            returnMap.put(counter, fldRow);
        }

system.debug(' @@@@ exclusionFields ..  ' + exclusionFields);        
        for (integer k :returnMap.keySet()){
            
            list<Schema.FieldSetMember> fList = returnMap.get(k);
            list<string> formatList = new list<string>();
            counter = 0;
            for (Schema.FieldSetMember f :fList){
                string format = '';
                string dataType = '';
                
                boolean exclude = false;
system.debug(' @@@  1 ' + f.fieldPath + ' - ' + f.getType());
        dataType = string.valueOf(f.getType());
               
                if (exclusionFields != null){

system.debug(' @@@  2 ' + f.fieldPath + ' - ' + exclusionFields.containsKey(f.fieldPath)); 
                    if (exclusionFields.containsKey(f.fieldPath)){
                        exclude = true;
                    }
                }                
                if ((f.required || f.DBRequired) && !exclude){
                    format += ' slds-form-element  slds-size--1-of-1 slds-medium-size--1-of-1 slds-large-size--1-of-2 slds-col--padded-medium slds-is-required req';
                } else {
                    format += ' slds-form-element  slds-size--1-of-1 slds-medium-size--1-of-1 slds-large-size--1-of-2 slds-col--padded-medium  ';                   
                }
                if (counter == 1){
                    if (fList[0] == fList[1]){
                        format += ' slds-hide';
                    }
                
                }
                counter++;
                formatList.add(format);
                formatList.add(dataType);
            }
            fldFormat.put(k, formatList);
        }

        return returnMap;    
        
    }
        
    public void useSelectedContact() {
        
        selectedContact = ApexPages.currentPage().getParameters().get('selectedContact');
        selectedAccount = ApexPages.currentPage().getParameters().get('selectedAccount');
        
        system.debug(' @@@@  ' + selectedContact);
        
        if (string.isnotBlank(selectedContact)){
            this.c = [select Gender__c, Name, Nationality__c, FirstName, LastName, BirthDate, Other_Names__c, Ethnic_Origin__c, 
                                Nickname__c, DOB_Estimated__c, Country_Region__c, Last_longer_term_place_settled_base__c,
                                Reason_for_leaving_settled_base__c, Places_stayed_1__c, Date_First_Seen_Rough_Sleeping__c,
                            Count_of_new_rs_flow_forms__c
                      from contact where Id = :selectedContact];
            selectedClientName = this.c.Name;
            exclusionFields.put('NSNO_Action__c', 'Timeline_Event__c');
            this.timelineEventFields = gettimelineEventFields(exclusionFields);
            
        } else {
            selectedClientName = this.c.FirstName + ' ' + this.c.LastName;
        }
                
                    
    }

  private static string getDefaultPicklistValue(map<string, Schema.sobjectField> objectFields, string fieldName){

    string returnValue = '';
    
      Schema.SObjectField sfield = objectFields.get(fieldName);
        schema.describeFieldResult dfield = sfield.getDescribe();

        List<Schema.PicklistEntry> listValues = dfield.getPicklistValues();
        for (Schema.PicklistEntry ps :listValues){
      if (ps.isDefaultValue()) {
        returnValue = ps.getValue();
        break;
      }
        }    
    return returnValue;    
  }
    
    public PageReference mobileCancel(){
        
        PageReference  pg = new PageReference('/apex/ClientSearch');
        return pg;
                    
    }
        
}