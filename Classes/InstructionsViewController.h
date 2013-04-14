//
//  InstructionsViewController.h
//  Shuzzle
//
//  Created by Frank Jiang on 2/2/10.
//  Copyright 2010 Xisen Science and Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionsViewController : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UIButton *buttonBack;
	IBOutlet UIPageControl *pgControl;
	IBOutlet UIScrollView *scrollView;
}

- (IBAction)onButtonBack;
- (void)pageControlDidChange:(id)sender;

@end
