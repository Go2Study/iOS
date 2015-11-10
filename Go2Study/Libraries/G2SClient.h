//
//  G2SClient.h
//  Go2Study
//
//  Created by Ashish Kumar on 10/11/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@protocol G2SClientDelegate;

#pragma mark - Interface
@interface G2SClient : AFHTTPSessionManager

@property (nonatomic, strong) id<G2SClientDelegate>delegate;

+ (G2SClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;

#pragma mark Users
- (void)getUsers;
- (void)getUserForPCN:(NSString *)pcn;
- (void)postUsersWithData:(NSData *)data;
- (void)putUserWithData:(NSData *)data forPCN:(NSString *)pcn;

@end

#pragma mark - Delegate Interface
@protocol G2SClientDelegate <NSObject>

@optional
- (void)g2sClient:(G2SClient *)client didFailWithError:(NSError *)error;

#pragma mark Users
- (void)g2sClient:(G2SClient *)client didGetUsersData:(id)data;
- (void)g2sClient:(G2SClient *)client didGetUserData:(id)data forPCN:(NSString *)pcn;
- (void)g2sClient:(G2SClient *)client didPostUsersWithResponse:(id)response;
- (void)g2sClient:(G2SClient *)client didPutUsersWithResponse:(id)response forPCN:(NSString *)pcn;

@end