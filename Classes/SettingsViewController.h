//
//  SettingsViewController.h
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate, MPMediaPickerControllerDelegate>
{
	IBOutlet UIButton *buttonBack;
	IBOutlet UISwitch *switchMusic;
	IBOutlet UISwitch *switchEffects;
	IBOutlet UISwitch *switchVibrate;
	IBOutlet UISwitch *switchCB;
	IBOutlet UISwitch *switchAdvanced;
	IBOutlet UISlider *volumeSlider;
	
	IBOutlet UITableView *settingsTable;
	
	IBOutlet UITableViewCell *volumeCell;
	IBOutlet UITableViewCell *musicCell;
	IBOutlet UITableViewCell *itunesCell;
	IBOutlet UITableViewCell *effectsCell;
	IBOutlet UITableViewCell *vibrateCell;
	IBOutlet UITableViewCell *restoreCell;
	IBOutlet UITableViewCell *colorBlindnessCell;
	IBOutlet UITableViewCell *advancedCell;
	
	IBOutlet UIView *headerOneView;
	IBOutlet UIView *headerTwoView;
}

@property (nonatomic, retain) UITableView *settingsTable;
@property (nonatomic, retain) UIButton *buttonBack;

@property (nonatomic, retain) UITableViewCell *volumeCell;
@property (nonatomic, retain) UITableViewCell *musicCell;
@property (nonatomic, retain) UITableViewCell *itunesCell;
@property (nonatomic, retain) UITableViewCell *effectsCell;
@property (nonatomic, retain) UITableViewCell *vibrateCell;
@property (nonatomic, retain) UITableViewCell *restoreCell;
@property (nonatomic, retain) UITableViewCell *colorBlindnessCell;
@property (nonatomic, retain) UITableViewCell *advancedCell;

@property (nonatomic, retain) UISlider *volumeSlider;

@property (nonatomic, retain) UISwitch *switchMusic;
@property (nonatomic, retain) UISwitch *switchEffects;
@property (nonatomic, retain) UISwitch *switchVibrate;
@property (nonatomic, retain) UISwitch *switchCB;
@property (nonatomic, retain) UISwitch *switchAdvanced;

@property (nonatomic, retain) UIView *headerOneView;
@property (nonatomic, retain) UIView *headerTwoView;

- (IBAction)onButtonBack;
- (IBAction)onSwitch:(UISwitch*)theSwitch;
- (IBAction)onSliderValueChanged:(UISlider*)slider;
- (void)showMediaPicker;

@end
