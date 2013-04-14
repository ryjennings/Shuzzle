//
//  FormicAppDelegate.m
//  Formic
//
//  Created by Austin Evers on 11/15/2009.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FormicAppDelegate.h"
#import "MainMenuViewController.h"
#import "LevelSelectViewController.h"
#import "InstructionsViewController.h"
#import "SettingsViewController.h"
#import "FormicViewController.h"
#import "SplashViewController.h"
#import "GameCenterManager.h"
#import "AchievementAlertView.h"
#import "DemoExpiredViewController.h"

#ifdef DEMO_MODE
#import "DemoCountdown.h"
#endif

@implementation FormicAppDelegate

@synthesize gameCenterManager, connectedToGameCenter;
@synthesize window;
@synthesize game;
@synthesize volume, musicOff, effectsOff, vibrateOff, colorBlindnessOn, advancedPieceOn;
@synthesize savedGame;
@synthesize controlScheme;
@synthesize userMediaItemCollection, musicPlayer;
@synthesize loadingView, loadingLabel;

#ifdef DEMO_MODE
@synthesize demoCountdown, loadedDemoSeconds, demoStatus;
#endif

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	srand(time(NULL));
	[window makeKeyAndVisible];
	
	[self readDefaults];
		
	loadingView = nil;

	achievementAlertQueue = [[NSMutableArray alloc] init];

	backMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
					   [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"back" ofType:@"mp3"]] error:nil];
	backMusicPlayer.numberOfLoops = -1;
	backMusicPlayer.volume = volume;
	
	menuMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
					   [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"menu" ofType:@"mp3"]] error:nil];
	menuMusicPlayer.numberOfLoops = -1;
	menuMusicPlayer.volume = volume;
	[menuMusicPlayer prepareToPlay];
	
	[menuMusicPlayer playAtTime:menuMusicPlayer.deviceCurrentTime+3.5];
	 
	game = [[FormicGame alloc] initWithViewController:formicViewController];
	
	savedGame = NO;
	
#ifdef DEMO_MODE
	[self loadRemainingDemoSeconds];
	if (self.demoStatus == FGDemoStatusExpired) {
		menuMusicPlayer.volume = 0.0;
		currentViewController = demoExpiredViewController;
	} else {
		currentViewController = splashViewController;
	}
#else
	currentViewController = splashViewController;
#endif
	[window addSubview:currentViewController.view];
	currentViewController.view.userInteractionEnabled = YES;
}

- (void)checkForInternetConnection
{
	NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:10.0];
	[[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
}	

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connectivity");
	if ([GameCenterManager isGameCenterAvailable] && !self.connectedToGameCenter) {
		self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate:self];
		[self.gameCenterManager authenticateLocalUser];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"NO connectivity");
	[[[[UIAlertView alloc] initWithTitle:@"Not connected to Internet or Internet connection is weak" 
								 message:@"You will be unable to earn achievements or submit scores without an active Internet connection."
								delegate:self 
					   cancelButtonTitle:@"OK"
					   otherButtonTitles:nil] autorelease] show];
	self.connectedToGameCenter = NO;
	NSLog(@"NOT connected to Game Center");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
#ifdef DEMO_MODE
	[self loadRemainingDemoSeconds];
	if (self.demoStatus == FGDemoStatusExpired) {
		menuMusicPlayer.volume = 0.0;
		[demoExpiredViewController showAlert];
		return;
	}
	if (currentViewController != splashViewController) {
		[self showDemoCountdown];
	}
#endif
	if (currentViewController == mainMenuViewController && !self.connectedToGameCenter) {
		[self checkForInternetConnection];
	}
	if (currentViewController == formicViewController && [game mState] == FGGameStateRunning) {
		[game pauseGame];
	} else if (currentViewController == mainMenuViewController) {
		if (!menuMusicPlayer.playing) [menuMusicPlayer play];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
#ifdef DEMO_MODE
	if (game == nil) return;
	[self saveRemainingDemoSeconds];
#endif	
	if (([game mState] == FGGameStateRunning && [[formicViewController btnPause] isEnabled]) || [game mState] == FGGameStatePaused) {
		[game stopTimer];
	} else if (currentViewController == formicViewController && [game mState] != FGGameStateOver) {
		[[formicViewController countdownTimer] stopCountdown];
		[formicViewController resetView];
		[game resetGame];
		[self showMainMenuView];
	}	   
	[self writeDefaults];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#ifdef DEMO_MODE
	[self saveRemainingDemoSeconds];
#endif
	[game saveGame];
	[self writeDefaults];
}

