/**
Local Authority Maps Location API Mock HTTP Response generator used only for testing.
 */
@isTest


global class MockLocationAPI implements HttpCalloutMock{
global string borough{get; set;}    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        string sBody = '';
        string sQuote = '"';
        string sEndPoint = req.getEndpoint();
        string sToken = req.getHeader('Authorization');
        if (string.isBlank(sToken)){
            sToken = '';
        }
        string sMethod = req.getMethod();
        if (string.isBlank(sMethod)){
            sMethod = '';
        }
        string sReqBody = req.getBody();
        if (string.isBlank(sReqBody)){
            sReqBody = '';
        }
    
        if (sEndPoint.contains('test')){
            // Create a fake response
            res = new HttpResponse();

            JSONGenerator gen = JSON.createGenerator(true);	
			gen.writeStartObject();	
			gen.writeStringField('name', 'Test Council');
			gen.writeStringField('type', 'UTA');
			gen.writeEndObject();
			gen.writeStartObject();	
			gen.writeStringField('name', 'Test Ward');
			gen.writeStringField('type', 'LBW');
			gen.writeEndObject();
			gen.writeStartObject();	
			gen.writeStringField('name', borough);
			gen.writeStringField('type', 'LBO');
			gen.writeEndObject();
			
			sBody = gen.getAsString();			
			/*            
            sBody = 'areas: {';
            sBody += '1: {';
            sBody += sQuote + 'name' + sQuote + ' : ' +  sQuote + 'Test Council' + sQuote + ',';
            sBody += sQuote + 'type' + sQuote + ' : ' + sQuote +  'UTA' + sQuote;
            sBody += '},';
            sBody += '2: {';
            sBody += sQuote + 'name' + sQuote + ' : ' +  sQuote + 'Test Ward' + sQuote + ',';
            sBody += sQuote + 'type' + sQuote + ' : ' + sQuote +  'LBW' + sQuote;
            sBody += '},';
            sBody += '3: {';
            sBody += sQuote + 'name' + sQuote + ' : ' +  sQuote + 'Test Borough' + sQuote + ',';
            sBody += sQuote + 'type' + sQuote + ' : ' + sQuote +  'LBO' + sQuote;
            sBody += '}}'; 
            */
                       
            res.setHeader('Content-Type', 'application/json');
            res.setBody(sBody);
            res.setStatusCode(200);         
        }
        
        return res;
        
    }
    
}