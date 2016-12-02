public with sharing class GenerateAccountTimelineEventURL
{
    private Account CurrentAccount;
    
    private Map<String,String> parameters;
    
    public GenerateAccountTimelineEventURL( ApexPages.StandardController stdController )
    {
        // Capture the page parameters
        this.parameters = ApexPages.currentPage().getParameters();
        this.CurrentAccount = [SELECT Id, Name, PersonContactId FROM Account WHERE Id = :stdController.getId()];
    }
    
    public PageReference URLPrepopulateRedirect()
    {
        PageReference createTimelineEvent = new PageReference( '/a0D/e' );
        createTimelineEvent.getParameters().put( 'Name', 'Name' );
//        createTimelineEvent.getParameters().put( 'nooverride', 'true' );
        createTimelineEvent.getParameters().put( 'RecordType', this.parameters.get( 'RecordType' ) );
        createTimelineEvent.getParameters().put( '00N80000004Gn8J', this.parameters.get( 'EncounterType' ) );
        createTimelineEvent.getParameters().put( '00N80000004Gn99', this.parameters.get( 'Event' ) );
        createTimelineEvent.getParameters().put( 'CF00N80000004GsgP', this.CurrentAccount.Name );
        createTimelineEvent.getParameters().put( 'CF00N80000004GsgP_lkid', this.CurrentAccount.PersonContactId );
        createTimelineEvent.getParameters().put( 'CF00N80000004Gn8N', this.parameters.get( 'ProjectTeam' ) );
        createTimelineEvent.getParameters().put( 'CF00N80000004Gn8N_lkid', this.parameters.get( 'ProjectTeamId' ) );
        
        // Return (redirect to) page reference
        return createTimelineEvent;
    }
    
    /***** TEST METHODS *****/
    private static TestMethod Void Test_BanklineProductFamilyUrl()
    {
        Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Barnet'
        );
        insert c;
        
        User u = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = c.Id
        );
        insert u;
        
        System.runAs(u)
        {
            Account NewAccount = New Account(FirstName='Luke',LastName='Mallon',PersonBirthdate=Date.Today().AddYears(-18),Gender__pc='Male',Ethnic_Origin__pc='White - Irish',Nationality__pc='Ireland (Republic of)');
            insert NewAccount;
            
            Account ThisAccount = [SELECT Id,Name,PersonContactId FROM Account WHERE Id = :NewAccount.Id];
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(ThisAccount);
            
            GenerateAccountTimelineEventURL URLTest = new GenerateAccountTimelineEventURL(stdController);
            PageReference TimelineEventURL = URLTest.URLPrepopulateRedirect();
            
            System.assertEquals(ThisAccount.Name, TimelineEventURL.getParameters().get('CF00N80000004GsgP'));
            System.assertEquals(ThisAccount.PersonContactId, TimelineEventURL.getParameters().get('CF00N80000004GsgP_lkid'));
        }
    }
}