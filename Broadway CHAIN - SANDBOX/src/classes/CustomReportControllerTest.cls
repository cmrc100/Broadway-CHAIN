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
private class CustomReportControllerTest {
  
	private static Custom_Report_Objects__c cro = new Custom_Report_Objects__c();
  
	static void setUpData(){
    	list<Custom_Report_Objects__c> croList = [select id from Custom_Report_Objects__c];
    	if (croList != null){
      		if(!croList.isEmpty()){
        		delete croList;
      		}
    	}

      Campaign cmp = new Campaign(
            Name = 'NLOS Assessment Hub', Borough__c = 'Barnet'
        );
        insert cmp;
        
        User usr = new User(
            Username = 'cstm@cstm.dl', Email = 'cstm@cstm.dl', Department = 'Department', Division = 'Division',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FirstName = 'Joe',
            LastName = 'Bloggs', Alias = 'jblo', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Default_Project_Id__c = cmp.Id
        );
        insert usr;

        System.runAs(usr) {
	        	
	
	        Account Client = new Account(FirstName = 'Chris', LastName = 'TestCross',
	        								AccountSource='Other', RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'NLOS Assessment Hub');
	        insert Client;    
    		
    		Client = [SELECT Id, PersonContactId FROM Account WHERE Id = :Client.Id];
    		
	    	cro = new Custom_Report_Objects__c(Name='AccountContactTest', Active__c=true, Master_Object_Name__c ='Account', Child_Object_Name__c = 'Contact');
	    	croList.add(cro);
	    	insert croList;
    
    	//Account a = new Account(Name = 'TestAccount1', AccountSource='Other',RecordType = new RecordType( Name = 'Client Account' ), Project_Team__pc = 'NLOS Assessment Hub' );
    	//insert a;
    
    	//	Contact c = new Contact(FirstName = 'Chris', LastName='TestCross', 
    	//										AccountId = Client.id, LeadSource ='Other', Title='Tester');
    	//	insert c;
        }
        
  	}
  
    static testMethod void testMasterSearch() {
        
		setUpData();
   
        PageReference pg = new PageReference('Page.CustomReport');
  //  pg.getParameters().put('Integration', 'TestBDL');       
    
    	test.setCurrentPageReference(pg);

    	test.startTest();  
    	CustomReportController controller = new CustomReportController();     
        
        list<SelectOption> primaryObjects = controller.getPrimaryObjects();
        system.assertEquals(primaryObjects.size(), 2);
        system.assertEquals(primaryObjects[1].getValue(), 'Account');
        
        controller.sobjectParentName = primaryObjects[1].getValue();
        controller.populateParentSobjectFields();
        
        list<SelectOption> fldOptions = controller.getsobjectFieldOptions();         
        list<SelectOption> booleanOperatorList = controller.getbooleanOperators();
        list<SelectOption> dateOperatorList = controller.getdateOperators();
        list<SelectOption> stringOperatorList = controller.getstringOperators();
        list<SelectOption> picklistOperatorList = controller.getpicklistOperators();
        list<SelectOption> dateLiteralsOperatorList = controller.getdateLiterals();
        list<SelectOption> allObjectsList = controller.getAllObjects();
           
        //list<CustomReportController.SobjectField> fldList = controller.selectedFields;
        //CustomReportController.SobjectField fldItem = new CustomReportController.SobjectField();
        system.assertEquals(controller.sobjectFieldFilters[0].fieldName, ' -- Select Field --');
        controller.sobjectFieldFilters[0].fieldName = 'CreatedDate';
        system.assertEquals(controller.sobjectFieldFilters[0].fieldName, 'CreatedDate');
        controller.sobjectFieldFilters[0].operator = '=';
        controller.sobjectFieldFilters[0].fieldDateLiteral = 'TODAY';
        controller.refreshFilter();
        
        //fldItem.fieldType = 'DATETIME';
        //fldList.add(fldItem);
        //controller.sobjectFieldFilters = fldList;       

        
        list<SelectOption> secondaryObjects = controller.getSecondaryObjects();
        system.assertEquals(secondaryObjects.size(), 2);
        system.assertEquals(secondaryObjects[1].getValue(), 'Contact');
        
        controller.sobjectChildName = secondaryObjects[1].getValue();      
        controller.populateChildSobjectFields();
        
        
        list<SelectOption> parentSelectList = controller.selectedParentFields;
        SelectOption so = new SelectOption('Name', 'Name');
    	parentSelectList.add(so);
        
        list<SelectOption> fldChildOptions = controller.getsobjectChildFieldOptions();         

        list<CustomReportController.SobjectField> fldListChild = controller.sobjectChildFieldFilters;
        fldListChild[0].fieldName = 'CreatedDate';
        fldListChild[0].operator = '=';
        fldListChild[0].fieldDateLiteral = 'TODAY';
        fldListChild[0].fieldType = 'DATETIME';

        controller.searchSobject();
 // system.assertEquals(controller.sSoql, 'Select');
        controller.addChildFilter(); 
               
    	list<Sobject> resultList = controller.getsobjects();
        system.assertEquals(resultList.size(), 1);
        system.assertEquals(string.valueOf(resultList[0].get('Name')), 'Chris TestCross');
        
        controller.firstPage();
        controller.nextPage();
        controller.lastPage();

       	controller.addFilter();

        controller.sobjectFieldFilters[1].fieldName = 'AccountSource';
        system.assertEquals(controller.sobjectFieldFilters[1].fieldName, 'AccountSource');
        controller.sobjectFieldFilters[1].operator = '=';
        controller.sobjectFieldFilters[1].fieldDateLiteral = 'Other';

        list<SelectOption> childSelectList = controller.selectedChildFields;
        so = new SelectOption('Title', 'Title');
    	childSelectList.add(so);
        
        controller.currentField = 'AccountSource';
        controller.currentContext = 'Account';
        controller.refreshpicklistFilter();
        controller.refreshFilter();
        
		//controller.searchSobject();
    	resultList = controller.getsobjects();
        system.assertEquals(resultList.size(), 1);
        system.assertEquals(string.valueOf(resultList[0].get('Name')), 'Chris TestCross');
        
        PageReference pgExport = controller.exportCSV();
        system.assert(controller.resultValues.length() > 0);
        
        controller.clearFilters();
        controller.sobjectParentName = primaryObjects[1].getValue();
        controller.sobjectChildName = secondaryObjects[1].getValue();     
        PageReference pgSecond = controller.addSecondFilter();
        controller.secondChild = true;
        pgSecond = controller.applySecondFilter();
        
        test.stopTest();
        
        
    }
}