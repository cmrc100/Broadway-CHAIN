@isTest
private class testTrigger_LastSupportNeedsAssessment
{
	static testMethod void testTrigger()
	{
		// Add new Person Account
		Account a = new Account(FirstName='Testy',LastName='McTest',RecordTypeId=[Select r.Id From RecordType r WHERE IsPersonType = TRUE AND IsActive = TRUE][0].Id);
		insert a;
		
		// Add multiple support needs assessments
		List<Support_Needs_Assessment__c> supportNeedsAssessmentRecords = new List<Support_Needs_Assessment__c>();
		Support_Needs_Assessment__c sna1 = new Support_Needs_Assessment__c( Assessment_Date__c = Date.newinstance(2010, 10, 17), Client2__c = a.id );
		supportNeedsAssessmentRecords.add( sna1 );
        Support_Needs_Assessment__c sna2 = new Support_Needs_Assessment__c( Assessment_Date__c = Date.newinstance(2011, 1, 9), Client2__c = a.id );
        supportNeedsAssessmentRecords.add( sna2 );
        Support_Needs_Assessment__c sna3 = new Support_Needs_Assessment__c( Assessment_Date__c = Date.newinstance(2010, 9, 23), Client2__c = a.id );
        supportNeedsAssessmentRecords.add( sna3 );
		insert supportNeedsAssessmentRecords;
		
		// Query Date Last Support Needs Assessment field from Account
		a = [SELECT Date_Last_Support_Needs_Assessment__pc FROM Account WHERE Id = :a.Id];
		
		// Check that Date Last Support Needs Assessment field equals date of latest Support Needs Assessment (sna2 above)
		System.assertEquals( a.Date_Last_Support_Needs_Assessment__pc, Date.newinstance(2011, 1, 9) );
	}
}