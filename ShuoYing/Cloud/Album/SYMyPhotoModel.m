//
//  SYMyPhotoModel.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYMyPhotoModel.h"

@implementation SYMyPhotoModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.photoID = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)photoWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
