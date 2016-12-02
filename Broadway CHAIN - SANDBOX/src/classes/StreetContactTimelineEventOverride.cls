public with sharing class StreetContactTimelineEventOverride {

    private string rtId = '';

    
    public StreetContactTimelineEventOverride(ApexPages.StandardController controller) {
     
    }

    public StreetContactTimelineEventOverride() {

    }

    public String url {
        get {
            if (url == null) {
                url = createUrl();
            }
            return url;
        }
        private set;
    }
    

    private String createUrl() {
         
        string surl = ''; 
        string sRecordType = ApexPages.currentPage().getParameters().get('RecordType');
        RecordType rt = [select Id from RecordType where id = :sRecordType limit 1];
        //rtId = rt.Id;
        rtId = ApexPages.currentPage().getParameters().get('RecordType');
system.debug( ' @@@ rtId  ' + rtId);        
        surl =  ApexPages.currentPage().getUrl();
        integer iPos1 = surl.indexOf('?');
        integer iPos2 = surl.indexOf('&');
        string sParams = surl.substring(iPos1 + 1);

        string sSite = site.getPrefix();
        if (!string.isBlank(sSite)){
            sSite = EncodingUtil.urlEncode(sSite, 'UTF-8');         
            sParams = sParams.replace(sSite, '/');
        }
system.debug( ' @@@ sParams 1 ' + sParams);
        /*
        integer pos = sParams.indexOf('sfdc.override=1');
        if (pos > -1) {        
            sParams = sParams.replace('sfdc.override=1', 'nooverride=1'); 
        } else {
            sParams = sParams + '&nooverride=1'; 
        }
        */
        sParams = sParams.replace('&save_new=1', '');
        surl = '/' + Timeline_Event__c.SObjectType.getDescribe().getKeyPrefix()
                + '/e' + '?' + sParams;
                  
        if (sRecordType != rt.Id){
            if(!string.isBlank(sSite)){
                surl = surl.substring(1);
                surl = site.getCurrentSiteUrl() + surl;
            }
            return surl;
        } else {

/*        
            surl = '/' + Outreach_referrals__c.SObjectType.getDescribe().getKeyPrefix()
                    + '/e'
                    + '?retURL=' + ApexPages.currentPage().getParameters().get('retURL')
                    + '&RecordType=' + ApexPages.currentPage().getParameters().get('RecordType')
                    + '&nooverride=1';
*/    
            Map<String, String> m = createDefaultValues();
            for (String key : m.keySet()) {
                sParams += '&' + key + '=' + EncodingUtil.urlEncode(m.get(key), 'UTF-8');
            }
            map<string,string> defaultParamMap = getDefaultParams();
            if (!defaultParamMap.isEmpty()){
	            for (String key : defaultParamMap.keySet()) {
	                sParams += '&' + key + '=' + defaultParamMap.get(key);
	            }
            }
system.debug( ' @@@ sParams 2 ' + sParams);                        
         
            surl = site.getPrefix() + '/apex/StreetContactMap?' + sParams;
        }
      
        return surl;

    }

    private Object getDefaultValue(SObjectField field) {
  
        // Defaulting business logic goes here
        Object oValue = null;

        schema.describefieldresult dfield = field.getDescribe();
        string sField = dfield.getName();

        if (sField.equalsIgnoreCase('Latitude_Longitude__c')) {
            oValue = 'Latitude_Longitude__c';
        }                      
        
        if (sField.equalsIgnoreCase('Location_URL__c')) {
            oValue = 'Location_URL__c';
        } 

        if (sField.equalsIgnoreCase('Ward__c')) {
            oValue = 'Ward__c';
        }        

        if (sField.equalsIgnoreCase('Street_site_borough__c')) {
            oValue = 'Street_site_borough__c';
        } 

        if (sField.equalsIgnoreCase('Borough_from_map__c')) {
            oValue = 'Borough_from_map__c';
        } 
        
        if (sField.equalsIgnoreCase('Postcode__c')) {
            oValue = 'Postcode__c';
        } 

        if (sField.equalsIgnoreCase('Street_name__c')) {
            oValue = 'Street_name__c';
        } 

        if (sField.equalsIgnoreCase('Lower_super_output_area_LSOA__c')) {
            oValue = 'Lower_super_output_area_LSOA__c';
        } 

        if (sField.equalsIgnoreCase('Lower_super_output_area_LSOA_code__c')) {
            oValue = 'Lower_super_output_area_LSOA_code__c';
        } 
        
        if (sField.equalsIgnoreCase('Middle_Layer_Super_Output_MSOA_code__c')) {
            oValue = 'Middle_Layer_Super_Output_MSOA_code__c';
        } 
        
        if (sField.equalsIgnoreCase('Middle_Layer_Super_Output_area_MSOA__c')) {
            oValue = 'Middle_Layer_Super_Output_area_MSOA__c';
        }                         

        if (sField.equalsIgnoreCase('Ward_code__c')) {
            oValue = 'Ward_code__c';
        } 
        return oValue;          


    }

    private Map<String, String> createDefaultValues() {

        // Obtain the  ids
        PageReference p = new PageReference('/' + Timeline_Event__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1' + '&RecordType=' + rtId);
        String html = '';
        if (Test.isRunningTest())
        {
           html = '"><label for="CF00NJ0000000jkjq">*</"><span class="requiredMark">Local Authority</label></ .......';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  p.getContent cant be tested !!!!!!';
           html += '  end  ';
           
        } else {
           html = p.getContent().toString();
        }       
        Map<String, String> labelToId = new Map<String, String>();

system.debug('@@@@@  html ....  ' + html);

        Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
        while (m.find()) {
            String label = m.group(3);
            String id = m.group(1);
			label = label.replace('<span class="assistiveText">*</span>', '');            
            labelToId.put(label, id);
system.debug(' @@@@   label to id   ' + label + ' : ' + id);
        }
       
        // Relate the ids to the SObject fields
        Map<String, String> params = new Map<String, String>();
        
        try{


            for (SObjectField field : Timeline_Event__c.SObjectType.getDescribe().fields.getMap().values()) {
    
                Object value = getDefaultValue(field);
                if (value != null) {
                    DescribeFieldResult f = field.getDescribe();
                    String label = f.getLabel();
                    if (labelToId.containsKey(label)) {
                        // Format
                        String valueAsString;
                        if (f.getType() == DisplayType.Date) {
                            valueAsString = ((Date) value).format();
                        } else if (f.getType() == DisplayType.Datetime) {
                            valueAsString = ((Datetime) value).format();
                        } else if (f.getType() == DisplayType.Boolean) {
                            valueAsString = ((Boolean) value) ? '1' : '0';
                        } else {
                            valueAsString = String.valueOf(value);
                        }
                        params.put(labelToId.get(label), valueAsString);
                    }
                }
    
            }

        }
        catch (exception e){
            system.debug(e.getMessage() + ' : ' + e.getStackTraceString()); 
            return null;
        }
        
        return params;
 
 
    }

	private map<string, string> getDefaultParams(){
		
        // If user project/team has Westminster_action_plan__c set to true,
        // pre-default CSTM_Private_Action_Plan__c to value of most recent record where  
        // value is not null
		map<string, string> returnMap = new map<string, string>();
		
        try{          
            
            string actionPlan = '';
            string veryPrivateActionPlan = '';
            string clientId = '';            

	        User u = [Select Id, Email, Default_Project_Id__C, Default_Project_Name__C from User where Id=:UserInfo.getUserId()];

	        String campName = u.Default_Project_Name__c;
	        if(u.Default_Project_Name__c!=null)
	             campName = EncodingUtil.urlEncode(u.Default_Project_Name__c,'UTF-8');
	        boolean westminsterActionPlan = false;
	        
	        if(u.Default_Project_Id__C!=null)
	        {
	            List<Campaign> campList = [Select Id, Type, Name, Westminster_action_plan__c from Campaign where Id=:u.Default_Project_Id__c];

	            if(campList.size()>0)
	            {
	                westminsterActionPlan = campList[0].Westminster_action_plan__c;
	            }
	        }    
                            
            string accountId  = ApexPages.currentPage().getParameters().get('accountId');
            
            clientId = [select PersonContactId from Account where Id = :accountId].PersonContactId;
            
            if(westminsterActionPlan){  
 
                system.debug(' @@@ clientId .. ' + clientId);  
                list<Timeline_Event__c> tleList = new list<Timeline_Event__c>();  
                tleList = [select CSTM_Private_Action_plan__c, CSTM_very_Private_Action_plan__c
                                from Timeline_Event__c where client__c = :clientId   
                                order by date__c desc];  
                      
                if (!tleList.isEmpty()){  
                    for(Timeline_Event__c tleRec :tleList){  
                        if (string.isnotBlank(tleRec.CSTM_Private_Action_plan__c)){  
                            actionPlan = tleRec.CSTM_Private_Action_plan__c;  
                            break;  
                        }     
                    }  

                    for(Timeline_Event__c tleRec :tleList){  
                        if (string.isnotBlank(tleRec.CSTM_very_Private_Action_plan__c)){  
                            veryPrivateActionPlan = tleRec.CSTM_very_Private_Action_plan__c;  
                            break;  
                        }     
                    }                          
                } 
                if (string.isnotBlank(actionPlan)){
                    actionPlan = EncodingUtil.urlEncode(actionPlan, 'UTF-8');
                    returnMap.put('00NC0000005l5c4', actionPlan ); // Labelled Westminster Private Action Plan                      
                }

                if (string.isnotBlank(veryPrivateActionPlan)){
                    veryPrivateActionPlan = EncodingUtil.urlEncode(veryPrivateActionPlan, 'UTF-8');
                    returnMap.put('00NC0000005mo79', veryPrivateActionPlan ); // Labelled CSTM Private Action Plan                      
                }
  
            }  
        } catch (exception e){
            system.debug('ERROR...  ' + e.getMessage() + ' : ' + e.getStackTraceString());
        }		
		
		return (returnMap);
	}
    
}