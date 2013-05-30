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
    NSLog(@"main menu viewDidLoad");
}

- (void)showIntroAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to Shuzzle"
                                                    message:@"You are playing the free version of Shuzzle. Only Easy Mode is available. Tap \"Unlock\" to access other game modes, as well as other locked features of this game." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"main menu viewWillAppear");
    [super viewWillAppear:animated];

    activeIndex = -1;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

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

- (void)appDidBecomeActive:(NSNotification *)note {
    [timewarp.layer removeAllAnimations];
    [timewarp.layer addAnimation:[AppDelegate rotationAnimation] forKey:@"spin"];
}

- (void)setupBottomOfScreen {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
        NSLog(@"GAME IS UNLOCKED!!!");
        unlockGroup.alpha = 0.0;
        playNowGroup.alpha = 1.0;
        buttonHighscores.enabled = YES;
        [self performSelector:@selector(setupScoreboard) withObject:nil afterDelay:0.0];
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
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 6, scrollView.frame.size.height);
    
    scores[0] = ([[NSUserDefaults standardUserDefaults] objectForKey:kEasyModeScoreKey]) ? [[[NSUserDefaults standardUserDefaults] objectForKey:kEasyModeScoreKey] intValue] : 0;

    scores[1] = ([[NSUserDefaults standardUserDefaults] objectForKey:kMediumModeScoreKey]) ? [[[NSUserDefaults standardUserDefaults] objectForKey:kMediumModeScoreKey] intValue] : 0;

    scores[2] = ([[NSUserDefaults standardUserDefaults] objectForKey:kHardModeScoreKey]) ? [[[NSUserDefaults standardUserDefaults] objectForKey:kHardModeScoreKey] intValue] : 0;

    scores[3] = ([[NSUserDefaults standardUserDefaults] objectForKey:kExtremeModeScoreKey]) ? [[[NSUserDefaults standardUserDefaults] objectForKey:kExtremeModeScoreKey] intValue] : 0;
    
    scores[4] = ([[NSUserDefaults standardUserDefaults] objectForKey:kBlitzModeScoreKey]) ? [[[NSUserDefaults standardUserDefaults] objectForKey:kBlitzModeScoreKey] intValue] : 0;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSMutableAttributedString *a1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Easy Mode %@ points", [formatter stringFromNumber:[NSNumber numberWithInt:scores[0]]]]];
    [a1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0] range:NSMakeRange(0, @"Easy Mode".length)];
    [a1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:18.0] range:NSMakeRange(@"Easy Mode".length, a1.string.length - @"Easy Mode".length)];

    scoreLabel1.attributedText = a1;
    scoreLabel1.textAlignment = NSTextAlignmentCenter;
    scoreLabel6.attributedText = a1;
    scoreLabel6.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *a2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Medium Mode %@ points", [formatter stringFromNumber:[NSNumber numberWithInt:scores[1]]]]];
    [a2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0] range:NSMakeRange(0, @"Medium Mode".length)];
    [a2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:18.0] range:NSMakeRange(@"Medium Mode".length, a2.string.length - @"Medium Mode".length)];
    scoreLabel2.attributedText = a2;
    scoreLabel2.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *a3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hard Mode %@ points", [formatter stringFromNumber:[NSNumber numberWithInt:scores[2]]]]];
    [a3 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0] range:NSMakeRange(0, @"Hard Mode".length)];
    [a3 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:18.0] range:NSMakeRange(@"Hard Mode".length, a3.string.length - @"Hard Mode".length)];
    scoreLabel3.attributedText = a3;
    scoreLabel3.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *a4 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Extreme Mode %@ points", [formatter stringFromNumber:[NSNumber numberWithInt:scores[3]]]]];
    [a4 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0] range:NSMakeRange(0, @"Extreme Mode".length)];
    [a4 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:18.0] range:NSMakeRange(@"Extreme Mode".length, a4.string.length - @"Extreme Mode".length)];
    scoreLabel4.attributedText = a4;
    scoreLabel4.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *a5 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Blitz Mode %@ points", [formatter stringFromNumber:[NSNumber numberWithInt:scores[4]]]]];
    [a5 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0] range:NSMakeRange(0, @"Blitz Mode".length)];
    [a5 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:18.0] range:NSMakeRange(@"Blitz Mode".length, a5.string.length - @"Blitz Mode".length)];
    scoreLabel5.attributedText = a5;
    scoreLabel5.textAlignment = NSTextAlignmentCenter;
    
    [self updatePlayNowLabel];
}

- (void)updatePlayNowLabel {
    activeIndex++;
    
    [scrollView scrollRectToVisible:CGRectMake(scrollView.frame.size.width * activeIndex, 0.0, scrollView.frame.size.width, scrollView.frame.size.height) animated:YES];
    
    [self performSelector:@selector(updatePlayNowLabel) withObject:nil afterDelay:7.0];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    if (aScrollView.contentOffset.x == 1860) {
        [aScrollView scrollRectToVisible:CGRectMake(0.0, 0.0, aScrollView.frame.size.width, aScrollView.frame.size.height) animated:NO];
    }
    [self performSelector:@selector(updatePlayNowLabel) withObject:nil afterDelay:7.0];
    activeIndex = (int)(aScrollView.contentOffset.x / aScrollView.frame.size.width);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView {
    if (aScrollView.contentOffset.x == 1860) {
        [aScrollView scrollRectToVisible:CGRectMake(0.0, 0.0, aScrollView.frame.size.width, aScrollView.frame.size.height) animated:NO];
        activeIndex = (int)(aScrollView.contentOffset.x / aScrollView.frame.size.width);
    }
    [self performSelector:@selector(updatePlayNowLabel) withObject:nil afterDelay:7.0];
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
    [self performSelector:@selector(setupScoreboard) withObject:nil afterDelay:0.0];
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
    [scrollView release];
    
    [mainButtons release];
    
    [unlockGroup release];
    [unlockButton release];
    [unlockLabel release];
    [unlockErrorLabel release];
    
    [playNowGroup release];
    [scoreButton1 release];
    [scoreButton2 release];
    [scoreButton3 release];
    [scoreButton4 release];
    [scoreButton5 release];
    [scoreLabel1 release];
    [scoreLabel2 release];
    [scoreLabel3 release];
    [scoreLabel4 release];
    [scoreLabel5 release];
    
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
