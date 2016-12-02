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
private class Test_HotspotTriggerHelper {

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
            
  
          Country_or_area__c Area = new Country_or_area__c(Name = 'Hotspot', Hotspot_Status__c = 'test status', Action_Plan__c = 'test plan', 
                                                           RecordType = new RecordType( Name = 'Hotspot' ));
          insert Area;
                      
          Area = [SELECT Id,  Hotspot_Status__c, Action_Plan__c 
                                      FROM Country_or_area__c WHERE Id = :Area.Id];
             
          DateTime Now = DateTime.now();
            
          id StatusRecordTypeID = Schema.SObjectType.Location_actions__c.RecordTypeInfosByName.get('Status Update').RecordTypeId; 
          id ActionRecordTypeID = Schema.SObjectType.Location_actions__c.RecordTypeInfosByName.get('Action Plan').RecordTypeId;           
            
                   
          Location_actions__c Hotspot1 = new Location_actions__c(
              Location__c = Area.Id,
              Date_time__c = Now - 10,
              Status__c = 'Under investigation - active',
              RecordType = new RecordType (id=StatusRecordTypeID)
          );
          
          test.startTest();
          
          insert Hotspot1;          
              
          Hotspot1 = [SELECT Status__c FROM Location_actions__c WHERE Id = :Hotspot1.Id];
         
          Location_actions__c ActionPlan1 = new Location_actions__c(
              Location__c = Area.Id,
              Date_time__c = Now - 10,
              Action_Plan__c = 'Test Action Plan TEST',
              RecordType = new RecordType(id=ActionRecordTypeID)
          );
          insert ActionPlan1;          
              
          ActionPlan1 = [SELECT Action_Plan__c FROM Location_actions__c WHERE Id = :ActionPlan1.Id];                
      
              system.assertEquals(Area.Hotspot_Status__c, 'test status');
              system.assertEquals(Area.Action_Plan__c, 'test plan');
                 
              
              // insert another two location actions and check Country or Area values updated to most recent record values
              
          Location_actions__c Hotspot2 = new Location_actions__c(
              Location__c = Area.Id,
              Date_time__c = Now,
              Status__c = 'Under investigation - inactive',
              RecordType = new RecordType (id=StatusRecordTypeID)
          );
          insert Hotspot2;          
              
          Hotspot2 = [SELECT Status__c FROM Location_actions__c WHERE Id = :Hotspot2.Id];
         
          Location_actions__c ActionPlan2 = new Location_actions__c(
              Location__c = Area.Id,
              Date_time__c = Now,
              Action_Plan__c = 'Test Action Plan 2 TEST',
              RecordType = new RecordType (id=ActionRecordTypeID)
          );
          insert ActionPlan2;          
              
          ActionPlan2 = [SELECT Action_Plan__c FROM Location_actions__c WHERE Id = :ActionPlan2.Id];     
                        
      
              system.assertEquals(Area.Hotspot_Status__c, 'test status');
              system.assertEquals(Area.Action_Plan__c, 'test plan');
              
          test.stopTest();
        
        }
        
    }
    

    
    
}