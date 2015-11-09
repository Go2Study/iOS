//
//  G2SApi.m
//  Go2Study
//
//  Created by Ashish Kumar on 03/11/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "G2SApi.h"

@implementation G2SApi

- (NSURL *)apiBaseURL {
    if (!_apiBaseURL) {
        _apiBaseURL = [[NSURL alloc] initWithString:@"http://localhost:8080/api/"];
    }
    
    return _apiBaseURL;
}

@end
