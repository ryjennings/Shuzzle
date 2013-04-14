//
//  SplashViewController.h
//  Shuzzle
//
//  Created by Ryan Jennings on 6/22/10.
//  Copyright 2010 Ryan Jennings. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController
{
	IBOutlet UIImageView *appuousView;
	IBOutlet UIImageView *splashTitleView;
}

- (void)showMainMenuView;

@end