- (void)dealloc
{
	if (backMusicPlayer != nil) {
		[backMusicPlayer stop];
		[backMusicPlayer release];
	}
	if (menuMusicPlayer != nil) {
		[menuMusicPlayer stop];
		[menuMusicPlayer release];
	}
	currentViewController = nil;
	showViewController = nil;
	[mainMenuViewController release];
	[levelSelectViewController release];
	[instructionsViewController release];
	[demoExpiredViewController release];
	[settingsViewController release];
	[formicViewController release];
	[splashViewController release];
	[window release];
	[game release];
    [loadingView release], loadingView = nil;
    [loadingLabel release], loadingLabel = nil;
	[achievementAlertQueue release];
	[super dealloc];
}

- (void)writeDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:volume forKey:@"volume"];
	[defaults setBool:musicOff forKey:@"musicOff"];
	[defaults setBool:effectsOff forKey:@"effectsOff"];
	[defaults setBool:vibrateOff forKey:@"vibrateOff"];
	[defaults setBool:colorBlindnessOn forKey:@"cbOn"];
	[defaults setBool:advancedPieceOn forKey:@"advancedOn"];
	[defaults setInteger:controlScheme forKey:@"controlScheme"];
	[defaults synchronize];
}

- (void)readDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	volume = [defaults floatForKey:@"volume"];
	if (volume==0) volume = 1.0;
	musicOff = [defaults boolForKey:@"musicOff"];
	effectsOff = [defaults boolForKey:@"effectsOff"];
	vibrateOff = [defaults boolForKey:@"vibrateOff"];
	colorBlindnessOn = [defaults boolForKey:@"cbOn"];
	advancedPieceOn = [defaults boolForKey:@"advancedOn"];
	controlScheme = [defaults integerForKey:@"controlScheme"];
}

#pragma mark -
#pragma mark Show View Controller Methods

- (void)showMainMenuView {
	[self playBackMusic:NO];
#ifdef DEMO_MODE
	if (self.demoStatus != FGDemoStatusExpired) {
#endif
		[self playMenuMusic:YES];
#ifdef DEMO_MODE
	}
#endif			
	[self showView:mainMenuViewController];
}

- (void)returnToMainMenuViewWithoutRestartingMusic {
	[self showView:mainMenuViewController];
}

- (void)showLevelSelectView {
	[self showView:levelSelectViewController];
}

- (void)showInstructionsView {
	[self showView:instructionsViewController];
}

- (void)showSettingsView {
	[self showView:settingsViewController];
}

- (void)showFormicView {
	[self showView:formicViewController];
}

- (void)showDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	currentViewController.view.userInteractionEnabled = YES;
}

- (void)hideDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if (currentViewController != nil) {
#ifdef DEMO_MODE
		[self hideDemoCountdown];
#endif
		[currentViewController.view removeFromSuperview];
#ifdef DEMO_MODE
//		if (showViewController == demoExpiredViewController) {
//			[currentViewController release];
//		}
#endif
	}
	currentViewController = showViewController;
	
#ifdef DEMO_MODE
	if (self.demoStatus != FGDemoStatusUnknown && currentViewController != demoExpiredViewController) {
		[self performSelector:@selector(showDemoCountdown) withObject:nil afterDelay:0.1];
	}
#else
	if (currentViewController == mainMenuViewController && !self.connectedToGameCenter) {
		[self checkForInternetConnection];
	}	
#endif
	
	currentViewController.view.alpha = 0.0;
	[window addSubview:showViewController.view];
	
	currentViewController.view.userInteractionEnabled = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showDidStop:finished:context:)];
	currentViewController.view.alpha = 1.0;
	[UIView commitAnimations];

	if (currentViewController == formicViewController && savedGame) {
		[game restoreGame];
		savedGame = NO;
	}
}

- (void)showView:(UIViewController *)controller
{
	showViewController = controller;
	
	if (currentViewController) {
		currentViewController.view.userInteractionEnabled = NO;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideDidStop:finished:context:)];
		currentViewController.view.alpha = 0.0;
		[UIView commitAnimations];
	}
	else {
		[self hideDidStop:nil finished:nil context:nil];
	}
}

#pragma mark -
#pragma mark Music Management

