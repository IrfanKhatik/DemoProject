//
//  UIImageView+Download.h
//  iTuneDemo
//
//  Created by Irfan Khatik on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface UIImageView (Download)
- (void)downloadImageFromImageURL:(NSURL *)imageURL withAppID:(NSString *)appID;
@end
