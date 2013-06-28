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
    
    pg1.frame = CGRectMake(0.0, 0.0, self.view.frame.size.height, self.view.frame.size.width);
    pg2.frame = CGRectOffset(pg1.frame, self.view.frame.size.height, 0.0);
    pg3.frame = CGRectOffset(pg1.frame, self.view.frame.size.height * 2, 0.0);
    pg4.frame = CGRectOffset(pg1.frame, self.view.frame.size.height * 3, 0.0);
    
    pg1.contentMode = UIViewContentModeScaleAspectFill;
    pg2.contentMode = UIViewContentModeScaleAspectFill;
    pg3.contentMode = UIViewContentModeScaleAspectFill;
    pg4.contentMode = UIViewContentModeScaleAspectFill;
    
    pg1.clipsToBounds = YES;
    pg2.clipsToBounds = YES;
    pg3.clipsToBounds = YES;
    pg4.clipsToBounds = YES;
    
	[scrollView addSubview:pg1];
	[scrollView addSubview:pg2];
	[scrollView addSubview:pg3];
	[scrollView addSubview:pg4];
    
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
    CGFloat contentSizeWidth = aScrollView.contentSize.width / 4;    
	if (aScrollView.contentOffset.x == 0) pgControl.currentPage = 0;
	else if (aScrollView.contentOffset.x == contentSizeWidth) pgControl.currentPage = 1;
	else if (aScrollView.contentOffset.x == contentSizeWidth * 2) pgControl.currentPage = 2;
	else if (aScrollView.contentOffset.x == contentSizeWidth * 3) pgControl.currentPage = 3;
}

- (void)pageControlDidChange:(id)sender 
{
    UIPageControl *control = (UIPageControl *)sender;
    if (control == pgControl) {
        [scrollView setContentOffset:CGPointMake(480.0 * control.currentPage, 0.0) animated:YES];
    }
}

@end
