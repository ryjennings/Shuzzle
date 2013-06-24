//
//  FormicViewController.m
//  Formic
//
//  Created by Austin Evers on 11/15/2009.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import "FormicViewController.h"
#import "FormicTimerView.h"
#import "FormicView.h"
#import "FormicAppDelegate.h"
#import "CGPointExtension.h"
#import "GameOverPopup.h"
#import "PowerupIndicator.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (float)M_PI * 180.0f)
#define kAccelFilt 0.2
#define TiltSensitivity 750
#define SCORE_FONT_SIZE_LG [UIFont boldSystemFontOfSize:32.5]
#define SCORE_FONT_SIZE_SM [UIFont boldSystemFontOfSize:28]

@implementation FormicViewController

@synthesize btnPause, livesCritical, scoreCritical, countdownTimer, gameOverPopup, powerupIndicator;

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	bgPowerup.alpha = 0.0;
		
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
	if (viewHasAppearedForTheFirstTime) {
		[countdownTimer performSelector:@selector(resetTimer) withObject:nil afterDelay:PAUSE_BEFORE_COUNTDOWN];
		countdownTimer.hidden = NO;
	}
	
	if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz) {
		mainBackground.image = [UIImage imageNamed:@"blitz-1136.png"];
		mLivesView.text = @"1:00";
		mLivesView.font = SCORE_FONT_SIZE_SM;
		mLivesZoomView.text = @"1:00";
		mLivesZoomView.font = SCORE_FONT_SIZE_SM;
		lowerLabel.text = @"CLOCK";
	} else {
		mainBackground.image = [UIImage imageNamed:@"main-1136.png"];
		mLivesZoomView.text = @"0";
		mLivesZoomView.font = SCORE_FONT_SIZE_LG;
		mLivesView.text = @"0";
		mLivesView.font = SCORE_FONT_SIZE_LG;
		lowerLabel.text = @"LIVES";
	}
	
	viewHasAppearedForTheFirstTime = YES;
	btnPause.enabled = NO;
//	if ([[AppDelegate musicPlayer] playbackState] != MPMusicPlaybackStatePlaying) {
//		[AppDelegate playMenuMusic:NO];
//		[AppDelegate playBackMusic:YES];
//	}
	[[AppDelegate game] stopTimer];
	[mTimerView setPosition:0];
	mCenterView.alpha = 0;

	[[AppDelegate game] completelyResetPowerups];

	consecutiveGames = 1;
    
    [timewarp.layer addAnimation:[AppDelegate rotationAnimation] forKey:@"spin"];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
        btnPowerup1.enabled = NO;
        btnPowerup2.enabled = NO;
        btnPowerup3.enabled = NO;
    }
    
    [self setupModeAnnouncer];
    autoWinCount = 0;
}

- (void)appDidBecomeActive:(NSNotification *)note {
    [timewarp.layer removeAllAnimations];
    [timewarp.layer addAnimation:[AppDelegate rotationAnimation] forKey:@"spin"];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	if (gameOverPopup != nil) {
		[gameOverPopup removeFromSuperview];
		[gameOverPopup release], gameOverPopup = nil;
		[blackness removeFromSuperview];
		[blackness release], blackness = nil;
	}
}

