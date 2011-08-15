/*
 *  QuartzCore_GPKit.c
 *  Soundcloud
 *
 *  Created by Gernot Poetsch on 23.11.10.
 *  Copyright 2010 nxtbgthng. All rights reserved.
 *
 */

#include "QuartzCore+SoundCloudAPI.h"

void SC_CGContextAddRoundedRect(CGContextRef context,
                                CGRect rect,
                                CGFloat radius)
{
    CGMutablePathRef path = CGPathCreateMutable();
    SC_CGPathAddRoundedRect(path, nil, rect, radius);
    CGContextAddPath(context, path);
    CGPathRelease(path);
}


void SC_CGPathAddRoundedRect(CGMutablePathRef path,
                             const CGAffineTransform *m,
                             CGRect rect,
                             CGFloat radius)
{    
    CGPathMoveToPoint(path, m,
                      rect.origin.x, rect.origin.y + radius);
    CGPathAddArcToPoint(path, m,
                        rect.origin.x, rect.origin.y,
                        rect.origin.x + radius, rect.origin.y,
                        radius);
    CGPathAddArcToPoint(path, m,
                        rect.origin.x + rect.size.width, rect.origin.y,
                        rect.origin.x + rect.size.width, rect.origin.y + radius,
                        radius);
    CGPathAddArcToPoint(path, m,
                        rect.origin.x + rect.size.width, rect.origin.y + rect.size.height,
                        rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height,
                        radius);
    CGPathAddArcToPoint(path, m,
                        rect.origin.x, rect.origin.y + rect.size.height,
                        rect.origin.x, rect.origin.y + rect.size.height - radius,
                        radius);
    CGPathCloseSubpath(path);
}
