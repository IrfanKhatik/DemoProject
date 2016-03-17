//
//  SecondViewController.m
//  iTuneDemo
//
//  Created by Netstratum on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import "SecondViewController.h"
#import "AppGridCell.h"
#import "AppDetailViewController.h"

@interface SecondViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, myProtocol, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collView;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL searchBarActive;
@property (nonatomic) float searchBarBoundsY;
@property (nonatomic,strong) UISearchBar *searchBar;

@end

@implementation SecondViewController
{
    NSMutableArray<NSManagedObject *> * appList;
    NSMutableArray<NSManagedObject *> *searchList;
    
    NSIndexPath * _Nonnull selectedIndex;
    BOOL isEditEnabled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = APP_NAME;
    isEditEnabled = NO;
    appList = [NSMutableArray arrayWithArray:[[DatabaseManager sharedManager] getAppList]];
    [self reloadData];
    
    [self getAppDetails];
    // Initialize the refresh control.
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor purpleColor];
    _refreshControl.tintColor = [UIColor whiteColor];
    [_refreshControl addTarget:self
                        action:@selector(getAppDetails)
              forControlEvents:UIControlEventValueChanged];
    
    [_collView addSubview:_refreshControl];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self prepareUI];
    appList = [NSMutableArray arrayWithArray:[[DatabaseManager sharedManager] getAppList]];
    [_collView reloadData];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)_collView.collectionViewLayout;
    flowLayout.itemSize = IS_IPAD ? CGSizeMake(SCREEN_SIZE.width/4.2, (SCREEN_SIZE.width/4.5)+60) : CGSizeMake(SCREEN_SIZE.width/3.5, (SCREEN_SIZE.width/3.3)+37);
    [flowLayout invalidateLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UINavigationController * _Nonnull detailPageNavC = [segue destinationViewController];
    AppDetailViewController * _Nonnull detailPageVC = detailPageNavC.viewControllers.firstObject;
    if (_searchBarActive) {
        detailPageVC.appDetail = [searchList objectAtIndex:selectedIndex.item];
    }else{
        detailPageVC.appDetail = [appList objectAtIndex:selectedIndex.item];
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
            appList = [NSMutableArray arrayWithArray:list];
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
    [_collView reloadData];
    
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

- (IBAction)EditToggle:(id)sender {
    isEditEnabled = !isEditEnabled;
    [_collView reloadData];
}

- (IBAction)deleteApp:(UIButton *)sender{
    NSIndexPath *deleteIndexPth = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    NSManagedObject *deleteAppObj = nil;
    if (_searchBarActive) {
        deleteAppObj = [searchList objectAtIndex:deleteIndexPth.row];
        [searchList removeObject:deleteAppObj];
        [appList removeObject:deleteAppObj];
        if (searchList.count == 0) {
            [self reloadData];
        } else {
            [_collView deleteItemsAtIndexPaths:[NSArray arrayWithObject:deleteIndexPth]];
            [_collView reloadData];
        }
    }else {
        deleteAppObj = [appList objectAtIndex:deleteIndexPth.row];
        [appList removeObject:deleteAppObj];
        if (appList.count == 0) {
            [self reloadData];
        } else {
            [_collView deleteItemsAtIndexPaths:[NSArray arrayWithObject:deleteIndexPth]];
            [_collView reloadData];
        }
    }
    [[DatabaseManager sharedManager] deleteAppDetail:deleteAppObj];
    
}

#pragma mark - UICollectionView Datasource Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    // Return the number of sections.
    if ([appList count]>0) {
        collectionView.backgroundView = nil;
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
        
        collectionView.backgroundView = _messageLabel;
    }
    
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_searchBarActive) {
        return searchList.count;
    }
    return appList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AppGridCellIdentity";
    AppGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSManagedObject *appDetail = nil;
    if (_searchBarActive) {
        appDetail = [searchList objectAtIndex:indexPath.row];
    } else {
        appDetail = [appList objectAtIndex:indexPath.row];
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
    [cell.lblAppName setNumberOfLines:0];
    [cell.lblAppName setLineBreakMode:NSLineBreakByTruncatingTail];
    [cell.lblAppName setTextAlignment:NSTextAlignmentJustified];
    if (isEditEnabled) {
        [cell.btnSelect setHidden:NO];
        [cell.btnSelect setTag:indexPath.item];
    } else {
        [cell.btnSelect setHidden:YES];
    }

    return cell;
}

#pragma mark - UICollectioView Delegate Method

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndex = indexPath;
    [self performSegueWithIdentifier:SegueIdentifier sender:self];
}

