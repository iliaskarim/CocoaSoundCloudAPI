//
//  GPWebAPI.m
//
//  Created by Gernot Poetsch on 09.03.08.
//  Copyright 2008 Gernot Poetsch. All rights reserved.
//

#import "NSString_GPKit.h"

#import "GPURLConnection.h"

#import "GPWebAPI.h"

@interface GPWebAPI (Private)
- (NSData *)_generateFormData:(NSDictionary *)dict withBoundary:(NSString *)boundary;
- (void)_removeConnection:(GPURLConnection *)connection;
@end

@implementation GPWebAPI

#pragma mark Lifecycle

- (id)init;
{
	if ((self = [super init])) {
		_connectionsWithIdentifiers = [[NSMutableDictionary alloc] init];
		_conditionalRequests = [[NSMutableArray alloc] init];
		etags = [[NSMutableDictionary alloc] init];
		self.scheme = @"http";
	}
	return self;
}

- (id)initWithHost:(NSString *)aHost delegate:(id<GPWebAPIDelegate>)aDelegate;
{
	if ((self = [self init])) {
		delegate = aDelegate;
		host = [aHost retain];
	}
	return self;
}

- (void)dealloc;
{
	[scheme release];
	[username release];
	[password release];
	[host release];
	[port release];
	[path release];
	[userAgent release];
	for (GPURLConnection *connection in [_connectionsWithIdentifiers allValues]) {
		[connection cancel];
	}
	[_connectionsWithIdentifiers release];
	[_conditionalRequests release];
	[etags release];
	[super dealloc];
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone;
{
	GPWebAPI *copy = [[[self class] alloc] initWithHost:self.host delegate:nil];
	[copy setScheme:self.scheme];
	[copy setUsername:self.username];
	[copy setPassword:self.password];
	[copy setPort:self.port];
	[copy setPath:self.path];
	[copy setUserAgent:self.userAgent];
	[copy setEtags:self.etags];
	
	return copy;
}

#pragma mark Accessors

@synthesize delegate, userAgent;
@synthesize scheme, username, password, host, port, path;
@synthesize etags;

- (void)setDelegate:(id<GPWebAPIDelegate>)value;
{
	[self willChangeValueForKey:@"delegate"];
	[value retain]; [delegate release]; delegate = value;
	[self didChangeValueForKey:@"delegate"];
}

- (void)setEtags:(NSDictionary *)value;
{
	NSMutableDictionary *copy = [value mutableCopy];
	[etags release];
	etags = copy;
}

#pragma mark Etags

- (void)resetEtags;
{
	[etags release];
	etags = [[NSMutableDictionary alloc] init];
}

- (NSString *)etagForURL:(NSURL *)URL;
{
	return [etags objectForKey:URL];
}

- (void)setEtag:(NSString *)etag forURL:(NSURL *)URL;
{
	if (!etag || !URL) return;
	[etags setObject:etag forKey:URL];
}


#pragma mark Method Incvocation

- (id)getResource:(NSString *)resource withArguments:(NSDictionary *)arguments;
{
	return [self getResource:resource
			   withArguments:arguments
					 context:nil
					 options:nil];
}

- (id)getResource:(NSString *)resource withArguments:(NSDictionary *)arguments context:(id)context options:(NSDictionary *)options;
{
	return [self invokeMethod:nil //Defaults to GET
				   onResource:resource
				withArguments:arguments
						 type:GPWebAPIRequestTypeURLOnly
				 headerFields:nil
					  context:context
					  options:options];
}

- (id)postMultiPartFormResource:(NSString *)resource 
				  withArguments:(NSDictionary *)arguments 
						context:(id)context 
						options:(NSDictionary *)options;
{
	return [self invokeMethod:@"POST"
				   onResource:resource
				withArguments:arguments
						 type:GPWebAPIRequestTypePostMultiPartForm
				 headerFields:nil
					  context:context
					  options:options];
}


- (id)invokeMethod:(NSString *)method
		onResource:(NSString *)resource
	 withArguments:(NSDictionary *)arguments
			  type:(GPWebAPIRequestType)type
	  headerFields:(NSDictionary *)headerFields
		   context:(id)context
		   options:(NSDictionary *)options;
{
	BOOL usesEtag = [[options objectForKey:GPWebAPIUseEtagKey] boolValue];
	
	NSString *boundary = @"GPWebAPISeparator";
	NSData *bodyData = nil;
	
	//Prepare the Body Data
	if (type == GPWebAPIRequestTypePostMultiPartForm) {
		//FIXME: Add random Component to boundary
		bodyData = [self _generateFormData:arguments withBoundary:boundary];
	}
	
	//Create the Request
	NSMutableURLRequest *request = nil;
	if (type == GPWebAPIRequestTypeURLOnly) {
		request = [self requestForResource:resource withArguments:arguments];
	} else {
		request = [self requestForResource:resource withArguments:nil]; //arguments are in the body
	}
	
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	
	//Set Method and Body
	if (method) [request setHTTPMethod:method];
	if (bodyData) [request setHTTPBody:bodyData];
	
	//Add HTTP Header Fields
	if (type == GPWebAPIRequestTypePostMultiPartForm) {
		[request setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
		[request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
	}
	
	//Conditional Get
	if (usesEtag) {
		NSString *etag = [self etagForURL:request.URL];
		if (etag) [request setValue:etag forHTTPHeaderField:@"If-None-Match"];
	}
	
	//Set Timeout
	NSNumber *timeout = [options objectForKey:GPWebAPITimeoutKey];
	if (timeout) {
		[request setTimeoutInterval:[timeout doubleValue]];
	}
	
	//Set Custom Header Fields
	if (headerFields) {
		for (NSString *headerKey in headerFields) {
			[request setValue:[headerFields objectForKey:headerKey] forHTTPHeaderField:headerKey];
		}
	}
	
	return [self sendRequest:request
					userInfo:[options objectForKey:GPWebAPIUserInfoKey]
					 context:context
				 conditional:usesEtag];
}

- (NSMutableURLRequest *)requestForResource:(NSString *)resource withArguments:(NSDictionary *)arguments;
{
	if (!host || !resource) {
		NSLog(@"Incomplete Connection invoke.\nHost: %@\nResource: %@\nArguments: %@",
			  self.host, resource, arguments);
		return nil;
	}
	
	//Build the base URL
	NSMutableString *URLString = [NSMutableString stringWithFormat:@"%@://", self.scheme];
	if (self.username) {
		if (self.password) {
			[URLString appendFormat:@"%@:%@@", self.username, self.password];
		} else {
			[URLString appendFormat:@"%@@", self.username];
		}
	}
	[URLString appendString:self.host];
	if (self.port) {
		[URLString appendFormat:@":%@", self.port];
	}
	if (self.path) {
		[URLString appendFormat:@"/%@", self.path];
	}
	[URLString appendFormat:@"/%@", resource];
	
	NSMutableArray *queryComponents = [NSMutableArray arrayWithCapacity:[arguments count]];
	for (NSString *queryKey in arguments) {
		NSString *queryValue = [arguments objectForKey:queryKey];
		if (![queryValue isKindOfClass:[NSString class]]) {
			NSLog(@"Can't put %@ (%@) into a URL string for key %@. Aborting.", queryValue, [queryValue class], queryKey);
			return nil;
		}
		NSString *queryComponent = [NSString stringWithFormat:@"%@=%@",
									[queryKey stringByAddingURLEncoding],
									[queryValue stringByAddingURLEncoding]];
		[queryComponents addObject:queryComponent];
	}
	
	if (queryComponents.count > 0) {
		[URLString appendFormat:@"?%@", [queryComponents componentsJoinedByString:@"&"]];
	}
	
	NSMutableURLRequest *request = [self requestWithURL:[NSURL URLWithString:URLString]];
	
	return request;
}

- (void)cancelRequest:(id)identifier;
{
	if (!identifier) return;
	GPURLConnection *request = [_connectionsWithIdentifiers objectForKey:identifier];
	[request cancel];
	[_connectionsWithIdentifiers removeObjectForKey:identifier];
}

#pragma mark Connection Delegate

- (void)connection:(GPURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
	if ([_conditionalRequests containsObject:connection]) {
		NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
		NSString *etag = [headerFields objectForKey:@"Etag"];
		if (etag) [self setEtag:etag forURL:response.URL];
	}
}

- (void)connection:(GPURLConnection *)connection didFailWithError:(NSError *)error;
{
	id userInfo = [[[connection userInfo] retain] autorelease]; //We are no longer in the runloop cycle of the original autorelease
	id context = [[[connection context] retain] autorelease]; //same here
	NSData *data = [[[connection data] retain] autorelease];
	[self _removeConnection:connection];
	if ([self.delegate respondsToSelector:@selector(webApi:didFailWithError:data:userInfo:context:)]){
		[self.delegate webApi:self didFailWithError:error data:data userInfo:userInfo context:context];
	}
}

- (void)connectionDidFinishLoading:(GPURLConnection *)connection;
{
	id userInfo = [[[connection userInfo] retain] autorelease]; //We are no longer in the runloop cycle of the original autorelease
	id context = [[[connection context] retain] autorelease]; //same here
	NSData *data = [[[connection data] retain] autorelease];
	int statusCode = [connection statusCode];
	
	[self _removeConnection:connection];
	
	if (statusCode >= 400) {
		if ([self.delegate respondsToSelector:@selector(webApi:didFailWithError:data:userInfo:context:)]){
			NSError *error = [NSError errorWithDomain:GPWebAPIHTTPError
												 code:statusCode
											 userInfo:nil];
			[self.delegate webApi:self didFailWithError:error data:data userInfo:userInfo context:context];
			return;
		}
	}
	
	if ([self.delegate respondsToSelector:@selector(webApi:didFinishWithData:userInfo:context:)]) {
		if (statusCode == 304) {
			[self.delegate webApi:self didFinishWithData:nil userInfo:userInfo context:context];
		} else {
			[self.delegate webApi:self didFinishWithData:data userInfo:userInfo context:context];
		}
	}
}

#pragma mark Overwrite

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url;
{
	return [NSMutableURLRequest requestWithURL:url];
}

- (id)sendRequest:(NSURLRequest *)request userInfo:(id)userInfo context:(id)context conditional:(BOOL)conditional;
{
	if (!request) {
		return nil;
	}
	
	//NSLog(@"Requesting: %@", request);
	
	GPURLConnection *connection = [GPURLConnection connectionWithRequest:request delegate:self];
	[connection setUserInfo:userInfo];
	[connection setContext:context];
	
	NSString *identifier = [NSString stringWithUUID];
	[_connectionsWithIdentifiers setObject:connection forKey:identifier];
	if (conditional) [_conditionalRequests addObject:connection];
	return identifier;
}

@end

#pragma mark -

@implementation GPWebAPI (Private)

#pragma mark Helper

- (NSData *)_generateFormData:(NSDictionary *)dict withBoundary:(NSString *)boundary;
{
	NSMutableData* result = [[[NSMutableData alloc] initWithCapacity:100] autorelease];
	
	for (NSString *key in dict) {
		id value = [dict valueForKey:key];
		[result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
							dataUsingEncoding:NSUTF8StringEncoding]];
		if ([value isKindOfClass:[NSString class]]) {
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]
								dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[[NSString stringWithFormat:@"%@\r\n",value]
								dataUsingEncoding:NSUTF8StringEncoding]];
		} else if ([value isKindOfClass:[NSURL class]] && [value isFileURL]) {
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, [[value path] lastPathComponent]]
								dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"]
								dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[NSData dataWithContentsOfFile:[value path]]];
			[result appendData:[[NSString stringWithString:@"\r\n"]
								dataUsingEncoding:NSUTF8StringEncoding]];
		} else if ([value isKindOfClass:[NSData class]]) {
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"unknown\"\r\n", key]
								dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"]
								dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:value];
			[result appendData:[[NSString stringWithString:@"\r\n"]
								dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	[result appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary]
						dataUsingEncoding:NSUTF8StringEncoding]];
	return result;
}

- (void)_removeConnection:(GPURLConnection *)connection;
{
	[_connectionsWithIdentifiers removeObjectsForKeys:[_connectionsWithIdentifiers allKeysForObject:connection]];
	[_conditionalRequests removeObject:connection];
}

@end
