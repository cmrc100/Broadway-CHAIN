@isTest
private class Test_Client_Rollup_Values {
    static testMethod void testFirstSeenRSCSTM () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice & Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            // Create dates for the different min & max dates required.
            DateTime Past = DateTime.now().addDays(-10);
            // Create dates for the different min & max dates required.
            DateTime Now = DateTime.now();
            
            Test.startTest();
            
            Timeline_Event__c TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Past,
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Now,
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            Test.stopTest();
            
            // Get the updated values.
            Client = [SELECT First_seen_RS_CSTM_apex__pc FROM Account WHERE Id = :Client.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals(Past.date(), Client.First_seen_RS_CSTM_apex__pc);
        }
    }
    
    static testMethod void testMostRecentCSTMTLE () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice & Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            // Create dates for the different min & max dates required.
            DateTime Past = DateTime.now().addDays(-10);
            // Create dates for the different min & max dates required.
            DateTime Now = DateTime.now();
            
            Test.startTest();
            
            Timeline_Event__c TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Past,
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Now,
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            Test.stopTest();
            
            // Get the updated values.
            Client = [SELECT Most_recent_CSTM_TLE_apex__pc FROM Account WHERE Id = :Client.Id];
            TimelineEvent = [SELECT Id, Action_Date__c FROM Timeline_Event__c WHERE Id = :TimelineEvent.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals(TimelineEvent.Action_Date__c, Client.Most_recent_CSTM_TLE_apex__pc);
        }
    }
    
    static testMethod void testFirstSeenRSPassage () {
        Campaign c = new Campaign(
            Name = 'Passage', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'Passage@Passage.dl', Email = 'Passage@Passage.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'Passage');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            // Create dates for the different min & max dates required.
            DateTime Past = DateTime.now().addDays(-10);
            // Create dates for the different min & max dates required.
            DateTime Now = DateTime.now();
            
            Test.startTest();
            
            Timeline_Event__c TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'Passage',
                Date__c = Past,
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'Passage',
                Date__c = Now,
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            Test.stopTest();
            
            // Get the updated values.
            Client = [SELECT First_seen_RS_Passage_apex__pc FROM Account WHERE Id = :Client.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals(Past.date(), Client.First_seen_RS_Passage_apex__pc);
        }
    }
    
    static testMethod void testFirstSeenAHCSTM () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice and Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            // Create dates for the different min & max dates required.
            DateTime Past = DateTime.now().addDays(-10);
            // Create dates for the different min & max dates required.
            DateTime Now = DateTime.now();
            
            Test.startTest();
            
            Timeline_Event__c TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Attended NSNO assessment centre',
                Creating_User_Organisation__c = 'St Mungo\'s',
                Date__c = Past,
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Attended NSNO assessment centre',
                Creating_User_Organisation__c = 'St Mungo\'s',
                Date__c = Now,
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            Test.stopTest();
            
            // Get the updated values.
            Client = [SELECT First_seen_A_H_CSTM_apex__pc FROM Account WHERE Id = :Client.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            //System.assertEquals(Past, Client.First_seen_A_H_CSTM_apex__pc);
        }
    }
    
    static testMethod void testCountsOfNSNOMungoThamesAndReconnections () {
        Campaign c = new Campaign(
            Name = 'NSNO Assessment Hub - North', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice & Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            // Create dates for the different min & max dates required.
            DateTime Now = DateTime.now();
            
            Test.startTest();
            
            Timeline_Event__c TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Attended NSNO assessment centre',
                Accommodation2__c = 'NSNO Assessment Hub - North',
                Type_of_Accommodation__c = 'NSNO Staging Post',
                Creating_User_Organisation__c = 'St Mungo\'s',
                Date__c = Now,
                //RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'NSNO Referrals' AND SobjectType = 'Timeline_Event__c'].Id,
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Attended NSNO assessment centre',
                Accommodation2__c = 'NSNO Assessment Hub - North',
                Type_of_Accommodation__c = 'NSNO Staging Post',
                Creating_User_Organisation__c = 'Thames Reach',
                Date__c = Now,
                Project_Team__c = c.Id,
                //RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Reconnections'].Id,
                RecordTypeId = Schema.SObjectType.Timeline_Event__c.getRecordTypeInfosByName().get('Reconnections').getRecordTypeId(),
                Return_to_home_area__c = true,
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            Test.stopTest();
            
            // Get the updated values.
            Client = [SELECT Thames_Reach_client_apex__pc, St_Mungo_s_client_apex__pc, Reconnections_apex__pc, Count_of_NSNO_Hub_attendances_apex__pc FROM Account WHERE Id = :Client.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals(0, Client.Count_of_NSNO_Hub_attendances_apex__pc);
            System.assertEquals(0, Client.St_Mungo_s_client_apex__pc);
            System.assertEquals(0, Client.Thames_Reach_client_apex__pc);
            System.assertEquals(1, Client.Reconnections_apex__pc);
        }
    }
    
    static testMethod void testDateOfMostRecentSNA () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice & Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            // Create dates for the different min & max dates required.
            Date Past = Date.today().addDays(-10);
            
            Support_Needs_Lifestyle__c SupportNeedsLifestyle = new Support_Needs_Lifestyle__c(
                Client__c = Client.PersonContactId,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Support_Needs_Lifestyle__c' AND Name = 'Support Needs & Lifestyle'].Id,
                Assessment_date__c = Past
            );
            insert SupportNeedsLifestyle;
            
            // Get the updated values.
            Client = [SELECT Id, PersonContactId, Date_of_most_recent_SNA_apex__pc FROM Account WHERE Id = :Client.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals(Past, Client.Date_of_most_recent_SNA_apex__pc);
            
            // Create dates for the different min & max dates required.
            Date Now = Date.today();
            
            SupportNeedsLifestyle = new Support_Needs_Lifestyle__c(
                Client__c = Client.PersonContactId,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Support_Needs_Lifestyle__c' AND Name = 'Support Needs & Lifestyle'].Id,
                Assessment_date__c = Now
            );
            insert SupportNeedsLifestyle;
            
            // Get the updated values.
            Client = [SELECT Date_of_most_recent_SNA_apex__pc FROM Account WHERE Id = :Client.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals(Now, Client.Date_of_most_recent_SNA_apex__pc);
        }
    }
    
    static testMethod void testDateLastAccessedCSTMNightcentreAndTotalDayNightCentreVisitsCSTM () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice & Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            // Create dates for the different min & max dates required.
            Date Past = Date.today().addDays(-10);
            
            Session__c Session = new Session__c(Date__c = Past);
            insert Session;
            
            Session_attendance__c SessionAttendance = new Session_attendance__c(
                Session__c = Session.Id,
                Client__c = Client.PersonContactId,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Session_attendance__c' AND Name = 'CSTM night centre_not today'].Id,
                Session_Date__c = Past
            );
            insert SessionAttendance;
            
            // Get the updated values.
            Client = [SELECT Id, PersonContactId, Date_last_accessed_CSTM_nightcentre_apex__pc FROM Account WHERE Id = :Client.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals(Past, Client.Date_last_accessed_CSTM_nightcentre_apex__pc);
            
            // Create dates for the different min & max dates required.
            Date Now = Date.today();
            
            Session.Date__c = Now;
            update Session;
            
            SessionAttendance = new Session_attendance__c(
                Session__c = Session.Id,
                Client__c = Client.PersonContactId,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Session_attendance__c' AND Name = 'CSTM night centre_not today'].Id,
                Session_Date__c = Now
            );
            insert SessionAttendance;
            
            SessionAttendance = new Session_attendance__c(
                Session__c = Session.Id,
                Client__c = Client.PersonContactId,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Session_attendance__c' AND Name = 'Session attendance_CSTM'].Id,
                Session_Date__c = Now
            );
            insert SessionAttendance;
            
            // Get the updated values.
            Client = [SELECT Date_last_accessed_CSTM_nightcentre_apex__pc, Total_day_night_centre_visits_CSTM_apex__pc FROM Account WHERE Id = :Client.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals(Now, Client.Date_last_accessed_CSTM_nightcentre_apex__pc);
            //System.assertEquals(3, Client.Total_day_night_centre_visits_CSTM_apex__pc);
            
            Past = Date.today().addDays(-50);
            SessionAttendance.Session_Date__c = Past;
            update SessionAttendance;
        }
    }
    
    static testMethod void testNumberOfClientAlerts () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice & Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            Client_Alerts__c ClientAlert = new Client_Alerts__c(
                Client__c = Client.PersonContactId,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Client_Alerts__c' AND Name = 'Client alerts_visible'].Id,
                Alert_Type__c = 'Serious assault - actual or threatened',
                Date_Created__c = Date.today()
            );
            insert ClientAlert;
            
            ClientAlert = new Client_Alerts__c(
                Client__c = Client.PersonContactId,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Client_Alerts__c' AND Name = 'Client alerts_visible'].Id,
                Alert_Type__c = 'Serious assault - actual or threatened',
                Date_Created__c = Date.today()
            );
            insert ClientAlert;
            
            // Get the updated values.
            Client = [SELECT Number_of_client_alerts_apex__pc FROM Account WHERE Id = :Client.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals(2, Client.Number_of_client_alerts_apex__pc);
        }
    }
    
    static testMethod void testCSTMOwnership() {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            Account a = new Account(FirstName = 'CSTM', LastName = 'Test', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = c.Name);
            insert a;
            
            a = [SELECT Id, PersonContactId, Ownership FROM Account WHERE Id = :a.Id];
            
            System.assertEquals('CSTM', a.Ownership);
            
            Test.startTest();
            
            Timeline_Event__c te = new Timeline_Event__c(
                Client__c = a.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Date.today(),
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert te;
            
            Test.stopTest();
            
            a = [SELECT Id, PersonContactId, Ownership FROM Account WHERE Id = :a.Id];
            
            System.assertEquals('Public', a.Ownership);
        }
    }
    
    static testMethod void testMungoOwnership() {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'mungo@mungo.dl', Email = 'mungo@mungo.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            Account a = new Account(FirstName = 'mungo', LastName = 'Test', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = c.Name);
            insert a;
            
            a = [SELECT Id, PersonContactId, Ownership FROM Account WHERE Id = :a.Id];
            
            System.assertEquals('St Mungo\'s', a.Ownership);
            
            Test.startTest();
            
            Timeline_Event__c te = new Timeline_Event__c(
                Client__c = a.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Date.today(),
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert te;
            
            Test.stopTest();
            
            a = [SELECT Id, PersonContactId, Ownership FROM Account WHERE Id = :a.Id];
            
            System.assertEquals('Public', a.Ownership);
        }
    }
    
    static testMethod void testThamesOwnership() {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'thames@thames.dl', Email = 'thames@thames.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            Account a = new Account(FirstName = 'thames', LastName = 'Test', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = c.Name);
            insert a;
            
            a = [SELECT Id, PersonContactId, Ownership FROM Account WHERE Id = :a.Id];
            
            System.assertEquals('Thames Reach', a.Ownership);
            
            Test.startTest();
            
            Timeline_Event__c te = new Timeline_Event__c(
                Client__c = a.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Date.today(),
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert te;
            
            Test.stopTest();
            
            a = [SELECT Id, PersonContactId, Ownership FROM Account WHERE Id = :a.Id];
            
            System.assertEquals('Public', a.Ownership);
        }
    }
    
    static testMethod void testPassageOwnership() {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'passage@passage.dl', Email = 'passage@passage.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            Account a = new Account(FirstName = 'passage', LastName = 'Test', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = c.Name);
            insert a;
            
            a = [SELECT Id, PersonContactId, Ownership FROM Account WHERE Id = :a.Id];
            
            System.assertEquals('Passage', a.Ownership);
            
            Test.startTest();
            
            Timeline_Event__c te = new Timeline_Event__c(
                Client__c = a.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Date.today(),
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage'
            );
            insert te;
            
            Test.stopTest();
            
            a = [SELECT Id, PersonContactId, Ownership FROM Account WHERE Id = :a.Id];
            
            System.assertEquals('Public', a.Ownership);
        }
    }
    
    
   static testMethod void testCSTMPrivateAction () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice & Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            // Create dates for the different min & max dates required.
            DateTime Past = DateTime.now().addDays(-10);
            // Create dates for the different min & max dates required.
            DateTime Now = DateTime.now();
            id NLOSRecordTypeID = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('NLOS Referrals').RecordTypeId; 
            Test.startTest();
            
            Timeline_Event__c TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage',
                CSTM_Private_Action_plan__c = 'Action 1',
                Date__c = system.Today().addDays(-2),
                RecordTypeId = NLOSRecordTypeID
            );
            insert TimelineEvent;
            
            TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Project_Team__c = c.Id,
                NSNO_Action__c = 'Declined to engage',
                CSTM_Private_Action_plan__c = 'Action 2',
                Date__c = system.Today().addDays(-1),
                RecordTypeId = NLOSRecordTypeID
            );
            insert TimelineEvent;                                                                         
            
            // Get the updated values.
            Contact contact = [SELECT CSTM_Private_Action_plan__c, Action_Plan_last_edited_by__c FROM Contact WHERE Id = :Client.PersonContactId];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals('Action 2', contact.CSTM_Private_Action_plan__c);   
            
            Test.stopTest();

        }
    }
    
    
   static testMethod void testNSNOEventCounts () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u) {
            // Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice & Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];

            NSNO_Event__c NSNOEvent = new NSNO_Event__c(Client__c = Client.PersonContactId, Rough_sleeping_status__c = 'New rough sleeper');
            insert NSNOEvent;
            
            // Create dates for the different min & max dates required.
            DateTime Past = DateTime.now().addDays(-10);
            // Create dates for the different min & max dates required.
            DateTime Now = DateTime.now();
            id NSNORecordTypeID = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('NSNO Referrals').RecordTypeId; 
            Test.startTest();
            
            Timeline_Event__c TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Encounter_type__c = 'Accessed service',
                Event__c = 'Attended NSNO assessment centre',
                Type_of_accommodation__c = 'Assessment centre',
                Accommodation2__c = 'NSNO Assessment Hub - North',
                Originating_borough__c = 'Havering',
                Creating_User_Organisation__c = 'CSTM',
                Project_Team__c = c.Id,
                Source_of_referral_pick__c = 'London Reconnect',
                Referral_Date__c = system.Today().addDays(-2),
                RecordTypeId = NSNORecordTypeID,
                NSNO_Event__c = NSNOEvent.Id
            );
            insert TimelineEvent;
            
            Timeline_Event__c TimelineEvent2 = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Encounter_type__c = 'Accessed service',
                Event__c = 'Attendend NSNO assessment centre',
                Type_of_accommodation__c = 'Assessment centre',
                Accommodation2__c = 'NSNO Assessment Hub - South',
                Originating_borough__c = 'Havering',
                Creating_User_Organisation__c = 'CSTM',
                Project_Team__c = c.Id,
                Source_of_referral_pick__c = 'London Reconnect',
                Referral_Date__c = system.Today().addDays(-1),
                Leaving_Date__c = system.today(),
                RecordTypeId = NSNORecordTypeID,
                NSNO_Event__c = NSNOEvent.Id
            );
            insert TimelineEvent2;                                                                        
            
            // Get the updated values.

            NSNOEvent = [select Count_of_NSNO_referrals__c, Count_of_open_NSNO_referrals__c from NSNO_Event__c where Id = :NSNOEvent.Id];
            system.assertEquals(NSNOEvent.Count_of_NSNO_referrals__c, 2);
            system.assertEquals(NSNOEvent.Count_of_open_NSNO_referrals__c, 1);
            
            delete TimelineEvent2;
            NSNOEvent = [select Count_of_NSNO_referrals__c, Count_of_open_NSNO_referrals__c from NSNO_Event__c where Id = :NSNOEvent.Id];
            system.assertEquals(NSNOEvent.Count_of_NSNO_referrals__c, 1);
            system.assertEquals(NSNOEvent.Count_of_open_NSNO_referrals__c, 1);          
            
            Test.stopTest();

        }
    }
                
}