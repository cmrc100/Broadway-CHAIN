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
@isTest (SeeAllData=true)
private class Test_ReferralsTriggerHandler {

    
    static testMethod void unitTestTrigger() {
    

       //Insert test referral
        Referrals__c ref = new Referrals__c(Referral_Date_time__c = system.now());
        RecordType rt = [select Id from RecordType where Name = 'Streetlink Referrals' and SobjectType = 'referrals__c' limit 1];
        ref.RecordTypeId = rt.Id;
        Local_Authority__c la = [Select Id, Name from local_authority__c where name = 'Walsall Borough Council'];
        ref.Local_authority__c = la.Id;
        ref.Referrer_type__c = 'Self';
        ref.Google_Maps_URL__c = 'http://maps.google.co.uk/?q=51.582029929065825,-0.08934974670410156&z=10';
        ref.sleeping_site_details__c = 'on the floor';
        
        test.startTest();
        insert ref;
        string refId = ref.Id;
        
        ref = [Select Referrer_type__c, sleeping_site_details__c from Referrals__c where id = :refId];
        
        system.assertEquals(ref.sleeping_site_details__c, 'on the floor');

        list<PartnerNetworkRecordConnection> pnList = [SELECT p.Status, p.LocalRecordId, p.ConnectionId 
                                          FROM PartnerNetworkRecordConnection p              
                                          WHERE p.LocalRecordId = :refId];
        
        system.assertEquals(pnList.size(), 1);                                           
        
        PartnerNetworkConnection pn = [Select id, connectionName, createdById from PartnerNetworkConnection where id = :pnList[0].ConnectionId ];
        string s = ConnectionHelper.getConnectionOwnerId(pn.connectionName);
        
        system.assertEquals(s, pn.createdById );
        
        test.stopTest();
    
    
    }
    
    
}