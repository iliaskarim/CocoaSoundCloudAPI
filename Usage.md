# How to use the SoundCloud API Wrapper

If all you want to do is uploading a track to SoundCloud, you should have a look at [SoundCloudUI]() (iOS only). __The SoundCloudUI should always be your first choice.__ It extends the API with a `SCLoginViewController` and a `SCSharingViewController`.

### The Basics

You only need to `#import "SCAPI.h"` to include the wrapper headers. The objects you should be most interested in are `SCSoundCloud` for configuration and `SCRequest` for invoking request on the API.


### Configure your App

To configure you App you have to set your App's _Client ID_, it's _Client Secret_ and it's _Redirect URL_. The best way to do this is in the `initialize` class method in your app delegate.

    + (void)initialize;
    {
        [SCSoundCloud  setClientID:@"<Client ID>"
                            secret:@"<Client Secret>"
                       redirectURL:[NSURL URLWithString:@"<Redirect URL>"]];
    }

You will get your App's _Client ID_, it's _Client Secret_ from [the SoundCloud page where you registered your App](http://soundcloud.com/you/apps). There you should register your App with it's name and a _Redirect URL_. That _Redirect URL_ should comply to a protocol that is handled by your app. See [this page](http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html) on how to set up the protocol in your App. For the curious: in the wrapper we're using _Redirect URL_ instead of _Redirect URI_ because the underlying type is of `NSURL`.


### Authentication 

#### The easy way (iOS only)

Have a look at [SoundCloudUI](). It extends the API with a `SCLoginViewController`.

#### The more complicated way

To request access for a certain user, you have to call the class method `+[SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:]`. With this call you trigger an authentication process. In this process a web page has to be opened where the user can sign in to SoundCloud and give your App access to it's account.

    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
        // Load the URL in a web view or open it in an external browser
    }];
    
If you open the URL in an external browser, your app delegate has to handel the redirect URL.

__On iOS:__s

    - (BOOL)application:(UIApplication *)application
                openURL:(NSURL *)url
      sourceApplication:(NSString *)sourceApplication
             annotation:(id)annotation;
    {
        BOOL handled = [SCSoundCloud handleRedirectURL:url];
        if (!handled) {
            NSLog(@"The URL (%@) could not be handled by the SoundCloud API. Maybe you want to do something with it.", url);
        }
        return handled;
    }

__On Mac OS X:__

    - (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
    {
        [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                           andSelector:@selector(handleURLEvent:withReplyEvent:)
                                                         forEventClass:kInternetEventClass
                                                            andEventID:kAEGetURL];
    }
    
    - (void)handleURLEvent:(NSAppleEventDescriptor*)event
            withReplyEvent:(NSAppleEventDescriptor*)replyEvent;
    {
        NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
        
        BOOL handled = [SCSoundCloud handleRedirectURL:[NSURL URLWithString:url]];
        if (!handled) {
            NSLog(@"The URL (%@) could not be handled by the SoundCloud API. Maybe you want to do something with it.", url);
        }
    }

#### The Authenticated Account

After a successful authentication, you have access to that account via the class method `[SCSoundCloud account]`. You should never keep a reference to this account. Always access the account with this method.

#### Removen Access

To log out the authenticated user, you have to call the method `[SCSoundCloud removeAccess]`.

### Invoking Requests on the API

The best way to invoke a request on the API is by calling the class method (see below) on `SCRequest`. You can call this method without an account (nil) for anonymous requests or with the account you get from `[SCSoundCloud account]`. The response is handled in the block you have to pass in the call. There you get the underlying `NSURLResponse` (e.g., to access the status code), the body of the response or (if something went wrong) an error.

    SCAccount *account = [SCSoundCLoud account];
    
    id obj = [SCRequest performMethod:SCRequestMethodGET
                           onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me.json"]
                      usingParameters:nil
                          withAccount:account
               sendingProgressHandler:nil
                      responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                            // Handle the response
                            if (error) {
                                NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                            } else {
                                // Check the statuscode and parse the data
                            }
              }];
    
In case you would like to cancel the request, you need to keep a reference of the opaque object returned by that method call. Then you can cancel the request with `[SCRequest cancelRequest:obj]`.

#### Providing Parameters

If you have to provide parameters, you must create a NSDictionary containing the key value pairs. If a value is a NSURL (or a NSData ???) it is automatically treated as a multipart data.


#### Sending Progress

On long running request (e.g., if you upload a track), it is wise to provide the user a feedback how fare the upload is gone. Therefor you can pass a sending progress handler on invocation. This handler is called occasionally with the total and already sent bytes.

     [SCRequest performMethod:SCRequestMethodPOST
                            onResource:[NSURL URLWithString:@"https://api.soundcloud.com/tracks"]
                       usingParameters:parameters
                           withAccount:account
                sendingProgressHandler:^(unsigned long long bytesSent, unsigned long long bytesTotal){
                                            self.progressView.progress = (float)bytesSent / bytesTotal;
                                       }
                       responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                            // Handle the response
                                       }];


### Listening for Notifications

There are to types of notifications which you might have interest in:

 - SCSoundCloudAccountDidChangeNotification
 - SCSoundCloudDidFailToRequestAccessNotification

#### SCSoundCloudAccountDidChangeNotification

This notification is send each time after the account did change. You could use this notification to update the user info.
    
    @implementation MyClass
    
    - (id)init;
    {
        self = [super init];
        if (self) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(accountDidChange:)
                                                         name:SCSoundCloudAccountDidChangeNotification
                                                       object:nil];
        }
        return self;
    }
    
    - (void)dealloc;
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [super dealloc];
    }
    
    - (void)accountDidChange:(NSNotification *)aNotification;
    {
        SCAccount *account = [SCSoundCloud account];
        
        if (account) {
            [SCRequest performMethod:SCRequestMethodGET
                                   onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me.json"]
                              usingParameters:nil
                                  withAccount:account
                       sendingProgressHandler:nil
                              responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                    // Update the user info
            }];
        } else {
            // Maybe you would like to update your user interface to show that ther is no account.
        }
    }
    
    @end

#### SCSoundCloudDidFailToRequestAccessNotification

If something went wrong while requesting access to SoundCloud, the notification `SCSoundCloudDidFailToRequestAccessNotification` is send. To get more details about what, a NSError is provided in the userInfo.

    - (id)init;
    {
        // ...
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFailToRequestAccess:)
                                                     name:SCSoundCloudDidFailToRequestAccessNotification
                                                   object:nil];
        // ...
    }
    
    - (void)didFailToRequestAccess:(NSNotification *)aNotification;
    {
        NSError *error = [[aNotification userInfo] objectForKey:kNXOAuth2AccountStoreError];
        NSLog(@"Requesting access to SoundCloud did fail with error: %@", [error localizedDescription]);
    }

### Thats it!

If you haven't had a look at the [documentation of the SoundCloud API](http://developers.soundcloud.com/docs) you should continue there.