- (void)viewDidLoad
{
	viewHasAppearedForTheFirstTime = NO;
		
	gameOverPopup = nil;
	powerupIndicator = nil;
		
	[(FormicView *)[self view] viewDidLoad];
	
	CGPoint center = [[self view] center];

	// create and add the timer view
	mTimerView = [[FormicTimerView alloc] init];
	mTimerView.center = CGPointMake (center.y+0.5, center.x+0.5);
	[accessoryView addSubview:mTimerView];
	
	// add the lives and points views
	mLivesView = [[RRSGlowLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.height - 88.0, 240.0, 105.0, 74.0)];
	mLivesView.textAlignment = NSTextAlignmentCenter;
	mLivesView.textColor = [UIColor whiteColor];
	mLivesView.backgroundColor = [UIColor clearColor];
	mLivesView.glowColor = [UIColor colorWithRed:0.8 green:1.0 blue:1.0 alpha:1.0];
    mLivesView.glowOffset = CGSizeMake(0.0, 0.0);
    mLivesView.glowAmount = 50.0;
	[accessoryView addSubview:mLivesView];

	mLivesZoomView = [[RRSGlowLabel alloc] initWithFrame:mLivesView.frame];
	mLivesZoomView.textAlignment = NSTextAlignmentCenter;
	mLivesZoomView.textColor = [UIColor whiteColor];
	mLivesZoomView.backgroundColor = [UIColor clearColor];
	mLivesZoomView.transform = CGAffineTransformIdentity;
	mLivesZoomView.alpha = 0.0;
	mLivesZoomView.glowColor = [UIColor colorWithRed:0.8 green:1.0 blue:1.0 alpha:1.0];
    mLivesZoomView.glowOffset = CGSizeMake(0.0, 0.0);
    mLivesZoomView.glowAmount = 50.0;
	[accessoryView addSubview:mLivesZoomView];
	
	mPointsView = [[RRSGlowLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.height - 88.0, -10.0, 105.0, 74.0)];
	mPointsView.text = @"0";
	mPointsView.adjustsFontSizeToFitWidth = YES;
	mPointsView.font = SCORE_FONT_SIZE_LG;
	mPointsView.textAlignment = NSTextAlignmentCenter;
	mPointsView.textColor = [UIColor whiteColor];
	mPointsView.backgroundColor = [UIColor clearColor];
	mPointsView.glowColor = [UIColor colorWithRed:0.8 green:1.0 blue:1.0 alpha:1.0];
    mPointsView.glowOffset = CGSizeMake(0.0, 0.0);
    mPointsView.glowAmount = 50.0;
	[accessoryView addSubview:mPointsView];
	
	mPointsZoomView = [[RRSGlowLabel alloc] initWithFrame:mPointsView.frame];
	mPointsZoomView.text = @"0";
	mPointsZoomView.font = SCORE_FONT_SIZE_LG;
	mPointsZoomView.textAlignment = NSTextAlignmentCenter;
	mPointsZoomView.textColor = [UIColor whiteColor];
	mPointsZoomView.backgroundColor = [UIColor clearColor];
	mPointsZoomView.transform = CGAffineTransformIdentity;
	mPointsZoomView.alpha = 0.0;
	mPointsZoomView.glowColor = [UIColor colorWithRed:0.8 green:1.0 blue:1.0 alpha:1.0];
    mPointsZoomView.glowOffset = CGSizeMake(0.0, 0.0);
    mPointsZoomView.glowAmount = 50.0;
	[accessoryView addSubview:mPointsZoomView];

	countdownTimer = [[CountdownTimer alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
	countdownTimer.center = CGPointMake(self.view.center.y, self.view.center.x);
	countdownTimer.backgroundColor = [UIColor clearColor];
	[accessoryView addSubview:countdownTimer];
	
	[[self view] retain];
			
	// for accelerometer
//	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
//	accel.delegate = self;
//	accel.updateInterval = 1.0f/10.0f;
	
	accelX = oldX = 0.0;
	accelY = oldY = 0.0;
	xCenter = yCenter = 0;
			
	tiltHit = YES;
	outOfPosition = NO;
}

- (void)setupModeAnnouncer {
    UIImage *gameModeImage;
    switch ([[AppDelegate game] gameLevel]) {
        case FGGameLevelEasy:
            gameModeImage = [UIImage imageNamed:@"easy.png"];
            break;
        case FGGameLevelMedium:
            gameModeImage = [UIImage imageNamed:@"medium.png"];
            break;
        case FGGameLevelHard:
            gameModeImage = [UIImage imageNamed:@"hard.png"];
            break;
        case FGGameLevelExtreme:
            gameModeImage = [UIImage imageNamed:@"extreme.png"];
            break;
        case FGGameLevelBlitz:
            gameModeImage = [UIImage imageNamed:@"blitz.png"];
            break;
        default:
            break;
    }
    modeImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    modeImageView.alpha = 1.0;
    modeImageView.image = gameModeImage;
    [UIView animateWithDuration:0.25
                          delay:0.6 options:nil
                     animations:^{
                         modeImageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
                         modeImageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
//                         [modeImageView removeFromSuperview];
                     }];
}

- (void)announceGoldenShape
{
	[AppDelegate playGoldShapeSound];
	UIImageView	*goldenShapeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goldenshape.png"]];
	
	CGPoint center = [self.view center];
	goldenShapeView.center = CGPointMake(center.y, center.x);
	goldenShapeView.alpha = 0.0;
	goldenShapeView.transform = CGAffineTransformMakeScale(1.5, 1.5);
	[[self view] addSubview:goldenShapeView];
	
	[UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 goldenShapeView.transform = CGAffineTransformIdentity;
						 goldenShapeView.alpha = 1.0;
					 }
					 completion:^(BOOL finished){
						 [UIView animateWithDuration:0.6
											   delay:0.3
											 options:UIViewAnimationOptionAllowUserInteraction
										  animations:^{
											  goldenShapeView.alpha = 0.0;
											  goldenShapeView.transform = CGAffineTransformMakeScale(0.5, 0.5);
										  }
										  completion:^(BOOL finished){
											  [goldenShapeView removeFromSuperview];
											  [goldenShapeView release];
										  }];	
					 }];	
}

- (void)showGameOverPopup
{
	if (blackness == nil) {
		blackness = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.height, self.view.frame.size.width)];
	}
	blackness.backgroundColor = [UIColor blackColor];
	blackness.alpha = 0.0;
	[self.view addSubview:blackness];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	blackness.alpha = 0.85;
	[UIView commitAnimations];
	
	if (gameOverPopup == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"GameOverPopup" owner:self options:nil];
		CGPoint center = [self.view center];
		gameOverPopup.scoreLabel.text = [NSString stringWithFormat:@"Your Score: %@", mPointsView.text];
		
		if ([[AppDelegate game] mState] == FGGameStateOver) {
			[gameOverPopup.btn1 setTitle:@"Menu" forState:UIControlStateNormal];
			[gameOverPopup.btn2 setTitle:@"Replay" forState:UIControlStateNormal];
			[gameOverPopup.btn3 setTitle:@"Submit Score" forState:UIControlStateNormal];
			gameOverPopup.popupFrame.image = [UIImage imageNamed:@"gameover-frame.png"];
			if (![AppDelegate connectedToGameCenter] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
				gameOverPopup.btn3.enabled = NO;
			} else {
				gameOverPopup.btn3.enabled = YES;
			}

		} else {
			[gameOverPopup.btn1 setTitle:@"End" forState:UIControlStateNormal];
			[gameOverPopup.btn2 setTitle:@"Break" forState:UIControlStateNormal];
			[gameOverPopup.btn3 setTitle:@"Resume" forState:UIControlStateNormal];
			gameOverPopup.popupFrame.image = [UIImage imageNamed:@"paused-frame.png"];
		}
		
		switch ([[AppDelegate game] gameLevel]) {
			case FGGameLevelEasy:
				gameOverPopup.modeLabel.text = @"Easy Mode";
				gameOverPopup.bannerView.image = [UIImage imageNamed:@"gameover-banner-easy.png"];
				break;
			case FGGameLevelMedium:
				gameOverPopup.modeLabel.text = @"Medium Mode";
				gameOverPopup.bannerView.image = [UIImage imageNamed:@"gameover-banner-medium.png"];
				break;
			case FGGameLevelHard:
				gameOverPopup.modeLabel.text = @"Hard Mode";
				gameOverPopup.bannerView.image = [UIImage imageNamed:@"gameover-banner-hard.png"];
				break;
			case FGGameLevelExtreme:
				gameOverPopup.modeLabel.text = @"Extreme Mode";
				gameOverPopup.bannerView.image = [UIImage imageNamed:@"gameover-banner-extreme.png"];
				break;
			case FGGameLevelBlitz:
				gameOverPopup.modeLabel.text = @"Blitz Mode";
				gameOverPopup.bannerView.image = [UIImage imageNamed:@"gameover-banner-blitz.png"];
				break;
		}

		gameOverPopup.center = CGPointMake(center.y, center.x);
		gameOverPopup.backgroundColor = [UIColor clearColor];
		gameOverPopup.transform = CGAffineTransformMakeScale(6.0, 6.0);
		[self.view addSubview:gameOverPopup];
	}
		
	gameOverPopup.alpha = 0.0;

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	gameOverPopup.alpha = 1.0;
	gameOverPopup.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)showPowerupIndicator
{
	if (powerupIndicator == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"PowerupIndicator" owner:self options:nil];
		powerupIndicator.frame = CGRectMake(0.0, 320.0, 145.0, 45.0);
		powerupIndicator.backgroundColor = [UIColor clearColor];
		
		UIImage *arrowImage;
		
		switch ([[AppDelegate game] powerupInUse]) {
			case FGPowerupDoubler:
				powerupIndicator.label.text = @"Doubler";
				arrowImage = [UIImage imageNamed:@"puDisplay-arrow-green.png"];
				break;
			case FGPowerupUniformity:
				powerupIndicator.label.text = @"Uniformity";
			case FGPowerupAutowin:
				powerupIndicator.label.text = @"Autowin";
				arrowImage = [UIImage imageNamed:@"puDisplay-arrow-purple.png"];
				break;
			case FGPowerupRadiation:
				powerupIndicator.label.text = @"Radiation";
				arrowImage = [UIImage imageNamed:@"puDisplay-arrow-red.png"];
				break;
			case FGPowerupSlowdown:
				if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz) {
					powerupIndicator.label.text = @"Freeze";
				} else {
					powerupIndicator.label.text = @"Slowdown";
				}
				arrowImage = [UIImage imageNamed:@"puDisplay-arrow-yellow.png"];
				break;
			case FGPowerupExtraLife:
				if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz) {
					powerupIndicator.label.text = @"Extra Time";
				} else {
					powerupIndicator.label.text = @"Extra Life";
				}
				arrowImage = [UIImage imageNamed:@"puDisplay-arrow-green.png"];
				break;
            case FGPowerupExtraTime:
            case FGPowerupFreeze:
            case FGPowerupNone:
                break;
		}
		
		powerupIndicator.arrow1.image = arrowImage;
		powerupIndicator.arrow2.image = arrowImage;
		powerupIndicator.arrow3.image = arrowImage;
		powerupIndicator.arrow4.image = arrowImage;
		
		[self.view addSubview:powerupIndicator];
	}

	[powerupIndicator animateArrows];
	
	[UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 powerupIndicator.frame = CGRectMake(0.0, 275.0, 145.0, 45.0);
					 }
					 completion:NULL];
}

