//
//  FormicGame.h
//  Formic
//
//  Created by Austin Evers on 11/15/2009.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import <GameKit/GameKit.h>

#define kEasyModeScoreKey @"easyScore"
#define kMediumModeScoreKey @"mediumScore"
#define kHardModeScoreKey @"hardScore"
#define kExtremeModeScoreKey @"extremeScore"
#define kBlitzModeScoreKey @"blitzScore"

@class FormicViewController;

@interface FormicGame : NSObject
{
	FormicViewController	*mController;
	GKLocalPlayer			*localPlayer;
	
	int mCenter[2];					// the color and shape of the center piece
	int mCircle[GAME_CIRCLES][2];	// the colors and shapes of the surrounding circles
	int mTime;						// the state of the running-out timer
	int mLives;						// the amount of lives left
	int mPoints;					// the amount of pieces set
	int mConsecutive;				// number of consecutive matches
    int mConsecutiveShapeOnly;
	FGGameState mState;				// the state of the game (running, over, etc.)
	BOOL mBlocked;					// if blocked for animations to finish
	BOOL mGameBegin;
	
	FGGameLevel gameLevel;
	
	int m_nLevel;
	NSTimer *timer;
	
	//
	// Blitz Mode
	//
	NSTimer *blitzTimer;
	BOOL timerIsFrozen;
	int blitzSeconds;
	
	//
	// Golden Shape
	//
	BOOL displayedGoldenCircle;
	BOOL displayedGoldenCenter;
	BOOL usedGoldenCircle;
	int goldenShape;
	
	//
	// Achievements
	//
	int mPointsWithOneLife;
	int mConsecutiveDouble;
	BOOL playingNthGame;
	BOOL consecutiveCombosAchieved;
	BOOL doubleCombosAchieved;	
	
	//
	// Powerups
	//
	FGPowerup powerupInUse;
	NSMutableArray *powerupSlot; // FGPowerupSlotInactive, FGPowerupSlotActive
	NSMutableArray *powerupInSlot; // FGPowerupRadiation, etc.
	FGPowerupUse powerupUse[GAME_POWERUPS]; // FGPowerupUsed, FGPowerupUnused
	BOOL noPowerupsUsed;
}

@property (nonatomic, retain) NSMutableArray *powerupSlot;
@property (nonatomic, retain) NSMutableArray *powerupInSlot;
@property (nonatomic, assign) FGPowerup powerupInUse;

@property (nonatomic, assign) FGGameState mState;
@property (nonatomic, assign) FGGameLevel gameLevel;

@property (nonatomic, assign, getter = isGameUnlocked) BOOL gameUnlocked;

@property (nonatomic, assign) BOOL mBlocked;
@property (nonatomic, assign) BOOL mGameBegin;
@property (nonatomic, assign) BOOL inBlitzMode;

@property (nonatomic, assign) BOOL playingNthGame;

@property (nonatomic, assign) GKLocalPlayer *localPlayer;

- (id)initWithViewController:(FormicViewController *)controller;

- (void)startGame;
- (void)pauseGame;
- (void)unpauseGame;

- (BOOL)moveCenterToCircle:(int)circle;
- (void)newPieceForCircle:(NSNumber *)circle;

- (void)saveGame;
- (void)eraseSavedGame;
- (void)restoreGame;

- (void)setLevel:(int)level;
- (void)resetGame;
- (void)loseLife;


- (void)restartTimerAfterPause:(double)pause;
- (void)slowdownTimer;

- (void)unblockGame;
- (void)startRestoredGame;
- (void)stopTimer;
- (void)showMainMenu;
- (void)addExtraLife;

//
// Powerups
//
- (void)activateRandomPowerupSlot;
- (void)loadPowerupInSlot:(int)slot;
- (void)resetPowerupSlot:(int)slot;
- (void)completelyResetPowerups;
- (void)replaceCenterShapeForUniformityPowerup;
- (void)usedPowerup;

//
// Blitz Mode
//
- (void)freezeClock;
- (void)unfreezeClock;
- (void)addExtraSeconds;

// Leaderboard
- (void)authenticateLocalUserAndSubmitScore;
- (void)submitScore;
- (void)cleanUpAfterUnsuccessfulScorePost;
// Achievements
- (void)checkForGameOverAchievements;
- (void)submitBackToBackAchievement;

- (void)newCenterPiece;

@end
