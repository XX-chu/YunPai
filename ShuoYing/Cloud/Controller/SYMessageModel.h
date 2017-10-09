//
//  SYMessageModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/3/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYMessageModel : NSObject

@property (nonatomic, copy) NSString *addtime;

@property (nonatomic, copy) NSString *messageID;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *msg;

@property (nonatomic, strong) NSNumber *state;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (instancetype)messageWithDictionary:(NSDictionary *)dic;

@end