- (void)hidePowerupIndicator
{
	[UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 powerupIndicator.frame = CGRectMake(0.0, 320.0, 145.0, 45.0);
					 }
					 completion:^(BOOL finished){
						 [powerupIndicator removeFromSuperview];
						 [powerupIndicator release], powerupIndicator = nil;
					 }];	
}

- (void)prepareForNewGame
{
	[countdownTimer performSelector:@selector(resetTimer) withObject:nil afterDelay:PAUSE_BEFORE_COUNTDOWN];
	countdownTimer.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -

- (void)zoomInCenterwithColor:(int)color andShape:(int)shape
{
	NSString	*filename;
	
    mCenterViewType = shape;
    
	// remove any leftovers
	[mCenterView removeFromSuperview];
	[mCenterView release];
	mCenterView = nil;
	
	// generate and place the new piece
	if ([AppDelegate colorBlindnessOn]) {
		if (color == 3) {
			filename = [NSString stringWithFormat:@"piece-%d-%d-1-cb.png", color, shape];
		} else {
			filename = [NSString stringWithFormat:@"piece-%d-%d-1.png", color, shape];
		}
	}
	else {
		filename = [NSString stringWithFormat:@"piece-%d-%d-1.png", color, shape];
	}
	
	mCenterView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]];
	CGPoint center = [[self view] center];
	mCenterView.center = CGPointMake(center.y, center.x);
	[accessoryView addSubview:mCenterView];
	
	// animate it in
	mCenterView.alpha = 0.0;
	mCenterView.transform = CGAffineTransformMakeScale (0.33, 0.33);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_NORMAL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(zoomInCenterwithColorStop)];
	mCenterView.alpha = 1.0;
	mCenterView.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)zoomInCenterwithColorStop {
	//tiltHit = NO;
	if ([[AppDelegate game] mGameBegin]) {
		[[AppDelegate game] setMBlocked:NO];
		[[AppDelegate game] setMGameBegin:NO];
		tiltHit = NO;
	}
}

