/**
  Registration Handler for Instagram
**/
global class InstagramRegHandler implements Auth.RegistrationHandler{
    
    private static final String ORG_SUFFIX = '@testing.instagram.com';
    private static final String DEFAULT_ACCOUNTNAME = 'Customers';
    private static final String EXTERNAL_USER_PROFILE = 'Customer Community User';
    private static final String INTERNAL_USER_PROFILE = 'Standard User';  
    private static final String TZSID = [SELECT timezonesidkey from User where profile.name = 'System Administrator' LIMIT 1].timezonesidkey;


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
    // Is this a Community Context?
        System.debug('Registering Community user: ' + data.username);
        Id contactId;
        contactId = createContact(data);
        System.debug('Created contact: '+ contactId);            
                
        // You'd likely use other logic to assign the Profile
        Profile p = [SELECT Id FROM profile WHERE name=:EXTERNAL_USER_PROFILE];
        System.debug('Found profile: '+ p);

        // Keeping it modular, we initialize the user in another method
        User u = createUser(data,p);
        
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
    private Id createContact(Auth.UserData data){
        Contact contact = new Contact();

        // handle name
        String fullname = data.fullName;
        List<String> names = fullname.split(' ', 2);
        if (names.size() >= 2 ){ 
            contact.LastName = names[1];
            contact.FirstName = names[0];
        } else if (names.size() < 2 ) {
            contact.LastName = fullname;
            contact.FirstName = 'Unknown';
        }
        
        contact.Description = data.attributeMap.get('bio');
        
        // instagram doesn't disclose (and doesn't have) email address
        // this is a workaround
        contact.Email = data.username + '@user.instagram.com';
        
        // set Account Id
        List<Account> accounts = [select Id from Account where Name =:DEFAULT_ACCOUNTNAME];
        System.debug('Found account: ' + accounts);
        
        contact.accountId = accounts[0].Id;            
        insert contact;

        System.debug('Contact created for ' + data.email + ' id=' + contact.id);

        return contact.id; 
    }

    
    /**
     * Create and initialize the User but don't save it yet
     * 
     * @param data - the provided User context from FaceBook
     * @param p - the Profile we are going to assign to this user
     * 
     * @return User that has been initialized but not Saved
     **/ 
    private User createUser(Auth.UserData data, Profile p) {
        User u = new User();
        // email workaround
        u.email = data.username + '@user.instagram.com';
        u.username = u.email;
        
        // handle name
        String fullname = data.fullName;
        List<String> names = fullname.split(' ', 2);
        if (names.size() >= 2 ){ 
            u.LastName = names[1];
            u.FirstName = names[0];
        } else if (names.size() < 2 ) {
            u.LastName = fullname;
            u.FirstName = 'Unknown';
        }

        String alias = data.username;
        
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLanguage();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = TZSID;
        u.profileId = p.Id;
        
        System.debug('User staged for ' + u.username);
        return u;
    }        
}