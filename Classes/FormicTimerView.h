//
//  FormicTimerView.h
//  Formic
//
//  Created by Austin Evers on 11/15/2009.
//  Copyright 2010 NorthBound Media, Inc (TM). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormicGame.h"

@interface FormicTimerView : UIImageView
{
	UIImage		*mProgressImage[GAME_TIMERSTEPS];
	int			mPosition;
}

- (id)init;
- (void)setPosition:(int)position;

@end