- (void)zoomOutCenter
{
	// animate it out
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_NORMAL];
	mCenterView.alpha = 0.0;
	mCenterView.transform = CGAffineTransformMakeScale (3.0, 3.0);
	[UIView commitAnimations];
}

- (void)moveCenterToCircle:(int)circle
{
	[AppDelegate playMoveSound];
	
	// animate it there
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:(([[AppDelegate game] powerupInUse] == FGPowerupAutowin) ? 0.55 : ANIM_NORMAL)];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(moveCenterToCircleStop)];
	mCenterView.alpha = 1.0;
	mCenterView.transform = CGAffineTransformMakeScale (0.95, 0.95);
	mCenterView.center = [(FormicView *)[self view] centerForCircle:circle];
	[UIView commitAnimations];
	
	// transfer and schedule finishing up
	mMovedView = mCenterView;
	mCenterView = nil;
	[self performSelector:@selector(clearCircle:) withObject:[NSNumber numberWithInt:circle] afterDelay:(([[AppDelegate game] powerupInUse] == FGPowerupAutowin) ? 0.55 : ANIM_NORMAL)];
}

- (void)moveCenterToCircleStop {
}

- (void)clearCircle:(NSNumber *)number
{
	int	circle = [number intValue];
	
	// animate inner and outer piece out
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_NORMAL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(clearCircleStop)];
	mMovedView.alpha = 0.0;
	mMovedView.transform = CGAffineTransformMakeScale (0.33, 0.33);
	mCircleView[circle].alpha = 0.0;
	mCircleView[circle].transform = CGAffineTransformMakeScale (3.0, 3.0);
	[UIView commitAnimations];
	
	// and remove them
	[mMovedView removeFromSuperview];
	[mMovedView release];
	mMovedView = nil;
	[mCircleView[circle] removeFromSuperview];
	[mCircleView[circle] release];
	mCircleView[circle] = nil;
	
	// then move new piece in
	[[AppDelegate game] newPieceForCircle:[NSNumber numberWithInt:circle]];
}

- (void)clearCircleStop {
}

- (void)zoomInCircle:(int)circle withColor:(int)color andShape:(int)shape
{
	NSString	*filename;
	
    mCircleViewTypes[circle] = shape;

        // remove any leftovers
	[mCircleView[circle] removeFromSuperview];
	[mCircleView[circle] release];
	mCircleView[circle] = nil;
	
	// generate and place the new piece
	if ([AppDelegate colorBlindnessOn]) {
		if (color == 3) {
			filename = [NSString stringWithFormat:@"piece-%d-%d-0-cb.png", color, shape];
		} else {
			filename = [NSString stringWithFormat:@"piece-%d-%d-0.png", color, shape];
		}
	}
	else {
		filename = [NSString stringWithFormat:@"piece-%d-%d-0.png", color, shape];
	}
	   
	mCircleView[circle] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]];
	mCircleView[circle].center = [(FormicView *)[self view] centerForCircle:circle];
	mCircleView[circle].alpha = 0.0;
	mCircleView[circle].transform = CGAffineTransformMakeScale (3.0, 3.0);
	[accessoryView addSubview:mCircleView[circle]];
	
	// animate in
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_NORMAL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(zoomInCircleStop)];
	
	mMovedView.alpha = 0.0;
	mMovedView.transform = CGAffineTransformMakeScale (0.33, 0.33);
	mCircleView[circle].alpha = 1.0;
	mCircleView[circle].transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}
	 
- (void)zoomInCircleStop {
	if (![[AppDelegate game] mGameBegin]) {
		[[AppDelegate game] setMBlocked:NO];
		tiltHit = NO;
	}
}

- (void)updateTimer:(int)timervalue
{
	[mTimerView setPosition:timervalue];
}

- (void)updateLives:(int)lives
{
	if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz) {
		
		NSString *seconds;
		int m = 0;
		int s = lives;
		if (s > 59) {
			m = floor(s/60.0);
			s = s%60;
		}
		if (s < 10) {
			seconds = [NSString stringWithFormat:@"0%i", s];
		} else {
			seconds = [NSString stringWithFormat:@"%i", s];
		}
		
		mLivesView.text = [NSString stringWithFormat:@"%i:%@", m, seconds];
		mLivesZoomView.text = [NSString stringWithFormat:@"%i:%@", m, seconds];
	} else {
		mLivesView.text = [NSString stringWithFormat:@"%d", lives];
		mLivesZoomView.text = [NSString stringWithFormat:@"%d", lives];
	}
	
	mLivesZoomView.transform = CGAffineTransformIdentity;
	mLivesZoomView.alpha = 1.0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_SHORT];
	mLivesZoomView.transform = CGAffineTransformMakeScale (4.5, 4.5);
	mLivesZoomView.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)updateLivesWithoutZooming:(int)lives
{
	if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz) {
		NSString *seconds;
		int m = 0;
		int s = lives;
		if (s > 59) {
			m = floor(s/60.0);
			s = s%60;
		}
		if (s < 10) {
			seconds = [NSString stringWithFormat:@"0%i", s];
		} else {
			seconds = [NSString stringWithFormat:@"%i", s];
		}
		mLivesView.text = [NSString stringWithFormat:@"%i:%@", m, seconds];
	} else {
		mLivesView.text = [NSString stringWithFormat:@"%d", lives];
	}
}

