//
//  SYBusnessInfosModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/26.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBusnessInfosModel.h"

@implementation SYBusnessInfosModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.productID = value;
    }
    if ([key isEqualToString:@"long"]) {
        self.jingdu = value;
    }
    if ([key isEqualToString:@"lat"]) {
        self.weidu = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)busnessInfosWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
