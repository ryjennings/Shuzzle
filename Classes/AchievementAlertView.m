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
    self = [super initWithFrame:CGRectMake(13.0, 266.0, 454.0, 54.0)];
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
	achievementLabel.textAlignment = UITextAlignmentCenter;
	[self addSubview:achievementLabel];
	
	NSString *achievementTitle;
	
	if (identifier == kAchievementBackToBack) achievementTitle = kTitleBackToBack;
	else if (identifier == kAchievementConsecutiveCombos) achievementTitle = kTitleConsecutiveCombos;
	else if (identifier == kAchievementDoubleCombos) achievementTitle = kTitleDoubleCombos;
	else if (identifier == kAchievementTiltExpert) achievementTitle = kTitleTiltExpert;
	else if (identifier == kAchievementOneLife) achievementTitle = kTitleOneLife;
	else if (identifier == kAchievementNoPowerups) achievementTitle = kTitleNoPowerups;
	else if (identifier == kAchievementLowPts) achievementTitle = kTitleLowPts;
	else if (identifier == kAchievementMedPts) achievementTitle = kTitleMedPts;
	else if (identifier == kAchievementHighPts) achievementTitle = kTitleHighPts;
	else if (identifier == kAchievementEliminator) achievementTitle = kTitleEliminator;
	
	achievementImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", identifier]];
	achievementLabel.text = [NSString stringWithFormat:@"Achievement Earned: %@", achievementTitle];
}

- (void)dealloc
{
    [super dealloc];
}

@end
