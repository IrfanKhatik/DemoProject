//
//  AppDetailViewController.h
//  iTuneDemo
//
//  Created by Netstratum on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol myProtocol <NSObject>
- (void)updateAppList;
@end
@interface AppDetailViewController : UIViewController
@property (nonatomic, weak) id <myProtocol>delegate;
@property (nonatomic, strong, nonnull) NSManagedObject *appDetail;
@end
