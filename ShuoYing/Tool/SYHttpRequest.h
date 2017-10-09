//
//  QTHttpRequest.h
//  ReadingClub
//
//  Created by qtkj on 16/8/9.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^sendResponse)(NSDictionary *resultDic);

@interface SYHttpRequest : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init;

- (NSURLSessionTask *)sendHttpRequestWithUrlString:(NSString *)urlString
                          WithParams:(NSDictionary *)params
                            withPOST:(NSString *)POST
                          completion:(sendResponse)newBlock;
#pragma mark - 请求数据
- (NSURLSessionTask *)getDataWithUrl:(NSString *)url Parameter:(NSDictionary *)para ResponseObject:(void(^)(NSDictionary *responseResult))responseObject;



@end
