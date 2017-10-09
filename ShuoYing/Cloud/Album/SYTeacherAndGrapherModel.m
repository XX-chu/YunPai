//
//  SYTeacherAndGrapherModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/11.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTeacherAndGrapherModel.h"

@implementation SYTeacherAndGrapherModel

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

+ (instancetype)modelWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
