//
//  DemoExpiredViewController.m
//  Shuzzle
//
//  Created by Ryan Jennings on 2/25/11.
//  Copyright 2011 Appuous, Inc. All rights reserved.
//

#import "DemoExpiredViewController.h"


@implementation DemoExpiredViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	alert = [[UIAlertView alloc] 
	   initWithTitle:@"Shuzzle Lite" 
	   message:@"Thanks for playing Shuzzle Lite, we hope you had fun! You have reached the demo's maximum playing time. To continue playing, please purchase Shuzzle from the App Store." 
	   delegate:self 
	   cancelButtonTitle:@"Buy $0.99" 
	   otherButtonTitles:@"Rate Shuzzle", nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[[UIApplication sharedApplication] 
	 openURL:[NSURL URLWithString:@"http://itunes.com/apps/shuzzle"]];
}

- (void)showAlert
{
	if (![alert isVisible]) {
		[alert show];
	}
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
