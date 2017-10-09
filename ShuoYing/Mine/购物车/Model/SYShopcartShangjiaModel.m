//
//  SYShopcartShangjiaModel.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/3.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYShopcartShangjiaModel.h"
#import "SYShopcartShangpinModel.h"
@implementation SYShopcartShangjiaModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSArray *goods = [dic objectForKey:@"goods"];
        NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
        if (goods.count > 0) {
            for (NSDictionary *dic in goods) {
                NSMutableDictionary *aDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [aDic setObject:@NO forKey:@"isSelected"];
                SYShopcartShangpinModel *model = [SYShopcartShangpinModel cartShangPinWithDictionary:aDic];
                [muArr addObject:model];
            }
        }
        [muDic setObject:muArr forKey:@"goods"];
        [self setValuesForKeysWithDictionary:muDic];
    }
    return self;
}

+ (instancetype)cartShangJiaWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

- (id)copyWithZone:(NSZone *)zone
{
    SYShopcartShangjiaModel *shangjia = [[[self class] allocWithZone:zone] init];
    shangjia.pid = self.pid;
    shangjia.name = self.name;
    shangjia.goods = self.goods;
    shangjia.isSelected = self.isSelected;
    shangjia.express = self.express;
    shangjia.free = self.free;
    return shangjia;
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
    SYShopcartShangjiaModel *shangjia = [[[self class] allocWithZone:zone] init];
    shangjia.pid = self.pid;
    shangjia.name = self.name;
    shangjia.goods = self.goods;
    shangjia.isSelected = self.isSelected;
    shangjia.express = self.express;
    shangjia.free = self.free;
    return shangjia;
}

@end
