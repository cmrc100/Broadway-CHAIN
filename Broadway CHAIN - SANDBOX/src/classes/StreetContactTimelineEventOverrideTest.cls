@isTest
private class StreetContactTimelineEventOverrideTest {

    static Account Client;
    static Contact contact;
    static User usr;
    
    static void setupData(){
       
       Campaign c = new Campaign(
            Name = 'NLOS Assessment Hub', Borough__c = 'Barnet', Private_notes_Westminster_copy_over__c = true
        );
        insert c;
        
        usr = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert usr;

        System.runAs(usr) {
                
    
            Client = new Account(LastName = 'Bones', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'NLOS Assessment Hub');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            contact = [SELECT Id,  Special_Action__c, Date_NSNO_offer_made__c, 
                                        Team_making_single_service_offer__c,
                                        Offer_Outcome__c 
                                        FROM contact WHERE Id = :Client.PersonContactId];

        }               
        
        
    }

    static testMethod void unitTest() {
        
        setupData();
        
        PageReference pageRef = page.StreetContactTimelineEventOverride;

        id recTypeID = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('Street Contact - bedded down').RecordTypeId; 
        DateTime Now = DateTime.now();
        Timeline_Event__c TimelineEvent1;
         
        System.runAs(usr) {
                TimelineEvent1 = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Street Contact - Bedded Down',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Now,
                Project_Team__c = usr.Default_Project_Id__c,
                Borough_Street_Site__c = 'Test Timeline Event',
                RecordTypeId = recTypeID,
                Private_notes_CSTM__c = 'Some CSTM Notes'    
            );

            insert TimelineEvent1;
    
            test.setCurrentPage(pageRef);  
            test.startTest();
            StreetContactTimelineEventOverride  testController = new StreetContactTimelineEventOverride(); 
            pageRef.getParameters().put('retURL', '/' +Client.Id);       
            pageRef.getParameters().put('recordType', recTypeID); 
            
            string sTest = testController.url;
            system.assert(sTest.length() > 0);   
        }

    }
}