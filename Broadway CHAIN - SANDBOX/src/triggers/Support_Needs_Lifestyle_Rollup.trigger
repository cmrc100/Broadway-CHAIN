trigger Support_Needs_Lifestyle_Rollup on Support_Needs_Lifestyle__c (after insert, after update, after delete) {
    List<Id> contactIds = new List<Id>();
    List<Contact> contacts = new List<Contact>();
    
    Date DateOfMostRecentSNA, MostRecentBBSStage1Assessment, MostRecentBBSStage2Assessment, MostRecentIAFCompletedCSTM;
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Support_Needs_Lifestyle__c t : Trigger.new) {
            contactIds.add(t.Client__c);
        }
    }
    else if (Trigger.isDelete) {
        for (Support_Needs_Lifestyle__c t : Trigger.old) {
            contactIds.add(t.Client__c);
        }
    }
    
    Map<Id, List<Support_Needs_Lifestyle__c>> supportNeedsLifestyleByContactId = new  Map<Id, List<Support_Needs_Lifestyle__c>>();
    for (Support_Needs_Lifestyle__c ThisSupportNeedsLifestyle : [SELECT Id, RecordType.Name, Assessment_date__c, Client__c FROM Support_Needs_Lifestyle__c WHERE Client__c IN :contactIds]) {
        if (!supportNeedsLifestyleByContactId.containsKey( ThisSupportNeedsLifestyle.Client__c)) {
            supportNeedsLifestyleByContactId.put( ThisSupportNeedsLifestyle.Client__c, new List<Support_Needs_Lifestyle__c>() );
        }
        
        supportNeedsLifestyleByContactId.get( ThisSupportNeedsLifestyle.Client__c ).add( ThisSupportNeedsLifestyle );
    }
    
    for (Contact c : [SELECT Id, Date_of_most_recent_SNA_apex__c, Most_recent_BBS_stage_1_assessment_apex__c, Most_recent_BBS_stage_2_assessment_apex__c, Most_recent_IAF_completed_CSTM_apex__c FROM Contact WHERE Id IN :contactIds]) {
        List<Support_Needs_Lifestyle__c> supportNeedsLifestyle = supportNeedsLifestyleByContactId.get( c.Id );
        
        DateOfMostRecentSNA = c.Date_of_most_recent_SNA_apex__c;
        MostRecentBBSStage1Assessment = c.Most_recent_BBS_stage_1_assessment_apex__c;
        MostRecentBBSStage2Assessment = c.Most_recent_BBS_stage_2_assessment_apex__c;
        MostRecentIAFCompletedCSTM = c.Most_recent_IAF_completed_CSTM_apex__c;
        
        if (supportNeedsLifestyle != null) {
            for (Support_Needs_Lifestyle__c ThisSupportNeedsLifestyle : supportNeedsLifestyle) {
                if (ThisSupportNeedsLifestyle.RecordType.Name == 'Support Needs & Lifestyle') {
                    if (DateOfMostRecentSNA == null) {
                        DateOfMostRecentSNA = ThisSupportNeedsLifestyle.Assessment_date__c;
                    } else if (DateOfMostRecentSNA < ThisSupportNeedsLifestyle.Assessment_date__c) {
                        DateOfMostRecentSNA = ThisSupportNeedsLifestyle.Assessment_date__c;
                    }
                }
                
                if (ThisSupportNeedsLifestyle.RecordType.Name == 'Stage 1 assessment (BBS)') {
                    if (MostRecentBBSStage1Assessment == null) {
                        MostRecentBBSStage1Assessment = ThisSupportNeedsLifestyle.Assessment_date__c;
                    } else if (MostRecentBBSStage1Assessment < ThisSupportNeedsLifestyle.Assessment_date__c) {
                        MostRecentBBSStage1Assessment = ThisSupportNeedsLifestyle.Assessment_date__c;
                    }
                }
                
                if (ThisSupportNeedsLifestyle.RecordType.Name == 'Stage 2 assessment (BBS)') {
                    if (MostRecentBBSStage2Assessment == null) {
                        MostRecentBBSStage2Assessment = ThisSupportNeedsLifestyle.Assessment_date__c;
                    } else if (MostRecentBBSStage2Assessment < ThisSupportNeedsLifestyle.Assessment_date__c) {
                        MostRecentBBSStage2Assessment = ThisSupportNeedsLifestyle.Assessment_date__c;
                    }
                }
                
                if (ThisSupportNeedsLifestyle.RecordType.Name == 'Day/Night Centre Initial assessment (CSTM)') {
                    if (MostRecentIAFCompletedCSTM == null) {
                        MostRecentIAFCompletedCSTM = ThisSupportNeedsLifestyle.Assessment_date__c;
                    } else if (MostRecentIAFCompletedCSTM < ThisSupportNeedsLifestyle.Assessment_date__c) {
                        MostRecentIAFCompletedCSTM = ThisSupportNeedsLifestyle.Assessment_date__c;
                    }
                }
            }
        }
        
        c.Date_of_most_recent_SNA_apex__c = DateOfMostRecentSNA;
        c.Most_recent_BBS_stage_1_assessment_apex__c = MostRecentBBSStage1Assessment;
        c.Most_recent_BBS_stage_2_assessment_apex__c = MostRecentBBSStage2Assessment;
        c.Most_recent_IAF_completed_CSTM_apex__c = MostRecentIAFCompletedCSTM;
        
        contacts.add(c);
    }
    
    update(contacts);
}