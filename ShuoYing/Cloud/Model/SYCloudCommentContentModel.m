//
//  SYCloudCommentContentModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/7/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYCloudCommentContentModel.h"

@implementation SYCloudCommentContentModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.ID = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)commentContenWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
