//
//  ServiceManager.h
//  iTuneDemo
//
//  Created by Irfan Khatik on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(NSArray<NSManagedObject *> * _Nullable list,  NSError  * _Nullable responseError);

@interface ServiceManager : NSObject

- (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)sharedManager;

- (void)getAppListWithCompletion:(nonnull CompletionBlock)completion;

@end
