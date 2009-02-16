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

#import <Foundation/Foundation.h>
#import "NSMutableURLRequest+Parameters.h"

@interface NSMutableURLRequest (SoundCloudAPI)
- (void)setParameterDictionary:(NSDictionary *)parameters;
@end
