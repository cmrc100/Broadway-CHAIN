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
private class AttachmentChangeTriggerHandlerTest {

    static testMethod void myUnitTest() {

        User usr = [Select Default_Project_Id__c from User where id =: UserInfo.getUserId()];                   
        // Create client account to use with the timeline events and client alerts.
        Account Client = new Account(LastName = 'Testing123', RecordType = new RecordType( Name = 'Client Account' ));
        insert Client;
        
        Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];

        Timeline_Event__c te = new Timeline_Event__c(
            Client__c = Client.PersonContactId,
            Event__c = 'Accommodation Stay',
            Creating_User_Organisation__c = 'CSTM',
            Date__c = Date.today(),
            Project_Team__c = usr.Default_Project_Id__c
        );
        insert te;
        
        SIB_Verification_Accommodation__c sib1 = new SIB_Verification_Accommodation__c(Timeline_Event__c = te.Id,
                                                                                        Date__c = system.today());
        
        insert sib1;

        
        test.startTest();
        Attachment att1 = new Attachment(Name='test.jpg', ParentId = sib1.Id, body = blob.valueOf('test1'));
        insert att1;
        sib1 = [select id, Attachments__c from SIB_Verification_Accommodation__c where id = :sib1.Id];
        system.assertEquals(sib1.Attachments__c, true);
        delete att1;
        sib1 = [select id, Attachments__c from SIB_Verification_Accommodation__c where id = :sib1.Id];
        system.assertEquals(sib1.Attachments__c, false);
        
        Attachment att2 = new Attachment(Name='test2.jpg', ParentId = sib1.Id, body = blob.valueOf('test2'));
        insert att2;
        
        sib1 = [select id, Attachments__c from SIB_Verification_Accommodation__c where id = :sib1.Id];
        system.assertEquals(sib1.Attachments__c, true);
        
        sib1.Attachments__c = false;
        update sib1;
        
        AttachmentChangeTriggerHandler.updateAllAttachmentFlags();
        sib1 = [select id, Attachments__c from SIB_Verification_Accommodation__c where id = :sib1.Id];
        system.assertEquals(sib1.Attachments__c, true);        
        
                
        //SIB_Verification_Employment__c sib2 = new SIB_Verification_Employment__c();
        //SIB_Verification_Qualifications__c sib3 = new SIB_Verification_Qualifications__c();
        //SIB_Verification_Reconnections__c sib4 = new SIB_Verification_Reconnections__c();
        //SIB_Verification_Self_emp_Vol__c sib5 = new SIB_Verification_Self_emp_Vol__c();
    
    
        test.stopTest();
        
    
    
    }
}