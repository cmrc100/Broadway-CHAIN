/**
 * ClientReferral
 *
 * @category Broadway
 * @package  Broadway
 * @author   Luke Mallon <luke.mallon@nexus451.com>
 * @license  Copyright Nexus451.com
 */

/**
 * This class is used for creating a Client from a Referral using the First Contact Form
 * or creating a Referral from the Client using the standard Referral form.
 *
 * @category Broadway
 * @package  Broadway
 * @author   Luke Mallon <luke.mallon@nexus451.com>
 * @license  Copyright Nexus451.com
 */
public with sharing class ClientReferral
{
    private Map<String,String> parameters;
    private ApexPages.StandardController controller;
    
    public ClientReferral(ApexPages.StandardController stdController)
    {
        this.parameters = ApexPages.currentPage().getParameters();
        this.controller = stdController;
    }
    
    public PageReference getReferral()
    {
        PageReference newClient = new PageReference('/apex/firstcontactpage_client_1');
        
        Referrals__c ref = [SELECT Id, Name, First_name__c, Last_name__c, Birthdate__c, DOB_estimated__c, Gender__c, Ethnic_Origin__c, Street_name__c FROM Referrals__c WHERE Id = :this.controller.getId()];
        
        newClient.getParameters().put('referral','true');
        newClient.getParameters().put('referralId',ref.Id);
        newClient.getParameters().put('firstName',ref.First_name__c);
        newClient.getParameters().put('lastName',ref.Last_name__c);
        
        if (ref.Birthdate__c != null) {
            newClient.getParameters().put('birthDate', ref.Birthdate__c.year() + '-' + ref.Birthdate__c.month() + '-' + ref.Birthdate__c.day());
        }
        
        newClient.getParameters().put('dobEstimated', String.valueOf(ref.DOB_estimated__c));
        newClient.getParameters().put('gender', ref.Gender__c);
        newClient.getParameters().put('ethnicOrigin', ref.Ethnic_Origin__c);
        newClient.getParameters().put('streetName', ref.Street_name__c);
        
        return newClient;
    }
    
    public PageReference getClient()
    {
        PageReference newReferral = new PageReference('/setup/ui/recordtypeselect.jsp');
        
        Account acc = [SELECT Id, FirstName, LastName, PersonBirthdate, DOB_Estimated__pc, Gender__pc, Ethnic_Origin__pc, ClientID__pc FROM Account WHERE Id = :this.controller.getId()];
        
        newReferral.getParameters().put('ent', '01IC00000012ABH');
        newReferral.getParameters().put('retURL', '/a0K/o');
        newReferral.getParameters().put('save_new_url', '/a0K/e?retURL=/a0K/e&00NC0000005Cybc=' + acc.FirstName +'&00NC0000005Cybg=' + acc.LastName
            + '&00NC0000005Cybl=' + acc.PersonBirthdate.day() + '/' + acc.PersonBirthdate.month() + '/' + acc.PersonBirthdate.year()
            + '&00Nc0000000L2PU=' + acc.DOB_Estimated__pc + '&00NC0000005Cybv=' + acc.Gender__pc + '&00NC0000005Cyc5=' + EncodingUtil.urlEncode(acc.Ethnic_Origin__pc + '&00NC0000005DMbS=' + acc.ClientID__pc, 'UTF-8'));
        
        return newReferral;
    }
    
    /***** TEST METHODS *****/
    private static TestMethod Void Test_ClientReferral()
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
            
            Account ThisAccount = [SELECT Id,FirstName,PersonContactId FROM Account WHERE Id = :NewAccount.Id];
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(ThisAccount);
            
            ClientReferral URLTest = new ClientReferral(stdController);
            PageReference URL = URLTest.getClient();
            
            Referrals__c NewReferral = New Referrals__c(First_Name__c='Luke',Last_Name__c='Mallon');
            insert NewReferral;
            
            Referrals__c ThisReferral = [SELECT Id,First_Name__c,Last_Name__c FROM Referrals__c WHERE Id = :NewReferral.Id];
            
            stdController = new ApexPages.StandardController(ThisReferral);
            
            URLTest = new ClientReferral(stdController);
            URL = URLTest.getReferral();
            
            System.assertEquals(ThisReferral.First_Name__c, URL.getParameters().get('firstName'));
            System.assertEquals(ThisReferral.Last_Name__c, URL.getParameters().get('lastName'));
        }
    }
}