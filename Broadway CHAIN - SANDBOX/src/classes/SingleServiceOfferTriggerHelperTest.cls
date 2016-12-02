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
private class SingleServiceOfferTriggerHelperTest {

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
                
    
            Account Client = new Account(LastName = 'Nexus451', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'NLOS Assessment Hub');
            insert Client;
            
            Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
            
            NSNO_Event__c NSNOEvent = new NSNO_Event__c(Client__c = Client.PersonContactId, Rough_sleeping_status__c = 'New rough sleeper');
            insert NSNOEvent;
                
            Contact contact = [SELECT Id,  Special_Action__c, Date_NSNO_offer_made__c, 
                                        Team_making_single_service_offer__c,
                                        Offer_Outcome__c 
                                        FROM contact WHERE Id = :Client.PersonContactId];
               
            DateTime Now = DateTime.now();
            
            id NLOSRecordTypeID = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('NLOS Referrals').RecordTypeId; 
            
            Timeline_Event__c TimelineEvent1 = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Accommodation Stay',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Now,
                Project_Team__c = usr.Default_Project_Id__c,
                Borough_Street_Site__c = 'Test Timeline Event',
                RecordTypeId = NLOSRecordTypeID,
                Accommodation__c = c.Id,
                Arrival_Date__c = system.today(),
                NLOS_Hub_Room_Number__c = 'Test1',
                Reason_brought_to_NLOS__c = 'For further assessment',
                Direct_transfer_to_NLOS_accommodation__c = 'Yes'                
            );
            insert TimelineEvent1;          
                
            TimelineEvent1 = [SELECT Id, Ward__c FROM Timeline_Event__c WHERE Id = :TimelineEvent1.Id];
    
                       
           Timeline_Event__c TimelineEvent2 = new Timeline_Event__c(
                Client__c = Client.PersonContactId,
                Event__c = 'Accommodation Stay',
                Creating_User_Organisation__c = 'CSTM',
                Date__c = Now,
                Project_Team__c = usr.Default_Project_Id__c,
                Borough_Street_Site__c = 'Test Timeline Event',
                RecordTypeId = NLOSRecordTypeID,
                Accommodation__c = c.Id,
                Arrival_Date__c = system.today(),
                NLOS_Hub_Room_Number__c = 'Test2',
                Reason_brought_to_NLOS__c = 'For further assessment',
                Direct_transfer_to_NLOS_accommodation__c = 'Yes'    
                
            );
            insert TimelineEvent2;
    
            //create Single Service Offer
            
            Single_Service_Offer__c sso1 = new Single_Service_Offer__c(Date_offer_made__c = system.today(),
                                                                        Team_making_SSO__c = 'Team for Test 1',
                                                                        Single_Service_Offer__c = 'The first Test',
                                                                        Offer_outcome__c = 'Accepted', 
                                                                        Timeline_Event__c = TimelineEvent1.Id,
                                                                        Client__c = Client.PersonContactId,
                                                                        NSNO_Event__c = NSNOEvent.Id);
            test.startTest();
                insert sso1;
            
                contact = [SELECT Id, Special_Action__c, Date_NSNO_offer_made__c, 
                                        Team_making_single_service_offer__c,
                                        Offer_Outcome__c 
                                        FROM contact WHERE Id = :Client.PersonContactId];           
                
                NSNOEvent = [select Count_of_SSOs__c from NSNO_Event__c where Id = :NSNOEvent.Id];
                system.assertEquals(NSNOEvent.Count_of_SSOs__c, 1);
                
                system.assertEquals(contact.Special_Action__c, sso1.Single_Service_Offer__c);
                system.assertEquals(contact.Team_making_single_service_offer__c, sso1.Team_making_SSO__c);
                system.assertEquals(contact.Offer_Outcome__c, sso1.Offer_outcome__c);
              
                
                // insert another SSO and check Contact values updated to most recent record values
    
                Single_Service_Offer__c sso2 = new Single_Service_Offer__c(Date_offer_made__c = system.today(),
                                                                        Team_making_SSO__c = 'Team for Test 2',
                                                                        Single_Service_Offer__c = 'The second Test',
                                                                        Offer_outcome__c = 'Rejected', 
                                                                        Timeline_Event__c = TimelineEvent1.Id,
                                                                        Client__c = Client.PersonContactId,
                                                                        NSNO_Event__c = NSNOEvent.Id);    
                insert sso2;
                
                contact = [SELECT Id, Special_Action__c, Date_NSNO_offer_made__c, 
                            Team_making_single_service_offer__c,
                            Offer_Outcome__c 
                            FROM contact WHERE Id = :Client.PersonContactId];           
                
                NSNOEvent = [select Count_of_SSOs__c from NSNO_Event__c where Id = :NSNOEvent.Id];
                system.assertEquals(NSNOEvent.Count_of_SSOs__c, 2);
                
                system.assertEquals(contact.Special_Action__c, sso2.Single_Service_Offer__c);
                system.assertEquals(contact.Team_making_single_service_offer__c, sso2.Team_making_SSO__c);
                system.assertEquals(contact.Offer_Outcome__c, sso2.Offer_outcome__c);
                     
                
                // Check SSO Counter on Timeline event
                TimelineEvent1 = [SELECT Id, SSO_Count__c FROM Timeline_Event__c WHERE Id = :TimelineEvent1.Id];
                system.assertEquals(2, TimelineEvent1.SSO_Count__c);
                
                // update timeline on SSO and recheck counter
                sso2 = [select Timeline_Event__c from Single_Service_Offer__c where Id =:sso2.Id];
                sso2.Timeline_Event__c = TimelineEvent2.Id;
                update sso2;
                
                TimelineEvent1 = [SELECT Id, SSO_Count__c FROM Timeline_Event__c WHERE Id = :TimelineEvent1.Id];
                system.assertEquals(1, TimelineEvent1.SSO_Count__c);
                            
                // delete sso's and check client values are blanked out
                list<Single_Service_Offer__c> ssoList = [select id from Single_Service_Offer__c where Client__c = :contact.Id];                                                             
                delete ssoList;
    
                contact = [SELECT Id, Special_Action__c, Date_NSNO_offer_made__c, 
                            Team_making_single_service_offer__c,
                            Offer_Outcome__c
                            FROM contact WHERE Id = :Client.PersonContactId];   
                                        
                system.assert(string.isBlank(contact.Special_Action__c));
                system.assert(string.isBlank(contact.Team_making_single_service_offer__c));
                system.assert(string.isBlank(contact.Offer_Outcome__c));
                          
    
                // Check SSO Counter on Timeline event
                TimelineEvent1 = [SELECT Id, SSO_Count__c FROM Timeline_Event__c WHERE Id = :TimelineEvent1.Id];
                system.assertEquals(0, TimelineEvent1.SSO_Count__c);
                
                // run batch class method for coverage
                string soql = 'select Id, SSO_Count__c from Timeline_event__c where Id= ' + '\'' + TimelineEvent1.Id + '\'';
                SingleServiceOfferBatchProcess ssoBatch = new SingleServiceOfferBatchProcess(soql);
                Database.executeBatch(ssoBatch);
                
            test.stopTest();
        
        }
        
    }
    

    
    
}