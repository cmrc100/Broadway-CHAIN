trigger OwnershipChange on Timeline_Event__c (after insert)
{
//System.Debug('#########DG###########');
    Account a = new Account();
    Contact c = new Contact();
    Map<Id,Account> accounts = new Map<Id,Account>();
    // 15/03/2011 - KMcH - Changed accounts from list to a map to ensure that an account is only updated once.
    
    List<Id> contactIds = new List<Id>();
    Map<Id,Contact> contacts = new Map<Id,Contact>();
    
    // Looping over trigger to capture contact ids for contacts we need to query
    for( Timeline_Event__c t : Trigger.new )
    {
        contactIds.add( t.Client__c );
    }
    
    // Querying all contacts in one SOQL query
    for( Contact ThisContact : [SELECT Id,Account.Id, Account.Ownership FROM Contact WHERE Id IN :contactIds] )
    {
        // Adding contacts to map for reference later
        contacts.put( ThisContact.Id, ThisContact );
    }
    
    for( Timeline_Event__c t : Trigger.new )
    {
        if( 'Street Contact' == t.Encounter_Type__c )
        {
            // Retrieve Account from contact map
            a = contacts.get( t.Client__c ).Account;
            a.Ownership = 'Public';
//System.Debug('#########DG###########');
//System.Debug(a);
            if( !accounts.containsKey( a.Id ) ) // 15/03/2011 - KMcH - Check if account is already being updated
            {
                accounts.put( a.Id, a ); // 15/03/2011 - KMcH - Put rather than add for map
            }
        }
    }
    
    if( accounts.size() > 0 )
    {
        update accounts.values(); // 15/03/2011 - KMcH - get values from Map for updating
    }
//System.Debug('#########DG###########');
}