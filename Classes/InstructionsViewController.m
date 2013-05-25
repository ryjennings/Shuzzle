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
	
	scrollView.contentSize = CGSizeMake(self.view.frame.size.height * 4, self.view.frame.size.width);
	
	UIImageView *pg1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions-pg1"]] autorelease];
	UIImageView *pg2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions-pg2"]] autorelease];
	UIImageView *pg3 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions-pg3"]] autorelease];
	UIImageView *pg4 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions-pg4"]] autorelease];
	pg1.center = CGPointMake(self.view.frame.size.height / 2, 160.0);
	pg2.center = CGPointMake(self.view.frame.size.height + (self.view.frame.size.height / 2), 160.0);
	pg3.center = CGPointMake((self.view.frame.size.height * 2) + (self.view.frame.size.height / 2), 160.0);
	pg4.center = CGPointMake((self.view.frame.size.height * 3) + (self.view.frame.size.height / 2), 160.0);
	
	[scrollView addSubview:pg1];
	[scrollView addSubview:pg2];
	[scrollView addSubview:pg3];
	[scrollView addSubview:pg4];

	scrollView.delegate = self;
	pgControl.currentPage = 0;
	pgControl.numberOfPages = 4;
	[pgControl addTarget:self action:@selector(pageControlDidChange:) forControlEvents:UIControlEventValueChanged];
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
