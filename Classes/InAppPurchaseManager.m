//
//  InAppPurchaseManager.m
//  Shuzzle
//
//  Created by Ryan Jennings on 5/22/13.
//  Copyright (c) 2013 Appuous, Inc. All rights reserved.
//

#import "InAppPurchaseManager.h"

#define kInAppPurchaseUnlockedProductId @"com.appuous.shuzzle.unlocked"

@implementation InAppPurchaseManager

+ (id)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)restorePurchase {
    NSLog(@"restorePurchase 1");
    if ([self canMakePurchases]) {
        NSLog(@"restorePurchase 2");
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        NSLog(@"restorePurchase 3");
    }
    NSLog(@"restorePurchase 4");
}

- (void)canUnlock {
    checkRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kInAppPurchaseUnlockedProductId]];
    checkRequest.delegate = self;
    [checkRequest start];
}

- (void)purchaseUnlock {
    if (proUpgradeProduct) {
        SKPayment *payment = [SKPayment paymentWithProduct:proUpgradeProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    NSArray *products = response.products;
    proUpgradeProduct = [products count] == 1 ? [[products objectAtIndex:0] retain] : nil;
    
    if (proUpgradeProduct) {
        NSLog(@"Product title: %@" , proUpgradeProduct.localizedTitle);
        NSLog(@"Product description: %@" , proUpgradeProduct.localizedDescription);
        NSLog(@"Product price: %@" , proUpgradeProduct.price);
        NSLog(@"Product id: %@" , proUpgradeProduct.productIdentifier);
        if ([self canMakePurchases]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerCanMakePurchaseAndProductExistsNotification
                                                                object:self
                                                              userInfo:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerCanNotMakePurchaseNotification
                                                                object:self
                                                              userInfo:nil];
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductDoesNotExistNotification
                                                            object:self
                                                          userInfo:nil];
    }

    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    [checkRequest release];
}

#pragma mark -
#pragma mark Public methods

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
//    [self canUnlock];
}

#pragma mark -
#pragma mark Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseUnlockedProductId]) {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"unlockTransactionReceipt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kInAppPurchaseUnlockedProductId]) {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isGameUnlocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful) {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    } else {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"transaction.transactionState %d", transaction.transactionState);
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSLog(@"transaction.transactionState %d", transaction.transactionState);
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end
