//
//  PowerupIndicator.m
//  Shuzzle
//
//  Created by Ryan Jennings on 2/24/11.
//  Copyright 2011 Appuous, Inc. All rights reserved.
//

#import "PowerupIndicator.h"

@implementation PowerupIndicator

@synthesize label, arrow1, arrow2, arrow3, arrow4;

- (void)animateArrows
{
	[self performSelector:@selector(fadeArrow:) withObject:arrow1 afterDelay:0.0];
	[self performSelector:@selector(fadeArrow:) withObject:arrow2 afterDelay:0.2];
	[self performSelector:@selector(fadeArrow:) withObject:arrow3 afterDelay:0.4];
	[self performSelector:@selector(fadeArrow:) withObject:arrow4 afterDelay:0.6];
}

- (void)fadeArrow:(UIImageView *)arrow
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	arrow.alpha = (arrow.alpha == 1.0) ? 0.0 : 1.0;
	[UIView commitAnimations];

	[self performSelector:@selector(fadeArrow:) withObject:arrow afterDelay:0.5];
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
