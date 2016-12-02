@isTest
private class Test_OutcomeStarChart {


    public static testMethod void testOutcomeStarChartClass()
    {

       Campaign c = new Campaign(
            Name = 'CSTM - Advice and Housing', Borough__c = 'Croydon'
        );
        insert c;  

        User u = new User(
            Username = 'tu@br.ie', Email = 'tu@br.ie', FirstName = 'Test',
            LastName = 'User', Alias = 'tu', TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_IE_EURO', EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US', ProfileId = [Select Id From Profile Where Name = 'System Administrator'].Id,
            Default_Project_Name__c = c.Name,
            Default_Project_Id__c = c.Id
        );
        
        System.runAs(u) {



            Account a = new Account(
                FirstName = 'Test',
                LastName = 'Account',
                RecordTypeId = [Select Id From RecordType Where Name = 'Client Account'].Id

            );
            insert a;
            Id osId = [Select Id From RecordType Where Name = 'Outcome Star'].Id;
            
            a = [Select PersonContactId, Id From Account Where Id = :a.Id];
            
            OutcomeStarChart chart = new OutcomeStarChart();
            System.assertEquals(true, chart.getAccountIDEmpty());
            System.assertEquals(true, chart.getSupportListEmpty());
            System.assertEquals('[[0]]', chart.StaffRows);
            System.assertEquals('[[0]]', chart.ClientRows);
            
            chart.AccountID = a.PersonContactId;
            System.assertEquals(false, chart.getAccountIDEmpty());
            chart.filter();
            chart.getRowData();
            
            Support_Needs_Lifestyle__c support = new Support_Needs_Lifestyle__c(
                Client__c = a.PersonContactId,
                RecordTypeId = osId                
            );
            insert(support);
            
            support = [Select Id, Assessment_date__c From Support_Needs_Lifestyle__c Where Id = :support.Id];
            
            chart.Selected.add(support.id);
            chart.filter();
            chart.getRowData();
            System.assertEquals(false, chart.getSupportListEmpty());
            System.assertEquals('[[0,"Outcome Star ' + support.Assessment_date__c.format() + '"],["Substance Use",0],["Social Networks & Relationships",0],["Self-Care/Living Skills",0],["Physical Health",0],["Offending Notes",0],["Motivation/Taking Responsibility",0],["Mental Well Being",0],["Meaningful Use of Time",0],["Managing Tenancy & Accommodation",0],["Managing Money & Personal Admin",0]]', chart.StaffRows);
            System.assertEquals('[[0,"Outcome Star ' + support.Assessment_date__c.format() + '"],["Substance Use",0],["Social Networks & Relationships",0],["Self-Care/Living Skills",0],["Physical Health",0],["Offending Notes",0],["Motivation/Taking Responsibility",0],["Mental Well Being",0],["Meaningful Use of Time",0],["Managing Tenancy & Accommodation",0],["Managing Money & Personal Admin",0]]', chart.ClientRows);
            
            delete support;
            
            support = new Support_Needs_Lifestyle__c(
                Substance_Use_Staff__c = '10',
                Social_Networks_Relationships_Staff__c = '1',
                Self_Care_Living_Skills_Staff__c = '2',
                Physical_Health_Staff__c = '3',
                Offending_Staff__c = '4',
                Motivation_Taking_Responsibility_Staf__c = '5',
                Mental_Well_Being_Staff__c = '6',
                Meaningful_Use_of_Time_Staff__c = '7',
                Managing_Tenancy_Accommodation_Staff__c = '8',
                Managing_Money_Personal_Admin_Staff__c = '9',
                Substance_Use_Client__c = '1',
                Social_Networks_Relationships_Client__c = '2',
                Self_Care_Living_Skills_Client__c = '3',
                Physical_Health_Client__c = '4',
                Offending_Client__c = '5',
                Motivation_Taking_Responsibility_Client__c = '6',
                Mental_Well_Being_Client__c = '7',
                Meaningful_Use_of_Time_Client__c = '8',
                Managing_Tenancy_Accommodation_Client__c = '9',
                Managing_Money_Personal_Admin_Client__c = '10',
                Client__c = a.PersonContactId,
                RecordTypeId = osId
            );
            insert(support);
            
            support = [Select Id, Assessment_date__c From Support_Needs_Lifestyle__c Where Id = :support.Id];
            
            chart.Selected.add(support.id);
            chart.filter();
            chart.getRowData();
            System.assertEquals(false, chart.getSupportListEmpty());
            System.assertEquals('[[0,"Outcome Star ' + support.Assessment_date__c.format() + '"],["Substance Use",10],["Social Networks & Relationships",1],["Self-Care/Living Skills",2],["Physical Health",3],["Offending Notes",4],["Motivation/Taking Responsibility",5],["Mental Well Being",6],["Meaningful Use of Time",7],["Managing Tenancy & Accommodation",8],["Managing Money & Personal Admin",9]]', chart.StaffRows);
            System.assertEquals('[[0,"Outcome Star ' + support.Assessment_date__c.format() + '"],["Substance Use",1],["Social Networks & Relationships",2],["Self-Care/Living Skills",3],["Physical Health",4],["Offending Notes",5],["Motivation/Taking Responsibility",6],["Mental Well Being",7],["Meaningful Use of Time",8],["Managing Tenancy & Accommodation",9],["Managing Money & Personal Admin",10]]', chart.ClientRows);
        }
    }
    
}