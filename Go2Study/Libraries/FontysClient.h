//
//  FontysClient.h
//  Go2Study
//
//  Created by Ashish Kumar on 10/11/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@protocol FontysClientDelegate;

#pragma mark - Interface
@interface FontysClient : AFHTTPSessionManager

@property (nonatomic, strong) id<FontysClientDelegate>delegate;

+ (FontysClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;

#pragma mark Access Token
@property (nonatomic, strong) NSURL *oauthURL;
@property (nonatomic, strong) NSURL *apiBaseURL;
@property (nonatomic, strong) NSString *accessToken;

#pragma mark Users
- (void)getUsers;
- (void)getUserForPCN:(NSString *)pcn;

#pragma mark Images
- (void)getUserImageForPCN:(NSString *)pcn;

@end

#pragma mark - Delegate Interface
@protocol FontysClientDelegate <NSObject>

@optional
- (void)fontysClient:(FontysClient *)client didFailWithError:(NSError *)error;

#pragma mark Users
- (void)fontysClient:(FontysClient *)client didGetUsersData:(id)data;
- (void)fontysClient:(FontysClient *)client didGetUserData:(id)data forPCN:(NSString *)pcn;

#pragma mark Pictures
- (void)fontysClient:(FontysClient *)client didGetUserImage:(UIImage *)image forPCN:(NSString *)pcn;

@end