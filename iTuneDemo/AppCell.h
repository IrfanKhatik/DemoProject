//
//  AppCell.h
//  iTuneDemo
//
//  Created by Irfan Khatik on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgAppIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblAppName;
@property (weak, nonatomic) IBOutlet UILabel *lblAppSummary;
@end
