public with sharing class CustomReportController {

    public list<Sobject> soqlResult{get; private set;}
    public string resultValues {get; private set;}
    public list<string> fieldSelection {get; set;}
    public list<string> fieldChildSelection {get; set;}
    public string selectedFields{get; private set;}
    public string sSoql {get; set;} 
    public string sSoqlChild {get; set;} 
    public string sobjectName {get; set;}

    //public string sobjectParentName {get; set;}

    public string currentField {get; set;} 
    public string currentContext {get; set;}

    public boolean filterParentByChild{get; set;}
    public integer filterIndexToRemove {get; set;}  
    public list<SobjectField> sobjectFields {get; set;} //Sobject field metadata - STRING, BOOLEAN and PICKLIST fields
    public list<SobjectField> sobjectFieldFilters  {get; set;} // Field filters to apply in the Sobject selection criteria  
    public list<list<SobjectField>> sobjectFiltersSaved {get; set;} // Field filters saved   
    public boolean secondChild{get; set;}
        
    public map<string, SobjectField> sobjectFieldMap  {get; set;} // All Sobject field metadata    
    public map<string, SobjectField> sobjectChildFieldMap  {get; set;} // All child Sobject field metadata 
    public list<SobjectField> sobjectChildFieldFilters  {get; set;} // Field filters to apply in the child Sobject selection criteria
    public list<SobjectField> sobjectChildFieldFilters2  {get; set;}
    public list<SobjectField> sobjectChildFields {get; set;} //Sobject field metadata - STRING, BOOLEAN and PICKLIST fields
    public list<SobjectField> sobjectChildFields2 {get; set;} 
    public ApexPages.StandardSetController setCon {get; set;}    
    public Integer resultsPerPage{get;Set;}    
    public Integer currentPage{get;Set;}    
    public decimal totalPages{get;Set;}    
    public String tabOpt {get;set;}
    public list<SelectOption> childObjectNames {get; set;}
    
    transient List<Schema.ChildRelationship> childRelationships = null;
    private list<Sobject> resultsList = null;
    private map<string, list<string>> objectMap = new map<string, list<string>>(); 

    public String sobjectChildName {
        get {

                return sobjectChildName;
        }
        set {

                sobjectChildName = value;
        }
    }       
 
        public string sobjectParentName {
                get{
                        
                        return sobjectParentName;
                }        
                set {
                        //sobjectSingleName = value;
                        sobjectParentName = value;
                        //sobjectName = value;                  
                }       
        }

        public string sobjectSingleName {
                get{
                        
                        return sobjectSingleName;
                }        
                set {
                        if (value == ' -- Select Single Object --'){
                        	value = '';
                        }
                        if (string.isnotBlank(value)){
	                        sobjectSingleName = value;
	                        sobjectParentName = value; 
	                        sobjectName = value;
                        }                    
                }       
        }         
    public CustomReportController() {
        
        filterParentByChild = true;
        secondChild = false;
        sobjectFieldFilters = new list<SobjectField>();
        sobjectChildFieldFilters = new list<SobjectField>();
        currentPage = 1;
        totalPages = 1;
        setupObjects();
        tabOpt = 'reportConfig';
                
        fieldSelection = new list<string>();
        fieldSelection.add('Id');
        fieldSelection.add('Name');
        selectedParentFields = new List<SelectOption>();
        
        fieldChildSelection = new list<string>();
        fieldChildSelection.add('Id');
        fieldChildSelection.add('Name');
        selectedChildFields = new List<SelectOption>();
             
    }
        
    private void setupObjects(){
                
    
        // Retrieve list of available objects from Custom Setting definition object
        list<Custom_Report_Objects__c> objectsList = Custom_Report_Objects__c.getall().values();

        for (Custom_Report_Objects__c obj :objectsList){
            boolean active = obj.Active__c;
            string master = obj.master_object_name__c;
            string child = obj.child_object_name__c;
            if (active)
            {
                list<string> childList = objectMap.get(master);
                if(childList == null){
                    childList = new list<string>();
                }
                childList.add(child);
                objectMap.put(master, childList);
            }
        }               
                
                
    }

        // Method to retrieve All organisation objects
        public List<SelectOption> getAllObjects() {
        //Variables to hold the Obj Label and Obj LabelName map
        List<String> objLabels = new List<String>();
        Map<String, String> objLabelNameMap = new Map<String, String>();
        
        //To fetch all the objects of the current Organisation
        List<Schema.SObjectType> allObjects = Schema.getGlobalDescribe().Values();    
        List<SelectOption> objectOptions = new List<SelectOption>();
        objectOptions.add(new SelectOption(' -- Select Single Object --', ' -- Select Single Object --'));
        
        //Loop to iterate over all objects
        for(Schema.SObjectType objectName : allObjects) {   

            objLabels.add(objectName.getDescribe().getLabel());
            objLabelNameMap.put(objectName.getDescribe().getLabel(), 
                                                   objectName.getDescribe().getName());

        }
        objLabels.sort();
        for(String objLabel : objLabels){
            
            objectOptions.add(new SelectOption(objLabelNameMap.get(objLabel),objLabel));
        }
        return objectOptions;
    }   
        
  // Method to populate drop-down selection of Primary (master) objects
    public list<SelectOption> getPrimaryObjects(){
                
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption(' -- Select Primary Object --', ' -- Select Primary Object --'));
        
        for(string s :objectMap.keySet()){
            Schema.DescribeSObjectResult parentSchema = Schema.getGlobalDescribe().get(s).getDescribe();    
            string label = parentSchema.getLabel();
            options.add(new SelectOption(s, label));
        }
                
                
        return options;     
    }
            
    // Method to populate drop-down selection of Secondary (child) objects
    public list<SelectOption> getSecondaryObjects(){
                
        List<SelectOption> options = new List<SelectOption>();
        map<string, string> valueMap = new map<string, string>();
        options.add(new SelectOption(' -- Select Child Object--', ' -- Select Child Object --'));
                        
        list<string> childList = objectMap.get(sobjectParentName);
        if(childList != null){
            for(string s :childList){
                Schema.DescribeSObjectResult childSchema = Schema.getGlobalDescribe().get(s).getDescribe();     
                string label = childSchema.getLabel();
                options.add(new SelectOption(s, label));                                
            }
                                
        }
                
        return options;     
    }
        
    public void populateChildSobjectFields(){
                
        sobjectChildFieldFilters = new list<SobjectField> ();
                sobjectChildFieldFilters2 = new list<SobjectField> ();
        sSoqlChild = ''; 
        currentContext = 'Child';
        refreshFilter();
        sobjectName = sobjectChildName;
        populateSobjectFields();
        addChildFilter();
    }

    public void populateParentSobjectFields(){
                
        sobjectFieldFilters = new list<SobjectField> (); 
        sobjectChildFieldFilters = new list<SobjectField> (); 
        sSoql= '';
        sSoqlChild = '';
        currentContext = 'Parent';
        sobjectName = sobjectParentName;
        populateSobjectFields();
        addFilter();
          
    }
            
    // This method setsup the Sobject field metadata required. 
    public void populateSobjectFields(){
                
        try{
         
            if (currentContext == 'Parent'){
                sobjectName = sobjectParentName;        
                sobjectFields = new list<SobjectField>();
                sobjectFieldMap = new map<string, SobjectField>();
                selectedParentFields = new list<SelectOption>();
            // put dummy record in the map
                SobjectField dummy = new SobjectField();
                sobjectFieldMap.put(' -- Select Field --', dummy);
            }
            if (currentContext == 'Child'){
                sobjectName = sobjectChildName;
                sobjectChildFields = new list<SobjectField>();
                sobjectChildFieldMap = new map<string, SobjectField>();
                selectedChildFields = new list<SelectOption>();
                // put dummy record in the map
                SobjectField dummyChild = new SobjectField();
                sobjectChildFieldMap.put(' -- Select Field --', dummyChild);
            }
       
            // retrieve all Sobject fields
            Map<String, Schema.SObjectField> objectFields 
                    = Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap();
                
            if(currentContext == 'Parent'){
                Schema.DescribeSObjectResult parentSchema = Schema.getGlobalDescribe().get(sobjectName).getDescribe();
                childRelationships = parentSchema.getChildRelationships();
            }
                        
            for(String s : objectFields.keySet())
            {
                    
                Schema.SObjectField sfield = objectFields.get(s);
                schema.describeFieldResult dfield = sfield.getDescribe();
                    
                SobjectField actFld = new SobjectField();
                actFld.fieldLabel = dfield.getLabel();
                actFld.fieldName = dfield.getName();
                actFld.fieldType = string.valueOf(dfield.getType()); //get Sobject field type
                // If a picklist field, retrieve picklist values and store agains the field
                if(string.valueOf(dfield.getType()) == 'Picklist' 
                        || string.valueOf(dfield.getType()) == 'MultiPicklist'){
                    actFld.isPicklist = true;

                }
                if (actFld.picklistValues.size() > 1){
                    actFld.picklistValues.remove(0);
                    actFld.picklistValues.add(0,new SelectOption(' -- Select Value --', ' -- Select Value --'));
                }
                if (currentContext == 'Parent'){       
                    sobjectFields.add(actFld); // Metadata used in the UI
                    sobjectFieldMap.put(actFld.fieldName, actFld); // Metadata for all fields, used for internal logic
                }
                if (currentContext == 'Child'){
        
                    sobjectChildFields.add(actFld); // Metadata used in the UI
                    if(secondChild){
                        sobjectChildFields2.add(actFld);
                    }
                    sobjectChildFieldMap.put(actFld.fieldName, actFld); // Metadata for all fields, used for internal logic
                }
                    
            }
                
            // Initialise variables used for sobject search results pagination
            this.currentPage = 0;
            this.resultsPerPage = 0;
            this.totalPages = 0;
                
        } catch(exception e){
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString()));                              
        }

    }
        
    private void retrievePicklistValues(SobjectField fld){
        // retrieve all Sobject fields
        Map<String, Schema.SObjectField> objectFields 
                        = Schema.getGlobalDescribe().get(currentContext).getDescribe().fields.getMap();         
                
        Schema.SObjectField sfield = objectFields.get(fld.fieldName);
        schema.describeFieldResult dfield = sfield.getDescribe();

        List<Schema.PicklistEntry> listValues = dfield.getPicklistValues();
        for (Schema.PicklistEntry ps :listValues){
            fld.picklistValues.add
                    (new SelectOption(string.valueOf(ps.label), string.valueOf(ps.label)));
        }

        if (fld.picklistValues.size() > 1){
            fld.picklistValues.remove(0);
            fld.picklistValues.add(0,new SelectOption(' -- Select Value --', ' -- Select Value --'));
        }
                
    }
        
   // Method to retrieve drop-down field name choices in the UI.
    // currently, only displays STRING, BOOLEAN or PICKLIST and DATE, DATETIME field types
    public list<SelectOption> getsobjectFieldOptions(){

        List<SelectOption> options = new List<SelectOption>();

        if (sobjectFields != null){
            for (SobjectField listItem :sobjectFields){
                string fldType = listItem.fieldType;
                string fldLabel = listItem.fieldLabel;
                string fldName =  listItem.fieldName;
                if (fldType == 'String' || fldType == 'Boolean' || 
                        fldType == 'Picklist' || fldType == 'MultiPicklist' ||
                        fldType == 'Date' || fldType == 'DateTime'){
                        
                    options.add(new SelectOption(fldName, fldLabel));
                }
                    
            }
            options = selectOptionSortByLabel(options);
            if(options.size() > 0) 
                options.add(0,new SelectOption(' -- Select Field --', ' -- Select Field --'));
            else
                options.add(new SelectOption(' -- Select Field --', ' -- Select Field --'));
            }
                
        return options;     

    }

  // Method to retrieve drop-down field name choices in the UI.
    // currently, only displays STRING, BOOLEAN or PICKLIST field types
    public list<SelectOption> getsobjectChildFieldOptions(){

        List<SelectOption> options = new List<SelectOption>();

        if(sobjectChildFields != null){
            for (SobjectField listItem :sobjectChildFields){
                string fldType = listItem.fieldType;
                string fldLabel = listItem.fieldLabel;
                string fldName =  listItem.fieldName;
                if (fldType == 'String' || fldType == 'Boolean' || 
                        fldType == 'Picklist' || fldType == 'MultiPicklist' ||
                        fldType == 'Date' || fldType == 'DateTime'){
                    
                    options.add(new SelectOption(fldName, fldLabel));
                }
            
            }
            options = selectOptionSortByLabel(options);
                
            if (options.size() > 0)
                options.add(0,new SelectOption(' -- Select Field --', ' -- Select Field --'));
            else
                options.add(new SelectOption(' -- Select Field --', ' -- Select Field --'));

        }
                        
        return options;     
    }
    
   // Method to populate available filter criteria definition operator values
    // in the operator UI dropdown if a STRING field type has been selected.
    public list<SelectOption> getstringOperators(){
        
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption(' -- Select Operator --', ' -- Select Operator --'));

        options.add(new SelectOption('=null', 'Is Null'));
        options.add(new SelectOption('!=null', 'Is Not Null'));
        options.add(new SelectOption('=', 'Equal to'));
        options.add(new SelectOption('!=', 'Not Equal to'));
        options.add(new SelectOption('like', 'Contains'));      
        options.add(new SelectOption('not like', 'Does not Contain'));
        
        return options;     
    }

    // Method to populate available filter criteria definition operator values
    // in the operator UI dropdown if a PICKLIST field type has been selected.
    public list<SelectOption> getpicklistOperators(){

        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption(' -- Select Operator --', ' -- Select Operator --'));
        
        options.add(new SelectOption('=null', 'Is Null'));
        options.add(new SelectOption('!=null', 'Is Not Null'));
        options.add(new SelectOption('=', 'Equal to'));
        options.add(new SelectOption('!=', 'Not Equal to'));
                
        return options;
        
    }

    // Method to populate available filter criteria definition operator values
    // in the operator UI dropdown if a BOOLEAN field type has been selected.   
    public list<SelectOption> getbooleanOperators(){

        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption(' -- Select Operator --', ' -- Select Operator --'));
        options.add(new SelectOption('=', 'Equal to'));
        options.add(new SelectOption('!=', 'Not Equal to'));
                
        return options;
        
    }
   // Method to populate available filter criteria definition operator values
    // in the operator UI dropdown if a Date or DateTime field type has been selected.
    public list<SelectOption> getdateOperators(){

        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption(' -- Select Operator --', ' -- Select Operator --'));
        
        options.add(new SelectOption('>', 'Greater Than'));
        options.add(new SelectOption('<', 'Less Than'));
        options.add(new SelectOption('=', 'Equal to'));
        options.add(new SelectOption('!=', 'Not Equal to'));
        options.add(new SelectOption('!=', 'Not Equal to'));
                
        return options;
        
    }

    public list<SelectOption> getdateLiterals(){

        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption(' -- Select Date Literal --', ' -- Select Date Literal --'));
        
        options.add(new SelectOption('YESTERDAY', 'Yesterday'));
        options.add(new SelectOption('TODAY', 'Today'));
        options.add(new SelectOption('TOMORROW', 'Tomorrow'));
        options.add(new SelectOption('LAST_WEEK', 'Last Week'));
        options.add(new SelectOption('THIS_WEEK', 'This Week'));
        options.add(new SelectOption('NEXT_WEEK', 'Next Week'));
        options.add(new SelectOption('THIS_MONTH', 'This Month'));
        options.add(new SelectOption('NEXT_MONTH', 'Next Month'));
        options.add(new SelectOption('LAST_90_DAYS', 'Last 90 Days'));
        options.add(new SelectOption('NEXT_90_DAYS', 'Next 90 Days'));
        options.add(new SelectOption('THIS_QUARTER', 'This Quarter'));
        options.add(new SelectOption('LAST_QUARTER', 'Last Quarter'));                
        options.add(new SelectOption('NEXT_QUARTER', 'Next Quarter'));
        options.add(new SelectOption('THIS_YEAR', 'This Year'));
        options.add(new SelectOption('LAST_YEAR', 'Last Year'));                
        options.add(new SelectOption('NEXT_YEAR', 'Next Year')); 
                
        return options;
        
    }
    
    public void refreshpicklistFilter(){
        SobjectField fld = new SobjectField();
        system.debug ('******************* &&&&&&&&&&&&&  ' + currentField);        
        if (currentContext == sobjectParentName){
            fld = sobjectFieldMap.get(currentField);
        }
        if (currentContext == sobjectChildName){
            fld = sobjectChildFieldMap.get(currentField);                   
        }

        retrievePicklistValues(fld);
        refreshFilter();
    }
  
   
   // Constructs a SOQL where clause based on the field name, operator and value choices
    // made in the UI
    public void refreshFilter(){
    
        try {   
            sSoql = '';
            sSoqlChild = '';
                
            sSoql = getSoql(sobjectFieldMap, sobjectFieldFilters);
system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ' +  sSoql);
                        if (secondChild){
                                sSoqlChild = getSoql(sobjectChildFieldMap, sobjectChildFieldFilters2);
                        } else {                  
                sSoqlChild = getSoql(sobjectChildFieldMap, sobjectChildFieldFilters);
                        }
        } catch (exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage() + ' : ' + e.getStackTraceString() 
                                                                                                        + ' - Unexpected Error Constructing SOQL Statement' ));                         
        }
    }
        
    private string getSoql(map<string, SobjectField> fieldMap, list<SobjectField> filtersList){
            
        string soqlReturn = '';
        string fldType = '';
        string conditionJoin = ''; 
system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ' +  filtersList);          
        integer fldPos = 0;
        for (SobjectField fld :filtersList){            
system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ' +  fld.andOr); 
            SobjectField accFld = fieldMap.get(fld.fieldName);               
            fldType = accFld.fieldType;
            if (string.isBlank(fldType))
                continue;
            if (string.isBlank(fld.operator) || fld.operator.contains('Select Operator'))
                continue;
                                
            if (string.isBlank(soqlReturn)){
                conditionJoin = '';
            } else if (filtersList.size() > 1){
                conditionJoin = soqlReturn + ' ' + filtersList[fldPos - 1].andOr + ' ';
            }
            if (fldPos == 0){
                conditionJoin = ' (';
            }
            if (fldPos > 1 && (filtersList[fldPos - 1].andOr != filtersList[fldPos - 2].andOr)){
                conditionJoin = soqlReturn + ') ' + filtersList[fldPos - 1].andOr + ' (';
            }
            if (fldPos + 1 == filtersList.size()){
                
            }    
            string sValue = '\'' + String.escapeSingleQuotes(fld.fieldValue) +'\'';
            if (fld.operator == 'like' || fld.operator == 'not like'){
                sValue = '\'%' + String.escapeSingleQuotes(fld.fieldValue)+'%\'';
            }
            if (fld.operator == '=null' || fld.operator == '!=null'){
                sValue = '';
            }
 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'FIELDTYPE   ' + fldType));           
