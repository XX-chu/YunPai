//
//  SYPhotoStudioModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/21.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotoStudioModel.h"

@implementation SYPhotoStudioModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.photoStudioID = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)photoStudioWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
