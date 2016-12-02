trigger MidlandsShare on Referrals__c (after insert) {

    ReferralsTriggerHandler rt = new ReferralsTriggerHandler();
    rt.shareWithMidlands(trigger.new);

}