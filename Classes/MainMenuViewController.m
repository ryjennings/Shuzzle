//
//  MainMenuViewController.m
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainMenuViewController.h"
#import "FormicAppDelegate.h"
#import "InAppPurchaseManager.h"
#import "FormicGame.h"

@interface MainMenuViewController ()
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *playWidthConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *playLeadingConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *playTrailingConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *scoresWidthConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *scoresLeadingConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *scoresTrailingConstraint;
@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)showIntroAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to Shuzzle"
                                                    message:@"You are playing the free version of Shuzzle. Only Easy Mode is available. Tap \"Unlock\" to access other game modes, as well as other locked features of this game." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [timewarp.layer addAnimation:[AppDelegate rotationAnimation] forKey:@"spin"];
    if ([AppDelegate shouldShowBigShuzzle]) {
        [AppDelegate setShouldShowBigShuzzle:NO];
        shuzzleBig.alpha = 1.0;
        instructionsWell.alpha = 0.0;
        buttonInstructions.alpha = 0.0;
        settingsWell.alpha = 0.0;
        buttonSettings.alpha = 0.0;
        unlockGroup.alpha = 0.0;
        playNowGroup.alpha = 0.0;
        mainButtons.alpha = 0.0;
        mainButtons.transform = CGAffineTransformMakeScale(0.8, 0.8);
        shuzzleSmall.alpha = 0.0;
        
        [UIView animateWithDuration:0.75
                              delay:1.5
                            options:nil
                         animations:^{
                             shuzzleBig.alpha = 0.0;
                             shuzzleBig.transform = CGAffineTransformMakeScale(1.2, 1.2);
                             instructionsWell.alpha = 1.0;
                             buttonInstructions.alpha = 1.0;
                             settingsWell.alpha = 1.0;
                             buttonSettings.alpha = 1.0;
                             mainButtons.alpha = 1.0;
                             mainButtons.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             shuzzleSmall.alpha = 1.0;
                             [self setupBottomOfScreen];
                         } completion:^(BOOL finished) {
                             if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
                                 [self performSelector:@selector(showIntroAlert) withObject:nil afterDelay:1.0];
                             }

                         }];
    }
}

- (void)setupBottomOfScreen {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
        NSLog(@"GAME IS UNLOCKED!!!");
        unlockGroup.alpha = 0.0;
        playNowGroup.alpha = 1.0;
        buttonHighscores.enabled = YES;
        [self setupScoreboard];
    } else {
        NSLog(@"GAME IS LOCKED!");
        [self hideErrorLabel];
        unlockGroup.alpha = 1.0;
        playNowGroup.alpha = 0.0;
        buttonHighscores.enabled = NO;
        [[InAppPurchaseManager sharedInstance] canUnlock];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canMakePurchaseAndProductExists:) name:kInAppPurchaseManagerCanMakePurchaseAndProductExistsNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canNotMakePurchase:) name:kInAppPurchaseManagerCanNotMakePurchaseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productDoesNotExist:) name:kInAppPurchaseManagerProductDoesNotExistNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionSucceeded:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailed:) name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
    }
}

- (void)setupScoreboard {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEasyModeScoreKey]) {
        scores[0] = [[[NSUserDefaults standardUserDefaults] objectForKey:kEasyModeScoreKey] intValue];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kMediumModeScoreKey]) {
        scores[1] = [[[NSUserDefaults standardUserDefaults] objectForKey:kMediumModeScoreKey] intValue];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kHardModeScoreKey]) {
        scores[2] = [[[NSUserDefaults standardUserDefaults] objectForKey:kHardModeScoreKey] intValue];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kExtremeModeScoreKey]) {
        scores[3] = [[[NSUserDefaults standardUserDefaults] objectForKey:kExtremeModeScoreKey] intValue];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kBlitzModeScoreKey]) {
        scores[4] = [[[NSUserDefaults standardUserDefaults] objectForKey:kBlitzModeScoreKey] intValue];
    }
    [self updatePlayNowLabel];
}

- (void)updatePlayNowLabel {
    NSString *mode;
    NSString *score;
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    switch (activeIndex) {
        case 0:
            mode = @"Easy Mode";
            score = [formatter stringFromNumber:[NSNumber numberWithInt:scores[0]]];
            break;
        case 1:
            mode = @"Medium Mode";
            score = [formatter stringFromNumber:[NSNumber numberWithInt:scores[1]]];
            break;
        case 2:
            mode = @"Hard Mode";
            score = [formatter stringFromNumber:[NSNumber numberWithInt:scores[2]]];
            break;
        case 3:
            mode = @"Extreme Mode";
            score = [formatter stringFromNumber:[NSNumber numberWithInt:scores[3]]];
            break;
        case 4:
            mode = @"Blitz Mode";
            score = [formatter stringFromNumber:[NSNumber numberWithInt:scores[4]]];
            break;
        default:
            break;
    }
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ points", mode, score]];
    [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0] range:NSMakeRange(0, mode.length)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:18.0] range:NSMakeRange(mode.length, attributed.string.length - mode.length)];
    playNowLabel.attributedText = attributed;
    playNowLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)canMakePurchaseAndProductExists:(NSNotification *)note {
    [self hideErrorLabel];
}

