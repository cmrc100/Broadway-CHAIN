@isTest
private class ownershipChangeTest
{ 
   public static testMethod void testSumOfHours() 
   {  
       Account a = new Account();
       a.FirstName = 'Testy';
       a.LastName = 'McTest';
       a.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Client Account'][0].Id;
       insert a;
       
       Contact c = [SELECT Id FROM Contact WHERE AccountId = :a.Id][0];
       
       Timeline_Event__c t = new Timeline_Event__c();
       t.Client__c = c.id;
       t.Encounter_Type__c = 'Street Contact';
       insert t;  
   }
}