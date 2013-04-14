//
//  DemoCountdown.h
//  Shuzzle
//
//  Created by Ryan Jennings on 2/25/11.
//  Copyright 2011 Appuous, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoCountdown : UIView
{
	UILabel *label;
	UIImageView *arrow1;
	UIImageView *arrow2;
	UIImageView *arrow3;
	UIImageView *arrow4;
	
	int remainingSeconds;
	BOOL countdownIsActive;
	
	NSTimer *countdownTimer;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIImageView *arrow1;
@property (nonatomic, retain) IBOutlet UIImageView *arrow2;
@property (nonatomic, retain) IBOutlet UIImageView *arrow3;
@property (nonatomic, retain) IBOutlet UIImageView *arrow4;

@property (nonatomic, assign) int remainingSeconds;

- (void)startArrows;
- (void)fadeArrow:(UIImageView *)arrow;
- (void)stopArrows;

@end
