//
//  FormicGame.m
//  Shuzzle (1.0.0)
//
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//	Copyright 2010 Staticom Corporation (TM). All rights reserved.
//	Copyright 2010 Vonoran Coporation (TM). All rights reserved. 

#import "FormicGame.h"
#import "FormicViewController.h"
#import "FormicAppDelegate.h"
#import "AchievementAlertView.h"

@interface FormicGame (Private)

- (void)startTimer;
- (float)timerInterval;
- (void)timerAdvanced:(NSTimer *)aTimer;
- (void)blitzTimerAdvanced:(NSTimer *)aTimer;
- (void)zoomInCircle:(NSNumber *)number;
- (void)newCenterPiece;

@end

@implementation FormicGame (Private)

- (void)startTimer
{
	if (self.gameLevel == FGGameLevelBlitz) {
		timer = [NSTimer scheduledTimerWithTimeInterval:[self timerInterval] 
												 target:self selector:@selector(timerAdvanced:) userInfo:nil repeats:YES];
	} else {
		timer = [NSTimer scheduledTimerWithTimeInterval:[self timerInterval]*((powerupInUse == FGPowerupSlowdown) ? GAME_SLOWDOWN : 1) 
												 target:self selector:@selector(timerAdvanced:) userInfo:nil repeats:YES];
	}
}

- (void)startBlitzTimer
{
	[NSTimer scheduledTimerWithTimeInterval:1.0
									 target:self 
								   selector:@selector(blitzTimerAdvanced:)
								   userInfo:nil 
									repeats:NO];
}

- (float)timerInterval
{
	float temp = 20.0;
	switch (m_nLevel) {
		case 0:
			temp = 20.0;
			break;
		case 1:
			temp = 15.0;
			break;
		case 2:
		case 4:
			temp = 10.0;
			break;
		case 3:
			temp = 6.5;
			break;
	}
	
	// gets faster the more pieces have been moved
	if (self.gameLevel == FGGameLevelBlitz)
		return temp/100.0;
	else
		return (temp/(((float)mPoints/3)+100.0));
}

- (void)timerAdvanced:(NSTimer *)aTimer
{
	// don't advance when blocked
	if (mBlocked) return;
	
	// new piece, new timing
	if (mTime == 0) {
		[timer invalidate];
		timer = nil;
		[self startTimer];
	}
	
	// advance timer
	[mController updateTimer:mTime];
	mTime++;
	if (mTime >= GAME_TIMERSTEPS) {
		[self loseLife];	
	}
}

- (void)blitzTimerAdvanced:(NSTimer *)aTimer
{
	if (!timerIsFrozen) {
		blitzSeconds--;
		if (blitzSeconds == 0) {
			[mController updateLives:0];
			[timer invalidate];
			timer = nil;
			mState = FGGameStateOver;
			[mController gameOver];
#ifdef DEMO_MODE
#else
			[self checkForGameOverAchievements];
#endif
		} else {
			if (blitzSeconds == 10) {
				[mController activateLivesCritical];
			}
			[mController updateLivesWithoutZooming:blitzSeconds];
			[NSTimer scheduledTimerWithTimeInterval:1.0
											 target:self 
										   selector:@selector(blitzTimerAdvanced:)
										   userInfo:nil 
											repeats:NO];	
		}
	}
}

- (void)zoomInCircle:(NSNumber *)number
{
	int	circle = [number intValue];
	[mController zoomInCircle:circle withColor:mCircle[circle][GAME_COLOR] andShape:mCircle[circle][GAME_SHAPE]];
}

- (void)newCenterPiece
{
	// fade existing one out
	[mController zoomOutCenter];
	
	if (powerupInUse == FGPowerupUniformity) {
		mCenter[GAME_COLOR] = BLUE_COLOR;
		mCenter[GAME_SHAPE] = mCircle[rand()%GAME_CIRCLES][GAME_SHAPE];
	} else {
		int golden = arc4random()%GOLDEN_CENTER_PROBABILITY;
		if (golden == 0 && displayedGoldenCircle && !displayedGoldenCenter && !usedGoldenCircle) {
			displayedGoldenCenter = YES;
			mCenter[GAME_COLOR] = GOLDEN_COLOR;
			mCenter[GAME_SHAPE] = goldenShape;
		} else {
			mCenter[GAME_COLOR] = rand()%GAME_MAXCOLORS;
			mCenter[GAME_SHAPE] = mCircle[rand()%GAME_CIRCLES][GAME_SHAPE];
		}
	}
	
	
	// display it
	[mController zoomInCenterwithColor:mCenter[GAME_COLOR] andShape:mCenter[GAME_SHAPE]];
	
	// reset the timer
	mTime = 0;
	[mController updateTimer:mTime];
}

