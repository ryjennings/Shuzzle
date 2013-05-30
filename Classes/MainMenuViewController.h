//
//  MainMenuViewController.h
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController <UIScrollViewDelegate> {
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
    IBOutlet UIButton *scoreButton1;
    IBOutlet UILabel *scoreLabel1;
    IBOutlet UIButton *scoreButton2;
    IBOutlet UILabel *scoreLabel2;
    IBOutlet UIButton *scoreButton3;
    IBOutlet UILabel *scoreLabel3;
    IBOutlet UIButton *scoreButton4;
    IBOutlet UILabel *scoreLabel4;
    IBOutlet UIButton *scoreButton5;
    IBOutlet UILabel *scoreLabel5;
    IBOutlet UIButton *scoreButton6;
    IBOutlet UILabel *scoreLabel6;
    
    IBOutlet UIImageView *instructionsWell;
    IBOutlet UIImageView *settingsWell;
    IBOutlet UIImageView *shuzzleSmall;
    IBOutlet UIImageView *shuzzleBig;
    
    IBOutlet UIScrollView *scrollView;
    
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
