public with sharing class Referral_Record_Type {
    public String selected{get;set;}
    public List<SelectOption> items{get;set;}
    
    public Referral_Record_type(ApexPages.StandardController controller)
    {
        items = new List<SelectOption>();
        getItemList();
    }
    
    private void getItemList()
    {
        for (Schema.RecordTypeInfo RecordTypeInfo : getRecordTypeInfos()) {
            if (RecordTypeInfo.isAvailable() && RecordTypeInfo.getRecordTypeId() != '012000000000000AAA') {
                items.add(new SelectOption(RecordTypeInfo.getRecordTypeId(), RecordTypeInfo.getName()));
                
                if (RecordTypeInfo.isDefaultRecordTypeMapping()) {
                    selected = String.valueOf(RecordTypeInfo.getRecordTypeId());
                }
            }
        }
    }
    
    private List<Schema.RecordTypeInfo> getRecordTypeInfos()
    {
        Schema.DescribeSObjectResult ReferralDescribe = Referrals__c.SObjectType.getDescribe();
        return ReferralDescribe.getRecordTypeInfos();
    }
}