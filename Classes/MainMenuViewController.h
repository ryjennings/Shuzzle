//
//  MainMenuViewController.h
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController {
	IBOutlet UIButton *buttonPlay;
	IBOutlet UIButton *buttonHighscores;
	IBOutlet UIButton *buttonInstructions;
	IBOutlet UIButton *buttonSettings;
    IBOutlet UIImageView *timewarp;
    
    IBOutlet UIView *mainButtons;
    
    IBOutlet UIView *unlockGroup;
    IBOutlet UIButton *unlockButton;
    IBOutlet UILabel *unlockLabel;
    IBOutlet UILabel *unlockErrorLabel;
    
    IBOutlet UIView *playNowGroup;
    IBOutlet UIButton *playNowButton;
    IBOutlet UILabel *playNowLabel;
    
    IBOutlet UIImageView *instructionsWell;
    IBOutlet UIImageView *settingsWell;
    IBOutlet UIImageView *shuzzleSmall;
    IBOutlet UIImageView *shuzzleBig;
    
    int scores[5];
    int activeIndex;
}

- (IBAction)onButtonPlay;
- (IBAction)onButtonHighscores;
- (IBAction)onButtonInstructions;
- (IBAction)onButtonSettings;

- (IBAction)didTapUnlockButton:(id)sender;
- (IBAction)didTapPlayNowButton:(id)sender;

@end
