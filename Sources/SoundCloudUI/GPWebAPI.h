//
//  GPWebAPI.h
//
//  Created by Gernot Poetsch on 09.03.08.
//  Copyright 2008 Gernot Poetsch. All rights reserved.
//

@class GPWebAPI;
@class GPURLConnection;



@protocol GPURLConnectionDelegate;

@protocol GPWebAPIDelegate <NSObject>
@optional

//In case of a 304 "Not modified" this will be called with nil data.
- (void)webApi:(GPWebAPI *)api didFinishWithData:(NSData *)data userInfo:(id)userInfo context:(id)context;

- (void)webApi:(GPWebAPI *)api didFailWithError:(NSError *)error data:(NSData *)data userInfo:(id)userInfo context:(id)context;

@end

#define GPWebAPIHTTPError @"GPWebAPIHTTPError"

typedef enum {
	GPWebAPIRequestTypeURLOnly,
	GPWebAPIRequestTypePostMultiPartForm,
	//FIXME: Implement additional Post Schemes
	//GPWebAPIRequestTypePostURLEncodedString,
	//GPWebAPIRequestTypePostXML,
	//GPWebAPIRequestTypePostJSON,
} GPWebAPIRequestType;

#define GPWebAPIUserInfoKey @"GPWebAPIUserInfoKey" //Any object
#define GPWebAPIUseEtagKey @"GPWebAPIUseEtagKey" //Use an NSNumber for YES or NO
#define GPWebAPITimeoutKey @"GPWebAPITimeoutKey" //Use an NSNumber with a Timeinterval

@interface GPWebAPI : NSObject <NSCopying, GPURLConnectionDelegate> {
	
	id<GPWebAPIDelegate> delegate;
	
	NSString *userAgent;
	
	NSString *scheme;
	NSString *username;
	NSString *password;
	NSString *host;
	NSNumber *port;
	NSString *path;
	
	NSMutableDictionary *_connectionsWithIdentifiers;
	NSMutableArray *_conditionalRequests; //For identifying reqests of whom to store etags, etc.
	NSMutableDictionary *etags;
}

- (NSString *)etagForURL:(NSURL *)URL;
- (void)setEtag:(NSString *)etag forURL:(NSURL *)URL;
- (void)resetEtags;

- (id)initWithHost:(NSString *)host delegate:(id<GPWebAPIDelegate>)value;

@property (nonatomic, assign) id<GPWebAPIDelegate> delegate;

@property (nonatomic, retain) NSString *scheme;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSNumber *port;
@property (nonatomic, retain) NSString *path;

@property (nonatomic, copy) NSDictionary *etags;
@property (nonatomic, retain) NSString *userAgent;

//Method Invocation

/* All Those Methods return an identifier for the Connection, which is used to a request */

- (id)getResource:(NSString *)resource withArguments:(NSDictionary *)arguments;

- (id)getResource:(NSString *)resource
	withArguments:(NSDictionary *)arguments
		  context:(id)context
		  options:(NSDictionary *)options;

- (id)postMultiPartFormResource:(NSString *)resource
				  withArguments:(NSDictionary *)arguments
						context:(id)context
						options:(NSDictionary *)options;

- (id)invokeMethod:(NSString *)method
		onResource:(NSString *)resource
	 withArguments:(NSDictionary *)arguments
			  type:(GPWebAPIRequestType)type
	  headerFields:(NSDictionary *)headerFields
		   context:(id)context
		   options:(NSDictionary *)options;

- (NSMutableURLRequest *)requestForResource:(NSString *)resource withArguments:(NSDictionary *)arguments;

- (void)cancelRequest:(id)identifier;


#pragma mark Overwrite for specific apis

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url;
- (id)sendRequest:(NSURLRequest *)request userInfo:(id)userInfo context:(id)context conditional:(BOOL)conditional;


@end

