global class Instagram implements Auth.AuthProviderPlugin {
               
               public String redirectUrl; // use this URL for the endpoint that the authentication provider calls back to for configuration
               private String key;
               private String secret;
               private String authUrl;    // application redirection to the Instgram website for authentication and authorization
               private String accessTokenUrl; // uri to get the new access token from Instagram  using the GET verb
               private String customMetadataTypeApiName; // api name for the custom metadata type created for this auth provider
               private String userAPIUrl; // api url to access the user in Instagram
               private String userAPIVersionUrl; // version of the user api url to access data from Instagram
       
               global String getCustomMetadataType() {
                   return 'Instagram_Identity__mdt';
               }
       
               global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
                   System.debug(authProviderConfiguration);
                   authUrl = authProviderConfiguration.get('Auth_URL__c');
                   key = authProviderConfiguration.get('clientID__c');
                   redirectUrl = authProviderConfiguration.get('redirectURL__c');
                   String url = authUrl + '?client_id='+ key +'&response_type=code&redirect_uri='+ redirectUrl + '&state=' + stateToPropagate;
                   System.debug(url);
                   return new PageReference(url);
                }
        
               global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
                   key = authProviderConfiguration.get('clientID__c');
                   secret = authProviderConfiguration.get('clientSecret__c');
                   accessTokenUrl = authProviderConfiguration.get('Access_Token_URL__c');
                   redirectURL = authProviderConfiguration.get('redirectURL__c');
                   
                   Map<String,String> queryParams = state.queryParameters;
                   String code = queryParams.get('code');
                   String sfdcState = queryParams.get('state');
                   
                   Http http = new Http();
                   HttpRequest req = new HttpRequest();
                   String url = accessTokenUrl;
                   req.setEndpoint(url);
                   req.setHeader('Content-Type','application/json');
                   req.setMethod('POST');
                   //Instragram expects these values post'ed as if in a form
                   req.setBody('client_id=' + key + '&client_secret=' + secret + '&redirect_uri=' + redirectURL + '&grant_type=authorization_code' + '&code=' + code);
                   
                   HTTPResponse res = http.send(req);
                   String responseBody = res.getBody();
                   Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                   String token = (String)responseMap.get('access_token');
                   
                   return new Auth.AuthProviderTokenResponse('Instagram', token, null, sfdcState);
                }
    
    
                 global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
                   System.debug('In getUserInfo');
                     //Here the developer is responsible for constructing an Auth.UserData object
                     String token = response.oauthToken;
                     HttpRequest req = new HttpRequest();
                     userAPIUrl = authProviderConfiguration.get('UserEndpoint__c');
                     
                     // Instagram requires access token in the query string
                     req.setEndpoint(userAPIUrl + '?access_token=' + token);
                     req.setHeader('Content-Type','application/json');
                     req.setMethod('GET');
                     
                     Http http = new Http();
                     HTTPResponse res = http.send(req);
                     String responseBody = res.getBody();
                     Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                     Map<String, Object> userMap = (Map<String, Object>)responseMap.get('data');

                     String id = (String)userMap.get('id');
                     String username = (String)userMap.get('username');
                     String profilePicture = (String)userMap.get('profile_picture');
                     String website = (String)userMap.get('website');
                     String bio = (String)userMap.get('bio');
                     String fullName = (String)userMap.get('full_name');                     
                     Map<String,String> provMap = new Map<String,String>();
                     provMap.put('profilePicture', profilePicture);
                     provMap.put('bio', bio);
                     return new Auth.UserData(id, null, null, fullName, null, website, username,null, 'Instagram', null, provMap);
                }
    
}