- (void)canNotMakePurchase:(NSNotification *)note {
    [self showErrorLabel];
    unlockErrorLabel.text = @"You might have 'In-App Purchases' turned off. You will have to enable them to unlock this game.";
}

- (void)productDoesNotExist:(NSNotification *)note {
    [self showErrorLabel];
    unlockErrorLabel.text = @"Error!";
}

- (void)transactionSucceeded:(NSNotification *)note {
    [UIView animateWithDuration:0.5
                     animations:^{
                         unlockGroup.alpha = 0.0;
                         playNowGroup.alpha = 1.0;
                         buttonHighscores.enabled = YES;
                     }];
    [self setupScoreboard];
    self.view.userInteractionEnabled = YES;
}

- (void)transactionFailed:(NSNotification *)note {
    NSLog(@"transactionFailed");
    [UIView animateWithDuration:0.5
                     animations:^{
                         unlockErrorLabel.alpha = 0.0;
                         unlockButton.alpha = 1.0;
                         unlockLabel.alpha = 1.0;
                     }];
    self.view.userInteractionEnabled = YES;
}

- (void)showErrorLabel {
    unlockErrorLabel.alpha = 1.0;
    unlockButton.alpha = 0.0;
    unlockLabel.alpha = 0.0;
}

- (void)hideErrorLabel {
    unlockErrorLabel.alpha = 0.0;
    unlockButton.alpha = 1.0;
    unlockLabel.alpha = 1.0;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
	[buttonPlay release];
	[buttonHighscores release];
	[buttonInstructions release];
	[buttonSettings release];

    [timewarp release];
    
    [mainButtons release];
    
    [unlockGroup release];
    [unlockButton release];
    [unlockLabel release];
    [unlockErrorLabel release];
    
    [playNowGroup release];
    [playNowButton release];
    [playNowLabel release];
    
    [instructionsWell release];
    [settingsWell release];
    [shuzzleSmall release];
    [shuzzleBig release];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super dealloc];
}

- (IBAction)onButtonPlay {
	
	[AppDelegate playButtonSound];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"saved"] && 
		[AppDelegate controlScheme] != [[[NSUserDefaults standardUserDefaults] valueForKey:@"mode"] intValue]) {
		
		NSString *savedMode = [[[NSUserDefaults standardUserDefaults] valueForKey:@"mode"] intValue] == 0 ? @"touch" : @"tilt";
		NSString *otherMode = [[[NSUserDefaults standardUserDefaults] valueForKey:@"mode"] intValue] != 0 ? @"touch" : @"tilt";
		
		[[[[UIAlertView alloc] initWithTitle:@"Saved Game" 
									 message:[NSString stringWithFormat:@"You have a saved game in %@ mode. Would you like to delete that save and start a new game in %@ mode?", savedMode, otherMode]
									delegate:self 
						   cancelButtonTitle:@"Play Saved" 
						   otherButtonTitles:@"New Game", nil] autorelease] show];
	} else {
		[AppDelegate showLevelSelectView];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
		NSUserDefaults *prefs = nil;
		prefs = [NSUserDefaults standardUserDefaults];
		switch (buttonIndex) {
			case 0:
				[AppDelegate setSavedGame:YES];
				[AppDelegate showFormicView];
				break;
			case 1:
				// Erase saved game
				[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"saved"];			
				[AppDelegate showLevelSelectView];
				break;
		}
}

- (IBAction)onButtonHighscores
{
	[AppDelegate displayLeaderBoard];
	[AppDelegate showLoadingViewWithLabel:@"Accessing Game Center"];
}

- (IBAction)onButtonInstructions {
	[AppDelegate playButtonSound];
	[AppDelegate showInstructionsView];
}

- (IBAction)onButtonSettings {
	[AppDelegate playButtonSound];
	[AppDelegate showSettingsView];
}

- (IBAction)didTapUnlockButton:(id)sender {
	[AppDelegate playButtonSound];
    [[InAppPurchaseManager sharedInstance] purchaseUnlock];
    [UIView animateWithDuration:0.5
                     animations:^{
                         unlockButton.alpha = 0.0;
                         unlockLabel.alpha = 0.0;
                         unlockErrorLabel.alpha = 1.0;
                         unlockErrorLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:14.0];
                         unlockErrorLabel.text = @"Purchasing full game...";
                     }];
    self.view.userInteractionEnabled = NO;
}

- (IBAction)didTapPlayNowButton:(id)sender {
	[AppDelegate playButtonSound];
	[[AppDelegate game] setLevel:activeIndex];
	[AppDelegate showFormicView];
}

@end
