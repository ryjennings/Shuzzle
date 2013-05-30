//
//  AchievementAlertView.m
//  Shuzzle
//
//  Created by Ryan Jennings on 2/7/11.
//  Copyright 2011 Appuous, Inc. All rights reserved.
//

#import "AchievementAlertView.h"

@implementation AchievementAlertView

- (id)initWithAchievement:(NSString *)anIdentifier
{
    UIWindow *frontWindow = [[UIApplication sharedApplication] keyWindow];
    self = [super initWithFrame:CGRectMake((frontWindow.frame.size.height / 2) - 227, 266.0, 454.0, 54.0)];
    if (self) {
        identifier = anIdentifier;
		super.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	UIImage *background = [UIImage imageNamed:@"achievement-alert.png"];
	[background drawAtPoint:CGPointMake(0.0, 0.0)];
	
	UIImageView *achievementImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(13.0, 11.0, 27.0, 27.0)] autorelease];
	[self addSubview:achievementImageView];
	
	UILabel *achievementLabel = [[[UILabel alloc] initWithFrame:CGRectMake(48.0, 14.0, 358.0, 21.0)] autorelease];
	achievementLabel.backgroundColor = [UIColor clearColor];
	achievementLabel.textColor = [UIColor whiteColor];
	achievementLabel.font = [UIFont boldSystemFontOfSize:15];
	achievementLabel.textAlignment = NSTextAlignmentCenter;
	[self addSubview:achievementLabel];
	
	NSString *achievementTitle;
	
	if ([identifier isEqualToString:kAchievementBackToBack]) achievementTitle = kTitleBackToBack;
	else if ([identifier isEqualToString:kAchievementConsecutiveCombos]) achievementTitle = kTitleConsecutiveCombos;
	else if ([identifier isEqualToString:kAchievementDoubleCombos]) achievementTitle = kTitleDoubleCombos;
	else if ([identifier isEqualToString:kAchievementTiltExpert]) achievementTitle = kTitleTiltExpert;
	else if ([identifier isEqualToString:kAchievementOneLife]) achievementTitle = kTitleOneLife;
	else if ([identifier isEqualToString:kAchievementNoPowerups]) achievementTitle = kTitleNoPowerups;
	else if ([identifier isEqualToString:kAchievementLowPts]) achievementTitle = kTitleLowPts;
	else if ([identifier isEqualToString:kAchievementMedPts]) achievementTitle = kTitleMedPts;
	else if ([identifier isEqualToString:kAchievementHighPts]) achievementTitle = kTitleHighPts;
	else if ([identifier isEqualToString:kAchievementEliminator]) achievementTitle = kTitleEliminator;
	
	achievementImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", identifier]];
	achievementLabel.text = [NSString stringWithFormat:@"Achievement Earned: %@", achievementTitle];
}

- (void)dealloc
{
    [super dealloc];
}

@end