@end

@implementation FormicGame

@synthesize mState, mBlocked, mGameBegin, powerupInUse, localPlayer, playingNthGame, powerupSlot, powerupInSlot, inBlitzMode;
@synthesize gameLevel;

- (id)initWithViewController:(FormicViewController *)controller
{
	// initialize super
	self = [super init];
	if (!self)
		return nil;
	
	// general initializations
	mController = [controller retain];
	mLives = 5;
	mTime = 0;
	mPoints = 0;
	mConsecutive = 0;
	mState = FGGameStateInit;
	mBlocked = YES;
	
	// Blitz
	timerIsFrozen = NO;
	blitzSeconds = GAME_BLITZ_SECONDS;

	// Powerups
	powerupSlot = nil;
	powerupInSlot = nil;
	[self completelyResetPowerups];
	
	// Golden Shape
	displayedGoldenCircle = NO;
	displayedGoldenCenter = NO;
	usedGoldenCircle = NO;
	
	// Achievement tracking variables
	mPointsWithOneLife = 0;
	mConsecutiveDouble = 0;
	playingNthGame = FALSE;
	consecutiveCombosAchieved = FALSE;
	doubleCombosAchieved = FALSE;
	
	mCenter[GAME_COLOR] = mCenter[GAME_SHAPE] = 0;
	for (int i = 0; i < GAME_CIRCLES; i++)
		mCircle[i][GAME_COLOR] = mCircle[i][GAME_SHAPE] = 0;
	
	return self;
}

- (void)dealloc
{
	// Clean up
	[mController release];
	[powerupSlot release];
	[powerupInSlot release];
	[super dealloc];
}

- (void)startGame
{
	// Don't start over
	if (mState == FGGameStateRunning) return;
	
	mState = FGGameStateRunning;

	mBlocked = YES;
	mGameBegin = YES;
	
	// Tell the controller about it
	[mController startGame];
	
	// Fill the outer circles
	for (int i = 0; i < GAME_CIRCLES; i++)
		[self performSelector:@selector(newPieceForCircle:) withObject:[NSNumber numberWithInteger:i] afterDelay:((float)i*0.2)];
	
	// Fill the inner circle
	[self performSelector:@selector(newCenterPiece) withObject:nil afterDelay:1.4];
	
	// Let the game begin
	[self performSelector:@selector(startTimer) withObject:nil afterDelay:1.6];
	if (self.gameLevel == FGGameLevelBlitz) {
		[self performSelector:@selector(startBlitzTimer) withObject:nil afterDelay:1.6];
		[mController updateLives:GAME_BLITZ_SECONDS];
	} else {
		[mController updateLives:mLives];
	}
}

