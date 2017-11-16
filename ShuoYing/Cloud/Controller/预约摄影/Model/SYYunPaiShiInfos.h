//
//  SYYunPaiShiInfos.h
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYYunPaiShiInfos : NSObject

@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *ModelNo;
@property (nonatomic, copy) NSString *yunpaishiID;
@property (nonatomic, copy) NSString *SerialNo;
@property (nonatomic, copy) NSString *ping;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *juli;
@property (nonatomic, copy) NSString *done;
@property (nonatomic, copy) NSString *money;
@property (nonatomic, copy) NSString *info;

+ (instancetype)yunpaishiWithDicaionary:(NSDictionary *)dic;


@end
