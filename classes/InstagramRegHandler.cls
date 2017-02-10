/**
  Registration Handler for Instagram
**/
global class InstagramRegHandler implements Auth.RegistrationHandler{
    
    public static String ORG_SUFFIX = '@user.instagram.com';
    private static final String DEFAULT_ACCOUNTNAME = 'Customers';
    public static String EXTERNAL_USER_PROFILE = 'Customer Community User';
    public static String TZSID = [SELECT timezonesidkey from User where profile.name = 'System Administrator' LIMIT 1].timezonesidkey;


/**
 * Create the User - A required method to implement the Handler Interface
 * 
 * @param portalId  - Id of the Community
 * @param data - Auth Provider user data describing the User to create
 * 
 * @return User that has been initialized
**/ 
    global User createUser(Id portalId, Auth.UserData data){
    // optimized for Communities
    
    System.debug('Dumping Auth.UserData: ' + data);
    System.debug('Registering Community user: ' + data.username);
    
    // keeping it modular, the marshal the data from Instagram in another method
    Auth.UserData d = normalizeUserData(data);
        
    Id contactId;
    contactId = createContact(d);
    System.debug('Created contact: '+ contactId);            
            
    // You'd likely use other logic to assign the Profile
    Profile p = [SELECT Id FROM profile WHERE name=:EXTERNAL_USER_PROFILE];
    System.debug('Found profile: '+ p);

    // Keeping it modular, we initialize the user in another method
    User u = createUser(d,p);
    
    u.contactId = contactId;
    return u;
}

    /**
     * Update the user
     * @param portalId  - Id of the Community
     * @param data - Auth Provider user data describing the User to create
     **/     
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        System.debug('Update User called for: ' + data.email);
        
        User u = new User(id=userId);
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        update(u);
    }
        /**
         * Create a Contact
         * 
         * @param data - Instagram provided context for the User
         **/
    
    private Auth.UserData normalizeUserData(Auth.UserData data){
        // Instagram doesn't have a lot of user profile data
        // it lacks email address for example
        // use this method to fill in the holes

        // handle name
        String fullname = data.fullName;
        List<String> names = fullname.split(' ', 2);
        if (names.size() >= 2){
            data.firstName = names[0];
            data.lastName = names[1]; 
        } else {
            data.LastName = fullname;
            data.FirstName = 'Unknown';
        }
        
        // handle email
        data.email = data.username + ORG_SUFFIX;
        
        return data;
    }
    
    private Id createContact(Auth.UserData data){
        Contact c = new Contact();
        
        c.email = data.email;
        c.FirstName = data.FirstName;
        c.LastName = data.LastName;

        c.Description = data.attributeMap.get('bio');
        
        // set Account Id
        List<Account> accounts = [select Id from Account where Name =:DEFAULT_ACCOUNTNAME];

        System.debug('Found account: ' + accounts);
        
        c.accountId = accounts[0].Id;            
        insert c;
    
        System.debug('Contact created for ' + data.email + ' id=' + c.id);
    
        return c.id; 
    }

    
    /**
     * Create and initialize the User but don't save it yet
     * 
     * @param data - the provided User context from Instagram
     * @param p - the Profile we are going to assign to this user
     * 
     * @return User that has been initialized but not Saved
     **/ 
    private User createUser(Auth.UserData data, Profile p) {
        User u = new User();
    
        u.email = data.email;  
        u.username = u.email;
        u.FirstName = data.FirstName;
        u.LastName = data.LastName;
        
        String alias = data.username;
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        
        u.languagelocalekey = UserInfo.getLocale();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = TZSID;
        u.profileId = p.Id;
        
        System.debug('User staged for ' + u.username);
        return u;
    }        
}