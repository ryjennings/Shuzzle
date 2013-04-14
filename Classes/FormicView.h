//
//  FormicView.h
//  Formic
//
//  Created by Austin Evers on 11/15/2009.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormicGame.h"

@interface FormicView : UIView 
{
	CGRect			mPieRect[GAME_CIRCLES];
	CGRect			mCenterRect;
	CGGradientRef	mGradient;
}

- (BOOL)intersectsWithCircle:(CGPoint)pt;
- (BOOL)intersectsWithCenter:(CGPoint)pt;
- (void)viewDidLoad;
- (CGPoint)centerForCircle:(int)circle;

@end
