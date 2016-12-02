global without sharing class mblTimelineEventStreetEntryController {

    public mblTimelineEventStreetEntryController(FirstContact controller) {

    }

    
    public Timeline_Event__c timelineEvent {get; set;}
    public static string longitude {get; set;}
    public static string latitude {get;set;}
    public static map<string, string> encounterTypeMap;
    public static map<string, string> eventMap;

    
    public mblTimelineEventStreetEntryController(ApexPages.StandardController controller){
        
        timelineEvent = new Timeline_Event__c();
    }

    
    // Method called by Submit button to save tyre log entry
    @RemoteAction
    global static string saveRecord(TLEData tleData) {
                
        string returnValue = 'Success';
        string accountId = '';
        string personId = '';

        try {
        
        list<selectoption> rtList = populateRecordTypeMaps();
        User u = [Select Id, Email, Default_Project_Id__C, Default_Project_Name__C from User where Id=:UserInfo.getUserId()];
          
        if (tleData != null)
            accountId = tleData.accountId;
        
        
        if(string.isnotBlank(accountId)){
            Account person = [SELECT Id, Name, PersonContactId FROM Account WHERE Id = :accountId];
            personId = person.PersonContactId;
            
            //DateTime dt = DateTime.parse(tleData.dte);
            //string utcDt = dt.format('dd-MM-yyyy', 'UTC');
  
            tleData.accountId = personId;
            
            Timeline_Event__c timeline = new Timeline_Event__c();
            timeline.RecordTypeId = tleData.recordtype;
            timeline.Encounter_Type__c = encounterTypeMap.get(tleData.recordtype);
            timeline.Event__c = eventMap.get(tleData.recordType);
            
            timeline.Project_Team__c = u.Default_Project_Id__c;
            
            timeline.Client__c = tleData.accountId;
            timeline.Date__c = system.Now();
            timeline.Time_of_contact__c = tleData.tme;
            timeline.Latitude_Longitude__c = tleData.lat + ',' + tleData.lng;
            timeline.Location_URL__c = 'https://www.google.co.uk/maps/place/'+ tleData.lat +', '+ tleData.lng;
            timeline.Ward__c = tleData.ward;
            timeline.Street_site_borough__c = tleData.borough;
            timeline.Borough_Street_Site__c = tleData.boroughsite;           
            timeline.Postcode__c = tleData.postcode;
//            timeline.Street_name__c = tleData.street;     
            
//            timeline.SF1_Created__c =  true;
            
            insert timeline;
             
        }        

            
        } catch (exception e){

            returnValue = 'A technical error has occurred .. ' + e.getMessage() + ' : ' + e.getStackTraceString();
            system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());
            return returnValue;            
            
        }
        return returnValue;
    }


        public List<SelectOption> recordTypesList {
            get {
                recordTypesList = populateRecordTypeMaps();
                return recordTypesList;
            }
            private set;
        } 

        @RemoteAction
        global static string getBoroughStreetSites(string boroughFound) {
            // return JSON string .. eg. { "1": "test 1", "2": "test 2" };  
            JSONGenerator gen = JSON.createGenerator(true); 
            gen.writeStartObject(); 
                        
            map<String, string> boroughMap = PicklistUtilities.getPicklistValues('Timeline_Event__c', 'Borough_Street_Site__c', null);          
            for (string s :boroughMap.keySet()){                
                list<string> item = s.split('-');
                string boroughName = item[0].trim();
                if (boroughName == boroughFound){                   
                    gen.writeStringField(s, boroughMap.get(s));
                }
            }
            gen.writeEndObject();
            
            return gen.getAsString();

        }
        
        private static List<SelectOption> populateRecordTypeMaps(){

            List<SelectOption> returnList = new List<SelectOption>();
                    
            map<string, string> rtMap = new map<string, string>();
            encounterTypeMap = new map<string, string>();
            eventMap = new map<string, string>();
                
            Id rtId = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('Street Contact - not bedded down').RecordTypeId;
            rtMap.put(string.valueOf(rtId), 'Street Contact - not bedded down');
            encounterTypeMap.put(string.valueOf(rtId), 'Street Contact');
            eventMap.put(string.valueOf(rtId), 'Street Contact - Not Bedded Down');
                                    
            rtId = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('Street Contact - bedded down').RecordTypeId;
            rtMap.put(string.valueOf(rtId), 'Street Contact - bedded down');
            encounterTypeMap.put(string.valueOf(rtId), 'Street Contact');
            eventMap.put(string.valueOf(rtId), 'Street Contact - Bedded Down');                 
                    
                    
            rtId = Schema.SObjectType.Timeline_Event__c.RecordTypeInfosByName.get('Street Count').RecordTypeId;
            rtMap.put(string.valueOf(rtId), 'Street Count');                    
            encounterTypeMap.put(string.valueOf(rtId), 'Street Count');
            eventMap.put(string.valueOf(rtId), 'Street count');
        
            // Now add combined collection to options list to return to UI
            for (string s : rtMap.keySet()) {
                returnList.add(new SelectOption(s, rtMap.get(s)));
            }
                    
            return returnList;          

        }
        
        public List<SelectOption> timeList {
            get {
                if (timeList == null)
                {
                    
                    timeList = new list<SelectOption>();
                    map<string, string> timeMap = PicklistUtilities.getPicklistValues('Timeline_Event__c', 'Time_of_contact__c', null);

                    // Now add combined collection to options list to return to UI
                    for (string s : timeMap.keySet()) {
                        timeList.add(new SelectOption(s, timeMap.get(s)));
                    }                   
                    timeList = PicklistUtilities.selectOptionSortByLabel(timeList);
                }                   
                
                return timeList;
            }
            private set;
        } 


   @RemoteAction
    global static String getMapPoint(String url, string sLnglat) {
        
        if(string.isnotBlank(sLngLat)){
            list<string> coords = sLngLat.split(',');
            if(!coords.isEmpty()){
                longitude = coords[0];
                latitude = coords[1];
            }
        }
        
        Http h = new Http();

        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);       
        //return res.getBody();
        string sBody = res.getBody();
        string sReturn = getLocalAuthority(sBody); 
