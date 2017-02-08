@isTest
global class InstagramMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        String namespace = InstagramTestClass.userEndpoint;
        String prefix = 'mockPrefix';

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        gen.writeStringField('full_name', InstagramTestClass.fullName);
        gen.writeStringField('bio', InstagramTestClass.bio);
        gen.writeStringField('website', InstagramTestClass.website);        
        gen.writeStringField('profilePicture', InstagramTestClass.profilePicture);
        gen.writeStringField('access_token', InstagramTestClass.oauthToken);
        gen.writeEndObject();

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(gen.getAsString());
        res.setStatusCode(200);
        return res;
    }
}