- (void)updateScore:(int)points
{
	if (points > 999) {
		mPointsView.font = SCORE_FONT_SIZE_SM;
		mPointsZoomView.font = SCORE_FONT_SIZE_SM;
	} else {
		mPointsView.font = SCORE_FONT_SIZE_LG;
		mPointsZoomView.font = SCORE_FONT_SIZE_LG;
	}
	mPointsView.text = [NSString stringWithFormat:@"%d", points];
	mPointsZoomView.text = [NSString stringWithFormat:@"%d", points];
	
	mPointsZoomView.transform = CGAffineTransformIdentity;
	mPointsZoomView.alpha = 1.0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_SHORT];
	mPointsZoomView.transform = CGAffineTransformMakeScale (4.5, 4.5);
	mPointsZoomView.alpha = 0.0;
	[UIView commitAnimations];	
}

- (void)updateScoreWithoutZooming:(int)points
{
	if (points > 999) {
		mPointsView.font = SCORE_FONT_SIZE_SM;
	} else {
		mPointsView.font = SCORE_FONT_SIZE_LG;
	}
	mPointsView.text = [NSString stringWithFormat:@"%d", points];
}

- (void)startGame
{
	countdownTimer.hidden = YES;
	self.view.userInteractionEnabled = YES;
	[self performSelector:@selector(enablePauseButton) withObject:nil afterDelay:1.5];
}

- (void)enablePauseButton
{
	btnPause.enabled = YES;
}

- (void)gameOver
{	
	[self showGameOverPopup];
	[AppDelegate playGameOverMusic];
	if (consecutiveGames == kRequirementBackToBack) {
		[[AppDelegate game] submitBackToBackAchievement];
	}
	pulsingLivesCritical = NO;
	btnPause.enabled = NO;
	[[AppDelegate game] eraseSavedGame]; // erase any previous saved game
}

- (void)showPauseAlert
{	
	[self showGameOverPopup];
	for (unsigned i = 0; i < GAME_CIRCLES; i++)
		mCircleView[i].hidden = YES;
}

- (void)onGameOverPopupBtn1:(id)sender
{
	if ([[AppDelegate game] mState] == FGGameStateOver) {
		// Menu
		[self resetView];
		[[AppDelegate game] resetGame];
		[AppDelegate showMainMenuView];
	} else {
		// End
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[self resetView];
		[[AppDelegate game] eraseSavedGame]; // erase any previous saved game
		[[AppDelegate game] resetGame];
		[AppDelegate showMainMenuView];
	}
}

- (void)onGameOverPopupBtn2:(id)sender
{
	if ([[AppDelegate game] mState] == FGGameStateOver) {
		// Replay
		[[AppDelegate game] completelyResetPowerups];
		[self removeGameOverPopup];
		[self resetView];
		[self prepareForNewGame];
		[[AppDelegate game] resetGame];
		consecutiveGames++;
	} else {
		// Break
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[[AppDelegate game] saveGame];
		[self resetView];
		[[AppDelegate game] resetGame];
		[AppDelegate showMainMenuView];
	}
}

- (void)onGameOverPopupBtn3:(id)sender
{
	if ([[AppDelegate game] mState] == FGGameStateOver) {
		// Submit score
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
            [AppDelegate showLoadingViewWithLabel:@"Accessing Game Center"];
            [[AppDelegate game] performSelector:@selector(authenticateLocalUserAndSubmitScore) withObject:nil afterDelay:0.5];
        }
	} else {
		// Resume
		[self removeGameOverPopup];
		[[AppDelegate game] unpauseGame];
		for (unsigned i = 0; i < GAME_CIRCLES; i++)
			mCircleView[i].hidden = NO;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == replayAlert) { // replay alert
		switch (buttonIndex) {
			case 0: // menu
				[self resetView];
				[[AppDelegate game] resetGame];
				[AppDelegate showMainMenuView];
				break;
			case 1: // replay
				[[AppDelegate game] completelyResetPowerups];
				[self resetView];
				[self prepareForNewGame];
				[[AppDelegate game] resetGame];
				consecutiveGames++;
				break;
			case 2: // submit score
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
                    [AppDelegate showLoadingViewWithLabel:@"Accessing Game Center"];
                    [[AppDelegate game] performSelector:@selector(authenticateLocalUserAndSubmitScore) withObject:nil afterDelay:0.5];
                }
				break;
		}
	} else if (alertView == pauseAlert) { // pause alert
		switch (buttonIndex) {
			case 0: // resume
				[[AppDelegate game] unpauseGame];
				for (unsigned i = 0; i < GAME_CIRCLES; i++)
					mCircleView[i].hidden = NO;
				break;
			case 1: // break
				[NSObject cancelPreviousPerformRequestsWithTarget:self];
				[[AppDelegate game] saveGame];
				[self resetView];
				[[AppDelegate game] resetGame];
				[AppDelegate showMainMenuView];
				break;
			case 2: // end
				[NSObject cancelPreviousPerformRequestsWithTarget:self];
				[self resetView];
				[[AppDelegate game] eraseSavedGame]; // erase any previous saved game
				[[AppDelegate game] resetGame];
				[AppDelegate showMainMenuView];
				break;
		}
	}
}

- (void)resetView
{
	if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz) {
		mLivesView.text = @"1:00";
		mLivesZoomView.text = @"1:00";
	} else {
		mLivesView.text = @"5";
		mLivesZoomView.text = @"5";
	}
	mPointsView.text = @"0";
	mPointsView.font = SCORE_FONT_SIZE_LG;
	mPointsZoomView.text = @"0";
	mPointsZoomView.font = SCORE_FONT_SIZE_LG;
	livesCritical.alpha = 0;
		
	[mCenterView removeFromSuperview];
	[mCenterView release];
	mCenterView = nil;
	[mTimerView setPosition:0];
	
	for (int i = 0; i < GAME_CIRCLES; i ++) {
		[mCircleView[i] removeFromSuperview];
		[mCircleView[i] release];
		mCircleView[i] = nil;
	}
}

