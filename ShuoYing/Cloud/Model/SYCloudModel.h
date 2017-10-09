//
//  SYCloudModel.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYCloudModel : NSObject<NSCoding>

@property (nonatomic, strong) NSNumber *ID;

@property (nonatomic, copy) NSString *info;

@property (nonatomic, copy) NSString *nick;

@property (nonatomic, copy) NSString *city;

@property (nonatomic, copy) NSArray *imgs;

@property (nonatomic, copy) NSString *head;

@property (nonatomic, strong) NSNumber *pholv;

@property (nonatomic, strong) NSNumber *my;//当前是否是自己发布的

@property (nonatomic, strong) NSNumber *agree;//当前用户是否点赞

@property (nonatomic, strong) NSNumber *uid;//

@property (nonatomic, copy) NSString *addtime;//发布时间

@property (nonatomic, copy) NSArray *type;//标记

@property (nonatomic, copy) NSArray *reply;//当前云拍的评论及回复

@property (nonatomic, strong) NSNumber *reward_count;//打赏记录数量

@property (nonatomic, strong) NSNumber *pho;//sheyingshi

@property (nonatomic, strong) NSNumber *agree_count;//当前点赞的统计

@property (nonatomic, strong) NSNumber *reply_count;//当前评论与回复的统计数量

@property (nonatomic, strong) NSNumber *follow;//当前用户是否关注


- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (instancetype)cloudWithDictionary:(NSDictionary *)dic;

@end
