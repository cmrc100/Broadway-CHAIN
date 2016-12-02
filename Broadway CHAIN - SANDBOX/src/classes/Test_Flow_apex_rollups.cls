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
@isTest(SeeAllData=true) 
private class Test_Flow_apex_rollups {

    static testMethod void unitTest() {

             
         Campaign c = new Campaign(
            Name = 'Assessment Hub', Borough__c = 'Barnet'
        );
        insert c;
        
        User usr = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert usr;

        System.runAs(usr) {
    
            //Create client account to use with the timeline events and client alerts.
            Account Client = new Account(LastName = 'CHAIN', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'CSTM - Advice & Housing', Count_of_new_rs_flow_forms__pc = 1);
            
            insert Client;
            
            Client = [SELECT Id, PersonContactId, Count_of_new_rs_flow_forms__pc FROM Account WHERE Id = :Client.Id];
            
            // Retrieve location actions record type Ids for New rough sleeper
            id NewRecordTypeID = Schema.SObjectType.Flow_information__c.RecordTypeInfosByName.get('New rough sleeper').RecordTypeId; 
  
            
            Test.startTest();
            
            Flow_information__c Flow = new Flow_information__c (
                Client__c = Client.PersonContactId,
                Last_longer_term_place_settled_base__c = 'Hospital',
                Primary_reason_for_leaving__c = 'Asked to leave',
                Location_last_settled_base_UK__c = 'Angus Council',
                RecordType = New RecordType (id=NewRecordTypeID)
            );
            
            insert Flow;
            
            system.assertEquals(Client.Count_of_new_rs_flow_forms__pc, 1);
            
            test.stopTest();
            
        }
    }
}