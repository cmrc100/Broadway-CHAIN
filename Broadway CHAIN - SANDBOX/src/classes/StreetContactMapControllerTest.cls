@isTest
private class StreetContactMapControllerTest {

    static testMethod void unitTest() {


        PageReference pageRef = page.StreetContactMap;
        
       // Insert test Loacal Authority
        Local_Authority__c la = new Local_Authority__c(Name='Test Council', Referral_Email__c = 'test@test.com');
        insert la; 
        
        map <string, string> boroughList = PicklistUtilities.getPicklistValues('Timeline_Event__c', 'Street_site_borough__c', null);
        string borough = boroughList.values()[0];
        
        test.setCurrentPage(pageRef);
        
        MockLocationAPI mockResponse = new MockLocationAPI();
        mockResponse.borough = borough;
        
        test.setMock(HttpCalloutMock.class, mockResponse);   
        test.startTest();
        StreetContactMapController  testController = new StreetContactMapController(null); 

        string latlng = '50000,-1.55555';
                
        string slaId = StreetContactMapController.getMapPoint('test', '', '', latlng);
 
        list<string> laList = slaId.split('\\^');
       
        system.assertEquals(laList[0], la.Name);
        system.assertEquals(laList[2], 'Test Ward');
        system.assertEquals(laList[3], borough);

        mockResponse.borough = 'not found';        
        test.setMock(HttpCalloutMock.class, mockResponse);  
        slaId = StreetContactMapController.getMapPoint('test', '', '', latlng);
        testController.saveLocation();        
        
        test.stopTest();

        


 


    }
}