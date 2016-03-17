//
//  AppDetailViewController.m
//  iTuneDemo
//
//  Created by Netstratum on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import "AppDetailViewController.h"
#import <Social/Social.h>
#import "ImageDetailCell.h"

@interface AppDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblDetail;
@end

@implementation AppDetailViewController
{
    BOOL isSelected;
    UITapGestureRecognizer *tapGuesture;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    isSelected = NO;
    
    self.navigationItem.title = [_appDetail valueForKey:@"appname"];
    
    _tblDetail.estimatedRowHeight = IS_IPAD ? 250.0f : 150.0f;
    _tblDetail.rowHeight = UITableViewAutomaticDimension;
    
    tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tapGuesture.numberOfTapsRequired = 1;
    tapGuesture.numberOfTouchesRequired = 1;
    
    [_tblDetail reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasComeInForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleImageTap:(UITapGestureRecognizer *)sender{
    isSelected = !isSelected;
    [_tblDetail reloadData];
}

- (void)appHasComeInForeground {
    [_tblDetail reloadData];
}

- (IBAction)doneClicked:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

- (IBAction)actionClicked:(UIBarButtonItem *)sender{
    
    UIAlertController *actionsheetController = [UIAlertController alertControllerWithTitle:[_appDetail valueForKey:@"appname"]
                                                                                   message:@"What do you want to do?"
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [actionsheetController addAction:cancelAction];
    
    UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:@"Share on Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *twSLComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [twSLComposeViewController setInitialText:APP_NAME];
            if ([NSURL URLWithString:[_appDetail valueForKey:@"appurl"]]) {
                [twSLComposeViewController addURL:[NSURL URLWithString:[_appDetail valueForKey:@"appurl"]]];
            }
            
            [self presentViewController:twSLComposeViewController animated:YES completion:nil];
            
            twSLComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
                switch(result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"facebook: CANCELLED");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"facebook: SHARED");
                        break;
                }
            };
        }
        else {
            NSString *message = @"Sorry, we're unable to find a Twitter account on your device."
                                "\nPlease setup an account in your devices settings and try again.";
            UIAlertController *failedController = [UIAlertController alertControllerWithTitle:@"Twitter unavailable"
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [failedController addAction:cancelAction];
           [self presentViewController:failedController animated:YES completion:nil];
        }
    }];
    
    [actionsheetController addAction:twitterAction];
    
    UIAlertAction *facebookAction = [UIAlertAction actionWithTitle:@"Share on Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *fbSLComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [fbSLComposeViewController setInitialText:APP_NAME];
            if ([NSURL URLWithString:[_appDetail valueForKey:@"appurl"]]) {
                [fbSLComposeViewController addURL:[NSURL URLWithString:[_appDetail valueForKey:@"appurl"]]];
            }
            [self presentViewController:fbSLComposeViewController animated:YES completion:nil];
            
            fbSLComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
                switch(result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"facebook: CANCELLED");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"facebook: SHARED");
                        break;
                }
            };
        }
        else {
            NSString *message = @"Sorry, we're unable to find a Facebook account on your device."
                                "\nPlease setup an account in your devices settings and try again.";
            UIAlertController *failedController = [UIAlertController alertControllerWithTitle:@"Facebook unavailable"
                                                                                      message:message
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [failedController addAction:cancelAction];
            [self presentViewController:failedController animated:YES completion:nil];
        }
    }];
    [actionsheetController addAction:facebookAction];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete App" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[DatabaseManager sharedManager] deleteAppDetail:_appDetail];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [_delegate updateAppList];
        }];
    }];
    [actionsheetController addAction:deleteAction];
    
    
    //Present the AlertController
    if (IS_IPAD) {
        [actionsheetController setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [actionsheetController popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.barButtonItem = sender;
        [self presentViewController:actionsheetController animated:YES completion:nil];
    } else {
        [self presentViewController:actionsheetController animated:YES completion:nil];
    }

}

#pragma mark - UITableView Delegate Method
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isSelected) {
        return 70.0f;
    } else {
        return IS_IPAD ? 250.0f : 150.0f;
    }
}

#pragma mark - UITableView Datasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return isSelected ? 5 : 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *summaryIdentifier = @"SummaryCell";
    static NSString *imageCellIdentifier = @"ImageCell";
    UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:summaryIdentifier];
    if (defaultCell == nil) {
        defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:summaryIdentifier];
    }
    
    [defaultCell.textLabel setNumberOfLines:0];
    [defaultCell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [defaultCell.textLabel setFont:[UIFont myCustomFont]];
    [defaultCell.textLabel setTextAlignment:NSTextAlignmentJustified];
    [defaultCell.detailTextLabel setFont:[UIFont myCustomdetailTextFont]];
    
    if (isSelected) {
        switch (indexPath.row) {
            case 0:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"appsummary"]];
                [defaultCell.detailTextLabel setText:@"Summary"];
                return defaultCell;
            }
                break;
            case 1:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"appartist"]];
                [defaultCell.detailTextLabel setText:@"Developer"];
                return defaultCell;
            }
                break;
            case 2:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"appcategory"]];
                [defaultCell.detailTextLabel setText:@"Category"];
                return defaultCell;
            }
                break;
            case 3:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"apprights"]];
                [defaultCell.detailTextLabel setText:@"Rights"];
                return defaultCell;
            }
                break;
            case 4:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"appreleasedate"]];
                [defaultCell.detailTextLabel setText:@"Release date"];
                return defaultCell;
            }
                break;
            default:
                return defaultCell;
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                ImageDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
                [cell.imgAppIcon setUserInteractionEnabled:YES];
                [cell.imgAppIcon addGestureRecognizer:tapGuesture];
                NSString *imgURL = [_appDetail valueForKey:@"appimage"];
                NSURL *url = [NSURL URLWithString:imgURL];
                
                if (url) {
                    NSString *appId = [_appDetail valueForKey:@"appid"];
                    [cell.imgAppIcon downloadImageFromImageURL:url withAppID:appId];
                } else {
                    [cell.imgAppIcon setImage:[UIImage imageNamed:@"Swift"]];
                    cell.imgAppIcon.layer.cornerRadius = 24.0f;
                    cell.imgAppIcon.layer.borderWidth = 0.3f;
                    cell.imgAppIcon.layer.borderColor = UIColor.lightGrayColor.CGColor;
                    cell.imgAppIcon.layer.masksToBounds = true;
                }
                return cell;
            }
                break;
            case 1:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"appsummary"]];
                [defaultCell.detailTextLabel setText:@"Summary"];
                return defaultCell;
            }
                break;
            case 2:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"appartist"]];
                [defaultCell.detailTextLabel setText:@"Developer"];
                return defaultCell;
            }
                break;
            case 3:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"appcategory"]];
                [defaultCell.detailTextLabel setText:@"Category"];
                return defaultCell;
            }
                break;
            case 4:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"apprights"]];
                [defaultCell.detailTextLabel setText:@"Rights"];
                return defaultCell;
            }
                break;
            case 5:{
                [defaultCell.textLabel setText:[_appDetail valueForKey:@"appreleasedate"]];
                [defaultCell.detailTextLabel setText:@"Release date"];
                return defaultCell;
            }
                break;
            default:
                return defaultCell;
                break;
        }
    }
}

@end
