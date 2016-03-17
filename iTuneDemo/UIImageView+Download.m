//
//  UIImageView+Download.m
//  iTuneDemo
//
//  Created by Irfan Khatik on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import "UIImageView+Download.h"

@implementation UIImageView (Download)
- (void)downloadImageFromImageURL:(NSURL *)imageURL withAppID:(NSString *)appID {
    NSString *imageName = [NSString stringWithFormat:@"%@.png",appID];
    
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingString:imageName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:tmpPath]) {
        self.image = [UIImage imageWithContentsOfFile:tmpPath];
        self.layer.cornerRadius = 24.0f;
        self.layer.borderWidth = 0.3f;
        self.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.layer.masksToBounds = true;
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imageData) {
                [imageData writeToFile:tmpPath atomically:YES];
                self.image = [UIImage imageWithData:imageData];
            } else {
                self.image = [UIImage imageNamed:@"Swift"];
            }
            self.layer.cornerRadius = 24.0f;
            self.layer.borderWidth = 0.3f;
            self.layer.borderColor = UIColor.lightGrayColor.CGColor;
            self.layer.masksToBounds = true;
        });
    });
}
@end
