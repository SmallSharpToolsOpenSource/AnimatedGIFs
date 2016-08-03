//
//  NetworkSessionManager.h
//  AnimatedGIFs
//
//  Created by Brennan Stehling on 7/14/16.
//  Copyright © 2016 SmallSharpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NetworkSessionManager : NSObject

- (nullable NSURLSessionTask *)fetchImageWithURL:(nonnull NSURL *)url params:(nullable NSDictionary *)params withCompletionBlock:(void (^ __nullable)(UIImage * __nullable image, NSError * __nullable error))completionBlock;

- (nullable NSURLSessionTask *)fetchDataRequestWithURL:(nonnull NSURL *)url params:(nullable NSDictionary *)params withCompletionBlock:(void (^ __nullable)(NSData * __nullable data, NSError * __nullable error))completionBlock;

- (nonnull NSURL *)appendQueryParameters:(nullable NSDictionary *)params toURL:(nonnull NSURL *)url;

@end
