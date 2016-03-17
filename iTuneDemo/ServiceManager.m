//
//  ServiceManager.m
//  iTuneDemo
//
//  Created by Irfan Khatik on 3/14/16.
//  Copyright © 2016 BestSoft. All rights reserved.
//

#import "ServiceManager.h"

@implementation ServiceManager
static NSURLSession *session = nil;
+ (ServiceManager *)sharedManager {
    static ServiceManager *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithConfiguration];
    });
    
    return _sharedClient;
}

- (nullable instancetype)initWithConfiguration {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configuration];
    }
    
    return self;
}

- (void)getAppListWithCompletion:(nonnull CompletionBlock)completion {
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@/json", PROTOCOL, BASE_URL, PATH];
    NSURL *url = [NSURL URLWithString:urlString];
    NSTimeInterval timeout = 60;
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@",[error localizedDescription]);
            completion(nil, error);
        } else {
            NSError *parseError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            if (parseError) {
                completion(nil, parseError);
            } else {
                NSDictionary  * _Nullable feedDict = [jsonDict objectForKey:@"feed"];
                if ([feedDict isKindOfClass:[NSNull class]]) {
                    completion(nil, [Utilities nullError]);
                } else {
                    NSArray * _Nullable entryList = [feedDict objectForKey:@"entry"];
                    if ([entryList isKindOfClass:[NSNull class]]) {
                        completion(nil, [Utilities nullError]);
                    } else {
                        [[DatabaseManager sharedManager] saveResponse:entryList];
                        completion([[DatabaseManager sharedManager] getAppList], nil);
                    }
                }
            }
        }
    }] resume];
}
@end
