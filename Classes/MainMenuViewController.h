//
//  MainMenuViewController.h
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController
{
	IBOutlet UIButton *buttonPlay;
	IBOutlet UIButton *buttonHighscores;
	IBOutlet UIButton *buttonInstructions;
	IBOutlet UIButton *buttonSettings;
	IBOutlet UIButton *buttonControlTouch;
	IBOutlet UIButton *buttonControlTilt;
	
	UIAlertView *demoScoresAlert;
	UIAlertView *demoIntroAlert;
}

- (IBAction)onButtonPlay;
- (IBAction)onButtonHighscores;
- (IBAction)onButtonInstructions;
- (IBAction)onButtonSettings;
- (IBAction)onButtonControls:(id)sender;

@end
