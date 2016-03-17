//
//  AppGridCell.h
//  iTuneDemo
//
//  Created by Netstratum on 3/15/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppGridCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgAppIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblAppName;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@end
