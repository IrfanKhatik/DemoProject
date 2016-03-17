//
//  LoadingOverlayView.m
//  iTuneDemo
//
//  Created by Netstratum on 3/15/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import "LoadingOverlayView.h"

@implementation LoadingOverlayView
- (instancetype)init:(UIView *)superView {
    self = [super init];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [superView addSubview:self];
    
    [self setupLoadingOverlay];
    NSDictionary *views = @{@"overlay":self};
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[overlay]|" options:0 metrics:nil views:views]];
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlay]|" options:0 metrics:nil views:views]];
    
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    }];
    
    return self;
}

- (void)setupLoadingOverlay {
    self.backgroundColor = [[UIColor alloc] initWithWhite:0.0f alpha:0.8f];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.translatesAutoresizingMaskIntoConstraints = FALSE;
    [self addSubview:indicator];
   
    [self addConstraint:[NSLayoutConstraint constraintWithItem:indicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:indicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    [indicator startAnimating];
}

-(void)removeLoadingOverlay {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
