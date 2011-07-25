//
//  SCAppIsRunningOnIPad.c
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 22.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#include "SCAppIsRunningOnIPad.h"

BOOL SCAppIsRunningOnIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES; 
	}
#endif
	return NO;
}
 