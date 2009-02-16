/*
 Copyright 2009 Ullrich Schäfer, Gernot Poetsch for SoundCloud Ltd.
 All rights reserved.
 
 This file is part of SoundCloudAPI.
 
 SoundCloudAPI is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published
 by the Free Software Foundation, version 3.
 
 SoundCloudAPI is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with SoundCloudAPI. If not, see <http://www.gnu.org/licenses/>.
 
 For more information and documentation refer to <http://soundcloud.com/api>.
 */

#import "OAToken+Keychain.h"
#import <Security/Security.h>

#if TARGET_OS_IPHONE && (! TARGET_IPHONE_SIMULATOR)

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
		NSLog(@"Error while initializing OAtoken: %d", status);
		[result release];
		return nil;
	}
	
	if (self = [super init]) {
		self.key = [result objectForKey:(NSString *)kSecAttrAccount];
		self.secret = [result objectForKey:(NSString *)kSecAttrGeneric];
		// put init stuff here
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

#elif !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#pragma mark -
#pragma mark Mac & Simulator implementation

@implementation OAToken (SoundCloudAPI)

- (id)initWithDefaultKeychainUsingAppName:(NSString *)name serviceProviderName:(NSString *)provider;
{
	if (!(self = [super init]))
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
                                        length:list.attr[0].length];
        if (password != NULL) {
            char passwordBuffer[1024];
            
            if (length > 1023) {
                length = 1023;
            }
            strncpy(passwordBuffer, password, length);
            
            passwordBuffer[length] = '\0';
			self.secret = [NSString stringWithCString:passwordBuffer];
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
	OSStatus status = SecKeychainAddGenericPassword(NULL,
                                                    [name length] + [provider length] + 9, 
                                                    [[NSString stringWithFormat:@"%@::OAuth::%@", name, provider] UTF8String],
                                                    [self.key length],                        
                                                    [self.key UTF8String],
                                                    [self.secret length],
                                                    [self.secret UTF8String],
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
