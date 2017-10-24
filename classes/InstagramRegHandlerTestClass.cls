@isTest
public class InstagramRegHandlerTestClass {
    public static String bio = 'a heartwarming backstory';
    public static String profilePicture = 'https://picture.test.website/123456788.png';
    public static String id = 'testId';
    public static String fullName = 'Thomas Jones-Drew';    
    public static String firstName = 'Thomas';
    public static String lastName = 'Jones-Drew';
    public static String website = 'https://iam.test.website';
    public static String username = 'testusername';    
    public static String ORG_SUFFIX = '@user.instagram.com';
    
    /**
     * Simple scenario to create a Community user
     **/ 
    testmethod public static void testCreateUser() {
        InstagramRegHandler handler = new InstagramRegHandler();

        Auth.UserData data = createUser();
        Account acct = new Account();
        User u;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

       // Insert account as current user

        System.runAs (thisUser) {
            acct.Name = 'Customers';
            insert(acct);
            
            User theUser = handler.createUser(null, data);
            
            validate(theUser,data);
        
            // Additional validations for Community User
            System.Assert(theUser.ContactId!=null,'Contact must be set for user');
        }


    }
    
    /**
     * Simple direct test of the UpdateUser method.  Create the user first 
     * and then attempt to update some properties.
     **/ 
    testMethod public static void testUpdateUser() {
        InstagramRegHandler handler = new InstagramRegHandler();
        Auth.UserData data = createUser();
        Account acct = new Account();
        User u;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            acct.Name = 'Customers';
            insert(acct);
            
            User theUser = handler.createUser(null, data);
            insert theUser;            
            
//            validate(theUser,data);
            data.firstName='Tom';
            handler.updateUser(theUser.id, null, data);
            
            User theUpdatedUser = [SELECT Id,firstName,Email,LastName 
                                   from User 
                                   Where Id = :theUser.id];
            
            validate(theUpdatedUser,data);
        }        
    }
    
    /**
     * Helper method to Validate the the User we've created
     * 
     * @param theUser - the User that we created
     * @param data - the original AuthData supplied by Instagram
     **/ 
    private static void validate(User theUser, Auth.UserData data) {
        System.Assert(theUser!=null,'User must not be null');
        System.AssertEquals(theUser.email,data.email,'Email address must be the same');
        System.AssertEquals(theUser.FirstName,data.FirstName,'First name must match');
        System.AssertEquals(theUser.LastName,data.LastName,'Last name must match');
    }

    
    /**
     * Helper method to instantiate the handler UserData
     **/ 
    private static Auth.UserData createUser() {
        Map<String, String> attributeMap = new Map<String,String>();
        attributeMap.put('bio', bio);        
        attributeMap.put('profilePicture', profilePicture);
        String locale = 'en_US';
        return new Auth.UserData( id,
            firstName,
            lastName,
            fullName, // fullname
            username + ORG_SUFFIX, //email
            website, // link
            username, // userName
            locale,
            'Instagram', // provider
            '', // siteLoginUrl
            attributeMap);       
    }
}