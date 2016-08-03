//
//  NetworkSessionManager.m
//  AnimatedGIFs
//
//  Created by Brennan Stehling on 7/14/16.
//  Copyright © 2016 SmallSharpTools. All rights reserved.
//

#import "NetworkSessionManager.h"

@implementation NetworkSessionManager

- (nullable NSURLSessionTask *)fetchImageWithURL:(nonnull NSURL *)url params:(nullable NSDictionary *)params withCompletionBlock:(void (^ __nullable)(UIImage * __nullable image, NSError * __nullable error))completionBlock {
    if (!completionBlock) {
        return nil;
    }

    NSURLSessionTask *task = [self fetchDataRequestWithURL:url params:params withCompletionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, error);
        }
        else {
            UIImage *image = [UIImage imageWithData:data];
            // return to main queue from background
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(image, nil);
            });
        }
    }];

    return task;
}

- (nullable NSURLSessionTask *)fetchDataRequestWithURL:(nonnull NSURL *)url params:(nullable NSDictionary *)params withCompletionBlock:(void (^ __nullable)(NSData * __nullable data, NSError * __nullable error))completionBlock {
    if (!completionBlock) {
        return nil;
    }

    url = [self appendQueryParameters:params toURL:url];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    request.HTTPMethod = @"GET";

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completionBlock(nil, error);
        }
        else {
            completionBlock(data, nil);
        }
    }];
    [task resume];

    return task;
}

- (nonnull NSURL *)appendQueryParameters:(nullable NSDictionary *)params toURL:(nonnull NSURL *)url {
    NSAssert(url, @"URL must not be nil");
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];

    NSMutableArray<NSURLQueryItem *> *queryItems = @[].mutableCopy;

    for (NSString *name in params) {
        NSObject *parameterValue = params[name];

        NSURLQueryItem *item = nil;

        if ([parameterValue isKindOfClass:[NSString class]]) {
            item = [[NSURLQueryItem alloc] initWithName:name value:params[name]];
        }
        else if ([parameterValue respondsToSelector:@selector(stringValue)]) {
            item = [[NSURLQueryItem alloc] initWithName:name value:[params[name] stringValue]];
        }

        if (item) {
            [queryItems addObject:item];
        }
    }

    components.queryItems = queryItems;
    
    return components.URL;
}

@end