- (void)setVolume:(float)val {
	volume = val;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:volume forKey:@"volume"];
	backMusicPlayer.volume = volume;
	menuMusicPlayer.volume = volume;
	musicPlayer.volume = volume;
}	

- (void)setMusicOff:(BOOL)val {
	musicOff = val;
	if (menuMusicPlayer.playing) {
		[menuMusicPlayer stop];
	}
	else {
		menuMusicPlayer.currentTime = 0;
		[menuMusicPlayer play];
	}
}

- (void)playMenuMusic:(BOOL)val {
	if (val && !musicOff) {
		menuMusicPlayer.currentTime = 0;
		[menuMusicPlayer play];
	}
	else [menuMusicPlayer stop];
}

- (void)stopMenuMusic {
	[menuMusicPlayer stop];
}

- (void)playBackMusic:(BOOL)val {
	if (val && !musicOff) {
		backMusicPlayer.currentTime = 0;
		[backMusicPlayer play];
	}
	else [backMusicPlayer stop];
}

- (void)playGameOverMusic
{
#ifdef DEMO_MODE
	if (self.demoStatus != FGDemoStatusExpired) {
#endif
		if (!effectsOff) {
			[self playSystemSound:@"/gameover.caf"];
		}
#ifdef DEMO_MODE
	}
#endif
}

- (void)playMoveSound
{
	if (!effectsOff) {
		[self playSystemSound:@"/move.caf"];
	}
}

- (void)playGoldShapeSound
{
	if (!effectsOff) {
		[self playSystemSound:@"/gold.caf"];
	}
}

- (void)playSlowdownSound
{
	if (!effectsOff) {
		[self playSystemSound:@"/clock.caf"];
	}
}

- (void)playRadiationSound
{
	if (!effectsOff) {
		[self playSystemSound:@"/ex.caf"];
	}
}

- (void)playDoublePointsSound
{
	if (!effectsOff) {
		[self playSystemSound:@"/pts.caf"];
	}
}

- (void)playUniformitySound
{
	if (!effectsOff) {
		[self playSystemSound:@"/uniform.caf"];
	}
}

- (void)playExtraLifeSound {
	if (!effectsOff) {
		[self playSystemSound:@"/extralife.caf"];
	}
}

- (void)playCountdownSound {
	if (!effectsOff) {
		[self playSystemSound:@"/cping.caf"];
	}
}

- (void)playErrorSound {
	if (!effectsOff) {
		[self playSystemSound:@"/errornoise.caf"];
	}
}

- (void)playButtonSound {
	if (!effectsOff) {
		[self playSystemSound:@"/button.caf"];
	}
}

- (void)playSystemSound:(NSString *)sound
{
	NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], sound];
	SystemSoundID soundID;
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
	AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);	
	AudioServicesPlaySystemSound(soundID);
}

- (void)doVibration {
	if (!vibrateOff) {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}	
}

#pragma mark -
#pragma mark Media Picker Methods

- (void)updatePlayerQueueWithMediaCollection:(MPMediaItemCollection *)mediaItemCollection
{	
	if (mediaItemCollection) {
		[self setMusicPlayer:[MPMusicPlayerController applicationMusicPlayer]];
		[self setUserMediaItemCollection:mediaItemCollection];
		[musicPlayer setQueueWithItemCollection:userMediaItemCollection];
		[musicPlayer setShuffleMode:MPMusicShuffleModeOff];
		[musicPlayer setRepeatMode:MPMusicRepeatModeAll];
		[musicPlayer play];
	}
}

#pragma mark -
#pragma mark Custom Loading Alert View

- (void)showLoadingViewWithLabel:(NSString *)labelText
{
	if (loadingView == nil) {
		loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 480.0, 320.0)];
		loadingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		UIActivityIndicatorView *aiv = [[[UIActivityIndicatorView alloc] 
										 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		aiv.center = CGPointMake(loadingView.bounds.size.width/2, loadingView.bounds.size.height/2);
		[loadingView addSubview:aiv];
		[aiv startAnimating];
		loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 187.0, 460.0, 21.0)];
		loadingLabel.textAlignment = UITextAlignmentCenter;
		loadingLabel.adjustsFontSizeToFitWidth = YES;
		loadingLabel.font = [UIFont boldSystemFontOfSize:17.0];
		loadingLabel.backgroundColor = [UIColor clearColor];
		loadingLabel.textColor = [UIColor whiteColor];
		[loadingView addSubview:loadingLabel];
	}
	
    [currentViewController.view addSubview:loadingView];
	loadingLabel.text = labelText;
    
    CALayer *viewLayer = self.loadingView.layer;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.duration = 0.35555555;
    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:0.6],
                        [NSNumber numberWithFloat:1.1],
                        [NSNumber numberWithFloat:.9],
                        [NSNumber numberWithFloat:1],
                        nil];
    animation.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:0.6],
                          [NSNumber numberWithFloat:0.8],
                          [NSNumber numberWithFloat:1.0], 
                          nil];    
    
    [viewLayer addAnimation:animation forKey:@"transform.scale"];	
}

