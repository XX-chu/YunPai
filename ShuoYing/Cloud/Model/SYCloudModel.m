//
//  SYCloudModel.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYCloudModel.h"

@implementation SYCloudModel

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.info forKey:@"info"];
    [aCoder encodeObject:self.nick forKey:@"nick"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.imgs forKey:@"imgs"];
    [aCoder encodeObject:self.head forKey:@"head"];
    [aCoder encodeObject:self.pholv forKey:@"pholv"];
    [aCoder encodeObject:self.my forKey:@"my"];
    [aCoder encodeObject:self.agree forKey:@"agree"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.addtime forKey:@"addtime"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.reply forKey:@"reply"];
    [aCoder encodeObject:self.reward_count forKey:@"reward_count"];
    [aCoder encodeObject:self.pho forKey:@"pho"];
    [aCoder encodeObject:self.agree_count forKey:@"agree_count"];
    [aCoder encodeObject:self.reply_count forKey:@"reply_count"];
    [aCoder encodeObject:self.follow forKey:@"follow"];

}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ([self init]) {
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.info = [aDecoder decodeObjectForKey:@"info"];
        self.nick = [aDecoder decodeObjectForKey:@"nick"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.imgs = [aDecoder decodeObjectForKey:@"imgs"];
        self.head = [aDecoder decodeObjectForKey:@"head"];
        self.pholv = [aDecoder decodeObjectForKey:@"pholv"];
        self.my = [aDecoder decodeObjectForKey:@"my"];
        self.agree = [aDecoder decodeObjectForKey:@"agree"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.addtime = [aDecoder decodeObjectForKey:@"addtime"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.reply = [aDecoder decodeObjectForKey:@"reply"];
        self.reward_count = [aDecoder decodeObjectForKey:@"reward_count"];
        self.pho = [aDecoder decodeObjectForKey:@"pho"];
        self.agree_count = [aDecoder decodeObjectForKey:@"agree_count"];
        self.reply_count = [aDecoder decodeObjectForKey:@"reply_count"];
        self.follow = [aDecoder decodeObjectForKey:@"follow"];

    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.ID = value;
    }
}

- (void)setReply:(NSArray *)reply{
    _reply = reply;
}

- (void)setReply_count:(NSNumber *)reply_count{
    _reply_count = reply_count;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)cloudWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}

@end