system.debug('@@@ sBody  ' + sBody);        
        string sMsg = '';

        sReturn = sReturn + '^' + sMsg;
        
        string sWard = getWard(sBody);
        string sBorough = getBorough(sBody);

system.debug('@@@ Borough  ' + sBorough);
               
        sReturn = sReturn + '^'  + sWard + '^' + sBorough;
        
        //string sAddress = getAddress();
        
        return sReturn;
    }
    
    
/*** Server side call to Google Maps - not required, as call is made from client browser    
    private static string getAddress(){
        
        string sReturn = '';
        string endPoint = 'https://maps.googleapis.com/maps/api/geocode/json';
        endpoint += '?' + latitude+','+longitude;
        
        Http h = new Http();

        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);             
     
        //return res.getBody();
        string sBody = res.getBody();
        
system.debug(' @@@@  address ?? ' + sBody);
        
        
        return sReturn;
                
    }
*/    
    private static string getWard(string sJSON){
        
        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sQuote = '"';
        boolean found  = false;

        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'name') {
                    string sTemp = parser.getText();
                    sValue = sTemp;
                }
                else if(fieldName == 'type'){
                    string sTemp2 = parser.getText();
                    if (sTemp2 == 'LBW'){
                        found = true;
                        break;
                    } 
                }
            
            }
        }

        if (!found){
            sValue = '';
        }
        return sValue;      
    
    }

    private static string getBorough(string sJSON){

        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sQuote = '"';
        boolean found  = false;
        
        map <string, string> boroughList = PicklistUtilities.getPicklistValues('Timeline_Event__c', 'Street_site_borough__c', null);

        while (parser.nextToken() != null) {
            if (found)
                break;
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'name') {
                    string sTemp = parser.getText();
                    sValue = sTemp;
                    integer pos1 = sValue.indexOf(' ');
                    if (pos1 > -1){
                        sValue = sValue.subString(0, pos1);
                    }
                }
                else if(fieldName == 'type'){
                    string sTemp2 = parser.getText();
                    if (sTemp2 == 'LBO'){
system.debug ('@@@@  1  ' + sValue ); 
                        found = true;
                        if (boroughList.containsKey(sValue)){
                            break;
                        } else {
                            boolean matched = false;
                            for (string key :boroughList.keySet()){
                                integer pos2 = key.indexOf(' ');
                                if (pos2 > -1) {
                                    string chkValue = key.subString(0, pos2);
system.debug ('@@@@  key  2  ' + key + ' - ' + sValue + ' - ' + chkValue);                                    
                                    if (chkValue == sValue){
                                        sValue = key;
system.debug ('@@@@  key  3  ' + key + ' - ' + sValue  );                                       
                                        matched = true;                                         
                                        break;     
                                    }     
                                }    
                             
                            }
                            if (!matched){
                                sValue = '';
                            }     

                        }                            
                    } 

                }
            
            }
        }
system.debug ('@@@@  key  4  ' + sValue  );           
        if (!found){
            sValue = '';
        }
        return sValue; 
    }

    
    private static string getLocalAuthority(string sJSON){

        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sQuote = '"';

        map <string, string> LACodes = new map <string, string>();
        LACodes.put('UTA', 'UTA');
        LACodes.put('DIS', 'DIS');
        LACodes.put('LBO', 'LBO');
        LACodes.put('MTD', 'MTD');

        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'name') {
                    string sTemp = parser.getText();
                    if (sTemp.containsIgnoreCase('Council')){
                        sValue = sTemp;
                    }
                }
                else if(fieldName == 'type'){
                    string sTemp2 = parser.getText();
                    if (LACodes.containsKey(sTemp2)){
                        break;
                    } 
                }
            
            }
        }
        return sValue;
    }





    //Data structure wrapper class to transport data back and forward between controller and UI
    global class TLEData {

        global Id accountId { get; set; }
        global string lng { get; set; }
        global string lat { get; set; }
        global string postcode { get; set; }
        global string street { get; set; }
        global string ward {get; set;}
        global string dte {get; set;}
        global string tme {get; set;}
        global string borough {get; set;}
        global string boroughsite {get; set;}
        global string recordtype {get; set;}
               
        public TLEData(){

            accountId = null;
            lng = '';
            lat = '';
            postcode = '';
            street = '';
            ward = '';
            dte = '';
            tme = '';
            borough = '';
            boroughsite = '';
            recordtype = '';
        
        }       
    
    }    
}