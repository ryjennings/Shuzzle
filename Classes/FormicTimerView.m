//
//  FormicTimerView.m
//  Formic
//
//  Created by Austin Evers on 11/15/2009.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import "FormicTimerView.h"

@implementation FormicTimerView

- (id)init
{
	int	i;
	
	// cache the images
	for (i = 0; i < GAME_TIMERSTEPS; i++)
		mProgressImage[i] = [[UIImage imageNamed:[NSString stringWithFormat:@"timer-%d.png", i+1]] retain];
	self = [super initWithImage:mProgressImage[0]];
	if (!self)
		return nil;
	
	// other initialization
	mPosition = 0;
	
	return self;
}

- (void)dealloc
{
	int i;
	
	// release the cached images
	for (i = 0; i < GAME_TIMERSTEPS; i++)
		[mProgressImage[i] release];
	
	// finish it
	[super dealloc];
}

#pragma mark -

- (void)setPosition:(int)position
{
	// update the timer circle
	[self setImage:mProgressImage[position]];
	mPosition = position;
}

@end
