//
//  FontysClient.h
//  Go2Study
//
//  Created by Ashish Kumar on 10/11/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@protocol FontysClientDelegate;


@interface FontysClient : AFHTTPSessionManager

@property (nonatomic, strong) id<FontysClientDelegate>delegate;

+ (FontysClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;

#pragma mark - Users
- (void)getUsers;
- (void)getUserForPCN:(NSString *)pcn;

@end


@protocol FontysClientDelegate <NSObject>

@optional
- (void)fontysClient:(FontysClient *)client didGetData:(id)data;
- (void)fontysClient:(FontysClient *)client didFailWithError:(NSError *)error;
- (void)fontysClient:(FontysClient *)client didGetUsersData:(id)data;
- (void)fontysClient:(FontysClient *)client didGetUserData:(id)data forPCN:(NSString *)pcn;

@end