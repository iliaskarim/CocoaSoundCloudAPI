/*
 *  QuartzCore+SoundCloudAPI.h
 *  Soundcloud
 *
 *  Created by Gernot Poetsch on 23.11.10.
 *  Copyright 2010 nxtbgthng. All rights reserved.
 *
 */

#include <QuartzCore/QuartzCore.h>

extern void SC_CGContextAddRoundedRect(CGContextRef context,
                                       CGRect rect,
                                       CGFloat radius);

extern void SC_CGPathAddRoundedRect(CGMutablePathRef path,
                                    const CGAffineTransform *m,
                                    CGRect rect,
                                    CGFloat radius);