- (void)removeGameOverPopup
{
	[UIView animateWithDuration:0.25
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 blackness.alpha = 0.0;
						 gameOverPopup.alpha = 0.0;
					 }
					 completion:^(BOOL finished){
						 [gameOverPopup removeFromSuperview];
						 [gameOverPopup release], gameOverPopup = nil;
						 [blackness removeFromSuperview];
						 [blackness release], blackness = nil;
					 }];	
}	

- (IBAction)onButtonPause:(id)sender
{
	[[AppDelegate game] stopTimer];
	[[AppDelegate game] pauseGame];
}


- (void)playSlowdownSoundLoop
{
	soundLoop++;
	[AppDelegate playSlowdownSound];
	if (soundLoop < 3) [self performSelector:@selector(playSlowdownSoundLoop) withObject:nil afterDelay:3.86];
}

- (void)localNewPieceForCircle:(NSNumber *)circle
{
	[[AppDelegate game] newPieceForCircle:circle];
}

#pragma mark -
#pragma mark Acceleration

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if ([[AppDelegate game] mState] == FGGameStatePaused) return;
	
	if (xCenter==0 && yCenter == 0) {
		xCenter = acceleration.x;
		yCenter = acceleration.y;
	}
	
	accelX = (acceleration.x * kAccelFilt) + (oldX * (1.0 - kAccelFilt));
	accelY = (-acceleration.y * kAccelFilt) + (oldY * (1.0 - kAccelFilt));		
		
	if ([[AppDelegate game] mState] == FGGameStateRunning) {	
				
		if ([AppDelegate controlScheme] == FGControlSchemeTiltMode) {
			CGPoint accelPt = CGPointMake(accelY, accelX);
			CGPoint oldPt = CGPointMake(oldY, oldX);
			float distance = ccpDistance(accelPt, oldPt);
			
			
			CGPoint pt = CGPointMake((accelY+yCenter), -(accelX-xCenter));
			CGPoint pt2 = CGPointMake(oldY+yCenter, -(oldX-xCenter));
			
			float radians = ccpToAngle(ccpSub(pt, pt2));
			float degrees = CC_RADIANS_TO_DEGREES(radians);
			if (degrees<0) {
				degrees = 180 + (180+degrees);
			}
			
			// original 0.023 
			if (distance>0.05 && ![[AppDelegate game] mBlocked]) {	
				if (!tiltHit) {	
					if ((degrees>330 && degrees<361) || (degrees>-1 && degrees<30)) {
						tiltHit =[[AppDelegate game] moveCenterToCircle:4];
					}
					if (degrees>270 && degrees<330) {
						tiltHit =[[AppDelegate game] moveCenterToCircle:3];
					}
					if (degrees>210 && degrees<270) {
						tiltHit =[[AppDelegate game] moveCenterToCircle:2];
					}
					if (degrees>150 && degrees<210) {
						tiltHit =[[AppDelegate game] moveCenterToCircle:1];
					}
					if (degrees>90 && degrees<150) {
						tiltHit =[[AppDelegate game] moveCenterToCircle:0];
					}
					if (degrees>30 && degrees<90) {
						tiltHit =[[AppDelegate game] moveCenterToCircle:5];
					}
					if (!tiltHit && !outOfPosition) {
						// vibrate
						[AppDelegate doVibration];
						[AppDelegate playErrorSound];
						
						outOfPosition = YES;
						accelTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDone) userInfo:nil repeats:NO];
					}
				}				
			}						
		}	
	}
	oldX = accelX;
	oldY = accelY;   
}

- (void)timerDone {
	outOfPosition = NO;
}

#pragma mark -
#pragma mark Powerups

- (void)activatePowerupSlot1
{
	[self fadeInPowerupButton:btnPowerup1];
}

- (void)activatePowerupSlot2
{
	[self fadeInPowerupButton:btnPowerup2];
}

- (void)activatePowerupSlot3
{
	[self fadeInPowerupButton:btnPowerup3];
}

- (void)fadeInPowerupButton:(UIButton *)btn
{
	// "Fade in" the button
	UIImageView *fadeView = [[UIImageView alloc] initWithImage:[btn backgroundImageForState:UIControlStateNormal]];
	fadeView.frame = btn.frame;
	fadeView.alpha = 0.0;
	[accessoryView addSubview:fadeView];

	[UIView animateWithDuration:0.1
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 fadeView.alpha = 1.0;
					 }
					 completion:^(BOOL finished){
                         if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
                             btn.enabled = YES;
                         }
						 btn.showsTouchWhenHighlighted = YES;
						 [fadeView removeFromSuperview];
						 [fadeView release];
					 }];
}

- (void)pulsePowerupButton:(UIButton *)btn
{
	if (pulsingPowerUpButton) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		btn.alpha = (btn.alpha == 1.0) ? 0.5 : 1.0;
		[UIView commitAnimations];
		[self performSelector:@selector(pulsePowerupButton:) withObject:btn afterDelay:0.5];
	}	
}

