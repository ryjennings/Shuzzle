//
//  FormicAppDelegate.h
//  Formic
//
//  Created by Austin Evers on 11/15/2009.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <MediaPlayer/MediaPlayer.h>
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"

@class FormicGame;
@class MainMenuViewController;
@class LevelSelectViewController;
@class InstructionsViewController;
@class SettingsViewController;
@class FormicViewController;
@class SplashViewController;

#define AppDelegate	(FormicAppDelegate *)[[UIApplication sharedApplication] delegate]

@interface FormicAppDelegate : NSObject <UIApplicationDelegate,
											GKLeaderboardViewControllerDelegate,
												UINavigationControllerDelegate,
													GameCenterManagerDelegate>
{
	GameCenterManager *gameCenterManager;
	
	UIWindow *window;
	FormicGame *game;
	BOOL savedGame;
	
	BOOL musicOff;
	BOOL effectsOff;
	BOOL vibrateOff;
	BOOL colorBlindnessOn;
	BOOL advancedPieceOn;

	float volume;
	
	IBOutlet MainMenuViewController *mainMenuViewController;
	IBOutlet LevelSelectViewController *levelSelectViewController;
	IBOutlet InstructionsViewController *instructionsViewController;
	IBOutlet SettingsViewController *settingsViewController;
	IBOutlet FormicViewController *formicViewController;
	IBOutlet SplashViewController *splashViewController;
	
	MPMusicPlayerController *musicPlayer;	
	MPMediaItemCollection *userMediaItemCollection;

	UIViewController *currentViewController;
	UIViewController *showViewController;
	
	AVAudioPlayer *backMusicPlayer;
	AVAudioPlayer *menuMusicPlayer;
	
	FGControlScheme controlScheme;
    UIView *loadingView;
    UILabel *loadingLabel;
	UIAlertView *pauseAlert;

	NSMutableArray *achievementAlertQueue;
	BOOL isAnnouncingAchievement;
	
	BOOL connectedToGameCenter;
    BOOL cannotLoadLeaderboard;
	BOOL shouldShowBigShuzzle;
}

@property (nonatomic, retain) GameCenterManager *gameCenterManager;

@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UILabel *loadingLabel;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (readonly) FormicGame *game;
@property (nonatomic, assign) BOOL musicOff;
@property (nonatomic, assign) BOOL effectsOff;
@property (nonatomic, assign) BOOL vibrateOff;
@property (nonatomic, assign) BOOL colorBlindnessOn;
@property (nonatomic, assign) BOOL advancedPieceOn;
@property (nonatomic, assign) BOOL savedGame;

@property (nonatomic, assign) BOOL connectedToGameCenter;
@property (nonatomic, assign) BOOL cannotLoadLeaderboard;
@property (nonatomic, assign) BOOL shouldShowBigShuzzle;

@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;
@property (nonatomic, retain) MPMediaItemCollection	*userMediaItemCollection; 

@property (nonatomic, assign) float volume;

@property (nonatomic, assign) FGControlScheme controlScheme;

- (void)showView:(UIViewController *)controller;
- (void)showMainMenuView;
- (void)showLevelSelectView;
- (void)showInstructionsView;
- (void)showSettingsView;
- (void)showFormicView;
- (void)setControlScheme:(FGControlScheme)scheme;
- (void)setVolume:(float)val;
- (void)setMusicOff:(BOOL)val;
- (void)readDefaults;
- (void)writeDefaults;
- (void)playMenuMusic:(BOOL)val;
- (void)stopMenuMusic;
- (void)playBackMusic:(BOOL)val;
- (void)playGameOverMusic;
- (void)playSlowdownSound;
- (void)playGoldShapeSound;
- (void)playRadiationSound;
- (void)playDoublePointsSound;
- (void)playCountdownSound;
- (void)playMoveSound;
- (void)playErrorSound;
- (void)playButtonSound;
- (void)playUniformitySound;
- (void)playExtraLifeSound;
- (void)doVibration;
- (void)returnToMainMenuViewWithoutRestartingMusic;
- (void)updatePlayerQueueWithMediaCollection:(MPMediaItemCollection *)mediaItemCollection;
- (void)playSystemSound:(NSString *)sound;
- (void)updateLoadingLabel:(NSString *)labelText;
- (void)showLoadingViewWithLabel:(NSString *)labelText;
- (void)dismissLoadingView;
- (void)removeLoadingView;

- (NSDictionary *)checkEarnedAchievements;
- (void)achievementSubmitted:(GKAchievement *)ach error:(NSError *)error;
- (void)addToAchievementAnnouncementQueue:(NSString *)identifier;
- (void)announceNextAchievementInQueue;
- (void)displayLeaderBoard;
- (void)showMainMenuViewAndLeaderBoard;

- (void)checkForInternetConnection;
- (CABasicAnimation *)rotationAnimation;

@end
