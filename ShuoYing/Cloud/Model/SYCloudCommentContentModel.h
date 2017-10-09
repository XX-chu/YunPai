//
//  SYCloudCommentContentModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/7/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYCloudCommentContentModel : NSObject

@property (nonatomic, copy) NSString *u_nick;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, strong) NSNumber *ID;

@property (nonatomic, strong) NSNumber *order;

@property (nonatomic, copy) NSString *u_head;

@property (nonatomic, strong) NSNumber *r_id;

@property (nonatomic, strong) NSNumber *u_id;

@property (nonatomic, copy) NSString *r_nick;

@property (nonatomic, copy) NSString *r_head;

@property (nonatomic, strong) NSNumber *pid;

+ (instancetype)commentContenWithDictionary:(NSDictionary *)dic;

@end