- (void)endPowerup
{
	[self hidePowerupIndicator];
	pulsingPowerUpButton = NO;

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	bgPowerup.alpha = 0.0;
	btnPowerup1.alpha = 1.0;
	btnPowerup2.alpha = 1.0;
	btnPowerup3.alpha = 1.0;
	[UIView commitAnimations];
	
	for (unsigned i = 0; i < 3; i++) {
		if ([[[[AppDelegate game] powerupSlot] objectAtIndex:i] intValue] == FGPowerupSlotActive) {
			// Reactivate the touch highlight for slots that still contain an active powerup
			switch (i) {
				case 0:
					btnPowerup1.showsTouchWhenHighlighted = YES;
					break;
				case 1:
					btnPowerup2.showsTouchWhenHighlighted = YES;
					break;
				case 2:
					btnPowerup3.showsTouchWhenHighlighted = YES;
					break;
			}
		} else {
			// Disable the button that contained the used powerup
			switch (i) {
				case 0:
					btnPowerup1.enabled = NO;
					break;
				case 1:
					btnPowerup2.enabled = NO;
					break;
				case 2:
					btnPowerup3.enabled = NO;
					break;
			}
		}
	}
	
	//
	// Replace the used powerup with a new powerup
	//
	[[AppDelegate game] resetPowerupSlot:powerupInUseSlot];
}

- (void)loadPowerupSlot:(int)slot
{
	int p;
	switch (slot) {
		case 0:
			p = [[[[AppDelegate game] powerupInSlot] objectAtIndex:0] intValue];
			if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz && p == FGPowerupExtraLife) {
				p = FGPowerupExtraTime;
			}
			[btnPowerup1 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn.png", p]]
								   forState:UIControlStateDisabled];
			[btnPowerup1 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn-sel.png", p]]
								   forState:UIControlStateNormal];
			btnPowerup1.enabled = NO;
			break;
		case 1:
			p = [[[[AppDelegate game] powerupInSlot] objectAtIndex:1] intValue];
			if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz && p == FGPowerupExtraLife) {
				p = FGPowerupExtraTime;
			}
			[btnPowerup2 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn.png", p]]
								   forState:UIControlStateDisabled];
			[btnPowerup2 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn-sel.png", p]]
								   forState:UIControlStateNormal];
			btnPowerup2.enabled = NO;
			break;
		case 2:
			p = [[[[AppDelegate game] powerupInSlot] objectAtIndex:2] intValue];
			if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz && p == FGPowerupExtraLife) {
				p = FGPowerupExtraTime;
			}
			[btnPowerup3 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn.png", p]]
								   forState:UIControlStateDisabled];
			[btnPowerup3 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn-sel.png", p]]
								   forState:UIControlStateNormal];
			btnPowerup3.enabled = NO;
			break;
	}
}

- (void)restoreSavedPowerups:(NSArray *)pu
{
	[btnPowerup1 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn.png", [[pu objectAtIndex:0] intValue]]]
						   forState:UIControlStateDisabled];
	[btnPowerup1 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn-sel.png", [[pu objectAtIndex:0] intValue]]]
						   forState:UIControlStateNormal];
	[btnPowerup2 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn.png", [[pu objectAtIndex:1] intValue]]]
						   forState:UIControlStateDisabled];
	[btnPowerup2 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn-sel.png", [[pu objectAtIndex:1] intValue]]]
						   forState:UIControlStateNormal];
	[btnPowerup3 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn.png", [[pu objectAtIndex:2] intValue]]]
						   forState:UIControlStateDisabled];
	[btnPowerup3 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pu%i-btn-sel.png", [[pu objectAtIndex:2] intValue]]]
						   forState:UIControlStateNormal];
}

- (void)restoreSavedBackground:(UIImage *)img
{
	mainBackground.image = img;
}

