//
//  FormicViewController.h
//  Formic
//
//  Created by Austin Evers on 11/15/2009.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "FormicGame.h"
#import "RRSGlowLabel.h"
#import "CountdownTimer.h"

@class FormicTimerView;
@class GameOverPopup;
@class PowerupIndicator;

@interface FormicViewController : UIViewController <UIAccelerometerDelegate>
{
	UIImageView		*mStartView;
	UIImageView		*mCenterView;
	UIImageView		*mMovedView;
	UIImageView		*mCircleView[GAME_CIRCLES];
	
	//
	// Powerups
	//
	
	IBOutlet UIImageView *bgPowerup;
	IBOutlet UIImageView *mainBackground;
	IBOutlet UIButton *btnPowerup1;
	IBOutlet UIButton *btnPowerup2;
	IBOutlet UIButton *btnPowerup3;
	
	IBOutlet UILabel *lowerLabel;

	IBOutlet UIView *accessoryView;
	
	int powerupInUseSlot;
	BOOL pulsingPowerUpButton;
	
	UIButton *btnPause;
	
	FormicTimerView	*mTimerView;

	RRSGlowLabel	*mLivesView;
	RRSGlowLabel	*mLivesZoomView;
	RRSGlowLabel	*mPointsView;
	RRSGlowLabel	*mPointsZoomView;

	CountdownTimer	*countdownTimer;
	
	GameOverPopup	*gameOverPopup;
	UIView			*gameOverView;
	
	PowerupIndicator *powerupIndicator;
	
	UIAlertView		*replayAlert;
	UIAlertView		*pauseAlert;
			
	float accelX;
	float accelY;	
	
	float oldX;
	float oldY;
	
	float xCenter;
	float yCenter;
	
	int soundLoop;
	
	BOOL tiltHit;
	BOOL outOfPosition;
	BOOL pulsingLivesCritical;
	BOOL viewHasAppearedForTheFirstTime;
	
	NSTimer *accelTimer;
	float accelTimerCount;
	
	SystemSoundID errornoise;
	
	UIImageView *livesCritical;
	UIImageView *scoreCritical;
	
	int consecutiveGames;
	
	UIView *blackness;
}

@property (nonatomic, retain) IBOutlet GameOverPopup *gameOverPopup;
@property (nonatomic, retain) IBOutlet PowerupIndicator *powerupIndicator;
@property (nonatomic, retain) IBOutlet UIButton *btnPause;
@property (nonatomic, retain) IBOutlet UIImageView *livesCritical;
@property (nonatomic, retain) IBOutlet UIImageView *scoreCritical;
@property (nonatomic, retain) CountdownTimer *countdownTimer;

- (IBAction)onButtonPause:(id)sender;
- (IBAction)onButtonPowerUp:(id)sender;
- (void)zoomInCenterwithColor:(int)color andShape:(int)shape;
- (void)zoomOutCenter;
- (void)moveCenterToCircle:(int)circle;
- (void)zoomInCircle:(int)circle withColor:(int)color andShape:(int)shape;
- (void)updateTimer:(int)timervalue;
- (void)updateLives:(int)lives;
- (void)updateLivesWithoutZooming:(int)lives;
- (void)updateScore:(int)points;
- (void)updateScoreWithoutZooming:(int)points;
- (void)startGame;
- (void)gameOver;
- (void)showPauseAlert;
- (void)resetView;
- (void)prepareForNewGame;
- (void)activateLivesCritical;
- (void)deactivateLivesCritical;
- (void)pulseLivesCritical;
- (void)localNewPieceForCircle:(NSNumber *)circle;
- (void)debugMessage:(NSString *)msg;
- (void)enablePauseButton;
- (void)playSlowdownSoundLoop;

// Blitz

- (void)flashScoreCritical;

// Powerups

- (void)activatePowerupSlot1;
- (void)activatePowerupSlot2;
- (void)activatePowerupSlot3;
- (void)endPowerup;
- (void)loadPowerupSlot:(int)slot;
- (void)fadeInPowerupButton:(UIButton *)btn;
- (void)pulsePowerupButton:(UIButton *)btn;
- (void)restoreSavedPowerups:(NSArray *)pu;
- (void)restoreSavedBackground:(UIImage *)img;
- (void)showPowerupIndicator;
- (void)hidePowerupIndicator;

// Game Over

- (void)showGameOverPopup;
- (void)removeGameOverPopup;
- (void)onGameOverPopupBtn1:(id)sender;
- (void)onGameOverPopupBtn2:(id)sender;
- (void)onGameOverPopupBtn3:(id)sender;

// Golden Shape

- (void)announceGoldenShape;

@end
