//
//  SYMessageModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMessageModel.h"

@implementation SYMessageModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.messageID = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)messageWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end