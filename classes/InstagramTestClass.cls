@IsTest
public class InstagramTestClass {
    public static String redirectUrl = 'http://localhost/services/authcallback/orgId/Instagram';
    public static String key = 'testKey';
    public static String secret = 'testSecret';
    public static String stateToPropagate  = 'testState';
    public static String accessTokenUrl = 'http://www.dummyhost.com/accessTokenUri';
    public static String authUrl = 'http://www.dummy.com/authurl';
    public static String oauthToken = 'testToken';
    public static String state = 'mocktestState';
    public static String id = 'testId';
    public static String username = 'testUsername';
    public static String fullName = 'Test FullName';
    public static String bio = 'Test bio which is very interesting';
    public static String website = 'https://iam.test.website';
    public static String profilePicture = 'https://picture.test.website/123456788.png';
    public static String provider = 'Instagram';
    public static String userEndpoint = 'https://api.instagram.com/v1/users/self/';
    public static String userAPIVersionUrl = '';


    // in the real world scenario , the key and value would be read from the custom metadata type record
    private static Map<String,String> setupAuthProviderConfig () {
        Map<String,String> authProviderConfiguration = new Map<String,String>();
        authProviderConfiguration.put('clientID__c',key);
        authProviderConfiguration.put('Auth_URL__c',authUrl);
        authProviderConfiguration.put('clientSecret__c',secret);
        authProviderConfiguration.put('Access_Token_URL__c',accessTokenUrl);
        authProviderConfiguration.put('UserEndpoint__c',userEndpoint);
        authProviderConfiguration.put('redirectURL__c',redirectUrl);
    
        return authProviderConfiguration;          
    }
    static testMethod void testInitiateMethod() {
        Instagram instagramCls = new Instagram();
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig();

        PageReference expectedUrl =  new PageReference(authUrl + '?client_id='+ key +'&response_type=code&redirect_uri='+ redirectUrl + '&state=' + stateToPropagate);        
        PageReference actualUrl = instagramCls.initiate(authProviderConfiguration,stateToPropagate);

        System.assertEquals(expectedUrl.getUrl(),actualUrl.getUrl());
       }    

    static testMethod void testHandleCallback() {
        Instagram instagramCls = new Instagram();
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
        Test.setMock(HttpCalloutMock.class, new InstagramMockHttpResponseGenerator());
        
        Map<String,String> queryParams = new Map<String,String>();
        queryParams.put('code','code');
        queryParams.put('state',state);
        
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams);
        Auth.AuthProviderTokenResponse actualAuthProvResponse = instagramCls.handleCallback(authProviderConfiguration, cbState);
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse('Instagram', oauthToken, null, state);

        System.assertEquals(expectedAuthProvResponse.provider, actualAuthProvResponse.provider);
        System.assertEquals(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken);
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken);
        System.assertEquals(expectedAuthProvResponse.state,actualAuthProvResponse.state);
    }
    
    static testMethod void testGetUserInfo(){
        Instagram instagramCls = new Instagram();
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig();      
        Test.setMock(HttpCalloutMock.class, new InstagramMockHttpResponseGenerator());
        Map<String,String> queryParams = new Map<String,String>();
        queryParams.put('code','code');
        queryParams.put('state',state);
        
        Auth.UserData actualUserData = instagramCls.getUserInfo(authProviderConfiguration, new Auth.AuthProviderTokenResponse('Instagram', oauthToken, null, state));
        Map<String, String> attributeMap = new Map<String,String>();
        attributeMap.put('bio', bio);        
        attributeMap.put('profilePicture', profilePicture);

        Auth.UserData expectedUserData = new Auth.UserData( id,
               null, // firstName
               null, // lastName
              fullName, // fullname
               null,// email
               website, // link
               userName,
               null, // locale
               'Instagram',
               null, // siteLoginUrl
               attributeMap);    
        System.assertEquals(expectedUserData.fullname, actualUserData.fullname);
        System.assertEquals(expectedUserData.userName, actualUserData.userName);
        System.assertEquals(expectedUserData.link, actualUserData.link);
        System.assertEquals(expectedUserData.attributeMap.get('profile_picture'), actualUserData.attributeMap.get('profile_picture'));
    }

}