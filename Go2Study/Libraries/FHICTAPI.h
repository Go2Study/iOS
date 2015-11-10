//
//  FHICTAPI.h
//  Go2Study
//
//  Created by Ashish Kumar on 10/11/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHICTAPI : NSObject

#pragma mark - Access Token

- (void)saveAccessToken:(NSURL *)url;
- (BOOL)accessTokenExists;

#pragma mark - Public API: Users

- (void)getUsers;
- (void)getUserPCN:(NSString *)pcn;

@end
