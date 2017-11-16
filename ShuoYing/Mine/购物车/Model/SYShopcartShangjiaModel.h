//
//  SYShopcartShangjiaModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/3.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYShopcartShangpinModel;
@interface SYShopcartShangjiaModel : NSObject<NSMutableCopying, NSCopying>

@property (nonatomic, strong) NSNumber *pid;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSArray<SYShopcartShangpinModel *> *goods;

@property (nonatomic, strong) NSNumber *isSelected;


@property (nonatomic, strong) NSNumber *express;

@property (nonatomic, strong) NSNumber *free;

+ (instancetype)cartShangJiaWithDictionary:(NSDictionary *)dic;

@end
