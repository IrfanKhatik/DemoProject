//
//  LoadingOverlayView.h
//  iTuneDemo
//
//  Created by Netstratum on 3/15/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingOverlayView : UIView
- (instancetype)init:(UIView *)superView;
-(void)removeLoadingOverlay;
@end