- (BOOL)moveCenterToCircle:(int)circle
{
	// no placement when blocked or game over
	if (mBlocked || (mState == FGGameStateOver))
		return NO;
	
	if (mCenter[GAME_SHAPE] == mCircle[circle][GAME_SHAPE]) {
		// see if they have the same color
		if (mCenter[GAME_COLOR] == mCircle[circle][GAME_COLOR]) {
			if (mCenter[GAME_COLOR] == GOLDEN_COLOR) {
				mPoints += (powerupInUse == FGPowerupDoubler) ? 200 : 100;
				if (mLives == 1) mPointsWithOneLife += (powerupInUse == FGPowerupDoubler) ? 200 : 100;
				NSLog(@"usedGoldenCircle");
				usedGoldenCircle = YES;
				[mController announceGoldenShape];
			} else {
				mPoints += (self.gameLevel == FGGameLevelBlitz ? BLITZ_COLOR_MATCH : SCORE_COLOR_MATCH) *
					((powerupInUse == FGPowerupDoubler) ? 2 : 1);
				if (mLives == 1) mPointsWithOneLife += SCORE_COLOR_MATCH * ((powerupInUse == FGPowerupDoubler) ? 2 : 1);
			}
			
			if (powerupInUse != FGPowerupUniformity) {

				// Consecutive match (this number could be one, in which case this is the first match)
				mConsecutive++;

			}
			
			if (powerupInUse == FGPowerupDoubler) {
				
				// Consecutive Doubler match
				mConsecutiveDouble++;
#ifdef DEMO_MODE
#else
				NSLog(@"%i == %i", mConsecutiveDouble, kRequirementDoubleCombos);
				if (mConsecutiveDouble == kRequirementDoubleCombos && [AppDelegate connectedToGameCenter]) {
					/* LOGIC FOR DOUBLE COMBOS ACHIEVEMENT */
					NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
					if ([earnedAchievements objectForKey:kAchievementDoubleCombos] == nil) {
						// Submit this achievement
						[[AppDelegate gameCenterManager] submitAchievement:kAchievementDoubleCombos percentComplete:100.0];
					}
					/* LOGIC FOR DOUBLE COMBOS ACHIEVEMENT */
				}
#endif
			}
#ifdef DEMO_MODE
#else
			if (mConsecutive == kRequirementConsecutiveCombos && [AppDelegate connectedToGameCenter]) {
				/* LOGIC FOR CONSECUTIVE COMBOS ACHIEVEMENT */
				NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
				if ([earnedAchievements objectForKey:kAchievementConsecutiveCombos] == nil) {
					// Submit this achievement
					[[AppDelegate gameCenterManager] submitAchievement:kAchievementConsecutiveCombos percentComplete:100.0];
				}
				/* LOGIC FOR CONSECUTIVE COMBOS ACHIEVEMENT */
			}
#endif
			if (mConsecutive > GAME_MATCHES) {
				// activate powerup and reset consecutive count
				[self activateRandomPowerupSlot];
				mConsecutive = 0;
			}
			[mController updateScore:mPoints];
		} else {
			if (mCircle[circle][GAME_COLOR] == GOLDEN_COLOR) {
				NSLog(@"usedGoldenCircle");
				usedGoldenCircle = YES;
			}
			
			mPoints += (self.gameLevel == FGGameLevelBlitz ? BLITZ_SHAPE_MATCH : SCORE_SHAPE_MATCH) *
				((powerupInUse == FGPowerupDoubler) ? 2 : 1);
			if (mLives == 1) mPointsWithOneLife += SCORE_SHAPE_MATCH * ((powerupInUse == FGPowerupDoubler) ? 2 : 1);
			[mController updateScoreWithoutZooming:mPoints];
			mConsecutive = 0;
			mConsecutiveDouble = 0;
		}
		
		
#ifdef DEMO_MODE
#else
		if ([AppDelegate connectedToGameCenter]) {
			/* LOGIC FOR TILT EXPERT ACHIEVEMENT */
			if (m_nLevel == 3 && mPoints > kRequirementTiltExpert-1 && [AppDelegate controlScheme] == FGControlSchemeTiltMode) {
				NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
				if ([earnedAchievements objectForKey:kAchievementTiltExpert] == nil) {
					// Submit this achievement
					[[AppDelegate gameCenterManager] submitAchievement:kAchievementTiltExpert percentComplete:100.0];
				}
			}
			/* LOGIC FOR TILT EXPERT ACHIEVEMENT */
			
			/* LOGIC FOR ONE LIFE ACHIEVEMENT */
			if (mPointsWithOneLife > kRequirementOneLife-1) {
				NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
				if ([earnedAchievements objectForKey:kAchievementOneLife] == nil) {
					// Submit this achievement
					[[AppDelegate gameCenterManager] submitAchievement:kAchievementOneLife percentComplete:100.0];
				}
			}
			/* LOGIC FOR ONE LIFE ACHIEVEMENT */
			
			/* LOGIC FOR LOW PTS ACHIEVEMENT */
			if (mPoints > kRequirementLowPts - 1) {
				NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
				if ([earnedAchievements objectForKey:kAchievementLowPts] == nil) {
					// Submit this achievement
					[[AppDelegate gameCenterManager] submitAchievement:kAchievementLowPts percentComplete:100.0];
				}
			}
			/* LOGIC FOR LOW PTS ACHIEVEMENT */
			
			/* LOGIC FOR MED PTS ACHIEVEMENT */
			if (mPoints > kRequirementMedPts - 1) {
				NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
				if ([earnedAchievements objectForKey:kAchievementMedPts] == nil) {
					// Submit this achievement
					[[AppDelegate gameCenterManager] submitAchievement:kAchievementMedPts percentComplete:100.0];
				}
			}
			/* LOGIC FOR MED PTS ACHIEVEMENT */
			
			/* LOGIC FOR HIGH PTS ACHIEVEMENT */
			if (mPoints > kRequirementHighPts - 1) {
				NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
				if ([earnedAchievements objectForKey:kAchievementHighPts] == nil) {
					// Submit this achievement
					[[AppDelegate gameCenterManager] submitAchievement:kAchievementHighPts percentComplete:100.0];
				}
			}
			/* LOGIC FOR HIGH PTS ACHIEVEMENT */
		}
#endif		
		
		mBlocked = YES;
		// temporary block so that the user can not rapidly place two shapes -- which causes a visual glitch
		[self performSelector:@selector(unblockGame) withObject:nil afterDelay:BLOCK_DELAY];
		
		// start moving and create new center
		[mController moveCenterToCircle:circle];
		mCenter[GAME_COLOR] = mCenter[GAME_SHAPE] = 0;
		[self newCenterPiece];
		
		// yes we can!
		return YES;
	}
	else {
		// cannot be placed		
		return NO;
	}
}

