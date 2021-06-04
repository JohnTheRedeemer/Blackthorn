@isTest
global class HttpMockBuilder implements httpCalloutMock {

    String body { get; set; }
    String status { get; set; }
    Integer code { get; set; }

    public HttpMockBuilder() {

        status = 'OK';
        code = 200;
        body = '{  }';
    }

    public HttpMockBuilder(String b, Integer c, String s) {

        status = s;
        code = c;
        body = b;
    }

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setBody(body);
        res.setStatusCode(code);
        res.setStatus(status);
        return res;
    }
}
