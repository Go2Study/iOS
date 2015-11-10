//
//  G2SClient.m
//  Go2Study
//
//  Created by Ashish Kumar on 10/11/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "G2SClient.h"

@implementation G2SClient

#pragma mark - Constants
static NSString * const apiBaseURLString = @"http://go2study.192.168.244.26.xip.io/";

#pragma mark - G2SClient

+ (G2SClient *)sharedClient {
    static G2SClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:apiBaseURLString]];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer  = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}


#pragma mark - Users

- (void)getUsers {
    [self GET:@"users"
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if ([self.delegate respondsToSelector:@selector(g2sClient:didGetUsersData:)]) {
              [self.delegate g2sClient:self didGetUsersData:responseObject];
          }
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if ([self.delegate respondsToSelector:@selector(g2sClient:didFailWithError:)]) {
              [self.delegate g2sClient:self didFailWithError:error];
          }
      }];
}

- (void)getUserForPCN:(NSString *)pcn {
    
}

- (void)postUsersWithData:(NSData *)data {
    
}

- (void)putUserWithData:(NSData *)data forPCN:(NSString *)pcn {
    
}


@end