- (void)unblockGame
{
	mBlocked = NO;
}

- (void)newPieceForCircle:(NSNumber *)circle
{
	int		num = [circle intValue];
	BOOL	centerFound = NO;
	
	// find new piece, and assure center piece can be set
	for (int i = 0; i < GAME_CIRCLES; i++)
		if ((mCenter[GAME_SHAPE] == mCircle[i][GAME_SHAPE]) && (i != num))
			centerFound = YES;

	// Shape
	if (centerFound)
		mCircle[num][GAME_SHAPE] = rand()%GAME_MAXSHAPES;
	else
		mCircle[num][GAME_SHAPE] = mCenter[GAME_SHAPE];

	// Color
	if (powerupInUse == FGPowerupUniformity) {
		mCircle[num][GAME_COLOR] = BLUE_COLOR;
	} else {
		int golden = arc4random()%GOLDEN_CIRCLE_PROBABILITY;
		if (golden == 0 && !displayedGoldenCircle && mPoints > GOLDEN_POINTS) {
			displayedGoldenCircle = YES;
			mCircle[num][GAME_COLOR] = GOLDEN_COLOR;
			goldenShape = mCircle[num][GAME_SHAPE];
		} else {
			mCircle[num][GAME_COLOR] = rand () % GAME_MAXCOLORS;
		}
	}
	
	// Display new circle	
	[mController zoomInCircle:num withColor:mCircle[num][GAME_COLOR] andShape:mCircle[num][GAME_SHAPE]];
}

- (void)saveGame
{
	NSUserDefaults *prefs = nil;
	
	prefs = [NSUserDefaults standardUserDefaults];
	if (mState == FGGameStateRunning || mState == FGGameStatePaused)
	{	
		// save the data representing the game to the preferences
		[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"saved"];
		[prefs setObject:[NSNumber numberWithInt:[AppDelegate controlScheme]] forKey:@"mode"];
		[prefs setObject:[NSData dataWithBytes:mCircle length:sizeof(mCircle)] forKey:@"circle"];
		[prefs setObject:[NSData dataWithBytes:mCenter length:sizeof(mCenter)] forKey:@"center"];
		[prefs setObject:[NSNumber numberWithInt:mLives] forKey:@"lives"];
		[prefs setObject:[NSNumber numberWithInt:mPoints] forKey:@"points"];

		[prefs setObject:[NSNumber numberWithInt:mPointsWithOneLife] forKey:@"pointswithonelife"];
		[prefs setObject:[NSNumber numberWithInt:powerupUse[FGPowerupRadiation]] forKey:@"radiationpowerupuse"];
		[prefs setObject:[NSNumber numberWithInt:powerupUse[FGPowerupDoubler]] forKey:@"doublerpowerupuse"];
		[prefs setObject:[NSNumber numberWithInt:powerupUse[FGPowerupSlowdown]] forKey:@"slowdownpowerupuse"];
		[prefs setObject:[NSNumber numberWithInt:powerupUse[FGPowerupUniformity]] forKey:@"uniformitypowerupuse"];
		[prefs setObject:[NSNumber numberWithInt:powerupUse[FGPowerupExtraLife]] forKey:@"extralifepowerupuse"];

		[prefs setObject:[NSNumber numberWithInt:m_nLevel] forKey:@"level"];
		[prefs setObject:powerupSlot forKey:@"powerupslot"];
		[prefs setObject:powerupInSlot forKey:@"powerupinslot"];
		
		// Golden Shape
		[prefs setObject:[NSNumber numberWithBool:displayedGoldenCircle] forKey:@"displayedgoldencircle"];
		[prefs setObject:[NSNumber numberWithBool:displayedGoldenCenter] forKey:@"displayedgoldencenter"];
		[prefs setObject:[NSNumber numberWithBool:usedGoldenCircle] forKey:@"usedgoldencircle"];
		[prefs setObject:[NSNumber numberWithInt:goldenShape] forKey:@"goldenshape"];
		
		// Blitz
		[prefs setObject:[NSNumber numberWithInt:blitzSeconds] forKey:@"blitzseconds"];
				
		NSLog(@"powerupSlot %@", powerupSlot);
		NSLog(@"powerupInSlot %@", powerupInSlot);
	}
	else
		// save the 'no game data' indication to the preferences
		[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"saved"];
}

