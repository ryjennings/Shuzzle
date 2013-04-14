//
//  SplashViewController.m
//  Shuzzle
//
//  Created by Ryan Jennings on 6/22/10.
//  Copyright 2010 Ryan Jennings. All rights reserved.
//

#import "SplashViewController.h"
#import "FormicAppDelegate.h"

@implementation SplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:1.0];
	appuousView.alpha = 0;
	[UIView commitAnimations];

	[self performSelector:@selector(showMainMenuView) withObject:nil afterDelay:3.0];
}

- (void)showMainMenuView
{
	[AppDelegate showMainMenuView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    [super dealloc];
}

@end
