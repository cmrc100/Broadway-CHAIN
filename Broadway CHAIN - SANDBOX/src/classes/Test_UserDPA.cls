/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_UserDPA {

    static PageReference pgDPATerms = page.DPATerms;
    static UserDPA  dpaController;  
    static User usrA;
    
    static testMethod void unitTestDPA() {
        
        // create User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
          
        usrA = new User(Alias = 'uA', Email='u1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, DPA_Agreement__c = false,
        TimeZoneSidKey='America/Los_Angeles', UserName='uATest@testorg.com');
      
        insert usrA;

        system.runAs(usrA){
                
            test.startTest();
            test.setCurrentPage(pgDPATerms);
            dpaController = new UserDPA();
            
            system.assertEquals(false, dpaController.usr.DPA_Agreement__c);
            
            User usr = dpaController.getusr();
                        
            system.assertEquals(usr.DPA_Agreement__c, false);

            string sTest = userDPA.checkAndRedirect();
            
            system.assertEquals(sTest, '/apex/DPATerms');
            
            dpaController.usrDPA = true;
            
            dpaController.updateDPA();
            
            system.assertEquals(usr.DPA_Agreement__c, true);
            
            sTest = userDPA.checkAndRedirect();
            
            system.assertEquals(sTest, '');
            
           
            
            test.stopTest();
            
        }


    }
}