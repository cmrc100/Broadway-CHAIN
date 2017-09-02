/*
###########################################################################
# Project Name..........: <<Broadway  >>
# File..................: <<testClass.cls >>
# Version...............: << >>
# Created by............: <<Gulshan Middha>>
# Created Date..........: <<20-Jan-2009>>
# Last Modified by......: <<Gulshan Middha >>
# Last Modified Date....: << >>
# Description...........: <Test cases>>
# Copyright (c) 2000-2008. Astadia, Inc. All Rights Reserved.
#
# Created by the Astadia, Inc. Modification must retain the above copyright notice.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any commercial purpose, without fee, and without a written
# agreement from Astadia, Inc., is hereby forbidden. Any modification to source
# code, must include this paragraph and copyright.
#
# Permission is not granted to anyone to use this software for commercial uses.
#
# Contact address: 2839 Paces Ferry Road, Suite 350, Atlanta, GA 30339
# Company URL : http://www.astadia.com
###########################################################################
*/

public without sharing class testClass {
  
  public static testMethod void testAttendee(){
    
    RecordType[] rt =[Select SobjectType, Name, IsPersonType, IsActive, Id From RecordType where SobjectType='Account' AND IsPersonType=true AND IsActive=true];
    if(rt!=null && rt.size()>0){
    Account a = new Account(RecordTypeId=rt[0].Id);
    a.FirstName= 'Test Account';
    a.LastName= 'Test Account';
    a.PersonBirthdate = Date.newInstance(1979, 01, 01);
    insert a;
    
    Contact[] c = [Select Id from Contact where AccountId=:a.Id];
    
    
       if(c!=null && c.size()>0)
      {
        
        List<Timeline_Event__c> teList = new List<Timeline_Event__c>();
        Timeline_Event__c te = new Timeline_Event__c(Client__c=c[0].Id);
        te.Date__c = Datetime.now();
        te.Other_Accommodation__c = 'Sample Acc';
        te.Work_Carried_Out_1__c = 'General discussion with client';
        te.Work_Carried_Out_2__c = 'Harm minimisation/health advice given';
        te.Work_Carried_Out_3__c = 'Accommodation advice given';
        teList.add(te);
        
        Timeline_Event__c te1 = new Timeline_Event__c(Client__c=c[0].Id);
        te1.Date__c = Datetime.now() + 1;
        te1.Other_Accommodation__c = 'Sample Acc';
        te1.Work_Carried_Out_1__c = 'General discussion with client';
        te1.Work_Carried_Out_2__c = 'Harm minimisation/health advice given';
        te1.Work_Carried_Out_3__c = 'Accommodation advice given';
        teList.add(te1);
        
        insert teList;  
        
        Campaign camp = new Campaign(
            Name = 'NLOS Assessment Hub', Borough__c = 'Barnet', 
            Private_notes_Westminster_copy_over__c = true, 
            Westminster_action_plan__c = true
        );
        insert camp;
        User usr = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = camp.Id
        );
        insert usr;
        id recTypeID = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('Street Contact - bedded down').RecordTypeId; 
        DateTime Now = DateTime.now();
        System.runAs(usr) {
            test.startTest();
            Timeline_Event__c TimelineEvent1 = new Timeline_Event__c(
            Client__c = c[0].Id,
            Event__c = 'Street Contact - Bedded Down',
            Creating_User_Organisation__c = 'CSTM',
            Date__c = Now,
            Project_Team__c = usr.Default_Project_Id__c,
            Borough_Street_Site__c = 'Test Timeline Event',
            RecordTypeId = recTypeID,
            Private_notes_CSTM__c = 'Some CSTM Notes');
            insert TimelineEvent1;
 
            Timeline t = new Timeline(new ApexPages.StandardController(TimelineEvent1));
            //Timeline t = new TimeLine();
            t.setSearchKey('test');
            t.getSearchKey();
            t.SearchClients();
            t.getSelectedClientOptions();
            t.getTimeline();
            List<SelectOption> opts = t.getClients();
            if(opts.size()>0)
            {
              t.strSelectedClients = opts[0].getValue();
              t.save();
              t.cancel();
            }
            t.redirectTimelineEvent();
            
            //First COntact Test
            ApexPages.currentPage().getParameters().put('aid',a.Id);
            ApexPages.currentPage().getParameters().put('selectedContact',c[0].Id);
            ApexPages.currentPage().getParameters().put('selectedAccount',a.Id);
            FirstContact fc = new FirstContact();
            fc.getContact();
            fc.getTimeLineEvent();
            fc.getSNA();
            fc.checkSourcePage();
            //fc.getIsNotesRequired();
            fc.Save();
            fc.saveAndAddFlow();
            fc.SaveSNA();
            fc.AddSupportNeeds();

            fc.Cancel(); 


            
    //        delete teList;
            
    //      CampaignController cc = new CampaignController();
    //      List<SelectOption> ll = cc.getCampaigns();
    //      if(ll!=null && ll.size()>0)
    //        cc.selectedCampaign = ll[0].getValue();
              
    //      cc.save();          
            test.stopTest();
        }
      }
    }

  }
  

    public static testMethod void testFCF(){  


            PageReference pg = new PageReference('/apex/FCF1');
            Test.setCurrentPage(pg);
            
            FirstContact fc = new FirstContact();
            
            fc.c = new Contact(FirstName = 'Jed',
                                LastName = 'Test',
                                BirthDate = system.today().addYears(-30),
                                Gender__c = 'Male',
                                Ethnic_Origin__c = 'White - British',
                                Nationality__c = 'UK',
                                Country_Region__c = 'England');
                                
            PageReference pg1 = fc.quickSaveClient();                    
                                
            

            fc.address = '1 High Street';
            fc.localAuthority = 'Test Authority';
            fc.lngLat = '50000,50000';
            fc.lng = '50000';
            fc.lat = '50000';    
            fc.postcode = 'SW1A 1AA';
            fc.ward = 'Test Ward';
            fc.borough = 'Test Borough';
            fc.LSOACode = 'AAA';
            fc.LSOAName = 'AAA';    
            fc.MSOACode = 'AAA';
            fc.MSOAName = 'AAA';
            fc.wardCode = 'AAA';
            
			fc.saveLocationFC();
        	fc.createTimelineEvent();
        
            PageReference pg2 = pg = fc.saveLocationFCMobile();
    		
        	fc.te.Date__C = system.today();
        	fc.te.Event__c = 'Street Contact - Not Bedded Down';
        	fc.te.Borough_Street_Site__c = 'Wandsworth - Battersea';
        	fc.te.Encounter_Type__c = 'Street Contact';
        	fc.te.Street_site_borough__c = 'Wandsworth';
        	fc.te.Time_of_contact__c = '00:00';
        	fc.te.NSNO_Action__c = 'Declined to engage';
        	
        	PageReference pg3 = fc.saveAndAddFlowMobile();
        
        	fc.flowInfo.Date__c = system.today();
        	fc.flowInfo.Primary_reason_for_leaving__c = 'Asked to leave';
        	fc.flowInfo.Last_longer_term_place_settled_base__c = 'Hostel';
        	fc.flowInfo.HPU_Housing_Options_in_last_12_months__c = 'Not known';
        	fc.flowInfo.Places_stayed_1__c = 'Hostel';
        	fc.flowInfo.Country_1__c = 'UK';
        	fc.flowInfo.Local_authority_UK_1__c = 'Angus Council';        	
        
        	PageReference pg4 = fc.saveFlowAndAddSupportNeeds();

        	fc.useSelectedContact();	
        
			fc.sna.Assessment_date__c = system.today();

			PageReference pg5 = fc.saveSupportNeedsandExit();        
        
        	
        	PageReference pg6 = fc.saveAndAddSupportNeedsfromTLE();
        	PageReference pg7 = fc.saveAndAddSupportNeeds();
        	PageReference pg8 = fc.saveFlowandExit();
        	PageReference pg9 = fc.saveFlow();
        	PageReference pg10 = fc.mobileCancel();
        
        
      
    }

  
}