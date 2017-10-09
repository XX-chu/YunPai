//
//  QTHttpRequest.m
//  ReadingClub
//
//  Created by qtkj on 16/8/9.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import "SYHttpRequest.h"
#import <CommonCrypto/CommonDigest.h>
static SYHttpRequest *_sharedInstance = nil;

@interface SYHttpRequest()

@end

@implementation SYHttpRequest


+ (instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
//    return [[self alloc] init];
}

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (NSURLSessionTask *)sendHttpRequestWithUrlString:(NSString *)urlString
                          WithParams:(NSDictionary *)params
                            withPOST:(NSString *)POST
                          completion:(sendResponse)newBlock{
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10.f;
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/javascript", nil];
    
    NSString *str = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [sessionManager POST:str parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];

        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = (NSDictionary *)result;
            if ([resultDic objectForKey:@"error"] || [[resultDic objectForKey:@"result"] integerValue] != 1) {
                
                if ([[resultDic objectForKey:@"result"] integerValue] == 2) {
                    
                    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
                    [us setBool:NO forKey:@"LoginStatus"];
                    [us synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginOut" object:nil];
                    NSLog(@"登陆失效时不清除token，防止在没有判断token是否存在的页面发生crash");

                }
            }
            newBlock(resultDic);

        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSDictionary *temDic = @{@"resError":error};
        newBlock(temDic);

    }];
    return dataTask;
}

#pragma mark - 请求数据
- (NSURLSessionTask *)getDataWithUrl:(NSString *)url Parameter:(NSDictionary *)para ResponseObject:(void(^)(NSDictionary *responseResult))responseObject{
    NSURLSessionTask *dataTask = [self sendHttpRequestWithUrlString:url WithParams:para withPOST:@"POST" completion:^(NSDictionary *resultDic) {
        responseObject(resultDic);
    }];
    return dataTask;
}


- (void)dealloc{
    NSLog(@"HTTPRequest dealloc");
}

@end
