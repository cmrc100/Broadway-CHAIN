@isTest

private class testSetWardValue {
    static testMethod void testTimelineEventWardValue () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id,
            Default_Project_Name__c = c.Name
        );
        insert u;
        
        System.runAs(u) {
            Country_or_Area__c CountryArea = new Country_or_Area__c(
                Name = 'Test Timeline Event', Borough__c = 'Barnet', Ward__c = 'Test Ward', SNT_Ward_Pick__c = 'Test Ward'
            );
            insert CountryArea;// Create client account to use with the timeline events and client alerts.
            
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice and Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            DateTime Now = DateTime.now();
            
            Timeline_Event__c TimelineEvent = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street count',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Now,
                Project_Team__c = c.Id,
                Borough_Street_Site__c = 'Test Timeline Event',
                NSNO_Action__c = 'Declined to engage'
            );
            insert TimelineEvent;
            
            TimelineEvent = [SELECT Id, SNT_Ward__c FROM Timeline_Event__c WHERE Id = :TimelineEvent.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals('Test Ward', TimelineEvent.SNT_Ward__c);
        }
    }
    
    static testMethod void testReferralsWardValue () {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id,
            Default_Project_Name__c = c.Name
        );
        insert u;
        
        System.runAs(u) {
            Country_or_Area__c CountryArea = new Country_or_Area__c(
                Name = 'Test Referral', Borough__c = 'Barnet', Ward__c = 'Test Ward'
            );
            insert CountryArea;// Create client account to use with the timeline events and client alerts.
            
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice and Housing');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            DateTime Now = DateTime.now();
            
            Referrals__c Referral = new Referrals__c(
                Street_name__c = 'Test Referral'
            );
            insert Referral;
            
            Referral = [SELECT Id, Ward__c FROM Referrals__c WHERE Id = :Referral.Id];
            
            // We can now check the details of the fields to see if they have updated correctly.
            System.assertEquals('Test Ward', Referral.Ward__c);
        }
    }
}