- (IBAction)onButtonPowerUp:(id)sender
{
	UIButton *btn = (UIButton *)sender;

	// Only one powerup at a time
	if ([[AppDelegate game] powerupInUse] != FGPowerupNone) return;
	
	btn.showsTouchWhenHighlighted = NO;
	
	// Pulse the active powerup button
	pulsingPowerUpButton = YES;
	[self pulsePowerupButton:btn];
	
	// Define which powerup is in use
	if (btn == btnPowerup1) {
		powerupInUseSlot = 0;
		[[[AppDelegate game] powerupSlot] replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:FGPowerupSlotInUse]];
		[[AppDelegate game] setPowerupInUse:[[[[AppDelegate game] powerupInSlot] objectAtIndex:0] intValue]];
	} else if (btn == btnPowerup2) {
		powerupInUseSlot = 1;
		[[[AppDelegate game] powerupSlot] replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:FGPowerupSlotInUse]];
		[[AppDelegate game] setPowerupInUse:[[[[AppDelegate game] powerupInSlot] objectAtIndex:1] intValue]];
	} else if (btn == btnPowerup3) {
		powerupInUseSlot = 2;
		[[[AppDelegate game] powerupSlot] replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:FGPowerupSlotInUse]];
		[[AppDelegate game] setPowerupInUse:[[[[AppDelegate game] powerupInSlot] objectAtIndex:2] intValue]];
	}
	
	[[AppDelegate game] usedPowerup];

	//
	// Radiation
	//
	if ([[AppDelegate game] powerupInUse] == FGPowerupRadiation) {
		[[AppDelegate game] stopTimer];
		[[AppDelegate game] restartTimerAfterPause:1.25];
		bgPowerup.image = [UIImage imageNamed:@"radiation-1136.png"];
		for (int i = 0; i < GAME_CIRCLES; i++)
			[self performSelector:@selector(localNewPieceForCircle:) 
					   withObject:[NSNumber numberWithInteger:i] 
					   afterDelay:((float)i*0.15)];
		[self performSelector:@selector(endPowerup) withObject:nil afterDelay:1.25];
		[AppDelegate playRadiationSound];
	}

	//
	// Doubler
	//
	else if ([[AppDelegate game] powerupInUse] == FGPowerupDoubler) {
		bgPowerup.image = [UIImage imageNamed:@"doubler-1136.png"];
		[self performSelector:@selector(endPowerup) withObject:nil afterDelay:10.28];
		soundLoop = 0;
		[AppDelegate playDoublePointsSound];
	}
	
	//
	// Slowdown / Freeze
	//
	else if ([[AppDelegate game] powerupInUse] == FGPowerupSlowdown) {
		bgPowerup.image = [UIImage imageNamed:@"slowdown-1136.png"];
		if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz)  {
			[[AppDelegate game] freezeClock];
		} else {
			[[AppDelegate game] slowdownTimer];
		}
		[self performSelector:@selector(endPowerup) withObject:nil afterDelay:11.58];
		soundLoop = 0;
		[self playSlowdownSoundLoop];
	}
	
	//
	// Extra Life
	//
	else if ([[AppDelegate game] powerupInUse] == FGPowerupExtraLife) {
		[[AppDelegate game] stopTimer];
		[[AppDelegate game] restartTimerAfterPause:1.25];
		bgPowerup.image = [UIImage imageNamed:@"doubler-1136.png"];
		if ([[AppDelegate game] gameLevel] == FGGameLevelBlitz) {
			[[AppDelegate game] addExtraSeconds];
		} else {
			[[AppDelegate game] addExtraLife];
		}
		[self performSelector:@selector(endPowerup) withObject:nil afterDelay:1.25];
		[AppDelegate playExtraLifeSound];
	}
	
    //
    // Uniformity
    //
	else if ([[AppDelegate game] powerupInUse] == FGPowerupUniformity) {
		bgPowerup.image = [UIImage imageNamed:@"uniformity-1136.png"];
		for (int i = 0; i < GAME_CIRCLES; i++)
			[self performSelector:@selector(localNewPieceForCircle:)
					   withObject:[NSNumber numberWithInteger:i]
					   afterDelay:((float)i*0.15)];
		[[AppDelegate game] performSelector:@selector(replaceCenterShapeForUniformityPowerup) withObject:nil afterDelay:0.9];
		[self performSelector:@selector(endPowerup) withObject:nil afterDelay:10.0];
		[AppDelegate playUniformitySound];
	}
	
    //
    // Autowin
    //
	else if ([[AppDelegate game] powerupInUse] == FGPowerupAutowin) {
        self.view.userInteractionEnabled = NO;
		bgPowerup.image = [UIImage imageNamed:@"uniformity-1136.png"];
		for (int i = 0; i < GAME_CIRCLES; i++)
			[self performSelector:@selector(localNewPieceForCircle:)
					   withObject:[NSNumber numberWithInteger:i]
					   afterDelay:((float)i*0.15)];
		[[AppDelegate game] performSelector:@selector(replaceCenterShapeForUniformityPowerup) withObject:nil afterDelay:0.9];
		[AppDelegate playUniformitySound];
        
        autoWinCount = 0;
        [self performSelector:@selector(autoWin) withObject:nil afterDelay:1.0];
    }
	
	// "Disable" the other powerup buttons and perform other necessary animations
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	bgPowerup.alpha = 1.0;
	if (btn == btnPowerup1) {
		btnPowerup2.alpha = 0.5;
		btnPowerup3.alpha = 0.5;
	} else if (btn == btnPowerup2) {
		btnPowerup1.alpha = 0.5;
		btnPowerup3.alpha = 0.5;
	} else {
		btnPowerup1.alpha = 0.5;
		btnPowerup2.alpha = 0.5;
	}
	[UIView commitAnimations];
	
	btnPowerup1.showsTouchWhenHighlighted = NO;
	btnPowerup2.showsTouchWhenHighlighted = NO;
	btnPowerup3.showsTouchWhenHighlighted = NO;
	[self showPowerupIndicator];
}

- (void)autoWin {
    autoWinCount++;
    for (unsigned i = 0; i < GAME_CIRCLES; i++) {
        if (mCircleViewTypes[i] == mCenterViewType) {
            [[AppDelegate game] moveCenterToCircle:i];
            [[AppDelegate game] newCenterPiece];
        }
    }
    
    if (autoWinCount < 5) {
        [self performSelector:@selector(autoWin) withObject:nil afterDelay:1.0];
    } else {
        autoWinCount = 0;
        [self endPowerup];
        self.view.userInteractionEnabled = YES;
    }
}

#pragma mark -
#pragma mark Other

- (void)activateLivesCritical
{
	pulsingLivesCritical = YES;
	[self pulseLivesCritical];
}

- (void)deactivateLivesCritical
{
	pulsingLivesCritical = NO;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationDelegate:self];
	livesCritical.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)pulseLivesCritical
{
	[UIView animateWithDuration:1.0
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 livesCritical.alpha = (livesCritical.alpha == 1.0 || !pulsingLivesCritical) ? 0.0 : 1.0;
					 }
					 completion:^(BOOL finished){
						 if (pulsingLivesCritical) {
							 [self pulseLivesCritical];
						 }
					 }];
}

- (void)debugMessage:(NSString *)msg
{
	mPointsView.text = msg;
}

- (void)flashScoreCritical
{
	[UIView animateWithDuration:0.1
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 scoreCritical.alpha = 1.0;
					 }
					 completion:^(BOOL finished){
						 [UIView animateWithDuration:0.1
											   delay:0.5
											 options:UIViewAnimationOptionAllowUserInteraction
										  animations:^{
											  scoreCritical.alpha = 0.0;
										  }
										  completion:NULL];
					 }];
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	[mTimerView release];
	[mLivesView release];
	[mLivesZoomView release];
	[mPointsView release];
	[mPointsZoomView release];
	[countdownTimer release];
	
	if (gameOverPopup != nil) {
		[gameOverPopup release];
	}

    [super dealloc];
}

@end
