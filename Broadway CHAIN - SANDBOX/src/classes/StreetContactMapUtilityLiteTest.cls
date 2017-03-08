@isTest
private class StreetContactMapUtilityLiteTest {

    static testMethod void unitTest() {


        PageReference pageRef = page.StreetContactMapLite;
        
        
        test.setCurrentPage(pageRef);
        
        MockLocationAPI mockResponse = new MockLocationAPI();
        mockResponse.borough = 'Westminster';
        
        test.setMock(HttpCalloutMock.class, mockResponse);   
        test.startTest();
        StreetContactMapUtilityLite  testController = new StreetContactMapUtilityLite(null); 

        string latlng = '50000,-1.55555';
                
        string slaId = StreetContactMapUtilityLite.getMapPoint('test', '',  latlng);

        list<string> laList = slaId.split('\\^');
		system.AssertEquals(laList[0], 'Test Council');      


        mockResponse.borough = 'not found';        
        test.setMock(HttpCalloutMock.class, mockResponse);  
        slaId = StreetContactMapUtilityLite.getMapPoint('test', '', latlng);
        testController.saveLocation();        
        
        test.stopTest();

        


 


    }
}