#pragma mark - UICollectioView FlowLayout Method
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return IS_IPAD ? CGSizeMake(SCREEN_SIZE.width/4.2, (SCREEN_SIZE.width/4.5)+60) : CGSizeMake(SCREEN_SIZE.width/3.5, (SCREEN_SIZE.width/3.3)+37);
}

#pragma mark - My Custom Protocol
-(void)updateAppList{
    NSManagedObject *deleteAppObj = nil;
    if (_searchBarActive) {
        deleteAppObj = [searchList objectAtIndex:selectedIndex.row];
        [searchList removeObject:deleteAppObj];
        [appList removeObject:deleteAppObj];
        if (searchList.count == 0) {
            [self reloadData];
        } else {
            [_collView deleteItemsAtIndexPaths:[NSArray arrayWithObject:selectedIndex]];
            [_collView reloadData];
        }
    }else {
        deleteAppObj = [appList objectAtIndex:selectedIndex.row];
        [appList removeObject:deleteAppObj];
        if (appList.count == 0) {
            [self reloadData];
        } else {
            [_collView deleteItemsAtIndexPaths:[NSArray arrayWithObject:selectedIndex]];
            [_collView reloadData];
        }
    }
    [[DatabaseManager sharedManager] deleteAppDetail:deleteAppObj];
    
}

#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
   searchList = [NSMutableArray arrayWithArray:[[DatabaseManager sharedManager] filterByArtistName:searchText]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length>0) {
        self.searchBarActive = YES;
        [self filterContentForSearchText:searchText
                                   scope:[[_searchBar scopeButtonTitles] objectAtIndex:[_searchBar selectedScopeButtonIndex]]];
        [_collView reloadData];
    }else{
        self.searchBarActive = NO;
        [_collView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [_collView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchBarActive = YES;
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    self.searchBarActive = NO;
    [self.searchBar setShowsCancelButton:NO animated:YES];
}
-(void)cancelSearching{
    isEditEnabled = NO;
    _searchBarActive = NO;
    [_searchBar resignFirstResponder];
    _searchBar.text  = @"";
    [_collView reloadData];
}

#pragma mark - prepareVC
-(void)prepareUI{
    [self addSearchBar];
}
-(void)addSearchBar{
    if (!_searchBar) {
        _searchBarBoundsY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,self.searchBarBoundsY, [UIScreen mainScreen].bounds.size.width, 44)];
        _searchBar.searchBarStyle       = UISearchBarStyleMinimal;
        _searchBar.delegate             = self;
        _searchBar.placeholder          = @"Search artist here ...";
        
        // add KVO observer.. so we will be informed when user scroll colllectionView
        [self addObservers];
    }
    
    if (![self.searchBar isDescendantOfView:self.view]) {
        [self.view addSubview:_searchBar];
    }
}

#pragma mark - observer
- (void)addObservers{
    [_collView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
- (void)removeObservers{
    [_collView removeObserver:self forKeyPath:@"contentOffset" context:Nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UICollectionView *)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"] && object == _collView ) {
        self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                          self.searchBarBoundsY + ((-1* object.contentOffset.y)-self.searchBarBoundsY),
                                          SCREEN_SIZE.width,
                                          self.searchBar.frame.size.height);
    }
}
@end
