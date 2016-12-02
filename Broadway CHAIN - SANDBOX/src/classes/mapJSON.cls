public with sharing class mapJSON {
    public mapJSON(ApexPages.StandardController controller) {
        // nothing required here.
    }
    
    @RemoteAction
    public static String getMapPoint(String url) {
        Http h = new Http();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res.getBody();
    }
}