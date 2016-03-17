//
//  DatabaseManager.h
//  iTuneDemo
//
//  Created by Irfan Khatik on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DatabaseManager : NSObject

- (nullable instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)sharedManager;

- (void)saveResponse:(nonnull NSArray *)responseList;

- (nullable NSArray<NSManagedObject *> *)getAppList;

- (void)deleteAppDetail:(nonnull NSManagedObject *)appDetail;

- (nullable NSArray *)filterByArtistName:(nonnull NSString *)artistName;

- (void)saveContext;

@end
