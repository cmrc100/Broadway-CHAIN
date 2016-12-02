/*
###########################################################################
# Project Name..........: <<Broadway  >>
# File..................: <<Timline.cls >>
# Version...............: << >>
# Created by............: <<Gulshan Middha>>
# Created Date..........: <<20-Jan-2009>>
# Last Modified by......: <<Gulshan Middha >>
# Last Modified Date....: << >>
# Description...........: <<The class is being used by the Multitimeline event page and the timeline triggers >>
# Copyright (c) 2000-2008. Astadia, Inc. All Rights Reserved.
#
# Created by the Astadia, Inc. Modification must retain the above copyright notice.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any commercial purpose, without fee, and without a written
# agreement from Astadia, Inc., is hereby forbidden. Any modification to source
# code, must include this paragraph and copyright.
#
# Permission is not granted to anyone to use this software for commercial uses.
#
# Contact address: 2839 Paces Ferry Road, Suite 350, Atlanta, GA 30339
# Company URL : http://www.astadia.com
###########################################################################
*/

public without sharing class Timeline {
    //The class is being used by the Multitimeline event page and the timeline triggers
    ApexPages.StandardController controller = null;
    Timeline_Event__c t;
    String strKey; 
    List<Contact> strSearchResults;
    List<String> lstOptionsAvailable{get;set;}
    List<String> lstOptionsSelected{get;set;}
    public String strSelectedClients{get;set;}
    public boolean submitForm{get;set;}
    
    List<SelectOption> lstOptions = new List<SelectOption>(); 
    List<SelectOption> lstSelectedoptions = new List<SelectOption>(); 
    Map<Id,Contact> selectedMap = new Map<Id,Contact>();
    Map<Id,Contact> ContactMap = new Map<Id,Contact>();
    Set<Id> cSet = new Set<Id>();
    
    private string lngLat = '';
    private string accountId=  '';
    private string streetUrl = '';
    private string ward = '';
    private string borough = '';
    private string street = '';
    private string postcode = '';
    private string LSOAName = '';
    private string LSOACode = '';
    private string MSOAName = '';
    private string MSOACode = '';
    private string wardCode = '';
    private string actionPlan = '';
    private string veryPrivateActionPlan = '';
    
    //get the Search key entered by user
    public String getSearchKey()
    {
        return this.strKey;
    }
    public void setSearchKey(String s)
    {
        this.strKey=s;
    }
    //Search client records matching the search key, this executes when the client clicks i=on the button.
    public Pagereference SearchClients()
    {
        lstOptions = new List<SelectOption>();
        //WE have to retain the records selected by user in previous search
        if(strSelectedClients!=null && strSelectedClients.trim()!='')
        {
            lstSelectedoptions = new List<SelectOption>();
            //If any already selected records exist, add them in the result list
            List<String> selectedIndex = strSelectedClients.split(';');
            if(selectedIndex!=null && selectedIndex.size()>0)
            {
                for(String s: selectedIndex)
                {
                    if(ContactMap.containsKey(s))
                    {
                        lstOptions.add(new SelectOption(ContactMap.get(s).Id,ContactMap.get(s).Name));
                    }
                }   
            }
        }
        submitForm=true;
        //options = new List<SelectOption>();
        //search for the matching client records in the global variable 
        if(strKey!=null && strKey.trim()!='')
        {
            String strTKey = '%' + strKey + '%';
            
            strSearchResults = [Select Id,Name from Contact where AccountId!=null AND Account.IsPersonAccount=true AND (FirstName like: strTKey OR LastName like: strTKey OR Nickname__c like: strTKey OR Other_Names__c like: strTKey)];
            
            submitForm=false;
        }
        
        return null;
    }
    public List<SelectOption> getSelectedClientOptions()
    {
        return lstSelectedoptions;
    }
    //return the matching client records in an option list
    public List<SelectOption> getClients() 
    {
        //ContactMap = new Map<Id,Contact>();
        if(strSearchResults!=null && strSearchResults.size()>0)
            {
                for(Integer i=0;i<strSearchResults.size();i++)
                {   
                    ContactMap.put(strSearchResults[i].Id,strSearchResults[i]);
                    lstOptions.add(new SelectOption(strSearchResults[i].Id,strSearchResults[i].Name));
                }   
            }
        else
            lstOptions.clear();        
               
        return lstOptions;
    }
    //create timeline event records on click of the save button
    public Pagereference Save()
    {
        submitForm = true;
        if(strSelectedClients!=null && strSelectedClients.trim()!='')
        {
            //get the encounter record type id, as all the timeline event records should be of this record type
            submitForm=false;
            RecordType rtE = [Select Id From RecordType where SobjectType='Timeline_Event__c' and Name='Encounters'];
            List<String> selectedIndex = strSelectedClients.split(';');
            //as all the selected clients are set in a multipicklist, the values are concatinated with a ';'
            //split them and create records in salesforce
            if(selectedIndex!=null && selectedIndex.size()>0)
            {
                List<Timeline_Event__c> teList = new List<Timeline_Event__c>();
                for(String s: selectedIndex)
                {
                    
                    Timeline_Event__c te = new Timeline_Event__c(Client__c =  s);
                    
                    te.RecordTypeId = rtE.Id;
                    te.Project_Team__c = t.Project_Team__c;
                    te.Date__c = t.Date__c;
                    te.Encounter_Type__c = t.Encounter_Type__c;
                    te.other_Site__c = t.Other_site__c;
                    te.Notes__c = t.Notes__c;
                    te.Work_Carried_Out_1__c = t.Work_Carried_Out_1__c;
                    te.Work_Carried_Out_2__c = t.Work_Carried_Out_2__c;
                    te.Work_Carried_Out_3__c = t.Work_Carried_Out_3__c;
                    teList.add(te);
                }
         try{
                if(teList.size()>0)
                    insert teList;
                }//show an error message back on page, in any
        catch (System.DmlException e) {
            for(Integer i =0; i<e.getNumDml(); ++i) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));  
            }
            strSelectedClients='';
            strKey='';
            submitForm=false;
            lstSelectedoptions = new List<SelectOption>();
            return null;
        }
                
                
                return new PageReference('/a0D/o');
                //return null;  
            }
        }
        return null;
    }
    public Pagereference Cancel()
    {
        return new PageReference('/a0D/o');
    }
    public Timeline()
    {
        this.t = new Timeline_Event__c();
        strKey = '';
        submitForm=false;
    }
    public Timeline(ApexPages.StandardController stdController)
    {
 
        controller = stdController; 
        this.t = new Timeline_Event__c();
        strKey = '';
        submitForm=false;

        
        lngLat = ApexPages.currentPage().getParameters().get('00NC0000005FiSZ');
        accountId  = ApexPages.currentPage().getParameters().get('accountId');
        streetUrl = ApexPages.currentPage().getParameters().get('00NC0000005FhOl');
        ward = ApexPages.currentPage().getParameters().get('00NC0000005ESSO');
        borough = ApexPages.currentPage().getParameters().get('00N80000004HdTf');
system.debug('@@@@   borough is ... ' + borough);        
        street = ApexPages.currentPage().getParameters().get('00NM0000001HhV0');
        postcode = ApexPages.currentPage().getParameters().get('00NM0000001HhQo');
        if (string.isBlank(postcode))
            postcode = ApexPages.currentPage().getParameters().get('00NC0000006UxdN');
        
        LSOAName = ApexPages.currentPage().getParameters().get('00NM0000001atqh');
        if (string.isBlank(LSOAName))
            LSOAName = ApexPages.currentPage().getParameters().get('00N2400000IA73c');
            
        LSOACode = ApexPages.currentPage().getParameters().get('00NM0000001atqr');
        if (string.isBlank(LSOACode))
            LSOACode = ApexPages.currentPage().getParameters().get('00N2400000IA73h');
            
        MSOAName = ApexPages.currentPage().getParameters().get('00NM0000001atqc');
        if (string.isBlank(MSOAName))
            MSOAName = ApexPages.currentPage().getParameters().get('00N2400000IA73r');
        
        MSOACode = ApexPages.currentPage().getParameters().get('00NM0000001atqX');
        if (string.isBlank(MSOACode))
            MSOACode = ApexPages.currentPage().getParameters().get('00N2400000IA73m');
            
        wardCode = ApexPages.currentPage().getParameters().get('00NM0000001atqS');     
        if (string.isBlank(wardCode))
            wardCode = ApexPages.currentPage().getParameters().get('00N2400000IA741');
            
        actionPlan = ApexPages.currentPage().getParameters().get('00NC0000005l5c4');
        veryPrivateActionPlan = ApexPages.currentPage().getParameters().get('00NC0000005mo79');

       
    }
    public PageReference redirectTimelineEvent()
    {
        
        User u = [Select Id, Email, Default_Project_Id__C, Default_Project_Name__C from User where Id=:UserInfo.getUserId()];
        //System.Debug('##############');
        //System.Debug(u);
        String campName = u.Default_Project_Name__c;
        if(u.Default_Project_Name__c!=null)
             campName = EncodingUtil.urlEncode(u.Default_Project_Name__c,'UTF-8');
        String outreachBBSValue;
        String typeOfAccommodation;
        String accommodation2;
        boolean westminsterActionPlan = false;
        
        if(u.Default_Project_Id__C!=null)
        {
            List<Campaign> campList = [Select Id, Type, Name, Westminster_action_plan__c from Campaign where Id=:u.Default_Project_Id__c];
            
            //    if(campList.size()>0 && campList[0].Type=='Outreach/BBS')
            if(campList.size()>0)
            {
                westminsterActionPlan = campList[0].Westminster_action_plan__c;
                //System.Debug('HAVE A CAMPAIGN LIST');
                if(campList[0].Type=='Outreach/BBS')
                {
                    //System.Debug('Outreach/BBS');
                    //outreachBBS = '&00N80000004Hlp6=' + campList[0].Name;
                    outreachBBSValue = campList[0].Name;
                }
                else
                {
                    //System.Debug('NOT Outreach/BBS');
                    // Prepop Type of accommodation and accommodation2 fields based on the associated campaign
                    List<Schema.PickListEntry> typePicklist = Timeline_Event__c.Type_of_Accommodation__c.getDescribe().getPicklistValues();
                    //System.Debug('CAMPAIGN TYPE:' + campList[0].Type);
                    for( Schema.PickListEntry picklistEntry : typePicklist )
                    {
                        //System.Debug('PICKLISTENTRY:' + picklistEntry.getLabel());
                        if( campList[0].Type == picklistEntry.getLabel() )
                        {
                            //System.Debug('SETTING TYPE OF ACCOMMODATION');
                            typeOfAccommodation = picklistEntry.getLabel();
                            
                            // Now see if we can set the accommodation 2 picklist too
                            List<Schema.PickListEntry> accom2Picklist = Timeline_Event__c.Accommodation2__c.getDescribe().getPicklistValues();
                            //System.Debug('CAMPAIGN NAME:' + campList[0].Name);
                            for( Schema.PickListEntry accom2PicklistEntry : accom2Picklist )
                            {
                                //System.Debug('PICKLISTENTRY:' + accom2PicklistEntry.getLabel());
                                if( campList[0].Name == accom2PicklistEntry.getLabel() )
                                {
                                    //System.Debug('SETTING ACCOMMODATION 2');
                                    accommodation2 = accom2PicklistEntry.getLabel();
                                }
                            }
                            if(accommodation2==null)
                            {
                                accommodation2 = 'Other - Specify in other accommodation';
                            }
                        }
                    }
                }
            }
        }
                
        //return
        PageReference objPage = new PageReference('/a0D/e?CF00N80000004Gn8N=&' + campName + '&CF00N80000004Gn8N_lkid=' + u.Default_Project_Id__c + '&_CONFIRMATIONTOKEN=' + ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN') + '&RecordType=' + ApexPages.currentPage().getParameters().get('RecordType') + '&retURL=' + ApexPages.currentPage().getParameters().get('retURL'));
        objpage.getParameters().put('nooverride', '1');
        objpage.getParameters().put('CF00N80000004Gn8N', campName);
        objpage.getParameters().put('CF00N80000004Gn8N_lkid', u.Default_Project_Id__c);
        objpage.getParameters().put('CF00N80000004GsgP', ApexPages.currentPage().getParameters().get('CF00N80000004GsgP'));
        objpage.getParameters().put('CF00N80000004GsgP_lkid', ApexPages.currentPage().getParameters().get('CF00N80000004GsgP_lkid'));
        if(outreachBBSValue!=null)
            objpage.getParameters().put('00N80000004Hlp6', outreachBBSValue);
        if(typeOfAccommodation!=null)
            objpage.getParameters().put('00N80000004Gyiq', typeOfAccommodation);
        if(accommodation2!=null)
            objpage.getParameters().put('00N80000004HlOF', accommodation2);

          
        // If user project/team has Westminster_action_plan__c set to true,
        // pre-default CSTM_Private_Action_Plan__c to value of most recent record where  
        // value is not null

        try{          
            if(westminsterActionPlan){  
                string clientId = '';  

                  
                if (controller != null){  
                    Timeline_Event__c tle = (Timeline_Event__c) controller.getRecord();  
                    clientId = tle.client__c;
                    system.debug(' @@@ ' + clientId);  
                    list<Timeline_Event__c> tleList = new list<Timeline_Event__c>();  
                    tleList = [select CSTM_Private_Action_plan__c, CSTM_very_Private_Action_plan__c
                                    from Timeline_Event__c where client__c = :clientId   
                                    order by date__c desc];  
                      
                    if (!tleList.isEmpty()){  
                        for(Timeline_Event__c tleRec :tleList){  
                            if (string.isnotBlank(tleRec.CSTM_Private_Action_plan__c)){  
                                actionPlan = tleRec.CSTM_Private_Action_plan__c;  
                                break;  
                            }     
                        }  

                        for(Timeline_Event__c tleRec :tleList){  
                            if (string.isnotBlank(tleRec.CSTM_very_Private_Action_plan__c)){  
                                veryPrivateActionPlan = tleRec.CSTM_very_Private_Action_plan__c;  
                                break;  
                            }     
                        }                          
                    } 
                    
                    system.debug(' @@@  1a ' + actionPlan);
                    system.debug(' @@@  1b ' + veryPrivateActionPlan);
                    //objPage.getParameters().put('00NC0000005mo79', actionPlan ); // Labelled CSTM Private Action Plan
                    if (string.isnotBlank(actionPlan)){
                        actionPlan = EncodingUtil.urlEncode(actionPlan, 'UTF-8');
                        system.debug(' @@@  2a ' + actionPlan);
                        objPage.getParameters().put('00NC0000005l5c4', actionPlan ); // Labelled Westminster Private Action Plan                      
                    }

                    if (string.isnotBlank(veryPrivateActionPlan)){
                        veryPrivateActionPlan = EncodingUtil.urlEncode(veryPrivateActionPlan, 'UTF-8');
                        system.debug(' @@@  2b ' + veryPrivateActionPlan);
                        objPage.getParameters().put('00NC0000005mo79', veryPrivateActionPlan ); // Labelled CSTM Private Action Plan                      
                    }

                }  
            }  
        } catch (exception e){
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());
        }

        /** Redirect to map page if Street contact record type is selected and profile allows**/

            // record type .. 012C0000000QA2o = Street Contact - not bedded down
            // record type .. 012C0000000QA2j = Street Contact - bedded down
            // record type .. 012C0000000QA5E = Street Count
            map<Id, string> streetRecordTypes = new map<Id, string>();
            streetRecordTypes.put('012C0000000QA2o', 'Street Contact - not bedded down' );
            streetRecordTypes.put('012C0000000QA2j', 'Street Contact - bedded down' );
            streetRecordTypes.put('012C0000000QA5E', 'Street Count' );
            string rt = ApexPages.currentPage().getParameters().get('RecordType');
            if (rt == '012C0000000QA2o' || rt == '012C0000000QA2j' || rt == '012C0000000QA5E'){
                // get profiles allowing mapping
                boolean navtoMap = false;
                list<string> profilesList = Label.Map_Profiles.split(',');
                if (!profilesList.isEmpty()){
                    if (profilesList[0] == 'ALL'){
                        navtoMap = true;
                    } else {
                    User usr = [select profileId, Profile.Name from User where Id =:UserInfo.getUserId() ];
                        for (string profile :profilesList) {            
                            if (usr.Profile.Name == profile){
                                navtoMap = true;
                                break;  
                            }
                        }
                    }
                }  else {
                    navtoMap = true;
                }

                if(string.isBlank(accountId) && navtoMap){
                    Timeline_Event__c timelineEvt = (Timeline_Event__c) controller.getRecord();  
                    accountId = [select Id from Account where PersonContactId = :timelineEvt.Client__c].Id;
                    PageReference mapPage = new PageReference('/apex/StreetContactTimelineEventOverride');
                    mapPage.getParameters().put('EncounterType', 'Street Contact');
                    mapPage.getParameters().put('Event', streetRecordTypes.get(rt));
                    mapPage.getParameters().put('Name', 'Updated+on+save');
                    mapPage.getParameters().put('RecordType', rt);
                    mapPage.getParameters().put('accountId', accountId);
                    mapPage.getParameters().put('actionPlan', actionPlan);
                    mapPage.getParameters().put('veryPrivateActionPlan', veryPrivateActionPlan);
                    mapPage.setRedirect(true);
                    return mapPage;
                }   

            }
        /** End of map redirection logic **/

        
        objpage.getParameters().put('_CONFIRMATIONTOKEN', ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN'));
        objpage.getParameters().put('RecordType', ApexPages.currentPage().getParameters().get('RecordType'));
        objpage.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        objpage.getParameters().put('Name','Updated on save '); //28/10/2010  
        
system.debug( ' @@@@ Parameters map 1 ... ' +  objpage.getParameters());       
        /* This section used when called from custom buttons on Account object for Street Contact Timeline events */
        
        if (string.isnotBlank(lngLat)){
            objpage.getParameters().put('00NC0000005FiSZ',lngLat);
        }
        if(string.isnotBlank(accountId)){
            Account person = [SELECT Id, Name, PersonContactId FROM Account WHERE Id = :accountId];
            objpage.getParameters().put('CF00N80000004GsgP', person.Name);
            objPage.getParameters().put('CF00N80000004GsgP_lkid', person.PersonContactId);
            objPage.getParameters().put('retURL', accountId );  
        }
        
        if (string.isnotBlank(streetUrl)){
            objPage.getParameters().put('00NC0000005FhOl', streetUrl);
        }
        
        if (string.isnotBlank(ward)){
            objPage.getParameters().put('00NC0000005ESSO', ward);
        }
        
        if (string.isnotBlank(borough)){
            objPage.getParameters().put('00N80000004HdTf', borough); // Street Site/Borough
            objPage.getParameters().put('00NM0000001aXNT', borough); // sandbox - Borough from map
            objPage.getParameters().put('00N2400000HsRUu', borough); // live - Borough from amp
        }

        if (string.isnotBlank(street)){
            objPage.getParameters().put('00NM0000001HhV0', street);
        }
     
        if (string.isnotBlank(postcode)){
            objPage.getParameters().put('00NM0000001HhQo', postcode); //sandbox
            objPage.getParameters().put('00NC0000006UxdN', postcode); // live
        }        

        if (string.isnotBlank(LSOAName)){
            objPage.getParameters().put('00NM0000001atqh', LSOAName); //sandbox
            objPage.getParameters().put('00N2400000IA73c', LSOAName); //live
        }
        
        if (string.isnotBlank(LSOACode)){
            objPage.getParameters().put('00NM0000001atqr', LSOACode); //sandbox
            objPage.getParameters().put('00N2400000IA73h', LSOACode); //live
        }
        
        if (string.isnotBlank(MSOAName)){
            objPage.getParameters().put('00NM0000001atqc', MSOAName); //sandbox
            objPage.getParameters().put('00N2400000IA73r', MSOAName); //live
        }
        
        if (string.isnotBlank(MSOACode)){
            objPage.getParameters().put('00NM0000001atqX', MSOACode); //sandbox
            objPage.getParameters().put('00N2400000IA73m', MSOACode); //live
        }
        
        if (string.isnotBlank(wardCode)){
            objPage.getParameters().put('00NM0000001atqS', wardCode); //sandbox
            objPage.getParameters().put('00N2400000IA741', wardCode); //live
        }
                                
        if (string.isnotBlank(actionPlan)){
            objPage.getParameters().put('00NC0000005l5c4', actionPlan ); // Labelled Westminster Private Action Plan
        }
        
        if (string.isnotBlank(veryPrivateActionPlan)){
            objPage.getParameters().put('00NC0000005mo79', veryPrivateActionPlan ); // Labelled CSTM Private Action Plan
        }
        
        /************************************************************************************************/
system.debug( ' @@@@ Parameters map 2 ... ' +  objpage.getParameters());
system.debug( ' @@@@ url ... ' +  objpage.getUrl());         
        objPage.setRedirect(true);
        return objPage;
        //return new PageReference('/a0D/e?CF00N80000004Gn8N=nooverride=1&' + u.Default_Project_Name__C + '&CF00N80000004Gn8N_lkid=' + u.Default_Project_Id__c + '&_CONFIRMATIONTOKEN=' + ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN') + '&RecordType=' + ApexPages.currentPage().getParameters().get('RecordType') + '&retURL=' + ApexPages.currentPage().getParameters().get('retURL'));
        //return new PageReference('http://www.google.com'); 
    }
    public Timeline_Event__c getTimeline()
    {
        return this.t;
    }
    //-------------------------------------USED BY TRIGGER-----------------------------------------------//
    //All the functionality in this funciton is closely binded and hence cannot be broken into different small functions.
    //It gets executed when any Timeline event record gets created/updated/deleted
    //This helps populate some values, based on the logic, into related client rcord 
   public void updateClientInfo(List<Timeline_Event__c> tleList,Map<Id,Timeline_Event__c> oldMap, Boolean isDelete)
    {
        
        System.debug(' @@@ 1 tleList: ' + tleList);
        System.debug(' @@@ 1 oldMap: ' + oldMap);
        System.debug(' @@@ 1 isDelete: ' + isDelete);
        
        //Collect all the distinct Contact Ids
        Set<Id> ContactIds = new Set<Id>();
        for(Timeline_Event__c t: tleList)
        {
            TimeLine_Event__c oldT;
            if(oldMap!=null) oldT = oldMap.get(t.Id);
            
            System.debug(' @@@ 2 oldT: ' + oldT);
            
            System.debug(' @@@ 2 t in tleList  LOOP   ..  : ' + t);
            
            if(t.Client__c!=null && (oldMap==null || isDelete || (t.Date__c!=oldT.Date__c || t.Rough_Sleeping__c!=oldT.Rough_Sleeping__c || t.Borough__c!=oldT.Borough__c || t.Accomodation_Name__c!=oldT.Accomodation_Name__c || t.Borough_Street_Site__c!=oldT.Borough_Street_Site__c || t.Street_site_borough__c!=oldT.Street_site_borough__c || t.Other_Accommodation__c!=oldT.Other_Accommodation__c || t.Arrival_Date__c!=oldT.Arrival_Date__c || t.Leaving_Date__c!=oldT.Leaving_Date__c || t.Project_Team__c!=oldT.Project_Team__c || t.Destination_on_Departure__c!=oldT.Destination_on_Departure__c || t.Event__c!=oldT.Event__c)))
                ContactIds.add(t.Client__c);
        }
        System.debug('CONTACT IDS: ' + ContactIds);
        System.debug('BEFORE===================LIMIT: ' + Limits.getQueries() + ' | ' + Limits.getLimitQueries());
        //All these different queries are made to avoid the business logic in controller and only get the relevant records from salesforce
        //These query retunrn records that are used to populate number of fields on client record.
        //Calculate the Date First Seen Rough Sleeping
    if(ContactIds.size()>0){    
        //Map<Id,Contact> firstRoughSleepingQueryMap = new Map<Id, Contact>([Select Id,AccountId, Date_First_Seen_Rough_Sleeping__c, (Select Id,Date__c from Timeline_Events__r where Rough_Sleeping__c >0 AND Date__c!=null Order by Date__c Asc limit 1) from Contact where Id IN: ContactIds]);
        //Calculate the Date Last Seen Rough Sleeping
        //Map<Id,Contact> lastRoughSleepingQueryMap = new Map<Id,Contact>([Select Id,AccountId, Date_Last_Seen_Rough_Sleeping__c, (Select Id,Date__c from Timeline_Events__r  where Rough_Sleeping__c >0 AND Date__c!=null Order by Date__c Desc limit 1) from Contact where Id IN: ContactIds]);
        Map<Id,Contact> roughSleepingQueryMap = new Map<Id,Contact>([Select Id,AccountId, Date_First_Seen_Rough_Sleeping__c, Date_Last_Seen_Rough_Sleeping__c, (Select Id,Date__c, Street_Site_Borough__c from Timeline_Events__r  where Rough_Sleeping__c >0 AND Date__c!=null Order by Date__c Desc) from Contact where Id IN: ContactIds]);
        //Calculate the First Contacted Date
        Map<Id,Contact> firstContactedQueryMap = new Map<Id,Contact>([Select Id,AccountId, Date_first_Contacted__c, (Select Id,Date__c from Timeline_Events__r where Date__c!=null Order by Date__c Asc limit 1) from Contact where Id IN: ContactIds]);
        //Calculate the Last Contacted date
        Map<Id,Contact> lastContactedQueryMap = new Map<Id,Contact>([Select Id,AccountId, Date_Last_Contacted__c,MailingStreet,MailingState,MailingCity,MailingCountry,MailingPostalCode, (Select Id,Date__c,Rough_Sleeping__c from Timeline_Events__r where Date__c!=null Order by Date__c Desc limit 1) from Contact where Id IN: ContactIds]);
        //Calculate the Borough Last Seen Rough sleeping
        Map<Id,Contact> lastBoroughQueryMap = new Map<Id,Contact>([Select Id,AccountId, Borough__c, (Select Id,Date__c,Street_site_borough__c,Borough__c from Timeline_Events__r where Street_site_borough__c!=null AND date__c!=null Order by Date__c Desc limit 1) from Contact where Id IN: ContactIds]);
        //Calculate the last known location
        Map<Id,Contact> locationQueryMap = new Map<Id,Contact>([Select Id,AccountId,Last_Known_Location__c, (Select Id,Date__c,Accomodation_Name__c, Borough_Street_Site__c, Other_Accommodation__c from Timeline_Events__r where Date__c!=null Order by Date__c Desc limit 1) from Contact where Id IN: ContactIds]);
        //Most recent Contact date, most recent ocntact user
        Map<Id,Contact> createdQueryMap = new Map<Id,Contact>([Select Id,AccountId, (Select Id,CreatedDate, CreatedById from Timeline_Events__r where Date__c!=null Order by CreatedDate Desc limit 1) from Contact where Id IN: ContactIds]);
        //If client in accommodation (eg Hostel) - arrival date is not null, end date is null, then update client's address (Organisations/Clients object) with accommodation address (from Project/team object).
        Map<Id,Contact> accomodationQueryMap = new Map<Id,Contact>([Select Id,AccountId, (Select Id,Arrival_Date__c,Leaving_Date__c,Project_Team__r.Street__c,Project_Team__r.City__c,Project_Team__r.Country__c,Project_Team__r.County__c,Project_Team__r.PostCode__c from Timeline_Events__r where Arrival_Date__c!=null AND Leaving_Date__c=null Order by Arrival_Date__c Desc limit 1) from Contact where Id IN: ContactIds]);
        //Add Last Known Location
        Map<Id,Contact> lklQueryMap = new Map<Id,Contact>([Select Id,AccountId,Last_Known_Location__c, (Select Id,Arrival_Date__c,Leaving_Date__c,Destination_on_Departure__c,Event__c,Date__c from Timeline_Events__r where Arrival_Date__c!=null OR Leaving_Date__c!=null OR Event__c='Street Contact - Bedded Down'  OR Event__c='Street Count' Order by Date__c Desc limit 1) from Contact where Id IN: ContactIds]);
        
        System.debug('AFTER===================LIMIT: ' + Limits.getQueries() + ' | ' + Limits.getLimitQueries());
      
        //Just for Borough, to match dates
        Map<Id,DateTime> lastBoroughMap = new Map<Id,DateTime>();
        Map<Id,DateTime> locationMap = new Map<Id,DateTime>(); 
        System.debug('BORIUGH MAP: ' + lastBoroughQueryMap);
        for(Id id: lastBoroughQueryMap.keySet())
        {
            if(lastBoroughQueryMap.get(id).Timeline_Events__r!=null && lastBoroughQueryMap.get(id).Timeline_Events__r.size()>0 && lastBoroughQueryMap.get(id).Timeline_Events__r[0].Street_site_borough__c!=null)
                {
                    
                    System.debug('BORIUGH VALUE TO UDPATE: ' + lastBoroughQueryMap.get(id).Timeline_Events__r[0].Street_site_borough__c);
                    lastBoroughQueryMap.get(id).Borough_Last_Seen_Rough_Sleeping__c = lastBoroughQueryMap.get(id).Timeline_Events__r[0].Street_site_borough__c;
                    lastBoroughMap.put(id,lastBoroughQueryMap.get(id).Timeline_Events__r[0].Date__c);
                }
            else
                lastBoroughQueryMap.get(id).Borough_Last_Seen_Rough_Sleeping__c=null;
           
           System.debug('BORIUGH MAP AFTER: ' + lastBoroughQueryMap);          
            
        }
        for(Id id: locationQueryMap.keySet())
        {
            if(locationQueryMap.get(id).Timeline_Events__r!=null && locationQueryMap.get(id).Timeline_Events__r.size()>0)
                {
                    if(locationQueryMap.get(id).Timeline_Events__r[0].Accomodation_Name__c!=null)
                    {   
                        locationQueryMap.get(id).Last_Known_Location__c = locationQueryMap.get(id).Timeline_Events__r[0].Accomodation_Name__c;
                        locationMap.put(id,locationQueryMap.get(id).Timeline_Events__r[0].Date__c);
                    }   
                    else if(locationQueryMap.get(id).Timeline_Events__r[0].Borough_Street_Site__c!=null)
                    {   
                        locationQueryMap.get(id).Last_Known_Location__c = locationQueryMap.get(id).Timeline_Events__r[0].Borough_Street_Site__c;
                        locationMap.put(id,locationQueryMap.get(id).Timeline_Events__r[0].Date__c);
                    }
                    else if(locationQueryMap.get(id).Timeline_Events__r[0].Other_Accommodation__c!=null)
                    {   
                        locationQueryMap.get(id).Last_Known_Location__c = locationQueryMap.get(id).Timeline_Events__r[0].Other_Accommodation__c;
                        locationMap.put(id,locationQueryMap.get(id).Timeline_Events__r[0].Date__c);
                    }
                    
                }
                else
                    locationQueryMap.get(id).Last_Known_Location__c = null; 
            
        }
System.debug(' @@@ RS 1 roughSleepingQueryMap: ' + roughSleepingQueryMap);         
        //Start populating, directly from queried records, Populate the values for each map       
        for(Id id: roughSleepingQueryMap.keySet())
        {
System.debug(' @@@ RS 2 roughSleepingQueryMap.get(id).Timeline_Events__r: ' + roughSleepingQueryMap.get(id).Timeline_Events__r); 
            if(roughSleepingQueryMap.get(id).Timeline_Events__r!=null && roughSleepingQueryMap.get(id).Timeline_Events__r.size()>0)
            {
                //roughSleepingQueryMap.get(id).Date_First_Seen_Rough_Sleeping__c = roughSleepingQueryMap.get(id).Timeline_Events__r[roughSleepingQueryMap.get(id).Timeline_Events__r.size()-1].Date__c.date();
                //roughSleepingQueryMap.get(id).Date_Last_Seen_Rough_Sleeping__c = roughSleepingQueryMap.get(id).Timeline_Events__r[0].Date__c.date();
                roughSleepingQueryMap.get(id).Borough__c = roughSleepingQueryMap.get(id).Timeline_Events__r[0].Street_site_borough__c;
            }   
            else
            {
                //roughSleepingQueryMap.get(id).Date_Last_Seen_Rough_Sleeping__c = null;
                //roughSleepingQueryMap.get(id).Date_First_Seen_Rough_Sleeping__c=null;
                roughSleepingQueryMap.get(id).Borough__c =null; 
            }
        }
        for(Id id: firstContactedQueryMap.keySet())
        {
            if(firstContactedQueryMap.get(id).Timeline_Events__r!=null && firstContactedQueryMap.get(id).Timeline_Events__r.size()>0)
                firstContactedQueryMap.get(id).Date_First_Contacted__c = firstContactedQueryMap.get(id).Timeline_Events__r[0].Date__c.date();
            else
                firstContactedQueryMap.get(id).Date_First_Contacted__c = null;  
        }
        for(Id id: lastContactedQueryMap.keySet())
        {
            if(lastContactedQueryMap.get(id).Timeline_Events__r!=null && lastContactedQueryMap.get(id).Timeline_Events__r.size()>0)
                lastContactedQueryMap.get(id).Date_Last_Contacted__c = lastContactedQueryMap.get(id).Timeline_Events__r[0].Date__c.date();
            else
               lastContactedQueryMap.get(id).Date_Last_Contacted__c=null; 
            //If the client is found ough sleeping, delete the client address
            //checking if the last found record is rough sleeping, if yes, update the Contact mailing adress to null.
            if(lastContactedQueryMap.get(id).Timeline_Events__r!=null && lastContactedQueryMap.get(id).Timeline_Events__r.size()>0 && lastContactedQueryMap.get(id).Timeline_Events__r[0].Rough_Sleeping__c >0)
            {
                lastContactedQueryMap.get(id).MailingStreet=null;
                lastContactedQueryMap.get(id).MailingCity=null;
                lastContactedQueryMap.get(id).MailingState=null;
                lastContactedQueryMap.get(id).MailingCountry=null;
                lastContactedQueryMap.get(id).MailingPostalCode=null;
            }    
        }
        for(Id id: createdQueryMap.keySet())
        {
            if(createdQueryMap.get(id).Timeline_Events__r!=null && createdQueryMap.get(id).Timeline_Events__r.size()>0){
                createdQueryMap.get(id).Most_Recent_Contact_Date__c = createdQueryMap.get(id).Timeline_Events__r[0].CreatedDate;
                createdQueryMap.get(id).Most_Recent_Contact_User__c = createdQueryMap.get(id).Timeline_Events__r[0].CreatedById;
            }
            else
             {
                createdQueryMap.get(id).Most_Recent_Contact_Date__c=null;
                createdQueryMap.get(id).Most_Recent_Contact_User__c=null;
             }      
        }
        //Update Acomodation depending on Arrival date and End Date
        for(Id id: accomodationQueryMap.keySet())
        {
            if(accomodationQueryMap.get(id).Timeline_Events__r!=null && accomodationQueryMap.get(id).Timeline_Events__r.size()>0){
                accomodationQueryMap.get(id).MailingStreet = accomodationQueryMap.get(id).Timeline_Events__r[0].Project_Team__r.Street__c;
                accomodationQueryMap.get(id).MailingCity = accomodationQueryMap.get(id).Timeline_Events__r[0].Project_Team__r.City__c;
                accomodationQueryMap.get(id).MailingCountry = accomodationQueryMap.get(id).Timeline_Events__r[0].Project_Team__r.Country__c;
                accomodationQueryMap.get(id).MailingPostalCode = accomodationQueryMap.get(id).Timeline_Events__r[0].Project_Team__r.PostCode__c;
                accomodationQueryMap.get(id).Mailing_County__c = accomodationQueryMap.get(id).Timeline_Events__r[0].Project_Team__r.County__c;
            }
            else
             {
                accomodationQueryMap.get(id).MailingStreet = null;
                accomodationQueryMap.get(id).MailingCity = null;
                accomodationQueryMap.get(id).MailingCountry = null;
                accomodationQueryMap.get(id).MailingPostalCode = null;
                accomodationQueryMap.get(id).Mailing_County__c = null;
             }
        }
        //set Last known location on client record
        for(Id id: lklQueryMap.keySet())
        {
            if(lklQueryMap.get(id).Timeline_Events__r!=null && lklQueryMap.get(id).Timeline_Events__r.size()>0){
                
                if(lklQueryMap.get(id).Timeline_Events__r[0].Arrival_Date__c!=null && lklQueryMap.get(id).Timeline_Events__r[0].Leaving_Date__c==null)
                {
                    lklQueryMap.get(id).Last_Known_Location__c = 'In Temp Accommodation';
                }
                else if(lklQueryMap.get(id).Timeline_Events__r[0].Event__c=='Street Contact - Bedded Down' || lklQueryMap.get(id).Timeline_Events__r[0].Event__c=='Street Count')
                {
                    lklQueryMap.get(id).Last_Known_Location__c = 'Rough Sleeping';
                }
                else if(lklQueryMap.get(id).Timeline_Events__r[0].Leaving_Date__c!=null)
                {
                    lklQueryMap.get(id).Last_Known_Location__c = lklQueryMap.get(id).Timeline_Events__r[0].Destination_on_Departure__c;
                }
            }
        }//
        //Handle the updates on client record if a record is deleted      
        if(!isDelete)
        {   
            //Populate the fields on Contact from batch
            for(Timeline_Event__c t :tleList)
            {
System.debug(' @@@ RS 3 t.Client__c: ' + t.Client__c);
System.debug(' @@@ RS 4 roughSleepingQueryMap.get(t.Client__c).Date_First_Seen_Rough_Sleeping__c: ' + roughSleepingQueryMap.get(t.Client__c).Date_First_Seen_Rough_Sleeping__c);

                if(t.Client__c!=null) // Wrapping whole block in this as all sub if's have the != null clause. DG - 20110408
                {
                    System.debug('ON DELETE: ' + t.Date__c + ' | ' + roughSleepingQueryMap.get(t.Client__c));
                    if(t.Client__c!=null && t.Rough_Sleeping__c>0 && t.Date__c < roughSleepingQueryMap.get(t.Client__c).Date_First_Seen_Rough_Sleeping__c){
                        roughSleepingQueryMap.get(t.Client__c).Date_First_Seen_Rough_Sleeping__c = t.Date__c.date();
System.debug(' @@@ RS 5 roughSleepingQueryMap.get(t.Client__c).Date_First_Seen_Rough_Sleeping__c: ' + roughSleepingQueryMap.get(t.Client__c).Date_First_Seen_Rough_Sleeping__c);                     
                    }   
                    System.debug('ON DELETE: ' + t.Date__c + ' | ' + roughSleepingQueryMap.get(t.Client__c));
                    if(t.Client__c!=null && t.Rough_Sleeping__c>0 && t.Date__c > roughSleepingQueryMap.get(t.Client__c).Date_Last_Seen_Rough_Sleeping__c){
                        roughSleepingQueryMap.get(t.Client__c).Date_Last_Seen_Rough_Sleeping__c = t.Date__c.date();
                    
                    }        
                    System.debug('MAP VALUE: ' + firstContactedQueryMap.get(t.Client__c));
                    if(t.Client__c!=null && firstContactedQueryMap.containsKey(t.Client__c) && t.Date__c < firstContactedQueryMap.get(t.Client__c).Date_First_Contacted__c)
                        firstContactedQueryMap.get(t.Client__c).Date_First_Contacted__c = t.Date__c.date();
                    
                    if(t.Client__c!=null && lastContactedQueryMap.containsKey(t.Client__c) && t.Date__c > lastContactedQueryMap.get(t.Client__c).Date_Last_Contacted__c)
                        lastContactedQueryMap.get(t.Client__c).Date_Last_Contacted__c = t.Date__c.date();
                    if(t.Client__c!=null && createdQueryMap.containsKey(t.Client__c) &&  t.CreatedDate > createdQueryMap.get(t.Client__c).Most_Recent_Contact_Date__c)
                    {
                        createdQueryMap.get(t.Client__c).Most_Recent_Contact_Date__c = t.CreatedDate;
                        createdQueryMap.get(t.Client__c).Most_Recent_Contact_User__c = t.CreatedById;
                    }       
                    if(t.Client__c!=null && lastBoroughMap.containsKey(t.Client__c) && t.Date__c > lastBoroughMap.get(t.Client__c) && t.Street_site_borough__c!=null)
                    {
                        lastBoroughQueryMap.get(t.Client__c).Borough_Last_Seen_Rough_Sleeping__c = t.Street_site_borough__c;
                        lastBoroughMap.put(t.Client__c,t.Date__c);
                    }
                        
                    if(t.Client__c!=null && locationQueryMap.containsKey(t.Client__c) && t.Date__c > locationMap.get(t.Client__c))
                    {
                        if(t.Accomodation_Name__c!=null)
                        {   
                            locationQueryMap.get(t.Client__c).Last_Known_Location__c = t.Accomodation_Name__c;
                            locationMap.put(t.Client__c,t.Date__c);
                        }   
                        else if(t.Borough_Street_Site__c!=null)
                        {   
                            locationQueryMap.get(t.Client__c).Last_Known_Location__c = t.Borough_Street_Site__c;
                            locationMap.put(t.Client__c,t.Date__c);
                        }
                        else if(t.Other_Accommodation__c!=null)
                        {   
                            locationQueryMap.get(t.Client__c).Last_Known_Location__c = t.Other_Accommodation__c;
                            locationMap.put(t.Client__c,t.Date__c);
                        }
                    }
                }                                                                                                                                   
            }
        }   
        //For all the maps set with updated values, start updating back to salesforc.
        //Do that in person accounts record
        System.debug('UPDATE MAP firstContactedQueryMap : ' + firstContactedQueryMap);
System.debug(' @@@ RS 6 roughSleepingQueryMap: ' + roughSleepingQueryMap);
        if(roughSleepingQueryMap.size()>0)
        {           
            List<Account> aList = new List<Account>();
            for(Contact c: roughSleepingQueryMap.values())
            {
                aList.add(new Account(Id=c.AccountId, Date_First_Seen_Rough_Sleeping__pc=c.Date_First_Seen_Rough_Sleeping__c,Date_Last_Seen_Rough_Sleeping__pc=c.Date_Last_Seen_Rough_Sleeping__c));
System.debug(' @@@ RS 7 LOOP aList: ' + aList);
            }
System.debug(' @@@ RS 8 FINAL aList: ' + aList);
            update aList;
System.debug(' @@@ RS 9 AFTER UPDATE 1 aList: ' + aList);            
        }   
        if(firstContactedQueryMap.size()>0)
            {
                List<Account> aList = new List<Account>();
                for(Contact c: firstContactedQueryMap.values())
                {
                    aList.add(new Account(Id=c.AccountId, Date_first_Contacted__pc=c.Date_first_Contacted__c));
                }
                update aList;
            }
        if(lastContactedQueryMap.size()>0)
            {
                    List<Account> aList = new List<Account>();
                    for(Contact c: lastContactedQueryMap.values())
                    {
                        aList.add(new Account(Id=c.AccountId, Date_Last_Contacted__pc=c.Date_Last_Contacted__c,PersonMailingStreet=c.MailingStreet, PersonMailingState=c.MailingState, PersonMailingCity=c.MailingCity, PersonMailingPostalCode=c.MailingPostalcode, PersonMailingCountry=c.MailingCountry));
                    }
                    update aList;
            }
        System.debug('UPDATE BOROUGH IN ACCOUNT ');
        if(lastBoroughQueryMap.size()>0)
            {
                List<Account> aList = new List<Account>();
                    for(Contact c: lastBoroughQueryMap.values())
                    {
                        System.debug('UPDATE VALUE TO:   ' + c.Borough_Last_Seen_Rough_Sleeping__c);
                        aList.add(new Account(Id=c.AccountId, Borough_Last_Seen_Rough_Sleeping__pc=c.Borough_Last_Seen_Rough_Sleeping__c));
                    }
                    update aList;
            }
        
        if(locationQueryMap.size()>0)
            {
                List<Account> aList = new List<Account>();
                    for(Contact c: locationQueryMap.values())
                    {
                        aList.add(new Account(Id=c.AccountId, Last_Known_Location__pc=c.Last_Known_Location__c));
                    }
                    update aList;
            }
          
        if(createdQueryMap.size()>0)
            {
                List<Account> aList = new List<Account>();
                    for(Contact c: createdQueryMap.values())
                    {
                        aList.add(new Account(Id=c.AccountId, Most_Recent_Contact_Date__pc=c.Most_Recent_Contact_Date__c, Most_Recent_Contact_User__pc=c.Most_Recent_Contact_User__c));
                    }
                    update aList;
            }
      if(accomodationQueryMap.size()>0)
            {
                    List<Account> aList = new List<Account>();
                    for(Contact c: accomodationQueryMap.values())
                    {
                        aList.add(new Account(Id=c.AccountId, PersonMailingCity=c.MailingCity,PersonMailingStreet=c.MailingStreet,PersonMailingCountry=c.MailingCountry,PersonMailingPostalCode=c.MailingPostalCode,Mailing_County__pc=c.Mailing_County__c));
                    }
                    
                    update aList;
            }
        if(lklQueryMap.size()>0)
            {
                    List<Account> aList = new List<Account>();
                    for(Contact c: lklQueryMap.values())
                    {
                        aList.add(new Account(Id=c.AccountId, Last_Known_Location__pc = c.Last_Known_Location__c));
                    }
                    update aList;
            }  
                                                
    }//If contactId has values
  }  
    //prison checkbox, on client record, should be checked, if the client has a prison history.
    //check all the timeline event records and if he was in prison sometime, udpate teh account record.
 
 public void updatePrison(List<Timeline_Event__c> newList)
 {
    Set<String> clientSet = new Set<String>();
    for(Timeline_Event__c teLocal: newList)
    {
        clientSet.add(teLocal.Client__c);
    }
    if(clientSet.size()>0)
    {
        List<Contact> ContactRecords = [Select Id,AccountId, Prison_2__c, (Select Id From Timeline_Events__r where Type_of_Accommodation__c='Prison') from Contact where Id IN: clientSet];
        Map<Id,Account> updateAccounts = new Map<Id,Account>();
        for(Contact c: ContactRecords)
        {
            Account newC = new Account(Id = c.AccountId);
            if(c.Timeline_Events__r!=null && c.Timeline_Events__r.size()>0)
            {
                newC.Prison_2__pc = 'Yes';
            }
            else
            {
            if (c.Prison_2__c != 'Yes' && c.Prison_2__c != 'No' && c.Prison_2__c != 'Not known')
            {
                newC.Prison_2__pc = 'Not selected';
            }
            updateAccounts.put(c.Id,newC);
        }
        
        if(updateAccounts.size()>0)
            update updateAccounts.values();
    }
 }  
 }
   //*****************************************Before TRigger Functionality*************************************************************
   public void beforeTimeline(List<Timeline_Event__c> newList,Map<Id,Timeline_Event__c> oldMap)
   {
    Set<String> setAccommodationName = new Set<String>();
     //We have some picklist fields as a combined picklists. Followig code is used to break the values of these picklist fields
     // and populate the 2 seperate picklist values
     
     for(Timeline_Event__c t: newList)
     {
        //Borough/Street Site into "Street site borough" and "Street or sleeping site"
        if(t.Borough_Street_Site__c!=null && t.Borough_Street_Site__c.indexOf('-')>-1)
        {   
            t.Street_site_borough__c = t.Borough_Street_Site__c.substring(0,t.Borough_Street_Site__c.indexOf('-'));
            if(t.Borough_Street_Site__c.indexOf('-')+1<t.Borough_Street_Site__c.length())
                t.Street_or_sleeping_site__c = t.Borough_Street_Site__c.substring(t.Borough_Street_Site__c.indexOf('-')+1,t.Borough_Street_Site__c.length());
        }   
        //If a user enters an Accomodation picklist value and Project/Team field is blank
        //Look for a campaign with same name and populate the Project/Team field.
        //Collect all the Accommodation field values here to be used in query
        if(t.Accommodation2__c!=null && (oldMap==null || (oldMap!=null && t.Accommodation2__c!=oldMap.get(t.Id).Accommodation2__c)) && t.Project_Team__c==null)
        {
            setAccommodationName.add(t.Accommodation2__c);
        }
     }
     
     //If any qualified accommodationName exists, query from campaign
     List<Campaign> listCampaign = [Select Id,Name from Campaign where isActive=true and Name IN :setAccommodationName];
     if(listCampaign.size()>0)
     {
        Map<String,Id> mapCampaign = new Map<String,Id>();
        for(Campaign c: listCampaign)
        {
            mapCampaign.put(c.Name,c.Id);
        }
        for(Timeline_Event__c t: newList)
        {
            if(t.Accommodation2__c!=null && (oldMap==null || (oldMap!=null && t.Accommodation2__c!=oldMap.get(t.Id).Accommodation2__c)) && t.Project_Team__c==null && mapCampaign.get(t.Accommodation2__c)!=null)
                t.Project_Team__c = mapCampaign.get(t.Accommodation2__c);
        }   
     }
   }
}