//
//  FirstViewController.m
//  iTuneDemo
//
//  Created by Irfan Khatik on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import "FirstViewController.h"
#import "AppCell.h"
#import "AppDetailViewController.h"

@interface FirstViewController ()<UITableViewDataSource, UITableViewDelegate, myProtocol, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblApps;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic,strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL searchBarActive;
@end

@implementation FirstViewController
{
    NSMutableArray<NSManagedObject *> * _appList;
    NSMutableArray<NSManagedObject *> * _searchList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = APP_NAME;
    _searchList = [NSMutableArray new];
    _appList = [NSMutableArray arrayWithArray:[[DatabaseManager sharedManager] getAppList]];
    [self reloadData];
    
    [self getAppDetails];
    // Initialize the refresh control.
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor purpleColor];
    _refreshControl.tintColor = [UIColor whiteColor];
    [_refreshControl addTarget:self
                        action:@selector(getAppDetails)
              forControlEvents:UIControlEventValueChanged];
    
    [_tblApps addSubview:_refreshControl];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _appList = [NSMutableArray arrayWithArray:[[DatabaseManager sharedManager] getAppList]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UINavigationController * _Nonnull detailPageNavC = [segue destinationViewController];
    AppDetailViewController * _Nonnull detailPageVC = detailPageNavC.viewControllers.firstObject;
    if (_searchBarActive) {
        detailPageVC.appDetail = [_searchList objectAtIndex:[self.tblApps indexPathForSelectedRow].row];
    } else {
        detailPageVC.appDetail = [_appList objectAtIndex:[self.tblApps indexPathForSelectedRow].row];
    }
    
    [detailPageVC setDelegate:self];
}

- (void)getAppDetails {
    LoadingOverlayView *loadOverlay = [[LoadingOverlayView alloc] init:self.view];
    
    ServiceManager *manager = [ServiceManager sharedManager];
    
    [manager getAppListWithCompletion:^(NSArray<NSManagedObject *> * _Nullable list, NSError * _Nullable responseError) {
        if (responseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadOverlay removeLoadingOverlay];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:APP_NAME
                                                                                         message:responseError.localizedDescription
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
            });
        } else {
            if (_searchBarActive) {
                [self filterContentForSearchText:_searchBar.text
                                           scope:[[_searchBar scopeButtonTitles] objectAtIndex:[_searchBar selectedScopeButtonIndex]]];
            }
            _appList = [NSMutableArray arrayWithArray:list];
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadOverlay removeLoadingOverlay];
                [self reloadData];
            });
        }
    }];
}

- (void)reloadData
{
    // Reload table data
    [_tblApps reloadData];
    
    // End the refreshing
    if (_refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        _refreshControl.attributedTitle = attributedTitle;
        
        [_refreshControl endRefreshing];
    }
}


#pragma mark - UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if ([_appList count]>0) {
        tableView.backgroundView = nil;
        return 1;
    } else {
        
        // Display a message when the table is empty
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        _messageLabel.text = @"No data is currently available.\nPlease pull down to refresh.";
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [_messageLabel sizeToFit];
        
        tableView.backgroundView = _messageLabel;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_searchBarActive) {
        return _searchList.count;
    }
    return _appList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"AppCell";
    AppCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSManagedObject *appDetail = nil;
    if (_searchBarActive) {
        appDetail = [_searchList objectAtIndex:indexPath.row];
    } else {
        appDetail = [_appList objectAtIndex:indexPath.row];
    }
    
    
    NSString *imgURL = [appDetail valueForKey:@"appimage"];
    NSURL *url = [NSURL URLWithString:imgURL];
    [cell.imgAppIcon setImage:[UIImage new]];
    if (url) {
        NSString *appId = [appDetail valueForKey:@"appid"];
        [cell.imgAppIcon downloadImageFromImageURL:url withAppID:appId];
    } else {
        [cell.imgAppIcon setImage:[UIImage imageNamed:@"Swift"]];
        cell.imgAppIcon.layer.cornerRadius = 24.0f;
        cell.imgAppIcon.layer.borderWidth = 0.3f;
        cell.imgAppIcon.layer.borderColor = UIColor.lightGrayColor.CGColor;
        cell.imgAppIcon.layer.masksToBounds = true;
    }
    
    NSString *appName = [appDetail valueForKey:@"appname"];
    [cell.lblAppName setText:appName];
    [cell.lblAppName setFont:[UIFont myCustomFont]];
    NSString *appSummary = [appDetail valueForKey:@"appsummary"];
    [cell.lblAppSummary setText:appSummary];
    [cell.lblAppName setFont:[UIFont myCustomdetailTextFont]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSManagedObject *appDetail = nil;
    if (_searchBarActive) {
        appDetail = [_searchList objectAtIndex:indexPath.row];
        [_searchList removeObject:appDetail];
        [_appList removeObject:appDetail];
        if (_searchList.count == 0) {
            [self reloadData];
        } else {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        appDetail = [_appList objectAtIndex:indexPath.row];
        [_appList removeObjectAtIndex:indexPath.row];
        
        if (_appList.count == 0) {
            [self reloadData];
        } else {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    [[DatabaseManager sharedManager] deleteAppDetail:appDetail];
    
    
}

#pragma mark - UITableView Delegate Methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return IS_IPAD? 201.0f : 121.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:SegueIdentifier sender:self];
}

#pragma mark - My Custom Protocol
-(void)updateAppList{
    if (_searchBarActive) {
        [[DatabaseManager sharedManager] deleteAppDetail:[_searchList objectAtIndex:[_tblApps indexPathForSelectedRow].row]];
        [_searchList removeObjectAtIndex:[self.tblApps indexPathForSelectedRow].row];
        [_appList removeObjectAtIndex:[self.tblApps indexPathForSelectedRow].row];
        if (_searchList.count == 0) {
            [self reloadData];
        } else {
            [_tblApps deleteRowsAtIndexPaths:[NSArray arrayWithObject:[_tblApps indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }else {
        [[DatabaseManager sharedManager] deleteAppDetail:[_appList objectAtIndex:[_tblApps indexPathForSelectedRow].row]];
        [_appList removeObjectAtIndex:[self.tblApps indexPathForSelectedRow].row];
        if (_appList.count == 0) {
            [self reloadData];
        } else {
            [_tblApps deleteRowsAtIndexPaths:[NSArray arrayWithObject:[_tblApps indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - SeachBar Delegate Methods
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    _searchList = [NSMutableArray arrayWithArray:[[DatabaseManager sharedManager] filterByArtistName:searchText]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length>0) {
        // search and reload data source
        _searchBarActive = YES;
        [self filterContentForSearchText:searchText
                                   scope:[[self.searchBar scopeButtonTitles] objectAtIndex:[self.searchBar selectedScopeButtonIndex]]];
        [_tblApps reloadData];
    }else{
        // if text lenght == 0
        // we will consider the searchbar is not active
        _searchBarActive = NO;
        [_tblApps reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [_tblApps reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _searchBarActive = YES;
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    _searchBarActive = NO;
    [searchBar setShowsCancelButton:NO animated:YES];
}
-(void)cancelSearching{
    _searchBarActive = NO;
    [_searchBar resignFirstResponder];
    _searchBar.text  = @"";
    [_tblApps reloadData];
}

@end
