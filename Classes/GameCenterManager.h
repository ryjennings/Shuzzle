//
//  GameCenterManager.h
//  Shuzzle
//
//  Created by Ryan Jennings on 9/20/10.
//  Copyright 2010 Ryan Jennings. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GKLeaderboard, GKAchievement, GKPlayer;

@protocol GameCenterManagerDelegate <NSObject>
@optional
- (void) processGameCenterAuth: (NSError*) error;
- (void) scoreReported: (NSError*) error;
- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error;
- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
- (void) achievementResetResult: (NSError*) error;
- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error;
@end

@interface GameCenterManager : NSObject
{
	NSMutableDictionary* earnedAchievementCache;
	id <GameCenterManagerDelegate, NSObject> delegate;
}

//This property must be attomic to ensure that the cache is always in a viable state...
@property (retain) NSMutableDictionary* earnedAchievementCache;

@property (nonatomic, assign)  id <GameCenterManagerDelegate> delegate;

+ (BOOL) isGameCenterAvailable;
- (void) authenticateLocalUser;
- (void) submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete;

@end
