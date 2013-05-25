//
//  SKProduct+LocalizedPrice.h
//  Shuzzle
//
//  Created by Ryan Jennings on 5/22/13.
//  Copyright (c) 2013 Appuous, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end