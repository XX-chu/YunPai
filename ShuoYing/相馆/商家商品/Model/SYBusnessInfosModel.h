//
//  SYBusnessInfosModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/26.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBusnessInfosModel : NSObject

@property (nonatomic, strong) NSNumber *productID;

@property (nonatomic, strong) NSNumber *free;

@property (nonatomic, copy) NSString *fee_min;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, copy) NSString *money_min;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *money_max;

@property (nonatomic, copy) NSString *rule;

@property (nonatomic, copy) NSString *tel;

@property (nonatomic, copy) NSString *fee_max;

@property (nonatomic, strong) NSNumber *pid;

@property (nonatomic, strong) NSNumber *line;

@property (nonatomic, strong) NSArray *imgs;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *img_200;

@property (nonatomic, strong) NSNumber *jingdu;//精度

@property (nonatomic, strong) NSNumber *weidu;//纬度

@property (nonatomic, copy) NSString *name;

+ (instancetype)busnessInfosWithDictionary:(NSDictionary *)dic;

@end
