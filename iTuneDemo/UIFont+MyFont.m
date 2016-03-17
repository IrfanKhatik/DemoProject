//
//  UIFont+MyFont.m
//  iTuneDemo
//
//  Created by Netstratum on 3/16/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import "UIFont+MyFont.h"

@implementation UIFont (MyFont)
+ (UIFont *)myCustomFont{
    CGFloat fontSize = IS_IPAD ? 20.0f : 15.0f;
    NSNumber *settingSize = [[NSUserDefaults standardUserDefaults] valueForKey:FONT_SETTING];
    if (settingSize) {
        fontSize = IS_IPAD ? [settingSize doubleValue]+5 : [settingSize doubleValue];
    }
    return [UIFont fontWithName:@"Chalkboard SE" size:fontSize];
}

+ (UIFont *)myCustomdetailTextFont{
    CGFloat fontSize = IS_IPAD ? 17.0f : 13.0f;
    NSNumber *settingSize = [[NSUserDefaults standardUserDefaults] valueForKey:FONT_SETTING];
    if (settingSize) {
        fontSize = IS_IPAD ? [settingSize doubleValue] : [settingSize doubleValue]-3;
    }
    return [UIFont fontWithName:@"Chalkboard SE" size:fontSize];
}

@end
