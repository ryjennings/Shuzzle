//
//  AchievementAlertView.h
//  Shuzzle
//
//  Created by Ryan Jennings on 2/7/11.
//  Copyright 2011 Appuous, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AchievementAlertView : UIView
{
	NSString *identifier;
}

- (id)initWithAchievement:(NSString *)ach;

@end
