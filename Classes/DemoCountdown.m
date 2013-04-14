//
//  DemoCountdown.m
//  Shuzzle
//
//  Created by Ryan Jennings on 2/25/11.
//  Copyright 2011 Appuous, Inc. All rights reserved.
//

#import "DemoCountdown.h"
#import "FormicAppDelegate.h"

@interface DemoCountdown (Private)

- (void)startCountdown;
- (void)countdownAdvanced;

@end

@implementation DemoCountdown (Private)

- (void)startCountdown
{
	if (countdownTimer == nil) {
		countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
										 target:self 
									   selector:@selector(countdownAdvanced)
									   userInfo:nil 
										repeats:NO];
	}
}

- (void)countdownAdvanced
{
	self.remainingSeconds--;
	if (self.remainingSeconds < 1) {
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:[NSNumber numberWithInt:FGDemoStatusExpired] forKey:@"demostatus"];
		countdownTimer = nil;
		[AppDelegate displayDemoExpiredViewController];
		return;
	}			
	NSLog(@"self.remainingSeconds = %i", self.remainingSeconds);
	NSString *seconds;
	int m = 0;
	int s = self.remainingSeconds;
	if (s > 59) {
		m = floor(s/60.0);
		s = s%60;
	}
	if (s < 10) {
		seconds = [NSString stringWithFormat:@"0%i", s];
	} else {
		seconds = [NSString stringWithFormat:@"%i", s];
	}
	label.text = [NSString stringWithFormat:@"%i:%@", m, seconds];
	
	if (countdownIsActive) {
		countdownTimer = nil;
		[self startCountdown];
	}
}

@end

@implementation DemoCountdown

@synthesize label, arrow1, arrow2, arrow3, arrow4;
@synthesize remainingSeconds;

- (void)startArrows
{
	[self performSelector:@selector(fadeArrow:) withObject:arrow1 afterDelay:0.0];
	[self performSelector:@selector(fadeArrow:) withObject:arrow2 afterDelay:0.2];
	[self performSelector:@selector(fadeArrow:) withObject:arrow3 afterDelay:0.4];
	[self performSelector:@selector(fadeArrow:) withObject:arrow4 afterDelay:0.6];
	
	countdownIsActive = YES;
	[self startCountdown];
}

- (void)fadeArrow:(UIImageView *)arrow
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	arrow.alpha = (arrow.alpha == 1.0) ? 0.0 : 1.0;
	[UIView commitAnimations];
	
	[self performSelector:@selector(fadeArrow:) withObject:arrow afterDelay:0.5];
}

- (void)stopArrows
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	arrow1.alpha = 1.0;
	arrow2.alpha = 1.0;
	arrow3.alpha = 1.0;
	arrow4.alpha = 1.0;
	
	countdownIsActive = NO;
	if (countdownTimer != nil) {
		[countdownTimer invalidate];
		countdownTimer = nil;
	}
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[label release];
	[arrow1 release];
	[arrow2 release];
	[arrow3 release];
	[arrow4 release];
	
    [super dealloc];
}

@end
