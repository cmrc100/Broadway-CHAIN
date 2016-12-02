/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ClientTriggerHelperTest {
    
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
            test.startTest();
                insert TimelineEvent1;
            test.stopTest();
        }   

        TimelineEvent1 = [select Private_notes_Westminster__c, Private_notes_CSTM__c from Timeline_Event__c
                            where Id = :TimelineEvent1.Id];
                            
    //  system.assertEquals(TimelineEvent1.Private_notes_Westminster__c, TimelineEvent1.Private_notes_CSTM__c);                 

    }
}