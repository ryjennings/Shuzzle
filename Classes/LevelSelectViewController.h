//
//  LevelSelectViewController.h
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelSelectViewController : UIViewController
{
	IBOutlet UIButton *buttonEasy;
	IBOutlet UIButton *buttonMedium;
	IBOutlet UIButton *buttonHard;
	IBOutlet UIButton *buttonExtreme;
	IBOutlet UIButton *buttonBlitz;
	IBOutlet UIButton *buttonBack;
    IBOutlet UIImageView *timewarp;
}

- (IBAction)onButtonEasy;
- (IBAction)onButtonMedium;
- (IBAction)onButtonHard;
- (IBAction)onButtonExtreme;
- (IBAction)onButtonBlitz;
- (IBAction)onButtonBack;

@end
