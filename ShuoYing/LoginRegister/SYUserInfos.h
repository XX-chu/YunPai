//
//  SYUserInfos.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYUserInfos : NSObject<NSCoding>

@property (nonatomic, strong) NSNumber *userId;

@property (nonatomic, copy) NSString *user;//手机号

@property (nonatomic, copy) NSString *head;//头像地址

@property (nonatomic, strong) NSNumber *money;//余额

@property (nonatomic, copy) NSString *nick;//昵称

@property (nonatomic, copy) NSString *sex;//性别

@property (nonatomic, copy) NSString *info;//个人说明

@property (nonatomic, strong) NSNumber *idcard;//1已通过身份认证   0未通过认证

@property (nonatomic, strong) NSNumber *teacher;//0.资格被取消，新申请。1.认证通过，是老师。2.认证未通过，重新申请。3.认证中…

@property (nonatomic, strong) NSNumber *pho;//0.资格被取消，新申请。1.认证通过，是摄影师。2.认证未通过，重新申请。3.认证中…

@property (nonatomic, strong) NSNumber *pholv;//摄影师星级

@property (nonatomic, strong) NSNumber *teacherlv;//老师星级

- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (instancetype)userinfosWithDictionry:(NSDictionary *)dic;



@end
