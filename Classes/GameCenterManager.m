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
                NSLog(@"callDelegateOnMainThread");
			 [self callDelegateOnMainThread:@selector(processGameCenterAuth:) withArg:NULL error:error];
            }
		 }];
	}
}

- (void)submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
 
	NSLog(@"Submitting achievement %@ %f", identifier, percentComplete);
	if (self.earnedAchievementCache == NULL) {
        NSLog(@"1");
		[GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *scores, NSError *error)
		{
            NSLog(@"2");
			 if (error == NULL) {
                 NSLog(@"3");
				 NSMutableDictionary *tempCache = [NSMutableDictionary dictionaryWithCapacity:[scores count]];
                 NSLog(@"4");
				 for (GKAchievement *score in scores) {
                     NSLog(@"5");
					 [tempCache setObject:score forKey:score.identifier];
                     NSLog(@"6");
				 }
                 NSLog(@"7");
				 self.earnedAchievementCache = tempCache;
                 NSLog(@"8");
				 if (percentComplete != 0) {
                     NSLog(@"9");
					 [self submitAchievement:identifier percentComplete:percentComplete];
                     NSLog(@"10");
                 }
                 NSLog(@"11");
			 } else {
                 NSLog(@"12");
				 // Something broke loading the achievement list. Error out, and we'll try again the next time achievements submit.
//				 [self callDelegateOnMainThread:@selector(achievementSubmitted:error:) withArg:NULL error:error];
                 NSLog(@"13");
			 }
		 }];
        NSLog(@"14");
	} else {
        NSLog(@"15");
		// Search the list for the ID we're using...
		GKAchievement *achievement = [self.earnedAchievementCache objectForKey:identifier];
        NSLog(@"16");
		if (achievement != NULL) {
            NSLog(@"17");
			if ((achievement.percentComplete >= 100.0) || (achievement.percentComplete >= percentComplete)) {
                NSLog(@"18");
				// Achievement has already been earned so we're done
				achievement = NULL;
                NSLog(@"19");
			}
            NSLog(@"20");
			achievement.percentComplete = percentComplete;
            NSLog(@"21");
		} else {
            NSLog(@"22");
			achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
            NSLog(@"23");
			achievement.percentComplete = percentComplete;
            NSLog(@"24");
			// Add achievement to achievement cache...
			[self.earnedAchievementCache setObject:achievement forKey:achievement.identifier];
            NSLog(@"25");
		}
        NSLog(@"26");
		if (achievement != NULL) {
            NSLog(@"27");
			// Submit the achievement...
			[achievement reportAchievementWithCompletionHandler: ^(NSError *error)
			 {
                 NSLog(@"28");
				 [self callDelegateOnMainThread:@selector(achievementSubmitted:error:) withArg:achievement error:error];
                 NSLog(@"29");
			 }];
		}
	}
    }
    NSLog(@"30");
}

@end