- (void)eraseSavedGame
{
	NSUserDefaults	*prefs = nil;	
	prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"saved"];
}

- (void)restoreGame
{
	NSUserDefaults	*prefs = nil;
	
	prefs = [NSUserDefaults standardUserDefaults];

	// get the data from the preferences
	[[prefs dataForKey:@"center"] getBytes:mCenter length:sizeof(mCenter)];
	[[prefs dataForKey:@"circle"] getBytes:mCircle length:sizeof(mCircle)];
	
	if (powerupSlot != nil)
		[powerupSlot release];
	if (powerupInSlot != nil)
		[powerupInSlot release];
	powerupSlot = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:@"powerupslot"]];
	powerupInSlot = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:@"powerupinslot"]];
	
	[mController restoreSavedPowerups:powerupInSlot];
	
	NSLog(@"powerupSlot %@", powerupSlot);
	NSLog(@"powerupInSlot %@", powerupInSlot);

	mTime = 0;
	mLives = [prefs integerForKey:@"lives"];
	mPoints = [prefs integerForKey:@"points"];

	mPointsWithOneLife = [prefs integerForKey:@"pointswithonelife"];
	
	powerupUse[FGPowerupRadiation] = [prefs integerForKey:@"radiationpowerupuse"];
	powerupUse[FGPowerupDoubler] = [prefs integerForKey:@"doublerpowerupuse"];
	powerupUse[FGPowerupSlowdown] = [prefs integerForKey:@"slowdownpowerupuse"];
	powerupUse[FGPowerupUniformity] = [prefs integerForKey:@"uniformitypowerupuse"];
	powerupUse[FGPowerupExtraLife] = [prefs integerForKey:@"extralifepowerupuse"];
	
	// Golden Shape
	displayedGoldenCircle = [prefs boolForKey:@"displayedgoldencircle"];
	displayedGoldenCenter = [prefs boolForKey:@"displayedgoldencenter"];
	usedGoldenCircle = [prefs boolForKey:@"usedgoldencircle"];
	goldenShape = [prefs integerForKey:@"goldenshape"];	

	// Blitz
	blitzSeconds = [prefs integerForKey:@"blitzseconds"];	

	mState = FGGameStateRunning;
	m_nLevel = [[prefs objectForKey:@"level"] intValue];
	
	switch (m_nLevel) {
		case 0:
			self.gameLevel = FGGameLevelEasy;
			break;
		case 1:
			self.gameLevel = FGGameLevelMedium;
			break;
		case 2:
			self.gameLevel = FGGameLevelHard;
			break;
		case 3:
			self.gameLevel = FGGameLevelExtreme;
			break;
		case 4:
			self.gameLevel = FGGameLevelBlitz;
			break;
	}
	
	if (mLives < 3 && self.gameLevel != FGGameLevelBlitz) {
		[mController activateLivesCritical];
	}
	
	// fill the outer circles
	for (int i = 0; i < GAME_CIRCLES; i++)
		[self performSelector:@selector(zoomInCircle:) withObject:[NSNumber numberWithInteger:i] afterDelay:1.5+((float)i*0.2)];
		
	// new inner circle
	[self performSelector:@selector(newCenterPiece) withObject:nil afterDelay:2.9];
	
	// let the game begin
	[self performSelector:@selector(startTimer) withObject:nil afterDelay:3.1];
	[self performSelector:@selector(startRestoredGame) withObject:nil afterDelay:3.1];
	
	if (self.gameLevel == FGGameLevelBlitz) {
		[self performSelector:@selector(startBlitzTimer) withObject:nil afterDelay:3.1];
		[mController restoreSavedBackground:[UIImage imageNamed:@"blitz.png"]];
		[mController updateLivesWithoutZooming:blitzSeconds];
	} else {
		[mController restoreSavedBackground:[UIImage imageNamed:@"main.png"]];
		[mController updateLivesWithoutZooming:mLives];
	}
	[mController updateScoreWithoutZooming:mPoints];
}

