global with sharing class MockBadRequestWeatherForService implements HttpCalloutMock  {
    
    global HttpResponse respond(HttpRequest req) {
    
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(500);
        res.setBody('{"error":"Internal Server Error"}');

        return res;

    }
}