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
private class Test_HubsController {

    static testMethod void myUnitTest() {
    
        PageReference pg = page.HubStatus;
        HubsController controller = null;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        User usrA = null;
        system.runAs(thisUser){ // to avoid DML error   
            
            // create User
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
              
            usrA = new User(Alias = 'uA', Email='u1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='uATest@testorg.com');
            
            insert usrA;
        }
        usrA = [select Id from User where Alias = 'uA'];
    
        system.runAs(usrA){ 
            
            string sProfile = [select name from profile where id=: UserInfo.getProfileId()].name; 
            Hubs__c hub = new Hubs__c(Name = 'Test Hub', Hub_Name__c = 'Test Hub', Hub_Open__c = true, profile__c = 'Standard User');
            insert hub;
            
            list<Hubs__c> hubsList = [select Hub_name__c, Hub_open__c from Hubs__c where profile__c=:sProfile]; 
            
            test.startTest();
            
            controller = new HubsController();
            
            hubsList = controller.hubs;
            
            for (Hubs__c h :hubsList){
                string sName = h.Hub_name__c;
                if(sName == 'Test Hub'){
                    h.Hub_open__c = false;
                }               
            }
            controller.updateValues();
            
            hub = [select Hub_open__c from Hubs__c where name = 'Test Hub'];
            
            system.assertEquals(hub.Hub_open__c, false);
            
            string s = HubsController.updateHub('Test Hub', false);
            
            system.assertEquals(s, '');

            hub = [select Hub_open__c from Hubs__c where name = 'Test Hub'];
            
            system.assertEquals(hub.Hub_open__c, true);
            
            system.assertEquals(sProfile, HubsController.getProfileName());
            
            test.stopTest();
        
        }
        
            
    }

}