- (void)startRestoredGame
{
	[mController startGame];
	if ([[powerupSlot objectAtIndex:0] intValue] == FGPowerupSlotActive) [mController activatePowerupSlot1];
	if ([[powerupSlot objectAtIndex:1] intValue] == FGPowerupSlotActive) [mController activatePowerupSlot2];
	if ([[powerupSlot objectAtIndex:2] intValue] == FGPowerupSlotActive) [mController activatePowerupSlot3];
}

- (void)setLevel:(int)level {
	m_nLevel = level;
	switch (m_nLevel) {
		case 0:
			self.gameLevel = FGGameLevelEasy;
			break;
		case 1:
			self.gameLevel = FGGameLevelMedium;
			break;
		case 2:
			self.gameLevel = FGGameLevelHard;
			break;
		case 3:
			self.gameLevel = FGGameLevelExtreme;
			break;
		case 4:
			self.gameLevel = FGGameLevelBlitz;
			break;
	}
}

- (void)resetGame
{
	// General
	mLives = 5;
	mTime = 0;
	mPoints = 0;
	mState = FGGameStateInit;
	mBlocked = NO;

	// Blitz
	timerIsFrozen = NO;
	blitzSeconds = GAME_BLITZ_SECONDS;
	
	// Achievement tracking variables
	mPointsWithOneLife = 0;
	mConsecutive = 0;
	mConsecutiveDouble = 0;
	playingNthGame = FALSE;
	consecutiveCombosAchieved = FALSE;
	doubleCombosAchieved = FALSE;
	
	// Powerups
	[self completelyResetPowerups];
	
	// Golden
	displayedGoldenCircle = NO;
	displayedGoldenCenter = NO;
	usedGoldenCircle = NO;

	mCenter[GAME_COLOR] = mCenter[GAME_SHAPE] = 0;
	for (int i = 0; i < GAME_CIRCLES; i++) {
		mCircle[i][GAME_COLOR] = mCircle[i][GAME_SHAPE] = 0;
	}	
}

- (void)loseLife
{
	if (mTime < GAME_TIMERSTEPS) {
		[timer invalidate];
		timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerAdvanced:) userInfo:nil repeats:YES];
		return;
	}
	
	// lost a life
	if (self.gameLevel != FGGameLevelBlitz) {
		mLives--;
		if (mLives == 2) {
			[mController activateLivesCritical];
		}
		[mController updateLives:mLives];
		if (mLives <= 0)
		{
			// game over
			mState = FGGameStateOver;
			[timer invalidate];
			timer = nil;
			[mController gameOver];
#ifdef DEMO_MODE
#else
			[self checkForGameOverAchievements];
#endif
		}
		else
		{
			// next piece
			[self newCenterPiece];
			mTime = 0;
		}
	} else {
		
		if (mPoints > 9) {
			mPoints -= GAME_BLITZ_PENALTY;
		} else {
			mPoints = 0;
		}
		[mController flashScoreCritical];
		[mController updateScore:mPoints];
		
		// next piece
		[self newCenterPiece];
		mTime = 0;
	}
}

- (void)pauseGame
{
	[mController showPauseAlert];
	mState = FGGameStatePaused;
	timerIsFrozen = YES;
}

- (void)unpauseGame
{
	[self startTimer];
	mState = FGGameStateRunning;
	timerIsFrozen = NO;
	if (self.gameLevel == FGGameLevelBlitz)
		[self startBlitzTimer];
}

- (void)showMainMenu
{
	[AppDelegate showMainMenuView];
}

- (void)restartTimerAfterPause:(double)pause
{
	[timer invalidate];
	timer = nil;
	mTime = 0;
	[mController updateTimer:mTime];
	[self performSelector:@selector(startTimer) withObject:nil afterDelay:pause];
}

- (void)slowdownTimer
{
	[timer invalidate];
	timer = [NSTimer scheduledTimerWithTimeInterval:([self timerInterval]*GAME_SLOWDOWN)
											 target:self 
										   selector:@selector(timerAdvanced:)
										   userInfo:nil 
											repeats:YES];
}

- (void)freezeClock
{
	timerIsFrozen = YES;
	[self performSelector:@selector(unfreezeClock) withObject:nil afterDelay:11.58];
}

- (void)unfreezeClock
{
	timerIsFrozen = NO;
	[self startBlitzTimer];
}

- (void)stopTimer
{
	if (timer != nil && [timer isKindOfClass:[NSTimer class]] && [timer isValid]) {
		[timer invalidate];
		timer = nil;
	}
}

