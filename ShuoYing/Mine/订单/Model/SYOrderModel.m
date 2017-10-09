//
//  SYOrderModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYOrderModel.h"
#import "SYProductModel.h"

@implementation SYOrderModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.orderId = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithDictionary:dic];
        if ([mudic objectForKey:@"product"] && [(NSArray *)[mudic objectForKey:@"product"] count] > 0) {
            NSMutableArray *proArr = [NSMutableArray arrayWithCapacity:0];
            NSArray *product = [mudic objectForKey:@"product"];
            for (NSDictionary *proDic in product) {
                SYProductModel *pro = [SYProductModel productWithDictionary:proDic];
                [proArr addObject:pro];
            }
            [mudic setObject:proArr forKey:@"product"];
        }
        
        [self setValuesForKeysWithDictionary:mudic];
    }
    return self;
}

+ (instancetype)orderWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
