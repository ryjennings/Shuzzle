//
//  GameOverPopup.h
//  Shuzzle
//
//  Created by Ryan Jennings on 2/15/11.
//  Copyright 2011 Appuous, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameOverPopup : UIView
{
	UILabel *scoreLabel;
	UILabel *modeLabel;
	UIImageView *bannerView;
	UIButton *btn1;
	UIButton *btn2;
	UIButton *btn3;
	UIImageView *popupFrame;	
}

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *modeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *bannerView;
@property (nonatomic, retain) IBOutlet UIButton *btn1;
@property (nonatomic, retain) IBOutlet UIButton *btn2;
@property (nonatomic, retain) IBOutlet UIButton *btn3;
@property (nonatomic, retain) IBOutlet UIImageView *popupFrame;

@end
