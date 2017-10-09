//
//  SYAddressModel.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/28.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYAddressModel.h"

@implementation SYAddressModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.addressId = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
+ (instancetype)addressWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

// 当将一个自定义对象保存到文件的时候就会调用该方法
// 在该方法中说明如何存储自定义对象的属性
// 也就说在该方法中说清楚存储自定义对象的哪些属性
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.addressId forKey:@"addressId"];
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.zone forKey:@"zone"];
    [aCoder encodeObject:self.tel forKey:@"tel"];
}

// 当从文件中读取一个对象的时候就会调用该方法
// 在该方法中说明如何读取保存在文件中的对象
// 也就是说在该方法中说清楚怎么读取文件中的对象
-(id)initWithCoder:(NSCoder *)aDecoder
{
    //注意：在构造方法中需要先初始化父类的方法
    if (self=[super init]) {
        self.address=[aDecoder decodeObjectForKey:@"address"];
        self.addressId=[aDecoder decodeObjectForKey:@"addressId"];
        self.state=[aDecoder decodeObjectForKey:@"state"];
        self.name=[aDecoder decodeObjectForKey:@"name"];
        self.zone=[aDecoder decodeObjectForKey:@"zone"];
        self.tel=[aDecoder decodeObjectForKey:@"tel"];
    }
    return self;
}


@end
