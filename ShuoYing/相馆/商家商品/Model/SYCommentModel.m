//
//  SYCommentModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/25.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYCommentModel.h"

@implementation SYCommentModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.commentID = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)commentWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
