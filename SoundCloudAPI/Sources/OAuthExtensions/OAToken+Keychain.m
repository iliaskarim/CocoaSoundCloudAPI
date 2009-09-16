/*
 * Copyright 2009 Ullrich Schäfer, Gernot Poetsch for SoundCloud Ltd.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * For more information and documentation refer to
 * http://soundcloud.com/api
 * 
 */

#import "OAToken+Keychain.h"
#import <Security/Security.h>

#if TARGET_OS_IPHONE

#pragma mark iPhone device implementation

@implementation OAToken (SoundCloudAPI)

- (id)initWithDefaultKeychainUsingAppName:(NSString *)name serviceProviderName:(NSString *)provider;
{
	NSDictionary *result = nil;
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", name, provider];
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
						   (NSString *)kSecClassGenericPassword, kSecClass,
						   serviceName, kSecAttrService,
						   kCFBooleanTrue, kSecReturnAttributes,
						   nil];
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
	
	if (status != noErr) {
		if (status != errSecItemNotFound) {
			NSLog(@"Error while initializing OAtoken: %d", status);
		}
		[result release];
		return nil;
	}
	
	if (self = [self init]) {
		self.key = [result objectForKey:(NSString *)kSecAttrAccount];
		self.secret = [result objectForKey:(NSString *)kSecAttrGeneric];
	}
	[result release];
	return self;
}

- (int)storeInDefaultKeychainWithAppName:(NSString *)name serviceProviderName:(NSString *)provider;
{
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", name, provider];
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
						   (NSString *)kSecClassGenericPassword, kSecClass,
						   serviceName, kSecAttrService,
						   @"SoundCloud API OAuth Token", kSecAttrLabel,
						   self.key, kSecAttrAccount,
						   self.secret, kSecAttrGeneric,
						   nil];
	[self removeFromDefaultKeychainWithAppName:name serviceProviderName:provider];
	return SecItemAdd((CFDictionaryRef)query, NULL);
}

- (int)removeFromDefaultKeychainWithAppName:(NSString *)name serviceProviderName:(NSString *)provider;
{
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", name, provider];	
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
						   (NSString *)kSecClassGenericPassword, kSecClass,
						   serviceName, kSecAttrService,
						   nil];
	return SecItemDelete((CFDictionaryRef)query);
}
@end

#else

#pragma mark -
#pragma mark Mac & Simulator implementation

@implementation OAToken (SoundCloudAPI)

- (id)initWithDefaultKeychainUsingAppName:(NSString *)name serviceProviderName:(NSString *)provider;
{
	if (!(self = [self init]))
		return nil;
    SecKeychainItemRef item = nil;
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", name, provider];
	OSStatus status = SecKeychainFindGenericPassword(NULL,
													 strlen([serviceName UTF8String]),
													 [serviceName UTF8String],
													 0,
													 NULL,
													 NULL,
													 NULL,
													 &item);
    if (status != noErr) {
        return nil;
    }
    
    // from Advanced Mac OS X Programming, ch. 16
    UInt32 length;
    char *password;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
    
    list.count = 4;
    list.attr = attributes;
    
    status = SecKeychainItemCopyContent(item, NULL, &list, &length, (void **)&password);
    if (status == noErr) {
        self.key = [NSString stringWithCString:list.attr[0].data
									  encoding:NSUTF8StringEncoding];
        if (password != NULL) {
            char passwordBuffer[1024];
            
            if (length > 1023) {
                length = 1023;
            }
            strncpy(passwordBuffer, password, length);
            
            passwordBuffer[length] = '\0';
			NSString *passwordString = [NSString stringWithCString:passwordBuffer
														  encoding:NSUTF8StringEncoding];
			NSArray *passwordComponents = [passwordString componentsSeparatedByString:@"&"];
			self.secret = [passwordComponents objectAtIndex:0];
			if (passwordComponents.count >= 2) { 
				self.verifier = [passwordComponents objectAtIndex:1];
			}
        }
        SecKeychainItemFreeContent(&list, password);
    } else {
		// TODO find out why this always works in i386 and always fails on ppc
		NSLog(@"Error from SecKeychainItemCopyContent: %d", status);
        return nil;
    }
    CFRelease(item);
	return self;
}

- (int)storeInDefaultKeychainWithAppName:(NSString *)name serviceProviderName:(NSString *)provider;
{
	[self removeFromDefaultKeychainWithAppName:name serviceProviderName:provider];
	NSString *passwordString = [NSString stringWithFormat:@"%@&%@", self.secret, self.verifier];
	OSStatus status = SecKeychainAddGenericPassword(NULL,
                                                    [name length] + [provider length] + 9, 
                                                    [[NSString stringWithFormat:@"%@::OAuth::%@", name, provider] UTF8String],
                                                    [self.key length],                        
                                                    [self.key UTF8String],
                                                    [passwordString length],
                                                    [passwordString UTF8String],
                                                    NULL
                                                    );
	return status;
}


- (int)removeFromDefaultKeychainWithAppName:(NSString *)name serviceProviderName:(NSString *)provider;
{
	SecKeychainItemRef item = nil;
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", name, provider];
	OSStatus status;
	
	status = SecKeychainFindGenericPassword(NULL,
											strlen([serviceName UTF8String]),
											[serviceName UTF8String],
											0,
											NULL,
											NULL,
											NULL,
											&item);
    if (status != noErr) {
		NSLog(@"Error finding token to delete from keychain");
        return status;
	}
	status = SecKeychainItemDelete(item);
	CFRelease(item);
	return status;
}
@end

#endif
