//
//  GameCenterManager.m
//  Shuzzle
//
//  Created by Ryan Jennings on 9/20/10.
//  Copyright 2010 Ryan Jennings. All rights reserved.
//

#import "GameCenterManager.h"
#import <GameKit/GameKit.h>

@implementation GameCenterManager

@synthesize earnedAchievementCache;
@synthesize delegate;

- (id)init
{
	self = [super init];
	if (self != NULL) {
		earnedAchievementCache = NULL;
	}
	return self;
}

- (void)dealloc
{
	self.earnedAchievementCache = NULL;
	[super dealloc];
}

- (void)callDelegate:(SEL)selector withArg:(id)arg error:(NSError *)err
{
	assert([NSThread isMainThread]);
	if ([delegate respondsToSelector:selector]) {
		if (arg != NULL) {
			[delegate performSelector:selector withObject:arg withObject:err];
		} else {
			[delegate performSelector:selector withObject:err];
		}
	}
}

- (void)callDelegateOnMainThread:(SEL)selector withArg:(id)arg error:(NSError *)err
{
	dispatch_async(dispatch_get_main_queue(), ^(void)
				   {
					   [self callDelegate:selector withArg:arg error:err];
				   });
}

+ (BOOL)isGameCenterAvailable
{
	// Check for the presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));	
	// Check if the device is running iOS 4.1 or later
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	return (gcClass && osVersionSupported);
}

- (void)authenticateLocalUser
{
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewcontroller, NSError *error) {
            if (!error) {
			 [self callDelegateOnMainThread:@selector(processGameCenterAuth:) withArg:NULL error:error];
            }
		 }];
	}
}

- (void)submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
 
	NSLog(@"Submitting achievement: %@ %f", identifier, percentComplete);
	if (self.earnedAchievementCache == NULL) {
		[GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *scores, NSError *error)
		{
			 if (error == NULL) {
				 NSMutableDictionary *tempCache = [NSMutableDictionary dictionaryWithCapacity:[scores count]];
				 for (GKAchievement *score in scores) {
					 [tempCache setObject:score forKey:score.identifier];
				 }
				 self.earnedAchievementCache = tempCache;
				 if (percentComplete != 0) {
					 [self submitAchievement:identifier percentComplete:percentComplete];
                 }
			 } else {
				 // Something broke loading the achievement list. Error out, and we'll try again the next time achievements submit.
				 [self callDelegateOnMainThread:@selector(achievementSubmitted:error:) withArg:NULL error:error];
			 }
		 }];
	} else {
		// Search the list for the ID we're using...
		GKAchievement *achievement = [self.earnedAchievementCache objectForKey:identifier];
		if (achievement != NULL) {
			if ((achievement.percentComplete >= 100.0) || (achievement.percentComplete >= percentComplete)) {
				// Achievement has already been earned so we're done
				achievement = NULL;
			}
			achievement.percentComplete = percentComplete;
		} else {
			achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
			achievement.percentComplete = percentComplete;
			// Add achievement to achievement cache...
			[self.earnedAchievementCache setObject:achievement forKey:achievement.identifier];
		}
		if (achievement != NULL) {
			// Submit the achievement...
			[achievement reportAchievementWithCompletionHandler: ^(NSError *error)
			 {
				 [self callDelegateOnMainThread:@selector(achievementSubmitted:error:) withArg:achievement error:error];
			 }];
		}
	}
    }
}

@end
