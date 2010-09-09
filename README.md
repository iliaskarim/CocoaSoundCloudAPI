# SoundCloud API Wrapper

A wrapper on the [SoundCloud](http://soundcloud.com) API for Mac OS & iOS (Cocoa & Cocoa touch). This wrapper supports the [OAuth 2](http://oauth.net/2) version of the API and uses the [OAuth2Client](http://github.com/nxtbgthng/OAuth2Client) project.

If you haven't yet now is the right time to have a look at the [SoundCloud API wiki](http://wiki.github.com/soundcloud/api/).

If you're looking for additional documentation on this wrapper have a look at the [wiki](http://wiki.github.com/soundcloud/cocoa-api-wrapper/) where you'll find the documentation for [version 1](http://github.com/soundcloud/cocoa-api-wrapper/tree/v1.0).

## QuickStart

In your terminal:

- git clone git://github.com/soundcloud/cocoa-api-wrapper.git
- cd cocoa-api-wrapper
- git checkout oauth2
- git submodule update --recursive --init

In your Xcode project:

- drag SoundCloudAPI.xcodeproj into your project
- add it as a build dependency
- add "/tmp/SoundCloudAPI.dst/usr/local/include" to your user header search path in the build settings
- you can also include the [OAuth2Client](http://github.com/nxtbgthng/OAuth2Client) headers by adding "/tmp/OAuth2Client.dst/usr/local/include" too (although you might not need them)

## Using the Wrapper in your code

### The Basics

You only need to `#import "SCAPI.h"` to include the wrapper headers. The file you should be most interested in is `SCSoundCloudAPI.h`. It defines the main interface as well as the protocol for the authentication delegate. All the magic that happens in the OAuth2Client is well hidden from you.


### Instantiating the API object

It is recommended that you have one central instance of the `SCSoundCloudAPI` object. You may keep it in a controller object that lives as a [singleton](http://cocoawithlove.com/2008/11/singletons-appdelegates-and-top-level.html) in you application. You can use this controller as a central place to build your API request, too.

To create an instance of `SCSoundCloudAPI` you can use the following code. Obtain the client key & secret for your app on [http://soundcloud.com/you/apps](http://soundcloud.com/you/apps). 

	SCSoundCloudAPIConfiguration *scAPIConfig = [SCSoundCloudAPIConfiguration configurationForProductionWithConsumerKey:CLIENT_KEY
																		                                 consumerSecret:CLIENT_SECRET
																			                                callbackURL:[NSURL URLWithString:CALLBACK_URL]];
	// scAPI is a instance variable
	// more on authDelegate in the next section
	scAPI = [[SCSoundCloudAPI alloc] initWithAuthenticationDelegate:authDelegate
												   apiConfiguration:scAPIConfig];
	[scAPI setResponseFormat:SCResponseFormatJSON];
	[scAPI setDelegate:self];	// this is the connection delegate

Until this nothing magical should happen. Your left with the `scAPI` and may query for it's status with `scAPI.isAuthenticated`. If you want to start the authentication flow you need to do a call to `[scAPI requestAuthentication]`. If the API object isn't authenticated it will start the authentication flow with your *authentication delegate*.


### The Authentication Delegate

You should have one instance of this in your code (for example your app delegate could be your authentication delegate). This delegate receives callbacks when a connection to SoundCloud was established (i.e. when your app receives an access token), when the connection was lost or when there was an error while receiving the access token.

    #pragma mark SCSoundCloudAPIAuthenticationDelegate
    	
    - (void)soundCloudAPIDidAuthenticate:(SCSoundCloudAPI *)scAPI;
    {
        // big cheers!! the user sucesfully signed in
		// now activate your interface and send requests
    }
	
    - (void)soundCloudAPIDidResetAuthentication:(SCSoundCloudAPI *)scAPI;
	{
		// the user did signed off
		// deactivate the interface and offer the user to sign in again
	}
	
    - (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI didFailToGetAccessTokenWithError:(NSError *)error;
	{
		// inform your user and let him retry the authentication
	}

There is a forth delegate method which is used for the authentication flow: `-soundCloudAPI:preparedAuthorizationURL:`

This method is invoked when `[scAPI requestAuthentication]` is called on an not yet authorized `SCSoundCloudAPI` object. If you passed an redirect URL with your API configuration while instantiating the API object you'll receive an authorization URL. Open this in an external browser or a web view inside your app. It's important to understand the idea behind OAuth: The user leaves his credentials in a known environment. Ideally the web site he knows in a browser of his trust.

	- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI preparedAuthorizationURL:(NSURL *)authorizationURL;
	{
		// example for iOS
		// One could also open a UIWebView and load the URL inside the app.
		[[UIApplication sharedApplication] openURL:authorizationURL]; // you should warn the user before doing this
	}

The user will be able to log in at SoundCloud and give your application access. Once this is done your redirect URL is being triggered. Make sure to implement the corresponding method in you application delegate.

	- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
	{
		return [scAPI handleOpenRedirectURL:url];
	}
	
	// AND / OR
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
	{
		NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];	
		return [scAPI handleOpenRedirectURL:launchURL];
	}

As an alternative to authenticating using a browser you can also implement `-soundCloudAPI:preparedAuthorizationURL:` as follows to use the *user credentials flow*:

	- (void)soundCloudAPI:(SCSoundCloudAPI *)scAPI preparedAuthorizationURL:(NSURL *)authorizationURL;
	{
		// open a view which asks the user for username & password
		// example for iOS
		MYCredentialsViewController *vc = [[[MyCredentialsViewController alloc] initWithDelegate:self] autorelease];
		[navigationController pushViewController:vs animated:YES];
	}
	
	// after the user entered his credentials
	- (void)credentialsController:(MYCredentialsViewController *)controller
	              didGetUsername:(NSString *)username
                        password:(NSString *)password;
	{
		// authorize with it
		[scAPI authorizeWithUsername:username password:password];
	}

But consider that this bypasses one of the major reasons for using OAuth, by passing the user credentials through your app.


### Invoking Requests on the API

There is one central method for sending requests to the API: `-performMethod:onResource:withParameters:context:connectionDelegate:`. This method returns an `id` which you can use to cancel the request later using `-cancelConnection:` method.

The context can be used to pass data to the delegate callbacks. It is retained for as long as the `SCSoundCloudConnection` instance exists.


### The Connection Delegate Protocol

The second important delegate in the wrapper is `SCSoundCloudConnectionDelegate`. Use it to implement callbacks for requests you send via the API. If you're familiar with [NSURLConnection and it's delegate](http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/URLLoadingSystem/Tasks/UsingNSURLConnection.html) you'll instantly feel familiar with this protocol. That's why I won't go into detail here. It offers you callbacks for certain events during the lifecycle of a request to the API. Notice that each callback contains the `(id)context` object that you passed when performing the request.


## Changes from version 1

We tried to get rid of the major obstacles that occurred while using the API wrapper. Therefore we had to change the interface but instead of adding stuff we tried to get rid of everything that was distracting. The next sections will describe in a short manner what was removed, what was renamed and what you have to do to move to version 2.


### The SCSoundCloudAPI interface

* Removed the `status`. It had too much complexity attached to it. Therefore added `isAuthenticated` which is a simple BOOL to check if the API is connected already.
* Also removed the delegate method `soundCloudAPI:didChangeAuthenticationStatus:` and replaced it with `soundCloudAPIDidAuthenticate:` and `soundCloudAPIDidResetAuthentication:`

* The verifier was removed since it's not needed anymore with OAuth2

* `soundCloudAPI:requestedAuthenticationWithURL:` was renamed to `soundCloudAPI:preparedAuthorizationURL:`
* `soundCloudAPI:didEncounterError:` was renamed to `soundCloudAPI:didFailToGetAccessTokenWithError:`
* `configurationForSoundCloudAPI:` was removed. You pass the API configuration in the initializer of the API object now.

* `performMethod:onResource:withParameters:context:` was renamed to `-performMethod:onResource:withParameters:context:connectionDelegate:` and now takes a connection delegate and returns a SCSoundCloudConnection object
* `SCSoundCloudAPIDelegate` was moved into `SCSoundCloudConnectionDelegate`. The connection delegate can now be set per request and not API wide.
* Also `-cancelRequest:` was removed. Use `-cancel` in `SCSoundCloudConnection` now.

* The authentication process was streamlined. Therefore `-authorizeRequestToken` was removed and `-handleOpenRedirectURL:` and `-authorizeWithUsername:password:` were added. See next chapter.


### The Authentication Process

The authentication process was too complicated in the previous version. So we streamlined it. Also there's a second authentication scheme now (user credentials). See previous sections for details. This section describes how the process changed.

In version 1 `-soundCloudAPIdidChangeAuthenticationStatus:` had to be implemented and depending on the status different things had to be triggered. Since we got rid of all the different statuses this There's not much left for you to implement :)

In `-soundCloudAPI:preparedAuthorizationURL:` you just have to decide which authentication flow you're using and depending on that either open a webView (or the browser) and present the user with the authentication page, or query the user for username & password. Once you got the response from either your URL callback or the username and password you pass them to the API with either `-handleOpenRedirectURL:` or `-authorizeWithUsername:password:`. That's it.


## Changelog for the Beta of 2.0

The wrapper is still subject to change. Although we thing that v2.0beta3 should be quite stable in it's interface now. But we're willing to optimize things even further and are hoping for your input.

### 2.0 Beta 2 to 2.0 Beta 3

* Renamed `-soundCloudAPIDidGetAccessToken:` to `-soundCloudAPIDidAuthenticate:` & added `-soundCloudAPIDidResetAuthentication:`
* Introduced `SCSoundCloudAPIConnection` and added `connectionDelegate:` per request
* Moved `SCSoundCloudAPIDelegate` into `SCSoundCloudAPIConnectionDelegate`


## Feedback

Please feel free to contact [me](mailto:ullrich@nxtbgthng.com?subject=SoundCloud API wrapper)