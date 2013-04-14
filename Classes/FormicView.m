//
//  FormicView.m
//  Formic
//
//  Created by Austin Evers on 11/15/2009.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import "FormicView.h"
#import "FormicAppDelegate.h"

CGRect CGRectMakeWithCenter (CGPoint center, CGFloat diameter)
{
	return CGRectMake (center.y - diameter / 2, center.x - diameter / 2, diameter, diameter);
}

CGPoint CGPointMakeFromRect (CGRect rect)
{
	return CGPointMake (rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
}

@implementation FormicView

- (void)viewDidLoad
{
	CGPoint		center, point;
	CGFloat		degree = 0;
	
	// init the rectangles
	center = self.center;
	mCenterRect = CGRectMakeWithCenter (center, RADIUS - 4);
	for (int i = 0; i < GAME_CIRCLES; i++)
	{
		point.x = floor(center.x + cos(degree) * RADIUS)+0.5;
		point.y = floor(center.y - sin(degree) * RADIUS)+0.5;
		mPieRect[i] = CGRectMakeWithCenter (point, RADIUS - 4);
		degree += PI / 3.0;
	}

	// init the gradient
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB ();
	CGFloat colors[] =
	{
		32.0 / 255.0, 32.0 / 265.0, 32.0 / 255.0, 1.0,
		64.0 / 255.0, 64.0 / 255.0, 64.0 / 255.0, 1.0
	};
	mGradient = CGGradientCreateWithColorComponents (rgb, colors, NULL, 2);
	CGColorSpaceRelease (rgb);	
	
	
}

- (CGPoint)centerForCircle:(int)circle
{
	return CGPointMakeFromRect (mPieRect[circle]);
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef	context;
	CGPoint			start, end;
	
	// Drawing the background gradient
	context = UIGraphicsGetCurrentContext ();
	start = [self frame].origin;
	end = start;
	end.y += [self frame].size.height;
	CGContextDrawLinearGradient (context, mGradient, start, end, 0);
	
	// drawing the middle circle
	CGContextFillEllipseInRect (context, mCenterRect);
	
	// drawing the outer circles
	for (int i = 0; i < GAME_CIRCLES; i++)
		CGContextFillEllipseInRect (context, mPieRect[i]);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint		touched;
	
	// Find position of the touch
	touched = [[touches anyObject] locationInView:self];
	
	// Find touch in center rectangle
	if ([self intersectsWithCenter:touched]) {
		if ([AppDelegate advancedPieceOn] && [[AppDelegate game] gameLevel] != FGGameLevelBlitz) {
			[[AppDelegate game] loseLife];
		}
	}
	
	// find touch in outer rectangles
	else if ([AppDelegate controlScheme] == FGControlSchemeTouchMode && [[AppDelegate game] mState] == FGGameStateRunning) {
		[self intersectsWithCircle:touched];
	}
}

- (BOOL)intersectsWithCircle:(CGPoint)pt {
	for (int i = 0; i < GAME_CIRCLES; i++)
		if (CGRectContainsPoint (mPieRect[i], pt)) {
			BOOL isGood = [[AppDelegate game] moveCenterToCircle:i];
			if (!isGood && [[AppDelegate game] mState] == FGGameStateRunning) {
				[AppDelegate doVibration];
				[AppDelegate playErrorSound];
			}
			return YES;
		}	
	
	return NO;			
}

- (BOOL)intersectsWithCenter:(CGPoint)pt {
	if (CGRectContainsPoint (mCenterRect, pt)) {
		return YES;		
	}
	return NO;
}

- (void)dealloc
{
	CGGradientRelease (mGradient);
	[super dealloc];
}

@end
