//
//  FHICTOAuth.h
//  Go2Study
//
//  Created by Ashish Kumar on 13/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHICTOAuth : NSObject

@property (nonatomic, strong) NSURL *oauthURL;
@property (nonatomic, strong) NSString *accessToken;

- (void)saveAccessToken:(NSURL *)url;
- (BOOL)confirmAuthStatus;
- (NSArray *)getJSONFrom:(NSString *)endpoint;

@end
