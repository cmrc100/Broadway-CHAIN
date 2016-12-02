@isTest
private class PicklistUtilitiesTest {

    static testMethod void testGetPicklistValues() {
        
        map<string, string> returnMap = PicklistUtilities.getPicklistValues('Account', 'AccountSource', null);
        
        system.assert(returnMap.keySet().size() > 0 );
        
        // test sorting
        list<SelectOption> poList = new list<SelectOption>();
        for (string key :returnMap.keySet()){
            poList.add(new SelectOption(key, returnMap.get(key)));
        }
        // sort the list for coverage
        poList = PicklistUtilities.selectOptionSortByLabel(poList);
    
    
    }
    
    static testMethod void testValidatePicklistValue() {
        
        boolean valid = PicklistUtilities.validateValue('Account', 'AccountSource', 'nonsense', null);
        
        system.assertEquals(valid, false);
 
        valid = PicklistUtilities.validateValue('Account', 'AccountSource', 'Other', null);
        
        system.assertEquals(valid, true);   
    
    }
    
    
    static testMethod void testTechnicalError() {
        
        map<string, string> returnMap = PicklistUtilities.getPicklistValues('Not an object', 'AccountSource', null);
        
        system.assertEquals(returnMap, null);
        
        try {
            boolean valid = PicklistUtilities.validateValue('Not an object', 'AccountSource', 'nonsense', null);
        } catch (exception e){
            system.assert(e.getMessage().length() > 0);
        }
    }
    
}