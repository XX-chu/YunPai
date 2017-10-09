//
//  SYUserInfos.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYUserInfos.h"

@implementation SYUserInfos

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.userId = value;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)userinfosWithDictionry:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

// 当将一个自定义对象保存到文件的时候就会调用该方法
// 在该方法中说明如何存储自定义对象的属性
// 也就说在该方法中说清楚存储自定义对象的哪些属性
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.user forKey:@"user"];
    [aCoder encodeObject:self.head forKey:@"head"];
    [aCoder encodeObject:self.money forKey:@"money"];
    [aCoder encodeObject:self.nick forKey:@"nick"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeObject:self.info forKey:@"info"];
    [aCoder encodeObject:self.idcard forKey:@"idcard"];
    [aCoder encodeObject:self.teacher forKey:@"teacher"];
    [aCoder encodeObject:self.pho forKey:@"pho"];
    [aCoder encodeObject:self.pholv forKey:@"pholv"];
    [aCoder encodeObject:self.teacherlv forKey:@"teacherlv"];
}

// 当从文件中读取一个对象的时候就会调用该方法
// 在该方法中说明如何读取保存在文件中的对象
// 也就是说在该方法中说清楚怎么读取文件中的对象
-(id)initWithCoder:(NSCoder *)aDecoder
{
    //注意：在构造方法中需要先初始化父类的方法
    if (self=[super init]) {
        self.userId=[aDecoder decodeObjectForKey:@"userId"];
        self.user=[aDecoder decodeObjectForKey:@"user"];
        self.head=[aDecoder decodeObjectForKey:@"head"];
        self.money=[aDecoder decodeObjectForKey:@"money"];
        self.nick=[aDecoder decodeObjectForKey:@"nick"];
        self.sex=[aDecoder decodeObjectForKey:@"sex"];
        self.info=[aDecoder decodeObjectForKey:@"info"];
        self.idcard=[aDecoder decodeObjectForKey:@"idcard"];
        self.teacher=[aDecoder decodeObjectForKey:@"teacher"];
        self.pho=[aDecoder decodeObjectForKey:@"pho"];
        self.pholv = [aDecoder decodeObjectForKey:@"pholv"];
        self.teacherlv = [aDecoder decodeObjectForKey:@"teacherlv"];
    }
    return self;
}

@end
