//
//  DatabaseManager.m
//  iTuneDemo
//
//  Created by Irfan Khatik on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import "DatabaseManager.h"

@interface DatabaseManager ()
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
@end

@implementation DatabaseManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)sharedManager {
    
        static DatabaseManager *_sharedDBClient = nil;
        static dispatch_once_t oncePredicate;
        
        dispatch_once(&oncePredicate, ^{
            _sharedDBClient = [[self alloc] init];
        });
        
        return _sharedDBClient;
}

- (void)saveResponse:(nonnull NSArray *)responseList {
    
    //Delete existing app list to store new list
    [self deleteLastAppList];
    
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"BlockApp"];
    [fetchReq setReturnsObjectsAsFaults:NO];
    for (NSDictionary *appDict in responseList) {
        
        NSString *appId = [[[appDict objectForKey:@"id"] objectForKey:@"attributes"] objectForKey:@"im:id"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appid == %@", appId];
        [fetchReq setPredicate:predicate];
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchReq error:nil];
        
        if (![results count]) {
            NSString *appTitle = [[appDict objectForKey:@"im:name"] objectForKey:@"label"];
            NSString *appImage = [[[appDict objectForKey:@"im:image"] lastObject] objectForKey:@"label"];
            NSString *appSummary = [[appDict objectForKey:@"summary"] objectForKey:@"label"];
            NSString *appURL = [[[appDict objectForKey:@"link"] objectForKey:@"attributes"] objectForKey:@"href"];
            NSString *appArtist = [[appDict objectForKey:@"im:artist"] objectForKey:@"label"];
            NSString *appReleaseDate = [[[appDict objectForKey:@"im:releaseDate"] objectForKey:@"attributes"] objectForKey:@"label"];
            NSString *appRights = [[appDict objectForKey:@"rights"] objectForKey:@"label"];
            NSString *appCategory = [[[appDict objectForKey:@"category"] objectForKey:@"attributes"] objectForKey:@"label"];
            
            NSManagedObject *appDetail = [NSEntityDescription insertNewObjectForEntityForName:@"AppDetail" inManagedObjectContext:self.managedObjectContext];
            
            [appDetail setValue:appId forKey:@"appid"];
            [appDetail setValue:appTitle forKey:@"appname"];
            [appDetail setValue:appSummary forKey:@"appsummary"];
            [appDetail setValue:appImage forKey:@"appimage"];
            
            [appDetail setValue:appURL forKey:@"appurl"];
            [appDetail setValue:appArtist forKey:@"appartist"];
            [appDetail setValue:appReleaseDate forKey:@"appreleasedate"];
            [appDetail setValue:appRights forKey:@"apprights"];
            [appDetail setValue:appCategory forKey:@"appcategory"];
            
            [self saveContext];
        }
    }
}

- (void)deleteLastAppList{
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"AppDetail"];
    [fetchReq setReturnsObjectsAsFaults:NO];
    NSError *fetchError = nil;
    NSArray<NSManagedObject *> *appList = [[self.managedObjectContext executeFetchRequest:fetchReq error:&fetchError] mutableCopy];
    if (!fetchError) {
        for (NSManagedObject *appDetail in appList) {
            NSString *appId = [appDetail valueForKey:@"appid"];
            [self.managedObjectContext deleteObject:appDetail];
            [self removeStoredImageForApp:appId];
            [self saveContext];
        }
    } else {
        NSLog(@"Unable to delete list");
    }
}

- (void)deleteAppDetail:(nonnull NSManagedObject *)appDetail {
    NSString *appId = [appDetail valueForKey:@"appid"];
    [self.managedObjectContext deleteObject:appDetail];
    [self removeStoredImageForApp:appId];
    [self saveContext];
    
    NSManagedObject *blockApp = [NSEntityDescription insertNewObjectForEntityForName:@"BlockApp" inManagedObjectContext:self.managedObjectContext];
    [blockApp setValue:appId forKey:@"appid"];
    
    [self saveContext];
}

- (void)removeStoredImageForApp:(nonnull NSString *)appId {
    
    NSString *imageName = [NSString stringWithFormat:@"%@.png",appId];
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingString:imageName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:tmpPath]) {
        [fileManager removeItemAtPath:tmpPath error:nil];
    }
}

- (nullable NSArray <NSManagedObject *> *)getAppList {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"AppDetail"];
    [fetchReq setReturnsObjectsAsFaults:NO];
    NSError *fetchError = nil;
    NSArray<NSManagedObject *> *appList = [self.managedObjectContext executeFetchRequest:fetchReq error:&fetchError];
    if (fetchError) {
        return nil;
    }
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"appartist" ascending:YES];
    NSArray *sorted = [appList sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
    
    return sorted;
}

- (nullable NSArray *)filterByArtistName:(nonnull NSString *)artistName {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"AppDetail"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appartist contains[c] %@", artistName];
    [fetchReq setPredicate:predicate];
    [fetchReq setReturnsObjectsAsFaults:NO];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchReq error:nil];
    return results;
}

#pragma mark - Core Data Stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.BestSoft.iTuneDemo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iTuneDemo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iTuneDemo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            
        }
    }
}
@end