system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ' +  conditionJoin ); 
            if (fld.fieldValue == 'true' || fld.fieldValue == 'false'){
                soqlReturn = conditionJoin + accFld.fieldName + ' ' + fld.operator + ' ' + boolean.valueOf(fld.fieldValue); 
            } else if (fldType == 'DATE' || fldType == 'DATETIME' ){ 
                if (string.isnotBlank(fld.fieldDateLiteral) && fld.fieldDateLiteral != ' -- Select Date Literal --'){
                    soqlReturn = conditionJoin + accFld.fieldName + ' ' + fld.operator + ' ' + fld.fieldDateLiteral;
                } else if (string.isnotBlank(fld.fieldValue)){ 
                    list<string> dateList = fld.FieldValue.Split('/');
                    integer year = integer.valueOf(dateList[2]);
                    integer month = integer.valueOf(dateList[1]);
                    integer day = integer.valueOf(dateList[0]);
                    DateTime dtValue = Date.valueOf(year + '-' + month + '-' + day + ' 00:00:00Z');
                    string sToday = dtValue.format('yyyy-MM-dd');
                if (sToday == string.valueOf(system.today())){
//         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ' TODAY '));
                    soqlReturn = conditionJoin + accFld.fieldName + ' ' + fld.operator + ' TODAY ';                            
                } else {
                    if (fldType == 'DATETIME'){
                        sValue = dtValue.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                        soqlReturn = conditionJoin + accFld.fieldName + ' ' + fld.operator + ' ' +   sValue;
                    }
                    if (fldType == 'DATE'){
                        sValue = dtValue.format('yyyy-MM-dd');
                        soqlReturn = conditionJoin + accFld.fieldName + ' ' + fld.operator + ' ' +  sValue;
                    }                               
                }
            }
                                       
            } else {                
                soqlReturn = conditionJoin + accFld.fieldName + ' ' + fld.operator + ' ' + sValue;
            }
            if (fldPos + 1 == filtersList.size()){
                soqlReturn = soqlReturn + ')';  
            }
           fldPos++;         
        }               
 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'RETURN SOQL IS ..   ' + soqlReturn + ' - ' + filtersList));                
        return soqlReturn;
                
    }
        
    public void saveFilter(){
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This feature is under construction'));     
                
    }
        
   // Creates an empty field criteria wrapper object for user input
    public void addFilter(){
        if(string.isnotBlank(sobjectParentName) && sobjectFields != null){ 
            SobjectField newField = new SobjectField();
            newField.fieldName = ' -- Select Field --';
            sobjectFieldFilters.add(newField); // add to list of filters created by user
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Must select a Master Object before applying a filter'));                                    
        }           
    }

    public void addChildFilter(){

        if(string.isnotBlank(sobjectChildName) && sobjectChildFields != null){         
            SobjectField newField = new SobjectField();
            newField.fieldName = ' -- Select Field --';
            sobjectChildFieldFilters.add(newField); // add to list of filters created by user
            if (secondChild){
                sobjectChildFieldFilters2.add(newField);
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Must select a Child Object before applying a filter'));            
        }            
    }
    // Retrieve the Sobject records matching the currently defined criteria.
    // Results are stored in a StandardSetController object
    public void searchSobject(){

        addSelectedFields();
        string selectList = '';
        if (!fieldSelection.isEmpty()){
            for (string s :fieldSelection)
            selectList += ' ' + s + ', '; 
        } else {
            selectList = 'Id,Name';
        }
        integer iPos = selectList.lastIndexOf(', ');
        if (iPos > -1){
            selectList = selectList.substring(0, iPos);
            selectedFields = selectList;
        }


 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ' Selection is .. ' + selectList));
        try{
            if (string.isBlank(sSoql) && string.isBlank(sSoqlChild))
                throw new customException();
            
        } catch (customException ce){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Please apply at least one filter!'));
            return;
        }
                
        try{
            refreshFilter(); //Ensure SOQL where clause reflects current selections
            string relationshipName = '';
            string foreignkeyField = '';
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PARENT SOQL IS .. ' + sSoql));            
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'CHILD SOQL IS .. ' + sSoqlChild));
            Schema.DescribeSObjectResult parentSchema = Schema.getGlobalDescribe().get(sobjectParentName).getDescribe();
                    childRelationships = parentSchema.getChildRelationships();
            if (childRelationships != null && string.isnotBlank(sSoqlChild)){
                for (Schema.ChildRelationship r :childRelationships){
                    Schema.SObjectType child = r.getChildSObject();
                    string sName = string.valueOf(child.getDescribe().getName());
                    string sLabel = string.valueOf(child.getDescribe().getLabel());
                    if (sName == sobjectChildName){
                        relationshipName = r.getRelationshipName();
                        foreignKeyField = r.getField().getDescribe().getName();
                        break;
                    }
                }
            }            
            if (filterParentByChild && string.isnotBlank(sSoqlChild)){
                list<Sobject> childList = new list<Sobject>();
                sSoqlChild = 'Select ' + foreignKeyField + ' from ' + sobjectChildName + ' where ' + sSoqlChild + ' order by name LIMIT 2000';
                
                try {
                    childList = Database.query(sSoqlChild);
                } catch (exception e){
                    childList = null;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, sSoqlChild)); 
                }
                if (childList != null){
                    if (childList.size() > 0){
                        list<string> parentIds = new list<string>();                                
                        for (sobject c :childList){
                            string parentValue = string.valueOf(c.get(foreignKeyField));
                            if (string.isnotBlank(parentValue)){
                                parentIds.add(parentValue);
                            }
                        }
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, sSoql + ' -- length is ' + sSoql.length() + ' @@@ ' + parentids)); 
                        if(string.isBlank(sSoql)){
                            sSoql = 'Select ' + selectList + ' from ' + sobjectParentName + ' where Id in :parentIds order by name LIMIT 2000';
                        } else {
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, sSoql + ' -- length is ' + sSoql.length())); 
                            sSoql = 'Select ' + selectList + ' from ' + sobjectParentName + ' where ' + sSoql + ' AND Id in :parentIds order by name LIMIT 2000';
                        }
                    }
                }
                
            } else {
                if (string.isnotBlank(sSoqlChild)){
                    if (string.isBlank(sSoql)){
                        sSoql = 'Select ' + selectList + ' ,(select name from ' + relationshipName + ' where ' + sSoqlChild + ') from ' + sobjectParentName +  ' order by name LIMIT 2000';
                    }else {
                        sSoql = 'Select ' + selectList + ' ,(select name from ' + relationshipName + ' where ' + sSoqlChild + ') from ' + sobjectParentName + ' where ' + sSoql + ' order by name LIMIT 2000';
                    }
                                                
                } else {
                    if (string.isBlank(sSoql)){
                        sSoql = 'Select ' + selectList +  ' from ' + sobjectParentName + ' order by name LIMIT 2000';
                    }else {
                        sSoql = 'Select ' + selectList +  ' from ' + sobjectParentName + ' where ' + sSoql + ' order by name LIMIT 2000';
                    }
                }       
            }
