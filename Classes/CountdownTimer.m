//
//  CountdownTimer.m
//  Shuzzle
//
//  Created by Ryan Jennings on 6/9/10.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import "CountdownTimer.h"
#import "FormicAppDelegate.h"
#import "FormicGame.h"

@implementation CountdownTimer

- (void)drawRect:(CGRect)rect
{	
	countdown = 4;
	rect = CGRectMake(0.0, 0.0, 100.0, 100.0);

	mCountdownView = [[RRSGlowLabel alloc] initWithFrame:rect];
	mCountdownView.text = @"3";
	mCountdownView.font = [UIFont boldSystemFontOfSize:32.5];
	mCountdownView.textAlignment = NSTextAlignmentCenter;
	mCountdownView.textColor = [UIColor whiteColor];
	mCountdownView.backgroundColor = [UIColor clearColor];
	mCountdownView.glowColor = [UIColor colorWithRed:0.8 green:1.0 blue:1.0 alpha:1.0];
    mCountdownView.glowOffset = CGSizeMake(0.0, 0.0);
    mCountdownView.glowAmount = 50.0;
	[self addSubview:mCountdownView];
	
	[self performSelector:@selector(animateCountdown) withObject:nil afterDelay:PAUSE_BEFORE_COUNTDOWN];
}

- (void)animateCountdown
{
	countdown--;
	if (countdown == 0) return;

	[AppDelegate playCountdownSound];

	mCountdownView.text = [NSString stringWithFormat:@"%i", countdown];
	mCountdownView.alpha = 1.0;
	mCountdownView.transform = CGAffineTransformMakeScale(3.0, 3.0);

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelay:0.0];
	mCountdownView.alpha = 1.0;
	mCountdownView.transform = CGAffineTransformMakeScale(1.0, 1.0);
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelay:0.4];
	mCountdownView.alpha = 0.0;
	mCountdownView.transform = CGAffineTransformMakeScale(0.33, 0.33);
	[UIView commitAnimations];
	
	if (countdown > 1) {
		[self performSelector:@selector(animateCountdown) withObject:nil afterDelay:0.8];
	} else {
		[self performSelector:@selector(startGame) withObject:nil afterDelay:0.7];
	}
}

- (void)resetTimer
{
	countdown = 4;
	[self animateCountdown];
}

- (void)startGame
{
	[[AppDelegate game] startGame];
}

- (void)stopCountdown
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)dealloc {
	[mCountdownView release];
    [super dealloc];
}

@end
