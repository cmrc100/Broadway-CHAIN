@isTest
private class Test_Account_Ownership {
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
}