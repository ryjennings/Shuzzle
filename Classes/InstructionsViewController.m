//
//  InstructionsViewController.m
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import "InstructionsViewController.h"
#import "FormicAppDelegate.h"

@implementation InstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	scrollView.contentSize = CGSizeMake(1920.0, 320.0);
	
	UIImageView *pg1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions-pg1"]] autorelease];
	UIImageView *pg2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions-pg2"]] autorelease];
	UIImageView *pg3 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions-pg3"]] autorelease];
	UIImageView *pg4 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions-pg4"]] autorelease];
	pg1.center = CGPointMake(240.0, 160.0);
	pg2.center = CGPointMake(720.0, 160.0);
	pg3.center = CGPointMake(1200.0, 160.0);
	pg4.center = CGPointMake(1680.0, 160.0);
	
	[scrollView addSubview:pg1];
	[scrollView addSubview:pg2];
	[scrollView addSubview:pg3];
	[scrollView addSubview:pg4];

	scrollView.delegate = self;
	pgControl.currentPage = 0;
	pgControl.numberOfPages = 4;
	[pgControl addTarget:self action:@selector(pageControlDidChange:) forControlEvents:UIControlEventValueChanged];
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
	[buttonBack release];
    [super dealloc];
}

- (IBAction)onButtonBack {
	[AppDelegate playButtonSound];
	[AppDelegate returnToMainMenuViewWithoutRestartingMusic];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
	if (aScrollView.contentOffset.x == 0) pgControl.currentPage = 0;
	else if (aScrollView.contentOffset.x == 480) pgControl.currentPage = 1;
	else if (aScrollView.contentOffset.x == 960) pgControl.currentPage = 2;
	else if (aScrollView.contentOffset.x == 1440) pgControl.currentPage = 3;
}

- (void)pageControlDidChange:(id)sender 
{
    UIPageControl *control = (UIPageControl *)sender;
    if (control == pgControl) {
        [scrollView setContentOffset:CGPointMake(480.0 * control.currentPage, 0.0) animated:YES];
    }
}

@end
