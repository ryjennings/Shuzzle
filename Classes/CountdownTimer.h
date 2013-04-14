//
//  CountdownTimer.h
//  Shuzzle
//
//  Created by Ryan Jennings on 6/9/10.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRSGlowLabel.h"

@interface CountdownTimer : UIView
{
	int				countdown;
	RRSGlowLabel	*mCountdownView;
}

- (void)animateCountdown;
- (void)startGame;
- (void)resetTimer;
- (void)stopCountdown;

@end
