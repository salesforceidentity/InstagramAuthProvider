@isTest
global class InstagramMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        String namespace = InstagramTestClass.userEndpoint;
        String prefix = 'mockPrefix';

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('data');
        gen.writeStartObject();
            gen.writeobjectfield('id', InstagramTestClass.id);
            gen.writeobjectfield('username', InstagramTestClass.username);        
            gen.writeobjectfield('full_name', InstagramTestClass.fullName);
            gen.writeobjectfield('bio', InstagramTestClass.bio);
            gen.writeobjectfield('website', InstagramTestClass.website);        
            gen.writeobjectfield('profile_picture', InstagramTestClass.profilePicture);
            gen.writeobjectfield('locale', '');
        gen.writeendobject();
        gen.writeobjectfield('access_token', InstagramTestClass.oauthToken);
        gen.writeendobject();


        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(gen.getAsString());
        res.setStatusCode(200);
        return res;
    }
}