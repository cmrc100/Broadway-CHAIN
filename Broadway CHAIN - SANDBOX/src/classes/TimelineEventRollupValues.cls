global class TimelineEventRollupValues
{
    @Future
    public static void TriggerRollup(List<Id> contactIds, Boolean isInsert)
    {
        List<Account> accounts = new List<Account>();
        
        DateTime FirstSeenAHCSTM, TimelineLastDate, TimelineFirstDate;
        Date FirstSeenRSCSTM, FirstSeenRSPassage, MostRecentCSTMTLE, DateFirstContacted, FirstSeenRS, LastSeenRS;
        String BoroughLastSeenRoughSleeping, ProjectLastTeam, BoroughFirstSeenRoughSleeping, ProjectFirstTeam, StreetSiteLastSeenRoughSleeping;
        String TimelineEventAccommodation2 = '', TimelineEventEvent = '', TimelineEventCreatingUserOrganisation = '', AccountOwnership = '', TimelineEventEncounterEvent = '';
        Decimal CountOfNSNOHubAttendances = 0, Reconnections = 0, StMungosClient = 0, ThamesReachClient = 0, CountOfRSByPassage = 0, CountOfRSTLEs = 0;
        
        Map<Id, List<Timeline_Event__c>> timelineEventsByContactId = new  Map<Id, List<Timeline_Event__c>>();
        for(Timeline_Event__c ThisTimelineEvent : [SELECT Id, Arrival_Date__c, Client__c, Street_site_borough__c, Borough_street_site__c, Event__c, Creating_User_Organisation__c, Date__c, Project_Team__c, Project_Team__r.Name, RecordType.Name, Action_Date__c, Accommodation2__c, Encounter_Event__c, On_behalf_of_project_team__c FROM Timeline_Event__c WHERE Client__c IN :contactIds]) {
            if (!timelineEventsByContactId.containsKey( ThisTimelineEvent.Client__c)) {
                timelineEventsByContactId.put(ThisTimelineEvent.Client__c, new List<Timeline_Event__c>());
            }
            
            timelineEventsByContactId.get(ThisTimelineEvent.Client__c).add(ThisTimelineEvent);
        }
        
        for (Account AccountObject : [SELECT Id, PersonContactId, Ownership, Date_First_Contacted__pc, First_seen_RS_CSTM_apex__pc, First_seen_RS_Passage_apex__pc, First_seen_A_H_CSTM_apex__pc, Most_recent_CSTM_TLE_apex__pc, Count_of_RS_by_Passage_apex__pc, Count_of_RS_TLEs_apex__pc, Date_First_Seen_Rough_Sleeping__pc, Date_Last_Seen_Rough_Sleeping__pc FROM Account WHERE PersonContactId IN :contactIds]) {
            DateFirstContacted = AccountObject.Date_First_Contacted__pc;
            List<Timeline_Event__c> timelineEvents = timelineEventsByContactId.get(AccountObject.PersonContactId);
            
            FirstSeenRS = AccountObject.Date_First_Seen_Rough_Sleeping__pc;
            LastSeenRS = AccountObject.Date_Last_Seen_Rough_Sleeping__pc;
            FirstSeenRSCSTM = AccountObject.First_seen_RS_CSTM_apex__pc;
            FirstSeenRSPassage = AccountObject.First_seen_RS_Passage_apex__pc;
            FirstSeenAHCSTM = AccountObject.First_seen_A_H_CSTM_apex__pc;
            MostRecentCSTMTLE = AccountObject.Most_recent_CSTM_TLE_apex__pc;
            CountOfNSNOHubAttendances = 0;
            StMungosClient = 0;
            ThamesReachClient = 0;
            Reconnections = 0;
            CountOfRSByPassage = 0;
            CountOfRSTLEs = 0;
            
            if (timelineEvents != null) {
                for (Timeline_Event__c ThisTimelineEvent : timelineEvents) {
                    TimelineEventAccommodation2 = '';
                    TimelineEventEvent = '';
                    TimelineEventCreatingUserOrganisation = '';
                    AccountOwnership = '';
                    TimelineEventEncounterEvent = '';
                    
                    if (ThisTimelineEvent.Accommodation2__c != null) {
                        TimelineEventAccommodation2 = ThisTimelineEvent.Accommodation2__c.toLowerCase();
                    }
                    
                    if (ThisTimelineEvent.Event__c != null) {
                        TimelineEventEvent = ThisTimelineEvent.Event__c.toLowerCase();
                    }
                    
                    if (ThisTimelineEvent.Encounter_Event__c != null) {
                        TimelineEventEncounterEvent = ThisTimelineEvent.Encounter_Event__c.toLowerCase();
                    }
                    
                    if (ThisTimelineEvent.Creating_User_Organisation__c != null) {
                        TimelineEventCreatingUserOrganisation = ThisTimelineEvent.Creating_User_Organisation__c.toLowerCase();
                    }
                    
                    if (AccountObject.Ownership != null) {
                        AccountOwnership = AccountObject.Ownership.toLowerCase();
                    }
                    
                    if (ThisTimelineEvent.RecordType.Name.toLowerCase() == 'NSNO Referrals' && ThisTimelineEvent.Arrival_Date__c != null) {
                        CountOfNSNOHubAttendances++;
                    }
                    
                    if (DateFirstContacted == null && ThisTimelineEvent.Date__c != null) {
                        DateFirstContacted = ThisTimelineEvent.Date__c.date();
                    } else if (ThisTimelineEvent.Date__c != null && DateFirstContacted > ThisTimelineEvent.Date__c.date()) {
                        DateFirstContacted = ThisTimelineEvent.Date__c.date();
                    }
                    
                    if (TimelineEventEvent == 'street count' || TimelineEventEvent == 'street contact - bedded down' || TimelineEventEvent == 'street contact') {
                        if (TimelineLastDate == null) {
                            BoroughLastSeenRoughSleeping = ThisTimelineEvent.Street_site_borough__c;
                            StreetSiteLastSeenRoughSleeping = ThisTimelineEvent.Borough_street_site__c;
                            ProjectLastTeam = ThisTimelineEvent.Project_Team__c;
                            TimelineLastDate = ThisTimelineEvent.Date__c;
                            
                            if (ThisTimelineEvent.On_behalf_of_project_team__c != null) {
                            ProjectLastTeam = ThisTimelineEvent.On_behalf_of_project_team__c;
                            }
                        } else if (ThisTimelineEvent.Date__c > TimelineLastDate) {
                            BoroughLastSeenRoughSleeping = ThisTimelineEvent.Street_site_borough__c;
                            StreetSiteLastSeenRoughSleeping = ThisTimelineEvent.Borough_street_site__c;
                            ProjectLastTeam = ThisTimelineEvent.Project_Team__c;
                            TimelineLastDate = ThisTimelineEvent.Date__c;
                            
                            if (ThisTimelineEvent.On_behalf_of_project_team__c != null) {
                            ProjectLastTeam = ThisTimelineEvent.On_behalf_of_project_team__c;
                            }                       
                        }
                        
                        if (TimelineEventCreatingUserOrganisation == 'cstm') {
                            if (FirstSeenRSCSTM == null) {
                                FirstSeenRSCSTM = ThisTimelineEvent.Date__c.date();
                            } else if (FirstSeenRSCSTM > ThisTimelineEvent.Date__c) {
                                FirstSeenRSCSTM = ThisTimelineEvent.Date__c.date();
                            }
                        } else if (TimelineEventCreatingUserOrganisation == 'passage') {
                            if (FirstSeenRSPassage == null) {
                                FirstSeenRSPassage = ThisTimelineEvent.Date__c.date();
                            } else if (FirstSeenRSPassage > ThisTimelineEvent.Date__c) {
                                FirstSeenRSPassage = ThisTimelineEvent.Date__c.date();
                            }
                        }
                        
                        if (TimelineEventCreatingUserOrganisation == 'passage') {
                            CountOfRSByPassage++;
                        }
                        
                        CountOfRSTLEs++;
                    }
                    
                    if (TimelineEventEvent == 'street count' || TimelineEventEvent == 'street contact - bedded down' || TimelineEventEvent == 'street contact' || TimelineEventEncounterEvent == 'street count' || TimelineEventEncounterEvent == 'street contact - bedded down' || TimelineEventEncounterEvent == 'street contact') {
                        if (TimelineFirstDate == null) {
                            BoroughFirstSeenRoughSleeping = ThisTimelineEvent.Street_site_borough__c;
                            StreetSiteLastSeenRoughSleeping = ThisTimelineEvent.Borough_street_site__c;
                            ProjectFirstTeam = ThisTimelineEvent.Project_Team__c;
                            TimelineFirstDate = ThisTimelineEvent.Date__c;
                            
                            if (ThisTimelineEvent.On_behalf_of_project_team__c != null) {
                                ProjectFirstTeam = ThisTimelineEvent.On_behalf_of_project_team__c;
                            }
                        } else if (ThisTimelineEvent.Date__c < TimelineFirstDate) {
                            BoroughFirstSeenRoughSleeping = ThisTimelineEvent.Street_site_borough__c;
                            StreetSiteLastSeenRoughSleeping = ThisTimelineEvent.Borough_street_site__c;
                            TimelineFirstDate = ThisTimelineEvent.Date__c;
                        }
                        
                        if (FirstSeenRS > ThisTimelineEvent.Date__c || FirstSeenRS == null) {
                            FirstSeenRS = ThisTimelineEvent.Date__c.Date();
                        }
                        
                        if (LastSeenRS < ThisTimelineEvent.Date__c || LastSeenRS == null) {
                            LastSeenRS = ThisTimelineEvent.Date__c.Date();
                        }
                    }
                    
                    if (TimelineEventEvent == 'street count' || TimelineEventEvent == 'street contact - bedded down' || TimelineEventEvent == 'street contact' || TimelineEventEvent == 'street contact - not bedded down' || TimelineEventEncounterEvent == 'street count' || TimelineEventEncounterEvent == 'street contact - bedded down' || TimelineEventEncounterEvent == 'street contact' || TimelineEventEncounterEvent == 'street contact - not bedded down') {
                        if (isInsert && AccountOwnership != 'public') {
                            AccountObject.Ownership = 'Public';
                        }
                    }
                    
                    if (ThisTimelineEvent.Project_Team__r != null) {
                        if ('cstm - advice & housing' == ThisTimelineEvent.Project_Team__r.Name.toLowerCase()) {
                            if (FirstSeenAHCSTM == null) {
                                FirstSeenAHCSTM = ThisTimelineEvent.Date__c;
                            } else if (FirstSeenAHCSTM > ThisTimelineEvent.Date__c) {
                                FirstSeenAHCSTM = ThisTimelineEvent.Date__c;
                            }
                        }
                    }
                    
                    if (TimelineEventCreatingUserOrganisation == 'st mungo\'s') {
                        StMungosClient++;
                    }
                    
                    if (TimelineEventCreatingUserOrganisation == 'thames reach') {
                        ThamesReachClient++;
                    }
                    
                    if (TimelineEventCreatingUserOrganisation == 'cstm') {
                        if (MostRecentCSTMTLE == null) {
                            MostRecentCSTMTLE = ThisTimelineEvent.Action_Date__c;
                        } else if (MostRecentCSTMTLE < ThisTimelineEvent.Action_Date__c) {
                            MostRecentCSTMTLE = ThisTimelineEvent.Action_Date__c;
                        }
                    }
                    
                    if (ThisTimelineEvent.RecordType.Name.toLowerCase() == 'reconnections') {
                        Reconnections++;
                    }
                }
            }
            
            AccountObject.Count_of_NSNO_Hub_attendances_apex__pc = CountOfNSNOHubAttendances;
            AccountObject.First_seen_RS_CSTM_apex__pc = FirstSeenRSCSTM;
            AccountObject.First_seen_RS_Passage_apex__pc = FirstSeenRSPassage;
            AccountObject.First_seen_A_H_CSTM_apex__pc = FirstSeenAHCSTM;
            AccountObject.Reconnections_apex__pc = Reconnections;
            AccountObject.St_Mungo_s_client_apex__pc = StMungosClient;
            AccountObject.Thames_Reach_client_apex__pc = ThamesReachClient;
            AccountObject.Most_recent_CSTM_TLE_apex__pc = MostRecentCSTMTLE;
            AccountObject.Borough_Last_Seen_Rough_Sleeping__pc = BoroughLastSeenRoughSleeping;
            AccountObject.StreetSite_Last_Seen_Rough_Sleeping_apex__pc = StreetSiteLastSeenRoughSleeping;
            AccountObject.Last_seen_rough_sleeping_by_Project_team__pc = ProjectLastTeam;
            AccountObject.Borough_first_rough_sleeping_apex__pc = BoroughFirstSeenRoughSleeping;
            AccountObject.Team_verifying_client_apex__pc = ProjectFirstTeam;
            AccountObject.Date_First_Contacted__pc = DateFirstContacted;
            AccountObject.Count_of_RS_by_Passage_apex__pc = CountOfRSByPassage;
            AccountObject.Count_of_RS_TLEs_apex__pc = CountOfRSTLEs;
            AccountObject.Date_First_Seen_Rough_Sleeping__pc = FirstSeenRS;
            AccountObject.Date_Last_Seen_Rough_Sleeping__pc = LastSeenRS;
            
            accounts.add(AccountObject);
        }
        
        update(accounts);
    }
    
    // Triggered from Timeline event changes 
    // to update the CSTM Private Action plan fields 
    // held against the parent contact with values from
    // most recent Timeline event record. 
    public static void updateContactActionPlan( List<Id> clientIdList){
        
        try{

            if (!clientIdList.isEmpty()){
                
                //Populate User map for reference
                map<Id, User> userMap = new map<Id,User>([select Id, Name from User]);
                
                // extract client SSO fields and the most recently created Timeline Event record related to the client
                list<Contact> contactList = [select Id, CSTM_Private_Action_plan__c, Action_Plan_last_edited_by__c, 
                                                CSTM_very_Private_action_plan__c, CSTM_vprivate_action_plan_last_edited__c,
                                                (select CSTM_Private_Action_plan__c, CSTM_very_Private_Action_plan__c,  
                                                    LastModifiedById, LastModifiedDate, Date__c
                                                            from Timeline_Events__r 
                                                            order by Date__c desc nulls last, Id desc )
                                                from contact where id in :clientIdList];     
                                                        
                for (contact c :contactList){                   
                    boolean actionPlanUpdated = false;
                    boolean actionPrivateActionPlanUpdated = false;
                    string actionPlan = '';
                    string vprivatePlan = '';
                    if (c.Timeline_Events__r.isEmpty() || c.Timeline_Events__r == null){ // blank out values if no Timeline Events exist
                        c.CSTM_Private_Action_plan__c = '';
                        c.Action_Plan_last_edited_by__c = '';
                        c.CSTM_very_Private_action_plan__c = '';
                        c.CSTM_vprivate_action_plan_last_edited__c = '';
                        actionPlanUpdated = true;
                        actionPrivateActionPlanUpdated = true;                                                                  
                    } else {
                        for(Timeline_Event__c tl :c.Timeline_Events__r){
                            actionPlan = tl.CSTM_Private_Action_plan__c;
                            if (string.isnotBlank(actionPlan) && !actionPlanUpdated){
                                actionPlanUpdated = true;
                                // stamp client fields with field values from Timeline Event record
                                string userName = '';
                                User u = userMap.get(tl.LastModifiedById);
                                if (u != null){
                                    userName = u.Name;
                                }
                                if (c.CSTM_Private_Action_plan__c != actionPlan){
                                    c.CSTM_Private_Action_plan__c = actionPlan;
                                    c.Action_Plan_last_edited_by__c = userName + ' - ' + tl.LastModifiedDate.format('dd/MM/yyyy HH:mm');
                                }
                                //break;
                            }

                            vprivatePlan = tl.CSTM_very_Private_Action_plan__c;
                            if (string.isnotBlank(vprivatePlan) && !actionPrivateActionPlanUpdated){
                                actionPrivateActionPlanUpdated = true;
                                // stamp client fields with field values from Timeline Event record
                                string userName = '';
                                User u = userMap.get(tl.LastModifiedById);
                                if (u != null){
                                    userName = u.Name;
                                }
                                if (c.CSTM_very_Private_action_plan__c != vprivatePlan){
                                    c.CSTM_very_Private_action_plan__c = vprivatePlan;
                                    c.CSTM_vprivate_action_plan_last_edited__c = userName + ' - ' + tl.LastModifiedDate.format('dd/MM/yyyy HH:mm');
                                }
                                //break;
                            }

                        }
                    }
                    if (string.isBlank(actionPlan) && !actionPlanUpdated){
                        c.CSTM_Private_Action_plan__c = '';
                        c.Action_Plan_last_edited_by__c = '';                       
                    }
                    if (string.isBlank(vprivatePlan) && !actionPrivateActionPlanUpdated){
                        c.CSTM_very_Private_action_plan__c = '';
                        c.CSTM_vprivate_action_plan_last_edited__c = '';                        
                    }
                }
                
                update contactList;       
            
            
            }
        
        } catch (exception e){
            
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());   
        }
    
    }

    // Triggered from Timeline event changes 
    // to update the summary count values held 
    // on the associated NSNO Event object 
    public static void updateNSNOEvents( set<Id> timelineIds){
        
        set<Id> NSNOEventIdList = new set<Id>();
        list<Timeline_Event__c> timelineEvents = new list<Timeline_Event__c>();
        map<Id, date> arrivalDateMap = new map<Id, date>(); 
        id NSNORecordTypeID = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('NSNO Referrals').RecordTypeId; 
        
        try{
            if (!timelineIds.isEmpty()){
                timelineEvents = [Select NSNO_Event__c, Arrival_Date__c from Timeline_Event__c 
                                        where Id in :timelineIds 
                                        and RecordTypeId =:NSNORecordTypeID 
                                        order by NSNO_Event__c, Arrival_Date__c ALL ROWS];    
                
                if(!timelineEvents.isEmpty()){
                    for(Timeline_Event__c timeline :timelineEvents){
                        if (string.isnotBlank(timeline.NSNO_Event__c)){
                            NSNOEventIdList.add(timeline.NSNO_Event__c);
                        }
                    }

                }
            }
            
            if (!NSNOEventIdList.isEmpty()){
                
                // Retrieve timeline record with earliest arrival date
                timelineEvents = [Select NSNO_Event__c, Arrival_Date__c from Timeline_Event__c 
                                        where NSNO_Event__c in :NSNOEventIdList
                                        and Arrival_Date__c != null                                         
                                        order by NSNO_Event__c, Arrival_Date__c ASC];                   

                for(Timeline_Event__c timeline :timelineEvents){
                    if (string.isnotBlank(timeline.NSNO_Event__c)){
                        if(!arrivalDateMap.containsKey(timeline.NSNO_Event__c)){
                            arrivalDateMap.put(timeline.NSNO_Event__c, timeline.Arrival_Date__c);
                        }
                    }
                }
system.debug(' @@@@@  Arrival Date Map   ' + arrivalDateMap);                   
                                
system.debug(' @@@@@  timelineEvents   ' + timelineEvents);             
                
                
                map<Id, NSNO_Event__c> NSNOEventsMap = new map<Id, NSNO_Event__c>([select Count_of_NSNO_referrals__c, Count_of_open_NSNO_referrals__c,
                                                                                    First_arrival__c
                                                                                    from NSNO_Event__c where id in :NSNOEventIdList]);
                
                AggregateResult [] allNSNOReferrals = [select NSNO_Event__c nsnoId, count (Id) RecordCount 
                                    From Timeline_Event__c  where
                                    NSNO_Event__c in :NSNOEventIdList and 
                                    RecordTypeId =:NSNORecordTypeID
                                    Group By NSNO_Event__c];
                if (!allNSNOReferrals.isEmpty()){
                    for (AggregateResult ar :allNSNOReferrals){
                        string recId = string.valueOf(ar.get('nsnoId'));
                        integer recCount = integer.valueOf(ar.get('RecordCount'));
                        NSNOEventsMap.get(recId).Count_of_NSNO_referrals__c = recCount;
                        NSNOEventsMap.get(recId).First_Arrival__c = arrivalDateMap.get(recId);
                    }
                } else {
                    for (NSNO_Event__c nsno :NSNOEventsMap.values()){
                        nsno.Count_of_NSNO_referrals__c = 0;
                        nsno.First_Arrival__c = arrivalDateMap.get(nsno.Id);                        
                    }
                }
                
                AggregateResult [] allOpenNSNOReferrals = [select NSNO_Event__c nsnoId, count (Id) RecordCount 
                                    From Timeline_Event__c  where
                                    NSNO_Event__c in :NSNOEventIdList and 
                                    RecordTypeId =:NSNORecordTypeID and
                                    Leaving_Date__c = null
                                    Group By NSNO_Event__c];                

                if (!allOpenNSNOReferrals.isEmpty()){
                    for (AggregateResult ar :allOpenNSNOReferrals){
                        string recId = string.valueOf(ar.get('nsnoId'));
                        integer recCount = integer.valueOf(ar.get('RecordCount'));
                        NSNOEventsMap.get(recId).Count_of_open_NSNO_referrals__c = recCount;
                    }
                } else {
                    for (NSNO_Event__c nsno :NSNOEventsMap.values()){
                        nsno.Count_of_open_NSNO_referrals__c = 0;                       
                    }
                }
                
                update NSNOEventsMap.values();
            }
        
        } catch (exception e){
            
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());   
        }
    
    }

}