- (void)dismissLoadingView
{
    [UIView beginAnimations:@"" context:nil];
    self.loadingView.alpha = 0.0;
    [UIView commitAnimations];
    [UIView setAnimationDuration:0.35];
    [self performSelector:@selector(removeLoadingView) withObject:nil afterDelay:0.5];
}

- (void)removeLoadingView
{
    [self.loadingView removeFromSuperview];
    self.loadingView.alpha = 1.0;
}

- (void)updateLoadingLabel:(NSString *)labelText
{
	loadingLabel.text = labelText;
}

#pragma mark -
#pragma mark Other

- (void)setControlScheme:(FGControlScheme)scheme {
	controlScheme = scheme;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:controlScheme forKey:@"controlScheme"];
}

#pragma mark -
#ifdef DEMO_MODE
#pragma mark -

#pragma mark Demo Mode

- (void)saveRemainingDemoSeconds
{
	[self hideDemoCountdown];
	int sec = demoCountdown.remainingSeconds;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[NSNumber numberWithInt:sec] forKey:@"demoseconds"];
	NSLog(@"saved seconds %i", demoCountdown.remainingSeconds);
}

- (void)loadRemainingDemoSeconds
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	self.demoStatus = [[NSNumber numberWithInt:[prefs integerForKey:@"demostatus"]] intValue];
	loadedDemoSeconds = [[NSNumber numberWithInt:[prefs integerForKey:@"demoseconds"]] intValue];
	NSLog(@"loaded seconds %i", loadedDemoSeconds);
}

- (void)showDemoCountdown
{
	if (demoCountdown == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"DemoCountdown" owner:self options:nil];
		demoCountdown.remainingSeconds = loadedDemoSeconds;
		demoCountdown.frame = CGRectMake(-25.0, 320.0, 145.0, 45.0);
		demoCountdown.backgroundColor = [UIColor clearColor];		
		[currentViewController.view addSubview:demoCountdown];
		[UIView animateWithDuration:0.2
							  delay:0.0
							options:UIViewAnimationOptionAllowUserInteraction
						 animations:^{
							 demoCountdown.frame = CGRectMake(-25.0, 275.0, 145.0, 45.0);
						 }
						 completion:NULL];
	} else {
		demoCountdown.frame = CGRectMake(-25.0, 275.0, 145.0, 45.0);
		[currentViewController.view addSubview:demoCountdown];
	}
	[demoCountdown startArrows];
}

- (void)hideDemoCountdown
{
	if (demoCountdown != nil) {
		[demoCountdown stopArrows];
		[demoCountdown removeFromSuperview];
	}
}

- (void)killDemoCountdown
{
	[UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 demoCountdown.frame = CGRectMake(-25.0, 320.0, 145.0, 45.0);
					 }
					 completion:^(BOOL finished){
						 [demoCountdown removeFromSuperview];
						 [demoCountdown release], demoCountdown = nil;
					 }];	
}

- (void)displayDemoExpiredViewController
{
	self.demoStatus = FGDemoStatusExpired;
	[self fadeOutAudioPlayer:backMusicPlayer];
	[self fadeOutAudioPlayer:menuMusicPlayer];
	[game release], game = nil;
	[currentViewController release];
	[self showView:demoExpiredViewController];
}

- (void)fadeOutAudioPlayer:(AVAudioPlayer *)player
{
	if (player.volume > 0) {
		player.volume -= 0.05;
		[self performSelector:@selector(fadeOutAudioPlayer:) withObject:player afterDelay:0.1];
	} else {
		[player stop];
		[player release], player = nil;
	}
}


#pragma mark -
#pragma mark Empties

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
}

#pragma mark -
#else
#pragma mark -

#pragma mark Leader Board

