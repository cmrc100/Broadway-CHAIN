public with sharing class StreetContactMapController {

    public Timeline_event__c tl {get;set;}
    
    public string tlId{get;set;}
    public string address{get;set;}
    public string localAuthority{get;set;}
    public string lngLat{get;set;}
    public string lng{get;set;}
    public string lat{get;set;}
    public string msg{get;set;}
    public string postcode{get;set;}
    public string ward{get;set;}
    public string borough {get; set;}    
    
    public StreetContactMapController(ApexPages.StandardController controller) {

    }

   @RemoteAction
    public static String getMapPoint(String url, string sAddress, string soutRefId, string sLnglat) {
        Http h = new Http();
        
        //string outRefId = System.currentPagereference().getParameters().get('id');        
        
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
        //sMsg = getLocalAuthorityId (sReturn );
        sReturn = sReturn + '^' + sMsg;
        
        string sWard = getWard(sBody);
        string sBorough = getBorough(sBody);
system.debug('@@@ Borough  ' + sBorough);                
        sReturn = sReturn + '^'  + sWard + '^' + sBorough;
        
        string sLSOA = getOA(sBody, 'OLF');
        
        string sMSOA = getOA(sBody, 'OMF');
        
        sReturn = sReturn + '^' + sLSOA + '^' + sMSOA; 
        
        string wardCode = getWardCode(sBody);
        
        sReturn = sReturn + '^' + wardCode;
                
        return sReturn;
    }

    private static string getOA(string sJSON, string sType){

        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sName = '';
        string sCode = '';

        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'ons') {
                    sCode = parser.getText();
                }
                else if(fieldName == 'name'){
                    sName = parser.getText();
                } else if (fieldName == 'type'){
					string sTemp = parser.getText();
                    if (sTemp == sType){
                        break;
                    } 
                }
            
            }
        }
        sValue = sName + '^' + sCode;
        return sValue;
    }
        
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

    private static string getWardCode(string sJSON){
        
        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sQuote = '"';
        boolean found  = false;

        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'ons') {
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

    /*
    private static String getLocalAuthorityId (string sLocalAuthority){      
       string sReturn = '';
       try{
            list<Local_authority__c>laList = [select id from Local_authority__c where name = :sLocalAuthority];
            string laId = laList[0].Id;
            
            return sReturn;
        } catch (exception e){
            
            sReturn = 'Local Authority not found! - Please check Local Authority configuration table, record cannot be saved';
            system.debug(e.getMessage() + ' : ' + e.getStackTraceString() + ' -- ' + sReturn);
            return sReturn;
            
        }    
    
    
    }
	*/
	
    public void saveLocation(){
       
        string laId = '';

        try{/* //validate Local Authority
            list<Local_authority__c>laList = [select id from Local_authority__c where name = :localAuthority];
            laId = laList[0].Id;
            if (laId.length() > 0){ //&& !string.isBlank(outRefId)) {  
            
                Outreach_Referrals__c wkd = [select Street_site__c, Latitude_Longitude__c, Local_authority_LU__c, Town_city_or_Postcode__c from Outreach_Referrals__c where id =:outRefId];
                
                wkd.Street_site__c = address;
                wkd.Latitude_Longitude__c = lng;
                wkd.Local_authority_LU__c = laId;
                wkd.Town_city_or_Postcode__c = postcode;
                
                update wkd;
            
            } else {
                ApexPages.addMessage(new ApexPages.Message
                        (ApexPages.Severity.ERROR, 'Local Authority not found!' ));

            }
            */
        } catch (exception e){        
             system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
             ApexPages.addMessage(new ApexPages.Message
                        (ApexPages.Severity.ERROR, 'Local Authority Error ... ' + e.getMessage() ));
        

        }
        
    }

}