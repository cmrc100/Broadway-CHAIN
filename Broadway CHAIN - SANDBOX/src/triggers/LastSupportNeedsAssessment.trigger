trigger LastSupportNeedsAssessment on Support_Needs_Assessment__c( after insert, after update )
{
    List<Id> accountIds = new List<Id>();
	List<Account> accountUpdates = new List<Account>();
	
	// Loop over Support Needs Assessment records in this trigger and capture the account ids if they are set.
	for( Support_Needs_Assessment__c ThisSupportNeedsAssessment : Trigger.new )
    {
        if( ThisSupportNeedsAssessment.Client2__c != null ) // Client__c refers to the Contact; Client2__c refers to the Account
        {
        	accountIds.add( ThisSupportNeedsAssessment.Client2__c );
        }
    }
    
    // If we have account id after looping over records query Accounts and last Support Needs Assessment record for each Account
    if( !accountIds.isEmpty() )
    {
    	// Loop over contacts
    	for( Account ThisAccount : [SELECT Id, Date_Last_Support_Needs_Assessment__pc, (SELECT Assessment_date__c From Support_Needs_Assessments__r ORDER BY Assessment_Date__c DESC) FROM Account WHERE Id IN :accountIds] )
    	{
    		// If the 'Date Last Support Needs Assessment' field is not set to the same date as the last Support Needs Assessment record for this account, update the value to the correct date and add account to the update List 
    		if( !ThisAccount.Support_Needs_Assessments__r.isEmpty() && ThisAccount.Date_Last_Support_Needs_Assessment__pc != ThisAccount.Support_Needs_Assessments__r.get( 0 ).Assessment_date__c )
    		{
    			ThisAccount.Date_Last_Support_Needs_Assessment__pc = ThisAccount.Support_Needs_Assessments__r.get( 0 ).Assessment_date__c;
    			accountUpdates.add( ThisAccount );
    		}
    	}
    	
    	// Update any contacts with an updated date
    	if( !accountUpdates.isEmpty() )
    	{
    		update accountUpdates;
    	}
    }
}