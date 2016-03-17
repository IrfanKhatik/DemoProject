//
//  Utilities.m
//  iTuneDemo
//
//  Created by Irfan Khatik on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (nonnull NSError *)nullError{
    NSError *nullError = [NSError errorWithDomain:ErrorDomain code:404 userInfo:@{@"localizedDescription":@"App list unavailable"}];
    return nullError;
}

@end
