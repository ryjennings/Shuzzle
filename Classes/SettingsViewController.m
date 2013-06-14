//
//  SettingsViewController.m
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "FormicAppDelegate.h"
#import "InAppPurchaseManager.h"

@implementation SettingsViewController

@synthesize settingsTable,buttonBack;
@synthesize switchMusic, switchEffects, switchVibrate, switchCB, switchAdvanced, volumeSlider;
@synthesize volumeCell, musicCell, itunesCell, effectsCell, vibrateCell, colorBlindnessCell, advancedCell;
@synthesize headerOneView, headerTwoView, restoreCell;

- (void)viewDidLoad
{
	switchMusic.on = ![AppDelegate musicOff];
	switchEffects.on = ![AppDelegate effectsOff];
	switchVibrate.on = ![AppDelegate vibrateOff];
	switchCB.on = [AppDelegate colorBlindnessOn];
	switchAdvanced.on = [AppDelegate advancedPieceOn];
	volumeSlider.value = [AppDelegate volume]*100.0f;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	self.settingsTable = nil;
	self.buttonBack = nil;
	self.switchMusic = nil;
	self.switchEffects = nil;
	self.switchVibrate = nil;
	self.switchCB = nil;
	self.switchAdvanced = nil;
	self.volumeCell = nil;
	self.restoreCell = nil;
	self.volumeSlider = nil;
	self.musicCell = nil;
	self.itunesCell = nil;
	self.effectsCell = nil;
	self.vibrateCell = nil;
	self.colorBlindnessCell = nil;
	self.advancedCell = nil;
	self.headerOneView = nil;
	self.headerTwoView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {	
    [super dealloc];
}

- (IBAction)onButtonBack {
	[AppDelegate playButtonSound];
	[AppDelegate returnToMainMenuViewWithoutRestartingMusic];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
	return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 5;
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section==0) return headerOneView;
	if (section==1) return headerTwoView;
	return nil;
}	


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;

	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell = volumeCell;
				break;
			case 1:
				cell = musicCell;
				break;
			case 2:
				cell = effectsCell;
				break;
			case 3:
				cell = vibrateCell;
				break;
			case 4:
				cell = itunesCell;
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
				break;				
		}
	} else if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0:
				cell = colorBlindnessCell;
				break;
			case 1:
				cell = advancedCell;
				break;
			case 2:
				cell = restoreCell;
				break;
		}
	}		
	return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0 && indexPath.row == 4) {
		[self showMediaPicker];
	}
	if (indexPath.section == 1 && indexPath.row == 2) {
		[[InAppPurchaseManager sharedInstance] restorePurchase];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0 && indexPath.row == 4) {
		[self showMediaPicker];
	}
	if (indexPath.section == 1 && indexPath.row == 2) {
		[[InAppPurchaseManager sharedInstance] restorePurchase];
	}
}

- (void)showMediaPicker
{
	[[AppDelegate musicPlayer] stop];
	MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
	picker.delegate = self;
	picker.allowsPickingMultipleItems = YES;
	picker.prompt = @"Add songs to play.";
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//	[self presentModalViewController:picker animated:YES];
    [self presentViewController:picker animated:YES completion:nil];
	[picker release];
}	

#pragma mark switch methods 

- (IBAction)onSwitch:(UISwitch*)theSwitch {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([theSwitch tag]==0) {
		[AppDelegate setMusicOff:!theSwitch.on];
		[defaults setBool:theSwitch.on forKey:@"musicOff"];
	}
	if ([theSwitch tag]==1) {
		[AppDelegate setEffectsOff:!theSwitch.on];
		[defaults setBool:theSwitch.on forKey:@"effectsOff"];
	}
	if ([theSwitch tag]==2) {
		[AppDelegate setVibrateOff:!theSwitch.on];
		[defaults setBool:theSwitch.on forKey:@"vibrateOff"];
	}
	if ([theSwitch tag]==3) {
		[AppDelegate setColorBlindnessOn:theSwitch.on];
		[defaults setBool:theSwitch.on forKey:@"cbOn"];
	}
	if ([theSwitch tag]==4) {
		[AppDelegate setAdvancedPieceOn:theSwitch.on];
		[defaults setBool:theSwitch.on forKey:@"advancedOn"];
	}
}


#pragma mark volume slider

- (IBAction)onSliderValueChanged:(UISlider *)slider {
	if ([slider value] == 1.0f) {
		[AppDelegate setVolume:0.0f];
	} else {
		[AppDelegate setVolume:[slider value]/100.0f];
	}
}

#pragma mark MPMediaPickerControllerDelegate Methods

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{	
	if ([AppDelegate musicOff] != YES) [AppDelegate setMusicOff:YES];
//	[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[AppDelegate updatePlayerQueueWithMediaCollection:mediaItemCollection];
	switchMusic.on = NO;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
//	[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

@end
