//
//  SYCommentModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/25.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYCommentModel : NSObject

@property (nonatomic, strong) NSArray *img_min;

@property (nonatomic, copy) NSString *nick;

@property (nonatomic, strong) NSNumber *ping;

@property (nonatomic, strong) NSNumber *commentID;

@property (nonatomic, strong) NSNumber *you;

@property (nonatomic, copy) NSString *date;

@property (nonatomic, copy) NSString *head;

@property (nonatomic, strong) NSNumber *wu;

@property (nonatomic, strong) NSArray *img_200;

@property (nonatomic, copy) NSString *info;

@property (nonatomic, strong) NSNumber *isSelecteYou;

@property (nonatomic, strong) NSNumber *isSelecteWu;


+ (instancetype)commentWithDictionary:(NSDictionary *)dic;

@end
