//
//  SYShopcartShangpinModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/3.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYShopcartShangpinModel.h"

@implementation SYShopcartShangpinModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.shangpinid = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)cartShangPinWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

- (id)copyWithZone:(NSZone *)zone
{
    SYShopcartShangpinModel *shangjia = [[[self class] allocWithZone:zone] init];
    shangjia.spceid = self.spceid;
    shangjia.product = self.product;
    shangjia.shangpinid = self.shangpinid;
    shangjia.fee = self.fee;
    shangjia.line = self.line;
    shangjia.num = self.num;
    shangjia.money = self.money;
    shangjia.state = self.state;
    shangjia.spce = self.spce;
    shangjia.title = self.title;
    shangjia.img_200 = self.img_200;
    shangjia.isSelected = self.isSelected;
    shangjia.upimg = self.upimg;
    shangjia.c_img = self.c_img;
    return shangjia;
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
    SYShopcartShangpinModel *shangjia = [[[self class] allocWithZone:zone] init];
    shangjia.spceid = self.spceid;
    shangjia.product = self.product;
    shangjia.shangpinid = self.shangpinid;
    shangjia.fee = self.fee;
    shangjia.line = self.line;
    shangjia.num = self.num;
    shangjia.money = self.money;
    shangjia.state = self.state;
    shangjia.spce = self.spce;
    shangjia.title = self.title;
    shangjia.img_200 = self.img_200;
    shangjia.isSelected = self.isSelected;
    shangjia.upimg = self.upimg;
    shangjia.c_img = self.c_img;
    return shangjia;
}

@end
