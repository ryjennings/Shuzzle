//
//  MainMenuViewController.m
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import "MainMenuViewController.h"
#import "FormicAppDelegate.h"

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if ([AppDelegate controlScheme] == FGControlSchemeTiltMode) {
		buttonControlTilt.selected = YES;
	} else {
		buttonControlTouch.selected = YES;
	}
#ifdef DEMO_MODE
	if ([AppDelegate demoStatus] == FGDemoStatusUnknown) {
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		// There's no saved value for "demostatus" so this is a new install
		[prefs setObject:[NSNumber numberWithInt:FGDemoStatusActive] forKey:@"demostatus"];
		[AppDelegate setLoadedDemoSeconds:DEMO_SECONDS];
		[AppDelegate setDemoStatus:FGDemoStatusActive];
		demoIntroAlert = [[[UIAlertView alloc] 
						   initWithTitle:@"Shuzzle Lite" 
						   message:@"Welcome to Shuzzle Lite! You will have 10 minutes to play and explore the entire app. Have a great time!" 
						   delegate:self 
						   cancelButtonTitle:@"Get Started" 
						   otherButtonTitles:nil] autorelease];
		[demoIntroAlert show];
	}
#endif
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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
	[buttonControlTouch release];
	[buttonControlTilt release];
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
	if (alertView == demoScoresAlert) {
		if (buttonIndex == 0) {
			[[UIApplication sharedApplication] 
			 openURL:[NSURL URLWithString:@"http://itunes.com/apps/shuzzle"]];
		}
	} else if (alertView == demoIntroAlert) {
#ifdef DEMO_MODE
		[AppDelegate showDemoCountdown];
#endif
	} else {
		NSUserDefaults *prefs = nil;	
		prefs = [NSUserDefaults standardUserDefaults];
		switch (buttonIndex) {
			case 0:
				if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"mode"] intValue] == 0) {
					buttonControlTouch.selected = YES;
					buttonControlTilt.selected = NO;
					[AppDelegate setControlScheme:FGControlSchemeTouchMode];
				} else {
					buttonControlTouch.selected = NO;
					buttonControlTilt.selected = YES;
					[AppDelegate setControlScheme:FGControlSchemeTiltMode];
				}
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
}

- (IBAction)onButtonHighscores
{
#ifdef DEMO_MODE
	demoScoresAlert = [[[UIAlertView alloc] initWithTitle:@"Shuzzle Lite" 
								 message:@"Leader boards and achievements are not available in Shuzzle Lite." 
								delegate:self 
					   cancelButtonTitle:@"Buy $0.99" 
					   otherButtonTitles:@"Cancel", nil] autorelease];
	[demoScoresAlert show];
#else
	[AppDelegate displayLeaderBoard];
	[AppDelegate showLoadingViewWithLabel:@"Accessing Game Center"];
#endif
}

- (IBAction)onButtonInstructions {
	[AppDelegate playButtonSound];
	[AppDelegate showInstructionsView];
}

- (IBAction)onButtonSettings {
	[AppDelegate playButtonSound];
	[AppDelegate showSettingsView];
}

- (IBAction)onButtonControls:(id)sender
{
	UIButton *btn = (UIButton *)sender;
	
	[AppDelegate playButtonSound];
	
	if (btn == buttonControlTouch) {
		buttonControlTouch.selected = YES;
		buttonControlTilt.selected = NO;
		
		[AppDelegate setControlScheme:FGControlSchemeTouchMode];
	}
	else {
		buttonControlTouch.selected = NO;
		buttonControlTilt.selected = YES;
		[AppDelegate setControlScheme:FGControlSchemeTiltMode];
	}
}

@end
