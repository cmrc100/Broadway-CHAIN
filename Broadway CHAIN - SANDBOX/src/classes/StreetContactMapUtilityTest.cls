@isTest
public class StreetContactMapUtilityTest {

    static testMethod void unitTest() {


        PageReference pageRef = page.StreetContactMap;
        
        
        test.setCurrentPage(pageRef);
        
        MockLocationAPI mockResponse = new MockLocationAPI();
        mockResponse.borough = 'Westminster';
        
        test.setMock(HttpCalloutMock.class, mockResponse);   
        test.startTest();
        StreetContactMapUtility  testController = new StreetContactMapUtility(new FirstContact()); 

        string latlng = '50000,-1.55555';
                
        string slaId = StreetContactMapUtility.getMapPoint('test', '',  latlng);

        list<string> laList = slaId.split('\\^');
		system.AssertEquals(laList[0], 'Test Council');      


        mockResponse.borough = 'not found';        
        test.setMock(HttpCalloutMock.class, mockResponse);  
        slaId = StreetContactMapUtility.getMapPoint('test', '', latlng);
        testController.saveLocation();        
        
        test.stopTest();

        


 


    }
    
}