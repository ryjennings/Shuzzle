//
//  GameOverPopup.m
//  Shuzzle
//
//  Created by Ryan Jennings on 2/15/11.
//  Copyright 2011 Appuous, Inc. All rights reserved.
//

#import "GameOverPopup.h"

@implementation GameOverPopup

@synthesize scoreLabel, modeLabel, bannerView, btn1, btn2, btn3, popupFrame;

- (void)dealloc
{
	[scoreLabel release];
	[modeLabel release];
	[bannerView release];
	[btn1 release];
	[btn2 release];
	[btn3 release];
	[popupFrame release];
	
    [super dealloc];
}

@end
