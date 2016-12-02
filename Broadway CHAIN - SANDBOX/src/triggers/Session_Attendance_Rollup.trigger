trigger Session_Attendance_Rollup on Session_attendance__c (after insert, after update, after delete) {
    List<Id> contactIds = new List<Id>();
    List<Contact> contacts = new List<Contact>();
    
    Date DateLastAccessedCSTMNightCentre, DateFirstContacted;
    DateTime MostRecentCSTMSessionAttendance;
    Integer TotalDayNightCentreVisitsCSTM = 0;
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Session_attendance__c t : Trigger.new) {
            contactIds.add(t.Client__c);
        }
    } else if (Trigger.isDelete) {
        for (Session_attendance__c t : Trigger.old) {
            contactIds.add(t.Client__c);
        }
    }
    
    Map<Id, List<Session_attendance__c>> sessionAttendanceByContactId = new  Map<Id, List<Session_attendance__c>>();
    for (Session_attendance__c ThisSessionAttendance : [SELECT Id, RecordType.Name, Session_Date__c, Client__c, Type__c FROM Session_attendance__c WHERE Client__c IN :contactIds]) {
        if (!sessionAttendanceByContactId.containsKey( ThisSessionAttendance.Client__c)) {
            sessionAttendanceByContactId.put( ThisSessionAttendance.Client__c, new List<Session_attendance__c>() );
        }
        
        sessionAttendanceByContactId.get( ThisSessionAttendance.Client__c ).add( ThisSessionAttendance );
    }
    
    for (Contact c : [SELECT Id, Date_First_Contacted__c, Date_last_accessed_CSTM_nightcentre_apex__c, Total_day_night_centre_visits_CSTM_apex__c FROM Contact WHERE Id IN :contactIds]) {
        DateFirstContacted = c.Date_First_Contacted__c;
        DateLastAccessedCSTMNightCentre = c.Date_last_accessed_CSTM_nightcentre_apex__c;
        TotalDayNightCentreVisitsCSTM = 0;
        
        List<Session_attendance__c> sessionAttendance = sessionAttendanceByContactId.get(c.Id);
        if (sessionAttendance != null) {
            for (Session_attendance__c ThisSessionAttendance : sessionAttendance) {
                if (ThisSessionAttendance.RecordType.Name == 'CSTM night centre_not today') {
                    if (DateLastAccessedCSTMNightCentre == null) {
                        DateLastAccessedCSTMNightCentre = ThisSessionAttendance.Session_Date__c;
                    } else if (DateLastAccessedCSTMNightCentre < ThisSessionAttendance.Session_Date__c) {
                        DateLastAccessedCSTMNightCentre = ThisSessionAttendance.Session_Date__c;
                    }
                }
                
                if (ThisSessionAttendance.RecordType.Name.contains('CSTM')) {
                    if (MostRecentCSTMSessionAttendance == null) {
                        MostRecentCSTMSessionAttendance = ThisSessionAttendance.Session_Date__c;
                    } else if (MostRecentCSTMSessionAttendance < ThisSessionAttendance.Session_Date__c) {
                        MostRecentCSTMSessionAttendance = ThisSessionAttendance.Session_Date__c;
                    }
                
                    if (ThisSessionAttendance.Type__c == 'Night Centre attendance' || ThisSessionAttendance.Type__c == 'Day Centre attendance') {
                        TotalDayNightCentreVisitsCSTM++;
                    }
                }
                
                if (DateFirstContacted == null) {
                    DateFirstContacted = ThisSessionAttendance.Session_Date__c;
                } else if (DateFirstContacted > ThisSessionAttendance.Session_Date__c) {
                    DateFirstContacted = ThisSessionAttendance.Session_Date__c;
                }
            }
        }
        
        c.Date_last_accessed_CSTM_nightcentre_apex__c = DateLastAccessedCSTMNightCentre;
        c.Total_day_night_centre_visits_CSTM_apex__c = TotalDayNightCentreVisitsCSTM;
        c.Date_First_Contacted__c = DateFirstContacted;
        c.Most_recent_CSTM_session_attendance_apex__c = MostRecentCSTMSessionAttendance;
        
        contacts.add(c);
    }
    
    update(contacts);
}