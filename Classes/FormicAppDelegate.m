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
#import "InAppPurchaseManager.h"

@implementation FormicAppDelegate

@synthesize gameCenterManager, connectedToGameCenter, cannotLoadLeaderboard, shouldShowBigShuzzle;
@synthesize window;
@synthesize game;
@synthesize volume, musicOff, effectsOff, vibrateOff, colorBlindnessOn, advancedPieceOn;
@synthesize savedGame;
@synthesize controlScheme;
@synthesize userMediaItemCollection, musicPlayer;
@synthesize loadingView, loadingLabel;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	srand(time(NULL));
	[window makeKeyAndVisible];
    
    self.shouldShowBigShuzzle = NO;
    self.cannotLoadLeaderboard = NO;
	
	[self readDefaults];
		
	loadingView = nil;

	achievementAlertQueue = [[NSMutableArray alloc] init];

	backMusicPlayer = [[AVAudioPlayer alloc] init];
	menuMusicPlayer = [[AVAudioPlayer alloc] init];

	game = [[FormicGame alloc] initWithViewController:formicViewController];
	
	savedGame = NO;
	
	currentViewController = splashViewController;

    [window setRootViewController:currentViewController];
	currentViewController.view.userInteractionEnabled = YES;
    
    [[InAppPurchaseManager sharedInstance] loadStore];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leaderboardViewControllerDidFinish:) name:@"CanceledGameCenterAuthentication" object:nil];
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
	NSLog(@"You are connected to the Internet.");
	if ([GameCenterManager isGameCenterAvailable] && !self.connectedToGameCenter) {
		self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate:self];
		[self.gameCenterManager authenticateLocalUser];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"You are not connect to the Internet.");
	[[[[UIAlertView alloc] initWithTitle:@"Not connected to Internet or Internet connection is weak" 
								 message:@"You will be unable to earn achievements or submit scores without an active Internet connection."
								delegate:self 
					   cancelButtonTitle:@"OK"
					   otherButtonTitles:nil] autorelease] show];
	self.connectedToGameCenter = NO;
	NSLog(@"Therefore you are not connected to Game Center.");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	if (currentViewController == mainMenuViewController && !self.connectedToGameCenter) {
		[self checkForInternetConnection];
	}
	if (currentViewController == formicViewController && [game mState] == FGGameStateRunning) {
		[game pauseGame];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
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
    [self playMenuMusic:YES];
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
		[currentViewController.view removeFromSuperview];
	}
	currentViewController = showViewController;
	
	if (currentViewController == mainMenuViewController && !self.connectedToGameCenter) {
		[self checkForInternetConnection];
	}	
	
	currentViewController.view.alpha = 0.0;
    [window setRootViewController:showViewController];
	
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
    if (!musicPlayer) {
        [self createMusicPlayer];
    }	
    musicPlayer.volume = volume;
}

- (void)setMusicOff:(BOOL)val {
}

- (void)playMenuMusic:(BOOL)val {
}

- (void)stopMenuMusic {
}

- (void)playBackMusic:(BOOL)val {
}

- (void)playGameOverMusic
{
    if (!effectsOff) {
        [self playSystemSound:@"/gameover.caf"];
    }
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
        if (!musicPlayer) {
            [self createMusicPlayer];
        }
		[self setUserMediaItemCollection:mediaItemCollection];
		[musicPlayer setQueueWithItemCollection:userMediaItemCollection];
		[musicPlayer play];
	}
}

- (void)createMusicPlayer
{
    [self setMusicPlayer:[MPMusicPlayerController applicationMusicPlayer]];
    [musicPlayer setShuffleMode:MPMusicShuffleModeOff];
    [musicPlayer setRepeatMode:MPMusicRepeatModeAll];
}

#pragma mark -
#pragma mark Custom Loading Alert View

- (void)showLoadingViewWithLabel:(NSString *)labelText
{
	if (loadingView == nil) {
		loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, currentViewController.view.frame.size.height, currentViewController.view.frame.size.width)];
		loadingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		UIActivityIndicatorView *aiv = [[[UIActivityIndicatorView alloc] 
										 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		aiv.center = CGPointMake(loadingView.frame.size.width/2, loadingView.frame.size.height/2);
		[loadingView addSubview:aiv];
		[aiv startAnimating];
		loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 187.0, currentViewController.view.frame.size.height - 20.0, 21.0)];
		loadingLabel.textAlignment = NSTextAlignmentCenter;
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

#pragma mark Leader Board

- (void)displayLeaderBoard
{
	[self playButtonSound];
	
	GKLocalPlayer *myPlayer = [GKLocalPlayer localPlayer];
	if (![myPlayer isAuthenticated]) {
        [myPlayer setAuthenticateHandler:^(UIViewController *viewcontroller, NSError *error) {
            if (!error) {
				[self updateLoadingLabel:@"Loading Leader Board"];
				GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
				leaderboardViewController.leaderboardDelegate = self;
				leaderboardViewController.timeScope = GKLeaderboardTimeScopeAllTime;				 
				leaderboardViewController.category = nil;
                [currentViewController presentViewController:leaderboardViewController animated:YES completion:nil];

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
        [currentViewController presentViewController:leaderboardViewController animated:YES completion:nil];
		[self dismissLoadingView];
	}	
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    currentViewController.view.alpha = 0.0;
        
    mainMenuViewController = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:[NSBundle mainBundle]];
    showViewController = mainMenuViewController;
    
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self hideDidStop:nil finished:nil context:nil];
    });
    
    [currentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMainMenuViewAndLeaderBoard
{
	[self playBackMusic:NO];
		[self playMenuMusic:YES];
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
	NSLog(@"Achievement submitted: %@ %f", ach.identifier, ach.percentComplete);
	if (error == NULL && ach != NULL && ach.identifier != NULL && ach.percentComplete) {
		[self addToAchievementAnnouncementQueue:ach.identifier];
	}
}

- (void)addToAchievementAnnouncementQueue:(NSString *)identifier
{
	if (![achievementAlertQueue containsObject:identifier]) {
		[achievementAlertQueue addObject:identifier];
		if (!isAnnouncingAchievement) {
			[self announceNextAchievementInQueue];
		}
	}
}

- (void)announceNextAchievementInQueue
{
	isAnnouncingAchievement = YES;
	AchievementAlertView *achievementAlert = [[AchievementAlertView alloc] initWithAchievement:[achievementAlertQueue objectAtIndex:0]];
	[achievementAlertQueue removeObjectAtIndex:0];
	[window.rootViewController.view addSubview:achievementAlert];
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
		[self.gameCenterManager authenticateLocalUser];
	}
}

- (void)processGameCenterAuth:(NSError*)error
{
	if (error == NULL) {
		if (!self.connectedToGameCenter) {
			NSLog(@"Connected to Game Center.");
			self.connectedToGameCenter = YES;
//			[GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error){}];
//			NSLog(@"Resetting achievements.");
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
		NSLog(@"You are not connected to Game Center.");
		self.connectedToGameCenter = NO;
	}
}

- (CABasicAnimation *)rotationAnimation {
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0.0];
    rotation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotation.duration = 20.0;
    rotation.repeatCount = HUGE_VALF;
    return rotation;
}

@end