//ApexPages.getMessages().clear();                
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '1  ' + sSoql));            
            list<Sobject> sobjectList = new list<Sobject>();
            setCon = null;            
            if(string.isnotBlank(sSoql)){ 
                sobjectlist = Database.query(sSoql);
            
                soqlResult = sobjectlist;
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '2  ' + sobjectList));                              
                setCon = new ApexPages.StandardSetController(sobjectList);
                setCon.setPageSize(25);
                resultsList = sobjectList;
            }
            tabOpt = 'queryResults';
                        
        } catch (exception e){

            system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage() + ' : ' + e.getStackTraceString())); 

        }
                    
    }  
    public list<SelectOption> getAndOr()
    {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('AND', 'AND'));
        options.add(new SelectOption('OR', 'OR'));
    
        return options;
    }
    
    public string AndOrLogic {get; set;}
    
    public void addAndOr(){
        
        
    }
    
     // Returns the list of Sobjects displayed in the UI from the StandardSetController object
    public List<Sobject> getSobjects() {
    	try{
    		
    	            
	        if (setCon != null){
	            // Populate Sobject search result pagination variables
	            this.resultsPerPage = setCon.getPageSize();
	            this.currentPage = setCon.getPageNumber();
	            decimal rs = Decimal.valueOf(setCon.getResultSize());
	            this.totalPages = rs.divide(setCon.getPageSize(),0,system.roundingmode.up);
	    
	            if (setCon.getPageSize() > setCon.getResultSize()){
	                this.totalPages = 1;
	            } else {
	                rs = Decimal.valueOf(setCon.getResultSize());
	                this.totalPages = rs.divide(setCon.getPageSize(),0,system.roundingmode.up);
	            }
	      
	            return (List<Sobject>) setCon.getRecords();
	            // return resultsList;
	        } else {
	            return null;
	        }
    	} catch (exception e){
            system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;  	    	
	    }        
    }   

   public void removeFilter(){
        
        try{
            
            if(currentContext == sobjectParentName)
                sobjectFieldFilters.remove(filterIndexToRemove);
            if(currentContext == sobjectChildName)
                sobjectChildFieldFilters.remove(filterIndexToRemove);
            
            refreshFilter();
            //searchSobject();
            
        } catch (exception e){
            system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));           
        }
        
    }   
    
   // Sobject search result pagination method
    public void prevPage()
    {
       
        this.currentPage--;
        setCon.setPageNumber(this.currentPage);
      
    }

    // Sobject search result pagination method    
    public void nextPage()
    {

        this.currentPage++;
        setCon.setPageNumber(this.currentPage);
   
    }
    
    // Sobject search result pagination method    
    public void firstPage()
    {

        this.currentPage = 1;
        setCon.setPageNumber(1);

    }
    
    // Sobject search result pagination method    
    public void lastPage()
    {

        this.currentPage = integer.valueOf(this.totalPages);
        setCon.setPageNumber(integer.valueOf(this.totalPages)); 
    }

    //utility method to sort UI dropdown options in alphabetical order
    public static list<selectOption> selectOptionSortByLabel(list<selectOption>
                                                            selectOptionsToSort) {
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1){
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;
    
        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];


        for(selectOption SO : selectOptionsToSort){
            if (SO.getLabel() != pivotValue.getLabel()){
                if(SO.getLabel() <= pivotValue.getLabel()){
                    lessSelectOption.add(SO);
                }else if(SO.getLabel() > pivotValue.getLabel()){
                    greaterSelectOption.add(SO);   
                }
             }
        }

        list<selectOption> sortedSelectOptions = new list<selectOption>(); 
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return SortedSelectOptions;
    }

  //Wrapper class containing Field filter attributes
    public class SobjectField {
        
        public string fieldLabel {get;set;}
        public string fieldName  {get; set;}
        public string fieldType  {get;set;}
        public boolean isPicklist  {get;set;}
        public list<SelectOption> picklistValues  {get;set;}
        public string fieldValue  {get;set;}
        // public string fieldDateLiteral {get; set;}
        public string operator  {get;set;}
        public string andOr {get; set;}
 
        public String fieldDateLiteral {
                get {
        
                        return fieldDateLiteral;
                }
                set {
        
                        fieldDateLiteral = value;
                }
        }   
        
        public SobjectField() {
            
            fieldLabel = '';
            fieldName = '';
            fieldType = '';
            isPicklist = false;
            picklistValues = new list<SelectOption>();
            picklistValues.add(new SelectOption(' -- Select Value --', ' -- Select Value --'));
            fieldValue = '';
            fieldDateLiteral = ' -- Select Date Literal --';
            operator = '';
            andOr = 'AND';

            
        }
        
    }

    public PageReference exportCSV() {
                
        integer iPos = 0;
        selectedFields = '';
        resultValues = '';
        for (string fld :fieldSelection){
            selectedFields += fld + ',';
        }
        selectedFields = selectedFields.trim(); 
        iPos = selectedFields.lastIndexOf(',');
        if (iPos > -1){
            selectedFields = selectedFields.substring(0, iPos);
        }
                       
        for (sobject obj :soqlResult){
            for (string fld :fieldSelection){
                resultValues += obj.get(fld) + ',';
            }
            iPos = resultValues.lastIndexOf(',');
            if (iPos > -1){
                resultValues = resultValues.substring(0, iPos);
            }

            resultValues = resultValues.trim();
            resultValues = resultValues + '\n';        
        }    
        PageReference pageRef = new PageReference('/apex/CustomReportExport');
      
        return pageRef;   
    }

    public PageReference clearFilters(){

        sobjectFieldFilters = new list<SobjectField>();
        sobjectChildFieldFilters = new list<SobjectField>();
        sobjectChildFieldFilters2 = new list<SobjectField>();
        sobjectFields = new list<SobjectField>(); 
        sobjectChildFields = new list<SobjectField>();
        fieldSelection = new list<string>();
        selectedParentFields = new list<SelectOption>();
        selectedChildFields = new list<SelectOption>();
        objectMap = new map<string, list<string>>();
        sobjectParentName = '';
        sobjectChildName = '';
        sobjectSingleName = '';
        currentPage = 1;
        totalPages = 1;
        setupObjects();
        sSoql = '';
        sSoqlChild = '';
            
        return null;                
                        
                
    }
    
    // Multiselect controller variables    
    public SelectOption[] selectedParentFields { get; set; }
    public SelectOption[] selectedChildFields { get; set; }

    private void addSelectedFields() {
        
        fieldSelection = new list<string>();
        
        for ( SelectOption so : selectedParentFields ) {
            if(!so.getValue().contains('Select Field'))
                fieldSelection.add(so.getValue());
        }
  
    }        

    private void addSelectedChildFields() {
        
        fieldChildSelection = new list<string>();
        
        for ( SelectOption so : selectedChildFields ) {
            if(!so.getValue().contains('Select Field'))
                fieldChildSelection.add(so.getValue());
        }
  
    }
    
    public pageReference addSecondFilter(){
        secondChild = true;
        sobjectChildFieldFilters = new list<SobjectField>();
        sobjectChildFieldFilters2 = new list<SobjectField>();
        sobjectChildFields = new list<SobjectField>();
        sobjectChildFields2 = new list<SobjectField>();
        selectedChildFields = new list<SelectOption>();
        sobjectChildName = '';
        sSoqlChild = '';        
        childObjectNames =new list<SelectOption>();  
        Schema.DescribeSObjectResult parentSchema = Schema.getGlobalDescribe().get(sobjectParentName).getDescribe();
        childRelationships = parentSchema.getChildRelationships();
        map<string, string> chkMap = new map<string, string>();
        for(Schema.ChildRelationship c :childRelationships){
                        string objName = c.getChildSObject().getDescribe().getName();
                        string objLabel = c.getChildSObject().getDescribe().getLabel();
                        if (!chkMap.containsKey(objName))
                                childObjectNames.add(new SelectOption(objName, objLabel));
                                
                        chkMap.put(objName, objName);   

        }        
        
        return null;            
    }        

    public pageReference applySecondFilter(){
 
		map<string, string> parentIdMap = new map<string, string>();  
		list<Sobject> childList = new list<Sobject>();
		list<Sobject> soqlResult2 = new list<Sobject>(); 			   	
    	
    	try {            
	        Schema.DescribeSObjectResult parentSchema = Schema.getGlobalDescribe().get(sobjectParentName).getDescribe();
	        childRelationships = parentSchema.getChildRelationships();
	        string relationshipName = '';
	        string foreignKeyField = '';
	        if (childRelationships != null){
	            for (Schema.ChildRelationship r :childRelationships){
	                Schema.SObjectType child = r.getChildSObject();
	                string sName = string.valueOf(child.getDescribe().getName());
	                string sLabel = string.valueOf(child.getDescribe().getLabel());
	                if (sName == sobjectChildName){
	                    relationshipName = r.getRelationshipName();
	                    foreignKeyField = r.getField().getDescribe().getName();
	                    break;
	                }
	            }
	        }               
			list<string> parentIds = new list<string>();
			parentIds = new list<string>();
                              
	        for (Sobject obj :soqlResult){
	            string parentValue = string.valueOf(obj.get('Id'));
	            if (string.isnotBlank(parentValue)){
	                parentIds.add(parentValue);
	            }
	        }
	        sSoqlChild = 'Select ' + foreignKeyField + ' from ' + sobjectChildName + ' where ' + sSoqlChild + ' and ' + foreignKeyField + ' in :parentIds  order by name LIMIT 2000';
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,sSoqlChild)); 
	        try {
	            childList = Database.query(sSoqlChild);
	        } catch (exception e){
	            childList = null;
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, sSoqlChild)); 
	        }
	        if (childList != null){
	            if (childList.size() > 0){
	                parentIds = new list<string>();                                
	                for (sobject c :childList){
	                    string parentValue = string.valueOf(c.get(foreignKeyField));
	                    if (string.isnotBlank(parentValue)){
	                        parentIdMap.put(parentValue, parentValue);
	                    }
	                }
	            }
	        }
	
			integer index = 0;
			list<integer> removeIndexList = new list<integer>();


			for (Sobject obj :soqlResult){
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,string.valueOf(obj.get('Id'))) ); 
				if(!parentIdMap.containsKey(string.valueOf(obj.get('Id')))){
					removeIndexList.add(index);
				}
				index++;
			}
			// remove items 
			if (!removeIndexList.isEmpty()){
				integer itemsRemoved = 0;									
				for (integer i :removeIndexList){															
					soqlResult.remove( i - itemsRemoved);
					itemsRemoved ++;
				}
	
			}

	        setCon = new ApexPages.StandardSetController(soqlResult);
	        setCon.setPageSize(25);
	        resultsList = soqlResult;           
    	} catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString()); 
 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,string.valueOf(childList.size()))); 

		       
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage() + ' : ' + e.getStackTraceString())); 
    		return null;
    	}
                        
        return null;
    }
    
    public class customException extends Exception{}

}