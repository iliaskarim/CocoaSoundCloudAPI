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

#import "SCParameterTableDataSource.h"


@implementation SCParameterTableDataSource

#pragma mark Lifecycle

- (id) init
{
	self = [super init];
	if (self != nil) {
		parameterDictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (void)dealloc;
{
	[parameterDictionary release];
	[super dealloc];
}

#pragma mark Accessors

@synthesize parameterDictionary;

- (void)setParameterDictionary:(NSDictionary *)inParameterDictionary;
{
	if(inParameterDictionary != parameterDictionary){
		[parameterDictionary release];
		parameterDictionary = [inParameterDictionary mutableCopy];
	}
}

#pragma mark Datasource informal protocol

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
	return [parameterDictionary count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
	NSString *key = [[parameterDictionary allKeys] objectAtIndex:row];
	NSString *colIdentifier = [tableColumn identifier];
	if([colIdentifier isEqualTo:@"Key"])
		return key;
	if([colIdentifier isEqualTo:@"Value"])
		return [parameterDictionary objectForKey:key];
	NSLog(@"Unknown Table Column: %@", colIdentifier);
	return @"check parameter datasource.. :(";
}

#pragma mark adding & removing parameters
- (void)addParameterWithKey:(NSString *)inKey value:(NSString *)inValue;
{
	NSLog(@"added parameter with key %@ and value %@", inKey, inValue);
	[parameterDictionary setObject:inValue forKey:inKey];
}

- (void)removeParametersAtIndexes:(NSIndexSet *)indexes;
{
	NSArray *keysToRemove = [[parameterDictionary allKeys] objectsAtIndexes:indexes];
	for (NSString *key in keysToRemove) {
		[parameterDictionary removeObjectForKey:key];
	}
}
@end