#pragma mark -
#pragma mark Powerups

- (void)activateRandomPowerupSlot
{
	if (
		([[powerupSlot objectAtIndex:0] intValue] == FGPowerupSlotActive || [[powerupSlot objectAtIndex:0] intValue] == FGPowerupSlotInUse) &&
		([[powerupSlot objectAtIndex:1] intValue] == FGPowerupSlotActive || [[powerupSlot objectAtIndex:1] intValue] == FGPowerupSlotInUse) &&
		([[powerupSlot objectAtIndex:2] intValue] == FGPowerupSlotActive || [[powerupSlot objectAtIndex:2] intValue] == FGPowerupSlotInUse)
		) {
		return; // All slots are already active
	}
	
	BOOL newPowerupSlotActivated = FALSE;
	while (!newPowerupSlotActivated) {
		int randomPowerupSlot = rand() % GAME_POWERUP_SLOTS;
		// check to make sure the random powerup isn't already active
		if (
			[[powerupSlot objectAtIndex:randomPowerupSlot] intValue] != FGPowerupSlotActive && 
			[[powerupSlot objectAtIndex:randomPowerupSlot] intValue] != FGPowerupSlotInUse
			) {
			[powerupSlot replaceObjectAtIndex:randomPowerupSlot withObject:[NSNumber numberWithInt:FGPowerupSlotActive]];
			newPowerupSlotActivated = TRUE;
			switch (randomPowerupSlot) {
				case 0:
					[mController activatePowerupSlot1];
					break;
				case 1:
					[mController activatePowerupSlot2];
					break;
				case 2:
					[mController activatePowerupSlot3];
					break;
			}
		}
	}
}

- (void)resetPowerupSlot:(int)slot
{
	mConsecutiveDouble = 0;
	if (powerupInUse == FGPowerupSlowdown) {
		powerupInUse = FGPowerupNone;
		[timer invalidate];
		timer = nil;
		[self startTimer];
	} else {
		powerupInUse = FGPowerupNone;
	}
	
	[powerupSlot replaceObjectAtIndex:slot withObject:[NSNumber numberWithInt:FGPowerupSlotInactive]];
	[self loadPowerupInSlot:slot];
}

- (void)completelyResetPowerups
{
	// First, initialize everything
	if (powerupSlot == nil && powerupInSlot == nil) {
		powerupSlot = [[NSMutableArray alloc] init];
		powerupInSlot = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < GAME_POWERUP_SLOTS; i++) {
			[powerupSlot addObject:[NSNumber numberWithInt:FGPowerupSlotInactive]];
			[powerupInSlot addObject:[NSNumber numberWithInt:FGPowerupNone]];
		}
	} else {
		for (unsigned i = 0; i < GAME_POWERUP_SLOTS; i++) {
			[powerupSlot replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:FGPowerupSlotInactive]];
			[powerupInSlot replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:FGPowerupNone]];
		}
	}
	
	powerupInUse = FGPowerupNone;
	noPowerupsUsed = TRUE;	
	for (unsigned i = 0; i < GAME_POWERUPS; i++) {
		powerupUse[i] = FGPowerupUnused;
	}
	
	// Then, set everything
	for (unsigned i = 0; i < GAME_POWERUP_SLOTS; i++) {
		[self loadPowerupInSlot:i];
	}
}

- (void)loadPowerupInSlot:(int)slot
{
	int newPowerup = arc4random() % GAME_POWERUPS;
	while (newPowerup == [[powerupInSlot objectAtIndex:((slot+1 > 2) ? 0 : slot+1)] intValue] ||
		   newPowerup == [[powerupInSlot objectAtIndex:((slot-1 < 0) ? 2 : slot-1)] intValue]) {
		newPowerup = arc4random() % GAME_POWERUPS;
		// Randomize one more time to decrease chance of receiving extra life powerup
		if (newPowerup == FGPowerupExtraLife) {
			newPowerup = arc4random() % GAME_POWERUPS;
		}
	}
	
	[powerupInSlot replaceObjectAtIndex:slot withObject:[NSNumber numberWithInt:newPowerup]];
	[mController loadPowerupSlot:slot];
}

- (void)addExtraLife
{
	if (mLives == 2) [mController deactivateLivesCritical];
	mLives++;
	[mController updateLives:mLives];
}

- (void)replaceCenterShapeForUniformityPowerup
{
	if (mCenter[GAME_COLOR] != BLUE_COLOR)
		[self newCenterPiece];		
}

