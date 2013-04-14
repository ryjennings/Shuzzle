//
//  PowerupIndicator.h
//  Shuzzle
//
//  Created by Ryan Jennings on 2/24/11.
//  Copyright 2011 Appuous, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PowerupIndicator : UIView
{
	UILabel *label;
	UIImageView *arrow1;
	UIImageView *arrow2;
	UIImageView *arrow3;
	UIImageView *arrow4;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIImageView *arrow1;
@property (nonatomic, retain) IBOutlet UIImageView *arrow2;
@property (nonatomic, retain) IBOutlet UIImageView *arrow3;
@property (nonatomic, retain) IBOutlet UIImageView *arrow4;

- (void)animateArrows;
- (void)fadeArrow:(UIImageView *)arrow;

@end