- (void)displayLeaderBoard
{
	[self playButtonSound];
	
	GKLocalPlayer *myPlayer = [GKLocalPlayer localPlayer];
	if (![myPlayer isAuthenticated]) {
		[myPlayer authenticateWithCompletionHandler:^(NSError *error) {			 
			if (!error) {
				[self updateLoadingLabel:@"Loading Leader Board"];
				GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
				leaderboardViewController.leaderboardDelegate = self;
				leaderboardViewController.timeScope = GKLeaderboardTimeScopeAllTime;				 
				leaderboardViewController.category = nil;
				[currentViewController presentModalViewController:leaderboardViewController animated:YES];
				[self dismissLoadingView];
			} else {
				[self dismissLoadingView];
			}
		}];		
	} else {
		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
		leaderboardViewController.leaderboardDelegate = self;
		leaderboardViewController.timeScope = GKLeaderboardTimeScopeAllTime;				 
		leaderboardViewController.category = nil;		
		[currentViewController presentModalViewController:leaderboardViewController animated:YES];
		[self dismissLoadingView];
	}	
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[currentViewController dismissModalViewControllerAnimated:YES];
}

- (void)showMainMenuViewAndLeaderBoard
{
	[self playBackMusic:NO];
#ifdef DEMO_MODE
	if (self.demoStatus != FGDemoStatusExpired) {
#endif
		[self playMenuMusic:YES];
#ifdef DEMO_MODE
	}
#endif
	[self showView:mainMenuViewController];
	[self performSelector:@selector(displayLeaderBoard) withObject:nil afterDelay:1.0];
}

#pragma mark -
#pragma mark Achievements

- (NSDictionary *)checkEarnedAchievements
{
	return [self.gameCenterManager earnedAchievementCache];
}

- (void)achievementSubmitted:(GKAchievement *)ach error:(NSError *)error
{
	NSLog(@"achievementSubmitted %@ %f", ach.identifier, ach.percentComplete);
	if (error == NULL && ach != NULL && ach.identifier != NULL && ach.percentComplete) {
		[self addToAchievementAnnouncementQueue:ach.identifier];
	}
}

- (void)addToAchievementAnnouncementQueue:(NSString *)identifier
{
	if (![achievementAlertQueue containsObject:identifier]) {
		NSLog(@"addToAchievementAnnouncementQueue");
		[achievementAlertQueue addObject:identifier];
		if (!isAnnouncingAchievement) {
			[self announceNextAchievementInQueue];
		}
	}
}

- (void)announceNextAchievementInQueue
{
	NSLog(@"announceNextAchievementInQueue");
	isAnnouncingAchievement = YES;
	AchievementAlertView *achievementAlert = [[AchievementAlertView alloc] initWithAchievement:[achievementAlertQueue objectAtIndex:0]];
	[achievementAlertQueue removeObjectAtIndex:0];
	[currentViewController.view addSubview:achievementAlert];
	achievementAlert.alpha = 0.0;
	[UIView animateWithDuration:0.25
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 achievementAlert.alpha = 1.0;
					 }
					 completion:^(BOOL finished){
						 [UIView animateWithDuration:0.25
											   delay:2.0
											 options:UIViewAnimationOptionAllowUserInteraction
										  animations:^{
											  achievementAlert.alpha = 0.0;
										  }
										  completion:^(BOOL finished){
											  [achievementAlert removeFromSuperview];
											  [achievementAlert release];
											  isAnnouncingAchievement = NO;
											  if ([achievementAlertQueue count] > 0) {
												  [self announceNextAchievementInQueue];
											  }
										  }];
					 }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		NSLog(@"retrying");
		[self.gameCenterManager authenticateLocalUser];
	}
}

- (void)processGameCenterAuth:(NSError*)error
{
	if (error == NULL) {
		if (!self.connectedToGameCenter) {
			NSLog(@"Connected to Game Center");
			self.connectedToGameCenter = YES;
//			[GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error) 
//			 {
//			 }];
//			NSLog(@"Resetting achievements");			
			// We're not actually submitting an achievement, simply loading already won achievements to memory
			[[AppDelegate gameCenterManager] submitAchievement:kAchievementBackToBack percentComplete:0.0];
		}
	} else {
		UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"Could not connect to Game Center" 
														message:[NSString stringWithFormat:@"Reason: %@", [error localizedDescription]]
													   delegate:self 
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Try Again" , nil] autorelease];
		[alert show];
		NSLog(@"NOT connected to Game Center");
		self.connectedToGameCenter = NO;
	}
}

#endif

@end
