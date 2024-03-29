//
//  LevelSelectViewController.m
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LevelSelectViewController.h"
#import "FormicAppDelegate.h"
#import "FormicGame.h"

@implementation LevelSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"saved"])
		
		[[[[UIAlertView alloc] initWithTitle:@"Resume Game" 
									 message:@"Do you want to resume the last unfinished game?"
									delegate:self 
						   cancelButtonTitle:@"New Game" 
						   otherButtonTitles:@"Resume", nil] autorelease] show];
    [timewarp.layer addAnimation:[AppDelegate rotationAnimation] forKey:@"spin"];    
}

- (void)appDidBecomeActive:(NSNotification *)note {
    [timewarp.layer removeAllAnimations];
    [timewarp.layer addAnimation:[AppDelegate rotationAnimation] forKey:@"spin"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[AppDelegate setSavedGame:YES];
		[AppDelegate showFormicView];
	}
}

- (void)dealloc {
	[buttonEasy release];
	[buttonMedium release];
	[buttonHard release];
	[buttonExtreme release];
	[buttonBack release];
    [super dealloc];
}

- (IBAction)onButtonEasy {
	[AppDelegate playButtonSound];
	[[AppDelegate game] setLevel:0];
	[AppDelegate showFormicView];
}

- (IBAction)onButtonMedium {
	[AppDelegate playButtonSound];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Locked" message:@"This game must be unlocked to access this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [[AppDelegate game] setLevel:1];
        [AppDelegate showFormicView];
    }
}

- (IBAction)onButtonHard {
	[AppDelegate playButtonSound];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Locked" message:@"This game must be unlocked to access this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [[AppDelegate game] setLevel:2];
        [AppDelegate showFormicView];
    }
}

- (IBAction)onButtonExtreme {
	[AppDelegate playButtonSound];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Locked" message:@"This game must be unlocked to access this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [[AppDelegate game] setLevel:3];
        [AppDelegate showFormicView];
    }
}

- (IBAction)onButtonBlitz {
	[AppDelegate playButtonSound];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isGameUnlocked"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Locked" message:@"This game must be unlocked to access this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [[AppDelegate game] setLevel:4];
        [AppDelegate showFormicView];
    }
}

- (IBAction)onButtonBack {
	[AppDelegate playButtonSound];
	[AppDelegate returnToMainMenuViewWithoutRestartingMusic];
}

@end
