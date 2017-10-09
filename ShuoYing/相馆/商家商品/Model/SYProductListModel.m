//
//  SYProductListModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/24.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYProductListModel.h"

@implementation SYProductListModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.productID = value;
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
