//
//  SYProductModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYProductModel.h"

@implementation SYProductModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.productId = value;
    }
    
    if ([key isEqualToString:@"img_200"]) {
        self.img_200 = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)productWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
