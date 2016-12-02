public with sharing class OutcomeStarChart
{
    public List<Support_Needs_Lifestyle__c> SupportList{get;set;}
    public String[] Selected{get;set;}
    public String StaffRows{get;set;}
    public String ClientRows{get;set;}
    @TestVisible String Message;
    @TestVisible String AccountID;
    
    public string accountName {get; private set;}
    
    public OutcomeStarChart()
    {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        SupportList = new List<Support_Needs_Lifestyle__c>();
        Selected = new String[]{};
        
        if (params.containsKey('id')) {
            AccountID = params.get('id');
            Account a;
            
            try {
                a = [Select Id, PersonContactId, Name From Account Where Id = :AccountID];
                accountName = a.Name;
            } catch (Exception e) {
                a = new Account();
            }
            
            if (null != a.PersonContactId) {
                AccountID = a.PersonContactId;
            } else {
                AccountID = null;
            }
        }
        
        if (null != AccountID || '' == AccountID) {
            Id RecordTypeId = [Select Id From RecordType Where Name = 'Outcome Star'].Id;
            
            SupportList = [Select s.Name, s.Substance_Use_Staff__c, s.Social_Networks_Relationships_Staff__c,
                s.Self_Care_Living_Skills_Staff__c, s.Physical_Health_Staff__c, s.Offending_Staff__c,
                s.Motivation_Taking_Responsibility_Staf__c, s.Mental_Well_Being_Staff__c,
                s.Meaningful_Use_of_Time_Staff__c, s.Managing_Tenancy_Accommodation_Staff__c,
                s.Managing_Money_Personal_Admin_Staff__c, s.Substance_Use_Client__c,
                s.Social_Networks_Relationships_Client__c, s.Self_Care_Living_Skills_Client__c,
                s.Physical_Health_Client__c, s.Offending_Client__c, s.Motivation_Taking_Responsibility_Client__c,
                s.Mental_Well_Being_Client__c, s.Meaningful_Use_of_Time_Client__c,
                s.Managing_Tenancy_Accommodation_Client__c, s.Managing_Money_Personal_Admin_Client__c, Assessment_date__c
                From Support_Needs_Lifestyle__c s Where s.Client__c = :AccountID And s.RecordTypeId = :RecordTypeId Order By Assessment_date__c ASC];
            
            for (Support_Needs_Lifestyle__c item : SupportList) {
                Selected.add(item.Id);
            }
        }
        
        getRowData();
    }
    
    public PageReference filter()
    {
        if (null != AccountID || '' == AccountID) {
            Id RecordTypeId = [Select Id From RecordType Where Name = 'Outcome Star'].Id;
            
            SupportList = [Select s.Name, s.Substance_Use_Staff__c, s.Social_Networks_Relationships_Staff__c,
                s.Self_Care_Living_Skills_Staff__c, s.Physical_Health_Staff__c, s.Offending_Staff__c,
                s.Motivation_Taking_Responsibility_Staf__c, s.Mental_Well_Being_Staff__c,
                s.Meaningful_Use_of_Time_Staff__c, s.Managing_Tenancy_Accommodation_Staff__c,
                s.Managing_Money_Personal_Admin_Staff__c, s.Substance_Use_Client__c,
                s.Social_Networks_Relationships_Client__c, s.Self_Care_Living_Skills_Client__c,
                s.Physical_Health_Client__c, s.Offending_Client__c, s.Motivation_Taking_Responsibility_Client__c,
                s.Mental_Well_Being_Client__c, s.Meaningful_Use_of_Time_Client__c,
                s.Managing_Tenancy_Accommodation_Client__c, s.Managing_Money_Personal_Admin_Client__c, Assessment_date__c
                From Support_Needs_Lifestyle__c s Where s.Client__c = :AccountID And s.RecordTypeId = :RecordTypeId Order By Assessment_date__c ASC];
        }
        
        getRowData();
        return null; 
    }
    
    public List<SelectOption> getItems()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        for (Support_Needs_Lifestyle__c item : SupportList) {
            options.add(new SelectOption(item.Id, 'Outcome Star ' + item.Assessment_date__c.format()));
        }
        
        return options;
    }
    
    public Boolean checkId(Id itemId)
    {
        for (String id : Selected) {
            if (id == itemId) {
                return true;
            }
        }
        
        return false;
    }
    
    public void getRowData()
    {
        StaffRows = '[[0';
        ClientRows = StaffRows;
        
        if (!SupportList.isEmpty()) {
            String Row1 = ',["Substance Use"';
            String Row2 = ',["Social Networks & Relationships"';
            String Row3 = ',["Self-Care/Living Skills"';
            String Row4 = ',["Physical Health"';
            String Row5 = ',["Offending Notes"';
            String Row6 = ',["Motivation/Taking Responsibility"';
            String Row7 = ',["Mental Well Being"';
            String Row8 = ',["Meaningful Use of Time"';
            String Row9 = ',["Managing Tenancy & Accommodation"';
            String Row10 = ',["Managing Money & Personal Admin"';
            String SubstanceUse = '';
            String SocialNetworksRelationships = '';
            String SelfCareLivingSkills = '';
            String PhysicalHealth = '';
            String Offending = '';
            String MotivationTakingResponsibility = '';
            String MentalWellBeing = '';
            String MeaningfulUseOfTime = '';
            String ManagingTenancyAccommodation = '';
            String ManagingMoneyPersonalAdmin = '';
            List<String> StringSplit = new List<String>();
            
            for (Support_Needs_Lifestyle__c SupportItem : SupportList) {
                if (checkId(SupportItem.Id)) {
                    StaffRows = StaffRows + ',"Outcome Star ' + SupportItem.Assessment_date__c.format() + '"';
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Substance_Use_Staff__c) {
                        StringSplit = SupportItem.Substance_Use_Staff__c.split('-');
                        SubstanceUse = StringSplit.get(0).replace(' ', '');
                    } else {
                        SubstanceUse = '';
                    }
                    
                    if ('' != SubstanceUse.trim()) {
                        row1 = row1 + ',' + SubstanceUse;
                    } else {
                        row1 = row1 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Social_Networks_Relationships_Staff__c) {
                        StringSplit = SupportItem.Social_Networks_Relationships_Staff__c.split('-');
                        SocialNetworksRelationships = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        SocialNetworksRelationships = '';
                    }
                    
                    if ('' != SocialNetworksRelationships.trim()) {
                        row2 = row2 + ',' + SocialNetworksRelationships;
                    } else {
                        row2 = row2 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Self_Care_Living_Skills_Staff__c) {
                        StringSplit = SupportItem.Self_Care_Living_Skills_Staff__c.split('-');
                        SelfCareLivingSkills = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        SelfCareLivingSkills = '';
                    }
                    
                    if ('' != SelfCareLivingSkills.trim()) {
                        row3 = row3 + ',' + SelfCareLivingSkills;
                    } else {
                        row3 = row3 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Physical_Health_Staff__c) {
                        StringSplit = SupportItem.Physical_Health_Staff__c.split('-');
                        PhysicalHealth = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        PhysicalHealth = '';
                    }
                    
                    if ('' != PhysicalHealth.trim()) {
                        row4 = row4 + ',' + PhysicalHealth;
                    } else {
                        row4 = row4 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Offending_Staff__c) {
                        StringSplit = SupportItem.Offending_Staff__c.split('-');
                        Offending = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        Offending = '';
                    }
                    
                    if ('' != Offending.trim()) {
                        row5 = row5 + ',' + Offending;
                    } else {
                        row5 = row5 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Motivation_Taking_Responsibility_Staf__c) {
                        StringSplit = SupportItem.Motivation_Taking_Responsibility_Staf__c.split('-');
                        MotivationTakingResponsibility = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        MotivationTakingResponsibility = '';
                    }
                    
                    if ('' != MotivationTakingResponsibility.trim()) {
                        row6 = row6 + ',' + MotivationTakingResponsibility;
                    } else {
                        row6 = row6 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Mental_Well_Being_Staff__c) {
                        StringSplit = SupportItem.Mental_Well_Being_Staff__c.split('-');
                        MentalWellBeing = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        MentalWellBeing = '';
                    }
                    
                    if ('' != MentalWellBeing.trim()) {
                        row7 = row7 + ',' + MentalWellBeing;
                    } else {
                        row7 = row7 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Meaningful_Use_of_Time_Staff__c) {
                        StringSplit = SupportItem.Meaningful_Use_of_Time_Staff__c.split('-');
                        MeaningfulUseOfTime = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        MeaningfulUseOfTime = '';
                    }
                    
                    if ('' != MeaningfulUseOfTime.trim()) {
                        row8 = row8 + ',' + MeaningfulUseOfTime;
                    } else {
                        row8 = row8 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Managing_Tenancy_Accommodation_Staff__c) {
                        StringSplit = SupportItem.Managing_Tenancy_Accommodation_Staff__c.split('-');
                        ManagingTenancyAccommodation = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        ManagingTenancyAccommodation = '';
                    }
                    
                    if ('' != ManagingTenancyAccommodation.trim()) {
                        row9 = row9 + ',' + ManagingTenancyAccommodation;
                    } else {
                        row9 = row9 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Managing_Tenancy_Accommodation_Staff__c) {
                        StringSplit = SupportItem.Managing_Money_Personal_Admin_Staff__c.split('-');
                        ManagingMoneyPersonalAdmin = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        ManagingMoneyPersonalAdmin = '';
                    }
                    
                    if ('' != ManagingMoneyPersonalAdmin.trim()) {
                        row10 = row10 + ',' + ManagingMoneyPersonalAdmin;
                    } else {
                        row10 = row10 + ',0';
                    }
                }
            }
            
            Row1 = Row1 + ']';
            Row2 = Row2 + ']';
            Row3 = Row3 + ']';
            Row4 = Row4 + ']';
            Row5 = Row5 + ']';
            Row6 = Row6 + ']';
            Row7 = Row7 + ']';
            Row8 = Row8 + ']';
            Row9 = Row9 + ']';
            Row10 = Row10 + ']';
            
            StaffRows = StaffRows + ']' + row1 + row2 + row3 + row4 + row5 + row6 + row7 + row8 + row9 + row10 + ']';
            
            Row1 = ',["Substance Use"';
            Row2 = ',["Social Networks & Relationships"';
            Row3 = ',["Self-Care/Living Skills"';
            Row4 = ',["Physical Health"';
            Row5 = ',["Offending Notes"';
            Row6 = ',["Motivation/Taking Responsibility"';
            Row7 = ',["Mental Well Being"';
            Row8 = ',["Meaningful Use of Time"';
            Row9 = ',["Managing Tenancy & Accommodation"';
            Row10 = ',["Managing Money & Personal Admin"';
            
            for (Support_Needs_Lifestyle__c SupportItem : SupportList) {
                if (checkId(SupportItem.Id)) {
                    ClientRows = ClientRows + ',"Outcome Star ' + SupportItem.Assessment_date__c.format() + '"';
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Substance_Use_Client__c) {
                        StringSplit = SupportItem.Substance_Use_Client__c.split('-');
                        SubstanceUse = StringSplit.get(0).replace(' ', '');
                    } else {
                        SubstanceUse = '';
                    }
                    
                    if ('' != SubstanceUse.trim()) {
                        row1 = row1 + ',' + SubstanceUse;
                    } else {
                        row1 = row1 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Social_Networks_Relationships_Client__c) {
                        StringSplit = SupportItem.Social_Networks_Relationships_Client__c.split('-');
                        SocialNetworksRelationships = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        SocialNetworksRelationships = '';
                    }
                    
                    if ('' != SocialNetworksRelationships.trim()) {
                        row2 = row2 + ',' + SocialNetworksRelationships;
                    } else {
                        row2 = row2 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Self_Care_Living_Skills_Client__c) {
                        StringSplit = SupportItem.Self_Care_Living_Skills_Client__c.split('-');
                        SelfCareLivingSkills = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        SelfCareLivingSkills = '';
                    }
                    
                    if ('' != SelfCareLivingSkills.trim()) {
                        row3 = row3 + ',' + SelfCareLivingSkills;
                    } else {
                        row3 = row3 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Physical_Health_Client__c) {
                        StringSplit = SupportItem.Physical_Health_Client__c.split('-');
                        PhysicalHealth = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        PhysicalHealth = '';
                    }
                    
                    if ('' != PhysicalHealth.trim()) {
                        row4 = row4 + ',' + PhysicalHealth;
                    } else {
                        row4 = row4 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Offending_Client__c) {
                        StringSplit = SupportItem.Offending_Client__c.split('-');
                        Offending = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        Offending = '';
                    }
                    
                    if ('' != Offending.trim()) {
                        Row5 = Row5 + ',' + Offending;
                    } else {
                        Row5 = Row5 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Motivation_Taking_Responsibility_Client__c) {
                        StringSplit = SupportItem.Motivation_Taking_Responsibility_Client__c.split('-');
                        MotivationTakingResponsibility = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        MotivationTakingResponsibility = '';
                    }
                    
                    if ('' != MotivationTakingResponsibility.trim()) {
                        Row6 = Row6 + ',' + MotivationTakingResponsibility;
                    } else {
                        Row6 = Row6 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Mental_Well_Being_Client__c) {
                        StringSplit = SupportItem.Mental_Well_Being_Client__c.split('-');
                        MentalWellBeing = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        MentalWellBeing = '';
                    }
                    
                    if ('' != MentalWellBeing.trim()) {
                        Row7 = Row7 + ',' + MentalWellBeing;
                    } else {
                        Row7 = Row7 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Meaningful_Use_of_Time_Client__c) {
                        StringSplit = SupportItem.Meaningful_Use_of_Time_Client__c.split('-');
                        MeaningfulUseOfTime = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        MeaningfulUseOfTime = '';
                    }
                    
                    if ('' != MeaningfulUseOfTime.trim()) {
                        Row8 = Row8 + ',' + MeaningfulUseOfTime;
                    } else {
                        Row8 = Row8 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Managing_Tenancy_Accommodation_Client__c) {
                        StringSplit = SupportItem.Managing_Tenancy_Accommodation_Client__c.split('-');
                        ManagingTenancyAccommodation = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        ManagingTenancyAccommodation = '';
                    }
                    
                    if ('' != ManagingTenancyAccommodation.trim()) {
                        Row9 = Row9 + ',' + ManagingTenancyAccommodation;
                    } else {
                        Row9 = Row9 + ',0';
                    }
                    
                    StringSplit = new List<String>();
                    
                    if (null != SupportItem.Managing_Money_Personal_Admin_Client__c) {
                        StringSplit = SupportItem.Managing_Money_Personal_Admin_Client__c.split('-');
                        ManagingMoneyPersonalAdmin = StringSplit.get(0).replaceAll(' ', '');
                    } else {
                        ManagingMoneyPersonalAdmin = '';
                    }
                    
                    if ('' != ManagingMoneyPersonalAdmin.trim()) {
                        row10 = row10 + ',' + ManagingMoneyPersonalAdmin;
                    } else {
                        row10 = row10 + ',0';
                    }
                }
            }
            
            Row1 = Row1 + ']';
            Row2 = Row2 + ']';
            Row3 = Row3 + ']';
            Row4 = Row4 + ']';
            Row5 = Row5 + ']';
            Row6 = Row6 + ']';
            Row7 = Row7 + ']';
            Row8 = Row8 + ']';
            Row9 = Row9 + ']';
            Row10 = Row10 + ']';
            
            ClientRows = ClientRows + ']' + row1 + row2 + row3 + row4 + row5 + row6 + row7 + row8 + row9 + row10 + ']';
        } else {
            ClientRows = ClientRows + ']]';
            StaffRows = StaffRows + ']]';
        }
    }
    
    public Boolean getSupportListEmpty()
    {
        return SupportList.isEmpty();
    }
    
    public Boolean getAccountIDEmpty()
    {
        return (null == AccountID || '' == AccountID.trim());
    }


/**    
    public static testMethod void testOutcomeStarChartClass()
    {
        User u = new User(
            Username = 'tu@br.ie', Email = 'tu@br.ie', FirstName = 'Test',
            LastName = 'User', Alias = 'tu', TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_IE_EURO', EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US', ProfileId = [Select Id From Profile Where Name = 'System Administrator'].Id
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
**/
    
}