- (void)usedPowerup
{
	powerupUse[self.powerupInUse] = FGPowerupUsed;
}

#pragma mark -
#pragma mark Blitz

- (void)addExtraSeconds
{
	blitzSeconds += GAME_BLITZ_EXTRASECONDS;
	[mController updateLives:blitzSeconds];
	if (blitzSeconds > 10) [mController deactivateLivesCritical];
}

#pragma mark -
#ifdef DEMO_MODE
#pragma mark -

#pragma mark -
#else
#pragma mark -

#pragma mark Leaderboard

- (void)authenticateLocalUserAndSubmitScore
{
	if (![[GKLocalPlayer localPlayer] isAuthenticated]) {
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
			if (!error) {
				[AppDelegate updateLoadingLabel:@"Posting Score"];
				[self submitScore];
			} else {
				[AppDelegate updateLoadingLabel:@"Unable To Post Score"];
				[self performSelector:@selector(cleanUpAfterUnsuccessfulScorePost) withObject:nil afterDelay:1.0];
			}
		}];
	} else {
		[AppDelegate showLoadingViewWithLabel:@"Posting Score"];
		[self submitScore];
	}
}

- (void)submitScore
{
	GKScore *score = [[GKScore alloc] init];
	[score setValue:mPoints];
	[score reportScoreWithCompletionHandler:^(NSError *error) {
		if (!error) {
			[mController resetView];
			[self resetGame];
			[AppDelegate showMainMenuViewAndLeaderBoard];
		} else {
			[AppDelegate updateLoadingLabel:@"Unable To Post Score"];
			[self performSelector:@selector(cleanUpAfterUnsuccessfulScorePost) withObject:nil afterDelay:1.0];
		}
		[score release];
	}];
}

- (void)cleanUpAfterUnsuccessfulScorePost
{
	[self showMainMenu];
	[self resetGame];
	[AppDelegate dismissLoadingView];
	[mController resetView];
}

#pragma mark -
#pragma mark Achievements

- (void)submitBackToBackAchievement
{
	if ([AppDelegate connectedToGameCenter]) {
		/* LOGIC FOR BACK TO BACK ACHIEVEMENT */
		NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
		if ([earnedAchievements objectForKey:kAchievementBackToBack] == nil) {
			[[AppDelegate gameCenterManager] submitAchievement:kAchievementBackToBack percentComplete:100.0];
		} else {
			GKAchievement *achievement = (GKAchievement *)[earnedAchievements objectForKey:kAchievementBackToBack];
			if (!achievement.completed) {
				[[AppDelegate gameCenterManager] submitAchievement:kAchievementBackToBack percentComplete:100.0];
			}
		}	
		/* LOGIC FOR BACK TO BACK ACHIEVEMENT */
	}
}

- (void)checkForGameOverAchievements
{
	if ([AppDelegate connectedToGameCenter]) {
		NSLog(@"pu %i %i %i %i %i", powerupUse[FGPowerupRadiation], powerupUse[FGPowerupSlowdown], powerupUse[FGPowerupExtraLife],
			  powerupUse[FGPowerupUniformity], powerupUse[FGPowerupDoubler]);
		/* LOGIC FOR NO POWERUPS ACHIEVEMENT */
		if (noPowerupsUsed && mPoints > kRequirementNoPowerups-1) {
			NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
			if ([earnedAchievements objectForKey:kAchievementNoPowerups] == nil) {
				// Submit this achievement
				[[AppDelegate gameCenterManager] submitAchievement:kAchievementNoPowerups percentComplete:100.0];
			}
		}
		/* LOGIC FOR NO POWERUPS ACHIEVEMENT */
		
		/* LOGIC FOR ELIMINATOR ACHIEVEMENT */
		if (
			powerupUse[FGPowerupRadiation] == FGPowerupUsed &&
			powerupUse[FGPowerupSlowdown] == FGPowerupUnused &&
			powerupUse[FGPowerupExtraLife] == FGPowerupUnused &&
			powerupUse[FGPowerupUniformity] == FGPowerupUnused &&
			powerupUse[FGPowerupDoubler] == FGPowerupUnused
			) {
			NSDictionary *earnedAchievements = [AppDelegate checkEarnedAchievements];
			if ([earnedAchievements objectForKey:kAchievementEliminator] == nil) {
				// Submit this achievement
				[[AppDelegate gameCenterManager] submitAchievement:kAchievementEliminator percentComplete:100.0];
			}
		}
		/* LOGIC FOR ELIMINATOR ACHIEVEMENT */
	}
}

#endif

@end
