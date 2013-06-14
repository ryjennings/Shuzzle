//
//  InAppPurchaseManager.h
//  Shuzzle
//
//  Created by Ryan Jennings on 5/22/13.
//  Copyright (c) 2013 Appuous, Inc. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerCanMakePurchaseAndProductExistsNotification @"kInAppPurchaseManagerCanMakePurchaseAndProductExistsNotification"
#define kInAppPurchaseManagerCanNotMakePurchaseNotification @"kInAppPurchaseManagerCanNotMakePurchaseNotification"
#define kInAppPurchaseManagerProductDoesNotExistNotification @"kInAppPurchaseManagerProductDoesNotExistNotification"

#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"


@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    SKProduct *proUpgradeProduct;
    SKProductsRequest *checkRequest;
}

+ (id)sharedInstance;
- (void)canUnlock;
- (void)purchaseUnlock;

- (void)loadStore;
- (BOOL)canMakePurchases;

- (void)restorePurchase;

@end