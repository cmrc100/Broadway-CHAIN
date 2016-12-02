global with sharing class ClientSearchController {

    public ClientSearchController(FirstContact controller) {

    }



	private static string clientRecType = Schema.SObjectType.Account.RecordTypeInfosByName.get('Client Account').RecordTypeId;
  

    @RemoteAction
    global static list<Account> searchClients(string param){
    
        list<Account> returnList = new list<Account>();
                  
        param = '\'' + param + '\'';
        
        system.debug(' @@@ Search for .. ' + param);
        
        List<Schema.FieldSetMember> fieldSet = getFields('ClientSearchList');
        string fieldList = '';
        
        for (Schema.FieldSetMember f: fieldSet) {

			fieldList += f.fieldPath + ',';

        }
        fieldList += 'Id, PersonContactId, ClientID__pc ';
        
        string query = 'FIND :param IN ALL FIELDS RETURNING Account(' + fieldList + ' WHERE recordTypeId = :clientRecType ORDER by Name asc limit 50)';
        
        List<List<SObject>> searchList = search.query(query); 
        

        returnList = searchList[0];
        return returnList;
    }

	private static List<Schema.FieldSetMember> getFields( string fsName) {
        
        List<Schema.FieldSetMember> fset = new List<FieldSetMember>();
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map <String, Schema.SObjectField> fieldMap = gd.get('Account').getDescribe().fields.getMap();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fsMap.get(fsName);
        
        if (fs != null){
            fset = fs.getFields();
        }
        return fset;
        
    }    

}