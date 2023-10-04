public class HttpCalloutExample {
    private static final String ENDPOINT_URL = 'https://postman-echo.com/get?foo1=bar1&foo2=bar2';   
    public static void makeHttpCallout() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT_URL);
        request.setMethod('GET');
        Http http = new Http();
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                System.debug('HTTP Response: ' + responseBody);
            } else {
                System.debug('HTTP Request failed with status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('HTTP Request failed with exception: ' + e.getMessage());
        }
    }
}